if (chunkProcessorG) then
    return chunkProcessorG
end
local chunkProcessor = {}

-- imports

local chunkUtils = require("ChunkUtils")
local mathUtils = require("MathUtils")
local constants = require("Constants")
local baseUtils = require("BaseUtils")

-- constants

local CHUNK_SIZE = constants.CHUNK_SIZE

local MAX_TICKS_BEFORE_SORT_CHUNKS = constants.MAX_TICKS_BEFORE_SORT_CHUNKS

-- imported functions

local mapScanEnemyChunk = chunkUtils.mapScanEnemyChunk
local mapScanPlayerChunk = chunkUtils.mapScanPlayerChunk
local mapScanResourceChunk = chunkUtils.mapScanResourceChunk

local createChunk = chunkUtils.createChunk
local initialScan = chunkUtils.initialScan
local chunkPassScan = chunkUtils.chunkPassScan

local euclideanDistanceNamed = mathUtils.euclideanDistanceNamed

local changeEntityAndUpdateDynamicRates = baseUtils.changeEntityAndUpdateDynamicRates
local getDynamicRates = baseUtils.getDynamicRates 

local tSort = table.sort

local abs = math.abs
local next = next
local table_size = table_size

local tRemove = table.remove

-- module code

local origin = {x=0,y=0}

local function sorter(a, b)
    local aDistance = euclideanDistanceNamed(a, origin)
    local bDistance = euclideanDistanceNamed(b, origin)

    if (aDistance == bDistance) then
        if (a.x == b.x) then
            return (abs(a.y) < abs(b.y))
        else
            return (abs(a.x) < abs(b.x))
        end
    end

    return (aDistance < bDistance)
end

function chunkProcessor.processPendingChunks(universe, tick, flush)
    local pendingChunks = universe.pendingChunks

    local area = universe.area
    local topOffset = area[1]
    local bottomOffset = area[2]

    local endCount = 2
	local chunkCount = 0
    -- if flush then
        -- endCount = table_size(pendingChunks)
    -- end
	for event, _ in pairs(pendingChunks) do
		local map = event.surface.valid and universe.maps[event.surface.index]
		if map then
			chunkCount = chunkCount + 1
            local topLeft = event.area.left_top
            local x = topLeft.x
            local y = topLeft.y

			topOffset[1] = x
			topOffset[2] = y
			bottomOffset[1] = x + CHUNK_SIZE
			bottomOffset[2] = y + CHUNK_SIZE

            if map[x] and map[x][y] then
                local chunk = map[x][y]
                mapScanPlayerChunk(chunk, map)
                mapScanEnemyChunk(chunk, map)
                mapScanResourceChunk(chunk, map)
            else
                if map[x] == nil then
                    map[x] = {}
                end

                local chunk = createChunk(x, y)

                chunk = initialScan(chunk, map, tick)

                if (chunk ~= -1) then	
                    map[x][y] = chunk
					local processQueue = map.processQueue
                    processQueue[#processQueue+1] = chunk
                end
            end
		end	
        pendingChunks[event] = nil
		if (not flush) and (chunkCount >= endCount) then
			break
		end	
    end
    -- if (#processQueue > map.nextChunkSort) or
        -- (((tick - map.nextChunkSortTick) > MAX_TICKS_BEFORE_SORT_CHUNKS) and
                -- ((map.nextChunkSort - 150) < #processQueue))
    -- then
        -- map.nextChunkSort = #processQueue + 150
        -- map.nextChunkSortTick = tick
        -- tSort(processQueue, sorter)
    -- end
end

function chunkProcessor.processScanChunks(universe)
    local area = universe.area

    local topOffset = area[1]
    local bottomOffset = area[2]

    --local removals = map.chunkRemovals

    local endCount = 2
    local chunkCount = 0

    local chunkToPassScan = universe.chunkToPassScan

    for chunkIndex, chunkData in pairs(chunkToPassScan) do
        local x = chunkData[1]
        local y = chunkData[2]
        local map = universe.maps[chunkData[3]]
		if map then

			topOffset[1] = x
			topOffset[2] = y
			bottomOffset[1] = x + CHUNK_SIZE
			bottomOffset[2] = y + CHUNK_SIZE

			local preScanChunk = map[x] and map[x][y]
			if not preScanChunk or (chunkPassScan(preScanChunk, map) == -1) then
				map[x][y] = nil
				-- removals[chunkCount] = preScanChunk
			end

			chunkCount = chunkCount + 1
			chunkToPassScan[chunkIndex] = nil
			if chunkCount >= endCount then
				break
			end	
		else	
			chunkToPassScan[chunkIndex] = nil
		end	
    end

    -- if (chunkCount > 0) then
        -- local processQueue = map.processQueue
        -- for i=#processQueue,1,-1 do
            -- for ri=chunkCount,1,-1 do
                -- if (removals[ri] == processQueue[i]) then
                    -- tRemove(processQueue, i)
                    -- -- tRemove(removals, ri)
                    -- break
                -- end
            -- end
        -- end
    -- end
end

function chunkProcessor.processPendingMutations(universe)
	local pendingChunks = universe.pendingMutations["chunks"]
 	local pendingEntities = universe.pendingMutations["entities"]
    local entityId = universe.pendingMutationsIterator
    local entityData
    if not entityId then
        entityId, entityData = next(pendingEntities, nil)
    else
        entityData = pendingEntities[entityId]
    end
	
    if not entityId then
        universe.pendingMutationsIterator = nil
		return
	end	
	
	local dynamicRates 
	local base
	local map
	
	local processedCnt = 0	
	local mutatesCnt = 0	
	local maxMutations = 1
	while entityId and (maxMutations > mutatesCnt) and (processedCnt < 100) do
		local entityValid
		local chunkIndex = entityData.chunkIndex
		map = universe.maps[entityData.surfaceIndex]
		entityValid = entityData.entity.valid and entityData.base and map
		if entityValid then
			if not base or (base ~= entityData.base) then
				base = entityData.base 
				dynamicRates = getDynamicRates(base) 	
			end
			newBuilding = changeEntityAndUpdateDynamicRates(entityData.entity, dynamicRates, map, base)			
			if newBuilding then
				mutatesCnt = mutatesCnt + 1
			end
		end
		processedCnt = processedCnt + 1
				
		pendingEntities[entityId] = nil
		pendingChunks[chunkIndex] = pendingChunks[chunkIndex] - 1
		
		entityId, entityData = next(pendingEntities, entityId)
	end
	
	local pendingEntities_left = table_size(pendingEntities)
	if pendingEntities_left == 0 then
		universe.pendingMutationsIterator = nil

		universe.pendingMutations = {
		["chunks"] = {},			
		["entities"] = {}
		}
	else	
		universe.pendingMutationsIterator = entityId
	end
end


chunkProcessorG = chunkProcessor
return chunkProcessor
