if movementUtilsG then
    return movementUtilsG
end
local movementUtils = {}

-- imports

local constants = require("Constants")
local mapUtils = require("MapUtils")
local mathUtils = require("MathUtils")
local pheromoneUtils = require("PheromoneUtils")

local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE

-- constants

local MAGIC_MAXIMUM_NUMBER = constants.MAGIC_MAXIMUM_NUMBER

-- imported functions

local canMoveChunkDirection = mapUtils.canMoveChunkDirection
local getNeighborChunks = mapUtils.getNeighborChunks

local tableRemove = table.remove
local tableInsert = table.insert

local distortPosition = mathUtils.distortPosition

-- module code

function movementUtils.findMovementPosition(surface, position)
    local pos = position
    pos = surface.find_non_colliding_position("chunk-scanner-squad-movement-rampant", pos, 10, 2, false)
    return pos
end

function movementUtils.findMovementPositionEntity(entityName, surface, position)
    local pos = position
    pos = surface.find_non_colliding_position(entityName, pos, 5, 4, true)
    return pos
end

function movementUtils.findMovementPositionDistort(surface, position)
    local pos = position
    pos = surface.find_non_colliding_position("chunk-scanner-squad-movement-rampant", pos, 10, 2, false)
    return distortPosition(pos, 8)
end

function movementUtils.addMovementPenalty(squad, chunk)
    if (chunk == -1) then
        return
    end
    local penalties = squad.penalties
    local penaltyCount = #penalties
    for i=1,penaltyCount do
        local penalty = penalties[i]
        if (penalty.c == chunk) then
            penalty.v = penalty.v + 1
            if (penalty.v > 4) then
                squad.kamikaze = true
            end
            return
        end
    end
    if (penaltyCount == 10) then
        tableRemove(penalties, 10)
    end
    tableInsert(penalties,
                1,
                { v = 1,
                  c = chunk })
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForAttack(map, chunk, neighborDirectionChunks, scoreFunction)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection

    for x=1,8 do
        local neighborChunk = neighborDirectionChunks[x]
        if (neighborChunk ~= -1) then
            if canMoveChunkDirection(map, x, chunk, neighborChunk) or (chunk == -1) then
                local score = scoreFunction(map, neighborChunk)
                if (score > highestScore) then
                    highestScore = score
                    highestChunk = neighborChunk
                    highestDirection = x
                end
            end
        end
    end
	
	local currentScore
	if chunk ~=-1 then
		local currentScore = scoreFunction(map, chunk)
		if currentScore >= highestScore then
			pheromoneUtils.processStaticPheromone(map, chunk, {recursion = true, color = {1, 1, 1}})
		end	
	end

    local nextHighestChunk = -1
    local nextHighestScore = highestScore
    local nextHighestDirection

    if (highestChunk ~= -1) then
        neighborDirectionChunks = getNeighborChunks(map, highestChunk.x, highestChunk.y)
        for x=1,8 do
            local neighborChunk = neighborDirectionChunks[x]
            if ((neighborChunk ~= -1) and (neighborChunk ~= chunk) and
                canMoveChunkDirection(map, x, highestChunk, neighborChunk)) then
                local score = scoreFunction(map, neighborChunk)
                if (score > nextHighestScore) then
                    nextHighestScore = score
                    nextHighestChunk = neighborChunk
                    nextHighestDirection = x
                end
            end
        end
    end

    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end
-- function movementUtils.scoreNeighborsForAttack(map, chunk, neighborDirectionChunks, scoreFunction)
    -- local highestChunk 		--= -1
    -- local highestScore 		--= -MAGIC_MAXIMUM_NUMBER
    -- local highestDirection
	
	-- local currentScore = 0
	-- for step = 1, 2 do
		-- highestChunk = -1
		-- highestScore = -MAGIC_MAXIMUM_NUMBER
		-- highestDirection = nil
		-- for n=1,8 do
			-- local neighborChunk = neighborDirectionChunks[n]
			-- if (neighborChunk ~= -1) then
				-- if canMoveChunkDirection(map, n, chunk, neighborChunk) or (chunk == -1) then
					-- local score
					-- if step == 2 then
						-- score = neighborChunk[BASE_DETECTION_PHEROMONE]
					-- else
						-- score = scoreFunction(map, neighborChunk)
					-- end
					-- if (score > highestScore) then
						-- highestScore = score
						-- highestChunk = neighborDirectionChunks[n]
						-- highestDirection = n
					-- end
				-- end
			-- end
		-- end
		-- if chunk ~=-1 then
			-- if (step == 2) then
				-- currentScore = chunk[BASE_DETECTION_PHEROMONE]
			-- else	
				-- currentScore = scoreFunction(map, chunk)
			-- end
		-- end
		-- if currentScore < highestScore then
			-- break
		-- else
			-- if step == 2 then
				-- if chunk ~=-1 then
					-- -- pheromoneUtils.multiplyPheromones(map, chunk, 0.1, {1, 1, 1})
					-- for n=1,8 do
						-- local neighborChunk = neighborDirectionChunks[n]
						-- if (neighborChunk ~= -1) then
							-- if (neighborChunk[BASE_DETECTION_PHEROMONE]*4) > chunk[BASE_DETECTION_PHEROMONE] then
								-- pheromoneUtils.multiplyPheromones(map, neighborChunk, 0.1, {0.5, 0.5, 0.5})
							-- end	
						-- end
					-- end	
					-- pheromoneUtils.processStaticPheromone(map, chunk, {recursion = true, color = {1, 1, 1}})
				-- end	
			-- end	
		-- end
	-- end	

    -- local nextHighestChunk = -1
    -- local nextHighestScore = highestScore
    -- local nextHighestDirection

    -- -- if (highestChunk ~= -1) then
        -- -- local nextNeighborDirectionChunks = getNeighborChunks(map, highestChunk.x, highestChunk.y)
        -- -- for n=1,8 do
            -- -- local neighborChunk = nextNeighborDirectionChunks[n]
            -- -- if ((neighborChunk ~= -1) and (neighborChunk ~= chunk) and
                -- -- canMoveChunkDirection(map, n, highestChunk, neighborChunk)) then
                -- -- local score = scoreFunction(map, neighborChunk)
                -- -- if (score > nextHighestScore) then
                    -- -- nextHighestScore = score
                    -- -- nextHighestChunk = neighborChunk
                    -- -- nextHighestDirection = n
                -- -- end
            -- -- end
        -- -- end
    -- -- end

    -- return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
-- end


--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForSettling(map, chunk, neighborDirectionChunks, scoreFunction)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection = 0

    for x=1,8 do
        local neighborChunk = neighborDirectionChunks[x]
        if (neighborChunk ~= -1) then
            if canMoveChunkDirection(map, x, chunk, neighborChunk) or (chunk == -1) then
                local score = scoreFunction(map, neighborChunk)
                if (score > highestScore) then
                    highestScore = score
                    highestChunk = neighborChunk
                    highestDirection = x
                end
            end
        end
    end

    if (chunk ~= -1) and (scoreFunction(map, chunk) > highestScore) then
        return chunk, 0, -1, 0
    end

    local nextHighestChunk = -1
    local nextHighestScore = highestScore
    local nextHighestDirection = 0

    if (highestChunk ~= -1) then
        local nextNeighborDirectionChunks = getNeighborChunks(map, highestChunk.x, highestChunk.y)
        for x=1,8 do
            local neighborChunk = nextNeighborDirectionChunks[x]
            if ((neighborChunk ~= -1) and (neighborChunk ~= chunk) and
                canMoveChunkDirection(map, x, highestChunk, neighborChunk)) then
                local score = scoreFunction(map, neighborChunk)
                if (score > nextHighestScore) then
                    nextHighestScore = score
                    nextHighestChunk = neighborChunk
                    nextHighestDirection = x
                end
            end
        end
    end

    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForResource(chunk, neighborDirectionChunks, validFunction, scoreFunction, map)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection
    for x=1,8 do
        local neighborChunk = neighborDirectionChunks[x]
        if (neighborChunk ~= -1) and
            canMoveChunkDirection(map, x, chunk, neighborChunk) and
            validFunction(map, neighborChunk)
        then
            local score = scoreFunction(map, neighborChunk)
            if (score > highestScore) then
                highestScore = score
                highestChunk = neighborChunk
                highestDirection = x
            end
        end
    end

    if (chunk ~= -1) and (scoreFunction(map, chunk) > highestScore) then
        return -1, -1
    end

    return highestChunk, highestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForRetreat(chunk, neighborDirectionChunks, scoreFunction, map)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection

    for x=1,8 do
        local neighborChunk = neighborDirectionChunks[x]
        if (neighborChunk ~= -1) then
            if canMoveChunkDirection(map, x, chunk, neighborChunk) or (chunk == -1) then
                local score = scoreFunction(map, neighborChunk)
                if (score > highestScore) then
                    highestScore = score
                    highestChunk = neighborChunk
                    highestDirection = x
                end
            end
        end
    end

    local nextHighestChunk = -1
    local nextHighestScore = highestScore
    local nextHighestDirection

    if (highestChunk ~= -1) then
  		local nextNeighborDirectionChunks = getNeighborChunks(map, highestChunk.x, highestChunk.y)
		for x=1,8 do
            local neighborChunk = nextNeighborDirectionChunks[x]
            if ((neighborChunk ~= -1) and (neighborChunk ~= chunk) and
                canMoveChunkDirection(map, x, highestChunk, neighborChunk)) then
                local score = scoreFunction(map, neighborChunk)
                if (score > nextHighestScore) then
                    nextHighestScore = score
                    nextHighestChunk = neighborChunk
                    nextHighestDirection = x
                end
            end
        end
    end

    if (nextHighestChunk == nil) then
        nextHighestChunk = -1
    end

    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end


--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForFormation(neighborChunks, validFunction, scoreFunction, map)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection
    for x=1,8 do
        local neighborChunk = neighborChunks[x]
        if (neighborChunk ~= -1) and validFunction(map, neighborChunk) then
            local score = scoreFunction(map, neighborChunk)
            if (score > highestScore) then
                highestScore = score
                highestChunk = neighborChunk
                highestDirection = x
            end
        end
    end

    return highestChunk, highestDirection
end

movementUtilsG = movementUtils
return movementUtils
