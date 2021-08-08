script.on_init(function() onInit() end)

function onInit()
    global.TN_shockwave_approaching = global.TN_shockwave_approaching or false
    global.TN_shockwave_impact_tick = global.TN_shockwave_impact_tick or {}
	global.TN_lightEffects = global.TN_lightEffects or {}
    -- WIP
end

function dist_a_b(PositionA, PositionB)
    return math.sqrt((PositionB.x - PositionA.x)^2+(PositionB.y-PositionA.y)^2) 
end

function shockwaveTravelTimeInTicks(distance)
    return (distance*60)/330
    -- WIP
end

function createBlastSoundsAndFlash(position, surface, radius_1, radius_2, radius_3, radius_4, radius_radiation, light_scale)
	local evtSurfaceID 
	if surface then
		evtSurfaceID = surface.index 
	end
	local dist = 0
	local renderFlashForPlayers = {}
	for i, player in pairs(game.connected_players) do
		if player.mod_settings["TN-mushroom-cloud-style-nuclear-flash"].value == true then
			renderFlashForPlayers[#renderFlashForPlayers + 1] = player
		end
	end
	local flashBase
	local flash
	if #renderFlashForPlayers > 0 then
		flashBase = rendering.draw_light{sprite = "utility/light_medium", scale = 5*light_scale, intensity = 1, minimum_darkness = 0, 
			target = position, surface = surface, time_to_live = 300, players = renderFlashForPlayers}
		flash = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 5*light_scale, y_scale = 5*light_scale, render_layer = "light-effect", 
			minimum_darkness = 0, tint = {0.95, 0.95, 1, 1}, target = position, surface = surface, time_to_live = 300, players = renderFlashForPlayers}
	end
	local lightGlow = rendering.draw_light{sprite = "utility/light_medium", scale = 50*light_scale, intensity = 0.4, minimum_darkness = 0, 
		target = position, surface = surface, color = {1, 0.5, 0.2, 0.1}, time_to_live = 500}	
	local lightBase = rendering.draw_light{sprite = "utility/light_medium", scale = 20*light_scale, intensity = 1, minimum_darkness = 0, 
		target = position, surface = surface, time_to_live = 500}
	local lightSurface = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 20*light_scale, y_scale = 17*light_scale, render_layer = "lower-object-above-shadow", 
		minimum_darkness = 0, tint = {0.75, 0.65, 0.6, 0.2}, target = position, surface = surface, time_to_live = 500}
	local lightObjects = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 25*light_scale, y_scale = 21.5*light_scale, render_layer = "entity-info-icon-above", 
		minimum_darkness = 0, tint = {1, 0.9, 0.5, 0.4}, target = position, surface = surface, time_to_live = 500}
	local lightCenterGlow = rendering.draw_sprite{sprite = "utility/light_medium", x_scale = 10*light_scale, y_scale = 8*light_scale, render_layer = "light-effect", 
		minimum_darkness = 0, tint = {1, 0.5, 0.2, 0.4}, target = position, surface = surface, time_to_live = 500}
	local effects = {}
	effects.maxDur = 500
	effects.ttl = 500
	effects.tickstart = game.tick
	effects.tickend = game.tick + effects.ttl
	effects.ids = {glow = lightGlow, light = lightBase, surface = lightSurface, objects = lightObjects, center = lightCenterGlow}
	if flashBase ~= nil then
		
		effects.flashDuration = 5
		effects.flashMaxScale = 100*light_scale
		effects.flashTransition = 300		
		effects.flashTransitionScale = 20
		effects.flashTransitionStartFadeOut = 150
		local flashTransitionColorStart = {0.95, 0.95, 1, 1}
		local flashTransitionColorEnd = {1, 0.5, 0.2, 0.4}
		local flashTransitionTicks = effects.flashDuration - effects.flashTransitionStartFadeOut
		local flashTransitionColorStep = {
			(flashTransitionColorStart[1] - flashTransitionColorEnd[1]) / flashTransitionTicks,  
			(flashTransitionColorStart[2] - flashTransitionColorEnd[2]) / flashTransitionTicks,
			(flashTransitionColorStart[3] - flashTransitionColorEnd[3]) / flashTransitionTicks,
			(flashTransitionColorStart[4] - flashTransitionColorEnd[4]) / flashTransitionTicks}			
		effects.flashTransitionColorStep = flashTransitionColorStep
		effects.flashTransitionColorEnd = flashTransitionColorEnd
		effects.ids.flashBase = flashBase
		effects.ids.flash = flash
	end
	effects.light_scale = light_scale;
	if global.TN_lightEffects == nil then
		global.TN_lightEffects = {}
	end
	
	global.TN_lightEffects[#global.TN_lightEffects+1] = effects
		
        for i, player in pairs(game.connected_players) do
		if player.surface.index == evtSurfaceID then
			dist = dist_a_b(player.position, position)
			if dist < radius_1 then
				player.play_sound{path = "nuclear-detonation-close-proximity"}
				--player.surface.create_entity({name = "nuclears-detonation-close-proximity", position = player.position})
			elseif dist < radius_2 then
				player.play_sound{path = "nuclear-detonation-in-vincinity"}
				--player.surface.create_entity({name = "nuclear-detonation-in-vincinity", position = player.position})
			elseif dist < radius_3 then
				player.play_sound{path = "nuclear-detonation-distant-boom"}
				--player.surface.create_entity({name = "nuclear-detonation-distant-boom", position = player.position})
			elseif dist < radius_4 then
				player.play_sound{path = "nuclear-detonation-far-away"}
				--player.surface.create_entity({name = "nuclear-detonation-far-away", position = player.position})
			end
			if dist < radius_radiation then
				player.play_sound{path = "nuclear-detonation-radiation-ticking"}
			end
		end
        end
end

function everyTick(event)	
	if global.TN_lightEffects == nil then
		global.TN_lightEffects = {}
	end
	if global.TN_lightEffects ~= nil then
		for i, effects in pairs(global.TN_lightEffects) do
			effects.ttl = effects.ttl - 1
			if effects.ttl <= 0 then 
				global.TN_lightEffects[i] = nil
			else
				local maxDur = effects.maxDur
				if effects.ids.flash ~= nil then
					local fs = 0
					local ftProgress = 0
					
					local flashBase = effects.ids.flashBase
					local flash = effects.ids.flash
					
					if (maxDur - effects.ttl) < effects.flashDuration then
						fs = ((maxDur - effects.ttl) / effects.flashDuration) * effects.flashMaxScale
						
						rendering.set_scale(flashBase, fs)
						rendering.set_x_scale(flash, fs)
						rendering.set_y_scale(flash, fs)
						
					elseif (maxDur - effects.ttl) < effects.flashTransition then
						fs = effects.flashMaxScale - ((effects.flashMaxScale - effects.flashTransitionScale) / (effects.flashTransition - effects.flashDuration)) * (maxDur - effects.ttl - effects.flashDuration)
						ftProgress = (effects.flashMaxScale - fs) / effects.flashTransitionScale
						
						rendering.set_x_scale(flash, fs)
						rendering.set_y_scale(flash, fs)
						rendering.set_intensity(flashBase, 1 - ftProgress)
						
						if (maxDur - effects.ttl) < effects.flashTransitionStartFadeOut then
							local fctProgress = (maxDur - effects.ttl - effects.flashDuration) / (effects.flashTransitionStartFadeOut - effects.flashDuration) 
							
							local currentColor = rendering.get_color(flash)
							
							rendering.set_color(flash, {currentColor.r + effects.flashTransitionColorStep[1], currentColor.g + effects.flashTransitionColorStep[2], currentColor.b + effects.flashTransitionColorStep[3], currentColor.a + effects.flashTransitionColorStep[4]})
						else
							local ffaProgress = 1 - ((maxDur - effects.ttl - effects.flashTransitionStartFadeOut) / (effects.flashTransition - effects.flashTransitionStartFadeOut))
							
							rendering.set_color(flash, {effects.flashTransitionColorEnd[1] * ffaProgress, effects.flashTransitionColorEnd[2] * ffaProgress, effects.flashTransitionColorEnd[3] * ffaProgress, effects.flashTransitionColorEnd[4] * ffaProgress})
						end
					end
				end
				
				local p0 = math.min(math.max(0, (effects.ttl - 100)) / 400, 1)
				local p02 = math.min(math.max(0, (effects.ttl - 200)) / 300, 1)
				local p03 = math.min(math.max(0, (effects.ttl - 200)) / 300, 1)
				local p1 = math.min(effects.ttl / 400, 1)
				local p2 = math.min(effects.ttl / 300, 1)
				local p3 = math.min(effects.ttl / 240, 1)
				local p4 = math.min(effects.ttl / 180, 1)
				local a1 = math.max((maxDur - effects.ttl) / 250, 1)
				local a2 = math.min((maxDur - effects.ttl) / 120, 1)
				local a3 = math.min((maxDur / effects.ttl) * 5, 2)
				
				
				local glow = effects.ids.glow
				local light = effects.ids.light
				local surface = effects.ids.surface
				local objects = effects.ids.objects
				local center = effects.ids.center
				
				rendering.set_intensity(glow, p2 * 0.4)
				rendering.set_intensity(light, a1 * p3 * 1)
				rendering.set_scale(light, a3 * p3 * 20 * effects.light_scale)
				rendering.set_color(light, {1, math.min(a3/2 * p4, 1), math.min(a3/2 * p4, 1), 1})
				
				rendering.set_color(surface, {p02 * 0.75, p02 * 0.65, p02 * 0.6, p02 * 0.2})
				rendering.set_x_scale(surface, p1 * 20 * effects.light_scale)
				rendering.set_y_scale(surface, p1 * 17 * effects.light_scale)
				
				rendering.set_color(objects, {p02 * 1, p02 * 0.9, p02 * 0.5, p02 * 0.4})
				rendering.set_x_scale(objects, p2 * 25 * effects.light_scale)
				rendering.set_y_scale(objects, p2 * 21.5 * effects.light_scale)
				
				rendering.set_color(center, {p03 * a2 * 1, p03 * a2 * 0.3, p03 * a2 * 0.1, p03 * a2 * 0.4})
				rendering.set_x_scale(center, p1 * 10 * effects.light_scale)
				rendering.set_y_scale(center, p1 * 8 * effects.light_scale)
			end
		end
	end
end
return {createBlastSoundsAndFlash, everyTick}
