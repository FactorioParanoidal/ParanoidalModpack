script.on_event(defines.events.on_tick, function(event)
	local tick = event.tick
	if tick % 31 < 3 then
		if tick % 31 == 0 then
			global.turrets_size = table_size(global.turrets)
		elseif tick % 31 == 1 then
			global.e_updater_size = table_size(global.electric_updater)
		else
			global.e_updater_disconnected_size = table_size(global.electric_updater_disconnected)
		end
	end
	if tick % 3 == 0 and global.combinators_size > 0 then
		local runs = math.max(1,global.combinators_size/20)
		local updates={}
		for i=1, runs do
			local key = global.iterate_combinators
			
			global.iterate_combinators = next(global.combinators, global.iterate_combinators)
			if key ~= nil then
			--for key, tbl in pairs(global.combinators) do
				local tbl = global.combinators[key]
				local entity = tbl.entity
				
				if not entity or not entity.valid then
					for k,turret in pairs (tbl.turrets) do
						if turret and turret.valid then
							toggle_shield(turret,false)
						end
					end
					global.combinators[key]=nil
					global.combinators_size = table_size(global.combinators)
					
				else
					entity.health=entity.health+4
					local control = entity.get_control_behavior()
					local red = control.get_circuit_network(defines.wire_type.red)
					local green = control.get_circuit_network(defines.wire_type.green)
					local val = 0
					if red then
						val = red.get_signal({type = "virtual", name = "signal-red"}) or 0
					end
					if green then 
						val = val + (green.get_signal({type = "virtual", name = "signal-red"}) or 0)
					end
					
					if tbl.orientation~=entity.orientation or val ~=0 and math.abs(tbl.amount or 0) ~= val or tick % 414 == 0 then
						local position=entity.position
						local onoff=val<=0
						local finder
						local mod = math.abs(val)-1
						if entity.orientation == 0 then
							position.y = position.y-1.5
							if val % 2 == 0 then position.x=position.x-0.5 end
							finder = entity.surface.find_entities({{position.x-0.2-mod,position.y-0.2},{position.x-0.2+mod,position.y+0.2}})
						elseif entity.orientation == 0.25 then
							position.x = position.x+1.5
							if val % 2 == 0 then position.y=position.y-0.5 end
							finder = entity.surface.find_entities({{position.x-0.2,position.y-0.2-mod},{position.x-0.2,position.y+0.2+mod}})
						elseif entity.orientation == 0.5 then
							position.y = position.y+1.5
							if val % 2 == 0 then position.x=position.x-0.5 end
							finder = entity.surface.find_entities({{position.x-0.2-mod,position.y-0.2},{position.x-0.2+mod,position.y+0.2}})
						elseif entity.orientation == 0.75 then
							position.x = position.x-1.5
							if val % 2 == 0 then position.y=position.y-0.5 end
							finder = entity.surface.find_entities({{position.x-0.2,position.y-0.2-mod},{position.x-0.2,position.y+0.2+mod}})
						end
						
						local checksum = 0
						--local shield_amount = 0
						local turr={}
						for k,turret in pairs (finder) do
							if turret.type == "fluid-turret" or turret.type == "ammo-turret" or turret.type == "electric-turret" then
								checksum = checksum + turret.unit_number
								turr[turret.unit_number]=turret
								
								
							end
						end
						if tbl.checksum ~= checksum and val ~= 0 then
							for k,turret in pairs (tbl.turrets) do
								if turret and turret.valid and not turr[turret.unit_number] then
									if not updates[turret.unit_number] then
										updates[turret.unit_number]={turret,true} 
									end
								end
							end
							for k,turret in pairs (turr) do
								if turret and turret.valid then
									if not updates[turret.unit_number] then 
										updates[turret.unit_number] = {turret,onoff}
									else
										updates[turret.unit_number][2]= onoff and updates[turret.unit_number][2]
									end
								end
							end
							tbl.turrets=turr
							tbl.checksum=checksum
							tbl.orientation=entity.orientation
							tbl.value=val
							tbl.amount=val
						end
		
					elseif tbl.value~=val or tick % 240 then
						tbl.value=val
						val = val<=0
						for k,turret in pairs (tbl.turrets) do
							if turret and turret.valid then
								if not updates[turret.unit_number] then 
									updates[turret.unit_number]={turret,val}
								else
									updates[turret.unit_number][2]= val and updates[turret.unit_number][2]
								end
							end
						end
					end
				end
			end
		end
		for key, tbl in pairs(updates) do
			toggle_shield(tbl[1],tbl[2])
		end
	end
	if tick % 299 == 0 then
		local i = 0
		for key, entity in pairs(global.refresh_orientation) do
			if entity.valid and global.energy_consumption and global.disabled_turrets[entity.unit_number] then
				global.refresh_orientation[key]=nil
				break
			end
    
			if entity.valid and entity.shooting_target == nil and entity.orientation % 0.25 == 0 then
				global.turrets[entity.unit_number][4] =	entity.orientation
				if global.energy_consumption then
					local position = global.turrets[entity.unit_number][7].position
					if entity.orientation == 0 then
						position.y = position.y+0.5
					elseif entity.orientation == 0.25 then
						position.x = position.x-0.5
					elseif entity.orientation == 0.5 then
						position.y = position.y-0.5
					elseif entity.orientation == 0.75 then
						position.x = position.x+0.5
					end
					global.turrets[entity.unit_number][7].teleport(position)
				end
				global.refresh_orientation[key]=nil
			elseif not entity.valid then
				global.refresh_orientation[key]=nil
			else
				i=i+1
			end
		end
	end
	--cleanup icons from script-deleted turrets
	if tick % 437 == 0 then
		for key, tabl in pairs(global.disabled_turrets) do
			if not global.disabled_turrets[key][2] or not global.disabled_turrets[key][2].valid then
				destroy_turret(key)
				--if global.disabled_turrets[key][1] and global.disabled_turrets[key][1].valid then global.disabled_turrets[key][1].destroy() end
				--global.disabled_turrets[key]=nil
				--if global.turrets[key] then
				--	if global.turrets[key][3] and global.turrets[key][3].valid then global.turrets[key][3].destroy() end
				--	if global.turrets[key][7] and global.turrets[key][7].valid then global.turrets[key][7].destroy() end
				--	global.turrets[key]=nil
				--end
				--global.electric_updater_disconnected[key]=nil
				--global.electric_updater[key]=nil
			end
		end
	end
	if global.energy_consumption then
		local runs = math.max(1,(global.e_updater_disconnected_size*2.5)^0.45/2.5)
		--print("e_updater_disconnected_size: "..runs)
		for i=1, runs do
			local key = global.iterate_e_updater_disconnected
			
			global.iterate_e_updater_disconnected = next(global.electric_updater_disconnected, global.iterate_e_updater_disconnected)
			if key ~= nil then
				if not global.turrets[key] or not global.turrets[key][8].valid or global.disabled_turrets[key] then
					destroy_turret(key)
				elseif global.turrets[key] and global.turrets[key][7].energy>0 then					
					global.electric_updater[key] = 0
					global.electric_updater_disconnected[key] = nil
				end
			end
		end
		runs = math.max(1,(global.turrets_size*2.5)^0.45/2.5)
		--print("turrets: "..runs)
		for i=1, runs do
			local key = global.iterate_turrets
			
			global.iterate_turrets = next(global.turrets, global.iterate_turrets)
			if key ~= nil then
				local tbl = global.turrets[key]
				if tbl and (not tbl[7].valid or not tbl[8].valid) then
					destroy_turret(key)
				else
					if global.turrets[key][7].energy<global.turrets[key][7].electric_buffer_size*0.9993 and not global.electric_updater_disconnected[key]and not global.electric_updater[key] then
						if global.turrets[key][7].energy > 0 then
							global.electric_updater[key]=0
						else
							global.electric_updater_disconnected[key]=0
						end
					end
				end
			end
		end
		runs = math.max(1,global.e_updater_size/23)
		--print("e_updater: "..runs)
		for i=1, runs do
			--print(i)
			local key = global.iterate_e_updater
			
			global.iterate_e_updater = next(global.electric_updater, global.iterate_e_updater)
			if key ~= nil then
				local ticks = global.electric_updater[key]
				if not global.turrets[key] or not global.turrets[key][8].valid then
					destroy_turret(key)
					
				elseif global.disabled_turrets[key] then
					global.electric_updater[key]=nil
					
					--if global.turrets[key] then
					--	if global.turrets[key][3] and global.turrets[key][3].valid then global.turrets[key][3].destroy() end
					--	if global.turrets[key][7] and global.turrets[key][7].valid then global.turrets[key][7].destroy() end
					--	global.turrets[key] = nil
					--end
					--
				else
					local electric = global.turrets[key][7]
					local energy = electric.energy
					local electric_buffer_size = electric.electric_buffer_size
					local power_usage = electric.power_usage
					if energy == 0 then
						global.electric_updater_disconnected[key] = ticks
						global.electric_updater[key] = nil
	
					else
						if global.turrets[key][2]-global.turrets[key][9] > energy and global.penalty > 0 and power_usage > 0 then
							--game.print("global.penalty: "..(global.turrets[key][2] - global.turrets[key][9] - global.turrets[key][7].energy)/((game.tick - global.turrets[key][1])*global.turrets[key][7].power_usage)*global.turrets[key][7].electric_buffer_size/9/3)
							--game.print(global.turrets[key][2] - global.turrets[key][9] - global.turrets[key][7].energy)
							--game.print(math.max(1,tick - global.turrets[key][1])*global.turrets[key][7].power_usage)
							local ticks_since = math.max(1,tick - global.turrets[key][1])
							energy = energy - (global.turrets[key][2] - global.turrets[key][9] - energy)/(ticks_since*power_usage)*electric_buffer_size*global.penalty/60*ticks_since
							global.turrets[key][7].energy = energy
						end				-- 100 verlorene energie / (6 ticks*10 usage) (=1.6)
						global.turrets[key][1]=tick
						global.turrets[key][2]=energy
						global.turrets[key][9]=0
						
						
						local entity = global.turrets[key][8]
						local hpbar = global.turrets[key][3]
						
						if global.research_enabled then
							charging_speed = global.forces[entity.force.name].speed/60*global.research_speed
							max_shield = global.forces[entity.force.name].size*global.research_size
						else
							charging_speed = global.forces[entity.force.name].speed/60
							max_shield = global.forces[entity.force.name].size
						end
						local shieldamount = energy / electric_buffer_size * max_shield + 0.1
						if shieldamount<max_shield or ticks < 3 then
							if shieldamount >= max_shield then
								global.electric_updater[key] = ticks+5
							end
							
							local shield = math.min(9,math.max(0,math.floor(shieldamount/max_shield*9)))
							local oldshield
							if hpbar and hpbar.valid then
								if entity.type == "fluid-turret" and global.turrets[entity.unit_number][4] % 0.5 ~= 0 then
									shield= math.min(13,math.max(0,math.floor(shieldamount/max_shield*13)))
									oldshield= tonumber( string.sub(global.turrets[entity.unit_number][3].name,15))
								else
									oldshield= tonumber( string.sub(global.turrets[entity.unit_number][3].name,8))
								end
							end
		
							if not hpbar or not hpbar.valid or shield ~= oldshield then
								if hpbar and hpbar.valid then hpbar.destroy() end
								
								local position = entity.position
								local index
								if entity.type == "fluid-turret" then
									if global.turrets[key][4] % 0.5 == 0 then
										global.turrets[entity.unit_number][3]=  entity.surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 1.3}, force = "neutral"}
									else
										shield = math.min(13,math.max(0,math.floor(shieldamount/max_shield*13)))
										global.turrets[entity.unit_number][3]=  entity.surface.create_entity{name = "liquid-square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
									end
								else
									global.turrets[entity.unit_number][3]= entity.surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
								end
								global.turrets[entity.unit_number][3].destructible = false
							end
						else
							--if hpbar and hpbar.valid then hpbar.destroy() end
							global.electric_updater[key]=nil
						end
					end
				end
			end
		end
	
	else
		if global.updater[tick] then
			for i, unit_number in pairs(global.updater[tick]) do
				--local entity = tabl[1]
				--local unit_number = tabl[2]
				if global.turrets[unit_number] and global.turrets[unit_number][8].valid then
					local entity = global.turrets[unit_number][8]
					local charging_speed
					local max_shield
					if global.research_enabled then
						charging_speed = global.forces[entity.force.name].speed/60*global.research_speed
						max_shield = global.forces[entity.force.name].size*global.research_size
					else
						charging_speed = global.forces[entity.force.name].speed/60
						max_shield = global.forces[entity.force.name].size
					end
					if global.turrets[unit_number][3] and global.turrets[unit_number][3].valid then global.turrets[unit_number][3].destroy() end
					
					local shieldamount = global.turrets[unit_number][2]+(tick-global.turrets[unit_number][1])*charging_speed
					
					if shieldamount<=max_shield*1.08 then
	
						local shield= math.min(9,math.max(0,math.floor(shieldamount/max_shield*9)))
						local position = entity.position
						local index
						if entity.type == "fluid-turret" then
							if global.turrets[unit_number][4] % 0.5 == 0 then
								global.turrets[unit_number][3]=  entity.surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 1.3}, force = "neutral"}
								index = math.floor((((shield+1)/9*max_shield-shieldamount)/charging_speed+tick+1))
							else
								shield= math.min(13,math.max(0,math.floor(shieldamount/max_shield*13)))
								global.turrets[unit_number][3]=  entity.surface.create_entity{name = "liquid-square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
								index = math.floor((((shield+1)/13*max_shield-shieldamount)/charging_speed+tick+1))
							end
						else
							global.turrets[unit_number][3]= entity.surface.create_entity{name = "square-"..shield, position = {position.x+0.01, position.y + 0.8}, force = "neutral"}
							index = math.floor((((shield+1)/9*max_shield-shieldamount)/charging_speed+tick+1))
						end
						global.turrets[unit_number][3].destructible = false
						
						if global.updater[index]==nil then
							global.updater[index]={unit_number}
						else
							table.insert(global.updater[index],unit_number)
						end
					end
				else
					destroy_turret(unit_number)
					--if global.turrets[tabl[2]] and global.turrets[tabl[2]][3] and global.turrets[tabl[2]][3].valid then global.turrets[tabl[2]][3].destroy() end
					--if global.turrets[tabl[2]] and global.turrets[tabl[2]][7] and global.turrets[tabl[2]][7].valid then global.turrets[tabl[2]][7].destroy() end
					--global.turrets[tabl[2]]=nil
				end
			end
			global.updater[tick] = nil
		end
	end
	
end)