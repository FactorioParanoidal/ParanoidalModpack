local function on_built(event)
	local main_entity = event.created_entity

	if global.CW_AirFilterTable == nil then
		global.CW_AirFilterTable = {}
	end

	if main_entity.name == "CW-air-filter-machine-1" or 
	   main_entity.name == "CW-air-filter-machine-2" or 
	   main_entity.name == "CW-air-filter-machine-3" or 
	   main_entity.name == "CW-air-filter-machine-4" or 
	   main_entity.name == "CW-air-filter-machine-5" or 
	   main_entity.name == "CW-air-filter-machine-6" then
	   
		global.CW_AirFilterTable[main_entity.unit_number] =  main_entity
	end
end


local function on_remove(event)
	local main_entity = event.entity
	
	if main_entity.name == "CW-air-filter-machine-1" or 
		main_entity.name == "CW-air-filter-machine-2" or 
		main_entity.name == "CW-air-filter-machine-3" or 
		main_entity.name == "CW-air-filter-machine-4" or 
		main_entity.name == "CW-air-filter-machine-5" or 
		main_entity.name == "CW-air-filter-machine-6" then
			global.CW_AirFilterTable[main_entity.unit_number] = nil
	end	
end

function on_tick(event)
	if event.tick % 60 == 0 and global.CW_AirFilterTable ~= nil then
		for x , filter in pairs(global.CW_AirFilterTable) do
			if filter.valid then
				local position = filter.position
				local surface = filter.surface
				local polution = surface.get_pollution(position)
				filter.active = polution > 1
			end
		end
	end
end



local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
script.on_event(build_events, on_built)

local remove_events = {defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity,defines.events.on_entity_died}
script.on_event(remove_events, on_remove)

script.on_event({defines.events.on_tick}, on_tick)


--[[
local function on_shift_click(event)
	local player = game.players[event.player_index]
	local surface = player.surface
	local position = player.position
	local polution = surface.get_pollution(position)
	game.print(polution)
end





script.on_event("on-shift-click", on_shift_click)


require ("gui")
local remake_connections = false

local function make_connection(main_entity)
	local surface = main_entity.surface
	local force = main_entity.force
	local position = main_entity.position
	local player = main_entity.last_user
	local conn_position = {x = position.x -1, y = position.y + 2}
	local conn = surface.create_entity({name = "CW-reactor-connection", position = conn_position, force = force, fast_replace = false, player = player})
	conn.operable = false
	global.CW_fusion_reactor[main_entity.unit_number] = 
	{
		main_entity = main_entity,
		connection = conn
	}
end

local function remake_all_connections()
	local surfaces = game.surfaces 
	for i , surface in pairs(surfaces) do
		reactors = surface.find_entities_filtered{name = "CW-fusion-reactor"} 
		for i , main_entity in pairs(reactors) do
			make_connection(main_entity)
			--game.print(i)
		end
	end
end


local function on_built(event)
	local main_entity = event.created_entity
	
	if main_entity.name == "CW-fusion-reactor" then
		make_connection(main_entity)
	elseif main_entity.name == "CW-fake-pyrolyser" then

		local surface = main_entity.surface
		local position = main_entity.position
		local force = main_entity.force
		local player = main_entity.last_user
		local direction = main_entity.direction 
		main_entity.destroy()
		surface.create_entity({
			name = "CW-pyrolyser", 
			position = position, 
			direction = direction, 
			force = force, 
			player = player,
		})
		
	end
end

local function on_click(event)
	local player = game.players[event.player_index]
	local main_entity = player.selected	
	
	
end

local function on_shift_click(event)
	local player = game.players[event.player_index]
	local main_entity = player.selected
	local gui = player.gui
	
	if main_entity ~= nil and main_entity.valid then

		if main_entity.name == "CW-fuel-cell-generator" then
			gui_fuel_cell(gui, main_entity, 3)
		elseif main_entity.name == "CW-fuel-cell-generator-primary" then
			gui_fuel_cell(gui, main_entity,1)
		elseif main_entity.name == "CW-fuel-cell-generator-secondary" then
			gui_fuel_cell(gui, main_entity, 2)

		elseif main_entity.name == "CW-hydrogen-furnace-1A" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-1B",
				position = position, 
				force = force, 
				player = player,
			})
		elseif main_entity.name == "CW-hydrogen-furnace-2A" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-2B",
				position = position, 
				force = force, 
				player = player,
			})
		elseif main_entity.name == "CW-hydrogen-furnace-3A" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-3B",
				position = position, 
				force = force, 
				player = player,
			})
		elseif main_entity.name == "CW-hydrogen-furnace-1B" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-1A",
				position = position, 
				force = force, 
				player = player,
			})
		elseif main_entity.name == "CW-hydrogen-furnace-2B" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-2A",
				position = position, 
				force = force, 
				player = player,
			})
		elseif main_entity.name == "CW-hydrogen-furnace-3B" then
			local surface = main_entity.surface
			local position = main_entity.position
			local force = main_entity.force	
			main_entity.destroy()
			surface.create_entity({
				name = "CW-hydrogen-furnace-3A",
				position = position, 
				force = force, 
				player = player,
			})
		end
	end
end


local function on_change(event)
	if global.CW_fusion_reactor == nil then
		global.CW_fusion_reactor = {}
		remake_connections = true
	end
	if global.CW_pyrolyser == nil then
		global.CW_pyrolyser = {}
	end
end


local function on_tick(event)
	
	if remake_connections then
		remake_all_connections()
		remake_connections = false
	end
	
	if (event.tick % 60) == 0 then
		for x , reactor in pairs(global.CW_fusion_reactor) do
			if reactor.main_entity.valid then
				local control = reactor.connection.get_or_create_control_behavior()
			
				local temperature = {signal = {type = "virtual", name = "CW-temperature"},count = reactor.main_entity.temperature}
				
				local burner = reactor.main_entity.burner
				
				local inventory_MJ = 0
				if not burner.inventory.is_empty() then
					local fuel = burner.inventory[1]
					inventory_MJ = fuel.prototype.fuel_value / 1000000 * fuel.count
				end
				
				remaining_fuel_MJ = (burner.remaining_burning_fuel )/1000000
				local fuel_MJ = remaining_fuel_MJ + inventory_MJ
				
				local fuel = {signal = {type = "virtual", name = "CW-fuel"}, count = fuel_MJ}
				control.set_signal(1,temperature)
				control.set_signal(2,fuel)
				
			end
		end
	end
end


local function on_remove(event)
	local main_entity = event.entity
	if main_entity.name == "CW-fusion-reactor" then
		if global.CW_fusion_reactor[main_entity.unit_number] ~= nil then
			global.CW_fusion_reactor[main_entity.unit_number].connection.destroy()
			global.CW_fusion_reactor[main_entity.unit_number] = nil
		end
	end
end


local build_events = {defines.events.on_built_entity, defines.events.on_robot_built_entity}
script.on_event(build_events, on_built)

local remove_events = {defines.events.on_player_mined_entity, defines.events.on_robot_mined_entity,defines.events.on_entity_died}
script.on_event(remove_events, on_remove)

script.on_configuration_changed(on_change)
script.on_init(on_change)

script.on_event({defines.events.on_tick}, on_tick)

script.on_event("on-shift-click", on_shift_click)

--]]

