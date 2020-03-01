



script.on_init(function()
	global.version = 1
	global.shields = {}
end)


--script.on_configuration_changed(function()
--	
--end)




--script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
--	alternate_effect = settings.global["SFX_alternate_effect"].value
--end)


script.on_event(defines.events.on_entity_damaged or 97,function(event)
	if event.original_damage_amount >0 then return end
	if event.entity.type == "character"
	or event.entity.type == "car" then
		if not event.entity.grid then return end
		if event.entity.grid.shield <0.1 then return end
		if event.entity.grid.shield ==event.entity.grid.max_shield then return end
		
		local damage=event.final_damage_amount
		
		local shieldamount
		local max_shield = 200
		shieldamount = event.entity.grid.shield --200 --global.shields[event.entity.unit_number][7].energy / global.shields[event.entity.unit_number][7].electric_buffer_size * max_shield
		local min_shield = 3.4 + math.min(max_shield,200)/70
		if alternate_effect then
			min_shield = 2 + math.min(max_shield, 200)/15
		end
		
		if event.entity.health > 0 and ((shieldamount > min_shield and shieldamount > damage/2) or shieldamount > damage) then
	
			
				
				--if global.shields[event.entity.unit_number] and global.shields[event.entity.unit_number][2].valid then global.shields[event.entity.unit_number][2].destroy() end
	
	
			local surface = event.entity.surface
			local position = event.entity.position
			local effect = ""
			if string.find(event.entity.name,"tank") then
				effect = effect.."-big"
			end
			
			
	
			--if event.entity.name == "laser-turret" then
			--	position.y = position.y -0.16
			--	position.x = position.x +0.02					
			--end

			if not global.shields[event.entity.unit_number] then
				global.shields[event.entity.unit_number] = {event.entity}
			end
			if settings.global["SFX_alternate_effect"].value then
				if global.shields[event.entity.unit_number][3] == nil or global.shields[event.entity.unit_number][3] < game.tick-5 then
					if global.shields[event.entity.unit_number][2] ~= nil and global.shields[event.entity.unit_number][2].valid then
						effect = effect.."2"
						global.shields[event.entity.unit_number][2].destroy()
					end
					if event.entity.type == "car" then
						if string.find(event.entity.name,"tank") then
							position.y = position.y - 0.4
							position.x = position.x - 0.16
						end
						position.y = position.y + 0.42
					end
					global.shields[event.entity.unit_number][2] = surface.create_entity{name = "shield-effect-alternate"..effect, position = {position.x-0.06, position.y -0.5}, force = "neutral"}
					global.shields[event.entity.unit_number][3] = game.tick
				end
			else
				--for i=1, math.max(1,absorbed/20) do
					global.shields[event.entity.unit_number][4] = position
					global.shields[event.entity.unit_number][3] = game.tick
					if event.entity.type == "car" then
						position.y = position.y + 0.3
					end
					if effect == "-big" then
						position.y = position.y -0.31
						position.x = position.x -0.2
					end
					surface.create_trivial_smoke{name="shield-effect"..effect, position = {position.x, position.y -0.48}}
					surface.create_trivial_smoke{name="shield-effect"..effect, position = {position.x, position.y -0.48}}
				--end
			end

		end
		
	end
end)

function b2s(bool)
if bool then return "true" else return "false" end
end

script.on_nth_tick(1, function(event)
	for key, tbl in pairs(global.shields) do
		if tbl[1].valid and tbl[2] and tbl[2].valid then
			if tbl[1].type == "car" then
				if string.find(tbl[1].name,"tank") then
					tbl[2].teleport({tbl[1].position.x-0.22,tbl[1].position.y-0.48})
				else
					tbl[2].teleport({tbl[1].position.x-0.06,tbl[1].position.y-0.08})
				end
			else
				tbl[2].teleport({tbl[1].position.x-0.06,tbl[1].position.y-0.5})
			end
		elseif tbl[1].valid and not settings.global["SFX_alternate_effect"].value and tbl[4] ~=tbl[1].position and tbl[3] >event.tick -7 then

			if tbl[1].type == "car" then
				if string.find(tbl[1].name,"tank") then
					tbl[1].surface.create_trivial_smoke{name="shield-effect-big", position = {tbl[1].position.x-0.2, tbl[1].position.y -0.5}}
				else
					tbl[1].surface.create_trivial_smoke{name="shield-effect", position = {tbl[1].position.x, tbl[1].position.y -0.18}}
				end
			else
				tbl[1].surface.create_trivial_smoke{name="shield-effect", position = {tbl[1].position.x, tbl[1].position.y -0.6}}
			end
		else
			global.shields[key]=nil
		end
	end
end)


script.on_event({defines.events.on_entity_died,defines.events.on_player_mined_entity,defines.events.on_robot_mined_entity},function(event)
		if (event.entity.type == "character"
		or event.entity.type == "car")
		and global.shields[event.entity] then
			global.shields[event.entity] = nil
	end
end)

--global.shields[entity.unit_number]
-- 1	car / player entity
-- 2	shield
-- 3	alternate shield last update