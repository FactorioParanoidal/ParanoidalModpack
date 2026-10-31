-- Windows of the item and the fluid memory units.
--
-- Item units: the plain unit replaces its chest window with an item window (one slot + this panel); logistic
-- units keep the chest window, which holds their logistic requests and storage filter, and get the panel beside
-- it. Fluid units: a screen frame instead of the tank window.
--
-- The windows are refreshed every 2 ticks only while one is open: storage.open_guis lists the players with a
-- window, the tick handler is registered while the list is not empty (and re-registered in on_load).

local shared = require "scripts.shared"
local item_unit = require "scripts.item-unit"
local fluid_unit = require "scripts.fluid-unit"
local variants = require "scripts.variants"

local M = {}

local ITEM_GUI = "pds_memory_unit_gui"
local FLUID_GUI = "pds_fluid_memory_unit_gui"
local NOT_WORKING = "utility/status_not_working"
local YELLOW = "utility/status_yellow"
local WORKING = "utility/status_working"
local EPSILON = shared.epsilon

local function is_logistic(name)
	local variant = variants.variants[name]
	return variant ~= nil and variant.logistic_mode ~= nil
end

local function format_energy(energy)
	return string.format("%.2f", energy * 60 / 1000000) .. "MW"
end

-- The windows are not closed by distance by the game: the mod does it.
local function out_of_reach(player, entity)
	return player.controller_type == defines.controllers.character and not player.can_reach_entity(entity)
end

-- Changes: in reach with a character, or in god/editor mode. Remote view is read-only.
local function can_access(player, entity)
	local controller = player.controller_type
	if controller == defines.controllers.character then return player.can_reach_entity(entity) end
	return controller == defines.controllers.god or controller == defines.controllers.editor
end

local function flying_text(player, text)
	player.create_local_flying_text {text = text, create_at_cursor = true}
end

-- Power bar and status line; the kind-specific status is given by `status_of` when the unit is powered.
local function update_power_and_status(content_flow, unit_data, status_of)
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	local electric_flow = content_flow.electric_flow
	local energy = powersource.energy
	local buffer_size = powersource.electric_buffer_size
	electric_flow.electricity.value = buffer_size > 0 and energy / buffer_size or 0
	electric_flow.consumption.caption = format_energy(energy) .. "/" .. format_energy(buffer_size)
	local factor = shared.unit_quality_factor(unit_data)
	electric_flow.consumption.tooltip = factor < 1 and {"mod-gui.quality-power-discount", math.floor((1 - factor) * 100 + 0.5)} or ""

	local status, img
	if entity.to_be_deconstructed() then
		status, img = {"entity-status.marked-for-deconstruction"}, NOT_WORKING
		electric_flow.consumption.caption = ""
	elseif energy == 0 then
		status, img = {"entity-status.no-power"}, NOT_WORKING
	else
		status, img = status_of()
		if not status then
			if energy < buffer_size * 0.9 then
				status, img = {"entity-status.low-power"}, YELLOW
			else
				status, img = {"entity-status.working"}, WORKING
			end
		end
	end
	content_flow.status_flow.status_text.caption = status
	content_flow.status_flow.status_sprite.sprite = img
end

-- Frame body shared by both windows: power bar, status line and the entity preview.
local function add_body(main_frame, entity, preview_visible)
	main_frame.style.width = 448
	local content_frame = main_frame.add {type = "frame", name = "content_frame", direction = "vertical", style = "inside_shallow_frame_with_padding"}
	local content_flow = content_frame.add {type = "flow", name = "content_flow", direction = "vertical"}
	content_flow.style.vertical_spacing = 8
	content_flow.style.margin = {-4, 0, -4, 0}
	content_flow.style.vertical_align = "center"

	local electric_flow = content_flow.add {type = "flow", name = "electric_flow", direction = "horizontal"}
	electric_flow.style.vertical_align = "center"
	electric_flow.style.horizontal_align = "right"
	electric_flow.style.width = 400
	electric_flow.style.bottom_margin = -32
	electric_flow.add {type = "label", name = "consumption"}.style.right_margin = 4
	electric_flow.add {type = "progressbar", name = "electricity", style = "electric_satisfaction_progressbar"}.style.width = 150

	local status_flow = content_flow.add {type = "flow", name = "status_flow", direction = "horizontal"}
	status_flow.style.vertical_align = "center"
	status_flow.style.top_margin = 4
	local status_sprite = status_flow.add {type = "sprite", name = "status_sprite"}
	status_sprite.resize_to_sprite = false
	status_sprite.style.size = {16, 16}
	status_flow.add {type = "label", name = "status_text"}

	local entity_preview = content_flow.add {type = "entity-preview", name = "entity_preview", style = "mu_entity_preview"}
	entity_preview.entity = entity
	entity_preview.visible = preview_visible
	entity_preview.style.height = 155

	local storage_flow = content_flow.add {type = "flow", name = "storage_flow", direction = "horizontal"}
	storage_flow.style.vertical_align = "center"
	storage_flow.add {type = "sprite-button", name = "content_sprite", style = "transparent_slot"}
	storage_flow.add {type = "label", name = "current_storage"}
	return content_flow
end

-- Open window bookkeeping and the conditional refresh handler.
local on_refresh_tick
local function sync_refresh_handler()
	script.on_nth_tick(2, next(storage.open_guis) and on_refresh_tick or nil)
end

local function mark_open(player)
	storage.open_guis[player.index] = true
	sync_refresh_handler()
end

function M.on_load()
	if storage.open_guis and next(storage.open_guis) then script.on_nth_tick(2, on_refresh_tick) end
end

---------------------------------------------------------------------------------------------------
-- Item units
---------------------------------------------------------------------------------------------------

local function close_item_gui(player)
	local gui = player.gui.relative[ITEM_GUI]
	local logistic = gui and gui.tags.logistic
	if gui then gui.destroy() end
	if logistic then
		if player.opened_gui_type == defines.gui_type.entity then player.opened = nil end
	elseif player.opened_gui_type == defines.gui_type.item then
		player.opened = nil
	end
end

-- The panel stays only while the window it belongs to is open.
local function item_gui_still_open(player, gui)
	if not gui.tags.logistic then return player.opened_gui_type == defines.gui_type.item end
	if player.opened_gui_type ~= defines.gui_type.entity then return false end
	local opened = player.opened
	return opened ~= nil and opened.valid and opened.unit_number == gui.tags.unit_number
end

local function update_item_gui(player, gui)
	local unit_data = storage.units[gui.tags.unit_number]
	if not (unit_data and unit_data.entity.valid) or out_of_reach(player, unit_data.entity) then
		close_item_gui(player)
		return
	end
	if not unit_data.powersource.valid then return end -- recreated by the next unit update
	local entity = unit_data.entity

	local content_flow = gui.content_frame.content_flow
	local access = can_access(player, entity)
	local item, quality = unit_data.item, unit_data.quality
	local locked = item ~= nil and prototypes.item[item] ~= nil
	local in_chest = locked and item_unit.inventory_count(unit_data) or 0
	local total = locked and (unit_data.count + in_chest) or 0

	content_flow.storage_flow.visible = locked
	content_flow.storage_seperator.visible = locked
	content_flow.io_flow.visible = locked
	content_flow.mu_no_input_item.visible = not locked
	content_flow.mu_no_input_item.enabled = access

	local item_name
	if locked then
		item_name = prototypes.item[item].localised_name
		local button = content_flow.storage_flow.content_sprite
		button.sprite = "item/" .. item
		button.quality = quality
		button.elem_tooltip = {type = "item-with-quality", name = item, quality = quality}
		local name = item_name
		if quality ~= "normal" and prototypes.quality[quality] then
			name = {"", item_name, " (", prototypes.quality[quality].localised_name, ")"}
		end
		local label = content_flow.storage_flow.current_storage
		label.caption = {"", "[font=default-semibold][color=255,230,192]", name, ":[/color][/font] ", shared.compactify(total)}
		-- The chest shows only its part (for logistic units, what robots can reach): say where the rest is.
		label.tooltip = {"mod-gui.exact-amount-split", shared.format_exact(total), shared.format_exact(in_chest), shared.format_exact(unit_data.count)}

		local io_flow = content_flow.io_flow
		io_flow.mu_bulk_insert.enabled = access and not unit_data.output_only
		io_flow.mu_bulk_extract.enabled = access
		io_flow.mu_reset_filter.visible = total == 0
		io_flow.mu_reset_filter.enabled = access
	end

	update_power_and_status(content_flow, unit_data, function()
		if not locked then
			local refused = item_unit.unsafe_item(unit_data)
			return refused and shared.refusal_text(refused) or {"entity-status.no-input-item"}, NOT_WORKING
		elseif unit_data.output_only then
			return {"entity-status.output-only", item_name}, YELLOW
		end
	end)
end

local function build_item_gui(player, entity)
	local unit_number = entity.unit_number
	local logistic = is_logistic(entity.name)
	local main_frame = player.gui.relative.add {
		type = "frame", name = ITEM_GUI, caption = {"entity-name." .. entity.name}, direction = "vertical",
		anchor = {
			gui = logistic and defines.relative_gui_type.container_gui or defines.relative_gui_type.item_with_inventory_gui,
			position = defines.relative_gui_position.right
		}
	}
	main_frame.tags = {unit_number = unit_number, logistic = logistic}
	-- The chest window of a logistic unit already shows the building.
	local content_flow = add_body(main_frame, entity, not logistic)
	content_flow.add {type = "line", name = "storage_seperator"}

	local tags = {unit_number = unit_number}
	local io_flow = content_flow.add {type = "flow", name = "io_flow", direction = "horizontal"}
	io_flow.style.vertical_align = "center"
	io_flow.add {type = "sprite-button", name = "mu_bulk_insert", style = "inventory_slot", sprite = "bulk-insert", tooltip = {"mod-gui.bulk-insert"}, tags = tags}
	io_flow.add {type = "sprite-button", name = "mu_bulk_extract", style = "inventory_slot", sprite = "bulk-extract", tooltip = {"mod-gui.bulk-extract"}, tags = tags}
	io_flow.add {type = "sprite-button", name = "mu_reset_filter", style = "inventory_slot", sprite = "utility/reset", tooltip = {"mod-gui.reset-filter"}, tags = tags}

	content_flow.add {type = "sprite-button", name = "mu_no_input_item", style = "inventory_slot", tooltip = {"mod-gui.no-input-item"}, tags = tags}
	return main_frame
end

local function get_item_unit(player, element)
	local unit_number = element.tags and element.tags.unit_number
	local unit_data = unit_number and storage.units[unit_number]
	if not unit_data then return nil end
	if not item_unit.ensure_valid(unit_data, unit_number) then return nil end
	if not can_access(player, unit_data.entity) then return nil end
	return unit_data, unit_number
end

local function bulk_io(player, element, event)
	local unit_data, unit_number = get_item_unit(player, element)
	if not (unit_data and unit_data.item) then return end
	local inventory = player.get_main_inventory()
	if not inventory then return end

	local item, quality = unit_data.item, unit_data.quality
	local stack_size = unit_data.stack_size
	local count = (event.button == defines.mouse_button_type.right) and stack_size * #inventory or stack_size

	if element.name == "mu_bulk_insert" then
		if unit_data.output_only then return end
		unit_data.count = unit_data.count + inventory.remove {name = item, count = count, quality = quality}
	else
		local unit_inventory = unit_data.inventory
		local available = unit_data.count + unit_inventory.get_item_count {name = item, quality = quality}
		count = math.min(count, available)
		if count == 0 then return end
		local inserted = inventory.insert {name = item, count = count, quality = quality}
		local from_counter = math.min(inserted, unit_data.count)
		unit_data.count = unit_data.count - from_counter
		if inserted > from_counter then
			unit_inventory.remove {name = item, count = inserted - from_counter, quality = quality}
		end
	end

	item_unit.update(unit_data, unit_number, true)
end

local function prime_unit(player, element)
	local unit_data, unit_number = get_item_unit(player, element)
	if not unit_data or unit_data.item then return end -- already locked (another player was faster)
	local stack = player.cursor_stack
	if not (stack and stack.valid_for_read) then return end

	if not shared.is_storable(stack.name) then
		flying_text(player, shared.refusal_text(stack.name))
		return
	end
	-- Locking spills other items from the chest: not allowed while it holds unstorable ones.
	local refused = item_unit.unsafe_item(unit_data)
	if refused then
		flying_text(player, shared.refusal_text(refused))
		return
	end

	local name, quality, count = stack.name, stack.quality.name, stack.count
	stack.clear()
	item_unit.lock(unit_data, name, quality)
	unit_data.count = unit_data.count + count
	item_unit.update(unit_data, unit_number, true)
end

local function reset_filter(player, element)
	local unit_data = get_item_unit(player, element)
	if not (unit_data and unit_data.item) then return end
	if unit_data.count ~= 0 or item_unit.inventory_count(unit_data) ~= 0 then return end
	item_unit.reset(unit_data)
end

local function open_item_gui(player, entity)
	-- A unit placed by a script without an event is registered on first use.
	if not storage.units[entity.unit_number] then item_unit.register(entity) end
	local old = player.gui.relative[ITEM_GUI]
	if old then old.destroy() end
	if not is_logistic(entity.name) then shared.open_inventory(player) end
	update_item_gui(player, build_item_gui(player, entity))
	mark_open(player)
end

---------------------------------------------------------------------------------------------------
-- Fluid units
---------------------------------------------------------------------------------------------------

local function fluid_gui_opened(player)
	if player.opened_gui_type ~= defines.gui_type.custom then return false end
	local opened = player.opened
	return opened ~= nil and opened.valid and opened.name == FLUID_GUI
end

local function close_fluid_gui(player)
	local gui = player.gui.screen[FLUID_GUI]
	if not gui then return end
	if fluid_gui_opened(player) then player.opened = nil end
	if gui.valid then gui.destroy() end
end

local function update_fluid_gui(player, gui)
	local unit_data = storage.fluid_units[gui.tags.unit_number]
	if not (unit_data and unit_data.entity.valid) or out_of_reach(player, unit_data.entity) then
		close_fluid_gui(player)
		return
	end
	if not unit_data.powersource.valid then return end -- recreated by the next unit update
	local entity = unit_data.entity

	local content_flow = gui.content_frame.content_flow
	local access = can_access(player, entity)
	local item = unit_data.item
	local locked = item ~= nil and prototypes.fluid[item] ~= nil
	local amount = locked and fluid_unit.buffer(unit_data) or 0
	local total = locked and (unit_data.count + amount) or 0
	local tank_empty = (entity.fluidbox[1] == nil)

	content_flow.storage_flow.visible = locked
	content_flow.temperature.visible = locked
	if locked then
		local localised_name = prototypes.fluid[item].localised_name
		local button = content_flow.storage_flow.content_sprite
		button.sprite = "fluid/" .. item
		button.elem_tooltip = {type = "fluid", name = item}
		local label = content_flow.storage_flow.current_storage
		label.caption = {"", "[font=default-semibold][color=255,230,192]", localised_name, ":[/color][/font] ", shared.compactify(total)}
		label.tooltip = {"mod-gui.exact-amount", shared.format_exact(total)}
		local temperature = unit_data.temperature or prototypes.fluid[item].default_temperature
		content_flow.temperature.caption = {"mod-gui.fluid-temperature", string.format("%.1f", temperature)}
	end

	local select_flow = content_flow.select_flow
	select_flow.visible = not locked and tank_empty
	select_flow.fmu_fluid_select.enabled = access
	content_flow.fmu_reset_fluid.visible = locked and total <= EPSILON
	content_flow.fmu_reset_fluid.enabled = access

	update_power_and_status(content_flow, unit_data, function()
		if not locked then return {"entity-status.no-input-fluid"}, NOT_WORKING end
	end)
end

local function build_fluid_gui(player, entity)
	local unit_number = entity.unit_number
	local main_frame = player.gui.screen.add {type = "frame", name = FLUID_GUI, caption = {"entity-name.fluid-memory-unit"}, direction = "vertical"}
	main_frame.tags = {unit_number = unit_number}
	main_frame.auto_center = true
	local content_flow = add_body(main_frame, entity, true)
	content_flow.add {type = "label", name = "temperature"}

	local tags = {unit_number = unit_number}
	local select_flow = content_flow.add {type = "flow", name = "select_flow", direction = "horizontal"}
	select_flow.style.vertical_align = "center"
	select_flow.add {
		type = "choose-elem-button",
		name = "fmu_fluid_select",
		elem_type = "fluid",
		elem_filters = {{filter = "hidden", invert = true}},
		tooltip = {"mod-gui.select-fluid"},
		tags = tags
	}
	select_flow.add {type = "label", caption = {"mod-gui.select-fluid"}}

	content_flow.add {type = "sprite-button", name = "fmu_reset_fluid", style = "inventory_slot", sprite = "utility/reset", tooltip = {"mod-gui.reset-fluid"}, tags = tags}

	player.opened = main_frame
	return main_frame
end

local function get_fluid_unit(player, element)
	local unit_number = element.tags and element.tags.unit_number
	local unit_data = unit_number and storage.fluid_units[unit_number]
	if not unit_data then return nil end
	if not fluid_unit.ensure_valid(unit_data, unit_number) then return nil end
	if not can_access(player, unit_data.entity) then return nil end
	return unit_data, unit_number
end

local function reset_fluid(player, element)
	local unit_data = get_fluid_unit(player, element)
	if not (unit_data and unit_data.item and unit_data.count <= EPSILON) then return end
	local amount = fluid_unit.buffer(unit_data)
	if amount > EPSILON then return end
	if amount > 0 then unit_data.entity.remove_fluid {name = unit_data.item, amount = amount} end
	fluid_unit.reset(unit_data)
end

local function open_fluid_gui(player, entity)
	-- A unit placed by a script without an event is registered on first use.
	if not storage.fluid_units[entity.unit_number] then fluid_unit.register(entity) end
	local old = player.gui.screen[FLUID_GUI]
	if old then old.destroy() end
	update_fluid_gui(player, build_fluid_gui(player, entity))
	mark_open(player)
end

---------------------------------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------------------------------

-- Refreshes the windows of one player; false when none is left.
local function refresh_player(player)
	local item_gui = player.gui.relative[ITEM_GUI]
	if item_gui then
		if item_gui_still_open(player, item_gui) then update_item_gui(player, item_gui) else item_gui.destroy() end
	end
	local fluid_gui = player.gui.screen[FLUID_GUI]
	if fluid_gui then
		if fluid_gui_opened(player) then
			update_fluid_gui(player, fluid_gui)
		else
			fluid_gui.destroy() -- left over, e.g. after loading a save
		end
	end
	return (item_gui ~= nil and item_gui.valid) or (fluid_gui ~= nil and fluid_gui.valid)
end

local function refresh_after_click(player)
	local item_gui = player.gui.relative[ITEM_GUI]
	if item_gui then update_item_gui(player, item_gui) end
	local fluid_gui = player.gui.screen[FLUID_GUI]
	if fluid_gui then update_fluid_gui(player, fluid_gui) end
end

on_refresh_tick = function()
	local open_guis = storage.open_guis
	for player_index in pairs(open_guis) do
		local player = game.get_player(player_index)
		if not (player and player.connected and refresh_player(player)) then
			if player then
				close_item_gui(player)
				close_fluid_gui(player)
			end
			open_guis[player_index] = nil
		end
	end
	if not next(open_guis) then sync_refresh_handler() end
end

local click_handlers = {
	mu_bulk_insert = bulk_io,
	mu_bulk_extract = bulk_io,
	mu_no_input_item = prime_unit,
	mu_reset_filter = reset_filter,
	fmu_reset_fluid = reset_fluid,
}

function M.on_gui_click(event)
	local element = event.element
	if not (element and element.valid) then return end
	local handler = click_handlers[element.name]
	if not handler or element.get_mod() ~= script.mod_name then return end
	local player = game.get_player(event.player_index)
	handler(player, element, event)
	refresh_after_click(player)
end

function M.on_gui_elem_changed(event)
	local element = event.element
	if not (element and element.valid and element.name == "fmu_fluid_select") then return end
	if element.get_mod() ~= script.mod_name then return end
	local player = game.get_player(event.player_index)
	local fluid = element.elem_value
	local unit_data, unit_number = get_fluid_unit(player, element)
	if fluid and unit_data and not unit_data.item and unit_data.entity.fluidbox[1] == nil and prototypes.fluid[fluid] then
		fluid_unit.lock(unit_data, fluid)
		fluid_unit.update(unit_data, unit_number, true)
	end
	element.elem_value = nil
	refresh_after_click(player)
end

function M.on_gui_opened(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid) then return end
	local name = entity.name
	if variants.variants[name] then
		open_item_gui(game.get_player(event.player_index), entity)
	elseif name == fluid_unit.name then
		open_fluid_gui(game.get_player(event.player_index), entity)
	end
end

function M.on_gui_closed(event)
	local player = game.get_player(event.player_index)
	local gui_type = event.gui_type
	if gui_type == defines.gui_type.custom then
		local element = event.element
		if element and element.valid and element.name == FLUID_GUI and element.get_mod() == script.mod_name then
			element.destroy()
		end
		return
	end
	local gui = player.gui.relative[ITEM_GUI]
	if not gui then return end
	if gui_type == defines.gui_type.item then
		if not gui.tags.logistic then gui.destroy() end
	elseif gui_type == defines.gui_type.entity then
		local entity = event.entity
		if gui.tags.logistic and not (entity and entity.valid and entity.unit_number ~= gui.tags.unit_number) then
			gui.destroy()
		end
	end
end

function M.on_player_changed_surface(event)
	local player = game.get_player(event.player_index)
	if player.gui.relative[ITEM_GUI] then close_item_gui(player) end
	close_fluid_gui(player)
end

function M.on_player_removed(event)
	storage.open_guis[event.player_index] = nil
	sync_refresh_handler()
end

return M
