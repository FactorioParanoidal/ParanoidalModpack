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

-- Neighbour selection shared by all squad movement scorers.
--[[
    Neighbours are numbered
    1 2 3
    4   5
    6 7 8
--]]

local mAbs = math.abs
local mRandom = math.random

-- Squads with a doctrine may take a near-best step instead of the best one: a candidate within NOISE_BAND of the
-- best score's magnitude gets weight noise * closeness (0..noise), the best gets weight 1.
local NOISE_BAND = 0.35
-- scratch arrays, filled only for a randomised pick and reset by the count of every call
local candidateChunks = {}
local candidateScores = {}
local candidateDirections = {}
local candidateWeights = {}

local function noisyPick(count, bestChunk, bestDirection, bestScore, noise, avoidChunk)
    local band = mAbs(bestScore) * NOISE_BAND
    local floor = bestScore - band
    local total = 1
    for i=1,count do
        local weight = 0
        local candidate = candidateChunks[i]
        if (candidate ~= bestChunk) and (candidate ~= avoidChunk) then
            local score = candidateScores[i]
            if (score >= floor) then
                if (band > 0) then
                    weight = noise * (score - floor) / band
                else
                    weight = noise
                end
            end
        end
        candidateWeights[i] = weight
        total = total + weight
    end
    if (total <= 1) then
        return bestChunk, bestDirection, bestScore
    end
    local roll = mRandom() * total - 1
    if (roll < 0) then
        return bestChunk, bestDirection, bestScore
    end
    for i=1,count do
        roll = roll - candidateWeights[i]
        if (roll < 0) then
            return candidateChunks[i], candidateDirections[i], candidateScores[i]
        end
    end
    return bestChunk, bestDirection, bestScore
end

-- Best neighbour by score (ties keep the first one). checkMove: the step must be passable, any step is allowed
-- from an unregistered chunk when anyFromUnknown. validFunction: optional filter.
-- Returns the chosen chunk, its direction and score, and the best score (they differ only with noise).
local function bestNeighbor(map, chunk, neighbors, scoreFunction, validFunction, checkMove, anyFromUnknown,
                            defaultDirection, noise, avoidChunk)
    local highestChunk = -1
    local highestScore = -MAGIC_MAXIMUM_NUMBER
    local highestDirection = defaultDirection
    local count = 0
    for x=1,8 do
        local neighborChunk = neighbors[x]
        if (neighborChunk ~= -1)
            and ((not checkMove) or canMoveChunkDirection(map, x, chunk, neighborChunk) or (anyFromUnknown and (chunk == -1)))
            and ((not validFunction) or validFunction(map, neighborChunk))
        then
            local score = scoreFunction(map, neighborChunk)
            if noise then
                count = count + 1
                candidateChunks[count] = neighborChunk
                candidateScores[count] = score
                candidateDirections[count] = x
            end
            if (score > highestScore) then
                highestScore = score
                highestChunk = neighborChunk
                highestDirection = x
            end
        end
    end
    if noise and (count > 1) then
        local chosenChunk, chosenDirection, chosenScore = noisyPick(count, highestChunk, highestDirection, highestScore, noise, avoidChunk)
        return chosenChunk, chosenDirection, chosenScore, highestScore
    end
    return highestChunk, highestDirection, highestScore, highestScore
end

-- Second step from fromChunk (never back to excludeChunk); it must score above threshold.
local function bestNextStep(map, fromChunk, excludeChunk, scoreFunction, threshold, defaultDirection)
    local nextChunk = -1
    local nextScore = threshold
    local nextDirection = defaultDirection
    if (fromChunk ~= -1) then
        local neighbors = getNeighborChunks(map, fromChunk.x, fromChunk.y)
        for x=1,8 do
            local neighborChunk = neighbors[x]
            if (neighborChunk ~= -1) and (neighborChunk ~= excludeChunk) and
                canMoveChunkDirection(map, x, fromChunk, neighborChunk)
            then
                local score = scoreFunction(map, neighborChunk)
                if (score > nextScore) then
                    nextScore = score
                    nextChunk = neighborChunk
                    nextDirection = x
                end
            end
        end
    end
    return nextChunk, nextDirection
end

--[[
    Expects all neighbors adjacent to a chunk.
    noise (optional): randomised near-best first step for squad doctrines; avoidChunk is never a random pick.
--]]
function movementUtils.scoreNeighborsForAttack(map, chunk, neighborDirectionChunks, scoreFunction, noise, avoidChunk)
    local highestChunk, highestDirection, highestScore, bestScore = bestNeighbor(map, chunk, neighborDirectionChunks,
        scoreFunction, nil, true, true, nil, noise, avoidChunk)
    -- a squad standing on a local maximum refreshes the static pheromones around it
    if (chunk ~= -1) and (scoreFunction(map, chunk) >= bestScore) then
        pheromoneUtils.processStaticPheromone(map, chunk, {recursion = true, color = {1, 1, 1}})
    end
    local nextHighestChunk, nextHighestDirection = bestNextStep(map, highestChunk, chunk, scoreFunction, highestScore, nil)
    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForSettling(map, chunk, neighborDirectionChunks, scoreFunction)
    local highestChunk, highestDirection, highestScore = bestNeighbor(map, chunk, neighborDirectionChunks,
        scoreFunction, nil, true, true, 0)
    if (chunk ~= -1) and (scoreFunction(map, chunk) > highestScore) then
        return chunk, 0, -1, 0
    end
    local nextHighestChunk, nextHighestDirection = bestNextStep(map, highestChunk, chunk, scoreFunction, highestScore, 0)
    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForResource(chunk, neighborDirectionChunks, validFunction, scoreFunction, map)
    local highestChunk, highestDirection, highestScore = bestNeighbor(map, chunk, neighborDirectionChunks,
        scoreFunction, validFunction, true, false, nil)
    if (chunk ~= -1) and (scoreFunction(map, chunk) > highestScore) then
        return -1, -1
    end
    return highestChunk, highestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForRetreat(chunk, neighborDirectionChunks, scoreFunction, map)
    local highestChunk, highestDirection, highestScore = bestNeighbor(map, chunk, neighborDirectionChunks,
        scoreFunction, nil, true, true, nil)
    local nextHighestChunk, nextHighestDirection = bestNextStep(map, highestChunk, chunk, scoreFunction, highestScore, nil)
    return highestChunk, highestDirection, nextHighestChunk, nextHighestDirection
end

--[[
    Expects all neighbors adjacent to a chunk
--]]
function movementUtils.scoreNeighborsForFormation(neighborChunks, validFunction, scoreFunction, map)
    local highestChunk, highestDirection = bestNeighbor(map, nil, neighborChunks, scoreFunction, validFunction,
        false, false, nil)
    return highestChunk, highestDirection
end

movementUtilsG = movementUtils
return movementUtils
