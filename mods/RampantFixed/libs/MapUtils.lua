if mapUtilsG then
    return mapUtilsG
end
local mapUtils = {}

-- imports

local constants = require("Constants")
local chunkPropertyUtils = require("ChunkPropertyUtils")

-- constants

local CHUNK_NORTH_SOUTH = constants.CHUNK_NORTH_SOUTH
local CHUNK_EAST_WEST = constants.CHUNK_EAST_WEST
local CHUNK_IMPASSABLE = constants.CHUNK_IMPASSABLE
local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS

-- local PASSABLE = constants.PASSABLE

local CHUNK_SIZE = constants.CHUNK_SIZE

local CHUNK_SIZE_DIVIDER = constants.CHUNK_SIZE_DIVIDER

-- imported functions

local mFloor = math.floor
local getPassable = chunkPropertyUtils.getPassable

-- module code

function mapUtils.getChunkByXY(map, x, y)
    local chunkX = map[x]
    if chunkX then
        return chunkX[y] or -1
    end
    return -1
end

function mapUtils.getChunkByPosition(map, position)
    local chunkX = map[mFloor(position.x * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE]
    if chunkX then
        return chunkX[mFloor(position.y * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE] or -1
    end
    return -1
end

function mapUtils.positionToChunkXY(position)
    local chunkX = mFloor(position.x * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
    local chunkY = mFloor(position.y * CHUNK_SIZE_DIVIDER) * CHUNK_SIZE
    return chunkX, chunkY
end

function mapUtils.getChunkListInRange(map, x, y, range)
	local chunkList = {}
	for dx = -range * CHUNK_SIZE, range * CHUNK_SIZE, CHUNK_SIZE do
		local xChunks = map[x + dx]
		if xChunks then
			for dy = -range * CHUNK_SIZE, range * CHUNK_SIZE, CHUNK_SIZE do
				if not ((dx == 0) and (dy == 0)) and xChunks[y + dy] then
					chunkList[#chunkList+1] = xChunks[y + dy]
				end
			end
		end
	end
	return chunkList
end

function mapUtils.removeChunkFromMap(map, chunk)
    local x = chunk.x
    local y = chunk.y

    if not map[x][y] then
        return
    end
	local universe = map.universe
    map[x][y] = nil

	local chunkData = {chunk.x, chunk.y, map.surface.index}
	local chunkIndex = "x"..chunkData[1].."y"..chunkData[2].."m"..chunkData[3]
    universe.chunkToPassScan[chunkIndex] = nil
	
	chunkPropertyUtils.setNestActiveTick(map, chunk, 0)
	
    chunkPropertyUtils.setNestActiveness(map, chunk, 0)		-- map.chunkToActiveNest[chunk] = nil
    chunkPropertyUtils.setRaidNestActiveness(map, chunk, 0)	-- map.chunkToActiveRaidNest[chunk] = nil
    chunkPropertyUtils.removeChunkBase(map, chunk, nil)		-- map.chunkToBase[chunk] = nil
    map.chunkToDeathGenerator[chunk] = nil
    map.chunkToDrained[chunk] = nil
    chunkPropertyUtils.setHiveCount(map, chunk, 0)			-- map.chunkToHives[chunk] = nil
    chunkPropertyUtils.setNestCount(map, chunk, 0)			-- map.chunkToNests[chunk] = nil
    map.chunkToPassable[chunk] = nil
    map.chunkToPathRating[chunk] = nil
    map.chunkToPlayerBase[chunk] = nil
    map.chunkToPlayerBaseDetection[chunk] = nil
    chunkPropertyUtils.setPlayerTurretCount(map, chunk, 0)	-- map.chunkToPlayerTurrets[chunk] = nil
    map.chunkToRallys[chunk] = nil
    map.chunkToResource[chunk] = nil
    map.chunkToRetreats[chunk] = nil
    chunkPropertyUtils.removeSquadsFromChunk(map, chunk)	-- map.chunkToSquad[chunk] = nil
    chunkPropertyUtils.setTrapCount(map, chunk, 0)			-- map.chunkToTraps[chunk] = nil
    chunkPropertyUtils.setNestCount(map, chunk, 0)			-- map.chunkToTurrets[chunk] = nil
    chunkPropertyUtils.setUtilityCount(map, chunk, 0)		-- map.chunkToUtilities[chunk] = nil
    map.chunkToVictory[chunk] = nil
	

    if map.processNestIterator == chunk then
        map.processNestIterator = nil
    end
    if map.processActiveSpawnerIterator == chunk then
        map.processActiveSpawnerIterator = nil
    end
    if map.processActiveRaidSpawnerIterator == chunk then
        map.processActiveRaidSpawnerIterator = nil
    end
    if map.processMigrationIterator == chunk then
        map.processMigrationIterator = nil
    end
end

--[[
    1 2 3
    \|/
    4- -5
    /|\
    6 7 8
]]--
function mapUtils.getNeighborChunks(map, x, y)
    local neighbors = map.universe.neighbors
    local chunkYRow1 = y - CHUNK_SIZE
    local chunkYRow3 = y + CHUNK_SIZE
    local xChunks = map[x-CHUNK_SIZE]
    if xChunks then
        neighbors[1] = xChunks[chunkYRow1] or -1
        neighbors[4] = xChunks[y] or -1
        neighbors[6] = xChunks[chunkYRow3] or -1
    else
        neighbors[1] = -1
        neighbors[4] = -1
        neighbors[6] = -1
    end

    xChunks = map[x+CHUNK_SIZE]
    if xChunks then
        neighbors[3] = xChunks[chunkYRow1] or -1
        neighbors[5] = xChunks[y] or -1
        neighbors[8] = xChunks[chunkYRow3] or -1
    else
        neighbors[3] = -1
        neighbors[5] = -1
        neighbors[8] = -1
    end

    xChunks = map[x]
    if xChunks then
        neighbors[2] = xChunks[chunkYRow1] or -1
        neighbors[7] = xChunks[chunkYRow3] or -1
    else
        neighbors[2] = -1
        neighbors[7] = -1
    end
    return neighbors
end


--[[
    1 2 3
    \|/
    4- -5
    /|\
    6 7 8
]]--
function mapUtils.canMoveChunkDirection(map, direction, startChunk, endChunk)
    local canMove = false
    local startPassable = getPassable(map, startChunk)
    local endPassable = getPassable(map, endChunk)
    -- print(direction, startPassable, endPassable)
    if (startPassable == CHUNK_ALL_DIRECTIONS) then
        if ((direction == 1) or (direction == 3) or (direction == 6) or (direction == 8)) then
            canMove = (endPassable == CHUNK_ALL_DIRECTIONS)
        elseif (direction == 2) or (direction == 7) then
            canMove = ((endPassable == CHUNK_NORTH_SOUTH) or (endPassable == CHUNK_ALL_DIRECTIONS))
        elseif (direction == 4) or (direction == 5) then
            canMove = ((endPassable == CHUNK_EAST_WEST) or (endPassable == CHUNK_ALL_DIRECTIONS))
        end
    elseif (startPassable == CHUNK_NORTH_SOUTH) then
        if ((direction == 1) or (direction == 3) or (direction == 6) or (direction == 8)) then
            canMove = (endPassable == CHUNK_ALL_DIRECTIONS)
        elseif (direction == 2) or (direction == 7) then
            canMove = ((endPassable == CHUNK_NORTH_SOUTH) or (endPassable == CHUNK_ALL_DIRECTIONS))
        end
    elseif (startPassable == CHUNK_EAST_WEST) then
        if ((direction == 1) or (direction == 3) or (direction == 6) or (direction == 8)) then
            canMove = (endPassable == CHUNK_ALL_DIRECTIONS)
        elseif (direction == 4) or (direction == 5) then
            canMove = ((endPassable == CHUNK_EAST_WEST) or (endPassable == CHUNK_ALL_DIRECTIONS))
        end
    else
        canMove = (endPassable ~= CHUNK_IMPASSABLE)
    end
    return canMove
end

function mapUtils.getCardinalChunks(map, x, y)
    local neighbors = map.universe.cardinalNeighbors
    local xChunks = map[x]
    if xChunks then
        neighbors[1] = xChunks[y-CHUNK_SIZE] or -1
        neighbors[4] = xChunks[y+CHUNK_SIZE] or -1
    else
        neighbors[1] = -1
        neighbors[4] = -1
    end

    xChunks = map[x-CHUNK_SIZE]
    if xChunks then
        neighbors[2] = xChunks[y] or -1
    else
        neighbors[2] = -1
    end

    xChunks = map[x+CHUNK_SIZE]
    if xChunks then
        neighbors[3] = xChunks[y] or -1
    else
        neighbors[3] = -1
    end
    return neighbors
end

function mapUtils.positionFromDirectionAndChunk(direction, startPosition, endPosition, scaling)
    if (direction == 1) then
        endPosition.x = startPosition.x - CHUNK_SIZE * (scaling - 0.1)
        endPosition.y = startPosition.y - CHUNK_SIZE * (scaling - 0.1)
    elseif (direction == 2) then
        endPosition.x = startPosition.x
        endPosition.y = startPosition.y - CHUNK_SIZE * (scaling + 0.25)
    elseif (direction == 3) then
        endPosition.x = startPosition.x + CHUNK_SIZE * (scaling - 0.1)
        endPosition.y = startPosition.y - CHUNK_SIZE * (scaling - 0.1)
    elseif (direction == 4) then
        endPosition.x = startPosition.x - CHUNK_SIZE * (scaling + 0.25)
        endPosition.y = startPosition.y
    elseif (direction == 5) then
        endPosition.x = startPosition.x + CHUNK_SIZE * (scaling + 0.25)
        endPosition.y = startPosition.y
    elseif (direction == 6) then
        endPosition.x = startPosition.x - CHUNK_SIZE * (scaling - 0.1)
        endPosition.y = startPosition.y + CHUNK_SIZE * (scaling - 0.1)
    elseif (direction == 7) then
        endPosition.x = startPosition.x
        endPosition.y = startPosition.y + CHUNK_SIZE * (scaling + 0.25)
    elseif (direction == 8) then
        endPosition.x = startPosition.x + CHUNK_SIZE * (scaling - 0.1)
        endPosition.y = startPosition.y + CHUNK_SIZE * (scaling - 0.1)
    end
    return endPosition
end

function mapUtils.positionFromDirectionAndFlat(direction, startPosition, endPosition)
    local lx = startPosition.x
    local ly = startPosition.y
    if (direction == 1) then
        lx = lx - CHUNK_SIZE
        ly = ly - CHUNK_SIZE
    elseif (direction == 2) then
        ly = ly - CHUNK_SIZE
    elseif (direction == 3) then
        lx = lx + CHUNK_SIZE
        ly = ly - CHUNK_SIZE
    elseif (direction == 4) then
        lx = lx - CHUNK_SIZE
    elseif (direction == 5) then
        lx = lx + CHUNK_SIZE
    elseif (direction == 6) then
        lx = lx - CHUNK_SIZE
        ly = ly + CHUNK_SIZE
    elseif (direction == 7) then
        ly = ly + CHUNK_SIZE
    elseif (direction == 8) then
        lx = lx + CHUNK_SIZE
        ly = ly + CHUNK_SIZE
    end
    endPosition.x = lx
    endPosition.y = ly
end

mapUtilsG = mapUtils
return mapUtils
