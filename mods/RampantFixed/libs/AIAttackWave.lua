if (aiAttackWaveG) then
    return aiAttackWaveG
end
local aiAttackWave = {}

-- imports

local constants = require("Constants")
local mapUtils = require("MapUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")
local unitGroupUtils = require("UnitGroupUtils")
local movementUtils = require("MovementUtils")
local mathUtils = require("MathUtils")
local config = require("__RampantFixed__/config")
local scoreChunks = require("ScoreChunks")


-- constants

local BASE_PHEROMONE = constants.BASE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE
local MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK

local AGGRESSIVE_CAN_ATTACK_WAIT_MAX_DURATION = constants.AGGRESSIVE_CAN_ATTACK_WAIT_MAX_DURATION
local AGGRESSIVE_CAN_ATTACK_WAIT_MIN_DURATION = constants.AGGRESSIVE_CAN_ATTACK_WAIT_MIN_DURATION

local AI_SQUAD_COST = constants.AI_SQUAD_COST
local AI_SETTLER_COST = constants.AI_SETTLER_COST
local AI_VENGENCE_SQUAD_COST = constants.AI_VENGENCE_SQUAD_COST
local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE

local COOLDOWN_RALLY = constants.COOLDOWN_RALLY

local CHUNK_ALL_DIRECTIONS = constants.CHUNK_ALL_DIRECTIONS

local CHUNK_SIZE = constants.CHUNK_SIZE

local RALLY_CRY_DISTANCE = constants.RALLY_CRY_DISTANCE

local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_MIGRATING = constants.AI_STATE_MIGRATING
local AI_STATE_RAIDING = constants.AI_STATE_RAIDING

-- imported functions

local randomTickEvent = mathUtils.randomTickEvent

local calculateKamikazeThreshold = unitGroupUtils.calculateKamikazeThreshold

local mRandom = math.random
local mMax = math.max
local mMin = math.min

local positionFromDirectionAndChunk = mapUtils.positionFromDirectionAndChunk

local getPassable = chunkPropertyUtils.getPassable
local getNestCount = chunkPropertyUtils.getNestCount
local getRaidNestActiveness = chunkPropertyUtils.getRaidNestActiveness
local getNestActiveness = chunkPropertyUtils.getNestActiveness
local getRallyTick = chunkPropertyUtils.getRallyTick
local setRallyTick = chunkPropertyUtils.setRallyTick

local gaussianRandomRange = mathUtils.gaussianRandomRange

local getNeighborChunks = mapUtils.getNeighborChunks
local getChunkByXY = mapUtils.getChunkByXY
local scoreNeighborsForFormation = movementUtils.scoreNeighborsForFormation
local scoreNeighborsForResource = movementUtils.scoreNeighborsForResource
local createSquad = unitGroupUtils.createSquad
local attackWaveScaling = config.attackWaveScaling
local settlerWaveScaling = config.settlerWaveScaling
local getAttackWaveMaxSize = config.getAttackWaveMaxSize
local getDeathGenerator = chunkPropertyUtils.getDeathGenerator

local validSiegeLocation = scoreChunks.validSiegeLocation
local validSettlerLocation = scoreChunks.validSettlerLocation
local validUnitGroupLocation = scoreChunks.validUnitGroupLocation

local scoreUnitGroupLocation = scoreChunks.scoreUnitGroupLocation
local scoreSiegeLocation = scoreChunks.scoreSiegeLocation
local scoreSettlerLocation = scoreChunks.scoreSettlerLocation

-- module code

local function attackWaveValidCandidate(chunk, map)
    local isValid = getNestActiveness(map, chunk)
    if (map.state == AI_STATE_RAIDING) or (map.state == AI_STATE_SIEGE) or (map.state == AI_STATE_MIGRATING) then
        isValid = isValid + getRaidNestActiveness(map, chunk)
    end
    return (isValid > 0)
end

-- + !КДА
local function getFreeNeighborChunks(neighborChunks, map)
	local freeChunks = 0
    for x=1,8 do
        local neighborChunk = neighborChunks[x]
        if (neighborChunk ~= -1) 
		and (getPassable(map, neighborChunk) == CHUNK_ALL_DIRECTIONS) 
		and (getNestCount(map, neighborChunk) == 0)
		then
			freeChunks = freeChunks + 1
        end
    end
	return freeChunks
end
-- - !КДА

local function visitPattern(o, cX, cY, distance)
    local startX
    local endX
    local stepX
    local startY
    local endY
    local stepY
    if (o == 0) then
        startX = cX - distance
        endX = cX + distance
        stepX = 32
        startY = cY - distance
        endY = cY + distance
        stepY = 32
    elseif (o == 1) then
        startX = cX + distance
        endX = cX - distance
        stepX = -32
        startY = cY + distance
        endY = cY - distance
        stepY = -32
    elseif (o == 2) then
        startX = cX - distance
        endX = cX + distance
        stepX = 32
        startY = cY + distance
        endY = cY - distance
        stepY = -32
    elseif (o == 3) then
        startX = cX + distance
        endX = cX - distance
        stepX = -32
        startY = cY - distance
        endY = cY + distance
        stepY = 32
    end
    return startX, endX, stepX, startY, endY, stepY
end

function aiAttackWave.rallyUnits(chunk, map, tick)
    if ((tick - getRallyTick(map, chunk) > COOLDOWN_RALLY) and (map.points >= AI_VENGENCE_SQUAD_COST)) then
        setRallyTick(map, chunk, tick)
        local cX = chunk.x
        local cY = chunk.y
        local startX, endX, stepX, startY, endY, stepY = visitPattern(tick % 4, cX, cY, RALLY_CRY_DISTANCE)
        local vengenceQueue = map.vengenceQueue
        for x=startX, endX, stepX do
            for y=startY, endY, stepY do
                if (x ~= cX) and (y ~= cY) then
                    local rallyChunk = getChunkByXY(map, x, y)
                    if (rallyChunk ~= -1) and (getNestCount(map, rallyChunk) > 0) then
                        local count = vengenceQueue[rallyChunk]
                        if not count then
                            count = 0
                            vengenceQueue[rallyChunk] = count
                        end
                        vengenceQueue[rallyChunk] = count + 1
                    end
                end
            end
        end

        return true
    end
end

function aiAttackWave.formSettlers(map, chunk)
    local universe = map.universe
	local squadCreated = false
	
    if (universe.builderCount < universe.AI_MAX_BUILDER_COUNT) and
        (mRandom() < universe.formSquadThreshold) and
        ((map.points - AI_SETTLER_COST) > 0)
    then
        local surface = map.surface
        local squadPath, squadDirection
		local neighborChunks = getNeighborChunks(map, chunk.x, chunk.y) 
		-- single nests have priority
		local FreeNeighborChunks = getFreeNeighborChunks(neighborChunks, map)		-- number of non-settled chunks
		local settleRoll= 1/(mMax(9-FreeNeighborChunks, 1)) -- 8 = 1, 7 - 50%, 6 - 25%, 5 = 12% ...
		local settlerType = "Settler"
		
		if (map.state == AI_STATE_SIEGE) or (universe.siegeAIToggle and (mRandom() <= 0.1)) then
			settlerType = "Siege"
		end

		if (settlerType == "Siege") then
			local siegeRoll
			local pheromones = chunk[BASE_DETECTION_PHEROMONE]
			if pheromones > universe.no_pollution_attack_threshold then
				siegeRoll = 1
			elseif pheromones < universe.raiding_minimum_base_threshold then
				if map.activeNests < 5 then
					siegeRoll = 1
				else
					siegeRoll = 0
				end	
			else	
				siegeRoll = (pheromones - universe.raiding_minimum_base_threshold)/(universe.no_pollution_attack_threshold - universe.raiding_minimum_base_threshold)
			end
			settleRoll = settleRoll * siegeRoll
		end
		if (settleRoll==1) or (mRandom() < settleRoll) then
		-- - !КДА
		
			if (settlerType == "Siege") then
				squadPath, squadDirection = scoreNeighborsForResource(chunk,
																	   getNeighborChunks(map, chunk.x, chunk.y),
																	   validSiegeLocation,
																	   scoreSiegeLocation,
																	   map)
				
			else
				squadPath, squadDirection = scoreNeighborsForResource(chunk,
																	  getNeighborChunks(map, chunk.x, chunk.y),
																	  validSettlerLocation,
																	  scoreSettlerLocation,
																	  map)
			end

			if (squadPath ~= -1) then
            local squadPosition = surface.find_non_colliding_position("chunk-scanner-squad-rampant",
                                                                      positionFromDirectionAndChunk(squadDirection,
                                                                                                    chunk,
                                                                                                    universe.position,
                                                                                                    0.98),
                                                                      CHUNK_SIZE,
                                                                      4,
                                                                      true)
            if squadPosition then
                local squad = createSquad(squadPosition, map, nil, true)

                squad.maxDistance = gaussianRandomRange(universe.expansionMaxDistance * 0.5,
                                                        universe.expansionMaxDistanceDerivation,
                                                        10,
                                                        universe.expansionMaxDistance)

				if settlerType == "Siege" then
					squad.siege = true
				end	
                local scaledWaveSize = settlerWaveScaling(universe)
                universe.formGroupCommand.group = squad.group
                universe.formCommand.unit_count = scaledWaveSize
                local foundUnits = surface.set_multi_command(universe.formCommand)
                if (foundUnits > 0) then
                    squad.kamikaze = mRandom() < calculateKamikazeThreshold(foundUnits, universe)
                    universe.builderCount = universe.builderCount + 1
					local rangeKf = 1
					if map.state == AI_STATE_MIGRATING then 
						rangeKf =  0.7 + mMin(chunk[BASE_DETECTION_PHEROMONE]/universe.no_pollution_attack_threshold, 0.3)
					end	
					local settlerCost = math.floor(AI_SETTLER_COST * rangeKf)
                    map.points = map.points - settlerCost
                    if universe.aiPointsPrintSpendingToChat then
                        game.print(map.surface.name .. ": Points: -" .. settlerCost .. ". ["..settlerType.."] Total: " .. string.format("%.2f", map.points) .. " [gps=" .. squadPosition.x .. "," .. squadPosition.y .. "]")
                    end
                    universe.groupNumberToSquad[squad.groupNumber] = squad
					map.vengenceLimiter = mMax(0, map.vengenceLimiter - 3)
					squadCreated = true
                else
                    if (squad.group.valid) then
                        squad.group.destroy()
                    end
                end
            end
        end
		end
    end
	return squadCreated
end

function aiAttackWave.formVengenceSquad(map, chunk)
    local universe = map.universe
	local finalSquadCost = universe.finalSquadCost
	local finalVengenceSquadCost = universe.finalVengenceSquadCost
    if (universe.squadCount < universe.AI_MAX_SQUAD_COUNT) and
        ((map.points - finalVengenceSquadCost) > 0) and
        (mRandom() < universe.formSquadThreshold)
    then
        local surface = map.surface
        local squadPath, squadDirection = scoreNeighborsForFormation(getNeighborChunks(map, chunk.x, chunk.y),
                                                                     validUnitGroupLocation,
                                                                     scoreUnitGroupLocation,
                                                                     map)
        if (squadPath ~= -1) then
            local squadPosition = surface.find_non_colliding_position("chunk-scanner-squad-rampant",
                                                                      positionFromDirectionAndChunk(squadDirection,
                                                                                                    chunk,
                                                                                                    universe.position,
                                                                                                    0.98),
                                                                      CHUNK_SIZE,
                                                                      4,
                                                                      true)
            if squadPosition then
                local squad = createSquad(squadPosition, map)
				squad.vengence = true
                squad.rabid = mRandom() < 0.03

                local scaledWaveSize = mMin(attackWaveScaling(universe), getAttackWaveMaxSize(universe)*0.8)
                universe.formGroupCommand.group = squad.group
                universe.formCommand.unit_count = scaledWaveSize
                local foundUnits = surface.set_multi_command(universe.formCommand)
                if (foundUnits > 0) then
                    squad.kamikaze = mRandom() < calculateKamikazeThreshold(foundUnits, universe)
                    universe.groupNumberToSquad[squad.groupNumber] = squad
                    universe.squadCount = universe.squadCount + 1
					if (map.points < finalSquadCost*4) or (universe.aiDifficulty~="Hard") then
						map.vengenceLimiter = map.vengenceLimiter + 1
					else
						map.vengenceLimiter = map.vengenceLimiter + 0.5					
					end	
					
                    map.points = map.points - finalVengenceSquadCost
                    if universe.aiPointsPrintSpendingToChat then
                        game.print(map.surface.name .. ": Points: -" .. finalVengenceSquadCost .. ". [Vengence] Total: " .. string.format("%.2f", map.points) .. " [gps=" .. squadPosition.x .. "," .. squadPosition.y .. "]")
                    end
                else
                    if (squad.group.valid) then
                        squad.group.destroy()
                    end
                end
            end
        end
    end
end

function aiAttackWave.formSquads(map, chunk, tick, remoteInterfaceParameters)
    local universe = map.universe
	local squadCreated = false
	local squad
	local finalSquadCost = universe.finalSquadCost
	local canCreateSquad = (remoteInterfaceParameters and remoteInterfaceParameters.ignoreSquadLimit) or (universe.squadCount < (universe.AI_MAX_SQUAD_COUNT*0.7))
	if remoteInterfaceParameters then
		finalSquadCost = mMin(finalSquadCost, map.points)
	end
    if canCreateSquad  and
        attackWaveValidCandidate(chunk, map) and
        ((map.points - finalSquadCost) >= 0) and
        (remoteInterfaceParameters or (mRandom() < universe.formSquadThreshold)) 
   then
        local surface = map.surface
        local squadPath, squadDirection = scoreNeighborsForFormation(getNeighborChunks(map, chunk.x, chunk.y),
                                                                     validUnitGroupLocation,
                                                                     scoreUnitGroupLocation,
                                                                     map)
        if (squadPath ~= -1) then
            local squadPosition = surface.find_non_colliding_position("chunk-scanner-squad-rampant",
                                                                      positionFromDirectionAndChunk(squadDirection,
                                                                                                    chunk,
                                                                                                    universe.position,
                                                                                                    0.98),
                                                                      CHUNK_SIZE,
                                                                      4,
                                                                      true)
            if squadPosition then
                squad = createSquad(squadPosition, map)
				if universe.undergroundAttack and (not remoteInterfaceParameters) and (universe.undergroundAttackProbability > 0) and (mRandom() < universe.undergroundAttackProbability)  then
					-- if mRandom() < 0.2 then
						-- squad.undergoundAttack = "randomTarget"	-- look at undergroundAttack.createUndergroudAttack
					-- else
						squad.undergoundAttack = "common"
					-- end		
				end
                squad.rabid = mRandom() < 0.03

                local scaledWaveSize = attackWaveScaling(universe)
                universe.formGroupCommand.group = squad.group
				if remoteInterfaceParameters and remoteInterfaceParameters.size and remoteInterfaceParameters.size > 0 then
					universe.formCommand.unit_count = remoteInterfaceParameters.size
				else
					universe.formCommand.unit_count = scaledWaveSize
				end	

                local foundUnits = surface.set_multi_command(universe.formCommand)
                if (foundUnits > 0) then
                    squad.kamikaze = mRandom() < calculateKamikazeThreshold(foundUnits, universe)

                    map.points = map.points - finalSquadCost
					map.vengenceLimiter = mMax(0, map.vengenceLimiter - 2)
					
					squadCreated = true
                    universe.squadCount = universe.squadCount + 1
                    universe.groupNumberToSquad[squad.groupNumber] = squad
					
                    if tick and ((map.state == AI_STATE_AGGRESSIVE) or (map.state ==AI_STATE_GROWING)) then
						map.squadsGenerated = (map.squadsGenerated or 0) + 1	-- this "attack-wave" only
						chanceForAdditionalSquad = map.activeNests/15-map.squadsGenerated
						if universe.aiPointsScaler > 1 then
							chanceForAdditionalSquad = chanceForAdditionalSquad + universe.aiPointsScaler - 1
						end
						chanceForAdditionalSquad = chanceForAdditionalSquad + map.points / 5000
						
						local needMoreSuads 
						if chanceForAdditionalSquad<=0 then
							needMoreSuads = false
						elseif chanceForAdditionalSquad>=1 then	
							needMoreSuads = true
						else
							needMoreSuads = (mRandom()<=chanceForAdditionalSquad)
						end
						if not needMoreSuads then
							map.squadsGenerated = 0

							map.canAttackTick = randomTickEvent(tick,
																AGGRESSIVE_CAN_ATTACK_WAIT_MIN_DURATION,
																AGGRESSIVE_CAN_ATTACK_WAIT_MAX_DURATION)
						end										
                    end
                    if universe.aiPointsPrintSpendingToChat then
                        game.print(map.surface.name .. ": Points: -" .. finalSquadCost .. ". [Squad] Total: " .. string.format("%.2f", map.points) .. " [gps=" .. squadPosition.x .. "," .. squadPosition.y .. "]")
                    end
                else
                    if (squad.group.valid) then
                        squad.group.destroy()
                    end
                end
            end
        end
    end
	if remoteInterfaceParameters then
		if squadCreated then
			remoteInterfaceParameters.squad = squad
		end
	end
	return squadCreated
end


aiAttackWaveG = aiAttackWave
return aiAttackWave
