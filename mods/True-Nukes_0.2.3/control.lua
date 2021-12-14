local mushroomFunctions = require("MushroomCloudInBuilt.control")
local createBlastSoundsAndFlash = mushroomFunctions[1]
script.on_init(function()
	global.waitingNukeCratersBasic = {}		-- a simple array of the craters, {t = the number minutes it has been waiting for, pos = centre of crater, d = diameter too fill, s = surface index}
	global.thermalBlasts = {}				-- a simple array, with elements: {surface_index, position, force, thermal_max_r, initialDamage, fireball_r, x, y}, each as a key of the map
	global.blastWaves = {}					-- a simple array, with elements:
	--{r = currrent explosion radius, pos = centre position, pow = initial blast multiplier (usually initial r*r)
	-- , max = maximum radius, s = surface index, fire = leave fires (true for thermobarics, false for nukes), damage_init = starting damage, speed = how far to jump every round, fire_rad = the radius to which the fire wave is solid
	-- , blast_min_damage = amount of extra damage to add all the time, itt = the number of itterations done, doItts = whether to time slice the blast, ittframe = keeps track of frame count for time slicing
	-- , force = force of the cause of the explosion - allows allocating kills correctly, cause = allows allocating kills to the originator})

	global.nukeBuildings = {} 				-- array of the LuaEntities for any nukeBuildings
	global.optimisedNukes = {} 				-- has keys: 
	    --position, surface_index, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, check_craters
	    --used for doing chunk-by-chunk loading of detonation results

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
local waterInCraterGoingOutDepth2Only = {"nuclear-deep-shallow-fill"}

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

local corpseMap = {}
corpseMap["biter-spawner"] = "biter-spawner-corpse"
corpseMap["spitter-spawner"] = "spitter-spawner-corpse"

corpseMap["small-biter"] = "small-biter-corpse"
corpseMap["medium-biter"] = "medium-biter-corpse"
corpseMap["big-biter"] = "big-biter-corpse"
corpseMap["behemoth-biter"] = "behemoth-biter-corpse"

corpseMap["small-spitter"] = "small-spitter-corpse"
corpseMap["medium-spitter"] = "medium-spitter-corpse"
corpseMap["big-spitter"] = "big-spitter-corpse"
corpseMap["behemoth-spitter"] = "behemoth-spitter-corpse"

corpseMap["small-worm-turret"] = "small-worm-corpse"
corpseMap["medium-worm-turret"] = "medium-worm-corpse"
corpseMap["big-worm-turret"] = "big-worm-corpse"
corpseMap["behemoth-worm-turret"] = "behemoth-worm-corpse"

local decorativeMap = {}
decorativeMap["brown-asterisk"] = {"rock-tiny", 1/4}
decorativeMap["green-asterisk"] = {"brown-asterisk", 1/4}
decorativeMap["green-asterisk-mini"] = {"brown-asterisk", 1/10}
decorativeMap["brown-asterisk-mini"] = {"brown-asterisk", 1/20}
decorativeMap["red-asterisk"] = {"brown-asterisk", 1/4}

decorativeMap["green-pita"] = {"rock-tiny", 1/10}
decorativeMap["red-pita"] = {"rock-small", 1/10}
decorativeMap["green-croton"] = {"sand-rock-small", 1/10}
decorativeMap["red-croton"] = {"red-desert-decal", 1/10}
decorativeMap["green-pita-mini"] = {"enemy-decal-transparent", 1/20}

decorativeMap["brown-fluff"] = {"rock-tiny", 1/10}
decorativeMap["brown-fluff-dry"] = {"brown-asterisk", 1/10}
decorativeMap["garballo"] = {"brown-fluff", 1/10}
decorativeMap["garballo-mini-dry"] = {"brown-fluff-dry", 1/10}

decorativeMap["green-bush-mini"] = {"brown-fluff", 1/10}
decorativeMap["green-hairy-grass"] = {"brown-hairy-grass", 1/10}
decorativeMap["muddy-stump"] = nil

decorativeMap["green-carpet-grass"] = {"sand-decal", 1/2}

decorativeMap["green-desert-bush"] = {"red-desert-bush", 1/2}
decorativeMap["white-desert-bush"] = {"white-desert-bush", 1/4}

decorativeMap["red-desert-bush"] = {"red-desert-bush", 1/2}
decorativeMap["green-small-grass"] = {"brown-asterisk", 1/10}
decorativeMap["brown-carpet-grass"] = {"brown-carpet-grass", 1/2}
decorativeMap["brown-hairy-grass"] = {"brown-hairy-grass", 1/2}

decorativeMap["rock-medium"] = {}
decorativeMap["rock-small"] = {}
decorativeMap["rock-tiny"] = {}
decorativeMap["sand-rock-medium"] = {}
decorativeMap["sand-rock-small"] = {}

decorativeMap["red-desert-decal"] = {}
decorativeMap["dark-mud-decal"] = {}
decorativeMap["puberty-decal"] = {}
decorativeMap["light-mud-decal"] = {}
decorativeMap["sand-decal"] = {}

decorativeMap["sand-dune-decal"] = {}
decorativeMap["big-ship-wreck-grass"] = nil
decorativeMap["small-ship-wreck-grass"] = nil

decorativeMap["enemy-decal"] = {}
decorativeMap["enemy-decal-transparent"] = {}

decorativeMap["nuclear-ground-patch"] = {}
decorativeMap["shroom-decal"] = nil
decorativeMap["worms-decal"] = nil
decorativeMap["lichen-decal"] = nil



	 
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
				local count = 0;
				for y,foundChunkH in pairs(xchunks) do	
					local tileChanges = {}
					local ghostChanges = {}

					local targetTiles
					local chunkH = foundChunkH					
					
					if(chunkH >= 0 and global.cratersFastData[surface].synch==1) then
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes0}
					elseif(chunkH >= -1 and (global.cratersFastData[surface].synch == 3 or global.cratersFastData[surface].synch == 1)) then
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes1}
					else
						targetTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8, y*8}, {x*8+8, y*8+8}}, name=craterTypes2}
					end
					if(#targetTiles>0) then
						count = count+1;
						local relevantTiles = game.surfaces[surface].find_tiles_filtered{area={{x*8-1, y*8-1}, {x*8+9, y*8+9}}, name=waterTypes}
						
						local tileH = {}
						local existsChunks = {};
						if(existsChunks[math.floor(x/4)] == nil) then
							existsChunks[math.floor(x/4)] = {}
						end
						existsChunks[math.floor(x/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor(y/4)});
						existsChunks[math.floor(x/4)][math.floor((y+1)/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor((y+1)/4)});
						existsChunks[math.floor(x/4)][math.floor((y-1)/4)] = game.surfaces[surface].is_chunk_generated({math.floor(x/4), math.floor((y-1)/4)});
						
						if(existsChunks[math.floor((x-1)/4)] == nil) then
							existsChunks[math.floor((x-1)/4)] = {}
						end
						existsChunks[math.floor((x-1)/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor((x-1)/4), math.floor(y/4)});
						
						if(existsChunks[math.floor((x+1)/4)] == nil) then
							existsChunks[math.floor((x+1)/4)] = {}
						end
						existsChunks[math.floor((x+1)/4)][math.floor(y/4)] = game.surfaces[surface].is_chunk_generated({math.floor((x+1)/4), math.floor(y/4)});
						
						
						
						for _,t in pairs(relevantTiles) do
							if(tileH[t.position.x] == nil) then
								tileH[t.position.x] = {}
							end
							if(existsChunks[math.floor(t.position.x/32)][math.floor(t.position.y/32)]) then
								tileH[t.position.x][t.position.y] = waterInCraterGoingOutDepths[t.name];
							end 
						end
						local hasHeightDiff = false;
						for _,t in pairs(targetTiles) do
							local heightDiff = 0;
							local currentH = waterInCraterGoingInDepths[t.name];
							chunkH = math.max(chunkH, currentH)
							local h1
							local h2
							if(tileH[t.position.x] ~=nil) then
								h1 = tileH[t.position.x][t.position.y+1];
								h2 = tileH[t.position.x][t.position.y-1];
							end
							
							local h3
							if(tileH[t.position.x+1] ~=nil) then
								h3 = tileH[t.position.x+1][t.position.y];
							end
							local h4
							if(tileH[t.position.x-1] ~=nil) then
								h4 = tileH[t.position.x-1][t.position.y];
							end
							
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
								table.insert(tileChanges, {name=depthsForCraterWater[waterDepths[t.name]][currentH+1], position = t.position})
								for _,tileGhost in pairs(game.surfaces[surface].find_entities_filtered{position = {t.position.x+0.5, t.position.y+0.5}, name = "tile-ghost"}) do
									table.insert(ghostChanges, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = {t.position.x+0.5, t.position.y+0.5}})
								end
								if(t.position.x == x*8) then
									if(chunks[x-1]==nil) then
										chunks[x-1] = {};
										global.cratersFastData[surface].xCount = global.cratersFastData[surface].xCount + 1
									end
									if(chunks[x-1][y]==nil) then
										chunks[x-1][y] = currentH+1
									else
										chunks[x-1][y] = math.max(currentH+1, chunks[x-1][y])
									end
								elseif(t.position.x == x*8+7) then
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
								if(t.position.y == y*8) then
									if(xchunks[y-1]==nil) then
										xchunks[y-1] = currentH+1
									else
										xchunks[y-1] = math.max(currentH+1, xchunks[y-1]);
									end
								elseif(t.position.y == y*8+7) then
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
					elseif(global.cratersFastData[surface].synch ~= 1) then
						count = count+1;
					else
						xchunks[y] = nil;
					end
				end
				if (count==0) then
					chunks[x] = nil;
				end
			end
		end
	end
end

local function moveBlast(i,blast,pastEHits)

	local efficientDamage = settings.global["use-efficient-thermal"].value
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

	local surface = game.surfaces[blast["s"]]
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
	local blastInnerSq = (blast.r - blast.speed)*(blast.r - blast.speed)
	local blastSq = blast["r"]*blast["r"]
	for _,entity in pairs(entities) do
		-- do blast damage - reduced for rails, belts, land mines and flying vehicles, as this makes some sense, and trees in order to leave some alive
		if (entity.valid and entity.position) then
			local xdif = entity.position.x-center.x
			local ydif = entity.position.y-center.y
			local distSq = xdif*xdif + ydif*ydif
			if((not (entity.prototype.max_health == 0)) and distSq > blastInnerSq and distSq <= blastSq) then 
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

					if(entity.prototype.resistances and entity.prototype.resistances.explosion) then
						damage = (damage-entity.prototype.resistances.explosion.decrease)*(1-entity.prototype.resistances.explosion.percent)
					end
					-- If a tree is destroyed, don't bother doing particle effects, just destroy it - huge performance savings
					if(entity.health<damage) then
						local destPos = entity.position
						entity.destroy()
						surface.create_entity{name="tree-01-stump",position=destPos}
					else
						entity.health = entity.health-damage
					end
				else
					damage = math.random(damage/2, damage*2)
					local calcDamage = damage;
					if(efficientDamage and entity.prototype.resistances and entity.prototype.resistances.explosion) then
						calcDamage = (calcDamage-entity.prototype.resistances.explosion.decrease)*(1-entity.prototype.resistances.explosion.percent)
					end
					if((not entity.grid) and efficientDamage and entity.health>calcDamage) then
						entity.health = entity.health-calcDamage
					else
						if(cause and cause.valid) then
							entity.damage(damage, blast.force, "explosion", blast.cause)
						else
							entity.damage(damage, blast.force, "explosion")
						end
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

local function atomic_thermal_blast_internal(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, initial_x, initial_y)
	 -- do thermal heat-wave damage
	 local thermSq = thermal_max_r*thermal_max_r;
	 local areas = {}
	 local y = -1;
	 local x = -1;
	 if(thermal_max_r<500) then
	 	areas = {{{position.x-thermal_max_r, position.y-thermal_max_r}, {position.x+thermal_max_r, position.y+thermal_max_r}}}
	 else
	 	local i = 0;
	 	y = initial_y;
 		x = initial_x;
	 	while(y+100<=position.y+thermal_max_r) do
	 		initial_x = position.x-thermal_max_r;
	 		while(x+100<=position.x +thermal_max_r) do
				local distSq1 = (x-position.x)*(x-position.x)        +(y-position.y)*(y-position.y)
				local distSq2 = (x+100-position.x)*(x+100-position.x)+(y-position.y)*(y-position.y)
				local distSq3 = (x-position.x)*(x-position.x)        +(y+100-position.y)*(y+100-position.y)
				local distSq4 = (x+100-position.x)*(x+100-position.x)+(y+100-position.y)*(y+100-position.y)
				if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
	 				i = i+1;
 					table.insert(areas, {{x, y}, {x+100, y+100}});
 				end
	 			x = x+100
	 		end
	 		if(x ~= position.x +thermal_max_r) then
				if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
	 				i = i+1;
					table.insert(areas, {{x, y}, {position.x +thermal_max_r, y+100}});
				end
 			end
			y = y+100
 			x = initial_x;
			if(i>=100) then
				break;
			end
	 	end
 		if(i<100 and y ~= position.y +thermal_max_r) then
	 		while(x+100<=position.x +thermal_max_r) do
				if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
					table.insert(areas, {{x, y}, {x+100, position.y+thermal_max_r}});
				end
	 			x = x+100
	 		end
	 		if(x ~= position.x +thermal_max_r) then
				if(distSq1<thermSq or distSq2<thermSq or distSq3<thermSq or distSq4<thermSq) then
					table.insert(areas, {{x, y}, {position.x +thermal_max_r, position.y+thermal_max_r}});
				end
 			end
		end
	 end
	 for _,a in pairs(areas) do
		 for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{area=a}) do
			if(v.valid and not (v.prototype.max_health == 0)) then
				local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
				if(distSq>fireball_r*fireball_r and distSq<=thermSq) then
					local damage = fireball_r*fireball_r*initialDamage/distSq
					if(v.type=="tree") then
		 				-- efficient tree handling
						if(math.random(0, 100)<1) then
							game.surfaces[surface_index].create_entity{name="fire-flame-on-tree",position=v.position, initial_ground_flame_count=1+math.min(254,thermal_max_r*thermal_max_r/distSq)}
						end
						local damage = math.random(damage/10, damage)
						if((((not v.prototype.resistances) or not v.prototype.resistances.fire) and v.health<damage) or (v.prototype.resistances and v.prototype.resistances.fire and v.health<(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent))) then
							local surface = v.surface
							local destPos = v.position
							v.destroy()
							surface.create_entity{name="tree-01-stump",position=destPos}
						else
							if((not v.prototype.resistances) or not v.prototype.resistances.fire) then
								v.health = v.health-damage
							else
								v.health = v.health-(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)
							end
						end
					else
						local damage = math.random(damage/2, damage*2)
						if(v.grid) then
							if(cause and cause.valid) then
								v.damage(damage, force, "fire", cause)
							else
								v.damage(damage, force, "fire")
							end
							if(v.valid and(v.type == "unit" or v.type == "car" or v.type == "spider-vehicle")) then
								local fireShield = nil
								for _,e in pairs(v.grid.equipment) do
									if(e.name=="fire-shield-equipment" and e.energy>=1000000) then
										fireShield = e;
										break;
									end	
								end
								if fireShield then
									fireShield.energy = fireShield.energy-1000000
								else
									game.surfaces[surface_index].create_entity{name="fire-sticker", position=v.position, target=v}
								end
							end
						else
							if(((not v.prototype.resistances) or not v.prototype.resistances.fire) and v.health>damage) then
								v.health = v.health-damage
							elseif(v.prototype.resistances and v.prototype.resistances.fire and v.health>(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)) then
								v.health = v.health-(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)
							else
								if(corpseMap[v.name]) then
									local vPos = v.position
									local corpseName = corpseMap[v.name]
									v.destroy()
									game.surfaces[surface_index].create_entity{name=corpseName, position=vPos}
								else
									if(cause and cause.valid) then
										v.damage(damage, force, "fire", cause)
									else
										v.damage(damage, force, "fire")
									end
								end
							end
						end
					end
				end
			end
		 end
	 end
	 return {x = x, y = y};
end

local function nukeBuildingDetonate(building)
	-- A nuke building just launches an artillery shell at itself, much easier than an entire seperate detonation system
	if(building.get_recipe().name == "megaton-detonation") then
		building.surface.create_entity{name="TN-really-huge-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "100kiloton-detonation") then
		building.surface.create_entity{name="TN-very-big-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "15kiloton-detonation") then
		building.surface.create_entity{name="TN-big-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
		
	elseif(building.get_recipe().name == "5megaton-detonation") then
		building.surface.create_entity{name="TN-5Mt-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "10megaton-detonation") then
		building.surface.create_entity{name="TN-10Mt-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "50megaton-detonation") then
		building.surface.create_entity{name="TN-50Mt-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "100megaton-detonation") then
		building.surface.create_entity{name="TN-100Mt-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	elseif(building.get_recipe().name == "1gigaton-detonation") then
		building.surface.create_entity{name="TN-1Gt-atomic-artillery-projectile", position={building.position.x-1, building.position.y}, target=building, speed=100, max_range=1, force=building.force}
	end
	building.get_output_inventory().clear();
	building.destroy();
end

local function tickHandler(event)
	mushroomFunctions[2](event)
	if(global.blastWaves ==nil) then
		global.blastWaves = {}
	end
	if(global.nukeBuildings ==nil) then
		global.nukeBuildings = {}
	end
	if(global.thermalBlasts ==nil) then
		global.thermalBlasts = {}
	end
	if(#global.blastWaves>0) then
		for i,blast in ipairs(global.blastWaves) do
			moveBlast(i,blast,0)
		end
	end
	
	if (#global.thermalBlasts>0) then
		for i,therm in pairs(global.thermalBlasts) do
			local pos = atomic_thermal_blast_internal(therm.surface_index, therm.position, therm.force, therm.cause, therm.thermal_max_r, therm.initialDamage, therm.fireball_r, therm.x, therm.y);
			therm.x = pos.x
			therm.y = pos.y
			if((pos.x == therm.position.x+therm.thermal_max_r and pos.y == therm.position.y+therm.thermal_max_r) or (pos.x == -1 and pos.y == -1)) then
				global.thermalBlasts[i]=nil
			end
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
						if (not settings.global["optimise-1Mt"].value) then
	 						building.surface.request_to_generate_chunks(building.position, 3200/32)
	 					else
	 						building.surface.request_to_generate_chunks(building.position, 400/32)
	 					end
					elseif(building.get_recipe().name == "100kiloton-detonation") then
						if (not settings.global["optimise-100kt"].value) then
	 						building.surface.request_to_generate_chunks(building.position, 1500/32)
	 					else
	 						building.surface.request_to_generate_chunks(building.position, 200/32)
	 					end
					elseif(building.get_recipe().name == "15kiloton-detonation") then
	 					building.surface.request_to_generate_chunks(building.position, 1000/32)
					end
				end
			else
				table.remove(global.nukeBuildings, i)
			end
		end
	end
end
script.on_event(defines.events.on_tick, tickHandler);


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
		local defaultOnly = true
		for k,v in pairs (tileMap) do
			if(k~="default") then
				defaultOnly=false;
				break;
			end
		end
		for num=0,sliceCount do
			local slice_w = (math.floor(radius*depthMult/50)+1)
			for ang=0,math.ceil(3.1416*2*radius*slice_w*4/(num*num+1)) do
				local dist = math.floor(math.random(num*slice_w, slice_w+num*slice_w))
				local offset = math.random()

				local noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.sin(ang+offset)+0.5), y = math.floor(position.y+(dist+radius-1)*math.cos(ang+offset)+0.5)}
				local cur_tile = defaultOnly or surface.get_tile(noise_pos)
				if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius+0.5) then
					--Do nothing - used to remove rounding errors and prevent hitting the same tile twice
				elseif (defaultOnly or tileMap[cur_tile.name] == nil) then
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


local function tileNoiseLimited(surface, tableTarget, position, radius, depthMult, tileMap, sliceCount, lesserAngle, greaterAngle, minR, maxR, boundaryBox)
	if (settings.global["nuke-crater-noise"].value) then
		local defaultOnly = true
		for k,v in pairs (tileMap) do
			if(k~="default") then
				defaultOnly=false;
				break;
			end
		end
		local startAngle = lesserAngle
		local endAngle = greaterAngle
		local angleDiff = (endAngle-startAngle)
		if(angleDiff>5) then
			angleDiff = 6.283185307-angleDiff
			local tmp = startAngle;
			startAngle = endAngle;
			endAngle = tmp+6.283185307;
		end
		local slice_w = (math.floor(radius*depthMult/50)+1)
		for num=0,sliceCount do
			if(minR<=slice_w+num*slice_w+radius and maxR>=num*slice_w+radius-1) then
				for ang=0,math.ceil(angleDiff*radius*slice_w*4/(num*num+1)) do
					local dist = math.floor(math.random(num*slice_w, slice_w+num*slice_w))
					local offset = math.random()+sliceCount
					local angle = (ang+offset)%angleDiff+startAngle
					local noise_pos = {x = math.floor(position.x+(dist+radius-1)*math.cos(angle)+0.5), y = math.floor(position.y+(dist+radius-1)*math.sin(angle)+0.5)}
					if(boundaryBox.left_top.x<=noise_pos.x and boundaryBox.right_bottom.x>=noise_pos.x 
							and boundaryBox.left_top.y<=noise_pos.y and boundaryBox.right_bottom.y>=noise_pos.y) then
						local cur_tile = defaultOnly or surface.get_tile(noise_pos)
						if(defaultOnly or cur_tile.valid) then
							if((position.x-noise_pos.x)*(position.x-noise_pos.x)+(position.y-noise_pos.y)*(position.y-noise_pos.y)<=radius+0.5) then
								--Do nothing - used to remove rounding errors and prevent hitting the same tile twice
							elseif (defaultOnly or tileMap[cur_tile.name] == nil) then
								if(not(tileMap["default"] == nil)) then
									table.insert(tableTarget, {name = tileMap["default"], position = noise_pos})
								end
							else
								table.insert(tableTarget, {name = tileMap[cur_tile.name], position = noise_pos})
							end
						end
					end
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
		if(waterDepths[v.name]) then
			table.insert(tileTable, {name = depthsForCrater[waterDepths[v.name]], position = v.position})
			for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {v.position.x+0.5, v.position.y+0.5}, name = "tile-ghost"}) do
				table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
			end
		end
		if(#tileTable >=1000) then
			game.surfaces[surface_index].set_tiles(tileTable)
			tileTable = {};
		end
	end
	local groundNoise = {}
	circularNoise(groundNoise, position, fireball_r, 1, 3)
	for x,xtiles in pairs(groundNoise) do
		for y,_ in pairs(xtiles) do
			local tile = game.surfaces[surface_index].get_tile(x, y)
			if not(waterDepths[tile.name] == nil) then
				table.insert(tileTable, {name = depthsForCrater[waterDepths[tile.name]], position = {x = x, y = y}})
				for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {x = x+0.5, y = y+0.5}, name = "tile-ghost"}) do
					table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
				end
			end
		end
		if(#tileTable >=1000) then
			game.surfaces[surface_index].set_tiles(tileTable)
			tileTable = {};
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
			if(#tileTable >=1000) then
				game.surfaces[surface_index].set_tiles(tileTable)
				tileTable = {};
			end
		end
	end
	-- add noise
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r/3, 1, {default = depthsForCrater[-3]}, 3);
	if(#tileTable >=1000) then
		game.surfaces[surface_index].set_tiles(tileTable)
		tileTable = {};
	end
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r*2/3, 1, {default = depthsForCrater[-2]}, 3);
	if(#tileTable >=1000) then
		game.surfaces[surface_index].set_tiles(tileTable)
		tileTable = {};
	end
	tileNoise(game.surfaces[surface_index], tileTable, position, crater_internal_r, 2, {default = depthsForCrater[0]}, 3);
	if(#tileTable >=1000) then
		game.surfaces[surface_index].set_tiles(tileTable)
		tileTable = {};
	end
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
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/8-1),math.floor((position.x+fireball_r*1.1)/8+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/8-1),math.floor((position.y+fireball_r*1.1)/8+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = waterTypes, limit = 1} == 0)) and 
				(not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = craterTypes0, limit = 1} == 0)) then
				local height = -2;
				if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = 0;
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
	local entitiesFound = game.surfaces[surface_index].find_entities_filtered{position = position, radius = crater_external_r*1.1+4, limit=1}
	while(entitiesFound[1]) do
		table.insert(buildingForces, entitiesFound[1].force)
		hasBuildings = true
		entitiesFound = game.surfaces[surface_index].find_entities_filtered{position = position, radius = crater_external_r*1.1+4, limit=1, force=buildingForces, invert=true}
	end
	entitiesFound = {}
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
		if(distSq>crater_external_r*crater_external_r and (noiseTables[1][v.position.x]==nil or noiseTables[1][v.position.x][v.position.y]==nil)) then
			if(waterDepths[v.name]) then
				table.insert(tileTable, {name = depthsForCrater[waterDepths[v.name]], position = v.position})
				for _,tileGhost in pairs(game.surfaces[surface_index].find_entities_filtered{position = {v.position.x+0.5, v.position.y+0.5}, name = "tile-ghost"}) do
					table.insert(tileGhosts, {ghost_name = tileGhost.ghost_name, force = tileGhost.force, pos = tileGhost.position})
				end
			end
		else
			local curr_height = waterDepths[v.name]
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
				elseif (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
					-- any tile not hit by the noise does this, otherwise we leave it
					curr_height = curr_height+1;
				end
			elseif (crater_internal_r<20) then
				if(distSq<=crater_internal_r*crater_internal_r/4) then
					curr_height = math.min(curr_height, -2)
				elseif(distSq<=crater_internal_r*crater_internal_r) then
					if (noiseTables[4][v.position.x]==nil or noiseTables[4][v.position.x][v.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					else
						curr_height = math.min(curr_height, -2)
					end
				elseif not (noiseTables[3][v.position.x]==nil or noiseTables[3][v.position.x][v.position.y]==nil)then
					curr_height = math.min(curr_height, -1)
				elseif (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
					curr_height = curr_height+1;
				end
			else
				if(distSq<=crater_internal_r*crater_internal_r/9) then
					curr_height = math.min(curr_height, -3)
				elseif(distSq<=crater_internal_r*crater_internal_r*4/9) then
					if  (noiseTables[7][v.position.x]==nil or noiseTables[7][v.position.x][v.position.y]==nil)then
						curr_height = math.min(curr_height, -2)
					else
						curr_height = math.min(curr_height, -3)
					end
				elseif(distSq<=crater_internal_r*crater_internal_r) then
					if  (noiseTables[6][v.position.x]==nil or noiseTables[6][v.position.x][v.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					else
						curr_height = math.min(curr_height, -2)
					end
				elseif(distSq<=(crater_external_r*1/3+crater_internal_r*2/3)*(crater_external_r*1/3+crater_internal_r*2/3)) then
					if  not (noiseTables[5][v.position.x]==nil or noiseTables[5][v.position.x][v.position.y]==nil)then
						curr_height = math.min(curr_height, -1)
					elseif  (noiseTables[4][v.position.x]==nil or noiseTables[4][v.position.x][v.position.y]==nil)then
						curr_height = curr_height+1;
					end
				elseif(distSq<=(crater_external_r*2/3+crater_internal_r*1/3)*(crater_external_r*2/3+crater_internal_r*1/3)) then
					if  (noiseTables[3][v.position.x]==nil or noiseTables[3][v.position.x][v.position.y]==nil)then
						curr_height = curr_height+2;
					else
						curr_height = curr_height+1;
					end
				else
					if  (noiseTables[2][v.position.x]==nil or noiseTables[2][v.position.x][v.position.y]==nil)then
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
			if(#tileTable >=1000) then
				game.surfaces[surface_index].set_tiles(tileTable)
				tileTable = {};
			end
		end
	end

	if (fireball_r>8) then
		local groundNoise = {}
		circularNoise(groundNoise, position, fireball_r, 1, 3)
		for x,xtiles in pairs(groundNoise) do
			for y,_ in pairs(xtiles) do
				local tileDepth = waterDepths[game.surfaces[surface_index].get_tile(x, y)];
				if not(tileDepth == nil) then
					table.insert(tileTable, {name = depthsForCrater[tileDepth], position = {x = x, y = y}})
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
			for _,f in pairs(buildingForces) do
				if (game.surfaces[surface_index].count_entities_filtered{position={tile.position.x+0.5, tile.position.y+0.5}, force = f, name="tile-ghost"} == 0) then
					game.surfaces[surface_index].create_entity{name="tile-ghost", position={tile.position.x+0.5, tile.position.y+0.5}, inner_name="landfill", force=f}
				end
			end
		end
		for _,tile in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=crater_external_r*1.1+4, name="nuclear-high"}) do
			for _,f in pairs(buildingForces) do
				tile.order_deconstruction(f);
			end
		end
	end

	-- setup craters to fill with water
	for xChunkPos = math.floor((position.x-fireball_r*1.1)/8-1),math.floor((position.x+fireball_r*1.1)/8+1) do
		for yChunkPos = math.floor((position.y-fireball_r*1.1)/8-1),math.floor((position.y+fireball_r*1.1)/8+1) do
			if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = waterTypes, limit = 1} == 0)) and 
				(not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = craterTypes0, limit = 1} == 0)) then
				local height = -2;
				if (not (game.surfaces[surface_index].count_tiles_filtered{area={{xChunkPos*8, yChunkPos*8}, {xChunkPos*8+8, yChunkPos*8+8}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
					height = 0;

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
	if(not global.cratersSlow)then
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
			if math.sqrt((v.position.x - position.x) ^ 2 + (v.position.y - position.y) ^ 2) > crater_external_r - 1 then
				if v.name == "water" or v.name == "deepwater" then
					edge_water_count = edge_water_count + 1
				end
			end
			if(#tileTable >=1000) then
				game.surfaces[surface_index].set_tiles(tileTable)
				tileTable = {};
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
			if not (v.name == "water" or v.name == "deepwater") then
				if((v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y) <= crater_internal_r*crater_internal_r) then
					table.insert(tileTable, {name = "water", position = v.position})
				else
					table.insert(tileTable, {name = "nuclear-ground", position = v.position})
				end
			end
			if(#tileTable >=1000) then
				game.surfaces[surface_index].set_tiles(tileTable)
				tileTable = {};
			end
		end
	end

	-- do the noise around the craters
	if (crater_external_r>8) then
		tileNoise(game.surfaces[surface_index], tileTable, position, crater_external_r, 1, {default="nuclear-ground", water="water", deepwater="deepwater"}, 3);
	end

	 game.surfaces[surface_index].set_tiles(tileTable)
end



local function atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r)
	if not global.thermalBlasts then
		global.thermalBlasts = {}
	end
	
	local pos = atomic_thermal_blast_internal(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r, position.x-thermal_max_r, position.y-thermal_max_r);
	if((pos.x ~= position.x+thermal_max_r or pos.y ~= position.y+thermal_max_r) and (pos.x ~= -1 or pos.y ~= -1)) then
		table.insert(global.thermalBlasts, {surface_index=surface_index, position=position, force=force, cause=cause, thermal_max_r=thermal_max_r, initialDamage=initialDamage, fireball_r=fireball_r, x=pos.x, y=pos.y})
	end
end

local function old_atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, initialDamage, fireball_r)
	 -- do thermal heat-wave damage
	 
	 for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=thermal_max_r}) do
		if(v.valid and not (v.prototype.max_health == 0)) then
			local distSq = (v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)
			if(distSq>fireball_r) then
				local damage = fireball_r*fireball_r*initialDamage/distSq	
				if(v.type=="tree") then
	 				-- efficient tree handling
					if(math.random(0, 100)<1) then
						game.surfaces[surface_index].create_entity{name="fire-flame-on-tree",position=v.position, initial_ground_flame_count=1+math.min(254,thermal_max_r*thermal_max_r/distSq)}
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
							game.surfaces[surface_index].create_entity{name="fire-sticker", position=v.position, target=v}
						end
					end
				end
			end
		end
	 end
end




local function find_event_position(event)
	 local position = event.target_position
	 if(not position) then
	 	position = event.source_position
	 end
	 return position
end

--chunkLoaderStruct: surface_index, blastIndex, blastId, force, source, position, crater_internal_r, crater_external_r, fireball_r, blast_max_r, init_blast, blast_min_damage, thermal_max_r, init_thermal
local function optimisedChunkLoadHandler(chunkPosAndArea, chunkLoaderStruct, killPlanes)
	local x = chunkPosAndArea.x*32
	local y = chunkPosAndArea.y*32
	local originPos = chunkLoaderStruct.position 
	local surface_index = chunkLoaderStruct.surface_index
	local r1 = math.sqrt((x-originPos.x)*(x-originPos.x) + (y-originPos.y)*(y-originPos.y))
	local r2 = math.sqrt((x+32-originPos.x)*(x+32-originPos.x) + (y-originPos.y)*(y-originPos.y))
	local r3 = math.sqrt((x-originPos.x)*(x-originPos.x) + (y+32-originPos.y)*(y+32-originPos.y))
	local r4 = math.sqrt((x+32-originPos.x)*(x+32-originPos.x) + (y+32-originPos.y)*(y+32-originPos.y))
	local minR = math.min(r1, r2, r3, r4)
	local maxR = math.max(r1, r2, r3, r4)
	if  ((minR<chunkLoaderStruct.blast_max_r) or (minR<chunkLoaderStruct.thermal_max_r)) then
      

		
		
		local cause = chunkLoaderStruct.source;
		local force = chunkLoaderStruct.force;
		local blastR = 0
		if(global.blastWaves == nil or global.blastWaves[blastIndex] == nil or global.blastWaves[blastIndex].blastId ~= blastId) then
			blastR = -1
		else
			blastR = global.blastWaves[blastIndex].r
		end
		--fireball
		if(minR<chunkLoaderStruct.fireball_r) then
			local entities = game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area}
			local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
			for _,e in pairs(entities) do
				if(e.valid and (not (string.match(e.type, "ghost"))) and ((e.type ~= "resource") and (killPlanes or (e.type ~= "car"))) 
				    and e.position.x>=x and e.position.x<x+32 and e.position.y>=y and e.position.y<y+32 and 
					(e.position.x-originPos.x)*(e.position.x-originPos.x) + (e.position.y-originPos.y)*(e.position.y-originPos.y)<=fireballSq) then

					if e.type=="tree" then
						e.destroy()
					elseif(corpseMap[e.name]) then
						e.destroy()
					elseif(cause ~= nil and cause.valid) then
						e.die(force, cause)
					else
						e.die(force)
					end
					
					if(e.valid) then
						e.destroy();
					end
				end
			end
			entities = game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area}
			for _,e in pairs(entities) do
				if(e.valid and (not (string.match(e.type, "ghost"))) and ((e.type ~= "resource")) and (killPlanes or e.type ~= "car") 
				    and e.position.x>=x and e.position.x<x+32 and e.position.y>=y and e.position.y<y+32 and 
					(e.position.x-originPos.x)*(e.position.x-originPos.x) + (e.position.y-originPos.y)*(e.position.y-originPos.y)<=fireballSq) then
					if e.type=="tree" then
						e.destroy()
					elseif(corpseMap[e.name]) then
						e.destroy()
					elseif(cause ~= nil and cause.valid) then
						e.die(force, cause)
					else
						e.die(force)
					end
					
					if(e.valid) then
						e.destroy();
					end
				end
			end
			-- destroy decoratives in the fireball
			local craterEdgeSq = (chunkLoaderStruct.crater_external_r*1.1+4)*(chunkLoaderStruct.crater_external_r*1.1+4)
			for _,v in pairs(game.surfaces[surface_index].find_decoratives_filtered{area = chunkPosAndArea.area}) do
				local distSq = (v.position.x-originPos.x)*(v.position.x-originPos.x)+(v.position.y-originPos.y)*(v.position.y-originPos.y);
				if(distSq<=fireballSq) then
					local tmpPos = v.position;
					local result = decorativeMap[v.decorative.name]
					if(result == nil or distSq<craterEdgeSq) then
						game.surfaces[surface_index].destroy_decoratives{position = v.position};
					elseif(result[1] == v.decorative.name) then
						local rnd = math.random();
						if(rnd<=result[2]) then
							game.surfaces[surface_index].destroy_decoratives{position = v.position};
						end
					elseif(result[1] ~=nil) then
						local rnd = math.random();
						game.surfaces[surface_index].destroy_decoratives{position = v.position};
						if(rnd<=result[2]) then
							game.surfaces[surface_index].create_decoratives{decoratives={{name=result[1], position=tmpPos, amount=1}}}
						end
					end
				end
			end
		end
		
		-- thermal
		if(minR<chunkLoaderStruct.thermal_max_r) then
			local thermSq = chunkLoaderStruct.thermal_max_r*chunkLoaderStruct.thermal_max_r;
			local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
			
			for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{area=chunkPosAndArea.area}) do
				if(v.valid and (not (v.prototype.max_health == 0)) and (killPlanes or v.type ~= "car")) then
					local distSq = (v.position.x-originPos.x)*(v.position.x-originPos.x)+(v.position.y-originPos.y)*(v.position.y-originPos.y)
					if(distSq>fireballSq and distSq<=thermSq and v.position.x>=x and v.position.x<x+32 and v.position.y>=y and v.position.y<y+32) then
						local damage = fireballSq*chunkLoaderStruct.init_thermal/distSq
						if(v.type=="tree") then
							if(math.random(0, 100)<1) then
								game.surfaces[surface_index].create_entity{name="fire-flame-on-tree",position=v.position, initial_ground_flame_count=1+math.min(254,thermSq/distSq)}
							end
							-- efficient tree handling
							damage = math.random(damage/10, damage)
							if((((not v.prototype.resistances) or not v.prototype.resistances.fire) and v.health<damage) or (v.prototype.resistances and v.prototype.resistances.fire and v.health<(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent))) then
								local surface = v.surface
								local destPos = v.position
								v.destroy()
								surface.create_entity{name="tree-01-stump",position=destPos}
							else
								if((not v.prototype.resistances) or not v.prototype.resistances.fire) then
									v.health = v.health-damage
								else
									v.health = v.health-(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)
								end
							end
						else
							damage = math.random(damage/2, damage*2)
							if(v.grid) then
								if(cause and cause.valid) then
									v.damage(damage, force, "fire", cause)
								else
									v.damage(damage, force, "fire")
								end
								if(v.valid and(v.type == "unit" or v.type == "car" or v.type == "spider-vehicle")) then
									local fireShield = nil
									for _,e in pairs(v.grid.equipment) do
										if(e.name=="fire-shield-equipment" and e.energy>=1000000) then
											fireShield = e;
											break;
										end	
									end
									if fireShield then
										fireShield.energy = fireShield.energy-1000000
									else
										game.surfaces[surface_index].create_entity{name="fire-sticker", position=v.position, target=v}
									end
								end
							else
								if(((not v.prototype.resistances) or not v.prototype.resistances.fire) and v.health>damage) then
									v.health = v.health-damage
								elseif(v.prototype.resistances and v.prototype.resistances.fire and v.health>(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)) then
									v.health = v.health-(damage-v.prototype.resistances.fire.decrease)*(1-v.prototype.resistances.fire.percent)
								else
									if(corpseMap[v.name]) then
										local vPos = v.position
										local corpseName = corpseMap[v.name]
										v.destroy()
										game.surfaces[surface_index].create_entity{name=corpseName, position=vPos}
									else
										if(cause and cause.valid) then
											v.damage(damage, force, "fire", cause)
										else
											v.damage(damage, force, "fire")
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		-- blast
		if(minR<chunkLoaderStruct.blast_max_r) then
			local blastSq = blastR*blastR
		    if(blastR == -1) then
		    	blastSq = math.max(r1*r1, r2*r2, r3*r3, r4*r4)+1
		    end
			local efficientDamage = settings.global["use-efficient-thermal"].value
			local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
			for _,entity in pairs(game.surfaces[surface_index].find_entities_filtered{area=chunkPosAndArea.area}) do
				-- do blast damage - reduced for rails, belts, land mines and flying vehicles, as this makes some sense, and trees in order to leave some alive
				if (entity.valid and entity.position and entity.position.x>=x and entity.position.x<x+32 and entity.position.y>=y and entity.position.y<y+32 and (killPlanes or entity.type ~= "car")) then
					local xdif = entity.position.x-originPos.x
					local ydif = entity.position.y-originPos.y
					local distSq = xdif*xdif + ydif*ydif
					if((not (entity.prototype.max_health == 0)) and distSq <= blastSq and distSq>=fireballSq) then 
						local dist = math.sqrt(xdif*xdif + ydif*ydif)
						local damage = fireballSq / distSq*chunkLoaderStruct.init_blast + chunkLoaderStruct.blast_min_damage
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
							damage = math.random(damage/10, damage)
							if(entity.prototype.resistances and entity.prototype.resistances.explosion) then
								damage = (damage-entity.prototype.resistances.explosion.decrease)*(1-entity.prototype.resistances.explosion.percent)
							end
							-- If a tree is destroyed, don't bother doing particle effects, just destroy it - huge performance savings
							if(entity.health<damage) then
								local destPos = entity.position
								entity.destroy()
								game.surfaces[surface_index].create_entity{name="tree-01-stump",position=destPos}
							else
								entity.health = entity.health-damage
							end
						else
							damage = math.random(damage/2, damage*2)
							local calcDamage = damage;
							if(entity.prototype.resistances and entity.prototype.resistances.explosion) then
								calcDamage = (calcDamage-entity.prototype.resistances.explosion.decrease)*(1-entity.prototype.resistances.explosion.percent)
							end
							if(efficientDamage and (not entity.grid) and entity.health>calcDamage) then
								entity.health = entity.health-calcDamage
							else
								if((not entity.grid) and corpseMap[entity.name]) then
									local entityPos = entity.position
									local corpseName = corpseMap[entity.name]
									entity.destroy()
									game.surfaces[surface_index].create_entity{name=corpseName, position=entityPos}
								else
									if(cause and cause.valid) then
										entity.damage(damage, force, "explosion", cause)
									else
										entity.damage(damage, force, "explosion")
									end
								end
							end
						end
					end
				end
			end
		end
		
		local ang1 = math.atan2(y-originPos.y, x-originPos.x)
		local ang2 = math.atan2(y-originPos.y, x+32-originPos.x)
		local ang3 = math.atan2(y+32-originPos.y, x-originPos.x)
		local ang4 = math.atan2(y+32-originPos.y, x+32-originPos.x)
		if((ang1<-1.5 or ang2<-1.5 or ang3<-1.5 or ang4<-1.5) and (ang1>1.5 or ang2>1.5 or ang3>1.5 or ang4>1.5))then
			if(ang1<0) then
				ang1 = ang1+6.283185307
			end
			if(ang2<0) then
				ang2 = ang2+6.283185307
			end
			if(ang3<0) then
				ang3 = ang3+6.283185307
			end
			if(ang4<0) then
				ang4 = ang4+6.283185307
			end
		end	
		-- crater
		if((minR<chunkLoaderStruct.fireball_r*1.1+4) and (maxR>chunkLoaderStruct.crater_external_r-4) ) then
			local tiles = game.surfaces[surface_index].find_tiles_filtered{area=chunkPosAndArea.area, name=waterTypes};
			if(#tiles ~=0) then
				local startAngle = math.min(ang1, ang2, ang3, ang4)
				local endAngle = math.max(ang1, ang2, ang3, ang4)
				local tileTable = {};

				local fireballSq = chunkLoaderStruct.fireball_r*chunkLoaderStruct.fireball_r;
				for _,v in pairs(tiles) do
					if((v.position.x-originPos.x)*(v.position.x-originPos.x)+(v.position.y-originPos.y)*(v.position.y-originPos.y)<=fireballSq) then
						local depth = waterDepths[v.name]
						if(depth) then
							if (depth == -2 and (v.position.x == x or v.position.x == x+31))then
								--depth = -3;
							elseif (depth == -2 and (v.position.y == y or v.position.y == y+31))then
								--depth = -3
							end
							table.insert(tileTable, {name = depthsForCrater[depth], position = v.position})
						end
					end
				end
				game.surfaces[surface_index].set_tiles(tileTable)
				if(maxR>chunkLoaderStruct.fireball_r-4) then
					tileTable = {};
					local waterMapping = {}
					for t,h in pairs(waterDepths) do
						waterMapping[t] = depthsForCrater[h]
					end
					tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, chunkLoaderStruct.fireball_r, 1, waterMapping, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
					game.surfaces[surface_index].set_tiles(tileTable)
				end
			end	
		end
		if(minR<chunkLoaderStruct.crater_external_r*1.1+4) then
			if(settings.global["destroy-resources-in-crater"].value) then
				-- destroy resources in crater (a bit more to account for the noise on crater edge)
				local craterEdgeSq = (chunkLoaderStruct.crater_external_r*1.1+4)*(chunkLoaderStruct.crater_external_r*1.1+4)
				for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{area = chunkPosAndArea.area, type="resource"}) do
					if(v.valid and (v.position.x-originPos.x)*(v.position.x-originPos.x) + (v.position.y-originPos.y)*(v.position.y-originPos.y)<=craterEdgeSq) then
						v.destroy()
					end
				end
			end
			local startAngle = math.min(ang1, ang2, ang3, ang4)
			local endAngle = math.max(ang1, ang2, ang3, ang4)
			local crater_internal_r = chunkLoaderStruct.crater_internal_r
			local crater_external_r = chunkLoaderStruct.crater_external_r
			local tileTable = {};
			for xoffset = 0, 32 do
				for yoffset = 0, 32 do
					local tilepos = {x + xoffset, y + yoffset}
					local xdiff = x+xoffset-originPos.x
					local ydiff = y+yoffset-originPos.y
					local distSq = xdiff*xdiff+ydiff*ydiff
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
			game.surfaces[surface_index].set_tiles(tileTable)
			tileTable = {};
			-- add noise
			if(minR<crater_internal_r*1.1/3+10 and maxR> crater_internal_r/3-10) then
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r/3, 1, {default = depthsForCrater[-3]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
			end
			if(minR<crater_internal_r*1.1*2/3+10 and maxR> crater_internal_r*2/3-10) then
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r*2/3, 1, {default = depthsForCrater[-2]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
			end
			if(minR<crater_internal_r*1.15+10 and maxR> crater_internal_r-10) then
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r, 2, {default = depthsForCrater[0]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_internal_r, 1, {default = depthsForCrater[-1]}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
			end
			game.surfaces[surface_index].set_tiles(tileTable)
			tileTable={};
			-- ensure noise for crater goes on top of lakes
			
			--noise around the crater
			if(minR<crater_external_r*1.1+10 and maxR> crater_external_r-10) then
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_external_r, 1, {default = "nuclear-ground"}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
			end
			--high noise around crater
			if(minR<crater_external_r*1.1+6 and maxR> crater_external_r-14) then
				tileNoiseLimited(game.surfaces[surface_index], tileTable, originPos, crater_external_r-4, 1, {default = "nuclear-high"}, 3, startAngle, endAngle, minR, maxR, chunkPosAndArea.area);
			end
			
			game.surfaces[surface_index].set_tiles(tileTable)
			for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{area=chunkPosAndArea.area, name="nuclear-high"}) do
				game.surfaces[surface_index].set_hidden_tile(v.position, "nuclear-ground")
			end
		end
		if (not (game.surfaces[surface_index].count_tiles_filtered{area={{x=chunkPosAndArea.area.left_top.x+1, y=chunkPosAndArea.area.left_top.y+1},{x=chunkPosAndArea.area.right_bottom.x-1, y=chunkPosAndArea.area.right_bottom.y-1}} , name = craterTypes0, limit = 1} == 0)) then
			table.insert(global.cratersSlow, {t = 0, x = chunkPosAndArea.x, y = chunkPosAndArea.y, surface = surface_index});
			
			for xChunkPos = 0,4 do
				for yChunkPos = 0,4 do
					if (not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = waterTypes, limit = 1} == 0)) and 
						(not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = craterTypes0, limit = 1} == 0)) then
						local height = -2;
						if (not (game.surfaces[surface_index].count_tiles_filtered{area={{x+xChunkPos*8, y+yChunkPos*8}, {x+xChunkPos*8+8, y+yChunkPos*8+8}}, name = waterInCraterGoingOutDepth0Only, limit = 1} == 0)) then
							height = 0;
						end
						-- have both water and crater
						if(global.cratersFast[surface_index]==nil)then
							global.cratersFast[surface_index] = {}
							global.cratersFastData[surface_index] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
						end
						if(global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos]==nil)then
							global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos] = {}
							global.cratersFastData[surface_index].xCount = global.cratersFastData[surface_index].xCount + 1
						end
						global.cratersFast[surface_index][chunkPosAndArea.x*4+xChunkPos][chunkPosAndArea.y*4+yChunkPos] = height
					end
				end
			end
		end
	end
end


local function atomic_weapon_hit(surface_index, source, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, small_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters, optimise_load)
	 -- find forces, positions, etc.
	 local force
	 if(settings.global["nukes-cause-pollution"].value) then
	 	game.surfaces[surface_index].pollute(position, polution)
	 end
	 if(not (source==nil)) then
	 	force = source.force
	 else
		force = "neutral"
	 end
	 local cause = source;
	 if(global.waitingNukeCratersBasic ==nil) then
		global.waitingNukeCratersBasic = {}
	 end
	 if optimise_load then
	 	if(not global.blastWaves) then
	 		global.blastWaves = {};
 		end
	 	local blastId = math.random();
 		table.insert(global.blastWaves, {r = fireball_r, pos = position, blastId=blastId, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = 5000.0, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause})
	 	local index = #global.blastWaves
	 	local chunkData = {surface_index=surface_index, blastIndex=index, blastId=blastId, force=force, source=cause, position=position, crater_internal_r=crater_internal_r, 
	 				crater_external_r=crater_external_r, fireball_r=fireball_r, blast_max_r=blast_max_r, init_blast=5000.0, blast_min_damage=0, thermal_max_r=thermal_max_r, init_thermal=5000.0};
	 	local chunks = {}
	 	for chunk in game.surfaces[surface_index].get_chunks() do
	 		if(game.surfaces[surface_index].is_chunk_generated(chunk)) then
				table.insert(chunks, chunk);
			end
		end
		for _,chunk in pairs(chunks) do
	 		--local xdiff = chunk.x*32+16-position.x
	 		--local ydiff = chunk.y*32+16-position.y
	 		--log(math.sqrt(xdiff*xdiff+ydiff*ydiff));
		  	optimisedChunkLoadHandler(chunk, chunkData, true);
	  	end
		if(not global.optimisedNukes) then
			global.optimisedNukes = {}
		end
		table.insert(global.optimisedNukes, chunkData);
	else
	 	-- force the map to generate (should be reasonably quick as it is pre-loaded)
	 	game.surfaces[surface_index].request_to_generate_chunks(position, load_r/32)
	 	game.surfaces[surface_index].force_generate_chunk_requests()
	 	
	 
		 for _,f in pairs(game.forces) do
			f.chart(game.surfaces[surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
		 end
		 -- kill things in the fireball
		 for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
			if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
				if v.type=="tree" then
					v.destroy()
				elseif(corpseMap[v.name]) then
					v.destroy()
				elseif cause and cause.valid then
					if not v.die(force, cause) then
						v.destroy()
					end
				elseif not v.die(force) then
					v.destroy()
				end
			end
		 end
		 if(settings.global["destroy-resources-in-crater"].value) then
			 -- destroy resources in crater (a bit more to account for the noise on crater edge)
			 for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=crater_external_r*1.1+4, type="resource"}) do
				if(v.valid) then
					v.destroy()
				end
			 end
		 end
		 -- destroy decoratives in the fireball
		 for _,v in pairs(game.surfaces[surface_index].find_decoratives_filtered{area = {{position.x-fireball_r, position.y-fireball_r}, {position.x+fireball_r, position.y+fireball_r}}}) do
				if((v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)<=fireball_r*fireball_r) then
					local tmpPos = v.position;
					local result = decorativeMap[v.decorative.name]
					if(result == nil) then
						game.surfaces[surface_index].destroy_decoratives{position = v.position};
					elseif(result[1] == v.decorative.name) then
						local rnd = math.random();
						if(rnd<=result[2]) then
							game.surfaces[surface_index].destroy_decoratives{position = v.position};
						end
					elseif(result[1] ~=nil) then
						local rnd = math.random();
						game.surfaces[surface_index].destroy_decoratives{position = v.position};
						if(rnd<=result[2]) then
							game.surfaces[surface_index].create_decoratives{decoratives={{name=result[1], position=tmpPos, amount=1}}}
						end
					end
				end
		 end
		 -- make sure everything is dead in the fireball
		 for _,v in pairs(game.surfaces[surface_index].find_entities_filtered{position=position, radius=fireball_r}) do
			if(v.valid and (not (string.match(v.type, "ghost"))) and (not (v.type == "resource"))) then
				if(cause and cause.valid) then
					v.die(force, cause);
				else
					v.die(force);
				end
				if(v.valid) then
					v.destroy();
				end
			end
		 end
		 if(settings.global["use-height-for-craters"].value and settings.startup["enable-new-craters"].value) then
			if(crater_external_r>150) then --use efficient crater generator (ignores height for lakes)
				nukeTileChangesHeightAwareHuge(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
			else
			 	nukeTileChangesHeightAware(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
		 	end
		 else
		 	nukeTileChanges(position, check_craters, surface_index, crater_internal_r, crater_external_r, fireball_r)
		 end
		 -- light fires as nessesary
		 if(flame_proportion>0) then
			 for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=fire_outer_r}) do
				local rand = math.random(0, fire_outer_r)
				if(math.random(0, flame_proportion)<1 and rand*rand>(v.position.x-position.x)*(v.position.x-position.x)+(v.position.y-position.y)*(v.position.y-position.y)) then 
					if((not(waterInCraterGoingOutDepths[v.name] == nil)) and waterInCraterGoingOutDepths[v.name] > -10) then
						game.surfaces[surface_index].create_entity{name="thermobaric-wave-fire",position=v.position}
					else
						game.surfaces[surface_index].create_entity{name="nuclear-fire",position=v.position}
					end
				end
			 end
		 end
		 if (settings.global["nuke-random-fires"].value and create_small_fires) then
			for i=0,(small_fire_max_r*small_fire_max_r/10) do
				local dist = math.random(0, math.random(0, small_fire_max_r))
				local angle = math.random()*3.1416*2
				game.surfaces[surface_index].create_entity{name="thermobaric-wave-fire",position={position.x+dist*math.cos(angle), position.y+dist*math.sin(angle)}}
			end
		 end
		 if(settings.global["use-efficient-thermal"].value) then
		 	atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, 5000, fireball_r)
		 else
		 	old_atomic_thermal_blast(surface_index, position, force, cause, thermal_max_r, 5000, fireball_r)
	 	 end
		 table.insert(global.blastWaves, {r = fireball_r, pos = position, pow = fireball_r*fireball_r, max = blast_max_r, s = surface_index, fire = false, damage_init = 5000.0, speed = 8, fire_rad = 0, blast_min_damage = 0, itt = 1, doItts = true, ittframe = 1, force = force, cause = cause})
	 end
end


local function thermobaric_weapon_hit(surface_index, source, position, explosion_r, blast_max_r, fire_r, load_r, visable_r)
	 local force
	 local cause = source;
	 if(not (source==nil)) then
	 	force = source.force
	 else
		force = "enemy"
	 end
	 game.surfaces[surface_index].request_to_generate_chunks(position, load_r/32)
	 game.surfaces[surface_index].force_generate_chunk_requests()

	 for _,f in pairs(game.forces) do
		f.chart(game.surfaces[surface_index], {{position.x-visable_r,position.y-visable_r},{position.x+visable_r,position.y+visable_r}})
	 end
	 for _,v in pairs(game.surfaces[surface_index].find_tiles_filtered{position=position, radius=explosion_r}) do
		game.surfaces[surface_index].create_entity{name="fire-flame",position=v.position}
	 end
	 table.insert(global.blastWaves, {r = explosion_r, pos = position, pow = explosion_r*explosion_r, max = blast_max_r, s = surface_index, fire = true, damage_init = 600.0, speed = 1, fire_rad = fire_r, blast_min_damage = 30, itt = 1, doItts = false, ittframe = 1, force = force, cause = cause})
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
			if (not settings.global["optimise-100kt"].value) then
				game.surfaces[event.surface_index].request_to_generate_chunks(position, 1500/32)
			else
				game.surfaces[event.surface_index].request_to_generate_chunks(position, 200/32)
			end
		elseif(entity.prototype.name == "TN-big-atomic-artillery-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 1000/32)
		elseif(entity.prototype.name == "TN-atomic-artillery-projectile" or entity.prototype.name == "big-atomic-bomb-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 800/32)
		elseif(entity.prototype.name == "TN-small-atomic-artillery-projectile" or entity.prototype.name == "very-big-atomic-bomb-projectile") then
	 		game.surfaces[event.surface_index].request_to_generate_chunks(position, 400/32)
		end
	end
end

 -- calculate polution as 1*tonnage + 1000*uranium input + 100*californium input + 10000*tritium input
 -- polution is capped at 500000
--local function atomic_weapon_hit(surface_index, source_entity, position, crater_internal_r, crater_external_r, fireball_r, fire_outer_r, blast_max_r, tree_fire_max_r, thermal_max_r, load_r, visable_r, polution, flame_proportion, create_small_fires, check_craters, optimise)
script.on_event(defines.events.on_script_trigger_effect, function(event)
  if(event.effect_id=="Thermobaric Weapon hit small-") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 1, 15, 10, 10, 10);
  elseif(event.effect_id=="Thermobaric Weapon hit small") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 3, 30, 20, 30, 15);
  elseif(event.effect_id=="Thermobaric Weapon hit small+") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 4, 45, 30, 45, 25);
  elseif(event.effect_id=="Thermobaric Weapon hit medium-") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 5, 60, 40, 60, 35);
  elseif(event.effect_id=="Thermobaric Weapon hit medium") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 6, 80, 50, 80, 50);
  elseif(event.effect_id=="Thermobaric Weapon hit large") then
	 thermobaric_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 9, 120, 100, 120, 100);
  elseif(event.effect_id=="Atomic Weapon hit 0.1t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 0, 1, 1, 3, 30, 15, 30, 15, 15, 300.1, 1, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 60, 100, 200, 700, 10, 0.06);
  elseif(event.effect_id=="Atomic Weapon hit 0.5t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 0, 3, 3, 5, 50, 25, 30, 30, 20, 700.5, 1, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 80, 150, 300, 1000, 20, 0.12);
  elseif(event.effect_id=="Atomic Weapon hit 2t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 0, 5, 5, 15, 80, 50, 100, 100, 50, 1302, 2, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 100, 250, 500, 2000, 40, 0.25);
  elseif(event.effect_id=="Atomic Weapon hit 4t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 1, 6, 7, 20, 130, 120, 150, 180, 80, 4004, 1, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 120, 300, 900, 4000, 70, 0.4);
  elseif(event.effect_id=="Atomic Weapon hit 8t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 3, 8, 14, 25, 200, 200, 200, 180, 100, 9008, 1, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 150, 400, 1250, 10000, 100, 0.6);
  elseif(event.effect_id=="Atomic Weapon hit 20t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 5, 10, 20, 30, 320, 320, 320, 180, 150, 30020, 1, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 250, 600, 1800, 15000, 160, 1);
  elseif(event.effect_id=="Atomic Weapon hit 500t") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 10, 20, 40, 35, 400, 400, 600, 400, 300, 75500, 1*settings.global["large-nuke-fire-scaledown"].value, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 400, 800, 2500, 25000, 300, 2);
  elseif(event.effect_id=="Atomic Weapon hit 1kt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 20, 40, 80, 75, 800, 800, 1200, 800, 300, 101000, 2*settings.global["large-nuke-fire-scaledown"].value, true, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 600, 1200, 8000, 60000, 600, 4);
  elseif(event.effect_id=="Atomic Weapon hit 15kt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 50, 100, 200, 150, 2000/settings.global["large-nuke-blast-range-scaledown"].value, 1000, 4000, 1000, 500, 315000, settings.global["huge-nuke-fire-scaledown"].value, false, true, false);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 1500, 3000, 20000, 100000, 1500, 8);
  elseif(event.effect_id=="Atomic Weapon hit 100kt") then
  	 local blastD = 5500;
  	 if not settings.global["optimise-100kt"].value then
  	 	blastD = blastD/settings.global["really-huge-nuke-blast-range-scaledown"].value
  	 end
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 90, 180, 500, 400, blastD, 2500, 10000, 1500, 1000, 450000, 2*settings.global["really-huge-nuke-fire-scaledown"].value, false, false, settings.global["optimise-100kt"].value);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 2700, 5400, 36000, 200000, 2700, 16);
  elseif(event.effect_id=="Atomic Weapon hit 1Mt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 190, 390, 1200, 1000, 12000, 5000, 24000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 6000, 10000, 60000, 400000, 5000, 32);
  elseif(event.effect_id=="Atomic Weapon hit 5Mt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 330, 660, 2400, 2000, 24000, 10000, 48000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 12000, 20000, 120000, 800000, 10000, 64);
  elseif(event.effect_id=="Atomic Weapon hit 10Mt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 420, 830, 3150, 4000, 36000, 15000, 72000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 18000, 30000, 180000, 1200000, 15000, 96);
  elseif(event.effect_id=="Atomic Weapon hit 50Mt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 710, 1420, 6000, 8000, 72000, 30000, 144000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 36000, 60000, 360000, 2400000, 30000, 192);
  elseif(event.effect_id=="Atomic Weapon hit 100Mt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 900, 1800, 8000, 12000, 96000, 40000, 192000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 48000, 80000, 480000, 3200000, 40000, 256);
  elseif(event.effect_id=="Atomic Weapon hit 1Gt") then
	 atomic_weapon_hit(event.surface_index, event.source_entity, find_event_position(event), 1800, 3600, 16000, 24000, 192000, 80000, 384000, 3200, 2000, 500000, 0, false, false, true);
	 createBlastSoundsAndFlash(event.target_position, game.surfaces[event.surface_index], 96000, 160000, 960000, 6400000, 80000, 512);
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
				game.surfaces[chunk.surface].set_tiles({{name = depthsForCraterWater[waterDepths[target.name]][h], position = pos}});
				for _,t in pairs(tileGhosts) do
					game.surfaces[chunk.surface].create_entity{name="tile-ghost",position={pos.x+0.5, pos.y+0.5},inner_name=t.ghost_name,force=t.force}
				end

				if(global.cratersFast[chunk.surface]==nil)then
					global.cratersFast[chunk.surface] = {}
					global.cratersFastData[chunk.surface] = {synch = 0, xCount = 0, xCountSoFar = 0, xDone = {}}
				end
				local xChunkPos = math.floor(pos.x/8)
				if(global.cratersFast[chunk.surface][xChunkPos]==nil)then
					global.cratersFast[chunk.surface][xChunkPos] = {}
					global.cratersFastData[chunk.surface].xCount = global.cratersFastData[chunk.surface].xCount + 1
				end
				if(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] == nil) then
					global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] = h
				else
					global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)] = math.max(global.cratersFast[chunk.surface][xChunkPos][math.floor((pos.y)/8)], h)
				end
			end
		end
	end
	
end)
script.on_event(defines.events.on_chunk_generated, function(event)
	if(global.optimisedNukes ==nil) then
		global.optimisedNukes = {}
	end
	if(#global.optimisedNukes>0) then
		for _,chunkData in pairs(global.optimisedNukes) do
			if(chunkData.surface_index == event.surface.index) then
		  		optimisedChunkLoadHandler({x=event.position.x, y=event.position.y, area=event.area}, chunkData, false);
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
				for _,w in pairs(game.surfaces[v["s"]].find_entities_filtered{position=v["pos"], radius=v["t"]-4}) do
					if(string.match(w.type, "ghost") or w.prototype.is_building) then
						force = w.force
						break
					end
				end
				if(not (force==nil)) then
					for j,w in ipairs(game.surfaces[v["s"]].find_tiles_filtered{position=v["pos"], radius=v["t"]-3}) do
						game.surfaces[v["s"]].create_entity{name="tile-ghost",position=w.position,inner_name="landfill",force=force}
					end
				end
				table.remove(global.waitingNukeCratersBasic, i)
			else 
				v["t"] = v["t"]+1
				if(v["t"]>5) then
					 for _,w in pairs(game.surfaces[v["s"]].find_entities_filtered{position=v["pos"], radius=v["t"]-3}) do
						if(w.prototype.is_building) then
							w.die(nil)
						end
					 end
					 local tileTable = {}
					 for _,w in pairs(game.surfaces[v["s"]].find_tiles_filtered{position=v["pos"], radius=v["t"]-4}) do
						if((w.position["x"]-v["pos"]["x"])*(w.position["x"]-v["pos"]["x"])+(w.position["y"]-v["pos"]["y"])*(w.position["y"]-v["pos"]["y"])>=(math.max(v["t"]-10, 0))*(v["t"]-10)) then
							table.insert(tileTable, {name = "water-shallow", position = w.position})
						end
					 end
					 game.surfaces[v["s"]].set_tiles(tileTable, true, false)
				end
			end
		end
	end
end)
local function clearAllCraters(surface)
	local l = {};
	for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-deep", "nuclear-deep-shallow-fill", "nuclear-deep-fill"}})) do
		table.insert(l, {position=t.position, name = "deepwater"});
	end
	for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-crater", "nuclear-crater-fill"}})) do
		table.insert(l, {position=t.position, name = "water"});
	end
	for _,t in pairs(surface.find_tiles_filtered({name={"nuclear-shallow"}})) do
		table.insert(l, {position=t.position, name = "water-shallow"});
	end
	surface.set_tiles(l);
end 

local function getGlobal()
	return global;
end
remote.add_interface("True-Nukes Scripts", {
	thermobaricWeaponHit = thermobaric_weapon_hit,
	atomicWeaponHit = atomic_weapon_hit,
	createBlastSoundsAndFlash = createBlastSoundsAndFlash,
	nukeTileChangesHeightAware = nukeTileChangesHeightAware,
	nukeTileChangesHeightAwareHuge = nukeTileChangesHeightAwareHuge,
	nukeTileChanges = nukeTileChanges,
	clearAllCraters = clearAllCraters
});
