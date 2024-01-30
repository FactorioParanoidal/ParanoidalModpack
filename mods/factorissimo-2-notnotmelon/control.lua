require 'util'

local remote_api = require 'script.lib'
local get_factory_by_entity = remote_api.get_factory_by_entity
local get_factory_by_building = remote_api.get_factory_by_building
local find_factory_by_building = remote_api.find_factory_by_building
local find_surrounding_factory = remote_api.find_surrounding_factory
local power_middleman_surface = remote_api.power_middleman_surface
local BUILDING_TYPE = BUILDING_TYPE

require 'script.layout'
local has_layout = Layout.has_layout
require 'script.connections.connections'
require 'script.updates'
require 'script.blueprint'
require 'script.camera'
require 'script.travel'
require 'script.overlay'
require 'script.pollution'
require 'compat.factoriomaps'

local update_hidden_techs = nil -- Function stub
local activate_factories = nil -- Function stub

-- INITIALIZATION --

local function init_globals()
	Layout.init()
	-- List of all factories
	global.factories = global.factories or {}
	-- Map: Id from item-with-tags -> Factory
	global.saved_factories = global.saved_factories or {}
	-- Map: Player or robot -> Save name to give him on the next relevant event
	global.pending_saves = global.pending_saves or {}
	-- Map: Entity unit number -> Factory it is a part of
	global.factories_by_entity = global.factories_by_entity or {}
	-- Map: Surface name -> list of factories on it
	global.surface_factories = global.surface_factories or {}
	-- Map: Surface name -> number of used factory spots on it
	global.surface_factory_counters = global.surface_factory_counters or {}
	-- Scalar
	global.next_factory_surface = global.next_factory_surface or 0
	-- Map: Player index -> Last teleport time
	global.last_player_teleport = global.last_player_teleport or {}
	-- Map: Player index -> Whether preview is activated
	global.player_preview_active = global.player_preview_active or {}
	-- List of all factory power pole middlemen
	global.middleman_power_poles = global.middleman_power_poles or {}
	-- Map: Surface name -> Whether radars are active
	global.hidden_radars = global.hidden_radars or {}

	-- List of all spidertrons
	global.spidertrons = {}
	for _, surface in pairs(game.surfaces) do
		for _, spider in pairs(surface.find_entities_filtered{type = 'spider-vehicle'}) do
			if spider.name ~= 'companion' then
				global.spidertrons[#global.spidertrons + 1] = spider
				script.register_on_entity_destroyed(spider)
			end
		end
	end
	
	if remote.interfaces['PickerDollies'] then
		remote.call('PickerDollies', 'add_blacklist_name', 'factory-1', true)
		remote.call('PickerDollies', 'add_blacklist_name', 'factory-2', true)
		remote.call('PickerDollies', 'add_blacklist_name', 'factory-3', true)
	end
end

script.on_init(function()
	init_globals()
	Connections.init_data_structure()
	Updates.init()
	Camera.init()
	power_middleman_surface()
	for _, force in pairs(game.forces) do
		update_hidden_techs(force)
	end
	Compat.handle_factoriomaps()
end)

script.on_load(function()
	Compat.handle_factoriomaps()
end)

script.on_configuration_changed(function(config_changed_data)
	init_globals()
	Updates.run()
	Camera.init()
	power_middleman_surface()
	activate_factories()
	if remote.interfaces['RSO'] then -- RSO compatibility
		for surface_name, _ in pairs(global.surface_factories or {}) do
			pcall(remote.call, 'RSO', 'ignoreSurface', surface_name)
		end
	end
	global.items_with_metadata = nil
end)

-- POWER MANAGEMENT --

-- disconnects a factory's power pole from the "direct connection pole" aka the pole on the outside surface
local function remove_direct_connection(factory)
	local dc = factory.direct_connection
	if not dc or not dc.valid then return end

	for _, pole in pairs(factory.inside_power_poles) do
		for _, neighbour in pairs(pole.neighbours.copper) do
			if neighbour == dc then
				local old = {}
				for _, neighbour in ipairs(dc.neighbours.copper) do
					if neighbour ~= pole and neighbour.type ~= 'power-switch' then
						old[#old + 1] = neighbour
					end
				end
				dc.disconnect_neighbour()
				for _, neighbour in ipairs(old) do dc.connect_neighbour(neighbour) end
				factory.direct_connection = nil
				return
			end
		end
	end
end

local function delete_middleman(i)
	local pole = global.middleman_power_poles[i]
	if pole == 0 then return end
	global.middleman_power_poles[i] = i < #global.middleman_power_poles and 0 or nil
	pole.destroy()
	for _, factory in pairs(global.factories) do
		if factory.middleman_id == i then
			factory.middleman_id = nil
		end
	end
end

local function cleanup_middlemen()
	for i, pole in ipairs(global.middleman_power_poles) do
		if pole ~= 0 and #pole.neighbours.copper < 2 then delete_middleman(i) end
	end
end

local function available_pole(factory)
	local poles = factory.inside_power_poles
	for i, pole in ipairs(poles) do
		local next = poles[i+1]
		if next then
			next.connect_neighbour(pole)
		end
	end

	for i, pole in ipairs(poles) do
		if #pole.neighbours.copper < (i == #poles and 4 or 5) then return pole end
	end

	local layout = factory.layout
	local pole = factory.inside_surface.create_entity{name='factory-overflow-pole', position=poles[1].position, force=poles[1].force}
	pole.destructible = false
	pole.disconnect_neighbour()
	pole.connect_neighbour(poles[#poles])
	table.insert(poles, pole)
	return pole
end

local function connect_power(factory, pole)
	if #pole.neighbours.copper == 5 then
		pole.surface.create_entity{name = 'flying-text', position = pole.position, text = {'electric-pole-wire-limit-reached'}}
		return
	end
	factory.outside_power_pole = pole

	if factory.inside_surface.name ~= pole.surface.name then
		available_pole(factory).connect_neighbour(pole)
		factory.direct_connection = pole
		return
	end

    local n
	for i, pole in ipairs(global.middleman_power_poles) do
		if pole == 0 then n = i break end
	end
	n = n or #global.middleman_power_poles + 1

	local surface = power_middleman_surface()
	local middleman = surface.create_entity{name = 'factory-power-connection', position = {2*(n%32), 2*math.floor(n/32)}, force = 'neutral'}
	middleman.destructible = false
	global.middleman_power_poles[n] = middleman

	middleman.connect_neighbour(available_pole(factory))
	middleman.connect_neighbour(pole)

	factory.middleman_id = n
end

function update_power_connection(factory, pole) -- pole parameter is optional
	local electric_network = factory.outside_energy_receiver.electric_network_id
	if electric_network == nil then return end
	local surface = factory.outside_surface
	local x = factory.outside_x
	local y = factory.outside_y

    if not script.active_mods['factorissimo-power-pole-addon'] and global.surface_factory_counters[surface.name] then
		local surrounding = find_surrounding_factory(surface, {x = x, y = y})
		if surrounding then
			connect_power(factory, available_pole(surrounding))
			return
		end
	end

	-- find the nearest connected power pole
	local D = game.max_electric_pole_supply_area_distance + factory.layout.outside_size / 2
	local candidates = {}
	for _, entity in ipairs(surface.find_entities_filtered{type='electric-pole', area={{x-D, y-D}, {x+D,y+D}}}) do
		if entity.electric_network_id == electric_network and entity ~= pole then
			candidates[#candidates+1] = entity
		end
	end

	if #candidates == 0 then return end
	connect_power(factory, surface.get_closest({x, y}, candidates))
end

local function get_factories_near_pole(pole)
	local D = pole.prototype.supply_area_distance
    if D == 0 then return {} end
    D = D + 1
	local position = pole.position
	local x = position.x
	local y = position.y

	local result = {}
	for _, candidate in ipairs(pole.surface.find_entities_filtered{type=BUILDING_TYPE, area={{x-D, y-D}, {x+D,y+D}}}) do
		if has_layout(candidate.name) then result[#result + 1] = get_factory_by_building(candidate) end
	end
	return result
end

local function power_pole_placed(pole)
	for _, factory in ipairs(get_factories_near_pole(pole)) do
		local electric_network = factory.outside_energy_receiver.electric_network_id
		if electric_network == nil or electric_network ~= pole.electric_network_id then goto continue end
		if not factory.inside_power_poles[1].valid then goto continue end
		if electric_network == factory.inside_power_poles[1].electric_network_id then goto continue end
		connect_power(factory, pole)

		::continue::
	end
end

local function power_pole_destroyed(pole)
	local old_neighbours = {}
	for _, neighbour in pairs(pole.neighbours.copper) do
		if neighbour.surface == pole.surface and neighbour.type ~= 'power-switch' then
			old_neighbours[#old_neighbours + 1] = neighbour
		end
	end

	pole.disconnect_neighbour()
	for _, factory in ipairs(get_factories_near_pole(pole)) do
		update_power_connection(factory, pole)
	end
	cleanup_middlemen()

	for _, neighbour in pairs(old_neighbours) do
		pole.connect_neighbour(neighbour)
	end
end

script.on_event(defines.events.on_player_selected_area, function(event)
	if event.item == 'power-grid-comb' then
		for _, building in pairs(event.entities) do
			if has_layout(building.name) then
				local factory = get_factory_by_building(building)
				if factory then update_power_connection(factory) end
			end
		end
	end
end)

-- prevent SHIFT+CLICK on factory power poles
script.on_event({defines.events.on_selected_entity_changed, defines.events.on_player_cursor_stack_changed}, function(event)
	local player = game.get_player(event.player_index)
	local pole = player.selected
	if pole and pole.type == 'electric-pole' then
		local permission = player.permission_group
		if not permission then
			permission = game.permissions.create_group()
			player.permission_group = permission
		end

		local has_cross_surface_connections = false
		for _, neighbour in pairs(pole.neighbours.copper) do
			if neighbour.surface ~= pole.surface then
				has_cross_surface_connections = true
				break
			end
		end
		permission.set_allows_action(defines.input_action.remove_cables, not has_cross_surface_connections)
	end

	Camera.update_camera(player) -- also update camera here
end)

-- FACTORY UPGRADES --

local function build_lights_upgrade(factory)
	if factory.upgrades.lights then return end
	factory.upgrades.lights = true
	factory.inside_surface.daytime = 1
end

-- FACTORY GENERATION --

local function update_destructible(factory)
	if factory.built and factory.building.valid then
		factory.building.destructible = not settings.global['Factorissimo2-indestructible-buildings'].value
	end
end

local function create_factory_position(layout)
	global.next_factory_surface = global.next_factory_surface + 1
	if (settings.global['Factorissimo2-same-surface'].value) then
		global.next_factory_surface = 1
	end
	local surface_name = 'factory-floor-' .. global.next_factory_surface
	local surface = game.surfaces[layout.surface_override or surface_name]
	if surface == nil then
        surface = game.create_surface(surface_name, {width = 2, height = 2})
        surface.daytime = 0.5
        surface.freeze_daytime = true
        if remote.interfaces['RSO'] then -- RSO compatibility
            pcall(remote.call, 'RSO', 'ignoreSurface', surface_name)
        end
	end
	local n = global.surface_factory_counters[surface_name] or 0
	global.surface_factory_counters[surface_name] = n+1
	local cx = 16*(n % 8)
	local cy = 16*math.floor(n / 8)

	-- To make void chunks show up on the map, you need to tell them they've finished generating.
	surface.set_chunk_generated_status({cx-2, cy-2}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-1, cy-2}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+0, cy-2}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+1, cy-2}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-2, cy-1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-1, cy-1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+0, cy-1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+1, cy-1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-2, cy+0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-1, cy+0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+0, cy+0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+1, cy+0}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-2, cy+1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx-1, cy+1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+0, cy+1}, defines.chunk_generated_status.entities)
	surface.set_chunk_generated_status({cx+1, cy+1}, defines.chunk_generated_status.entities)
	surface.destroy_decoratives{area={{32*(cx-2),32*(cy-2)},{32*(cx+2),32*(cy+2)}}}

	local factory = {}
	factory.inside_surface = surface
	factory.inside_x = 32*cx
	factory.inside_y = 32*cy
	factory.stored_pollution = 0
	factory.upgrades = {}

	global.surface_factories[surface_name] = global.surface_factories[surface_name] or {}
	global.surface_factories[surface_name][n+1] = factory
	local fn = #(global.factories)+1
	global.factories[fn] = factory
	factory.id = fn

	return factory
end

local function add_tile_rect(tiles, tile_name, xmin, ymin, xmax, ymax) -- tiles is rw
	local i = #tiles
	for x = xmin, xmax-1 do
		for y = ymin, ymax-1 do
			i = i + 1
			tiles[i] = {name = tile_name, position = {x, y}}
		end
	end
end

local function add_tile_mosaic(tiles, tile_name, xmin, ymin, xmax, ymax, pattern) -- tiles is rw
	local i = #tiles
	for x = 0, xmax-xmin-1 do
		for y = 0, ymax-ymin-1 do
			if (string.sub(pattern[y+1],x+1, x+1) == '+') then
				i = i + 1
				tiles[i] = {name = tile_name, position = {x+xmin, y+ymin}}
			end
		end
	end
end

local function create_factory_interior(layout, force)
	local factory = create_factory_position(layout)
	factory.layout = layout
	factory.force = force
	factory.inside_door_x = layout.inside_door_x + factory.inside_x
	factory.inside_door_y = layout.inside_door_y + factory.inside_y
	local tiles = {}
	for _, rect in pairs(layout.rectangles) do
		add_tile_rect(tiles, rect.tile, rect.x1 + factory.inside_x, rect.y1 + factory.inside_y, rect.x2 + factory.inside_x, rect.y2 + factory.inside_y)
	end
	for _, mosaic in pairs(layout.mosaics) do
		add_tile_mosaic(tiles, mosaic.tile, mosaic.x1 + factory.inside_x, mosaic.y1 + factory.inside_y, mosaic.x2 + factory.inside_x, mosaic.y2 + factory.inside_y, mosaic.pattern)
	end
	for _, cpos in pairs(layout.connections) do
		table.insert(tiles, {name = layout.connection_tile, position = {factory.inside_x + cpos.inside_x, factory.inside_y + cpos.inside_y}})
	end
	factory.inside_surface.set_tiles(tiles)

	local power_pole = factory.inside_surface.create_entity{
        name = 'factory-power-pole',
        position = {factory.inside_x + layout.inside_energy_x, factory.inside_y + layout.inside_energy_y},
        force = force
    }
	power_pole.destructible = false
	factory.inside_power_poles = {power_pole}

    local radar = factory.inside_surface.create_entity{
        name = 'factory-hidden-radar',
        position = {factory.inside_x, factory.inside_y},
        force = force
    }
    radar.destructible = false
	radar.active = false
	factory.radar = radar

	if force.technologies['factory-interior-upgrade-lights'].researched then
		build_lights_upgrade(factory)
	end

	factory.inside_overlay_controllers = {}

	if force.technologies['factory-interior-upgrade-display'].researched then
		Overlay.build_display_upgrade(factory)
	end

	factory.connections = {}
	factory.connection_settings = {}
	factory.connection_indicators = {}

	return factory
end

local function create_factory_exterior(factory, building)
	local layout = factory.layout
	local force = factory.force
	factory.outside_x = building.position.x
	factory.outside_y = building.position.y
	factory.outside_door_x = factory.outside_x + layout.outside_door_x
	factory.outside_door_y = factory.outside_y + layout.outside_door_y
	factory.outside_surface = building.surface

	local oer = factory.outside_surface.create_entity{name = layout.outside_energy_receiver_type, position = {factory.outside_x, factory.outside_y}, force = force}
	oer.destructible = false
	oer.operable = false
	oer.rotatable = false
	factory.outside_energy_receiver = oer

	factory.outside_overlay_displays = {}
	factory.outside_port_markers = {}

	global.factories_by_entity[building.unit_number] = factory
	factory.building = building
	factory.built = true

	Connections.recheck_factory(factory, nil, nil)
	update_power_connection(factory)
	Overlay.update_overlay(factory)
	update_destructible(factory)
	return factory
end

local function toggle_port_markers(factory)
	if not factory.built then return end
	if #(factory.outside_port_markers) == 0 then
		for id, cpos in pairs(factory.layout.connections) do
			local sprite_data = {
				sprite = 'utility/indication_arrow',
				orientation = cpos.direction_out/8,
				target = factory.building,
				surface = factory.building.surface,
				target_offset = {cpos.outside_x - 0.5 * cpos.indicator_dx, cpos.outside_y - 0.5 * cpos.indicator_dy},
				only_in_alt_mode = true,
				render_layer = 'entity-info-icon',
			}
			table.insert(factory.outside_port_markers, rendering.draw_sprite(sprite_data))
		end
	else
		for _, sprite in pairs(factory.outside_port_markers) do rendering.destroy(sprite) end
		factory.outside_port_markers = {}
	end
end

local function cleanup_factory_exterior(factory, building)
	factory.outside_energy_receiver.destroy()
	if factory.middleman_id then delete_middleman(factory.middleman_id) end
	remove_direct_connection(factory)

	Connections.disconnect_factory(factory)
	for _, render_id in pairs(factory.outside_overlay_displays) do rendering.destroy(render_id) end
	factory.outside_overlay_displays = {}
	for _, render_id in pairs(factory.outside_port_markers) do rendering.destroy(render_id) end
	factory.outside_port_markers = {}
	factory.building = nil
	factory.built = false
end

-- FACTORY SAVING AND LOADING --

commands.add_command('give-lost-factory-buildings', {'command-help-message.give-lost-factory-buildings'}, function(event)
	local player = game.players[event.player_index]
	if not (player and player.connected and player.admin) then return end
	local inventory = player.get_main_inventory()
	for id, factory in pairs(global.saved_factories) do
		for i = 1, #inventory do
			local stack = inventory[i]
			if stack.valid_for_read and stack.name == factory.layout.name and stack.type == 'item-with-tags' and stack.tags.id == id then goto found end
		end
		player.insert{name = factory.layout.name, count = 1, tags = {id = id}}
		::found::
	end
end)

-- FACTORY PLACEMENT AND DESTRUCTION --

local function cancel_creation(entity, player_index, message)
	local inserted = 0
	local item_to_place = entity.prototype.items_to_place_this
	if not item_to_place then return end
	item_to_place = item_to_place[1]
	local surface = entity.surface
	local position = entity.position
	local force = entity.force

	if player_index then
		local player = game.get_player(player_index)
		if player.mine_entity(entity, false) then
			inserted = 1
		elseif item_to_place then
			inserted = player.insert(item_to_place)
		end
	end

	entity.destroy{raise_destroy = true}

	if inserted == 0 and item_to_place then
		surface.spill_item_stack(position, item_to_place, true, force, false)
	end

	if message then
		surface.create_entity{
			name = 'flying-text',
			position = position,
			text = message,
			render_player_index = player_index
		}
	end
end

local function can_place_factory_here(tier, surface, position)
	local factory = find_surrounding_factory(surface, position)
	if not factory then return true end
	local outer_tier = factory.layout.tier
	if outer_tier > tier and (factory.force.technologies['factory-recursion-t1'].researched or settings.global['Factorissimo2-free-recursion'].value) then return true end
	if (outer_tier >= tier or settings.global['Factorissimo2-better-recursion-2'].value)
		and (factory.force.technologies['factory-recursion-t2'].researched or settings.global['Factorissimo2-free-recursion'].value) then return true end
	if outer_tier > tier then
		surface.create_entity{name='flying-text', position=position, text={'factory-connection-text.invalid-placement-recursion-1'}, force = factory.force}
	elseif (outer_tier >= tier or settings.global['Factorissimo2-better-recursion-2'].value) then
		surface.create_entity{name='flying-text', position=position, text={'factory-connection-text.invalid-placement-recursion-2'}, force = factory.force}
	else
		surface.create_entity{name='flying-text', position=position, text={'factory-connection-text.invalid-placement'}, force = factory.force}
	end
	return false
end

-- When a connection piece is placed or destroyed, check if can be connected to a factory building
local function recheck_nearby_connections(entity, delayed)
	local surface = entity.surface
    local pos = entity.position

	local sbox = table.deepcopy(entity.prototype.selection_box)
	local orientation = entity.orientation
	if orientation == 0 then -- north
		-- sbox is fine
	elseif orientation == 0.5 then -- south
		sbox.left_top.y, sbox.right_bottom.y = -sbox.right_bottom.y, -sbox.left_top.y
	elseif orientation == 0.25 then -- east
		sbox.left_top.y, sbox.left_top.x, sbox.right_bottom.x, sbox.right_bottom.y = -sbox.right_bottom.x, -sbox.right_bottom.y, -sbox.left_top.y, -sbox.left_top.x
	elseif orientation == 0.75 then -- west
		sbox.left_top.y, sbox.right_bottom.y = -sbox.right_bottom.y, -sbox.left_top.y
		sbox.left_top.y, sbox.left_top.x, sbox.right_bottom.x, sbox.right_bottom.y = -sbox.right_bottom.x, -sbox.right_bottom.y, -sbox.left_top.y, -sbox.left_top.x
	end

	-- Expand box to catch factories and also avoid illegal zero-area finds
	local bbox = {
		left_top = {x = pos.x - 0.3 + sbox.left_top.x, y = pos.y - 0.3 + sbox.left_top.y},
		right_bottom = {x = pos.x + 0.3 + sbox.right_bottom.x, y = pos.y + 0.3 + sbox.right_bottom.y}
	}

	for _, candidate in pairs(surface.find_entities_filtered{area = bbox, type = BUILDING_TYPE}) do
		if candidate ~= entity and has_layout(candidate.name) then
			local factory = get_factory_by_building(candidate)
			if factory then
				if delayed then
					Connections.recheck_factory_delayed(factory, bbox, nil)
				else
					Connections.recheck_factory(factory, bbox, nil)
				end
			end
		end
	end
	local factory = find_surrounding_factory(surface, pos)
	if factory then
		if delayed then
			Connections.recheck_factory_delayed(factory, nil, bbox)
		else
			Connections.recheck_factory(factory, nil, bbox)
		end
	end
end

local function create_fresh_factory(entity)
	local layout = Layout.create_layout(entity.name)
	local factory = create_factory_interior(layout, entity.force)
	create_factory_exterior(factory, entity)
	factory.inactive = not can_place_factory_here(layout.tier, entity.surface, entity.position)
	return factory
end

local function handle_factory_placed(entity, tags)
	if not tags or not tags.id then
		create_fresh_factory(entity)
	elseif global.saved_factories[tags.id] then
		-- This is a saved factory, we need to unpack it
		local factory = global.saved_factories[tags.id]
		global.saved_factories[tags.id] = nil
		create_factory_exterior(factory, entity)
		factory.inactive = not can_place_factory_here(factory.layout.tier, entity.surface, entity.position)
	elseif global.factories[tags.id] then
		-- This factory was copied from somewhere else. Clone all contained entities
		local factory = create_fresh_factory(entity)
		Blueprint.copy_entity_ghosts(global.factories[tags.id], factory)
		Overlay.update_overlay(factory)
	else
		entity.surface.create_entity{name='flying-text', position=entity.position, text={'factory-connection-text.invalid-factory-data'}}
		entity.destroy()
	end
end

script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity, defines.events.script_raised_built, defines.events.script_raised_revive}, function(event)
	local entity = event.created_entity or event.entity
	if has_layout(entity.name) then
		local stack = event.stack
		if stack and stack.valid_for_read and stack.type == 'item-with-tags' then
			handle_factory_placed(entity, stack.tags)
		else
			handle_factory_placed(entity, event.tags)
		end
    elseif Connections.is_connectable(entity) then
		if entity.name == 'factory-circuit-connector' then
			entity.operable = false
		else
			local _, _, pipe_name_input = entity.name:find('^factory%-(.*)%-input$')
			local _, _, pipe_name_output = entity.name:find('^factory%-(.*)%-output$')
			local pipe_name = pipe_name_input or pipe_name_output
			if pipe_name then entity = remote_api.replace_entity(entity, pipe_name) end
		end

		recheck_nearby_connections(entity)
	elseif entity.type == 'electric-pole' then
		power_pole_placed(entity)
    elseif entity.type == 'solar-panel' or entity.name == 'bi-solar-boiler' then
		if global.surface_factory_counters[entity.surface.name] then
			cancel_creation(entity, event.player_index, {'factory-connection-text.invalid-placement'})
		else
			entity.force.technologies['factory-interior-upgrade-lights'].researched = true
		end
	elseif entity.type == 'entity-ghost' and Connections.indicator_names[entity.ghost_name] then
		Blueprint.unpack_connection_settings_from_blueprint(entity)
		entity.destroy()
	elseif entity.type == 'entity-ghost' and (entity.ghost_name == 'factory-overlay-controller' or entity.ghost_name == 'factory-blueprint-anchor') then
		entity.destroy()
	elseif entity.type == 'spider-vehicle' and entity.name ~= 'companion' then
		global.spidertrons[entity.unit_number] = entity
		script.register_on_entity_destroyed(entity)
	end
end)

local sprite_path_translation = {
	item = 'item',
	fluid = 'fluid',
	virtual = 'virtual-signal',
}
local function generate_factory_item_description(factory)
	local overlay = factory.inside_overlay_controller
	local params = {}
	if overlay and overlay.valid then
		for _, param in pairs(overlay.get_or_create_control_behavior().parameters) do
			if param and param.signal and param.signal.name then
				table.insert(params, '[' .. sprite_path_translation[param.signal.type] .. '=' .. param.signal.name .. ']')
			end
		end
	end
	params = table.concat(params, ' ')
	if params ~= '' then return '[font=heading-2]' .. params .. '[/font]' end
end

-- How players pick up factories
-- Working factory buildings don't return items, so we have to manually give the player an item
script.on_event({defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity}, function(event)
	local entity = event.entity
	if has_layout(entity.name) then
		local factory = get_factory_by_building(entity)
		if not factory then return end
		cleanup_factory_exterior(factory, entity)
		global.saved_factories[factory.id] = factory
		local buffer = event.buffer
		buffer.clear()
		buffer.insert{name = factory.layout.name}
		buffer[1].tags = {id = factory.id}
		local description = generate_factory_item_description(factory)
		if description then buffer[1].custom_description = description end
	elseif Connections.is_connectable(entity) then
		recheck_nearby_connections(entity, true) -- Delay
	elseif entity.type == 'electric-pole' then
		power_pole_destroyed(entity)
	end
end)

local function rebuild_factory(entity)
	local factory = get_factory_by_building(entity)
	if not factory then return end
	global.factories_by_entity[entity.unit_number] = nil
	local entity = entity.surface.create_entity{
		name = entity.name,
		position = entity.position,
		force = entity.force,
		raise_built = false,
		create_build_effect_smoke = false,
		player = entity.last_user
	}
	global.factories_by_entity[entity.unit_number] = factory
	factory.building = entity
	Overlay.update_overlay(factory)
	if #factory.outside_port_markers ~= 0 then
		factory.outside_port_markers = {}
		toggle_port_markers(factory)
	end
	entity.surface.create_entity{name = 'flying-text', position = entity.position, text = {'factory-cant-be-mined'}}
end

local fake_robots = {['repair-block-robot'] = true} -- Modded construction robots with heavy control scripting
script.on_event(defines.events.on_robot_pre_mined, function(event)
	local entity = event.entity
	if has_layout(entity.name) and fake_robots[event.robot.name] then
		rebuild_factory(entity)
		entity.destroy()
	elseif Connections.is_connectable(entity) then
		recheck_nearby_connections(entity, true) -- Delay
	elseif entity.type == 'item-entity' and entity.stack.valid_for_read and has_layout(entity.stack.name) then
		event.robot.destructible = false
	end
end)

-- How biters pick up factories
-- Too bad they don't have hands
script.on_event(defines.events.on_entity_died, function(event)
	local entity = event.entity
	if has_layout(entity.name) then
		local factory = get_factory_by_building(entity)
		if not factory then return end
		global.saved_factories[factory.id] = factory
		cleanup_factory_exterior(factory, entity)

		local item = entity.surface.create_entity{
			name = 'item-on-ground',
			position = entity.position,
			stack = {name = factory.layout.name, tags = {id = factory.id}}
		}
		item.order_deconstruction(entity.force)
		item.to_be_looted = true
		local description = generate_factory_item_description(factory)
		if description then item.stack.custom_description = description end
	elseif Connections.is_connectable(entity) then
		recheck_nearby_connections(entity, true) -- Delay
	elseif entity.type == 'electric-pole' then
		power_pole_destroyed(entity)
	end
end)

script.on_event(defines.events.on_post_entity_died, function(event)
	if not has_layout(event.prototype.name) or not event.ghost then return end
	local factory = global.factories_by_entity[event.unit_number]
	if not factory then return end
	event.ghost.tags = {id = factory.id}
end)

-- Just rebuild the factory in this case
script.on_event(defines.events.script_raised_destroy, function(event)
	local entity = event.entity
	if has_layout(entity.name) then
		rebuild_factory(entity)
	elseif Connections.is_connectable(entity) then
		recheck_nearby_connections(entity, true) -- Delay
	elseif entity.type == 'electric-pole' then
		power_pole_destroyed(entity)
	end
end)

-- How to clone your factory
-- This implementation will not actually clone factory buildings, but move them to where they were cloned.
local clone_forbidden_prefixes = {
	'factory-1-',
	'factory-2-',
	'factory-3-',
	'factory-power-input-',
	'factory-connection-indicator-',
	'factory-power-pole',
	'factory-overlay-controller',
	'factory-overlay-display',
	'factory-port-marker',
	'factory-fluid-dummy-connector'
}

local function is_entity_clone_forbidden(name)
	for _, prefix in pairs(clone_forbidden_prefixes) do
		if name:sub(1, #prefix) == prefix then
			return true
		end
	end
	return false
end

script.on_event(defines.events.on_entity_cloned, function(event)
	local src_entity = event.source
	local dst_entity = event.destination
	if is_entity_clone_forbidden(dst_entity.name) then
		dst_entity.destroy()
	elseif has_layout(src_entity.name) then
		local factory = get_factory_by_building(src_entity)
		cleanup_factory_exterior(factory, src_entity)
		if src_entity.valid then src_entity.destroy() end
		create_factory_exterior(factory, dst_entity)
	end
end)

-- ON TICK --

CONNECTION_UPDATE_RATE = 5
script.on_nth_tick(CONNECTION_UPDATE_RATE, Connections.update)

script.on_nth_tick(180, function(event)
	local has_players = {}
	for _, player in pairs(game.players) do
		if global.surface_factory_counters[player.surface.name] and (player.render_mode == defines.render_mode.chart or player.render_mode == defines.render_mode.chart_zoomed_in) then
			has_players[player.surface.name] = true
		end
	end

	for surface, _ in pairs(global.surface_factory_counters) do
		surface = game.get_surface(surface)
		local players = not not has_players[surface.name]
		if players ~= global.hidden_radars[surface.name] then
			for _, factory in pairs(global.factories) do
				if factory.radar.valid and factory.inside_surface == surface then
					factory.radar.active = players
				end
			end
			global.hidden_radars[surface.name] = players
		end
	end
end)

-- CONNECTION SETTINGS --

script.on_event(defines.events.on_player_rotated_entity, function(event)
	local entity = event.entity
	if Connections.indicator_names[entity.name] then
		entity.direction = event.previous_direction
	elseif Connections.is_connectable(entity) then
		recheck_nearby_connections(entity)
		if entity.valid and entity.type == 'underground-belt' then
			local neighbour = entity.neighbours
			if neighbour then
				recheck_nearby_connections(neighbour)
			end
		end
	end
end)

script.on_event('factory-rotate', function(event)
	local player = game.players[event.player_index]
	local entity = player.selected
	if not entity then return end
	if has_layout(entity.name) then
		local factory = get_factory_by_building(entity)
		if factory then --and player.is_cursor_empty() then
			toggle_port_markers(factory)
		end
	elseif Connections.indicator_names[entity.name] then
		local factory = find_surrounding_factory(entity.surface, entity.position)
		if factory then
			Connections.rotate(factory, entity)
		end
	end
end)

script.on_event('factory-increase', function(event)
	local entity = game.players[event.player_index].selected
	if not entity then return end
	if Connections.indicator_names[entity.name] then
		local factory = find_surrounding_factory(entity.surface, entity.position)
		if factory then
			Connections.adjust(factory, entity, true)
		end
	end
end)

script.on_event('factory-decrease', function(event)
	local entity = game.players[event.player_index].selected
	if not entity then return end
	if Connections.indicator_names[entity.name] then
		local factory = find_surrounding_factory(entity.surface, entity.position)
		if factory then
			Connections.adjust(factory, entity, false)
		end
	end
end)

-- MISC --

update_hidden_techs = function(force)
	if settings.global['Factorissimo2-hide-recursion'] and settings.global['Factorissimo2-hide-recursion'].value then
		force.technologies['factory-recursion-t1'].enabled = false
		force.technologies['factory-recursion-t2'].enabled = false
	elseif settings.global['Factorissimo2-hide-recursion-2'] and settings.global['Factorissimo2-hide-recursion-2'].value then
		force.technologies['factory-recursion-t1'].enabled = true
		force.technologies['factory-recursion-t2'].enabled = false
	else
		force.technologies['factory-recursion-t1'].enabled = true
		force.technologies['factory-recursion-t2'].enabled = true
	end
end

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	local setting = event.setting
	if setting == 'Factorissimo2-hide-recursion' or setting == 'Factorissimo2-hide-recursion-2' then
		for _, force in pairs(game.forces) do
			update_hidden_techs(force)
		end
	elseif setting == 'Factorissimo2-indestructible-buildings' then
		for _, factory in pairs(global.factories) do
			update_destructible(factory)
		end
	end
end)

script.on_event(defines.events.on_force_created, function(event)
	local force = event.force
	update_hidden_techs(force)
end)

script.on_event(defines.events.on_forces_merging, function(event)
	for _, factory in pairs(global.factories) do
		if not factory.force.valid then
			factory.force = game.forces['player']
		end
		if factory.force.name == event.source.name then
			factory.force = event.destination
		end
	end
end)

activate_factories = function()
	for _, factory in pairs(global.factories) do
		factory.inactive = factory.outside_surface.valid and not can_place_factory_here(
			factory.layout.tier,
			factory.outside_surface,
			{x = factory.outside_x, y = factory.outside_y}
		)
	end
end

script.on_event(defines.events.on_research_finished, function(event)
	if not global.factories then return end -- In case any mod or scenario script calls LuaForce.research_all_technologies() during its on_init
	local research = event.research
	local name = research.name
	if name == 'factory-connection-type-fluid' or name == 'factory-connection-type-chest' or name == 'factory-connection-type-circuit' then
		for _, factory in pairs(global.factories) do
			if factory.built then Connections.recheck_factory(factory, nil, nil) end
		end
	elseif name == 'factory-interior-upgrade-lights' then
		for _, factory in pairs(global.factories) do build_lights_upgrade(factory) end
	elseif name == 'factory-interior-upgrade-display' then
		for _, factory in pairs(global.factories) do Overlay.build_display_upgrade(factory) end
	elseif name == 'factory-interior-upgrade-roboport' then
		for _, factory in pairs(global.factories) do build_roboport_upgrade(factory) end
	elseif name == 'factory-recursion-t1' or name == 'factory-recursion-t2' then
		activate_factories()
	elseif name == 'factory-preview' then
		for _, player in pairs(game.players) do Camera.get_camera_toggle_button(player) end
	end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	if event.setting_type == 'runtime-global' then activate_factories() end
end)

remote.add_interface('factorissimo', remote_api)
