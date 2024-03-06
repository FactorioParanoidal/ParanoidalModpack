if mapProcessorG then
    return mapProcessorG
end
local mapProcessor = {}

-- imports

local pheromoneUtils = require("PheromoneUtils")
local aiAttackWave = require("AIAttackWave")
local aiPredicates = require("AIPredicates")
local constants = require("Constants")
local mapUtils = require("MapUtils")
local playerUtils = require("PlayerUtils")
local chunkUtils = require("ChunkUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")
local baseUtils = require("BaseUtils")
local squadCompression = require("SquadCompression")

-- constants

local DURATION_ACTIVE_NEST_DIVIDER = constants.DURATION_ACTIVE_NEST_DIVIDER
local DURATION_ACTIVE_NEST = constants.DURATION_ACTIVE_NEST

local PROCESS_QUEUE_SIZE = constants.PROCESS_QUEUE_SIZE
local RESOURCE_QUEUE_SIZE = constants.RESOURCE_QUEUE_SIZE
local ENEMY_QUEUE_SIZE = constants.ENEMY_QUEUE_SIZE
local PLAYER_QUEUE_SIZE = constants.PLAYER_QUEUE_SIZE

local CLEANUP_QUEUE_SIZE = constants.CLEANUP_QUEUE_SIZE

local CHUNK_SIZE = constants.CHUNK_SIZE

local PROCESS_PLAYER_BOUND = constants.PROCESS_PLAYER_BOUND
local CHUNK_TICK = constants.CHUNK_TICK

local PROCESS_STATIC_QUEUE_SIZE = constants.PROCESS_STATIC_QUEUE_SIZE

local AI_VENGENCE_SQUAD_COST = constants.AI_VENGENCE_SQUAD_COST
local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE

local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL
local AI_STATE_MIGRATING = constants.AI_STATE_MIGRATING
local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_GROWING = constants.AI_STATE_GROWING

local GROWING_COOLDOWN = constants.GROWING_COOLDOWN

local COOLDOWN_RALLY = constants.COOLDOWN_RALLY
local COOLDOWN_RETREAT = constants.COOLDOWN_RETREAT
local COOLDOWN_HUNT = constants.COOLDOWN_HUNT

local BASE_PROCESS_INTERVAL = constants.BASE_PROCESS_INTERVAL

-- imported functions

local processStaticPheromone = pheromoneUtils.processStaticPheromone
local processPheromone = pheromoneUtils.processPheromone

local getDeathGenerator = chunkPropertyUtils.getDeathGenerator
local processBase = baseUtils.processBase

local processNestActiveness = chunkPropertyUtils.processNestActiveness

local formSquads = aiAttackWave.formSquads
local formVengenceSquad = aiAttackWave.formVengenceSquad
local formSettlers = aiAttackWave.formSettlers

local getChunkByPosition = mapUtils.getChunkByPosition
local getChunkByXY = mapUtils.getChunkByXY

local validPlayer = playerUtils.validPlayer

local mapScanEnemyChunk = chunkUtils.mapScanEnemyChunk
local mapScanPlayerChunk = chunkUtils.mapScanPlayerChunk
local mapScanResourceChunk = chunkUtils.mapScanResourceChunk
local registerEnemyBaseStructure = chunkUtils.registerEnemyBaseStructure

local getNestCount = chunkPropertyUtils.getNestCount
local getHiveCount = chunkPropertyUtils.getHiveCount
local getTurretCount = chunkPropertyUtils.getTurretCount
local getEnemyStructureCount = chunkPropertyUtils.getEnemyStructureCount
local getNestActiveness = chunkPropertyUtils.getNestActiveness
local getNestActiveTick = chunkPropertyUtils.getNestActiveTick
local setNestActiveTick = chunkPropertyUtils.setNestActiveTick

local getRaidNestActiveness = chunkPropertyUtils.getRaidNestActiveness
local thisIsNewEnemyPosition = chunkPropertyUtils.thisIsNewEnemyPosition
local getSquadsOnChunk = chunkPropertyUtils.getSquadsOnChunk

local squadDecompress = squadCompression.squadDecompress

local canAttack = aiPredicates.canAttack
local canMigrate = aiPredicates.canMigrate

local tableSize = table_size

local mMin = math.min
local mMax = math.max

local next = next
local mRandom = math.random

-- module code

--[[
    processing is not consistant as it depends on the number of chunks that have been generated
    so if we process 400 chunks an iteration and 200 chunks have been generated than these are
    processed 3 times a second and 1200 generated chunks would be processed once a second
    In theory, this might be fine as smaller bases have less surface to attack and need to have
    pheromone dissipate at a faster rate.
--]]
function mapProcessor.processMap(map, tick)
    local index = map.processIndex

    local outgoingWave = map.outgoingScanWave
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local step
    local endIndex
    if outgoingWave then
        step = 1
        endIndex = mMin(index + PROCESS_QUEUE_SIZE, processQueueLength)
    else
        step = -1
        endIndex = mMax(index - PROCESS_QUEUE_SIZE, 1)
    end

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex,step do
        local chunk = processQueue[x]
        if chunk and (chunk[CHUNK_TICK] ~= tick) then
            chunk[CHUNK_TICK] = tick
            processPheromone(map, chunk)
        end
    end

    if (endIndex == processQueueLength) then
        map.outgoingScanWave = false
    elseif (endIndex == 1) then
        map.outgoingScanWave = true
    elseif outgoingWave then
        map.processIndex = endIndex + 1
    else
        map.processIndex = endIndex - 1
    end
end

function mapProcessor.processStaticMap(map)
    local index = map.processStaticIndex

    local outgoingWave = map.outgoingStaticScanWave
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local step
    local endIndex
    if outgoingWave then
        step = 1
        endIndex = mMin(index + PROCESS_STATIC_QUEUE_SIZE, processQueueLength)
    else
        step = -1
        endIndex = mMax(index - PROCESS_STATIC_QUEUE_SIZE, 1)
    end

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex,step do
        local chunk = processQueue[x]
        processStaticPheromone(map, chunk)
    end

    if (endIndex == processQueueLength) then
        map.outgoingStaticScanWave = false
    elseif (endIndex == 1) then
        map.outgoingStaticScanWave = true
    elseif outgoingWave then
        map.processStaticIndex = endIndex + 1
    else
        map.processStaticIndex = endIndex - 1
    end
end

local function queueNestSpawners(map, chunk, tick)
    local processActiveNest = map.universe.processActiveNest
    if not processActiveNest[chunk] then
        if (getNestActiveness(map, chunk) > 0) or (getRaidNestActiveness(map, chunk) > 0) then
            processActiveNest[chunk] = {
                map = map,
                tick = tick + DURATION_ACTIVE_NEST
            }
        end
    end
end


local xyVector = {{-1, -1}, {-1, 1}, {1, -1}, {1, 1}}
local huntingChance = {}
huntingChance[0] = 1
huntingChance[32] = 0.5
huntingChance[64] = 0.1
huntingChance[96] = 0.02
huntingChance[128] = 0.004
--[[
    Localized player radius were processing takes place in realtime, doesn't store state
    between calls.
    vs
    the slower passive version processing the entire map in multiple passes.
--]]
function mapProcessor.processPlayers(players, universe, tick)
    -- put down player pheromone for player hunters
    -- randomize player order to ensure a single player isn't singled out
    -- not looping everyone because the cost is high enough already in multiplayer
	local enemyForce = game.forces["enemy"]
	universe.chunkToPlayerCount = {}
    for i=1,#players do
        local player = players[i]
        if validPlayer(player) and enemyForce.is_enemy(player.force) then
            local playerCharacter = player.character
			if playerCharacter then 
				local map = universe.maps[playerCharacter.surface.index]
				if map then
					local chunk = getChunkByPosition(map, playerCharacter.position)
					if (chunk ~= -1) then
						universe.chunkToPlayerCount[chunk] = (universe.chunkToPlayerCount[chunk] or 0) + 1
					end
				end
			end	
        end
    end	
	
   if (#players > 0) then
        local player = players[mRandom(#players)]
        if validPlayer(player) and enemyForce.is_enemy(player.force) then
           local playerCharacter = player.character
			if playerCharacter then 
				local map = universe.maps[playerCharacter.surface.index]
				if map then
					local playerChunk = getChunkByPosition(map, playerCharacter.position)
					if (playerChunk ~= -1) then
						local roll = mRandom() 
						local allowingAttacks = canAttack(map, tick)
						local allowingVengence = (allowingAttacks or settings.global["rampantFixed--allowDaytimePlayerHunting"].value) and (map.points >= (AI_VENGENCE_SQUAD_COST*0))

						local forceVengence = (getEnemyStructureCount(map, playerChunk) > 0)

						for dx= 0, PROCESS_PLAYER_BOUND, 32 do
							for dy= 0, PROCESS_PLAYER_BOUND, 32 do
								local vengence = allowingVengence and (forceVengence or (roll < (huntingChance[mMax(dx, dy)] or 0.002)))
								for _, vector in pairs(xyVector) do									
									local x = playerChunk.x + dx*vector[1]
									local y = playerChunk.y - dy*vector[2]
									local chunk = getChunkByXY(map, x, y)
									if (chunk ~= -1) and (chunk[CHUNK_TICK] ~= tick) then
										chunk[CHUNK_TICK] = tick
										processPheromone(map, chunk, true)
										if (not chunk.nextHuntTick) or (chunk.nextHuntTick <= tick) then 
											if (getNestCount(map, chunk) > 0) then
												 processNestActiveness(map, chunk)
												 --queueNestSpawners(map, chunk, tick)		-- + !КДА too high cost. Lets just set "active"
												 
												if vengence then
													local count = map.vengenceQueue[chunk]
													if not count then
														count = 0
														map.vengenceQueue[chunk] = count
													end
													map.vengenceQueue[chunk] = count + 1
													chunk.nextHuntTick = tick + COOLDOWN_HUNT
												end
											end
										end	
									end
										--- compressed squads
									if (chunk ~= -1) then
										for _,squad in pairs(getSquadsOnChunk(map, chunk)) do
											local unitGroup = squad.group
											if squad.compressed and unitGroup and unitGroup.valid then
												squadDecompress(universe, map.surface, squad, nil, playerCharacter, true)
											end
										end
									end
										--- compressed squads
								end
							end
						end
					end
				end
			end	
		end
	end	
end

function mapProcessor.cleanUpMapTables(map, tick)
    local index = map.cleanupIndex

    local retreats = map.chunkToRetreats
    local rallys = map.chunkToRallys
    local drained = map.chunkToDrained
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local endIndex = mMin(index + CLEANUP_QUEUE_SIZE, processQueueLength)

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex do
        local chunk = processQueue[x]

        local retreatTick = retreats[chunk]
        if retreatTick and ((tick - retreatTick) > COOLDOWN_RETREAT) then
            retreats[chunk] = nil
        end

        local rallyTick = rallys[chunk]
        if rallyTick and ((tick - rallyTick) > COOLDOWN_RALLY) then
            rallys[chunk] = nil
        end

        local drainTick = drained[chunk]
        if drainTick and ((tick - drainTick) > 0) then
            drained[chunk] = nil
        end
    end

    if (endIndex == processQueueLength) then
        map.cleanupIndex = 1
    else
        map.cleanupIndex = endIndex + 1
    end
end

--[[
    Passive scan to find entities that have been generated outside the factorio event system
--]]
function mapProcessor.scanPlayerMap(map, tick)
    if (map.nextProcessMap == tick) or (map.nextPlayerScan == tick) or
        (map.nextEnemyScan == tick) or (map.nextChunkProcess == tick)
    then
        return
    end
    local index = map.scanPlayerIndex

    local area = map.universe.area
    local offset = area[2]
    local chunkBox = area[1]
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local endIndex = mMin(index + PLAYER_QUEUE_SIZE, processQueueLength)

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex do
        local chunk = processQueue[x]

        chunkBox[1] = chunk.x
        chunkBox[2] = chunk.y

        offset[1] = chunk.x + CHUNK_SIZE
        offset[2] = chunk.y + CHUNK_SIZE

        mapScanPlayerChunk(chunk, map)
    end

    if (endIndex == processQueueLength) then
        map.scanPlayerIndex = 1
    else
        map.scanPlayerIndex = endIndex + 1
    end
end

function mapProcessor.scanEnemyMap(map, tick)
    if (map.nextProcessMap == tick) or (map.nextPlayerScan == tick) or (map.nextChunkProcess == tick) then
        return
    end

    local index = map.scanEnemyIndex

    local area = map.universe.area
    local offset = area[2]
    local chunkBox = area[1]
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local endIndex = mMin(index + ENEMY_QUEUE_SIZE, #processQueue)

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex do
        local chunk = processQueue[x]

        chunkBox[1] = chunk.x
        chunkBox[2] = chunk.y

        offset[1] = chunk.x + CHUNK_SIZE
        offset[2] = chunk.y + CHUNK_SIZE

        mapScanEnemyChunk(chunk, map)
    end

    if (endIndex == processQueueLength) then
        map.scanEnemyIndex = 1
    else
        map.scanEnemyIndex = endIndex + 1
    end
end

function mapProcessor.scanResourceMap(map, tick)
    if (map.nextProcessMap == tick) or (map.nextPlayerScan == tick) or
        (map.nextEnemyScan == tick) or (map.nextChunkProcess == tick)
    then
        return
    end
    local index = map.scanResourceIndex

    local area = map.universe.area
    local offset = area[2]
    local chunkBox = area[1]
    local processQueue = map.processQueue
    local processQueueLength = #processQueue

    local endIndex = mMin(index + RESOURCE_QUEUE_SIZE, processQueueLength)

    if (processQueueLength == 0) then
        return
    end

    for x=index,endIndex do
        local chunk = processQueue[x]

        chunkBox[1] = chunk.x
        chunkBox[2] = chunk.y

        offset[1] = chunk.x + CHUNK_SIZE
        offset[2] = chunk.y + CHUNK_SIZE

        mapScanResourceChunk(chunk, map)
    end

    if (endIndex == processQueueLength) then
        map.scanResourceIndex = 1
    else
        map.scanResourceIndex = endIndex + 1
    end
end

function mapProcessor.processActiveNests(universe, tick)
    local processActiveNest = universe.processActiveNest
    local chunk = universe.processActiveNestIterator
    local chunkPack
    if not chunk then
        chunk, chunkPack = next(processActiveNest, nil)
    else
        chunkPack = processActiveNest[chunk]
    end
    if not chunk then
        universe.processActiveNestIterator = nil
    else
        universe.processActiveNestIterator = next(processActiveNest, chunk)
        if chunkPack.tick < tick  then
            local map = chunkPack.map
            if (not map) or (not map.surface.valid) then
                processActiveNest[chunk] = nil
                return
            end
            processNestActiveness(map, chunk)
            if (getNestActiveness(map, chunk) == 0) and (getRaidNestActiveness(map, chunk) == 0) then
                processActiveNest[chunk] = nil
            else
                chunkPack.tick = tick + DURATION_ACTIVE_NEST
            end
        end
    end
end


function mapProcessor.processVengence(map)
    local ss = map.vengenceQueue
    local chunk = map.deployVengenceIterator
    if not chunk then
        chunk = next(ss, nil)
    end
    if not chunk then
        map.deployVengenceIterator = nil
        if (tableSize(ss) == 0) then
            map.vengenceQueue = {}
        end
    else
        map.deployVengenceIterator = next(ss, chunk)
        formVengenceSquad(map, chunk)
        ss[chunk] = nil
    end
end

function mapProcessor.processNests(map, tick)
    local bases = map.chunkToBase
    local chunks = map.chunkToNests
    local chunk = next(chunks, map.processNestIterator)
	
    if not chunk then
        map.processNestIterator = nil
        return
    else
        processNestActiveness(map, chunk)
        queueNestSpawners(map, chunk, tick)

        if map.universe.NEW_ENEMIES then
            local base = bases[chunk]
            if base and base.thisIsRampantEnemy and ((tick - base.tick) > BASE_PROCESS_INTERVAL) then				
               processBase(chunk, map, tick, base)
            end
        end
    end
    map.processNestIterator = chunk
end


local function chooseSquad(map, migrate, attack)
	local settlementsProbability = settings.global["rampantFixed--settlementsProbability"].value
    if migrate and ((map.activeRaidNests == 0) or (mRandom()<settlementsProbability)) then		-- ((map.activeNests < 10) or (mRandom()<settlementsProbability)) 
		return "migrate"
	else
		return "attack"
	end
end

local function processSpawners(map, tick, iterator, chunks, remoteInterfaceParameters)
    local chunk = next(chunks, map[iterator])
    if not chunk then
		map[iterator] = nil
        return
    else
		local migrate = canMigrate(map)
		local attack = canAttack(map, tick)
		if not map.nextSquad then
			map.nextSquad = chooseSquad(map, migrate, attack) 
		end	
		local currentSquad = map.nextSquad
		if (currentSquad == "migrate") then
			if map.universe.builderCount >= map.universe.AI_MAX_BUILDER_COUNT then
				currentSquad = "attack"
			end
		elseif migrate and (map.universe.squadCount >= (map.universe.AI_MAX_SQUAD_COUNT*0.8)) then
			currentSquad = "migrate"			
		end		
		local squadCreated = false
		if remoteInterfaceParameters then
			currentSquad = "attack"
            squadCreated = formSquads(map, chunk, tick, remoteInterfaceParameters)
        elseif migrate and (currentSquad == "migrate") then
            squadCreated = formSettlers(map, chunk)
        elseif attack then
            squadCreated = formSquads(map, chunk, tick)
        end
		if squadCreated then
			if remoteInterfaceParameters then
				if settings.global["rampantFixed--aiPointsPrintSpendingToChat"].value then		
					game.print(currentSquad.." squad created by remote interface")
				end	
			else
				map.nextSquad = chooseSquad(map, migrate, attack)
				if settings.global["rampantFixed--aiPointsPrintSpendingToChat"].value then		
					game.print(currentSquad.." squad created. Next is "..map.nextSquad.." squad")
				end	
			end	
		end	
    end
    map[iterator] = chunk
end

function mapProcessor.processSpawners(map, tick, remoteInterfaceParameters)
    if (map.state ~= AI_STATE_PEACEFUL) then
        if (map.state == AI_STATE_MIGRATING) then
			if remoteInterfaceParameters or (map.nextSquad and (map.nextSquad == "attack")) then
				processSpawners(map,
							tick,
							"processActiveRaidSpawnerIterator",
							map.chunkToActiveRaidNest
							, remoteInterfaceParameters
							)
			else
				processSpawners(map,
							tick,
							"processMigrationIterator",
							map.chunkToNests
							, remoteInterfaceParameters
							)
			end					
        elseif (map.state == AI_STATE_AGGRESSIVE) or (map.state == AI_STATE_GROWING) then
			if  map.universe.raidAIToggle and (mRandom() < 0.2) then
				processSpawners(map,
                            tick,
                            "processActiveRaidSpawnerIterator",
                            map.chunkToActiveRaidNest
							, remoteInterfaceParameters
							)
			else
				processSpawners(map,
                            tick,
                            "processActiveSpawnerIterator",
                            map.chunkToActiveNest
							, remoteInterfaceParameters
							)
			end				
        elseif (map.state == AI_STATE_SIEGE) then
            processSpawners(map,
                            tick,
                            "processActiveSpawnerIterator",
                            map.chunkToActiveNest
							, remoteInterfaceParameters
							)
            processSpawners(map,
                            tick,
                            "processActiveRaidSpawnerIterator",
                            map.chunkToActiveRaidNest
							, remoteInterfaceParameters
							)
            processSpawners(map,
                            tick,
                            "processMigrationIterator",
                            map.chunkToNests
							, remoteInterfaceParameters
							)
        else
            processSpawners(map,
                            tick,
                            "processActiveSpawnerIterator",
                            map.chunkToActiveNest
							, remoteInterfaceParameters
							)
            processSpawners(map,
                            tick,
                            "processActiveRaidSpawnerIterator",
                            map.chunkToActiveRaidNest
							, remoteInterfaceParameters
							)
        end
    end
end

local querySpawners = {area={}, force="enemy", type={"turret", "unit-spawner"}}
-- growType = 0 - center
local function growChunk(map, base, chunk, growType)
	local growCenter
	if growType == 0 then
		local universe = map.universe
		querySpawners.area = {{chunk.x, chunk.y}, {chunk.x + 32, chunk.y + 32}}
		local entities = map.surface.find_entities_filtered(querySpawners)
		if #entities == 0 then
			return false
		end
		newEntity = baseUtils.upgradeEntity(entities[mRandom(#entities)], base.alignment, map, nil, true, true)
		if newEntity and newEntity.valid then
			chunk.growFails = nil
			registerEnemyBaseStructure(map, newEntity, base)
			-- game.print("Growing chunk: [gps=" .. newEntity.position.x .. "," .. newEntity.position.y .."] ".. newEntity.name)	-- debug
			return true
		else	
			chunk.growFails = (chunk.growFails or 0) + 1
			-- game.print("Growing chunk: [gps=" .. chunk.x .. "," .. chunk.y .."], can't place "..chunk.growFails.."/5")	-- debug
		end
		
	end
	return false
end

function mapProcessor.processGrowingBases(universe, tick)
	local growingBases = universe.growingBases
	local baseId
	if universe.growingBasesIterator and growingBases[universe.growingBasesIterator] then
		baseId = next(growingBases, nil)
	else
		baseId = next(growingBases, universe.growingBasesIterator)
	end
	
    if not baseId then
        universe.growingBasesIterator = nil
        return
	end	
	local growingData = growingBases[baseId]	
	if not growingData then
		return
	end
	local base = universe.bases[baseId]
    if not base then
		universe.growingBases[baseId] = nil
        universe.growingBasesIterator = nil
        return
	end	
	local map = universe.maps[base.mapIndex]
    if not map then
		universe.growingBases[baseId] = nil
        universe.growingBasesIterator = nil
        return	
	end
	local surface = map.surface
	if not surface then
		return
	end
	-- if map.state ~= AI_STATE_GROWING then
		-- return
	-- end	
	
    universe.growingBasesIterator = baseId
	
	if growingData.tick > tick then
		return
	end
	
	local growed = false
	local chunksCount = 0
	local activeChunks = 0
	local chunksArray = {}
	for chunk, _ in pairs(base.chunks) do
		local nestCount = getNestCount(map, chunk) + getHiveCount(map, chunk)
		local turretCount = getTurretCount(map, chunk)
		chunksCount = chunksCount + 1
		if (getNestActiveness(map, chunk) > 0) then
			activeChunks = activeChunks + 1
		end
		if baseUtils.chunkCanGrow(map, chunk) then
			chunksArray[#chunksArray+1] = chunk
			-- if not growed then
			-- -- if growingData.nests and (growingData.nests>0) then
				-- -- growChunk(map, base, chunk, 1)
				-- -- growingData.nests = growingData.nests - 1
			-- -- elseif growingData.worms and (growingData.worms>0) then	
				-- -- growChunk(map, base, chunk, 2)
				-- -- growingData.worms = growingData.worms - 1
			-- -- else
				-- growed = growChunk(map, base, chunk, 0)
			-- -- end
			-- end
			surface.create_trivial_smoke({name = "growing-dust-nonTriggerCloud-rampant", position = {chunk.x + 16, chunk.y + 16}})
		end		
	end
	
	if #chunksArray > 0 then
		growed = growChunk(map, base, chunksArray[mRandom(#chunksArray)], 0)
	end	
	
	if not growed then
		base.growFails = (base.growFails or 0) + 1
		-- game.print("base fail to grow: #"..base.id.." try # = "..base.growFails)	-- debug
		if (base.growFails > 5) or (activeChunks == 0) or (chunksCount >= 6)  then
			-- game.print("base stop growing: #"..base.id.." activeChunks = "..activeChunks..", growFails =".. base.growFails..", chunksCount = "..chunksCount)	-- debug
			universe.growingBases[baseId] = nil
			universe.growingBasesIterator = nil
		end					
	else
		base.growFails = nil
	end
	growingData.tick = tick + GROWING_COOLDOWN

end


function mapProcessor.suspendClearedMaps(universe, tick)
	local map
	if not universe.suspendMapsIterator then
		universe.suspendMapsIterator, map = next(universe.maps, nil)
	else
		map = universe.maps[universe.suspendMapsIterator]
	end	
	if (not map) or (not map.surface) then
		if map and (not map.suspended) then
			map.suspended = true
			map.suspendCheckTick = tick	
		end	
		universe.suspendMapsIterator, map = next(universe.maps, universe.suspendMapsIterator)
		return
	end
	
	if map.surface.name == "nauvis" then	
	else
		if not map.suspended then
			if (map.activeRaidNests < 1) and (tick - (map.suspendCheckTick or 0) > 3600)then
				local enemySpawners = map.surface.count_entities_filtered({force = "enemy", type = "unit-spawner", limit = 1})
				if enemySpawners == 0 then
					map.suspended = true
					--game.print("suspend clear surface:"..map.surface.name)	-- debug map.suspended
				end
				map.suspendCheckTick = tick		
			end	
		end
	end
	universe.suspendMapsIterator, map = next(universe.maps, universe.suspendMapsIterator)
end

mapProcessorG = mapProcessor
return mapProcessor
