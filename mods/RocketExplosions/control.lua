-- changed: darkfrei 2021-07-20

function playSound(entity)
  entity.surface.play_sound -- https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.play_sound
  {
    path = "rocket-win"
  }
end


function make_explosion (entity, chance)
	if math.random () < chance then
	-- is explosion!
		-- https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.create_entity
		entity.surface.create_entity{name="atomic-rocket", 
		position=entity.position, 
		target=entity, speed=1}
		return true
	end
	-- did not explode
	return false
end

function get_tech_level (force, tech_name)
    local level = 0
    local techs = force.technologies
    
    local tech = techs[tech_name] or techs[tech_name..'-1']
    
    if tech and tech.researched then
        level = tech.level
        local i = 1
        local fl = true
        while fl do
            i=i+1
            local tech = techs[tech_name..'-'..i]
            if tech and tech.researched then
                --game.print ('ok: i: '..i)
                level=tech.level
            elseif tech then
                -- level 7 or not researched
                fl = false
                
                if not (techs[tech_name..'-'..(i+1)]) then
                    -- there is no level 8 at all
                    level=tech.level
                end
            else
                fl = false
            end
        end
    else
        --game.print ('not researched')
        return 0
    end
    return level
end

script.on_event(defines.events.on_rocket_launch_ordered, function(event)
	local rocket_silo = event.rocket_silo
	local force = rocket_silo.force
	local force_name = force.name
	local surface = rocket_silo.surface
	
	-- https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.rockets_launched
	local rockets_launched = game.forces[force_name].rockets_launched

	local tech_name = "rocket-failure-revision"
	
--	for tech_name, tech in pairs (force.technologies) do
--		log ('tech_name: ' .. tech_name .. ' tech.level: ' .. tech.level)
--	end
	
--	https://lua-api.factorio.com/latest/LuaForce.html#LuaForce.technologies
	local level = get_tech_level (force, tech_name)
	
	
--	local dfc = 0.5 -- default failure chance
	local dfc = settings.global["re-default-failure-chance"].value / 100
	
--	local drf = 0.9 -- research factor
	local drf = settings.global["re-research-factor"].value / 100
	
--	local dlf = 0.9 -- launch factor
	local dlf = settings.global["re-launch-factor"].value / 100
	
	local a = drf^level
	local b = dlf^rockets_launched	
	local failure_chance = dfc * (0.1*a + 0.1*b + 0.8*a*b)
	
	local was_explosion = make_explosion (rocket_silo, failure_chance)
	
	if (not was_explosion) and rockets_launched == 0 then
		playSound(rocket_silo)
	end
	
end)
