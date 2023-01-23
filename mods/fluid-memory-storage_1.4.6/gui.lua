local shared = require 'shared'
local compactify = shared.compactify
local update_power_usage = shared.update_power_usage
local combine_tempatures = shared.combine_tempatures

local function format_energy(energy)
	return string.format('%.2f', energy * 60 / 1000000) .. 'MW'
end

local function update_gui(gui, fresh_gui)
	local unit_data = global.units[gui.tags.unit_number]
	if not unit_data then gui.destroy() return end
	local content_flow = gui.content_frame.content_flow
	local entity = unit_data.entity
	local powersource = unit_data.powersource
	
	if not entity.valid or not powersource.valid then return end
	
	local count = unit_data.count
	local deconstructed = entity.to_be_deconstructed()
	local inventory_count = 0
	if unit_data.item then
		inventory_count = entity.get_fluid_count(unit_data.item)
		if fresh_gui or not deconstructed then
			local localised_name = game.fluid_prototypes[unit_data.item].localised_name
			content_flow.storage_flow.content_sprite.sprite = 'fluid/' .. unit_data.item
			content_flow.storage_flow.current_storage.caption = {
				'',
				{'', '[font=default-semibold][color=255,230,192]', localised_name},
				{'', ':[/color][/font] ', compactify(count + inventory_count)}
			}
			local temperature = 0
			if inventory_count ~= 0 then
				temperature = combine_tempatures(unit_data.count, unit_data.temperature, inventory_count, entity.fluidbox[1].temperature)
			end
			content_flow.temperature.caption = {
				'',
				{'', '[font=default-semibold][color=255,230,192]', {'description.fluid-temperature', localised_name}},
				':[/color][/font] ' .. string.format('%.2f', temperature) .. ' °C'
			}
		end
	end
	local visible = not not unit_data.item
	content_flow.storage_flow.visible = visible
	content_flow.temperature.visible = visible
	
	content_flow.electric_flow.electricity.value = powersource.energy / powersource.electric_buffer_size
	content_flow.electric_flow.consumption.caption = format_energy(powersource.energy) .. '/' .. format_energy(powersource.electric_buffer_size)
	if unit_data.item then update_power_usage(unit_data, count + inventory_count) end
	
	local status, img
	if entity.to_be_deconstructed() then
		status = {'entity-status.marked-for-deconstruction'}
		img = 'utility/status_not_working'
		content_flow.electric_flow.consumption.caption = ''
	elseif powersource.energy == 0 then
		status = {'entity-status.no-power'}
		img = 'utility/status_not_working'
	elseif not unit_data.item then
		status = {'entity-status.no-input-fluid'}
		img = 'utility/status_not_working'
	elseif powersource.energy < powersource.electric_buffer_size * 0.9 then
		status = {'entity-status.low-power'}
		img = 'utility/status_yellow'
	else
		status = {'entity-status.working'}
		img = 'utility/status_working'
	end
	
	content_flow.status_flow.status_text.caption = status
	content_flow.status_flow.status_sprite.sprite = img
end

script.on_nth_tick(2, function(event)
	for _, player in pairs(game.connected_players) do
		if player.opened_gui_type == defines.gui_type.custom then
			local gui = player.gui.screen.fluid_memory_unit_gui
			if gui then update_gui(gui) end
		end
	end
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
	local player = game.get_player(event.player_index)
	if player.opened_gui_type == defines.gui_type.custom then
		local gui = player.gui.screen.fluid_memory_unit_gui
		if gui then gui.destroy() end
	end
end)

script.on_event(defines.events.on_gui_opened, function(event)
	local player = game.get_player(event.player_index)
	local entity = event.entity
                
	if event.gui_type ~= defines.gui_type.entity or not entity or entity.name ~= 'fluid-memory-unit' then return end
	
	local main_frame = player.gui.screen.add{type = 'frame', name = 'fluid_memory_unit_gui', caption = {'entity-name.fluid-memory-unit'}, direction = 'vertical'}
	main_frame.style.width = 448
	main_frame.tags = {unit_number = entity.unit_number}
	main_frame.auto_center = true
	player.opened = main_frame
               
	local content_frame = main_frame.add{type = 'frame', name = 'content_frame', direction = 'vertical', style = 'inside_shallow_frame_with_padding'}
	local content_flow = content_frame.add{type = 'flow', name = 'content_flow', direction = 'vertical'}
	content_flow.style.vertical_spacing = 8
	content_flow.style.margin = {-4, 0, -4, 0}
	content_flow.style.vertical_align = 'center'
	
	local electric_flow = content_flow.add{type = 'flow', name = 'electric_flow', direction = 'horizontal'}
	electric_flow.style.vertical_align = 'center'
	electric_flow.style.horizontal_align = 'right'
	electric_flow.style.width = 400
	electric_flow.style.bottom_margin = -32
	electric_flow.add{type = 'label', name = 'consumption'}.style.right_margin = 4
	electric_flow.add{type = 'progressbar', name = 'electricity', style = 'electric_satisfaction_progressbar'}.style.width = 150
               
	local status_flow = content_flow.add{type = 'flow', name = 'status_flow', direction = 'horizontal'}
	status_flow.style.vertical_align = 'center'
	status_flow.style.top_margin = 4
	local status_sprite = status_flow.add{type = 'sprite', name = 'status_sprite'}
	status_sprite.resize_to_sprite = false
	status_sprite.style.size = {16, 16}
	local status_text = status_flow.add{type = 'label', name = 'status_text'}
	
	local entity_preview = content_flow.add{type = 'entity-preview', name = 'entity_preview', style = 'mu_entity_preview'}
	entity_preview.entity = entity
	entity_preview.visible = true
	entity_preview.style.height = 155
	
	local storage_flow = content_flow.add{type = 'flow', name = 'storage_flow', direction = 'horizontal'}
	storage_flow.style.vertical_align = 'center'
	
	local content_sprite = storage_flow.add{type = 'sprite', name = 'content_sprite'}
	content_sprite.resize_to_sprite = false
	content_sprite.style.size = {32, 32}
	storage_flow.add{type = 'label', name = 'current_storage'}
	content_flow.add{type = 'label', name = 'temperature'}
	
	update_gui(main_frame, true)
end)

script.on_event(defines.events.on_gui_closed, function(event)
	local player = game.get_player(event.player_index)
	if event.gui_type == defines.gui_type.custom then
		local gui = player.gui.screen.fluid_memory_unit_gui
		if gui then gui.destroy() end
	end
end)
