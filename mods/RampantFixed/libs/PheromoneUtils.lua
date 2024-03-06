if pheromoneUtilsG then
    return pheromoneUtilsG
end
local pheromoneUtils = {}

-- imports
local mathUtils = require("MathUtils")
local mapUtils = require("MapUtils")
local constants = require("Constants")
local chunkPropertyUtils = require("ChunkPropertyUtils")

-- constants

local VICTORY_SCENT_MULTIPLER = constants.VICTORY_SCENT_MULTIPLER
local VICTORY_SCENT_BOUND = constants.VICTORY_SCENT_BOUND

local MAGIC_MAXIMUM_NUMBER = constants.MAGIC_MAXIMUM_NUMBER

local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS
local CHUNK_NORTH_SOUTH = constants.CHUNK_NORTH_SOUTH
local CHUNK_EAST_WEST = constants.CHUNK_EAST_WEST

local MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK	-- + !КДА
local BASE_PHEROMONE = constants.BASE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE	-- + !КДА
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE

local VICTORY_SCENT = constants.VICTORY_SCENT

local PLAYER_PHEROMONE_GENERATOR_AMOUNT = constants.PLAYER_PHEROMONE_GENERATOR_AMOUNT

local DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.DEATH_PHEROMONE_GENERATOR_AMOUNT

-- imported functions

local addVictoryGenerator = chunkPropertyUtils.addVictoryGenerator

local getNeighborChunks = mapUtils.getNeighborChunks

local getEnemyStructureCount = chunkPropertyUtils.getEnemyStructureCount
local getPlayerTurretCount = chunkPropertyUtils.getPlayerTurretCount
local getPathRating = chunkPropertyUtils.getPathRating
local getPassable = chunkPropertyUtils.getPassable
local getPlayerBaseGenerator = chunkPropertyUtils.getPlayerBaseGenerator
local getResourceGenerator = chunkPropertyUtils.getResourceGenerator
local addDeathGenerator = chunkPropertyUtils.addDeathGenerator
local getDeathGenerator = chunkPropertyUtils.getDeathGenerator
local decayDeathGenerator = chunkPropertyUtils.decayDeathGenerator

local linearInterpolation = mathUtils.linearInterpolation
local mMin = math.min
local mMax = math.max

local getChunkByXY = mapUtils.getChunkByXY

local next = next

-- module code

function pheromoneUtils.victoryScent(map, chunk, entityType)
    local value = VICTORY_SCENT[entityType]
    if value then
        addVictoryGenerator(map, chunk, value)
    end
end

function pheromoneUtils.disperseVictoryScent(map)
    local chunk = map.victoryScentIterator
    local chunkToVictory = map.chunkToVictory
    local pheromone
    if not chunk then
        chunk, pheromone = next(chunkToVictory, nil)
    else
        pheromone = chunkToVictory[chunk]
    end
    if not chunk then
        map.victoryScentIterator = nil
    else
        map.victoryScentIterator = next(chunkToVictory, chunk)
        local chunkX = chunk.x
        local chunkY = chunk.y
        local i = 1
        for x=chunkX - VICTORY_SCENT_BOUND, chunkX + VICTORY_SCENT_BOUND,32 do
            for y = chunkY - VICTORY_SCENT_BOUND, chunkY + VICTORY_SCENT_BOUND,32 do
                local c = getChunkByXY(map, x, y)
                if (c ~= -1) then
                    addDeathGenerator(map, c, -pheromone * VICTORY_SCENT_MULTIPLER[i] * getPathRating(map, c))
                end
                i = i + 1
            end
        end

        chunkToVictory[chunk] = nil
    end
end

function pheromoneUtils.deathScent(map, chunk)
    addDeathGenerator(map, chunk, DEATH_PHEROMONE_GENERATOR_AMOUNT)
end

local function compare_pheromones(neighbor, pheromone_neighbor)
	local pheromone
	pheromone = neighbor[BASE_PHEROMONE]
	if pheromone_neighbor.chunkBase < pheromone then
		pheromone_neighbor.chunkBase = pheromone
		pheromone_neighbor.src = "[gps=" .. neighbor.x .. "," .. neighbor.y .."]"
	end
	pheromone = neighbor[BASE_DETECTION_PHEROMONE] or 0
	if pheromone_neighbor.chunkBaseDetection < pheromone then
		pheromone_neighbor.chunkBaseDetection = pheromone
	end			
	pheromone = neighbor[RESOURCE_PHEROMONE]
	if pheromone_neighbor.chunkResource < pheromone then
		pheromone_neighbor.chunkResource = pheromone
	end
end

local pheromoneMultipliers = {}
for i = 1, 10 do
	pheromoneMultipliers[i] = 0.9^i
end

local function getPheromoneMultiplier(turretCount)
	if (not turretCount) or (turretCount == 0) then
		return 1
	end
	if turretCount > #pheromoneMultipliers then
		return pheromoneMultipliers[#pheromoneMultipliers]
	end
	
	local pheromoneMultiplier = pheromoneMultipliers[turretCount]
	if pheromoneMultiplier then
		return pheromoneMultiplier
	end
	
	return 1
end


--[[
    1 2 3
    \|/
    4- -5
    /|\
    6 7 8
]]--
function pheromoneUtils.processStaticPheromone(map, chunk)
    local chunkBase = -MAGIC_MAXIMUM_NUMBER
	local chunkBaseDetection = -MAGIC_MAXIMUM_NUMBER
    local chunkResource = -MAGIC_MAXIMUM_NUMBER
    local chunkPathRating = getPathRating(map, chunk)

    local clear = getEnemyStructureCount(map, chunk)

    local tempNeighbors = getNeighborChunks(map, chunk.x, chunk.y)

    local neighbor
    local neighborPass

    local chunkPass = getPassable(map, chunk)
    local pheromone
	local pheromone_neighbor = {chunkBase = 0, chunkBaseDetection = 0, chunkResource = 0}
	
    if (chunkPass == CHUNK_ALL_DIRECTIONS) then
        neighbor = tempNeighbors[2]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[7]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[4]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[5]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[1]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[3]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
 				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[6]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
 				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[8]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end
    elseif (chunkPass == CHUNK_EAST_WEST) then

        neighbor = tempNeighbors[4]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[5]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end
    elseif (chunkPass == CHUNK_NORTH_SOUTH) then

        neighbor = tempNeighbors[2]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
 				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end

        neighbor = tempNeighbors[7]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
				compare_pheromones(neighbor, pheromone_neighbor)
            end
        end
    end
	
    pheromone_neighbor.chunkBaseDetection = mMin(pheromone_neighbor.chunkBaseDetection, MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK)  * 0.9
    pheromone = mMin(getPlayerBaseGenerator(map, chunk, BASE_DETECTION_PHEROMONE), MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK)	
	
    if pheromone_neighbor.chunkBaseDetection < pheromone then
        chunk[BASE_DETECTION_PHEROMONE] = pheromone
    else
        chunk[BASE_DETECTION_PHEROMONE] = pheromone_neighbor.chunkBaseDetection
    end
	if chunkPathRating <= 0.1 then
        chunk[BASE_DETECTION_PHEROMONE] = pheromone * chunkPathRating	
	end
	
    pheromone_neighbor.chunkBase = pheromone_neighbor.chunkBase * 0.9
    pheromone = getPlayerBaseGenerator(map, chunk, BASE_PHEROMONE)
	
    if pheromone_neighbor.chunkBase < pheromone then
        chunk[BASE_PHEROMONE] = pheromone * chunkPathRating
    else
        chunk[BASE_PHEROMONE] = pheromone_neighbor.chunkBase * chunkPathRating
    end
		
	-- turrets and kills
	local turretCount = 0
	for i = 1, 8 do
		turretCount = turretCount + getPlayerTurretCount(map, tempNeighbors[i])
	end
	turretCount = math.floor(turretCount * 0.3) + getPlayerTurretCount(map, chunk)
	local pheromoneMultiplier = getPheromoneMultiplier(turretCount)
	
	local casualitiesAsAdditionalTurrets =  mMin(math.floor(0.05 * getDeathGenerator(map, chunk) / DEATH_PHEROMONE_GENERATOR_AMOUNT), 5)
	pheromoneMultiplier = pheromoneMultiplier * getPheromoneMultiplier(casualitiesAsAdditionalTurrets)
	chunk[BASE_PHEROMONE] = chunk[BASE_PHEROMONE] * pheromoneMultiplier
	--------------
	
	chunk[BASE_DETECTION_PHEROMONE] = math.floor(chunk[BASE_DETECTION_PHEROMONE])
	chunk[BASE_PHEROMONE] = math.floor(chunk[BASE_PHEROMONE])
	
	-- DEBUG
	-- local chunkText = ""..chunk[BASE_PHEROMONE].."/"..chunk[BASE_DETECTION_PHEROMONE].."("..(math.floor(pheromoneMultiplier*100)/100)..") "
	-- if chunk.textId then
		-- rendering.set_text(chunk.textId, chunkText)
	-- else	
		-- chunk.textId = rendering.draw_text({
		-- text = chunkText, 
		-- surface = map.surface,
		-- target = {x = chunk.x, y = chunk.y},
		-- color = {r = 0, g = 0.5, b = 0, a = 0.5},
		-- forces = {"player"},
		-- scale = 5
		-- })
	 -- end
	

    pheromone_neighbor.chunkResource = pheromone_neighbor.chunkResource * 0.9
    pheromone = getResourceGenerator(map, chunk)
    if (pheromone > 0) and clear then
        pheromone = linearInterpolation(pheromone, 15000, 20000)
    end
    if chunkResource < pheromone then
        if clear then
            chunk[RESOURCE_PHEROMONE] = pheromone * chunkPathRating
        else
            chunk[RESOURCE_PHEROMONE] = pheromone * chunkPathRating * 0.1
        end
    else
        if clear then
            chunk[RESOURCE_PHEROMONE] = pheromone_neighbor.chunkResource * chunkPathRating
        else
            chunk[RESOURCE_PHEROMONE] = pheromone_neighbor.chunkResource * chunkPathRating * 0.1
        end
    end
end

function pheromoneUtils.processPheromone(map, chunk, player)
    local chunkPlayer = -MAGIC_MAXIMUM_NUMBER
    local chunkPathRating = getPathRating(map, chunk)

    local tempNeighbors = getNeighborChunks(map, chunk.x, chunk.y)

    local neighbor
    local neighborPass

    local chunkPass = getPassable(map, chunk)
    local pheromone
    if (chunkPass == CHUNK_ALL_DIRECTIONS) then
        neighbor = tempNeighbors[2]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[7]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[4]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[5]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[1]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[3]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[6]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[8]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if (neighborPass == CHUNK_ALL_DIRECTIONS) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end
    elseif (chunkPass == CHUNK_EAST_WEST) then

        neighbor = tempNeighbors[4]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[5]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_EAST_WEST)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end
    elseif (chunkPass == CHUNK_NORTH_SOUTH) then

        neighbor = tempNeighbors[2]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end

        neighbor = tempNeighbors[7]
        if (neighbor ~= -1) then
            neighborPass = getPassable(map, neighbor)
            if ((neighborPass == CHUNK_ALL_DIRECTIONS) or (neighborPass == CHUNK_NORTH_SOUTH)) then
                pheromone = neighbor[PLAYER_PHEROMONE]
                if chunkPlayer < pheromone then
                    chunkPlayer = pheromone
                end
            end
        end
    end

    if not player then
        decayDeathGenerator(map, chunk)
    end

    chunkPlayer = chunkPlayer * 0.45	
    pheromone = ((map.universe.chunkToPlayerCount[chunk] and 1) or 0) * PLAYER_PHEROMONE_GENERATOR_AMOUNT
	
    if chunkPlayer < pheromone then
        chunk[PLAYER_PHEROMONE] = pheromone * chunkPathRating
    else
        chunk[PLAYER_PHEROMONE] = chunkPlayer * chunkPathRating
    end
	
	if chunk[PLAYER_PHEROMONE] < 1 then
		chunk[PLAYER_PHEROMONE] = 0
	end
	
	-- DEBUG
	-- local chunkText = " PLAYERS = "..tostring((map.universe.chunkToPlayerCount[chunk] or 0))..", "..math.floor(chunk[PLAYER_PHEROMONE])
	-- if chunk.textId then
		-- rendering.set_text(chunk.textId, chunkText)
	-- else	
		-- chunk.textId = rendering.draw_text({
		-- text = chunkText, 
		-- surface = map.surface,
		-- target = {x = chunk.x, y = chunk.y},
		-- color = {r = 0, g = 0.5, b = 0, a = 0.5},
		-- forces = {"player"},
		-- scale = 5
		-- })
	-- end	
	--
end

pheromoneUtilsG = pheromoneUtils
return pheromoneUtils
