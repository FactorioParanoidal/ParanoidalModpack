if chunkUtilsG then
    return chunkUtilsG
end
local chunkUtils = {}

-- imports

local baseUtils = require("BaseUtils")
local constants = require("Constants")
local mapUtils = require("MapUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")

-- constants

local HIVE_BUILDINGS_TYPES = constants.HIVE_BUILDINGS_TYPES

local DEFINES_WIRE_TYPE_RED = defines.wire_type.red
local DEFINES_WIRE_TYPE_GREEN = defines.wire_type.green

local CHUNK_PASS_THRESHOLD = constants.CHUNK_PASS_THRESHOLD

local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT

local BASE_PHEROMONE = constants.BASE_PHEROMONE
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local GENERATOR_PHEROMONE_LEVEL = constants.GENERATOR_PHEROMONE_LEVEL

local GET_ENTITY_PHEROMONES = constants.GET_ENTITY_PHEROMONES
local BUILDING_PHEROMONES = constants.BUILDING_PHEROMONES
local FACTORISSIMO_ENTITY = constants.FACTORISSIMO_ENTITY
local FACTORISSIMO_ENTITY_FEROMONE = constants.FACTORISSIMO_ENTITY_FEROMONE
	

local CHUNK_SIZE = constants.CHUNK_SIZE
local CHUNK_SIZE_DIVIDER = constants.CHUNK_SIZE_DIVIDER

local CHUNK_NORTH_SOUTH = constants.CHUNK_NORTH_SOUTH
local CHUNK_EAST_WEST = constants.CHUNK_EAST_WEST

local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS
local CHUNK_IMPASSABLE = constants.CHUNK_IMPASSABLE

local RESOURCE_NORMALIZER = constants.RESOURCE_NORMALIZER

local CHUNK_TICK = constants.CHUNK_TICK
local GLOBAL_LVLUP_COOLDOWN = constants.GLOBAL_LVLUP_COOLDOWN

local MAXIMUM_BASE_RADIUS = constants.MAXIMUM_BASE_RADIUS
local BASE_CHANGING_CHANCE = constants.BASE_CHANGING_CHANCE

local VANILLA_ENTITIES = constants.VANILLA_ENTITIES


-- imported functions

local setNestCount = chunkPropertyUtils.setNestCount
local setPlayerBaseGenerator = chunkPropertyUtils.setPlayerBaseGenerator
local addPlayerBaseGenerator = chunkPropertyUtils.addPlayerBaseGenerator


local setResourceGenerator = chunkPropertyUtils.setResourceGenerator
local addResourceGenerator = chunkPropertyUtils.addResourceGenerator
local setPlayerTurretCount = chunkPropertyUtils.setPlayerTurretCount
local setHiveCount = chunkPropertyUtils.setHiveCount
local setTrapCount = chunkPropertyUtils.setTrapCount
local setTurretCount = chunkPropertyUtils.setTurretCount
local setUtilityCount = chunkPropertyUtils.setUtilityCount
local getPlayerBaseGenerator = chunkPropertyUtils.getPlayerBaseGenerator
local getNestCount = chunkPropertyUtils.getNestCount
local getHiveCount = chunkPropertyUtils.getHiveCount
local getTrapCount = chunkPropertyUtils.getTrapCount
local getUtilityCount = chunkPropertyUtils.getUtilityCount
local getTurretCount = chunkPropertyUtils.getTurretCount
local setRaidNestActiveness = chunkPropertyUtils.setRaidNestActiveness
local setNestActiveness = chunkPropertyUtils.setNestActiveness

local processNestActiveness = chunkPropertyUtils.processNestActiveness

local getEnemyStructureCount = chunkPropertyUtils.getEnemyStructureCount

local findNearbyBase = baseUtils.findNearbyBase
local createBase = baseUtils.createBase
local upgradeEntity = baseUtils.upgradeEntity

local changeEntityAligment = baseUtils.changeEntityAligment
local changeEntityTier = baseUtils.changeEntityTier
local getDynamicRates = baseUtils.getDynamicRates
local changeEntityAndUpdateDynamicRates = baseUtils.changeEntityAndUpdateDynamicRates

local thisIsNewEnemyPosition = chunkPropertyUtils.thisIsNewEnemyPosition

local getChunkBase = chunkPropertyUtils.getChunkBase
local setChunkBase = chunkPropertyUtils.setChunkBase
local removeChunkBase = chunkPropertyUtils.removeChunkBase
local setPassable = chunkPropertyUtils.setPassable
local setPathRating = chunkPropertyUtils.setPathRating

local getChunkByXY = mapUtils.getChunkByXY

local mMin = math.min
local mMax = math.max
local mFloor = math.floor
local mRandom = math.random

-- module code

local function getEntityOverlapChunks(map, entity)
    local boundingBox = entity.prototype.collision_box or entity.prototype.selection_box;
    local overlapArray = map.universe.chunkOverlapArray

    overlapArray[1] = -1 --LeftTop
    overlapArray[2] = -1 --RightTop
    overlapArray[3] = -1 --LeftBottom
    overlapArray[4] = -1 --RightBottom

    if boundingBox then
        local center = entity.position
        local topXOffset
        local topYOffset

        local bottomXOffset
        local bottomYOffset

        topXOffset = boundingBox.left_top.x
        topYOffset = boundingBox.left_top.y
        bottomXOffset = boundingBox.right_bottom.x
        bottomYOffset = boundingBox.right_bottom.y

        local leftTopChunkX = mFloor((center.x + topXOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
        local leftTopChunkY = mFloor((center.y + topYOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

        local rightTopChunkX = mFloor((center.x + bottomXOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
        local leftBottomChunkY = mFloor((center.y + bottomYOffset) * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

        overlapArray[1] = getChunkByXY(map, leftTopChunkX, leftTopChunkY) -- LeftTop
        if (leftTopChunkX ~= rightTopChunkX) then
            overlapArray[2] = getChunkByXY(map, rightTopChunkX, leftTopChunkY) -- RightTop
        end
        if (leftTopChunkY ~= leftBottomChunkY) then
            overlapArray[3] = getChunkByXY(map, leftTopChunkX, leftBottomChunkY) -- LeftBottom
        end
        if (leftTopChunkX ~= rightTopChunkX) and (leftTopChunkY ~= leftBottomChunkY) then
            overlapArray[4] = getChunkByXY(map, rightTopChunkX, leftBottomChunkY) -- RightBottom
        end
    end
    return overlapArray
end

local function scanPaths(chunk, map)
    local surface = map.surface
    local pass = CHUNK_IMPASSABLE

    local x = chunk.x
    local y = chunk.y

    local universe = map.universe
    local filteredEntitiesCliffQuery = universe.filteredEntitiesCliffQuery
    local filteredTilesPathQuery = universe.filteredTilesPathQuery
    local count_entities_filtered = surface.count_entities_filtered
    local count_tiles_filtered = surface.count_tiles_filtered

    local passableNorthSouth = false
    local passableEastWest = false

    local topPosition = filteredEntitiesCliffQuery.area[1]
    local bottomPosition = filteredEntitiesCliffQuery.area[2]
    topPosition[2] = y
    bottomPosition[2] = y + 32

    for xi=x, x + 32 do
        topPosition[1] = xi
        bottomPosition[1] = xi + 1
        if (count_entities_filtered(filteredEntitiesCliffQuery) == 0) and
            (count_tiles_filtered(filteredTilesPathQuery) == 0)
        then
            passableNorthSouth = true
            break
        end
    end

    topPosition[1] = x
    bottomPosition[1] = x + 32

    for yi=y, y + 32 do
        topPosition[2] = yi
        bottomPosition[2] = yi + 1
        if (count_entities_filtered(filteredEntitiesCliffQuery) == 0) and
            (count_tiles_filtered(filteredTilesPathQuery) == 0)
        then
            passableEastWest = true
            break
        end
    end

    if passableEastWest and passableNorthSouth then
        pass = CHUNK_ALL_DIRECTIONS
    elseif passableEastWest then
        pass = CHUNK_EAST_WEST
    elseif passableNorthSouth then
        pass = CHUNK_NORTH_SOUTH
    end
    return pass
end

local function scorePlayerBuildings(map, chunk)
    local surface = map.surface
	local universe = map.universe
	local turretsCount = 0
	local pheromones = {}
	pheromones[BASE_PHEROMONE] = 0
	pheromones[BASE_DETECTION_PHEROMONE] = 0
    if surface.count_entities_filtered(universe.hasPlayerStructuresQuery) > 0 then
		for lvlName, values in pairs(GENERATOR_PHEROMONE_LEVEL) do
			local query = universe.filteredEntities_player_pheromones[lvlName]
			if query then
				local enityCnt = surface.count_entities_filtered(query)
				pheromones[BASE_PHEROMONE] = pheromones[BASE_PHEROMONE] + enityCnt*values[BASE_PHEROMONE]
				pheromones[BASE_DETECTION_PHEROMONE] = pheromones[BASE_DETECTION_PHEROMONE] + enityCnt*values[BASE_DETECTION_PHEROMONE]
				if lvlName == "turrets" then
					turretsCount = turretsCount + enityCnt
				end
			end	
		end
		
		local entities = surface.find_entities_filtered(universe.filteredEntitiesPlayerQueryFactorissimo)	-- 
		for i = 1, #entities do
			local entity = entities[i]
			if FACTORISSIMO_ENTITY(entity) then
				pheromones[BASE_PHEROMONE] = pheromones[BASE_PHEROMONE] + FACTORISSIMO_ENTITY_FEROMONE[BASE_PHEROMONE]			
				pheromones[BASE_DETECTION_PHEROMONE] = pheromones[BASE_DETECTION_PHEROMONE] + FACTORISSIMO_ENTITY_FEROMONE[BASE_DETECTION_PHEROMONE]			
			end
		end    
    end		
	setPlayerBaseGenerator(map, chunk, pheromones[BASE_PHEROMONE], BASE_PHEROMONE)
	setPlayerBaseGenerator(map, chunk, pheromones[BASE_DETECTION_PHEROMONE], BASE_DETECTION_PHEROMONE)
	setPlayerTurretCount(map, chunk, turretsCount)

	return pheromones[BASE_PHEROMONE]
end

function chunkUtils.initialScan(chunk, map, tick)
    local surface = map.surface
    local universe = map.universe
    local waterTiles = (1 - (surface.count_tiles_filtered(universe.filteredTilesQuery) * 0.0009765625)) * 0.80
    local enemyBuildings = surface.find_entities_filtered(universe.filteredEntitiesEnemyStructureQuery)

    if (waterTiles >= CHUNK_PASS_THRESHOLD) or (#enemyBuildings > 0) then
        local neutralObjects = mMax(0,
                                    mMin(1 - (surface.count_entities_filtered(universe.filteredEntitiesChunkNeutral) * 0.005),
                                         1) * 0.20)
        local pass = scanPaths(chunk, map)		
		
		local pheromones = scorePlayerBuildings(map, chunk)

        if ((pheromones > 0) or (#enemyBuildings > 0)) and (pass == CHUNK_IMPASSABLE) then
            pass = CHUNK_ALL_DIRECTIONS
        end

        if (pass ~= CHUNK_IMPASSABLE) then
            local resources = surface.count_entities_filtered(universe.countResourcesQuery) * RESOURCE_NORMALIZER

            local buildingHiveTypeLookup = universe.buildingHiveTypeLookup
            local counts = map.chunkScanCounts
            for i=1,#HIVE_BUILDINGS_TYPES do
                counts[HIVE_BUILDINGS_TYPES[i]] = 0
            end
			local unknownNests = 0
            if (#enemyBuildings > 0) then
				local thisIsRampantEnemy = false
				local base
                if universe.NEW_ENEMIES then
					base = findNearbyBase(map, chunk, MAXIMUM_BASE_RADIUS, BASE_CHANGING_CHANCE)
					if base then
						setChunkBase(map, chunk, base)
					else
						base = createBase(map, chunk, tick, thisIsNewEnemyPosition(universe, chunk.x, chunk.y))
					end
					thisIsRampantEnemy = base.thisIsRampantEnemy
				end
				
				if thisIsRampantEnemy then
					local alignment = base.alignment
						local unitList = surface.find_entities_filtered(universe.filteredEntitiesUnitQuery)
						for i=1,#unitList do
							local unit = unitList[i]
							if (unit.valid) then
								unit.destroy()
							end
						end

						for i = 1, #enemyBuildings do
							local enemyBuilding = enemyBuildings[i]							
							if not buildingHiveTypeLookup[enemyBuilding.name] then
								local newEntity
								if VANILLA_ENTITIES[enemyBuilding.name] or ((not universe.ALLOW_OTHER_ENEMIES) and (mRandom()<0.8)) then
									newEntity = upgradeEntity(enemyBuilding, alignment, map, nil, true)
								end	
								if newEntity then
									local hiveType = buildingHiveTypeLookup[newEntity.name]
									counts[hiveType] = counts[hiveType] + 1
								elseif (enemyBuilding and enemyBuilding.type == "unit-spawner") then
									unknownNests = unknownNests + 1
								end
							end
						end
						setNestCount(map, chunk, counts["spitter-spawner"] + counts["biter-spawner"]  + unknownNests)
						setUtilityCount(map, chunk, counts["utility"])
						setHiveCount(map, chunk, counts["hive"])
						setTrapCount(map, chunk, counts["trap"])
						setTurretCount(map, chunk, counts["turret"])
				
				else
                    for i=1,#enemyBuildings do
                        local building = enemyBuildings[i]
                        local hiveType = buildingHiveTypeLookup[building.name] or
                            ((building.type == "turret") and "turret")
							if hiveType then	
								counts[hiveType] = counts[hiveType] + 1
							elseif building.type == "unit-spawner" then
								unknownNests = unknownNests + 1
							end
                    end
                    setNestCount(map, chunk, counts["spitter-spawner"] + counts["biter-spawner"] + unknownNests)
					setTurretCount(map, chunk, counts["turret"])
				end				
				if map.suspended then
					map.suspended = false
					map.suspendCheckTick = tick
				end
			end	
								
            setResourceGenerator(map, chunk, resources)

            setPassable(map, chunk, pass)
            setPathRating(map, chunk, waterTiles + neutralObjects)

            return chunk
        end
    end

    return -1
end

function chunkUtils.chunkPassScan(chunk, map)
    local surface = map.surface
    local universe = map.universe
    local waterTiles = (1 - (surface.count_tiles_filtered(universe.filteredTilesQuery) * 0.0009765625)) * 0.80

    if (waterTiles >= CHUNK_PASS_THRESHOLD) then
        local neutralObjects = mMax(0,
                                    mMin(1 - (surface.count_entities_filtered(universe.filteredEntitiesChunkNeutral) * 0.005),
                                         1) * 0.20)
        local pass = scanPaths(chunk, map)

        local playerObjects = getPlayerBaseGenerator(map, chunk, BASE_PHEROMONE)

        local nests = getNestCount(map, chunk)

        if ((playerObjects > 0) or (nests > 0)) and (pass == CHUNK_IMPASSABLE) then
            pass = CHUNK_ALL_DIRECTIONS
        end

        setPassable(map, chunk, pass)
        setPathRating(map, chunk, waterTiles + neutralObjects)

        return chunk
    end

    return -1
end

function chunkUtils.mapScanPlayerChunk(chunk, map)
	scorePlayerBuildings(map, chunk)
end

function chunkUtils.mapScanResourceChunk(chunk, map)
    local surface = map.surface
    local universe = map.universe
    local resources = surface.count_entities_filtered(universe.countResourcesQuery) * RESOURCE_NORMALIZER
    setResourceGenerator(map, chunk, resources)
    local waterTiles = (1 - (surface.count_tiles_filtered(universe.filteredTilesQuery) * 0.0009765625)) * 0.80
    local neutralObjects = mMax(0,
                                mMin(1 - (surface.count_entities_filtered(universe.filteredEntitiesChunkNeutral) * 0.005),
                                     1) * 0.20)
    setPathRating(map, chunk, waterTiles + neutralObjects)
end

function chunkUtils.mapScanEnemyChunk(chunk, map)
    local universe = map.universe
    local buildingHiveTypeLookup = universe.buildingHiveTypeLookup
    local buildings = map.surface.find_entities_filtered(universe.filteredEntitiesEnemyStructureQuery)
    local counts = map.chunkScanCounts

    local FactionCounts = {}
	local enemyAlignmentLookup = universe.enemyAlignmentLookup
	local base = getChunkBase(map, chunk)
	local changingEntities = false
	local dynamicRates
	
	local baseTier = 1
	local newTier = 1
			
	local thisIsRampantEnemy = false
	if universe.NEW_ENEMIES and base and base.thisIsRampantEnemy then
		thisIsRampantEnemy = true
		changingEntities = base.changingEntities
		baseTier = mMax(base.tier-base.tierHandicap, 1)
		newTier = mMax(baseTier - mRandom(0, 2), 1)
	end	
	
	if changingEntities then
		dynamicRates = baseUtils.getDynamicRates(base)
	end	
	
    for i=1,#HIVE_BUILDINGS_TYPES do
        counts[HIVE_BUILDINGS_TYPES[i]] = 0
    end
		
	local mutatesCnt = 0	
	local maxMutations = 5
	local tick = game.tick
	
	local pendingMutations = universe.pendingMutations
	local pendingEntities = pendingMutations["entities"]
	local pendingChunks = pendingMutations["chunks"]
	local pendingEntitiesCnt = 0
	local chunkIndex = "x"..chunk.x.."y"..chunk.y.."m"..map.surface.index
	
	local buildingsCnt = #buildings
	
    for i=1,#buildings do
        local building = buildings[i]
        local newBuilding
		-- mutation and upgrade--
		if thisIsRampantEnemy and (not pendingChunks[chunkIndex]) and building.valid then
			if changingEntities then
				if ((chunk.nextMutationTick  or 0) < tick) and (buildingHiveTypeLookup[building.name] or (building.type == "turret")) then
					-- if mutatesCnt>maxMutations then
						pendingEntitiesCnt = pendingEntitiesCnt + 1
						local entityData = {
							["chunkIndex"] = chunkIndex,
							["surfaceIndex"] = map.surface.index,
							["base"] = base,
							["entity"] = building
						}
						pendingEntities[building.unit_number] = entityData 
					-- else
						-- newBuilding = changeEntityAndUpdateDynamicRates(building, dynamicRates, map, base)
						-- if newBuilding then
							-- mutatesCnt = mutatesCnt + 1
							-- building = newBuilding
						-- end
					-- end
				end
			else
				local oldTier = universe.buildingTierLookup[building.name]
				if oldTier and (oldTier<newTier) and (universe.lvlupTick<=tick) then
					local roll = mRandom()
					if roll < 0.01 then
						--local oldName = building.name
						newBuilding = changeEntityTier(building, newTier, map)
						if newBuilding then
							--game.print("chunkUtils.mapScanEnemyChunk. Changing tier:"..oldName.."->"..newBuilding.name)	-- debug
							universe.lvlupTick = tick + GLOBAL_LVLUP_COOLDOWN
							building = newBuilding
						end
					end
				end
			end
		end			
		
		-----
		if building.valid then	
			local hiveType = buildingHiveTypeLookup[building.name] or
				(((building.type == "turret") and "turret") 
					or ((building.type =="unit-spawner") and "biter-spawner")
				)	
			counts[hiveType] = counts[hiveType] + 1
			
			
			if universe.NEW_ENEMIES then
				if building.type =="unit-spawner" then
					local faction = enemyAlignmentLookup[building.name]
					if faction then
						FactionCounts[faction] = (FactionCounts[faction] or 0) + 1
					end
				end	
			end
		end	
    end

	if pendingEntitiesCnt > 0 then
		pendingChunks[chunkIndex] = pendingEntitiesCnt
	end
	
	if (mutatesCnt > 0) or (pendingEntitiesCnt > 0) then
		chunk.nextMutationTick = tick + mMin(pendingEntitiesCnt + mutatesCnt, 20)*1800
	end

		
	if universe.NEW_ENEMIES then		
		if (buildingsCnt > 0) and not base then
 			base = findNearbyBase(map, chunk, MAXIMUM_BASE_RADIUS, BASE_CHANGING_CHANCE)
			if base then
				setChunkBase(map, chunk, base)
			else
				local FactionCountsIterator = next(FactionCounts, nil)
				if FactionCountsIterator then
					base = createBase(map, chunk, game.tick, true)
				else	
					base = createBase(map, chunk, game.tick, thisIsNewEnemyPosition(universe, chunk.x, chunk.y))
				end	
				setChunkBase(map, chunk, base)
			end
			thisIsRampantEnemy = base.thisIsRampantEnemy
		----------------	
		end
		if (buildingsCnt == 0) and base then
			removeChunkBase(map, chunk, base)
		end
	end	


    setNestCount(map, chunk, counts["spitter-spawner"] + counts["biter-spawner"])
    setUtilityCount(map, chunk, counts["utility"])
    setHiveCount(map, chunk, counts["hive"])
    setTrapCount(map, chunk, counts["trap"])
    setTurretCount(map, chunk, counts["turret"])

	if universe.NEW_ENEMIES and thisIsRampantEnemy then
		local baseChunkFactions = {}

		if base then
			base.chunkFactions[chunk] = FactionCounts
		end	
	end	
	
	if map.suspended and (counts["spitter-spawner"] + counts["biter-spawner"] > 0) then
		map.suspended = false
		map.suspendCheckTick = game.tick
	end
end

function chunkUtils.entityForPassScan(map, entity)
    local overlapArray = getEntityOverlapChunks(map, entity)

    for i=1,#overlapArray do
        local chunk = overlapArray[i]
        if (chunk ~= -1) then
			local chunkData = {chunk.x, chunk.y, map.surface.index}
			local chunkIndex = "x"..chunkData[1].."y"..chunkData[2].."m"..chunkData[3]
            map.universe.chunkToPassScan[chunkIndex] = chunkData
        end
    end
end

function chunkUtils.createChunk(topX, topY)
    local chunk = {
        x = topX,
        y = topY
    }
    chunk[BASE_PHEROMONE] = 0
    chunk[BASE_DETECTION_PHEROMONE] = 0	-- + !КДА
    chunk[PLAYER_PHEROMONE] = 0
    chunk[RESOURCE_PHEROMONE] = 0
    chunk[CHUNK_TICK] = 0
    chunk["deathLevel"] = nil	

    return chunk
end

function chunkUtils.colorChunk(chunk, surface, color)
    local lx = math.floor(chunk.x * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
    local ly = math.floor(chunk.y * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

    rendering.draw_rectangle({
            color = color or {0.1, 0.3, 0.1, 0.6},
            width = 32 * 32,
            filled = true,
            left_top = {lx, ly},
            right_bottom = {lx+32, ly+32},
            surface = surface,
            time_to_live = 180,
            draw_on_ground = true,
            visible = true
    })
end

function chunkUtils.colorXY(x, y, surface, color)
    local lx = math.floor(x * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
    local ly = math.floor(y * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE

    rendering.draw_rectangle({
            color = color or {0.1, 0.3, 0.1, 0.6},
            width = 32 * 32,
            filled = true,
            left_top = {lx, ly},
            right_bottom = {lx+32, ly+32},
            surface = surface,
            time_to_live = 180,
            draw_on_ground = true,
            visible = true
    })
end


function chunkUtils.registerEnemyBaseStructure(map, entity, base)
    local entityType = entity.type
    if ((entityType == "unit-spawner") or (entityType == "turret")) and (entity.force.name == "enemy") then
        local overlapArray = getEntityOverlapChunks(map, entity)

        local getFunc
        local setFunc
        local universe = map.universe
        local hiveTypeLookup = universe.buildingHiveTypeLookup
        local hiveType = hiveTypeLookup[entity.name]
        if (hiveType == "spitter-spawner") or (hiveType == "biter-spawner") then
            map.builtEnemyBuilding = map.builtEnemyBuilding + 1
            getFunc = getNestCount
            setFunc = setNestCount
        elseif (hiveType == "turret") then
            map.builtEnemyBuilding = map.builtEnemyBuilding + 1
            getFunc = getTurretCount
            setFunc = setTurretCount
        elseif (hiveType == "trap") then
            getFunc = getTrapCount
            setFunc = setTrapCount
        elseif (hiveType == "utility") then
            map.builtEnemyBuilding = map.builtEnemyBuilding + 1
            getFunc = getUtilityCount
            setFunc = setUtilityCount
        elseif (hiveType == "hive") then
            map.builtEnemyBuilding = map.builtEnemyBuilding + 1
            getFunc = getHiveCount
            setFunc = setHiveCount
        else
            if (entityType == "turret") then
                map.builtEnemyBuilding = map.builtEnemyBuilding + 1
                getFunc = getTurretCount
                setFunc = setTurretCount
            elseif (entityType == "unit-spawner") then
                map.builtEnemyBuilding = map.builtEnemyBuilding + 1
                getFunc = getNestCount
                setFunc = setNestCount
            end
        end

        for i=1,#overlapArray do
            local chunk = overlapArray[i]
			if (chunk ~= -1) then
				setFunc(map, chunk, getFunc(map, chunk) + 1)
				if base then
					setChunkBase(map, chunk, base)
				end	
				processNestActiveness(map, chunk)
           end
        end
    end

    return entity
end

function chunkUtils.unregisterEnemyBaseStructure(map, entity, damageType)
    local entityType = entity.type
    if ((entityType == "unit-spawner") or (entityType == "turret")) and (entity.force.name == "enemy") then
        local overlapArray = getEntityOverlapChunks(map, entity)
        local getFunc
        local setFunc
        local hiveTypeLookup = map.universe.buildingHiveTypeLookup
        local hiveType = hiveTypeLookup[entity.name]
        if (hiveType == "spitter-spawner") or (hiveType == "biter-spawner") then
            map.lostEnemyBuilding = map.lostEnemyBuilding + 1
            getFunc = getNestCount
            setFunc = setNestCount
        elseif (hiveType == "turret") then
            map.lostEnemyBuilding = map.lostEnemyBuilding + 1
            getFunc = getTurretCount
            setFunc = setTurretCount
        elseif (hiveType == "trap") then
            getFunc = getTrapCount
            setFunc = setTrapCount
        elseif (hiveType == "utility") then
            map.lostEnemyBuilding = map.lostEnemyBuilding + 1
            getFunc = getUtilityCount
            setFunc = setUtilityCount
        elseif (hiveType == "hive") then
            map.lostEnemyBuilding = map.lostEnemyBuilding + 1
            getFunc = getHiveCount
            setFunc = setHiveCount
        else
            if (entityType == "turret") then
                map.lostEnemyBuilding = map.lostEnemyBuilding + 1
                getFunc = getTurretCount
                setFunc = setTurretCount
            elseif (entityType == "unit-spawner") then
                hiveType = "biter-spawner"
                map.lostEnemyBuilding = map.lostEnemyBuilding + 1
                getFunc = getNestCount
                setFunc = setNestCount
            end
        end

        for i=1,#overlapArray do
            local chunk = overlapArray[i]
			if (chunk ~= -1) then
				local count = getFunc(map, chunk)
				if count then
					if (count <= 1) then
						if (hiveType == "spitter-spawner") or (hiveType == "biter-spawner") then
							setRaidNestActiveness(map, chunk, 0)
							setNestActiveness(map, chunk, 0)
						end
						setFunc(map, chunk, 0)
						if (getEnemyStructureCount(map, chunk) == 0) then
							removeChunkBase(map, chunk)
						end
					else
						setFunc(map, chunk, count - 1)
					end
				end
			end
		end
    end
end

local function ignoredForce(force, universe)
	local forceIgnored = true
	for i = 1, #universe.activePlayerForces do
		if universe.activePlayerForces[i] == force.name then
			forceIgnored = false
			break
		end
	end
	return forceIgnored
end

function chunkUtils.accountPlayerEntity(entity, map, addObject, creditNatives)
	if ignoredForce(entity.force, map.universe) then
		return
	end	
	local GENERATOR_PHEROMONE_LEVEL = constants.GENERATOR_PHEROMONE_LEVEL
	local pointsToAccount = {BASE_PHEROMONE, BASE_DETECTION_PHEROMONE}
	for i = 1, #pointsToAccount do
		local pheromoneType = pointsToAccount[i]
		if (entity.force.name ~= "enemy") then
			local universe = map.universe
			local entityValue = GET_ENTITY_PHEROMONES(entity, pheromoneType)
			local overlapArray = getEntityOverlapChunks(map, entity)
			if not addObject then
				if (creditNatives) and (pheromoneType==BASE_PHEROMONE) then					
					if entity.type ~= "wall" then	-- + !КДА 2021.11
						map.destroyPlayerBuildings = map.destroyPlayerBuildings + 1
						if universe.aiDifficulty == "Hard" then
							if (map.state == AI_STATE_ONSLAUGHT) then
								map.points = map.points + entityValue
								if universe.aiPointsPrintGainsToChat then
									game.print(map.surface.name .. ": Points: +" .. math.floor(entityValue) .. ". [Structure Kill] Total: " .. string.format("%.2f", map.points))
								end
							else
								map.points = map.points + entityValue * 0.12
								if universe.aiPointsPrintGainsToChat then
									game.print(map.surface.name .. ": Points: +" .. math.floor(entityValue * 0.12) .. ". [Structure Kill] Total: " .. string.format("%.2f", map.points))
								end
							end
						end	
					end
				end					
				entityValue = -entityValue
			end

			for i=1,#overlapArray do
				local chunk = overlapArray[i]
				if chunk ~= -1 then
					addPlayerBaseGenerator(map, chunk, entityValue, pheromoneType)
				end
			end	
		end	
	end	
    return entity
end

function chunkUtils.unregisterResource(entity, map)
    if entity.prototype.infinite_resource then
        return
    end
    local overlapArray = getEntityOverlapChunks(map, entity)

    for i=1,#overlapArray do
        local chunk = overlapArray[i]
        if (chunk ~= -1) then
            addResourceGenerator(map, chunk, -RESOURCE_NORMALIZER)
        end
    end
end

function chunkUtils.registerResource(entity, map)
    local overlapArray = getEntityOverlapChunks(map, entity)

    for i=1,#overlapArray do
        local chunk = overlapArray[i]
        if (chunk ~= -1) then
            addResourceGenerator(map, chunk, RESOURCE_NORMALIZER)
        end
    end
end

function chunkUtils.makeImmortalEntity(surface, entity)
    local repairPosition = entity.position
    local repairName = entity.name
    local repairForce = entity.force
    local repairDirection = entity.direction

    local wires
    if (entity.type == "electric-pole") then
        wires = entity.neighbours
    end
    entity.destroy()
    local newEntity = surface.create_entity({position=repairPosition,
                                             name=repairName,
                                             direction=repairDirection,
                                             force=repairForce})
    if wires then
        for _,v in pairs(wires.copper) do
            if (v.valid) then
                newEntity.connect_neighbour(v);
            end
        end
        for _,v in pairs(wires.red) do
            if (v.valid) then
                newEntity.connect_neighbour({wire = DEFINES_WIRE_TYPE_RED, target_entity = v});
            end
        end
        for _,v in pairs(wires.green) do
            if (v.valid) then
                newEntity.connect_neighbour({wire = DEFINES_WIRE_TYPE_GREEN, target_entity = v});
            end
        end
    end

    newEntity.destructible = false
end

chunkUtilsG = chunkUtils
return chunkUtils
