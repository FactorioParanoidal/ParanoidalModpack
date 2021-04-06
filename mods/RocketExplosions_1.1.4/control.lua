-- changed: darkfrei 2021-04-05


function make_explosion (entity, chance)
	if math.random () < chance then
		-- https://lua-api.factorio.com/latest/LuaSurface.html#LuaSurface.create_entity
		entity.surface.create_entity{name="atomic-rocket", 
		position=entity.position, 
		target=entity, speed=1}
		return true
	end
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
	local c = drf^level * dlf^rockets_launched
	
	local failure_chance = dfc * (0.1*a + 0.1*b + 0.8*c)
	
	

	local was_explosion = make_explosion (rocket_silo, failure_chance)
--[[
	force.print('rockets launched: ' .. rockets_launched .. 
		'; level: ' .. level .. 
		'; failure chance: ' .. failure_chance ..
		'; a:'..a..' b:'..b..' c:'..c ..
		'; explosion: '.. tostring(was_explosion))
]]--
end)


--[[
local evo_frame = player.gui.top.add{
	type='frame', 
	name='evo_frame', 
	direction='horizontal', 
	style='outer_frame_without_shadow'
	} -- transparent frame
    evo_frame.add{
		type="label", 
		name='label_evolution', 
		caption = 'text' } -- tiny text
]]


--[[
tech_name: automation tech.level: 1
tech_name: automation-2 tech.level: 2
tech_name: automation-3 tech.level: 3
tech_name: electronics tech.level: 1
tech_name: fast-inserter tech.level: 1
tech_name: advanced-electronics tech.level: 1
tech_name: advanced-electronics-2 tech.level: 2
tech_name: circuit-network tech.level: 1
tech_name: explosives tech.level: 1
tech_name: logistics tech.level: 1
tech_name: logistics-2 tech.level: 2
tech_name: logistics-3 tech.level: 3
tech_name: optics tech.level: 1
tech_name: laser tech.level: 1
tech_name: solar-energy tech.level: 1
tech_name: gun-turret tech.level: 1
tech_name: laser-turret tech.level: 1
tech_name: stone-wall tech.level: 1
tech_name: gate tech.level: 1
tech_name: engine tech.level: 1
tech_name: electric-engine tech.level: 1
tech_name: lubricant tech.level: 1
tech_name: battery tech.level: 1
tech_name: landfill tech.level: 1
tech_name: braking-force-1 tech.level: 1
tech_name: braking-force-2 tech.level: 2
tech_name: braking-force-3 tech.level: 3
tech_name: braking-force-4 tech.level: 4
tech_name: braking-force-5 tech.level: 5
tech_name: braking-force-6 tech.level: 6
tech_name: braking-force-7 tech.level: 7
tech_name: chemical-science-pack tech.level: 1
tech_name: logistic-science-pack tech.level: 1
tech_name: military-science-pack tech.level: 1
tech_name: production-science-pack tech.level: 1
tech_name: space-science-pack tech.level: 1
tech_name: steel-processing tech.level: 1
tech_name: utility-science-pack tech.level: 1
tech_name: advanced-material-processing tech.level: 1
tech_name: steel-axe tech.level: 1
tech_name: advanced-material-processing-2 tech.level: 2
tech_name: concrete tech.level: 1
tech_name: electric-energy-accumulators tech.level: 1
tech_name: electric-energy-distribution-1 tech.level: 1
tech_name: electric-energy-distribution-2 tech.level: 2
tech_name: railway tech.level: 1
tech_name: fluid-wagon tech.level: 1
tech_name: automated-rail-transportation tech.level: 1
tech_name: rail-signals tech.level: 1
tech_name: robotics tech.level: 1
tech_name: construction-robotics tech.level: 1
tech_name: logistic-robotics tech.level: 1
tech_name: logistic-system tech.level: 1
tech_name: personal-roboport-equipment tech.level: 1
tech_name: personal-roboport-mk2-equipment tech.level: 1
tech_name: worker-robots-speed-1 tech.level: 1
tech_name: worker-robots-speed-2 tech.level: 2
tech_name: worker-robots-speed-3 tech.level: 3
tech_name: worker-robots-speed-4 tech.level: 4
tech_name: mining-productivity-1 tech.level: 1
tech_name: mining-productivity-2 tech.level: 2
tech_name: mining-productivity-3 tech.level: 3
tech_name: mining-productivity-4 tech.level: 4
tech_name: worker-robots-speed-5 tech.level: 5
tech_name: worker-robots-speed-6 tech.level: 6
tech_name: worker-robots-storage-1 tech.level: 1
tech_name: worker-robots-storage-2 tech.level: 2
tech_name: worker-robots-storage-3 tech.level: 3
tech_name: toolbelt tech.level: 1
tech_name: research-speed-1 tech.level: 1
tech_name: research-speed-2 tech.level: 2
tech_name: research-speed-3 tech.level: 3
tech_name: research-speed-4 tech.level: 4
tech_name: research-speed-5 tech.level: 5
tech_name: research-speed-6 tech.level: 6
tech_name: stack-inserter tech.level: 1
tech_name: inserter-capacity-bonus-1 tech.level: 1
tech_name: inserter-capacity-bonus-2 tech.level: 2
tech_name: inserter-capacity-bonus-3 tech.level: 3
tech_name: inserter-capacity-bonus-4 tech.level: 4
tech_name: inserter-capacity-bonus-5 tech.level: 5
tech_name: inserter-capacity-bonus-6 tech.level: 6
tech_name: inserter-capacity-bonus-7 tech.level: 7
tech_name: oil-processing tech.level: 1
tech_name: fluid-handling tech.level: 1
tech_name: advanced-oil-processing tech.level: 1
tech_name: coal-liquefaction tech.level: 1
tech_name: sulfur-processing tech.level: 1
tech_name: plastics tech.level: 1
tech_name: artillery tech.level: 1
tech_name: spidertron tech.level: 1
tech_name: military tech.level: 1
tech_name: atomic-bomb tech.level: 1
tech_name: military-2 tech.level: 2
tech_name: uranium-ammo tech.level: 1
tech_name: military-3 tech.level: 3
tech_name: military-4 tech.level: 4
tech_name: automobilism tech.level: 1
tech_name: flammables tech.level: 1
tech_name: flamethrower tech.level: 1
tech_name: tank tech.level: 1
tech_name: land-mine tech.level: 1
tech_name: rocketry tech.level: 1
tech_name: explosive-rocketry tech.level: 1
tech_name: energy-weapons-damage-1 tech.level: 1
tech_name: refined-flammables-1 tech.level: 1
tech_name: stronger-explosives-1 tech.level: 1
tech_name: weapon-shooting-speed-1 tech.level: 1
tech_name: artillery-shell-range-1 tech.level: 1
tech_name: artillery-shell-speed-1 tech.level: 1
tech_name: physical-projectile-damage-1 tech.level: 1
tech_name: rocket-failure-revision-1 tech.level: 1
tech_name: energy-weapons-damage-2 tech.level: 2
tech_name: physical-projectile-damage-2 tech.level: 2
tech_name: refined-flammables-2 tech.level: 2
tech_name: rocket-failure-revision-2 tech.level: 2
tech_name: stronger-explosives-2 tech.level: 2
tech_name: weapon-shooting-speed-2 tech.level: 2
tech_name: energy-weapons-damage-3 tech.level: 3
tech_name: physical-projectile-damage-3 tech.level: 3
tech_name: refined-flammables-3 tech.level: 3
tech_name: rocket-failure-revision-3 tech.level: 3
tech_name: stronger-explosives-3 tech.level: 3
tech_name: weapon-shooting-speed-3 tech.level: 3
tech_name: energy-weapons-damage-4 tech.level: 4
tech_name: physical-projectile-damage-4 tech.level: 4
tech_name: refined-flammables-4 tech.level: 4
tech_name: rocket-failure-revision-4 tech.level: 4
tech_name: stronger-explosives-4 tech.level: 4
tech_name: weapon-shooting-speed-4 tech.level: 4
tech_name: energy-weapons-damage-5 tech.level: 5
tech_name: physical-projectile-damage-5 tech.level: 5
tech_name: refined-flammables-5 tech.level: 5
tech_name: rocket-failure-revision-5 tech.level: 5
tech_name: stronger-explosives-5 tech.level: 5
tech_name: weapon-shooting-speed-5 tech.level: 5
tech_name: energy-weapons-damage-6 tech.level: 6
tech_name: energy-weapons-damage-7 tech.level: 7
tech_name: physical-projectile-damage-6 tech.level: 6
tech_name: physical-projectile-damage-7 tech.level: 7
tech_name: refined-flammables-6 tech.level: 6
tech_name: refined-flammables-7 tech.level: 7
tech_name: rocket-failure-revision-6 tech.level: 6
tech_name: rocket-failure-revision-7 tech.level: 7
tech_name: stronger-explosives-6 tech.level: 6
tech_name: stronger-explosives-7 tech.level: 7
tech_name: weapon-shooting-speed-6 tech.level: 6
tech_name: laser-shooting-speed-1 tech.level: 1
tech_name: laser-shooting-speed-2 tech.level: 2
tech_name: laser-shooting-speed-3 tech.level: 3
tech_name: laser-shooting-speed-4 tech.level: 4
tech_name: laser-shooting-speed-5 tech.level: 5
tech_name: laser-shooting-speed-6 tech.level: 6
tech_name: laser-shooting-speed-7 tech.level: 7
tech_name: defender tech.level: 1
tech_name: distractor tech.level: 1
tech_name: destroyer tech.level: 1
tech_name: follower-robot-count-1 tech.level: 1
tech_name: follower-robot-count-2 tech.level: 2
tech_name: follower-robot-count-3 tech.level: 3
tech_name: follower-robot-count-4 tech.level: 4
tech_name: follower-robot-count-5 tech.level: 5
tech_name: follower-robot-count-6 tech.level: 6
tech_name: follower-robot-count-7 tech.level: 7
tech_name: kovarex-enrichment-process tech.level: 1
tech_name: nuclear-fuel-reprocessing tech.level: 1
tech_name: nuclear-power tech.level: 1
tech_name: uranium-processing tech.level: 1
tech_name: heavy-armor tech.level: 1
tech_name: modular-armor tech.level: 1
tech_name: power-armor tech.level: 1
tech_name: power-armor-mk2 tech.level: 1
tech_name: energy-shield-equipment tech.level: 1
tech_name: energy-shield-mk2-equipment tech.level: 1
tech_name: night-vision-equipment tech.level: 1
tech_name: belt-immunity-equipment tech.level: 1
tech_name: exoskeleton-equipment tech.level: 1
tech_name: battery-equipment tech.level: 1
tech_name: battery-mk2-equipment tech.level: 1
tech_name: solar-panel-equipment tech.level: 1
tech_name: fusion-reactor-equipment tech.level: 1
tech_name: personal-laser-defense-equipment tech.level: 1
tech_name: discharge-defense-equipment tech.level: 1
tech_name: modules tech.level: 1
tech_name: speed-module tech.level: 1
tech_name: speed-module-2 tech.level: 2
tech_name: speed-module-3 tech.level: 3
tech_name: productivity-module tech.level: 1
tech_name: productivity-module-2 tech.level: 2
tech_name: productivity-module-3 tech.level: 3
tech_name: effectivity-module tech.level: 1
tech_name: effectivity-module-2 tech.level: 2
tech_name: effectivity-module-3 tech.level: 3
tech_name: effect-transmission tech.level: 1
tech_name: low-density-structure tech.level: 1
tech_name: rocket-control-unit tech.level: 1
tech_name: rocket-fuel tech.level: 1
tech_name: rocket-silo tech.level: 1
tech_name: cliff-explosives tech.level: 1

]]