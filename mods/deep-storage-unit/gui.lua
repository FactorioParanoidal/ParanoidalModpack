local shared = require "shared"
local compactify = shared.compactify
local update_power_usage = shared.update_power_usage

local function format_energy(energy)
	return string.format("%.2f", energy * 60 / 1000000) .. "MW"
end

local function update_gui(gui, fresh_gui)
	local unit_data = storage.units[gui.tags.unit_number]
	if not unit_data then
		gui.destroy()
		return
	end
	local content_flow = gui.content_frame.content_flow
	local entity = unit_data.entity
	local powersource = unit_data.powersource

	if not entity.valid or not powersource.valid then return end

	local count = unit_data.count
	local inventory = unit_data.inventory
	local deconstructed = entity.to_be_deconstructed()
	local inventory_count = 0
	if unit_data.item then
		inventory_count = inventory.get_item_count{
			name = unit_data.item,
			quality = unit_data.quality,
		}

		if fresh_gui or not deconstructed then
			content_flow.storage_flow.content_sprite.sprite = "item/" .. unit_data.item
			if unit_data.quality and prototypes.quality[unit_data.quality] and prototypes.quality[unit_data.quality].level ~= 0 then
				content_flow.storage_flow.current_storage.caption = {
					"",
					{"", "[font=default-semibold][color=255,230,192]", prototypes.item[unit_data.item].localised_name},
					{"", " (",                                          prototypes.quality[unit_data.quality].localised_name, ")"},
					{"", ":[/color][/font] ",                          compactify(count + inventory_count)}
				}
			else
				content_flow.storage_flow.current_storage.caption = {
					"",
					{"", "[font=default-semibold][color=255,230,192]", prototypes.item[unit_data.item].localised_name},
					{"", ":[/color][/font] ",                          compactify(count + inventory_count)}
				}
			end
		end
	end
	local visible = not not unit_data.item
	content_flow.storage_flow.visible = visible
	content_flow.storage_seperator.visible = visible
	content_flow.io_flow.visible = visible
	content_flow.no_input_item.visible = not visible

	content_flow.electric_flow.electricity.value = powersource.energy / powersource.electric_buffer_size
	content_flow.electric_flow.consumption.caption = format_energy(powersource.energy) .. "/" .. format_energy(powersource.electric_buffer_size)
	if unit_data.item then update_power_usage(unit_data, count + inventory_count) end

	local status, img
	if entity.to_be_deconstructed() then
		status = {"entity-status.marked-for-deconstruction"}
		img = "utility/status_not_working"
		content_flow.electric_flow.consumption.caption = ""
	elseif powersource.energy == 0 then
		status = {"entity-status.no-power"}
		img = "utility/status_not_working"
	elseif not unit_data.item then
		for _, itemstack in pairs(inventory.get_contents()) do
			local name = itemstack.name
			if shared.is_spoilable(name) then
				status = {"entity-status.cannot-store", prototypes.item[name].localised_name}
				img = "utility/status_not_working"
				content_flow.electric_flow.consumption.caption = ""
				goto cannot_store
			end
		end
		status = {"entity-status.no-input-item"}
		img = "utility/status_not_working"
		::cannot_store::
	elseif powersource.energy < powersource.electric_buffer_size * 0.9 then
		status = {"entity-status.low-power"}
		img = "utility/status_yellow"
	else
		status = {"entity-status.working"}
		img = "utility/status_working"
	end

	content_flow.status_flow.status_text.caption = status
	content_flow.status_flow.status_sprite.sprite = img
end

script.on_nth_tick(2, function(event)
	for _, player in pairs(game.connected_players) do
		if player.opened_gui_type == defines.gui_type.item then
			local gui = player.gui.relative.memory_unit_gui
			if gui then update_gui(gui) end
		end
	end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
	local player = game.get_player(event.player_index)
	if player.opened_gui_type == defines.gui_type.item then
		local gui = player.gui.relative.memory_unit_gui
		if gui then gui.destroy() end
	end
end)

script.on_event(defines.events.on_gui_opened, function(event)
	if event.gui_type ~= defines.gui_type.entity or not event.entity or event.entity.name ~= "memory-unit" then return end

	local player = game.get_player(event.player_index)
	local entity = event.entity
	shared.open_inventory(player)

	local main_frame = player.gui.relative.add {
		type = "frame", name = "memory_unit_gui", caption = {"entity-name.memory-unit"}, direction = "vertical",
		anchor = {
			gui = defines.relative_gui_type.item_with_inventory_gui,
			position = defines.relative_gui_position.right
		}
	}
	main_frame.style.width = 448
	main_frame.tags = {unit_number = entity.unit_number}

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
	local status_text = status_flow.add {type = "label", name = "status_text"}

	local entity_preview = content_flow.add {type = "entity-preview", name = "entity_preview", style = "mu_entity_preview"}
	entity_preview.entity = entity
	entity_preview.visible = true
	entity_preview.style.height = 155

	local storage_flow = content_flow.add {type = "flow", name = "storage_flow", direction = "horizontal"}
	storage_flow.style.vertical_align = "center"

	local content_sprite = storage_flow.add {type = "sprite", name = "content_sprite"}
	content_sprite.resize_to_sprite = false
	content_sprite.style.size = {32, 32}
	storage_flow.add {type = "label", name = "current_storage"}
	content_flow.add {type = "line", name = "storage_seperator"}

	local io_flow = content_flow.add {type = "flow", name = "io_flow", direction = "horizontal"}
	storage_flow.style.vertical_align = "center"
	local bulk_insert = io_flow.add {type = "sprite-button", name = "bulk_insert", style = "inventory_slot", sprite = "bulk-insert", tooltip = {"mod-gui.bulk-insert"}}
	bulk_insert.tags = {unit_number = entity.unit_number}
	local bulk_extract = io_flow.add {type = "sprite-button", name = "bulk_extract", style = "inventory_slot", sprite = "bulk-extract", tooltip = {"mod-gui.bulk-extract"}}
	bulk_extract.tags = {unit_number = entity.unit_number}

	local no_input_item = content_flow.add {type = "sprite-button", name = "no_input_item", style = "inventory_slot", tooltip = {"mod-gui.no-input-item"}}
	no_input_item.tags = {unit_number = entity.unit_number}

	update_gui(main_frame, true)
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local player = game.get_player(event.player_index)
	if event.gui_type == defines.gui_type.item then
		local gui = player.gui.relative.memory_unit_gui
		if gui then gui.destroy() end
	end
end)

local function bulk_io(event, element)
	local player = game.get_player(event.player_index)
	if player.controller_type == defines.controllers.remote then return end
	local inventory = player.get_main_inventory()
	if not inventory then return end
	local unit_data = storage.units[element.tags.unit_number]
	local item = unit_data.item
	if not item then return end

	local count = (event.button == defines.mouse_button_type.right) and unit_data.stack_size * #inventory or unit_data.stack_size
	local quality = unit_data.quality

	if element.name == "bulk_insert" then -- insert
		local amount_removed = inventory.remove {name = item, count = count, quality = quality}
		unit_data.count = unit_data.count + amount_removed
	elseif element.name == "bulk_extract" then -- extract
		local unit_inventory = unit_data.inventory
		local inventory_count = unit_inventory.get_item_count{
			name = item,
			quality = quality,
		}

		if inventory_count + unit_data.count < count then -- not enough items are in storage
			count = inventory_count + unit_data.count
		end

		if count == 0 then return end

		local amount_inserted = inventory.insert {name = item, count = count, quality = quality}
		unit_data.count = unit_data.count - amount_inserted
		if unit_data.count < 0 then
			unit_inventory.remove {name = item, count = -unit_data.count, quality = quality}
			unit_data.count = 0
		end
	end

	update_unit(unit_data, element.tags.unit_number, true)
end

local function prime_unit(event, element)
	local player = game.get_player(event.player_index)
	local stack = player.cursor_stack
	if not stack.valid_for_read then return end

	if shared.is_spoilable(stack.name) then
		player.create_local_flying_text {
			text = {"entity-status.cannot-store", prototypes.item[stack.name].localised_name},
			create_at_cursor = true,
		}
		return
	end

	local unit_data = storage.units[element.tags.unit_number]

	unit_data.count = stack.count
	unit_data.item = stack.name
	unit_data.quality = stack.quality.name
	unit_data.stack_size = stack.prototype.stack_size
	unit_data.comfortable = unit_data.stack_size * #unit_data.inventory / 2
	set_filter(unit_data)
	stack.clear()

	update_unit(unit_data, element.tags.unit_number, true)
	update_gui(player.gui.relative.memory_unit_gui)
end

script.on_event(defines.events.on_gui_click, function(event)
	local element = event.element
	if not element.tags or not element.tags.unit_number then return end
	if element.name == "bulk_insert" or element.name == "bulk_extract" then
		bulk_io(event, element)
	elseif element.name == "no_input_item" then
		prime_unit(event, element)
	end
end)
