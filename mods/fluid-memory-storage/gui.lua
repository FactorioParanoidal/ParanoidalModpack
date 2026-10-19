local shared = require "shared"
local unit = require "unit"

local GUI_NAME = "fluid_memory_unit_gui"
local NOT_WORKING = "utility/status_not_working"
local YELLOW = "utility/status_yellow"
local WORKING = "utility/status_working"
local EPSILON = shared.epsilon

local function format_energy(energy)
	return string.format("%.2f", energy * 60 / 1000000) .. "MW"
end

-- The GUI replaces the tank GUI, so the game does not close it by distance: the mod does.
local function out_of_reach(player, entity)
	return player.controller_type == defines.controllers.character and not player.can_reach_entity(entity)
end

-- Changes (fluid choice, reset): in reach with a character, or in god/editor mode.
local function can_access(player, entity)
	local controller = player.controller_type
	if controller == defines.controllers.character then return player.can_reach_entity(entity) end
	return controller == defines.controllers.god or controller == defines.controllers.editor
end

local function is_opened(player)
	if player.opened_gui_type ~= defines.gui_type.custom then return false end
	local opened = player.opened
	return opened ~= nil and opened.valid and opened.name == GUI_NAME
end

local function close_gui(player)
	local gui = player.gui.screen[GUI_NAME]
	if not gui then return end
	if is_opened(player) then player.opened = nil end
	if gui.valid then gui.destroy() end
end

local function update_gui(player, gui)
	local unit_data = storage.units[gui.tags.unit_number]
	if not (unit_data and unit_data.entity.valid) or out_of_reach(player, unit_data.entity) then
		close_gui(player)
		return
	end
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	if not powersource.valid then return end -- recreated by the next unit update

	local content_flow = gui.content_frame.content_flow
	local access = can_access(player, entity)
	local item = unit_data.item
	local locked = item ~= nil and prototypes.fluid[item] ~= nil
	local amount = locked and unit.buffer(unit_data) or 0
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
		status = {"entity-status.no-input-fluid"}
		img = NOT_WORKING
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
	local main_frame = player.gui.screen.add {type = "frame", name = GUI_NAME, caption = {"entity-name.fluid-memory-unit"}, direction = "vertical"}
	main_frame.style.width = 448
	main_frame.tags = {unit_number = unit_number}
	main_frame.auto_center = true

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
	entity_preview.visible = true
	entity_preview.style.height = 155

	local storage_flow = content_flow.add {type = "flow", name = "storage_flow", direction = "horizontal"}
	storage_flow.style.vertical_align = "center"
	storage_flow.add {type = "sprite-button", name = "content_sprite", style = "transparent_slot"}
	storage_flow.add {type = "label", name = "current_storage"}
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

local function get_unit(player, element)
	local unit_number = element.tags and element.tags.unit_number
	local unit_data = unit_number and storage.units[unit_number]
	if not unit_data then return nil end
	if not unit.ensure_valid(unit_data, unit_number) then return nil end
	if not can_access(player, unit_data.entity) then return nil end
	return unit_data, unit_number
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
	local element = event.element
	if not (element and element.valid and element.name == "fmu_fluid_select") then return end
	if element.get_mod() ~= script.mod_name then return end
	local player = game.get_player(event.player_index)
	local fluid = element.elem_value
	local unit_data, unit_number = get_unit(player, element)
	if fluid and unit_data and not unit_data.item and unit_data.entity.fluidbox[1] == nil and prototypes.fluid[fluid] then
		unit.lock(unit_data, fluid)
		unit.update(unit_data, unit_number, true)
	end
	element.elem_value = nil
	local gui = player.gui.screen[GUI_NAME]
	if gui then update_gui(player, gui) end
end)

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if not (element and element.valid and element.name == "fmu_reset_fluid") then return end
	if element.get_mod() ~= script.mod_name then return end
	local player = game.get_player(event.player_index)
	local unit_data = get_unit(player, element)
	if unit_data and unit_data.item and unit_data.count <= EPSILON then
		local amount = unit.buffer(unit_data)
		if amount <= EPSILON then
			if amount > 0 then unit_data.entity.remove_fluid {name = unit_data.item, amount = amount} end
			unit.reset(unit_data)
		end
	end
	local gui = player.gui.screen[GUI_NAME]
	if gui then update_gui(player, gui) end
end)

script.on_nth_tick(2, function()
	for _, player in pairs(game.connected_players) do
		local gui = player.gui.screen[GUI_NAME]
		if gui then
			if is_opened(player) then
				update_gui(player, gui)
			else
				gui.destroy() -- left over, e.g. after loading a save
			end
		end
	end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
	close_gui(game.get_player(event.player_index))
end)

script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type ~= defines.gui_type.entity then return end
	local entity = event.entity
	if not (entity and entity.valid and entity.name == "fluid-memory-unit") then return end

	local player = game.get_player(event.player_index)
	-- A unit placed by a script without an event is registered on first use.
	if not storage.units[entity.unit_number] then unit.register(entity) end

	local old = player.gui.screen[GUI_NAME]
	if old then old.destroy() end
	update_gui(player, build_gui(player, entity))
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if event.gui_type ~= defines.gui_type.custom then return end
	local element = event.element
	if element and element.valid and element.name == GUI_NAME and element.get_mod() == script.mod_name then
		element.destroy()
	end
end)
