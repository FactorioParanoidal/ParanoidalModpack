local shared = require "shared"
local unit = require "unit"
local variants = require "variants"

-- The plain unit replaces its chest window with an item window (one slot + this panel). Logistic units keep
-- the chest window, which holds their logistic requests and storage filter, and get this panel beside it.
local function is_logistic(name)
	local variant = variants.variants[name]
	return variant ~= nil and variant.logistic_mode ~= nil
end

local GUI_NAME = "memory_unit_gui"
local NOT_WORKING = "utility/status_not_working"
local YELLOW = "utility/status_yellow"
local WORKING = "utility/status_working"

local function format_energy(energy)
	return string.format("%.2f", energy * 60 / 1000000) .. "MW"
end

-- The GUI is an item GUI, so the game does not close it by distance: the mod does.
local function out_of_reach(player, entity)
	return player.controller_type == defines.controllers.character and not player.can_reach_entity(entity)
end

-- Item transfer: in reach with a character, or in god/editor mode. Remote view is read-only.
local function can_access(player, entity)
	local controller = player.controller_type
	if controller == defines.controllers.character then return player.can_reach_entity(entity) end
	return controller == defines.controllers.god or controller == defines.controllers.editor
end

local function close_gui(player)
	local gui = player.gui.relative[GUI_NAME]
	local logistic = gui and gui.tags.logistic
	if gui then gui.destroy() end
	if logistic then
		if player.opened_gui_type == defines.gui_type.entity then player.opened = nil end
	elseif player.opened_gui_type == defines.gui_type.item then
		player.opened = nil
	end
end

-- The panel stays only while the window it belongs to is open.
local function gui_still_open(player, gui)
	if not gui.tags.logistic then return player.opened_gui_type == defines.gui_type.item end
	if player.opened_gui_type ~= defines.gui_type.entity then return false end
	local opened = player.opened
	return opened ~= nil and opened.valid and opened.unit_number == gui.tags.unit_number
end

local function flying_text(player, text)
	player.create_local_flying_text {text = text, create_at_cursor = true}
end

local function update_gui(player, gui)
	local unit_number = gui.tags.unit_number
	local unit_data = storage.units[unit_number]
	if not (unit_data and unit_data.entity.valid) or out_of_reach(player, unit_data.entity) then
		close_gui(player)
		return
	end
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	if not powersource.valid then return end -- recreated by the next unit update

	local content_flow = gui.content_frame.content_flow
	local access = can_access(player, entity)
	local item, quality = unit_data.item, unit_data.quality
	local locked = item ~= nil and prototypes.item[item] ~= nil
	local in_chest = locked and unit.inventory_count(unit_data) or 0
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

	local electric_flow = content_flow.electric_flow
	local buffer_size = powersource.electric_buffer_size
	electric_flow.electricity.value = buffer_size > 0 and powersource.energy / buffer_size or 0
	electric_flow.consumption.caption = format_energy(powersource.energy) .. "/" .. format_energy(buffer_size)
	local factor = shared.quality_factor(entity.quality.name)
	electric_flow.consumption.tooltip = factor < 1 and {"mod-gui.quality-power-discount", math.floor((1 - factor) * 100 + 0.5)} or ""

	local status, img
	if entity.to_be_deconstructed() then
		status = {"entity-status.marked-for-deconstruction"}
		img = NOT_WORKING
		electric_flow.consumption.caption = ""
	elseif powersource.energy == 0 then
		status = {"entity-status.no-power"}
		img = NOT_WORKING
	elseif not locked then
		local refused = unit.unsafe_item(unit_data)
		status = refused and shared.refusal_text(refused) or {"entity-status.no-input-item"}
		img = NOT_WORKING
	elseif unit_data.output_only then
		status = {"entity-status.output-only", item_name}
		img = YELLOW
	elseif powersource.energy < buffer_size * 0.9 then
		status = {"entity-status.low-power"}
		img = YELLOW
	else
		status = {"entity-status.working"}
		img = WORKING
	end

	content_flow.status_flow.status_text.caption = status
	content_flow.status_flow.status_sprite.sprite = img
end

local function build_gui(player, entity)
	local unit_number = entity.unit_number
	local logistic = is_logistic(entity.name)
	local main_frame = player.gui.relative.add {
		type = "frame", name = GUI_NAME, caption = {"entity-name." .. entity.name}, direction = "vertical",
		anchor = {
			gui = logistic and defines.relative_gui_type.container_gui or defines.relative_gui_type.item_with_inventory_gui,
			position = defines.relative_gui_position.right
		}
	}
	main_frame.style.width = 448
	main_frame.tags = {unit_number = unit_number, logistic = logistic}

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
	-- The chest window of a logistic unit already shows the building.
	entity_preview.visible = not logistic
	entity_preview.style.height = 155

	local storage_flow = content_flow.add {type = "flow", name = "storage_flow", direction = "horizontal"}
	storage_flow.style.vertical_align = "center"
	storage_flow.add {type = "sprite-button", name = "content_sprite", style = "transparent_slot"}
	storage_flow.add {type = "label", name = "current_storage"}
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

local function get_unit(player, element)
	local unit_number = element.tags and element.tags.unit_number
	local unit_data = unit_number and storage.units[unit_number]
	if not unit_data then return nil end
	if not unit.ensure_valid(unit_data, unit_number) then return nil end
	if not can_access(player, unit_data.entity) then return nil end
	return unit_data, unit_number
end

local function bulk_io(player, element, event)
	local unit_data, unit_number = get_unit(player, element)
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

	unit.update(unit_data, unit_number, true)
end

local function prime_unit(player, element)
	local unit_data, unit_number = get_unit(player, element)
	if not unit_data or unit_data.item then return end -- already locked (another player was faster)
	local stack = player.cursor_stack
	if not (stack and stack.valid_for_read) then return end

	if not shared.is_storable(stack.name) then
		flying_text(player, shared.refusal_text(stack.name))
		return
	end
	-- Locking spills other items from the chest: not allowed while it holds unstorable ones.
	local refused = unit.unsafe_item(unit_data)
	if refused then
		flying_text(player, shared.refusal_text(refused))
		return
	end

	local name, quality, count = stack.name, stack.quality.name, stack.count
	stack.clear()
	unit.lock(unit_data, name, quality)
	unit_data.count = unit_data.count + count
	unit.update(unit_data, unit_number, true)
end

local function reset_filter(player, element)
	local unit_data = get_unit(player, element)
	if not (unit_data and unit_data.item) then return end
	if unit_data.count ~= 0 or unit.inventory_count(unit_data) ~= 0 then return end
	unit.reset(unit_data)
end

local click_handlers = {
	mu_bulk_insert = bulk_io,
	mu_bulk_extract = bulk_io,
	mu_no_input_item = prime_unit,
	mu_reset_filter = reset_filter,
}

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if not (element and element.valid) then return end
	local handler = click_handlers[element.name]
	if not handler or element.get_mod() ~= script.mod_name then return end
	local player = game.get_player(event.player_index)
	handler(player, element, event)
	local gui = player.gui.relative[GUI_NAME]
	if gui then update_gui(player, gui) end
end)

script.on_nth_tick(2, function()
	for _, player in pairs(game.connected_players) do
		local gui = player.gui.relative[GUI_NAME]
		if gui then
			if gui_still_open(player, gui) then
				update_gui(player, gui)
			else
				gui.destroy()
			end
		end
	end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
	local player = game.get_player(event.player_index)
	if player.gui.relative[GUI_NAME] then close_gui(player) end
end)

script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid and variants.variants[entity.name]) then return end

	local player = game.get_player(event.player_index)
	-- A unit placed by a script without an event is registered on first use.
	if not storage.units[entity.unit_number] then unit.register(entity) end

	local old = player.gui.relative[GUI_NAME]
	if old then old.destroy() end
	if not is_logistic(entity.name) then shared.open_inventory(player) end
	update_gui(player, build_gui(player, entity))
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local player = game.get_player(event.player_index)
	local gui = player.gui.relative[GUI_NAME]
	if not gui then return end
	if event.gui_type == defines.gui_type.item then
		if not gui.tags.logistic then gui.destroy() end
	elseif event.gui_type == defines.gui_type.entity then
		local entity = event.entity
		if gui.tags.logistic and not (entity and entity.valid and entity.unit_number ~= gui.tags.unit_number) then
			gui.destroy()
		end
	end
end)
