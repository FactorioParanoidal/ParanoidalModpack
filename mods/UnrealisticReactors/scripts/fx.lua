local rpath = (...):match("(.-)[^%.]+$")
local Setting = require(rpath .. "setting")


-- TODO merge geiger into geiger-counter
-- FIXME use damage type resistances for radiation via data


local function periodic_pollution(entity,mult) --on_tick
	entity.surface.pollute(entity.position, math.floor(20000*mult)) --0.002% evo
end


-- radiation damage function
local function radio_damage(entity,force,tick)
	if entity.type == "character" then
		--sound
		if entity.player then
			if global.geigers[entity.player.index] == nil
			or global.geigers[entity.player.index]+3 < tick then
				
				local index = math.floor(global.random()*1.99)
				global.geigers[entity.player.index] = tick
				
				entity.player.play_sound{
					path = "RR-geiger-" .. index,
					volume_modifier =0.7,
				}
				
			end
		end
		--damage
		local resist = 1 --resistances
		if entity.grid then
			if entity.grid.max_shield > 0 then
				resist = 1 - math.min(35,entity.grid.shield)/35
				entity.damage(math.min(entity.grid.shield, 35)+0.0001,game.forces.neutral,"electric")
			else
				entity.damage(0.0001,game.forces.neutral,"electric")
			end
			if entity.grid.shield > 0 then return end
			if entity.grid.prototype.name == "radiation-suit-grid" then
				resist = resist*0.1
			elseif entity.grid.prototype.name == "small-equipment-grid" then
				resist = resist*0.85
			elseif entity.grid.prototype.name == "medium-equipment-grid" then
				resist = resist*0.7
			else
				resist = resist*0.55
			end
		else
			entity.damage(0.0001,game.forces.neutral,"electric")
		end
		if force == "radioactivity" then
			entity.health = entity.health -0.25*resist
			entity.damage(0.13*resist,game.forces.neutral,"electric")
		else
			entity.health = entity.health -0.4*resist
			entity.damage(0.2*resist,game.forces.neutral,"electric")
		end
		if entity.health < 1 then
			entity.die(force)
		end
	else
		if force == "radioactivity" then
			entity.health = entity.health -0.4
		else
			entity.health = entity.health -0.6
		end
		if entity.health < 1 then
			entity.die(force)
		end
	
	end
end


-- radiation damage (event)
local function on_script_trigger_effect(effect_id, entity, force, tick)
	if (effect_id == "radiation-damage" or effect_id == "radiation-damage-strong") and entity then
		if effect_id == "radiation-damage" then
			force = "radioactivity"
		else
			force = "radioactivity-strong"
		end
		if entity.type == "car" then
		
			local passenger = entity.get_passenger()	--passenger
			if passenger and passenger.type == "character" and passenger.has_flag("breaths-air") then
				radio_damage(passenger, force, tick)
			end
			
			local passenger = entity.get_driver()		--driver
			if passenger and passenger.name == "character" and passenger.has_flag("breaths-air") then
				radio_damage(passenger, force, tick)
			end
			
		elseif entity.type == "character" and entity.has_flag("breaths-air") then
			radio_damage(entity, force, tick)
			
		elseif entity.has_flag("breaths-air") then
			radio_damage(entity, force, tick)
		end
	end
end


--fallout stuff...
local function circular_radiation(surface,position,min_radius,size)
	local step = 3.2
	if min_radius == 0 then
		surface.create_entity{
			name = "permanent-radiation",
			position = position,
			force = "radioactivity",
		}
		surface.create_entity{
			name = "permanent-radiation",
			position = position,
			force = "radioactivity",
		}
		min_radius = min_radius + 1
	end
	for spread = min_radius, size do --each run adds another layer
		local x = position.x-step/2*spread
		local y = position.y-step/2*spread
		for i=1, spread*4 do
			
			surface.create_entity{
				name = "permanent-radiation",
				position = {x,y},
				force = "radioactivity",
			}
			if i <= spread then
				x=x+step
				y=y-step*0.7*(1- i / ((spread+1)/2)) --almost perfect circle
	
			elseif i <= spread * 2 then
				y=y+step
				x=x+step*0.7*(1- (i-spread) / ((spread+1)/2))
	
			elseif i <= spread * 3 then
				x=x-step
				y=y+step*0.7* (1- (i-spread*2) / ((spread+1)/2))
	
			elseif i <= spread * 4 then
				y=y-step
				x=x-step*0.7*(1- (i-spread*3) / ((spread+1)/2))
	
			end
		end
	end
end


return { -- exports
	effect = on_script_trigger_effect,
	periodic_pollution = periodic_pollution,
	circular_radiation = circular_radiation,
}
