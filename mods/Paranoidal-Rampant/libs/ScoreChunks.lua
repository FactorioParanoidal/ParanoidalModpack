if (scoreChunksG) then
    return scoreChunksG
end
local scoreChunks = {}


local constants = require("Constants")
local chunkPropertyUtils = require("ChunkPropertyUtils")


local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_RAIDING = constants.AI_STATE_RAIDING

local BASE_PHEROMONE = constants.BASE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE
local PLAYER_PHEROMONE_MULTIPLER = constants.PLAYER_PHEROMONE_MULTIPLER

local MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK

local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS

local getDeathGenerator = chunkPropertyUtils.getDeathGenerator
local getPassable = chunkPropertyUtils.getPassable
local getNestCount = chunkPropertyUtils.getNestCount

---- validation
function scoreChunks.validSiegeLocation(map, neighborChunk)
    return (getPassable(map, neighborChunk) == CHUNK_ALL_DIRECTIONS)		
		and (neighborChunk[BASE_DETECTION_PHEROMONE] <= MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK*0.9)
		and (getNestCount(map, neighborChunk) == 0)
end

function scoreChunks.validSettlerLocation(map, neighborChunk)
    return (getPassable(map, neighborChunk) == CHUNK_ALL_DIRECTIONS) 
	and (getNestCount(map, neighborChunk) == 0)
end

function scoreChunks.validUnitGroupLocation(map, neighborChunk)
    return getPassable(map, neighborChunk) == CHUNK_ALL_DIRECTIONS and
        (getNestCount(map, neighborChunk) == 0)
end


---- score


function scoreChunks.scoreUnitGroupLocation(map, neighborChunk)
    return neighborChunk[PLAYER_PHEROMONE] +
        -getDeathGenerator(map, neighborChunk) +
        neighborChunk[BASE_PHEROMONE] + 0.01 * neighborChunk[BASE_DETECTION_PHEROMONE]
end

function scoreChunks.scoreResourceLocation(map, neighborChunk)
    local settle = -getDeathGenerator(map, neighborChunk) + neighborChunk[RESOURCE_PHEROMONE]
    return settle - (neighborChunk[PLAYER_PHEROMONE] * PLAYER_PHEROMONE_MULTIPLER)
end

function scoreChunks.scoreResourceLocationKamikaze(_, neighborChunk)
    local settle = neighborChunk[RESOURCE_PHEROMONE]
    return settle - (neighborChunk[PLAYER_PHEROMONE] * PLAYER_PHEROMONE_MULTIPLER)
end

function scoreChunks.scoreAttackLocation(map, neighborChunk)
    local damage = neighborChunk[BASE_PHEROMONE] + 0.01 * neighborChunk[BASE_DETECTION_PHEROMONE] + 
        (neighborChunk[PLAYER_PHEROMONE] * PLAYER_PHEROMONE_MULTIPLER)
    return damage
end

function scoreChunks.scoreAttackKamikazeLocation(_, neighborChunk)
    local damage = neighborChunk[BASE_DETECTION_PHEROMONE] + (neighborChunk[PLAYER_PHEROMONE] * PLAYER_PHEROMONE_MULTIPLER)
    return damage
end

function scoreChunks.scoreSettlerLocation(map, neighborChunk)
    return neighborChunk[RESOURCE_PHEROMONE] +
        -getDeathGenerator(map, neighborChunk) +
        -neighborChunk[PLAYER_PHEROMONE]
end

function scoreChunks.scoreSiegeLocation(map, neighborChunk)
	local pheromones = neighborChunk[BASE_DETECTION_PHEROMONE]
	local maxBasePoints = MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK
	if pheromones >= maxBasePoints then
		return 0
	else
		local scores = 0.1*neighborChunk[RESOURCE_PHEROMONE]
        + neighborChunk[BASE_PHEROMONE] +
        - (2*getDeathGenerator(map, neighborChunk))
		
		if pheromones > maxBasePoints*0.81 then
			return scores*.5
		else
			return scores
		end	
	end	
end

function scoreChunks.scoreSiegeLocationKamikaze(_, neighborChunk)
    local settle = neighborChunk[BASE_DETECTION_PHEROMONE]
         + 0.1*neighborChunk[RESOURCE_PHEROMONE]

    return settle
end

----------------------

scoreChunksG = scoreChunks
return scoreChunks