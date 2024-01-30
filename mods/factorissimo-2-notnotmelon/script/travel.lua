local find_surrounding_factory = remote_api.find_surrounding_factory
local power_middleman_surface = remote_api.power_middleman_surface
local find_factory_by_building = remote_api.find_factory_by_building
local get_factory_by_building = remote_api.get_factory_by_building
local has_layout = Layout.has_layout

local function find_connected_spidertron_remotes(player, e)
	local inventory = player.get_main_inventory()
	local result = {}
	for i = 0, #inventory do
		local stack; if i == 0 then stack = player.cursor_stack else stack = inventory[i] end
		if stack and stack.valid_for_read and stack.type == 'spidertron-remote' and stack.connected_entity == e then
			result[#result + 1] = stack
		end
	end
	return result
end

local function teleport_safely(e, surface, position, player, leaving)
	position = {x = position.x or position[1], y = position.y or position[2]}
	local is_spider = not e.is_player() and e.type == 'spider-vehicle'
	
	if is_spider and e.autopilot_destination then
		if player then
			local current_factory = find_surrounding_factory(e.surface, e.position)
			local destination_factory = find_surrounding_factory(surface, position)
			if current_factory and destination_factory then
				e.autopilot_destination = {
					e.autopilot_destination.x - current_factory.inside_x + destination_factory.inside_x,
					e.autopilot_destination.y - current_factory.inside_y + destination_factory.inside_y
				}
			else e.autopilot_destination = nil end
		else e.autopilot_destination = nil end
	end
	
	if is_spider and e.surface ~= surface then
		local remotes = {}
		for _, player in pairs(player and {player} or game.players) do
			for _, stack in pairs(find_connected_spidertron_remotes(player, e)) do remotes[#remotes + 1] = stack end
		end
		
		if player then player.teleport(position, surface) end
		e.teleport(leaving and {e.position.x, e.position.y + 1.5} or e.position, surface)
		if player then e.set_driver(player) end
		
		for _, stack in pairs(remotes) do stack.connected_entity = e end
	end
	
	if is_spider then
		e.teleport(leaving and {position.x, position.y + 1.5} or position, surface)
	elseif e.is_player() and not e.character then -- god controller
		e.teleport(position, surface)
	else
		position = surface.find_non_colliding_position(
			e.is_player() and e.character.name or e.name,
			position, 5, 0.5, false
		) or position
		e.teleport({0, 0}, power_middleman_surface()) -- teleport personal robots with the player
		e.teleport(position, surface)
	end
	
	global.last_player_teleport[player and player.index or e.unit_number] = game.tick
	if player then Camera.update_camera(player) end
end

local function enter_factory(e, factory, player)
	teleport_safely(e, factory.inside_surface, {factory.inside_door_x, factory.inside_door_y}, player, false)
end

local function leave_factory(e, factory, player)
	teleport_safely(e, factory.outside_surface, {factory.outside_door_x, factory.outside_door_y}, player, true)
end

script.on_event(defines.events.on_spider_command_completed, function(event)
	local spider = event.vehicle
	if not spider.get_driver() then return end
	for _, building in pairs(spider.surface.find_entities_filtered{type = BUILDING_TYPE, position = spider.position}) do
		if has_layout(building.name) then
			local factory = get_factory_by_building(building)
			if factory then
				enter_factory(spider, factory, nil)
			end
			return
		end
	end
end)

-- https://mods.factorio.com/mod/jetpack
local function get_jetpacks()
	local jetpack = script.active_mods.jetpack
	if jetpack then
		return remote.call('jetpack', 'get_jetpacks', {})
	end
	return nil
end

local function is_airborne(jetpacks, player_unit_number)
	local data = jetpacks[player_unit_number]
	if data == nil then return false end
	return data.status == 'flying'
end

local function teleport_players()
	local tick = game.tick
	local jetpacks = get_jetpacks()
	for player_index, player in pairs(game.connected_players) do
		if tick - (global.last_player_teleport[player_index] or 0) < 45 then goto continue end
		local walking_state = player.walking_state
		local driving = player.driving
		if not walking_state.walking and not driving then goto continue end
		if driving and not player.vehicle then goto continue end -- if the player is riding a rocket silo
		local airborne = jetpacks and player.character ~= nil and is_airborne(jetpacks, player.character.unit_number)
		
		if not airborne then
			if (driving and player.vehicle.type == 'spider-vehicle')
				or walking_state.direction == defines.direction.north
				or walking_state.direction == defines.direction.northeast
				or walking_state.direction == defines.direction.northwest then
					
				local factory = find_factory_by_building(player.surface, {
					{player.position.x - 0.2, player.position.y - 0.3},
					{player.position.x + 0.2, player.position.y}
				})
				
				if factory ~= nil and not factory.inactive and player.position.y > factory.outside_y + 1 and math.abs(player.position.x - factory.outside_x) < 0.6 then
					enter_factory(driving and player.vehicle or player, factory, player)
					return
				end
			end
		end
		
		if (driving and player.vehicle.type == 'spider-vehicle' and player.vehicle.autopilot_destination and player.vehicle.autopilot_destination.y > player.vehicle.position.y)
			or walking_state.direction == defines.direction.south
			or walking_state.direction == defines.direction.southeast
			or walking_state.direction == defines.direction.southwest
			then
				
			local factory = find_surrounding_factory(player.surface, player.position)
			if factory and player.position.y > factory.inside_door_y + (airborne and -0.5 or 1) then
				if math.abs(player.position.x - factory.inside_door_x) < 4 then
					leave_factory(driving and player.vehicle or player, factory, player)
					Camera.update_camera(player)
					Overlay.update_overlay(factory)
				end
			end
		end
		::continue::
	end
end
script.on_nth_tick(6, teleport_players)
