if (chunkProcessorG) then
    return chunkProcessorG
end
local chunkProcessor = {}

-- imports

local chunkUtils = require("ChunkUtils")
local constants = require("Constants")
local baseUtils = require("BaseUtils")
local mapUtils = require("MapUtils")
local chunkQueue = require("ChunkQueue")
local CHUNK_SIZE = constants.CHUNK_SIZE
local changeEntityAndUpdateDynamicRates = baseUtils.changeEntityAndUpdateDynamicRates
local getDynamicRates = baseUtils.getDynamicRates

function chunkProcessor.queueGeneratedChunk(map, x, y)
    local key = "x"..x.."y"..y.."m"..map.surface.index
    map.universe.pendingChunks[key] = {x = x, y = y, map = map}
end

function chunkProcessor.cancelGeneratedChunk(map, x, y)
    local key = "x"..x.."y"..y.."m"..map.surface.index
    map.universe.pendingChunks[key] = nil
end

function chunkProcessor.queuePassScan(map, chunk)
    local key = "x"..chunk.x.."y"..chunk.y.."m"..map.surface.index
    map.universe.chunkToPassScan[key] = {chunk.x, chunk.y, map.surface.index, chunk}
end

local function scanGenerated(map, x, y, tick, refresh)
    local area = map.universe.area
    local top, bottom = area[1], area[2]
    top[1], top[2] = x, y
    bottom[1], bottom[2] = x + CHUNK_SIZE, y + CHUNK_SIZE
    local chunk = mapUtils.getChunkByXY(map, x, y)
    if chunk ~= -1 then
        if refresh then
            chunkUtils.mapScanPlayerChunk(chunk, map)
            chunkUtils.mapScanEnemyChunk(chunk, map)
            chunkUtils.mapScanResourceChunk(chunk, map)
        end
    else
        local fresh = chunkUtils.createChunk(x, y)
        chunk = chunkUtils.initialScan(fresh, map, tick)
        if chunk == -1 then
            mapUtils.discardChunkState(map, fresh)
        else
            local column = map[x]
            if not column then
                column = {}
                map[x] = column
            end
            column[y] = chunk
            chunkQueue.append(map, chunk)
        end
    end
end

function chunkProcessor.indexExistingChunks(map, tick)
    if not map.indexing then return end
    local iterator = map.chunkIterator
    if not (iterator and iterator.valid) then
        iterator = map.surface.get_chunks()
        map.chunkIterator = iterator
    end
    for _ = 1, 8 do
        local position = iterator()
        if not position then
            map.chunkIterator, map.indexing = nil, nil
            return
        end
        local x, y = position.x * CHUNK_SIZE, position.y * CHUNK_SIZE
        if map.surface.is_chunk_generated(position) then
            -- on_chunk_generated, if pending, owns the delayed RSO scan.
            local key = "x"..x.."y"..y.."m"..map.surface.index
            local pending = map.universe.pendingChunks[key]
            if not pending or pending.map ~= map then scanGenerated(map, x, y, tick, false) end
        end
    end
end

function chunkProcessor.processPendingChunks(universe, tick)
    local pending = universe.pendingChunks
    local visited = 0
    for key, data in pairs(pending) do
        local map, x, y
        if type(key) == "table" then -- generated events persisted by older versions
            local surface = key.surface
            map = surface and surface.valid and universe.maps[surface.index]
            x, y = key.area.left_top.x, key.area.left_top.y
        else
            map, x, y = data.map, data.x, data.y
        end
        pending[key] = nil
        if map and map.surface and map.surface.valid and universe.maps[map.surface.index] == map
                and map.surface.is_chunk_generated({x / CHUNK_SIZE, y / CHUNK_SIZE}) then
            scanGenerated(map, x, y, tick, true)
        end
        visited = visited + 1
        if visited >= 2 then break end
    end
end

function chunkProcessor.processScanChunks(universe)
    local area = universe.area
    local top, bottom = area[1], area[2]
    local visited = 0
    local pending = universe.chunkToPassScan
    for key, data in pairs(pending) do
        pending[key] = nil
        if type(data) == "table" then
            local x, y = data[1], data[2]
            local map = universe.maps[data[3]]
            local chunk = map and mapUtils.getChunkByXY(map, x, y)
            if chunk and chunk ~= -1 and (not data[4] or data[4] == chunk) then
                top[1], top[2] = x, y
                bottom[1], bottom[2] = x + CHUNK_SIZE, y + CHUNK_SIZE
                if chunkUtils.chunkPassScan(chunk, map) == -1 then
                    mapUtils.removeChunkFromMap(map, chunk)
                end
            end
        end
        visited = visited + 1
        if visited >= 2 then break end
    end
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
		entityValid = entityData.entity and entityData.entity.valid and entityData.base and map
            and (not entityData.chunk or chunkQueue.isLive(map, entityData.chunk))
		if entityValid then
			if not base or (base ~= entityData.base) then
				base = entityData.base 
				dynamicRates = getDynamicRates(base) 	
			end
			local newBuilding = changeEntityAndUpdateDynamicRates(entityData.entity, dynamicRates, map, base)
			if newBuilding then
				mutatesCnt = mutatesCnt + 1
			end
		end
		processedCnt = processedCnt + 1
				
		pendingEntities[entityId] = nil
		local remaining = (pendingChunks[chunkIndex] or 1) - 1
        pendingChunks[chunkIndex] = remaining > 0 and remaining or nil
		
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
