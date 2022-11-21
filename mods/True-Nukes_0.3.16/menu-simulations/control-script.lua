
-- All attribution for the part of this copied from MushroomCloud remains with MushroomCloud, as stated in the attribution file in the MushroomCloud directory

return [[script.on_init(function() onInit() end)

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

 -- This is the end of stuff coppied from MushroomCloud


script.on_init(function()
	global.waitingNukeCratersBasic = {}		-- a simple array of the craters, {t = the number minutes it has been waiting for, pos = centre of crater, d = diameter too fill, s = surface index}
	global.blastWaves = {}					-- a simple array, with elements:
	--{r = currrent explosion radius, pos = centre position, pow = initial blast multiplier (usually initial r*r)
	-- , max = maximum radius, s = surface index, fire = leave fires (true for thermobarics, false for nukes), damage_init = starting damage, speed = how far to jump every round, fire_rad = the radius to which the fire wave is solid
	-- , blast_min_damage = amount of extra damage to add all the time, itt = the number of itterations done, doItts = whether to time slice the blast, ittframe = keeps track of frame count for time slicing
	-- , force = force of the cause of the explosion - allows allocating kills correctly, cause = allows allocating kills to the originator})

	global.nukeBuildings = {} 				-- array of the LuaEntities for any nukeBuildings

	global.cratersFast = {} 				-- map: cratersFast[surface index][xposition][yposition] = the highest water height in that area (x, y in units of 10)
	global.cratersFastData = {}				-- map: cratersFastData[surface index] = 
	-- {synch =  1-4 making deep water travel slower, xCount = number of x chunks on this surface, xCountSoFar = number of x chunks done so far this round, xDone = all x values done so far this round}
	global.cratersFastItterationCount = 0	-- the counter of ticks for circling x chunks - counts up to 53


	global.cratersSlow = {} 				-- array of {t = time waiting - 20s units, x = xin units of 32, y = y in units of 32, surface = the surface index}
end)

-- These allow lookups to find tiles of interest in an area.
local waterAndCraterTypes = {"nuclear-deep", "nuclear-crater", "nuclear-shallow", "nuclear-crater-shallow-fill", "nuclear-deep-shallow-fill", "nuclear-deep-fill", "deepwater", "water", "water-shallow", "water-mud"}

local waterTypes = {"water-shallow", "water-mud", "nuclear-crater-shallow-fill", "water", "nuclear-deep-shallow-fill", "nuclear-deep-fill", "deepwater"}

local craterTypes0 = {"nuclear-deep", "nuclear-crater", "nuclear-shallow", "nuclear-crater-shallow-fill", "nuclear-deep-shallow-fill", "nuclear-deep-fill"}
local craterTypes1 = {"nuclear-deep", "nuclear-crater", "nuclear-deep-shallow-fill"}
local craterTypes2 = {"nuclear-deep"}


-- These allow water to be emptied, by getting the depth of the ground beneath the water.
local waterDepths = {}
waterDepths["nuclear-shallow"] = -1
waterDepths["water-shallow"] = -1
waterDepths["water-mud"] = -1
waterDepths["nuclear-crater"] = -2
waterDepths["nuclear-crater-shallow-fill"] = -2
waterDepths["water"] = -2
waterDepths["nuclear-deep"] = -3
waterDepths["nuclear-deep-shallow-fill"] = -3
waterDepths["nuclear-deep-fill"] = -3
waterDepths["deepwater"] = -3
waterDepths["nuclear-high"] = 1
--everything else is treated as 0


-- these are the heights of water given a tile, as far as nearby tiles are concerned
local waterInCraterGoingOutDepths = {}
waterInCraterGoingOutDepths["nuclear-shallow"] = -10
waterInCraterGoingOutDepths["water-shallow"] = 0
waterInCraterGoingOutDepths["water-mud"] = 0
waterInCraterGoingOutDepths["nuclear-crater"] = -10
waterInCraterGoingOutDepths["nuclear-crater-shallow-fill"] = -1
waterInCraterGoingOutDepths["water"] = 0
waterInCraterGoingOutDepths["nuclear-deep"] = -10
waterInCraterGoingOutDepths["nuclear-deep-shallow-fill"] = -2
waterInCraterGoingOutDepths["nuclear-deep-fill"] = -1
waterInCraterGoingOutDepths["deepwater"] = 0

-- these are the waters for different heights, so that we can find the water height in any given area
local waterInCraterGoingOutDepth0Only = {"deepwater", "water", "water-shallow", "water-mud"}
local waterInCraterGoingOutDepth1Only = {"nuclear-crater-shallow-fill", "nuclear-deep-fill"}
local waterInCraterGoingOutDepth2Only = {"nuclear-deep-fill"}

-- these are the height of water given a tile, for whether that tile will be filled with water
local waterInCraterGoingInDepths = {}
waterInCraterGoingInDepths["nuclear-shallow"] = -1
waterInCraterGoingInDepths["water-shallow"] = 0
waterInCraterGoingInDepths["water-mud"] = 0
waterInCraterGoingInDepths["nuclear-crater"] = -2
waterInCraterGoingInDepths["nuclear-crater-shallow-fill"] = -1
waterInCraterGoingInDepths["water"] = 0
waterInCraterGoingInDepths["nuclear-deep"] = -3
waterInCraterGoingInDepths["nuclear-deep-shallow-fill"] = -2
waterInCraterGoingInDepths["nuclear-deep-fill"] = -1
waterInCraterGoingInDepths["deepwater"] = 0

-- these allow empty crater to be created from a height
local depthsForCrater = {}
depthsForCrater[-3] = "nuclear-deep"
depthsForCrater[-2] = "nuclear-crater"
depthsForCrater[-1] = "nuclear-shallow"
depthsForCrater[0] = "nuclear-ground"
depthsForCrater[1] = "nuclear-high"

-- These allow water to fill craters intelligently
local depthsForCraterWater = {}
depthsForCraterWater[-3] = {}
depthsForCraterWater[-3][-3] = "nuclear-deep"
depthsForCraterWater[-3][-2] = "nuclear-deep-shallow-fill"
depthsForCraterWater[-3][-1] = "nuclear-deep-fill"
depthsForCraterWater[-3][0] = "deepwater"
depthsForCraterWater[-2] = {}
depthsForCraterWater[-2][-2] = "nuclear-crater"
depthsForCraterWater[-2][-1] = "nuclear-crater-shallow-fill"
depthsForCraterWater[-2][0] = "water"
depthsForCraterWater[-1] = {}
depthsForCraterWater[-1][-1] = "nuclear-shallow"
depthsForCraterWater[-1][0] = "water-mud"

local function doFastCraterFilling(event) 
	-- fast crater filling
	if(global.cratersFast==nil) then
		global.cratersFast = {}
	end
	if(global.cratersFastItterationCount == nil) then
		global.cratersFastItterationCount = 0
	end
	if(global.cratersFastData == nil) then
		global.cratersFastData = {}
	end
	global.cratersFastItterationCount = global.cratersFastItterationCount + 1
	if(global.cratersFastItterationCount > 53) then
		global.cratersFastItterationCount = 1
	end
	for surface,chunks in pairs(global.cratersFast) do
		global.cratersFastData[surface].synch = global.cratersFastData[surface].synch+1
		if(global.cratersFastData[surface].synch == 5) then
			global.cratersFastData[surface].synch = 1
		end
		if(global.cratersFastItterationCount == 1) then
			global.cratersFastData[surface].xCountSoFar = 0
			global.cratersFastData[surface].xDone = {}
		end
		for x,xchunks in pairs(chunks) do
			if(global.cratersFastData[surface].xDone[x]==nil) then	--ignore all the ones we have already done
				if(global.cratersFastData[surface].xCountSoFar > global.cratersFastData[surface].xCount*global.cratersFastItterationCount/53) then
					break;
				end
				global.cratersFastData[surface].xDone[x] = 1
				global.cratersFastData[surface].xCountSoFar = global.cratersFastData[surface].xCountSoFar + 1
				for y,foundChunkH in pairs(xchunks) do
					local tileChanges = {}
					local ghostChanges = {}

					local targetTiles
					local chunkH = foundChunkH
					if(chunkH >= 0 and global.cratersFastData[surface].synch==1) then
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*10, y*10}, {x*10+10, y*10+10}}, name=craterTypes0}
					elseif(chunkH >= -1 and (global.cratersFastData[surface].synch == 3 or global.cratersFastData[surface].synch == 1)) then
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*10, y*10}, {x*10+10, y*10+10}}, name=craterTypes1}
					else
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*10, y*10}, {x*10+10, y*10+10}}, name=craterTypes2}
					end
					local hasHeightDiff = false;
					for _,t in pairs(targetTiles) do
						local heightDiff = 0;
						local currentH = waterInCraterGoingInDepths[t.name];
						chunkH = math.max(chunkH, currentH)
						local h1 = waterInCraterGoingOutDepths[game.surfaces[surface].get_tile(t.position.x, t.position.y+1).name];
						local h2 = waterInCraterGoingOutDepths[game.surfaces[surface].get_tile(t.position.x, t.position.y-1).name];
						local h3 = waterInCraterGoingOutDepths[game.surfaces[surface].get_tile(t.position.x+1, t.position.y).name];
						local h4 = waterInCraterGoingOutDepths[game.surfaces[surface].get_tile(t.position.x-1, t.position.y).name];
						if((not (h1 == nil)) and h1>currentH)then
							heightDiff = heightDiff+h1-currentH;
							chunkH = math.max(chunkH, h1)
						end
						if((not (h2 == nil)) and h2>currentH)then
							heightDiff = heightDiff+h2-currentH;
							chunkH = math.max(chunkH, h2)
						end
						if((not (h3 == nil)) and h3>currentH)then
							heightDiff = heightDiff+h3-currentH;
							chunkH = math.max(chunkH, h3)
						end
						if((not (h4 == nil)) and h4>currentH)then
							heightDiff = heightDiff+h4-currentH;
							chunkH = math.max(chunkH, h4)
						end
						if(heightDiff>0) then
							hasHeightDiff = true;
						end
						if(heightDiff>0 and (heightDiff>=3 or math.random()*3<heightDiff))then
							if(currentH == waterDepths[t.name]) then
								for _,f in pairs(game.surfaces[surface].find_entities_filtered{area={{t.position.x, t.position.y}, {t.position.x+1, t.position.y+1}}, type="fire"}) do
									f.destroy();
								end
							end
							chunkH = math.max(chunkH, currentH+1)
							table.insert(tileChanges, {name=depthsForCraterWater[waterDepths[t.name] ][currentH+1], position = t.position})
							for _,tileGhost in pairs(game.surfaces[surface].find_entities_filtered{position = {t.position.x+0.5, t.position.y+0.5}, name = "tile-ghost"}) do
								table.insert(ghostChanges, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = {t.position.x+0.5, t.position.y+0.5}})
							end
							if(t.position.x == x*10) then
								if(chunks[x-1]==nil) then
									chunks[x-1] = {};
									global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount + 1
								end
								if(chunks[x-1][y]==nil) then
									chunks[x-1][y] = currentH+1
								else
									chunks[x-1][y] = math.max(currentH+1, chunks[x-1][y])
								end
							elseif(t.position.x == x*10+9) then
								if(chunks[x+1]==nil) then
									chunks[x+1] = {};
									global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount + 1
								end
								if(chunks[x+1][y]==nil) then
									chunks[x+1][y] = currentH+1
								else
									chunks[x+1][y] = math.max(currentH+1, chunks[x+1][y]);
								end
							end
							if(t.position.y == y*10) then
								if(xchunks[y-1]==nil) then
									xchunks[y-1] = currentH+1
								else
									xchunks[y-1] = math.max(currentH+1, xchunks[y-1]);
								end
							elseif(t.position.y == y*10+9) then
								if(xchunks[y+1]==nil) then
									xchunks[y+1] = currentH+1
								else
									xchunks[y+1] = math.max(currentH+1, xchunks[y+1]);
								end
							end
						end
					end
					game.surfaces[surface].set_tiles(tileChanges)
					for _,ghost in pairs(ghostChanges) do
						game.surfaces[surface].create_entity{name="tile-ghost",position=ghost.pos,inner_name=ghost.ghost_name,force=ghost.force}
					end
					xchunks[y] = chunkH; -- just to set the height back to being correct, in case it has changed (e.g. a new, higher water level has been found)
					if global.cratersFastData[surface].synch==1 and not hasHeightDiff then
						xchunks[y] = nil
						if next(xchunks) == nil then
							global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount-1
							chunks[x] = nil
						end
						if next(chunks) == nil then
							global.cratersFast[surface] = nil
							global.cratersFastData[surface] = nil
						end
					end
				end
			end
		end
	end
end

local function moveBlast(i,blast,pastEHits)
	-- Compute the number of regions we move the blast in
	local regNum = 8
	if(blast.r<=500 or not blast.doItts) then
		regNum = 8
	elseif(blast.r<=2000) then
		regNum = 24
	elseif(blast.r<=4000) then
		regNum = 48
	else
		regNum = 96
	end
	-- Do we need to wait a while (we might need to if the simulated blast is going faster than expected) 
	blast.ittframe = blast.ittframe+1
	if(blast.itt > regNum and blast.ittframe >=8) then
		blast.r = blast.r + blast.speed
		blast.ittframe = 1
		blast.itt = 1
	elseif (blast.itt > regNum) then
		return
	end

	local surface = game.surfaces[blast["s"] ]
	local center = blast["pos"]
	local sideOffset = blast.speed*1.5
	local extraSpace = blast.speed
	
	local eHits = pastEHits
	
	local area = {{}, {}}

	-- Some hard-coded regions for small blasts
	local regions = {{{center.x-blast.r/2-sideOffset, center.y+(blast.r-extraSpace)*0.86603-0.5}, {center.x+blast.r/2+sideOffset, center.y+blast.r+1}}, 
		 		 {{center.x-blast.r/2-sideOffset, center.y-blast.r}, {center.x+blast.r/2+sideOffset, center.y-(blast.r-extraSpace)*0.86603+0.5}}, 
				 {{center.x+(blast.r-extraSpace)*0.86603-0.5, center.y-blast.r/2-sideOffset}, {center.x+blast.r+1, center.y+blast.r/2+sideOffset}}, 
				 {{center.x-blast.r, center.y-blast.r/2-sideOffset}, {center.x-(blast.r-extraSpace)*0.86603+0.5, center.y+blast.r/2+sideOffset}}, 

				 {{center.x-(blast.r-extraSpace)*0.86603-0.5, center.y+blast.r/2-extraSpace/2-0.5}, {center.x-blast.r/2+extraSpace/2+0.5, center.y+(blast.r-extraSpace)*0.86603+0.5}}, 
				 {{center.x+blast.r/2-extraSpace/2-0.5, center.y+blast.r/2-extraSpace/2-0.5}, {center.x+(blast.r-extraSpace)*0.86603+0.5, center.y+(blast.r-extraSpace)*0.86603+0.5}}, 
				 {{center.x-(blast.r-extraSpace)*0.86603-0.5, center.y-(blast.r-extraSpace)*0.86603-0.5}, {center.x-blast.r/2+extraSpace/2+0.5, center.y-blast.r/2+extraSpace/2+0.5}}, 
				 {{center.x+blast.r/2-extraSpace/2-0.5, center.y-(blast.r-extraSpace)*0.86603-0.5}, {center.x+(blast.r-extraSpace)*0.86603+0.5, center.y-blast.r/2+extraSpace/2+0.5}}}

	if(blast.r<=500 or not blast.doItts) then
		area = regions[blast.itt]
	else
		-- otherwise compute the regions for large area blast-waves
		local reg = blast.itt % (regNum/4)
		local currentQuadrant = (math.floor(blast.itt/(regNum/4)))%4
		local angleUnit = 2*3.14159/regNum
		local angleRelative = math.min(angleUnit*(reg+1), angleUnit*(regNum/4-reg-1))
		local angleStart = angleUnit*((regNum/4)*currentQuadrant+reg)
		local overstep = math.sqrt( (blast.r*math.sin(angleRelative))^2+2*blast.r*blast.speed+blast.speed*blast.speed)-blast.r*math.sin(angleRelative)+2;

		

		if(currentQuadrant==0) then
			if(reg<regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart)}, 
						{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)+overstep}}
			elseif(reg==regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}, 
							{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
			else
				area = {{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}, 
						{center.x + (blast.r-blast.speed)*math.cos(angleStart)+overstep, center.y + (blast.r)*math.sin(angleStart+angleUnit)}}
			end
		elseif(currentQuadrant==1) then
			if(reg<regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit)-overstep, center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}, 
						{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r)*math.sin(angleStart)}}
			elseif(reg==regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}, 
						{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
			else
				area = {{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart+angleUnit)}, 
						{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)+overstep}}
			end
		elseif(currentQuadrant==2) then
			if(reg<regNum/8) then
				area = {{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)-overstep}, 
						{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart)}}
			elseif(reg==regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}, 
							{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
			else
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart)-overstep, center.y + (blast.r)*math.sin(angleStart+angleUnit)}, 
						{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart)}}
			end
		else
			if(reg<regNum/8) then
				area = {{center.x + (blast.r)*math.cos(angleStart), center.y + (blast.r)*math.sin(angleStart)}, 
						{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit)+overstep, center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
			elseif(reg==regNum/8) then
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)}, 
							{center.x + (blast.r-blast.speed)*math.cos(angleStart+angleUnit), center.y + (blast.r-blast.speed)*math.sin(angleStart+angleUnit)}}
			else
				area = {{center.x + (blast.r-blast.speed)*math.cos(angleStart), center.y + (blast.r-blast.speed)*math.sin(angleStart)-overstep}, 
						{center.x + (blast.r)*math.cos(angleStart+angleUnit), center.y + (blast.r)*math.sin(angleStart+angleUnit)}}
			end
		end
	end

	local entities = surface.find_entities(area)
	eHits = eHits + #entities
	--game.players[1].print(math.floor(blast.itt/6) .. " {" .. area[1][1] .. ", " .. area[1][2] .. "}, {" .. area[2][1] .. ", " .. area[2][2] .. "}")
	for _,entity in pairs(entities) do
		-- do blast damage - reduced for rails, belts, land mines and flying vehicles, as this makes some sense, and trees in order to leave some alive
		if (entity.valid and entity.position) then
			local xdif = entity.position.x-center.x
			local ydif = entity.position.y-center.y
			local distSq = xdif*xdif + ydif*ydif
			if((not (entity.prototype.max_health == 0)) and distSq > (blast.r - blast.speed)*(blast.r - blast.speed) and distSq <= blast["r"]*blast["r"]) then 
				local dist = math.sqrt(xdif*xdif + ydif*ydif)
				local damage = blast.pow/distSq*blast.damage_init+blast.blast_min_damage
				local t = entity.type
				if(t=="curved-rail") then
					damage = damage/10
				elseif (t=="straight-rail") then
					damage = damage/10
				elseif (t=="transport-belt") then
					damage = damage/10
				elseif (t=="land-mine") then
					damage = damage/10
				elseif(t=="car" or t=="spider-vehicle") then
					if (next(entity.prototype.collision_mask)==nil)then
						damage = damage/5
					end
				end
				if(t=="tree") then
					if(blast.fire) then
						surface.create_entity{name="fire-flame-on-tree",position=entity.position, initial_ground_flame_count=255}
					end
					damage = math.random(damage/10, damage)
				else
					damage = math.random(damage/2, damage*2)
				end
				if(t=="tree") then
					-- If a tree is destroyed, don't bother boing particle effects, just destroy it - huge performance savings
					if((((not entity.prototype.resistances) or not entity.prototype.resistances.fire) and entity.health<damage) or (entity.prototype.resistances and entity.prototype.resistances.fire and entity.health<(damage-entity.prototype.resistances.explosion.decrease)*(1-entity.prototype.resistances.explosion.percent))) then
						local destPos = entity.position
						entity.destroy()
						surface.create_entity{name="tree-01-stump",position=destPos}
					else
						if(cause and cause.valid) then
							entity.damage(damage, blast.force,"explosion", blast.cause)
						else
							entity.damage(damage, blast.force,"explosion")
						end
					end
				else
					if(cause and cause.valid) then
						entity.damage(damage, blast.force, "explosion", blast.cause)
					else
						entity.damage(damage, blast.force, "explosion")
					end
				end
				-- For thermobarics, with the blast wave carrying the fire
				if blast.fire and entity.valid and (entity.type == "unit" or entity.type == "car" or entity.type == "spider-vehicle") then
					local fireShield = nil
					if entity.grid then
						for _,e in pairs(entity.grid.equipment) do
							if(e.name=="fire-shield-equipment" and e.energy>=500000) then
								fireShield = e;
								break;
							end	
						end
					end
					if fireShield then
						fireShield.energy = fireShield.energy-500000
					else
						surface.create_entity{name="fire-sticker", position=entity.position, target=entity}
					end
					if(cause and cause.valid) then
						entity.damage(20, blast.force, "fire", blast.cause)
						if(entity.valid)then
							entity.damage(40, blast.force, "physical", blast.cause)
						end
						if(entity.valid and entity.type == "car" and (entity.prototype.max_health >= 1000 or fireShield)) then
							entity.damage(80, blast.force, "fire", blast.cause)
						end
					else
						entity.damage(20, blast.force, "fire")
						if(entity.valid)then
							entity.damage(40, blast.force, "physical")
						end
						if(entity.valid and entity.type == "car" and (entity.prototype.max_health >= 1000 or fireShield)) then
							entity.damage(80, blast.force, "fire")
						end
					end
				elseif blast.fire and entity.valid and (not (entity.type == "tree")) then
					if(cause and cause.valid) then
						entity.damage(100, blast.force, "fire", blast.cause)
					else
						entity.damage(100, blast.force, "fire")
					end
				end
			end
		end
	end

	-- For thermobarics, start all the required fires
	if(blast.fire) then
		local area = regions[blast.itt]
		local tiles = surface.find_tiles_filtered{area=area}
		for _,tile in pairs(tiles) do
			local xdif = tile.position.x-center.x
			local ydif = tile.position.y-center.y
			local distSq = xdif*xdif + ydif*ydif
			if(distSq > (blast["r"] - blast.speed)*(blast["r"] - blast.speed) and distSq <= blast["r"]*blast["r"]) then 
				if (blast.fire_rad >= blast.r) then 
					local chance = math.random(0, blast.fire_rad)
					if(chance*chance>distSq) then
						surface.create_entity{name="fire-flame",position=tile.position}
					else
						surface.create_entity{name="thermobaric-wave-fire",position=tile.position}
					end
				else
					local chanceWave = math.random(blast.fire_rad, blast.max)
					if(chanceWave*chanceWave>distSq) then
						surface.create_entity{name="thermobaric-wave-fire",position=tile.position}
					end
				end
			end
		end
	end
	-- We want to do more regions this frame if the ones we have covered contain very few entities (such as it they are unloaded)
	if (blast.ittframe>=8) then
		if(blast.itt == regNum) then
			blast.r = blast.r + blast.speed
			blast.itt = 1
		else 
			blast.itt = blast.itt+1
			if(not blast.doItts or eHits<4000) then
				moveBlast(i, blast,eHits)
			end
		end
	end
	if(blast.r>blast.max) then
		table.remove(global.blastWaves, i)
	end
end

local function nukeBuildingDetonate(building)
	-- A nuke building just launches an artillery shell at itself, much easier than an entire seperate detonation system
	if(building.get_recipe().name == "megaton-detonation") then
		building.surface.create_entity{name="TN-really-huge-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "100kiloton-detonation") then
		building.surface.create_entity{name="TN-very-big-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "15kiloton-detonation") then
		building.surface.create_entity{name="TN-big-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	end
	building.get_output_inventory().clear();
	building.destroy();
end

local function tickHandler(event)
	everyTick(event)
	if(global.blastWaves ==nil) then
		global.blastWaves = {}
	end
	if(global.nukeBuildings ==nil) then
		global.nukeBuildings = {}
	end
	if(#global.blastWaves>0) then
		for i,blast in ipairs(global.blastWaves) do
			moveBlast(i,blast,0)
		end
	end
	doFastCraterFilling(event)
	if(#global.nukeBuildings>0) then
		for i,building in ipairs(global.nukeBuildings) do
			if(building.valid) then
				if(not building.get_output_inventory().is_empty()) then
					nukeBuildingDetonate(building)
				elseif (building.crafting_progress > 0 and building.crafting_progress < 0.01) then
					-- Force map loading when a nuke is set up
					if(building.get_recipe().name == "megaton-detonation") then
	 					building.surface.request_to_generate_chunks(building.position, 3200/32)
					elseif(building.get_recipe().name == "100kiloton-detonation") then
	 					building.surface.request_to_generate_chunks(building.position, 2000/32)
					elseif(building.get_recipe().name == "15kiloton-detonation") then
	 					building.surface.request_to_generate_chunks(building.position, 1500/32)
					end
				end
			else
				table.remove(global.nukeBuildings, i)
			end
		end
	end
end
script.on_event(defines.events.on_tick, tickHandler);

local function setupCratersToFill(position, outerRadius, innerRadius)
	




end

local function circularNoise(tableTarget, position, radius, depthMult, sliceCount)
	if (settings.global["nuke-crater-noise"].value) then
		for num=0,sliceCount do
			local slice_w = (math.floor(radius*depthMult/50)+1)
			for ang=0,math.ceil(3.1416*2*radius*slice_w*4/(num*num+1)) do
				local dist = math.floor(num*slice_w+slice_w*math.random())
				local offset = math.random()

				noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.sin(ang+offset)+0.5), y = math.floor(position.y+(dist+radius-1)*math.cos(ang+offset)+0.5)}
				if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius*radius) then
					--Do nothing - used to remove rounding errors and prevent hitting the same tile twice
				else
					if(tableTarget[noise_pos.x]==nil) then
						tableTarget[noise_pos.x] = {}
					end
					tableTarget[noise_pos.x][noise_pos.y] = 1;
				end
			end
		end
	end
end

local function tileNoise(surface, tableTarget, position, radius, depthMult, tileMap, sliceCount)
	if (settings.global["nuke-crater-noise"].value) then
		for num=0,sliceCount do
			local slice_w = (math.floor(radius*depthMult/50)+1)
			for ang=0,math.ceil(3.1416*2*radius*slice_w*4/(num*num+1)) do
				local dist = math.floor(math.random(num*slice_w, slice_w+num*slice_w))
				local offset = math.random()

				noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.sin(ang+offset)+0.5), y = math.floor(position.y+(dist+radius-1)*math.cos(ang+offset)+0.5)}
				cur_tile = surface.get_tile(noise_pos)
				if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius+0.5) then
					--Do nothing - used to remove rounding errors and prevent hitting the same tile twice
				elseif (tileMap[cur_tile.name] == nil) then
					if(not(tileMap["default"] ==nil)) then
						table.insert(tableTarget, {name = tileMap["default"], position = noise_pos})
					end
				else
					table.insert(tableTarget, {name = tileMap[cur_tile.name], position = noise_pos})
				end
			end
		end
	end
end

local function nukeTileChangesHeightAwareHuge(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
	local buildingForces = {}
	local tileGhosts = {}
	local hasBuildings = false

	local tileTable = {}

	-- find interested forces
	for _,ghost in pairs(game.surfaces[surface_index].find_entities_filtered{position = position, radius = crater_external_r*1.1+4, name = "entity-ghost"}) do
		buildingForces[ghost.force] = 1
		hasBuildings = true
	end
	--fireball boils water...
	for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name=waterTypes}) do
		local cur_tile = game.surfaces[surface_index].get_tile(v.position)
		if(waterDepths[cur_tile.name]) then
			table.insert(tileTable, {name = depthsForCrater[waterDepths[cur_tile.name] ], position = v.position})
			for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {v.position.x+0.5, v.position.y+0.5}, name = "tile-ghost"}) do
				table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
			end
		end
	end
	local groundNoise = {}
	circularNoise(groundNoise, position, fireball_r, 1, 3)
	for x,xtiles in pairs(groundNoise) do
		for y,_ in pairs(xtiles) do
			if not(waterDepths[game.surfaces[surface_index].get_tile(x, y).name] == nil) then
				table.insert(tileTable, {name = depthsForCrater[waterDepths[game.surfaces[surface_index].get_tile(x, y).name] ], position = {x = x, y = y}})
				for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {x = x+0.5, y = y+0.5}, name = "tile-ghost"}) do
					table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
				end
			end
		end
	end
	-- make the crater
	for x = math.floor(-crater_external_r+0.5), math.floor(crater_external_r+0.5) do
		for y = math.floor(-crater_external_r+0.5), math.floor(crater_external_r+0.5) do
			local tilepos = {position.x + x, position.y + y}
			local distSq = x*x+y*y
			if(distSq<crater_internal_r*crater_internal_r/9) then
				table.insert(tileTable, {name = depthsForCrater[-3], position = tilepos})
			elseif(distSq<crater_internal_r*crater_internal_r*4/9) then
				table.insert(tileTable, {name = depthsForCrater[-2], position = tilepos})
			elseif(distSq<crater_internal_r*crater_internal_r) then
				table.insert(tileTable, {name = depthsForCrater[-1], position = tilepos})
			elseif(distSq<crater_external_r*crater_external_r) then
				table.insert(tileTable, {name = depthsForCrater[1], position = tilepos})
			end
		end
	end
	-- add noise
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r/3, 1, {default = depthsForCrater[-3]}, 3);
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r*2/3, 1, {default = depthsForCrater[-2]}, 3);
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r, 2, {default = depthsForCrater[0]}, 3);
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r, 1, {default = depthsForCrater[-1]}, 3);
	game.surfaces[surface_index].set_tiles(tileTable)
	-- ensure noise for crater goes on top of lakes
	local tileTable2 = {}
	--noise around the crater
	local externalNoise = {default = "nuclear-ground"}
	tileNoise(game.surfaces[surface_index], tileTable2, position, crater_external_r, 1, externalNoise, 3);

	--high noise around crater
	local externalNoise2 = {default = "nuclear-high"}
	tileNoise(game.surfaces[surface_index], tileTable2, position, crater_external_r-2, 1, externalNoise2, 3);
	game.surfaces[surface_index].set_tiles(tileTable2)

	--make the high ground removable
	for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name="nuclear-high"}) do
		game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
	end

	-- re-add tile ghosts, and create them for the interested forces (and deconstruct high nuclear ground for those forces)
	for _,t in pairs(tileGhosts) do
		game.surfaces[surface_index].create_entity{name="tile-ghost", position=t.pos, inner_name=t.ghost_name, force=t.force}
	end 
	if(hasBuildings) then
		for _,tile in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r*1.1+4, name=waterAndCraterTypes}) do
			for f,_ in pairs(buildingForces) do
				if (game.surfaces[surface_index].count_entities_filtered{position={tile.position.x+0.5, tile.position.y+0.5}, force = f, name="tile-ghost"} == 0) then
					game.surfaces[surface_index].create_entity{name="tile-ghost", position={tile.position.x+0.5, tile.position.y+0.5}, inner_name="landfill", force=f}
				end
			end
		end
		for _,tile in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r*1.1+4, name="nuclear-high"}) do
			for f,_ in pairs(buildingForces) do
				tile.order_deconstruction(f);
			end
		end
	end

	-- setup craters to fill with water
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/10-1),math.floor((position.x+fireball_r*1.1)/10+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/10-1),math.floor((position.y+fireball_r*1.1)/10+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterTypes, limit = 1} == 0)) and 
				(not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = craterTypes0, limit = 1} == 0)) then
				local height = -2;
				if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = 0;
				elseif (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = -1;
				end
				-- have both water and crater
				if(global.cratersFast[surface_index]==nil)then
					global.cratersFast[surface_index] = {}
					global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
				end
				if(global.cratersFast[surface_index][xChunkPos]==nil)then
					global.cratersFast[surface_index][xChunkPos] = {}
					global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
				end
				global.cratersFast[surface_index][xChunkPos][yChunkPos] = height
			end
		end
	end
	-- slow filling - no checks required, all the chunks get this anyway
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/32-1),math.floor((position.x+fireball_r*1.1)/32+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/32-1),math.floor((position.y+fireball_r*1.1)/32+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*32, yChunkPos*32}, {xChunkPos*32+32, yChunkPos*32+32}}, name = craterTypes0, limit = 1} == 0)) then
				table.insert(global.cratersSlow, {t = 0, x = xChunkPos, y = yChunkPos, surface = surface_index});
			end
		end
	end
end


local function nukeTileChangesHeightAware(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
	local buildingForces = {}
	local tileGhosts = {}
	local hasBuildings = false

	local tileTable = {}
	local noiseTables = {}
	if (crater_internal_r<5) then
		noiseTables[1] = {}
		--no extra noise needed
	elseif (crater_internal_r<10) then
		noiseTables[1] = {}
		noiseTables[2] = {}
		circularNoise(noiseTables[2], position, crater_internal_r, 1/2, 3)
		circularNoise(noiseTables[1], position, crater_external_r, 1/2, 3)
	elseif (crater_internal_r<20) then
		noiseTables[1] = {}
		noiseTables[2] = {}
		noiseTables[3] = {}
		noiseTables[4] = {}
		circularNoise(noiseTables[4], position, crater_internal_r/2, 1/2, 3)
		circularNoise(noiseTables[3], position, crater_internal_r, 1/2, 3)
		circularNoise(noiseTables[2], position, crater_internal_r, 1, 3)
		circularNoise(noiseTables[1], position, crater_external_r, 1/2, 3)
	else
		local noiseLevel = 1/2;
		if(crater_internal_r>50)then
			noiseLevel = 1;
		end
		noiseTables[1] = {}
		noiseTables[2] = {}
		noiseTables[3] = {}
		noiseTables[4] = {}
		noiseTables[5] = {}
		noiseTables[6] = {}
		noiseTables[7] = {}
		circularNoise(noiseTables[7], position, crater_internal_r/3, noiseLevel, 3)
		circularNoise(noiseTables[6], position, crater_internal_r*2/3, noiseLevel, 3)
		circularNoise(noiseTables[5], position, crater_internal_r, noiseLevel, 3)
		circularNoise(noiseTables[4], position, crater_internal_r, noiseLevel*2, 3)
		circularNoise(noiseTables[3], position, crater_external_r*1/3+crater_internal_r*2/3, noiseLevel, 3)
		circularNoise(noiseTables[2], position, crater_external_r*2/3+crater_internal_r*1/3, noiseLevel, 3)
		circularNoise(noiseTables[1], position, crater_external_r-1, noiseLevel, 3)
	end
	-- find interested forces
	for _,ghost in pairs(game.surfaces[surface_index].find_entities_filtered{position = position, radius = crater_external_r*1.1+4, name = "entity-ghost"}) do
		buildingForces[ghost.force] = 1
		hasBuildings = true
	end
	-- do the noise around the craters
	if (crater_external_r>8) then
		local externalNoise = {default = "nuclear-ground"}
		for tile,h in pairs(waterDepths) do
			externalNoise[tile] = depthsForCrater[h];
		end
		tileNoise(game.surfaces[surface_index], tileTable, position, crater_external_r, 1, externalNoise, 3);
	end
	if(crater_internal_r==0) then
		for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = position, radius = crater_external_r+1, name = "tile-ghost"}) do
			table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
		end
	end
	for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5}) do
		local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
		local cur_tile = game.surfaces[surface_index].get_tile(v.position)
		if(distSq>crater_external_r*crater_external_r and (noiseTables[1][v.position.x]==nil or noiseTables[1][v.position.x][v.position.y]==nil)) then
			if(waterDepths[cur_tile.name]) then
				table.insert(tileTable, {name = depthsForCrater[waterDepths[cur_tile.name] ], position = v.position})
				for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {v.position.x+0.5, v.position.y+0.5}, name = "tile-ghost"}) do
					table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
				end
			end
		else
			local curr_height = waterDepths[cur_tile.name]
			if(curr_height==nil) then
				curr_height = 0;
			end
			if (crater_internal_r<5) then
				if(distSq<=crater_internal_r*crater_internal_r) then
					curr_height = math.min(curr_height, -1)
				end
			elseif (crater_internal_r<10) then
				if(distSq<=crater_internal_r*crater_internal_r) then
					curr_height = math.min(curr_height, -1)
				elseif (noiseTables[2][cur_tile.position.x]==nil or noiseTables[2][cur_tile.position.x][cur_tile.position.y]==nil)then
					-- any tile not hit by the noise does this, otherwise we leave it
					curr_height = curr_height+1;
				end
			elseif (crater_internal_r<20) then
				if(distSq<=crater_internal_r*crater_internal_r/4) then
					curr_height = math.min(curr_height, -2)
				elseif(distSq<=crater_internal_r*crater_internal_r) then
					if (noiseTables[4][cur_tile.position.x]==nil or noiseTables[4][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					else
						curr_height = math.min(curr_height, -2)
					end
				elseif not (noiseTables[3][cur_tile.position.x]==nil or noiseTables[3][cur_tile.position.x][cur_tile.position.y]==nil)then
					curr_height = math.min(curr_height, -1)
				elseif (noiseTables[2][cur_tile.position.x]==nil or noiseTables[2][cur_tile.position.x][cur_tile.position.y]==nil)then
					curr_height = curr_height+1;
				end
			else
				if(distSq<=crater_internal_r*crater_internal_r/9) then
					curr_height = math.min(curr_height, -3)
				elseif(distSq<=crater_internal_r*crater_internal_r*4/9) then
					if  (noiseTables[7][cur_tile.position.x]==nil or noiseTables[7][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = math.min(curr_height, -2)
					else
						curr_height = math.min(curr_height, -3)
					end
				elseif(distSq<=crater_internal_r*crater_internal_r) then
					if  (noiseTables[6][cur_tile.position.x]==nil or noiseTables[6][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					else
						curr_height = math.min(curr_height, -2)
					end
				elseif(distSq<=(crater_external_r*1/3+crater_internal_r*2/3)*(crater_external_r*1/3+crater_internal_r*2/3)) then
					if  not (noiseTables[5][cur_tile.position.x]==nil or noiseTables[5][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					elseif  (noiseTables[4][cur_tile.position.x]==nil or noiseTables[4][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = curr_height+1;
					end
				elseif(distSq<=(crater_external_r*2/3+crater_internal_r*1/3)*(crater_external_r*2/3+crater_internal_r*1/3)) then
					if  (noiseTables[3][cur_tile.position.x]==nil or noiseTables[3][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = curr_height+2;
					else
						curr_height = curr_height+1;
					end
				else
					if  (noiseTables[2][cur_tile.position.x]==nil or noiseTables[2][cur_tile.position.x][cur_tile.position.y]==nil)then
						curr_height = curr_height+1;
					else
						curr_height = curr_height+2;
					end
				end
			end
			if(curr_height > 1) then
				table.insert(tileTable, {name = "nuclear-high", position = v.position})
			else
				table.insert(tileTable, {name = depthsForCrater[curr_height], position = v.position})
			end
		end
	end

	if (fireball_r>8) then
		local groundNoise = {}
		circularNoise(groundNoise, position, fireball_r, 1, 3)
		for x,xtiles in pairs(groundNoise) do
			for y,_ in pairs(xtiles) do
				if not(waterDepths[game.surfaces[surface_index].get_tile(x, y).name] == nil) then
					table.insert(tileTable, {name = depthsForCrater[waterDepths[game.surfaces[surface_index].get_tile(x, y).name] ], position = {x = x, y = y}})
					for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {x = x+0.5, y = y+0.5}, name = "tile-ghost"}) do
						table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
					end
				end
			end
		end
	end

	game.surfaces[surface_index].set_tiles(tileTable)
	--make the high ground removable
	for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fireball_r+0.5, name="nuclear-high"}) do
		game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
	end
	-- re-add tile ghosts, and create them for the interested forces (and deconstruct high nuclear ground for those forces)
	for _,t in pairs(tileGhosts) do
		game.surfaces[surface_index].create_entity{name="tile-ghost", position=t.pos, inner_name=t.ghost_name, force=t.force}
	end 
	if(hasBuildings) then
		for _,tile in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r*1.1+4, name=waterAndCraterTypes}) do
			for f,_ in pairs(buildingForces) do
				if (game.surfaces[surface_index].count_entities_filtered{position={tile.position.x+0.5, tile.position.y+0.5}, force = f, name="tile-ghost"} == 0) then
					game.surfaces[surface_index].create_entity{name="tile-ghost", position={tile.position.x+0.5, tile.position.y+0.5}, inner_name="landfill", force=f}
				end
			end
		end
		for _,tile in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r*1.1+4, name="nuclear-high"}) do
			for f,_ in pairs(buildingForces) do
				tile.order_deconstruction(f);
			end
		end
	end

	-- setup craters to fill with water
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/10-1),math.floor((position.x+fireball_r*1.1)/10+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/10-1),math.floor((position.y+fireball_r*1.1)/10+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterTypes, limit = 1} == 0)) and 
				(not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = craterTypes0, limit = 1} == 0)) then
				local height = -2;
				if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = 0;
				elseif (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*10, yChunkPos*10}, {xChunkPos*10+10, yChunkPos*10+10}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = -1;
				end
				-- have both water and crater
				if(global.cratersFast[surface_index]==nil)then
					global.cratersFast[surface_index] = {}
					global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
				end
				if(global.cratersFast[surface_index][xChunkPos]==nil)then
					global.cratersFast[surface_index][xChunkPos] = {}
					global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
				end
				global.cratersFast[surface_index][xChunkPos][yChunkPos] = height
			end
		end
	end
	if(not global.cratersSlow) then
		global.cratersSlow = {}
	end
	-- slow filling - no checks required, all the chunks get this anyway
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/32-1),math.floor((position.x+fireball_r*1.1)/32+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/32-1),math.floor((position.y+fireball_r*1.1)/32+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*32, yChunkPos*32}, {xChunkPos*32+32, yChunkPos*32+32}}, name = craterTypes0, limit = 1} == 0)) then
				table.insert(global.cratersSlow, {t = 0, x = xChunkPos, y = yChunkPos, surface = surface_index});
			end
		end
	end
end

local function nukeTileChanges(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
	local tileTable = {}

	local is_waterfilled = crater_external_r<=8
	if (check_craters) then
		local edge_water_count = 0
		local edge_water_threshold = 0.1 -- Threshold of proportion of crater edge touching water for crater to fill with water

		for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r}) do
			local cur_tile = game.surfaces[surface_index].get_tile(v.position)
			if math.sqrt((cur_tile.position.x - position.x) ^ 2 + (cur_tile.position.y - position.y) ^ 2) > crater_external_r - 1 then
				if cur_tile.name == "water" or cur_tile.name == "deepwater" then
					edge_water_count = edge_water_count + 1
				end
			end
		end

		if edge_water_count / (2 * math.pi * crater_external_r) > edge_water_threshold then
			is_waterfilled = true
		end

		-- mandelbrodt - Moved from above to check if crater is next to water before appending to waitingNukeCratersBasic
		if crater_internal_r>0 and settings.global["crater-water-filling"].value and not is_waterfilled then
			table.insert(global.waitingNukeCratersBasic, {t = 0, pos = position, d = crater_internal_r, s = surface_index})
		end
	end
	if ((not check_craters) or not is_waterfilled) then
		for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r}) do
			table.insert(tileTable, {name = "nuclear-ground", position = v.position})
		end
	else
		-- mandelbrodt - If crater touches (non-shallow/mud) water, fill crater with "water" tiles
		for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r}) do
			local cur_tile = game.surfaces[surface_index].get_tile(v.position)
			if not (cur_tile.name == "water" or cur_tile.name == "deepwater") then
				if((v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y) <= crater_internal_r*crater_internal_r) then
					table.insert(tileTable, {name = "water", position = v.position})
				else
					table.insert(tileTable, {name = "nuclear-ground", position = v.position})
				end
			end
		end
	end

	-- do the noise around the craters
	if (crater_external_r>8) then
		tileNoise(game.surfaces[surface_index], tileTable, position, crater_external_r, 1, {default="nuclear-ground", water="water", deepwater="deepwater"}, 3);
	end

	 game.surfaces[surface_index].set_tiles(tileTable)
end




local function atomic_weapon_hit(event, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
	 -- find forces, positions, etc.
	 local force
	 local position = event.target_position
	 if(not position) then
	 	position = event.source_position
	 end
	 if(settings.global["nukes-cause-pollution"].value) then
	 	game.surfaces[event.surface_index].pollute(position, polution)
	 end
	 if(not (event.source_entity==nil)) then
	 	force = event.source_entity.force
	 else
		force = "enemy"
	 end
	 local cause = event.source_entity;
	 if(global.waitingNukeCratersBasic ==nil) then
		global.waitingNukeCratersBasic = {}
	 end

	 -- force the map to generate (should be reasonably quick as it is pre-loaded)
	 game.surfaces[event.surface_index].request_to_generate_chunks(position, load_r/32)
	 game.surfaces[event.surface_index].force_generate_chunk_requests()

	 for _,f in pairs(game.forces) do
		f.chart(game.surfaces[event.surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
	 end
	 -- kill things in the fireball
	 for _,v in pairs(game.surfaces[event.surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
		if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
			if v.type=="tree" then
				v.destroy()
			elseif cause and cause.valid then
				if not v.die(force, cause) then
					v.destroy()
				end
			elseif not v.die(nil) then
				v.destroy()
			end
		end
	 end
	 if(settings.global["destroy-resources-in-crater"].value) then
		 -- destroy resources in crater (a bit more to account for the noise on crater edge)
		 for _,v in pairs(game.surfaces[event.surface_index].find_entities_filtered{position=position, radius=crater_external_r*1.1+4, type="resource"}) do
			if(v.valid) then
				v.destroy()
			end
		 end
	 end
	 -- destroy decoratives in the fireball
	 for _,v in pairs(game.surfaces[event.surface_index].find_decoratives_filtered{area = {{position.x-fireball_r, position.y-fireball_r}, {position.x+fireball_r, position.y+fireball_r}}}) do
		if((v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)<=fireball_r*fireball_r) then
			game.surfaces[event.surface_index].destroy_decoratives{position = v.position};
		end
	 end
	 -- make sure everything is dead in the fireball
	 for _,v in pairs(game.surfaces[event.surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
		if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
			if(cause and cause.valid) then
				v.die(force, cause);
			else
				v.die(nil);
			end
			if(v.valid) then
				v.destroy();
			end
		end
	 end
	 if(settings.global["use-height-for-craters"].value and settings.startup["enable-new-craters"].value) then
		if(crater_external_r>200) then --use efficient crater generator (ignores height for lakes)
			nukeTileChangesHeightAwareHuge(position, check_craters, event.surface_index, crater_internal_r, crater_external_r, fireball_r)
		else
		 	nukeTileChangesHeightAware(position, check_craters, event.surface_index, crater_internal_r, crater_external_r, fireball_r)
	 	end
	 else
	 	nukeTileChanges(position, check_craters, event.surface_index, crater_internal_r, crater_external_r, fireball_r)
	 end
	 -- light fires as nessesary
	 if(flame_proportion>0) then
		 for _,v in pairs(game.surfaces[event.surface_index].find_tiles_filtered{position=position, radius=fire_outer_r}) do
			local rand = math.random(0, fire_outer_r)
			if(math.random(0, flame_proportion)<1 and rand*rand>(v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)) then 
				if((not(waterInCraterGoingOutDepths[v.name] == nil)) and waterInCraterGoingOutDepths[v.name] > -10) then
					game.surfaces[event.surface_index].create_entity{name="thermobaric-wave-fire",position=v.position}
				else
					game.surfaces[event.surface_index].create_entity{name="nuclear-fire",position=v.position}
				end
			end
		 end
	 end
	 if (settings.global["nuke-random-fires"].value and create_small_fires) then
		for i=0,(tree_fire_max_r*tree_fire_max_r/10) do
			local dist = math.random(0, math.random(0, tree_fire_max_r))
			local angle = math.random()*3.1416*2
			game.surfaces[event.surface_index].create_entity{name="thermobaric-wave-fire",position={position.x+dist*math.cos(angle), position.y+dist*math.sin(angle)}}
		end
	 end
	 -- do thermal heat-wave damage
	 for _,v in pairs(game.surfaces[event.surface_index].find_entities_filtered{position=position, radius=thermal_max_r}) do
		if(v.valid and not (v.prototype.max_health == 0)) then
			local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
			if(distSq>fireball_r) then
				local damage = thermal_max_r*thermal_max_r/distSq*10	
				if(v.type=="tree") then
	 				-- efficient tree handling
					if(math.random(0, 100)<1) then
						game.surfaces[event.surface_index].create_entity{name="fire-flame-on-tree",position=v.position, initial_ground_flame_count=1+math.min(254,thermal_max_r*thermal_max_r/distSq)}
					end
					local damage = math.random(damage/10, damage)
					if((((not v.prototype.resistances) or not v.prototype.resistances.fire) and v.health<damage) or (v.prototype.resistances and v.prototype.resistances.fire and v.health<(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent))) then
						local surface = v.surface
						local destPos = v.position
						v.destroy()
						surface.create_entity{name="tree-01-stump",position=destPos}
					else
						if(cause and cause.valid) then
							v.damage(damage, force, "fire", cause)
						else
							v.damage(damage, force, "fire")
						end
					end
				else
					if(cause and cause.valid) then
						v.damage(math.random(damage/2, damage*2), force, "fire", cause)
					else
						v.damage(math.random(damage/2, damage*2), force, "fire")
					end
					if(v.valid and (v.type == "unit" or v.type == "car" or v.type == "spider-vehicle")) then
						local fireShield = nil
						if v.grid then
							for _,e in pairs(v.grid.equipment) do
								if(e.name=="fire-shield-equipment" and e.energy>=1000000) then
									fireShield = e;
									break;
								end	
							end
						end
						if fireShield then
							fireShield.energy = fireShield.energy-1000000
						else
							game.surfaces[event.surface_index].create_entity{name="fire-sticker", position=v.position, target=v}
						end
					end
				end
			end
		end
	 end
	 table.insert(global.blastWaves, {r = fireball_r, pos = position, pow = fireball_r*fireball_r, max = blast_max_r, s = event.surface_index, fire = false, damage_init = 5000.0, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause})
end

local function thermobaric_weapon_hit(event, explosion_r, blast_max_r, fire_r, load_r, visable_r)
	 local force
	 local cause = event.source_entity;
	 local position = event.target_position
	 if(not (event.source_entity==nil)) then
	 	force = event.source_entity.force
	 else
		force = "enemy"
	 end
	 game.surfaces[event.surface_index].request_to_generate_chunks(position, load_r/32)
	 game.surfaces[event.surface_index].force_generate_chunk_requests()

	 for _,f in pairs(game.forces) do
		f.chart(game.surfaces[event.surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
	 end
	 for _,v in pairs(game.surfaces[event.surface_index].find_tiles_filtered{position=position, radius=explosion_r}) do
		game.surfaces[event.surface_index].create_entity{name="fire-flame",position=v.position}
	 end
	 table.insert(global.blastWaves, {r = explosion_r, pos = position, pow = explosion_r*explosion_r, max = blast_max_r, s = event.surface_index, fire = true, damage_init = 600.0, speed = 1, fire_rad = fire_r, blast_min_damage = 30, itt = 1, doItts = false, ittframe = 1, force = force, cause = cause})
end



local function nukeFiredScan(event)
	local entity;
	if(event.entity) then
	 	entity = event.entity
	elseif(event.source_entity) then
	 	entity = event.source_entity
	end
	if (entity) then
		local position = event.target_entity.position 
		if(entity.prototype.name == "TN-very-big-atomic-artillery-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 2000/32)
		elseif(entity.prototype.name == "TN-big-atomic-artillery-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 1500/32)
		elseif(entity.prototype.name == "TN-atomic-artillery-projectile" or entity.prototype.name == "big-atomic-bomb-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 800/32)
		elseif(entity.prototype.name == "TN-small-atomic-artillery-projectile" or entity.prototype.name == "very-big-atomic-bomb-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 400/32)
		end
	end
end

 -- calculate polution as 1*tonnage + 1000*uranium input + 100*californium input + 10000*tritium input
--local function atomic_weapon_hit(event, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters)
script.on_event(defines.events.on_script_trigger_effect, function(event)
  if(event.effect_id=="Thermobaric Weapon hit small-") then
	 thermobaric_weapon_hit(event, 1, 15, 10, 10, 10);
  elseif(event.effect_id=="Thermobaric Weapon hit small") then
	 thermobaric_weapon_hit(event, 3, 30, 20, 30, 15);
  elseif(event.effect_id=="Thermobaric Weapon hit small+") then
	 thermobaric_weapon_hit(event, 4, 45, 30, 45, 25);
  elseif(event.effect_id=="Thermobaric Weapon hit medium-") then
	 thermobaric_weapon_hit(event, 5, 60, 40, 60, 35);
  elseif(event.effect_id=="Thermobaric Weapon hit medium") then
	 thermobaric_weapon_hit(event, 6, 80, 50, 80, 50);
  elseif(event.effect_id=="Thermobaric Weapon hit large") then
	 thermobaric_weapon_hit(event, 9, 120, 100, 120, 100);
  elseif(event.effect_id=="Atomic Weapon hit 0.1t") then
	 atomic_weapon_hit(event, 0, 1, 1, 3, 30, 15, 30, 15, 15, 300.1, 1, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 60, 100, 200, 700, 10, 0.06);
  elseif(event.effect_id=="Atomic Weapon hit 0.5t") then
	 atomic_weapon_hit(event, 0, 3, 3, 5, 50, 25, 30, 30, 20, 700.5, 1, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 80, 150, 300, 1000, 20, 0.12);
  elseif(event.effect_id=="Atomic Weapon hit 2t") then
	 atomic_weapon_hit(event, 0, 5, 5, 15, 80, 50, 100, 100, 50, 1302, 2, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 100, 250, 500, 2000, 40, 0.25);
  elseif(event.effect_id=="Atomic Weapon hit 4t") then
	 atomic_weapon_hit(event, 1, 6, 7, 20, 130, 120, 150, 180, 80, 4004, 1, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 120, 300, 900, 4000, 70, 0.4);
  elseif(event.effect_id=="Atomic Weapon hit 8t") then
	 atomic_weapon_hit(event, 3, 8, 14, 25, 200, 200, 200, 180, 100, 9008, 1, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 150, 400, 1250, 10000, 100, 0.6);
  elseif(event.effect_id=="Atomic Weapon hit 20t") then
	 atomic_weapon_hit(event, 5, 10, 20, 30, 320, 320, 320, 180, 150, 30020, 1, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 250, 600, 1800, 15000, 160, 1);
  elseif(event.effect_id=="Atomic Weapon hit 500t") then
	 atomic_weapon_hit(event, 10, 20, 40, 35, 400, 400, 600, 400, 300, 75500, 1*settings.global["large-nuke-fire-scaledown"].value, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 400, 800, 2500, 25000, 300, 2);
  elseif(event.effect_id=="Atomic Weapon hit 1kt") then
	 atomic_weapon_hit(event, 20, 40, 80, 75, 800, 800, 1200, 800, 300, 101000, 2*settings.global["large-nuke-fire-scaledown"].value, true, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 600, 1200, 8000, 60000, 600, 4);
  elseif(event.effect_id=="Atomic Weapon hit 15kt") then
	 atomic_weapon_hit(event, 50, 100, 200, 150, 2000/settings.global["large-nuke-blast-range-scaledown"].value, 1000, 4000, 1000, 500, 315000, settings.global["huge-nuke-fire-scaledown"].value, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 1500, 3000, 20000, 100000, 1500, 8);
  elseif(event.effect_id=="Atomic Weapon hit 100kt") then
	 atomic_weapon_hit(event, 90, 180, 500, 400, 5500/settings.global["really-huge-nuke-blast-range-scaledown"].value, 2500, 9000, 1500, 1000, 450000, 2*settings.global["really-huge-nuke-fire-scaledown"].value, false, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 2700, 5400, 36000, 200000, 2700, 16);
  elseif(event.effect_id=="Atomic Weapon hit 1Mt") then
	 atomic_weapon_hit(event, 190, 390, 1200, 1000, 12000/settings.global["mega-nuke-blast-range-scaledown"].value, 5000, 10000, 3200, 2500, 1800000, 0, false, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 6000, 10000, 60000, 400000, 5000, 32);
  elseif(event.effect_id=="Nuke firing") then
	 nukeFiredScan(event);
  elseif(event.effect_id=="Mega-nuke built") then
	 table.insert(global.nukeBuildings, event.source_entity)
  end

end)



script.on_nth_tick(1207, function(event)
	-- slow crater filling
	if(global.cratersSlow == nil) then
		global.cratersSlow = {}
	end
	for index,chunk in pairs(global.cratersSlow) do
		chunk.t = chunk.t+1;
		if(chunk.t>30) then
			local target = nil
			if (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes2, limit = 1} == 0)) then
				local prob = 128;
				if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/8
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
					prob = prob/4
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/2
				end
				prob = prob - math.floor((chunk.t-30)/3)
				if(math.random(1, math.max(prob,2)) == 1) then
					local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes2}
					target = targets[math.random(1, #targets)]
				end
			elseif (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes1, limit = 1} == 0)) then
				local prob = 512;
				if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/32
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
					prob = prob/16
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/2
				end
				prob = prob - math.floor((chunk.t-30)/3)
				if(math.random(1, math.max(prob,2)) == 1) then
					local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes1}
					target = targets[math.random(1, #targets)]
				end
			elseif (not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes0, limit = 1} == 0)) then
				local prob = 2048;
				if(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/32
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth1Only, limit = 1} == 0)) then
					prob = prob/4
				elseif(not (game.surfaces[chunk.surface].count_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					prob = prob/2
				end
				prob = prob - math.floor((chunk.t-30)/3)
				if math.random(1, math.max(prob,2)) == 1 then
					local targets = game.surfaces[chunk.surface].find_tiles_filtered{area={{chunk.x*32, chunk.y*32}, {chunk.x*32+32, chunk.y*32+32}}, name = craterTypes0}
					target = targets[math.random(1, #targets)]
				end
			else
				global.cratersSlow[index] = nil
			end
			if not (target==nil) then
				local h = waterInCraterGoingInDepths[target.name]+1
				local pos = target.position;

				-- ensure we preserve ghosts, e.g. landfill
				local tileGhosts = {}
				for _,t in pairs(game.surfaces[chunk.surface].find_entities_filtered{position = {pos.x+0.5, pos.y+0.5}, name = "tile-ghost"}) do
					table.insert(tileGhosts, {ghost_name = t.ghost_name, force = t.force})
				end
				game.surfaces[chunk.surface].set_tiles({{name = depthsForCraterWater[waterDepths[target.name] ][h], position = pos}});
				for _,t in pairs(tileGhosts) do
					game.surfaces[chunk.surface].create_entity{name="tile-ghost",position={pos.x+0.5, pos.y+0.5},inner_name=t.ghost_name,force=t.force}
				end

				if(global.cratersFast[chunk.surface]==nil)then
					global.cratersFast[chunk.surface] = {}
					global.cratersFastData[chunk.surface] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
				end
				local xChunkPos = math.floor(pos.x/10)
				if(global.cratersFast[chunk.surface][xChunkPos]==nil)then
					global.cratersFast[chunk.surface][xChunkPos] = {}
					global.cratersFastData[chunk.surface].xCount = global.cratersFastData[chunk.surface].xCount + 1
				end
				if(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/10)] == nil) then
					global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/10)] = h
				else
					global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/10)] = math.max(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/10)], h)
				end
			end
		end
	end
	
end)

script.on_nth_tick(3601, function(event)
	-- handling crater filling for non-height aware craters
	if(global.waitingNukeCratersBasic ==nil) then
		global.waitingNukeCratersBasic = {}
	end
	if(#global.waitingNukeCratersBasic>0) then
		for _,v in pairs(global.waitingNukeCratersBasic) do
			if(v["t"]>5+v["d"]) then
				local force = nil
				for _,w in pairs(game.surfaces[v["s"] ].find_entities_filtered{position=v["pos"], radius=v["t"]-4}) do
					if(string.match(w.type, "ghost") or w.prototype.is_building) then
						force = w.force
						break
					end
				end
				if(not (force==nil)) then
					for j,w in ipairs(game.surfaces[v["s"] ].find_tiles_filtered{position=v["pos"], radius=v["t"]-3}) do
						game.surfaces[v["s"] ].create_entity{name="tile-ghost",position=w.position,inner_name="landfill",force=force}
					end
				end
				table.remove(global.waitingNukeCratersBasic, i)
			else 
				v["t"] = v["t"]+1
				if(v["t"]>5) then
					 for _,w in pairs(game.surfaces[v["s"] ].find_entities_filtered{position=v["pos"], radius=v["t"]-3}) do
						if(w.prototype.is_building) then
							w.die(nil)
						end
					 end
					 local tileTable = {}
					 for _,w in pairs(game.surfaces[v["s"] ].find_tiles_filtered{position=v["pos"], radius=v["t"]-4}) do
						if((w.position["x"]-v["pos"]["x"])*(w.position["x"]-v["pos"]["x"])+(w.position["y"]-v["pos"]["y"])*(w.position["y"]-v["pos"]["y"])>=(math.max(v["t"]-10, 0))*(v["t"]-10)) then
							table.insert(tileTable, {name = "water-shallow", position = w.position})
						end
					 end
					 game.surfaces[v["s"] ].set_tiles(tileTable, true, false)
				end
			end
		end
	end
end)
  ]]















