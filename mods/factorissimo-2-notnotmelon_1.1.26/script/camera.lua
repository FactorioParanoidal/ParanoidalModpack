Camera = {}

local mod_gui = require 'mod-gui'
local get_factory_by_entity = remote_api.get_factory_by_entity
local find_surrounding_factory = remote_api.find_surrounding_factory

local function get_camera_toggle_button(player)
	local buttonflow = mod_gui.get_button_flow(player)
	local button = buttonflow.factory_camera_toggle_button or buttonflow.add{type='sprite-button', name='factory_camera_toggle_button', sprite='technology/factory-architecture-t1'}
	button.visible = player.force.technologies['factory-preview'].researched
	return button
end
Camera.get_camera_toggle_button = get_camera_toggle_button

local function get_camera_frame(player)
	local frameflow = mod_gui.get_frame_flow(player)
	local camera_frame = frameflow.factory_camera_frame
	if not camera_frame then
		camera_frame = frameflow.add{type = 'frame', name = 'factory_camera_frame', style = 'captionless_frame'}
		camera_frame.visible = false
	end
	return camera_frame
end

local function prepare_gui(player)
	get_camera_toggle_button(player)
	get_camera_frame(player)
end

local function init()
	for _, player in pairs(game.players) do
		prepare_gui(player)
	end
end
Camera.init = init

local function set_camera(player, factory, inside)
	if not player.force.technologies['factory-preview'].researched or factory.inactive then return end

	local ps = settings.get_player_settings(player)
	local ps_preview_size = ps['Factorissimo2-preview-size']
	local preview_size = ps_preview_size and ps_preview_size.value or 300
	local ps_preview_zoom = ps['Factorissimo2-preview-zoom']
	local preview_zoom = ps_preview_zoom and ps_preview_zoom.value or 1
	local position, surface_index, zoom
	if not inside then
		position = {x = factory.outside_x, y = factory.outside_y}
		surface_index = factory.outside_surface.index
		zoom = (preview_size/(32/preview_zoom))/(8+factory.layout.outside_size)
	else
		position = {x = factory.inside_x, y = factory.inside_y}
		surface_index = factory.inside_surface.index
		zoom = (preview_size/(32/preview_zoom))/(5+factory.layout.inside_size)
	end
	local camera_frame = get_camera_frame(player)
	local camera = camera_frame.factory_camera
	if camera then
		camera.position = position
		camera.surface_index = surface_index
		camera.zoom = zoom
		camera.style.minimal_width = preview_size
		camera.style.minimal_height = preview_size
		camera.ignored_by_interaction = true
	else
		local camera = camera_frame.add{type = 'camera', name = 'factory_camera', position = position, surface_index = surface_index, zoom = zoom}
		camera.style.minimal_width = preview_size
		camera.style.minimal_height = preview_size
		camera.ignored_by_interaction = true
	end
	camera_frame.ignored_by_interaction = true
	camera_frame.visible = true
end

local function unset_camera(player)
	get_camera_frame(player).visible = false
end

local function update_camera(player)
	if not global.player_preview_active[player.index] then return end
	if not player.force.technologies['factory-preview'].researched then return end
	local cursor_stack = player.cursor_stack
	if cursor_stack and
		cursor_stack.valid_for_read and
		cursor_stack.type == 'item-with-tags' and
		cursor_stack.tags and
		global.saved_factories[cursor_stack.tags.id] then
		local factory = global.saved_factories[cursor_stack.tags.id]
		if not factory.inactive then set_camera(player, factory, true) return end
	end
	local selected = player.selected
	if selected then
		local factory
		if selected.type == 'item-entity' and selected.stack.type == 'item-with-tags' and Layout.has_layout(selected.stack.name) then
			factory = global.saved_factories[selected.stack.tags.id]
		else
			factory = get_factory_by_entity(player.selected)
		end
		if factory and not factory.inactive then
			set_camera(player, factory, true)
			return
		elseif selected.name == 'factory-power-pole' then
			local factory = find_surrounding_factory(selected.surface, selected.position)
			if factory then
				Overlay.update_overlay(factory)
				set_camera(player, factory, false)
				return
			end
		end
	end
	unset_camera(player)
end
Camera.update_camera = update_camera

script.on_event(defines.events.on_player_created, function(event)
	prepare_gui(game.players[event.player_index])
end)

script.on_event(defines.events.on_gui_click, function(event)
	local player = game.players[event.player_index]
	if event.element.valid and event.element.name == 'factory_camera_toggle_button' then
		if global.player_preview_active[player.index] then
			get_camera_toggle_button(player).sprite = 'technology/factory-architecture-t1'
			global.player_preview_active[player.index] = false
			unset_camera(player)
		else
			get_camera_toggle_button(player).sprite = 'technology/factory-preview'
			global.player_preview_active[player.index] = true
			update_camera(player)
		end
	end
end) 
