require "on_tick"
ignored_entities = {
["vehicle-gun-turret"] = true,
["vehicle-gun-turretv2"] = true,
["vehicle-gun-turretv3"] = true,
["vehicle-rocket-turret"] = true,
["vehicle-rocket-turretv2"] = true,
["vehicle-rocket-turretv3"] = true,
}

script.on_init(function()
	global.disabled_turrets={}
	global.combinators={}
	refresh_everything()
	global.version = 33
	
	global.turrets_size = 0
	global.e_updater_size = 0
	global.e_updater_disconnected_size = 0
	global.combinators_size = 0
	
	global.iterate_turrets = nil
	global.iterate_e_updater = nil
	global.iterate_e_updater_disconnected = nil
	global.iterate_combinators = nil
	--global.worker_key = nil
end)


script.on_configuration_changed(function()
	global.research_enabled = settings.global["TS_research_enabled"].value
	global.research_size = settings.global["TS_research_size"].value
	global.research_speed = settings.global["TS_research_speed"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
	global.energy_consumption = settings.global["TS_energy_consumption"].value
	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.penalty = settings.global["TS_penalty"].value/100
	global.power_usage = settings.global["TS_power_usage"].value/100
	--global.worker_key = nil
	if global.version < 22 then
		global.disabled_turrets={}
		global.version=22
	end
	if global.version < 24 then
		global.combinators={}
		global.version=24
	end
	if global.version < 25 then
		for key, tbl in pairs(global.combinators) do
			global.combinators[key].entity = tbl[1]
			global.combinators[key][1]=nil
			global.combinators[key].turrets={tbl[2]}
			global.combinators[key][2]=nil
		end
		global.version=25
	end
	if global.version < 26 then
		refresh_everything()
		global.version=26
	end
	if global.version < 27 then
		global.refresh_orientation={}
		global.version=27
	end
	if global.version < 31 then
		for k, force in pairs (game.forces) do
			if force.technologies["turret-shields-base"].researched then
				force.recipes["ts-shield-disabler"].enabled=true
				force.recipes["turret-shield-combinator"].enabled=true
			end
		end
		global.version=31
	end
	if global.version < 32 then
		for tick, tbl in pairs(global.updater) do
			for a,b in pairs(tbl) do
				tbl[a] = b[2]
			end
		end
		for a, b in pairs(global.electric_updater) do
			global.electric_updater[a] = b[2]
		end
		for a, b in pairs(global.electric_updater_disconnected) do
			global.electric_updater[a] = b[2]
		end
		global.turrets_size = table_size(global.turrets)
		global.e_updater_size = table_size(global.electric_updater)
		global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
		global.combinators_size = table_size(global.combinators)
		--for key, tabl in pairs(global.disabled_turrets) do
		--	if global.turrets[key] then
		--		global.turrets[10] = tabl[1]
		--	end
		--end
		--global.disabled_turrets = nil
		global.version = 32
		
		disabled_turrets={}
		combinators={}
		
	end
	if global.version < 33 then
		for a,b in pairs(global.turrets) do
			if b[8].valid and ignored_entities[b[8].name] then
				destroy_turret(b[8].unit_number)
			end
		end
		global.version = 33
	end
	if global.energy_consumption then
		for k, force in pairs (game.forces) do
			update_electricity(force,"size")
		end
	end
end)

function print(str)
	game.print(str)
end
script.on_event(defines.events.on_force_created,function(event)

	global.forces[event.force.name] = {}
	event.force.technologies["turret-shields-base"].enabled = global.research_enabled
	event.force.technologies["turret-shields-speed-1"].enabled = global.research_enabled
	event.force.technologies["turret-shields-speed-2"].enabled = global.research_enabled
	event.force.technologies["turret-shields-speed-3"].enabled = global.research_enabled
	event.force.technologies["turret-shields-size-1"].enabled = global.research_enabled
	event.force.technologies["turret-shields-size-2"].enabled = global.research_enabled
	event.force.technologies["turret-shields-size-3"].enabled = global.research_enabled

	if global.research_enabled then
		local speed = 5
		local size = 50
		if event.force.technologies["turret-shields-speed-1"].researched then
			speed = 10
		end
		if event.force.technologies["turret-shields-speed-2"].researched then
			speed = 15
		end
		if event.force.technologies["turret-shields-speed-3"].researched then
			speed = (event.force.technologies["turret-shields-speed-3"].level-3)*10+15
		end
		if event.force.technologies["turret-shields-size-1"].researched then
			size = 100
		end
		if event.force.technologies["turret-shields-size-2"].researched then
			size = 150
		end
		if event.force.technologies["turret-shields-size-3"].researched then
			size = (force.technologies["turret-shields-size-3"].level-3)*100+150
		end
		global.forces[event.force.name].speed = speed
		global.forces[event.force.name].size = size
		--if event.force.technologies["turret-shields-base"].researched then
		--	for key, surface in pairs(game.surfaces) do
		--		for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force = event.force.name}) do
		--			init_turret(turret)
		--		end
		--		for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force = event.force.name}) do
		--			init_turret(turret)
		--		end
		--		for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force = event.force.name}) do
		--			init_turret(turret)
		--		end
		--	end
		--end
		global.forces[event.force.name].enabled = event.force.technologies["turret-shields-base"].researched
		
	else

		global.forces[event.force.name].enabled = true
		global.forces[event.force.name].speed = settings.global["TS_charging_speed"].value
		global.forces[event.force.name].size = settings.global["TS_max_shield"].value

		for key, surface in pairs(game.surfaces) do
			for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force = event.force.name}) do
				init_turret(turret)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force = event.force.name}) do
				init_turret(turret)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force = event.force.name}) do
				init_turret(turret)
			end
		end
	end



end)


script.on_event(defines.events.on_player_selected_area,function(event)
    if event.item == "ts-shield-disabler" then
		if global.energy_consumption then
			for key, entity in pairs(event.entities) do
				if entity.valid and entity.type== "ammo-turret" or entity.type== "fluid-turret" or entity.type== "electric-turret" then
					if global.disabled_turrets[entity.unit_number] then
						global.disabled_turrets[entity.unit_number][1].destroy()
						global.disabled_turrets[entity.unit_number] = nil
						init_turret(entity,true)
					else
						global.disabled_turrets[entity.unit_number] = {}
						global.disabled_turrets[entity.unit_number][1] = entity.surface.create_entity{name = "ts-unplugged", position = {entity.position.x, entity.position.y}, force = "neutral"}
						global.disabled_turrets[entity.unit_number][2] = entity
						destroy_turret(entity.unit_number)
						--if global.turrets[entity.unit_number] and global.turrets[entity.unit_number][3] and global.turrets[entity.unit_number][3].valid then global.turrets[entity.unit_number][3].destroy() end
						--if global.turrets[entity.unit_number] and global.turrets[entity.unit_number][7] and global.turrets[entity.unit_number][7].valid then global.turrets[entity.unit_number][7].destroy() end
						--global.turrets[entity.unit_number]=nil
					end
				end
			end
		else
			for key, entity in pairs(event.entities) do
				if entity.valid and entity.type== "ammo-turret" or entity.type== "fluid-turret" or entity.type== "electric-turret" then
					if global.disabled_turrets[entity.unit_number] then
						global.disabled_turrets[entity.unit_number][1].destroy()
						global.disabled_turrets[entity.unit_number] = nil
					else
						global.disabled_turrets[entity.unit_number] = {}
						global.disabled_turrets[entity.unit_number][1] = entity.surface.create_entity{name = "ts-unplugged", position = {entity.position.x, entity.position.y}, force = "neutral"}
						global.disabled_turrets[entity.unit_number][2] = entity
					end
				end
			end
		end
    end
end)

function init_turret(turret,recharge)
	if global.energy_consumption and global.disabled_turrets[turret.unit_number] then return end
	if ignored_entities[turret.name] then return end

	local charging_speed
	local max_shield
	if global.research_enabled then
		charging_speed = global.forces[turret.force.name].speed*global.research_speed
		max_shield = global.forces[turret.force.name].size*global.research_size
	else
		charging_speed = global.forces[turret.force.name].speed
		max_shield = global.forces[turret.force.name].size
	end
	
	global.turrets[turret.unit_number]={game.tick,0}
	global.turrets[turret.unit_number][8]=turret
	local position = turret.position
	local index
	if turret.type == "fluid-turret" then
		global.turrets[turret.unit_number][4] =	turret.orientation
		if turret.shooting_target ~= nil or turret.orientation % 0.25 ~= 0 then
			table.insert(global.refresh_orientation,turret)
		end
	end
	if not global.energy_consumption or global.energy_consumption and recharge then
		if turret.type == "fluid-turret" then
			if turret.orientation % 0.5 == 0 then
				global.turrets[turret.unit_number][3]=  turret.surface.create_entity{name = "square-0", position = {position.x+0.01, position.y + 1.3}, force = "neutral"}
				index = math.floor(((1/9*max_shield)/charging_speed/60+game.tick+1))
			else
				global.turrets[turret.unit_number][3]=  turret.surface.create_entity{name = "liquid-square-0", position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
				index = math.floor(((1/13*max_shield)/charging_speed/60+game.tick+1))
			end
		else
			global.turrets[turret.unit_number][3]=  turret.surface.create_entity{name = "square-0", position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
			index = math.floor(((1/9*max_shield)/charging_speed/60+game.tick+1))
		end
		global.turrets[turret.unit_number][3].destructible = false
	end
	global.turrets_size = table_size(global.turrets)
	
	
	if global.energy_consumption then
		local e_interface
		if global.research_enabled then
			e_interface = math.min(575,global.forces[turret.force.name].speed)
		else
			if global.forces[turret.force.name].speed <20 then
				e_interface = math.max(5,math.floor(global.forces[turret.force.name].speed/5)*5)
			else
				e_interface = math.min(575,math.floor((global.forces[turret.force.name].speed-15)/10+0.5)*10+15)
			end
		end
		if turret.type == "fluid-turret" and turret.orientation % 0.25 == 0 then
			if turret.orientation == 0 then
				position.y = position.y+0.5
			elseif turret.orientation == 0.25 then
				position.x = position.x-0.5
			elseif turret.orientation == 0.5 then
				position.y = position.y-0.5
			elseif turret.orientation == 0.75 then
				position.x = position.x+0.5
			end
		end
		global.turrets[turret.unit_number][7] = turret.surface.create_entity{name = "ts-electric-interface-"..e_interface, position = {position.x, position.y }, force = "neutral"}
		global.turrets[turret.unit_number][7].destructible = false
		global.turrets[turret.unit_number][7].electric_buffer_size=math.floor(60000*max_shield/(charging_speed/e_interface)*global.energy_consumption_multiplier)
		global.turrets[turret.unit_number][7].power_usage=math.floor(60000*max_shield*global.power_usage/60*global.energy_consumption_multiplier)
		if recharge then
			global.electric_updater[turret.unit_number] = 0
		else
			global.turrets[turret.unit_number][7].energy = global.turrets[turret.unit_number][7].electric_buffer_size
		end
		global.turrets[turret.unit_number][1] = game.tick
		global.turrets[turret.unit_number][2] = global.turrets[turret.unit_number][7].energy
		global.turrets[turret.unit_number][9] = 0
		global.e_updater_size = table_size(global.electric_updater)
		global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
	else
		if global.updater[index]==nil then
			global.updater[index]={turret.unit_number }
		else
			table.insert(global.updater[index],turret.unit_number)
		end
	end
end


function remove_hpbars()
	for key, surface in pairs(game.surfaces) do
		for i=0,9 do
			for key, entity in pairs(surface.find_entities_filtered{name= "square-"..i}) do
				entity.destroy()
			end
		end
		for i=0,13 do
			for key, entity in pairs(surface.find_entities_filtered{name= "liquid-square-"..i}) do
				entity.destroy()
			end
		end
	end
end


function remove_energy()
	for key, surface in pairs(game.surfaces) do
		for key, entity in pairs(surface.find_entities_filtered{type= "electric-energy-interface"}) do
			if string.sub(entity.name,1,22) == "ts-electric-interface-" then
				entity.destroy()
			end
		end
	end
end


function refresh_everything()
	game.print("refreshing all turret shields")
	global.iterate_turrets = nil
	global.iterate_e_updater = nil
	global.iterate_e_updater_disconnected = nil
	
	global.turrets= {}
	global.updater = {}
	global.electric_updater = {}
	global.electric_updater_disconnected = {}
	global.refresh_orientation = {}
	global.forces = {}
	for k, force in pairs (game.forces) do
		global.forces[force.name] = {}
	end
	remove_hpbars()
	remove_energy()
	global.research_enabled = settings.global["TS_research_enabled"].value
	global.research_size = settings.global["TS_research_size"].value
	global.research_speed = settings.global["TS_research_speed"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
	global.energy_consumption = settings.global["TS_energy_consumption"].value
	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.penalty = settings.global["TS_penalty"].value/100
	global.power_usage = settings.global["TS_power_usage"].value/100
	
	for k, force in pairs (game.forces) do
		force.technologies["turret-shields-base"].enabled = global.research_enabled
		force.technologies["turret-shields-speed-1"].enabled = global.research_enabled
		force.technologies["turret-shields-speed-2"].enabled = global.research_enabled
		force.technologies["turret-shields-speed-3"].enabled = global.research_enabled
		force.technologies["turret-shields-size-1"].enabled = global.research_enabled
		force.technologies["turret-shields-size-2"].enabled = global.research_enabled
		force.technologies["turret-shields-size-3"].enabled = global.research_enabled
	end
	if global.research_enabled then
		for k, force in pairs (game.forces) do

			local speed = 5
			local size = 50
			if force.technologies["turret-shields-speed-1"].researched then
				speed = 10
			end
			if force.technologies["turret-shields-speed-2"].researched then
				speed = 15
			end
			if force.technologies["turret-shields-speed-3"].researched then
				speed = (force.technologies["turret-shields-speed-3"].level-3)*10+15
			end
			if force.technologies["turret-shields-size-1"].researched then
				size = 100
			end
			if force.technologies["turret-shields-size-2"].researched then
				size = 150
			end
			if force.technologies["turret-shields-size-3"].researched then
				size = (force.technologies["turret-shields-size-3"].level-3)*100+150
			end
			global.forces[force.name].speed = speed
			global.forces[force.name].size = size
			if force.technologies["turret-shields-base"].researched then
				for key, surface in pairs(game.surfaces) do
					for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force = force.name}) do
						init_turret(turret)
					end
					for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force = force.name}) do
						init_turret(turret)
					end
					for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force = force.name}) do
						init_turret(turret)
					end
				end
			end
			global.forces[force.name].enabled = force.technologies["turret-shields-base"].researched
		end
	else
		for k, force in pairs (game.forces) do
			global.forces[force.name].enabled = true
			global.forces[force.name].speed = settings.global["TS_charging_speed"].value
			global.forces[force.name].size = settings.global["TS_max_shield"].value
		end
		for key, surface in pairs(game.surfaces) do
			for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret"}) do
				init_turret(turret)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret"}) do
				init_turret(turret)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret"}) do
				init_turret(turret)
			end
		end
	end
end


function update_force(force)
	force.technologies["turret-shields-base"].enabled = global.research_enabled
	force.technologies["turret-shields-speed-1"].enabled = global.research_enabled
	force.technologies["turret-shields-speed-2"].enabled = global.research_enabled
	force.technologies["turret-shields-speed-3"].enabled = global.research_enabled
	force.technologies["turret-shields-size-1"].enabled = global.research_enabled
	force.technologies["turret-shields-size-2"].enabled = global.research_enabled
	force.technologies["turret-shields-size-3"].enabled = global.research_enabled
	if global.forces[force.name]==nil then
		global.forces[force.name] = {}
		if global.research_enabled then
	
			local speed = 5
			local size = 50
			if force.technologies["turret-shields-speed-1"].researched then
				speed = 10
			end
			if force.technologies["turret-shields-speed-2"].researched then
				speed = 15
			end
			if force.technologies["turret-shields-speed-3"].researched then
				speed = (force.technologies["turret-shields-speed-3"].level-3)*10+15
			end
			if force.technologies["turret-shields-size-1"].researched then
				size = 100
			end
			if force.technologies["turret-shields-size-2"].researched then
				size = 150
			end
			if force.technologies["turret-shields-size-3"].researched then
				size = (force.technologies["turret-shields-size-3"].level-3)*100+150
			end
			global.forces[force.name].speed = speed
			global.forces[force.name].size = size
			if force.technologies["turret-shields-base"].researched then
				for key, surface in pairs(game.surfaces) do
					for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force = force.name}) do
						init_turret(turret)
					end
					for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force = force.name}) do
						init_turret(turret)
					end
					for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force = force.name}) do
						init_turret(turret)
					end
				end
			end
			global.forces[force.name].enabled = force.technologies["turret-shields-base"].researched
	
		else
			global.forces[force.name].enabled = true
			global.forces[force.name].speed = settings.global["TS_charging_speed"].value
			global.forces[force.name].size = settings.global["TS_max_shield"].value 
			for key, surface in pairs(game.surfaces) do
				for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret"}) do
					init_turret(turret)
				end
				for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret"}) do
					init_turret(turret)
				end
				for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret"}) do
					init_turret(turret)
				end
			end
		end
	end
end

script.on_event( defines.events.on_player_changed_force, function(event)
	local force= game.players[event.player_index].force
	update_force(force)
end)




script.on_event( defines.events.on_console_chat, function(event)
	if event.player_index == 1 and event.message == "ts refresh" then
		refresh_everything()
	end
end)


script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	--global.alternate_effect = settings.global["TS_alternate_effect"].value
	--global.penalty = settings.global["TS_penalty"].value/100/60*23
	--global.power_usage = settings.global["TS_power_usage"].value/100
	if global.research_enabled ~= settings.global["TS_research_enabled"].value 
	or global.research_size ~= settings.global["TS_research_size"].value
	or global.research_speed ~= settings.global["TS_research_speed"].value
	or global.energy_consumption ~= settings.global["TS_energy_consumption"].value then
		refresh_everything()
	else
		if settings.global["TS_energy_consumption"].value then
			refresh_everything()
		elseif not settings.global["TS_research_enabled"].value then
			for k, force in pairs (game.forces) do
				global.forces[force.name].enabled = true
				global.forces[force.name].speed = settings.global["TS_charging_speed"].value
				global.forces[force.name].size = settings.global["TS_max_shield"].value
			end
		end
	end
	global.research_enabled = settings.global["TS_research_enabled"].value
	global.research_size = settings.global["TS_research_size"].value
	global.research_speed = settings.global["TS_research_speed"].value
	global.alternate_effect = settings.global["TS_alternate_effect"].value
	global.energy_consumption = settings.global["TS_energy_consumption"].value
	global.energy_consumption_multiplier = settings.startup["TS_energy_consumption_multiplier"].value
	global.penalty = settings.global["TS_penalty"].value/100
	global.power_usage = settings.global["TS_power_usage"].value/100
end)


function update_electricity(force,mode)
	local e_interface
	local charging_speed
	local max_shield
	if not global.forces[force.name] then
		update_force(force)
	end
		
	if global.research_enabled then
		e_interface = math.min(575,global.forces[force.name].speed)
		charging_speed = global.forces[force.name].speed*global.research_speed
		max_shield = global.forces[force.name].size*global.research_size
	else
		charging_speed = global.forces[force.name].speed
		max_shield = global.forces[force.name].size
		if global.forces[force.name].speed <20 then
			e_interface = math.max(5,math.floor(global.forces[force.name].speed/5)*5)
		else
			e_interface = math.min(575,math.floor((global.forces[force.name].speed-15)/10+0.5)*10+15)
		end
	end
	if mode == "speed" then
		for key, tbl in pairs(global.turrets) do
			if tbl[8] and tbl[8].valid and tbl[8].force == force then
				local position = tbl[7].position
				local energy = tbl[7].energy
				local surface = tbl[8].surface
				
				tbl[7].destroy()
				global.turrets[key][7] = surface.create_entity{name = "ts-electric-interface-"..e_interface, position = {position.x, position.y }, force = "neutral"}
				global.turrets[key][7].destructible = false
				global.turrets[key][7].electric_buffer_size=math.floor(60000*max_shield/(charging_speed/e_interface)*global.energy_consumption_multiplier)
				global.turrets[key][7].power_usage=math.floor(60000*max_shield*global.power_usage/60*global.energy_consumption_multiplier) 
				global.turrets[key][7].energy = energy
				if not global.electric_updater[key] and not global.electric_updater_disconnected[key] then
					global.electric_updater[key] = 0
				end
				global.turrets[key][1]=game.tick
				global.turrets[key][2]=global.turrets[key][7].energy
				global.turrets[key][9]=0
			end
		end
	end
	if mode == "size" then
		for key, tbl in pairs(global.turrets) do
			if tbl[8] and tbl[8].valid and tbl[8].force.name == force.name then
			
				local energy = tbl[7].energy
				tbl[7].electric_buffer_size=math.floor(60000*max_shield/(charging_speed/e_interface)*global.energy_consumption_multiplier)
				tbl[7].power_usage=math.floor(60000*max_shield*global.power_usage/60*global.energy_consumption_multiplier)
				if energy >= tbl[7].electric_buffer_size then
					tbl[7].energy = tbl[7].electric_buffer_size
				elseif not global.electric_updater[key] and not global.electric_updater_disconnected[key] then
					global.electric_updater[key] = 0
				end
				global.turrets[key][1]=game.tick
				global.turrets[key][2]=global.turrets[key][7].energy
				global.turrets[key][9]=0
			end
		end
	end
end


script.on_event(defines.events.on_research_finished,function(event)

	force = event.research.force
	if not global.research_enabled then return end

	if event.research.name == "turret-shields-base" then
		if not global.refresh_orientation then
			global.refresh_orientation = {}
		end
		global.forces[force.name].enabled = force.technologies["turret-shields-base"].researched
		global.forces[force.name].speed = 5
		global.forces[force.name].size = 50
		for key, surface in pairs(game.surfaces) do
			for i, turret in pairs(surface.find_entities_filtered{type= "ammo-turret", force = force.name}) do
				init_turret(turret,true)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "fluid-turret", force = force.name}) do
				init_turret(turret,true)
			end
			for i, turret in pairs(surface.find_entities_filtered{type= "electric-turret", force = force.name}) do
				init_turret(turret,true)
			end
		end
	end
	local mode
	if event.research.name == "turret-shields-speed-1" or event.research.name == "turret-shields-speed-2" then
		global.forces[force.name].speed = (event.research.level*5+5)
		mode = "speed"
	end
	if event.research.name == "turret-shields-size-1" or event.research.name == "turret-shields-size-2" then
		global.forces[force.name].size = (event.research.level*50+50)
		mode = "size"
	end
	if event.research.name == "turret-shields-speed-3" then
		global.forces[force.name].speed = ((event.research.level-3)*10+15)
		mode = "speed"
	end
	if event.research.name == "turret-shields-size-3" then
		global.forces[force.name].size = ((event.research.level-3)*100+150)
		mode = "size"
	end
	if mode and global.energy_consumption then
		update_electricity(force,mode)
	end
end)


script.on_event(defines.events.on_research_started,function(event)
	if event.research.name == "turret-shields-speed-3" and event.research.level >=59 then
		event.research.force.print("Sorry, you have reached the maximum level for turret shields charging speed")
		event.research.force.current_research = nil
	end
end)


script.on_event(defines.events.script_raised_revive,function(event)
	if global.forces[event.entity.force.name].enabled then
		if event.entity.type == "ammo-turret"
		or event.entity.type == "fluid-turret"
		or event.entity.type == "electric-turret" then
			init_turret(event.entity,true)
		end
	end
	if event.entity.name=="turret-shield-combinator" then
		global.combinators[event.entity.unit_number]={}
		global.combinators[event.entity.unit_number].entity=event.entity
		global.combinators[event.entity.unit_number].turrets={}
		global.combinators_size = table_size(global.combinators)
	end
end)

script.on_event({defines.events.on_robot_built_entity,defines.events.on_built_entity},function(event)
	if global.forces[event.created_entity.force.name].enabled then
		if event.created_entity.type == "ammo-turret"
		or event.created_entity.type == "fluid-turret"
		or event.created_entity.type == "electric-turret" then
			init_turret(event.created_entity,true)
		end
	end
	if event.created_entity.name=="turret-shield-combinator" then
		global.combinators[event.created_entity.unit_number]={}
		global.combinators[event.created_entity.unit_number].entity=event.created_entity
		global.combinators[event.created_entity.unit_number].turrets={}
		global.combinators_size = table_size(global.combinators)
	end
end)


script.on_event(defines.events.on_entity_damaged,function(event)
	if not event.entity.valid then
		return
	end
	if global.energy_consumption and global.disabled_turrets[event.entity.unit_number] then return end
	if global.forces[event.entity.force.name] and global.forces[event.entity.force.name].enabled then
		if event.entity.type == "ammo-turret"
		or event.entity.type == "fluid-turret"
		or event.entity.type == "electric-turret" then
			if string.sub(event.entity.name,1,4)=="wisp" then return end
			local charging_speed
			local max_shield
			if global.research_enabled then
				charging_speed = global.forces[event.entity.force.name].speed/60*global.research_speed
				max_shield = global.forces[event.entity.force.name].size*global.research_size
			else
				charging_speed = global.forces[event.entity.force.name].speed/60
				max_shield = global.forces[event.entity.force.name].size
			end
			if global.turrets[event.entity.unit_number] then
				local damage=event.final_damage_amount
				
				local shieldamount
				local electric_buffer_size
				if global.energy_consumption then
					electric_buffer_size = global.turrets[event.entity.unit_number][7].electric_buffer_size
					shieldamount = global.turrets[event.entity.unit_number][7].energy / electric_buffer_size * max_shield
				else
					shieldamount = math.min(max_shield,global.turrets[event.entity.unit_number][2]+(game.tick-global.turrets[event.entity.unit_number][1])*charging_speed)
				end
				
				if event.entity.health > 0 or shieldamount > damage  then
					local min_shield = 3.4 + math.min(max_shield,200)/70
					if global.alternate_effect then
						min_shield = 2 + math.min(max_shield, 200)/15
					end
				
					local shield_active = (shieldamount > min_shield and shieldamount > damage/4) or shieldamount > damage
					local absorbed
					if shield_active then
						if global.turrets[event.entity.unit_number][3] and global.turrets[event.entity.unit_number][3].valid then global.turrets[event.entity.unit_number][3].destroy() end
						if global.energy_consumption then
							global.turrets[event.entity.unit_number][7].energy = math.max(0,(shieldamount-damage)/max_shield*electric_buffer_size)
							global.turrets[event.entity.unit_number][9] = global.turrets[event.entity.unit_number][9] +  math.min(shieldamount,damage)/max_shield*electric_buffer_size
							
						else
							global.turrets[event.entity.unit_number][1]=game.tick
							global.turrets[event.entity.unit_number][2]=math.max(0,shieldamount-damage)
						end
						event.entity.health = event.entity.health+math.min(damage, shieldamount)
						absorbed = math.min(shieldamount,damage)
						
						shieldamount = math.max(0,(shieldamount-damage))

						local shield= math.floor(math.max(0,(shieldamount)/max_shield*9))
						local surface = event.entity.surface
						local position = event.entity.position
						local index
						local effect = ""
						if event.entity.type == "fluid-turret" then
							if global.turrets[event.entity.unit_number][4] % 0.5 == 0 then
								global.turrets[event.entity.unit_number][3]=  surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 1.3}, force = "neutral"}
								index = math.floor((((shield+1)/9*max_shield-shieldamount)/charging_speed+event.tick+1))
								effect = "-big"
							else
								shield= math.floor(math.max(0,(shieldamount)/max_shield*13))
								global.turrets[event.entity.unit_number][3]=  surface.create_entity{name = "liquid-square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
								index = math.floor((((shield+1)/13*max_shield-shieldamount)/charging_speed+event.tick+1))
								effect = "-big"
							end
						else
							global.turrets[event.entity.unit_number][3]= surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
							index = math.floor((((shield+1)/9*max_shield-shieldamount)/charging_speed+event.tick+1))
						end
						global.turrets[event.entity.unit_number][3].destructible = false
			
						if global.energy_consumption then
							if global.electric_updater_disconnected[event.entity.unit_number] then
								global.electric_updater_disconnected[event.entity.unit_number]=0
							else
								--if global.turrets[event.entity.unit_number][7].is_connected_to_electric_network() or global.turrets[event.entity.unit_number][7].energy > 0 then
									global.electric_updater[event.entity.unit_number]=0
								--else
								--	global.electric_updater_disconnected[event.entity.unit_number]={event.entity,0}
								--end
							end
						else
							if global.updater[index]==nil then
								global.updater[index]={event.entity.unit_number}
							else
								table.insert(global.updater[index],event.entity.unit_number)
							end
						end

						if event.entity.name == "laser-turret" then
							position.y = position.y -0.16
							position.x = position.x +0.02					
						end
						
						
						if global.alternate_effect then
							if global.turrets[event.entity.unit_number][6] == nil or global.turrets[event.entity.unit_number][6] < game.tick-5 then
								if global.turrets[event.entity.unit_number][5] ~= nil and global.turrets[event.entity.unit_number][5].valid then
									effect = effect.."2"
									global.turrets[event.entity.unit_number][5].destroy()
								end
								global.turrets[event.entity.unit_number][5] = surface.create_entity{name = "shield-effect-alternate"..effect, position = {position.x-0.06, position.y -0.38}, force = "neutral"}
								global.turrets[event.entity.unit_number][6] = game.tick
							end
						else
							for i=1, math.max(1,absorbed/20) do
								surface.create_trivial_smoke{name="shield-effect"..effect, position = {position.x, position.y -0.48}}
							end
						end
					end
				else
					destroy_turret(event.entity.unit_number)
				end
			else
				init_turret(event.entity)
			end
		end
	end
end)
script.set_event_filter(defines.events.on_entity_damaged, {{filter = "turret"}})
-----------------------------------------------------------------------------------------------------------------------------------------------------------
function toggle_shield(turret,onoff)
	if not onoff and not global.disabled_turrets[turret.unit_number] then
		if global.energy_consumption then
			global.disabled_turrets[turret.unit_number] = {}
			global.disabled_turrets[turret.unit_number][1] = turret.surface.create_entity{name = "ts-unplugged", position = {turret.position.x, turret.position.y}, force = "neutral"}
			global.disabled_turrets[turret.unit_number][2] = turret
			if global.turrets[turret.unit_number] and global.turrets[turret.unit_number][3] and global.turrets[turret.unit_number][3].valid then global.turrets[turret.unit_number][3].destroy() end
			if global.turrets[turret.unit_number] and global.turrets[turret.unit_number][7] and global.turrets[turret.unit_number][7].valid then global.turrets[turret.unit_number][7].destroy() end
			global.turrets[turret.unit_number]=nil
		else
			global.disabled_turrets[turret.unit_number] = {}
			global.disabled_turrets[turret.unit_number][1] = turret.surface.create_entity{name = "ts-unplugged", position = {turret.position.x, turret.position.y}, force = "neutral"}
			global.disabled_turrets[turret.unit_number][2] = turret
		end
	elseif onoff and global.disabled_turrets[turret.unit_number] then
		if global.energy_consumption then
			global.disabled_turrets[turret.unit_number][1].destroy()
			global.disabled_turrets[turret.unit_number] = nil
			init_turret(turret,true)
		else
			global.disabled_turrets[turret.unit_number][1].destroy()
			global.disabled_turrets[turret.unit_number] = nil
		end
	end
	
end

function b2s(bool)
if bool then return "true" else return "false" end
end




script.on_event({defines.events.on_entity_died,defines.events.on_player_mined_entity,defines.events.on_robot_mined_entity},function(event)
	if event.entity.type == "ammo-turret"
	or event.entity.type == "fluid-turret"
	or event.entity.type == "electric-turret" then
		if global.disabled_turrets[event.entity.unit_number] then 
			global.disabled_turrets[event.entity.unit_number][1].destroy()
			global.disabled_turrets[event.entity.unit_number]=nil
		end
		if global.turrets[event.entity.unit_number] and global.turrets[event.entity.unit_number][3] and global.turrets[event.entity.unit_number][3].valid then global.turrets[event.entity.unit_number][3].destroy() end
		if global.energy_consumption then
			if global.turrets[event.entity.unit_number] and global.turrets[event.entity.unit_number][7] and global.turrets[event.entity.unit_number][7].valid then global.turrets[event.entity.unit_number][7].destroy() end
		end
		if global.iterate_turrets == event.entity.unit_number then
			global.iterate_turrets = next(global.turrets, global.iterate_turrets)
		end
		global.turrets[event.entity.unit_number] = nil
	end
	if event.entity.name=="turret-shield-combinator" then
		local tbl=global.combinators[event.entity.unit_number]
		for k,turret in pairs (tbl.turrets) do
			if turret and turret.valid then
				toggle_shield(turret,true)
			end
		end
		if global.iterate_combinators == event.entity.unit_number then
			global.iterate_combinators = next(global.combinators, global.iterate_combinators)
		end
		global.combinators[event.entity.unit_number]=nil
		global.combinators_size = table_size(global.combinators)
	end
end)
function destroy_turret(key)
	if global.turrets[key] then
		--if global.turrets[key].fx then global.turrets[key].fx.destroy() end
		if global.turrets[key][3] then global.turrets[key][3].destroy() end
		if global.turrets[key][7] then global.turrets[key][7].destroy() end
		--if global.turrets[key].disabled then global.turrets[key].disabled.destroy() end
		if global.iterate_turrets == key then
			global.iterate_turrets = next(global.turrets, key)
		end
		global.turrets[key] = nil
	end
	if key == global.iterate_e_updater then
		global.iterate_e_updater = next(global.electric_updater, key)
	end
	global.iterate_e_updater = nil
	if key == global.iterate_e_updater_disconnected then
		global.iterate_e_updater_disconnected = next(global.electric_updater_disconnected, key)
	end
	
	global.electric_updater_disconnected[key] = nil
	global.electric_updater[key] = nil
	
	global.turrets_size = table_size(global.turrets)
	global.e_updater_size = table_size(global.electric_updater)
	global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
end
--global.turrets
-- 1	tick of last update / last energy tick **
-- 2	shield at last update / last energy value **
-- 3	hpbar entity
-- 4	orientation
-- 5	shield effect entity
-- 6	tick of last shield effect
-- 7	electric interface entity
-- 8	turret entity
-- 9	damage taken since last tick **
-- 10	disabled entity or not
-- electric_updater[turret.unitnumber] = {turret_entity, ticks_fully_loaded}
-- updater[update_tick]={{turret,turret.unit_number}}