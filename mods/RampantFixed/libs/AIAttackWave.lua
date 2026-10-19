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
local aiBrain = require("AIBrain")

local TACTICS = aiBrain.TACTICS


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

local SQUAD_BUILDING = constants.SQUAD_BUILDING

-- imported functions

local randomTickEvent = mathUtils.randomTickEvent

local mRandom = math.random
local mMax = math.max
local mMin = math.min
local mFloor = math.floor
local mCeil = math.ceil

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

-- New squad next to the chunk in the given direction (nil if there is no room)
local function placeSquad(map, chunk, squadDirection, settlers)
    local squadPosition = map.surface.find_non_colliding_position("chunk-scanner-squad-rampant",
                                                                  positionFromDirectionAndChunk(squadDirection,
                                                                                                chunk,
                                                                                                map.universe.position,
                                                                                                0.98),
                                                                  CHUNK_SIZE,
                                                                  4,
                                                                  true)
    if not squadPosition then
        return nil
    end
    return createSquad(squadPosition, map, nil, settlers), squadPosition
end

-- Commands up to unitCount nearby units to join the squad; returns the number of units found
local function fillSquad(map, squad, unitCount)
    local universe = map.universe
    universe.formGroupCommand.group = squad.group
    universe.formCommand.unit_count = unitCount
    return map.surface.set_multi_command(universe.formCommand)
end

local function dropSquad(squad)
    if (squad.group.valid) then
        squad.group.destroy()
    end
end

local function printSpending(map, cost, label, position)
    if map.universe.aiPointsPrintSpendingToChat then
        game.print(map.surface.name .. ": Points: -" .. cost .. ". [" .. label .. "] Total: " .. string.format("%.2f", map.points) .. " [gps=" .. position.x .. "," .. position.y .. "," .. map.surface.name .. "]")
    end
end

function aiAttackWave.formSettlers(map, chunk)
	if chunk.nextSquadTick and (chunk.nextSquadTick > game.tick) then
		return false
	end
	
    local universe = map.universe
	local squadCreated = false
	
    if (universe.builderCount < universe.AI_MAX_BUILDER_COUNT) and
        (mRandom() < map.formSquadThreshold) and
        ((map.points - AI_SETTLER_COST) > 0)
    then
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
			if pheromones > map.no_pollution_attack_threshold then
				siegeRoll = 1
			else
				if map.activeRaidNests < 5 then
					siegeRoll = 1
				elseif map.activeRaidNests < 10 then
					siegeRoll = 0.5
				else	
					siegeRoll = 0.05
				end	
				if pheromones > map.raiding_minimum_base_threshold then
					siegeRoll = mMax(siegeRoll, (pheromones - map.raiding_minimum_base_threshold)/(map.no_pollution_attack_threshold - map.raiding_minimum_base_threshold))
				elseif pheromones == 0 then
					siegeRoll = mMin(0.1, siegeRoll)
				end
			end
			settleRoll = settleRoll * siegeRoll
		end
		local failChance = 1 - settleRoll
		if map.points > 10000 then
			failChance = failChance ^ 3
		elseif 	map.points > 5000 then
			failChance = failChance ^ 2
		end
		if (failChance==0) or (mRandom() >= failChance) then
			local validFunction = validSettlerLocation
			local scoreFunction = scoreSettlerLocation
			if (settlerType == "Siege") then
				validFunction = validSiegeLocation
				scoreFunction = scoreSiegeLocation
			end
			local squadPath, squadDirection = scoreNeighborsForResource(chunk,
																		getNeighborChunks(map, chunk.x, chunk.y),
																		validFunction,
																		scoreFunction,
																		map)
			if (squadPath ~= -1) then
				local squad, squadPosition = placeSquad(map, chunk, squadDirection, true)
				if squad then
					squad.maxDistance = gaussianRandomRange(universe.expansionMaxDistance * 0.5,
															universe.expansionMaxDistanceDerivation,
															10,
															universe.expansionMaxDistance)
					if settlerType == "Siege" then
						squad.siege = true
					end	
					local foundUnits = fillSquad(map, squad, settlerWaveScaling(map))
					if (foundUnits > 0) then
						squad.kamikaze = mRandom() < map.kamikazeThreshold
						universe.builderCount = universe.builderCount + 1
						local rangeKf = 1
						if map.state == AI_STATE_MIGRATING then
							rangeKf =  0.7 + mMin(chunk[BASE_DETECTION_PHEROMONE]/map.no_pollution_attack_threshold, 0.3)
						end
						local settlerCost = math.floor(AI_SETTLER_COST * rangeKf)
						map.points = map.points - settlerCost
						printSpending(map, settlerCost, settlerType, squadPosition)
						universe.groupNumberToSquad[squad.groupNumber] = squad
						map.vengenceLimiter = mMax(0, map.vengenceLimiter - 3)
						squadCreated = true
					else
						squadCreated = nil
						dropSquad(squad)
					end
				end
			end
		end
    end
	
	return squadCreated
end			

function aiAttackWave.formResourceSettlers(map, chunk)
	if chunk.nextSquadTick and (chunk.nextSquadTick > game.tick) then
		return false
	end
	if chunk[RESOURCE_PHEROMONE] < 5000 then	-- ~10 range
		return false
	end
	
    local universe = map.universe
	local squadCreated = false
	
	local squadPath, squadDirection = scoreNeighborsForResource(chunk,
								  getNeighborChunks(map, chunk.x, chunk.y),
								  validSettlerLocation,
								  scoreSettlerLocation,
								  map)
	if (squadPath ~= -1) then
		local squad, squadPosition = placeSquad(map, chunk, squadDirection, true)
		if squad then
			squad.maxDistance = 17 * CHUNK_SIZE
			squad.siege = false

			local foundUnits = fillSquad(map, squad, 6)
			if (foundUnits > 0) then
				squad.kamikaze = false
				universe.builderCount = universe.builderCount + 1

				local settlerCost = 10
				map.points = map.points - settlerCost
				printSpending(map, settlerCost, "claiming resource", squadPosition)
				universe.groupNumberToSquad[squad.groupNumber] = squad
				squadCreated = true
				
				if (map.state == constants.AI_STATE_SIEGE) or (map.state == constants.AI_STATE_MIGRATING) then
					map.resourceSettleTick = game.tick + 3600*5
				else
					map.resourceSettleTick = game.tick + 3600*30	-- 30 min
				end	
			else
				squadCreated = nil
				dropSquad(squad)
			end
		end	
	end	
	return squadCreated	
end

function aiAttackWave.formVengenceSquad(map, chunk)
	if chunk.nextSquadTick and (chunk.nextSquadTick > game.tick) then
		return false
	end
    local universe = map.universe
	local finalSquadCost = map.finalSquadCost
	local finalVengenceSquadCost = map.finalVengenceSquadCost
    if (universe.squadCount < universe.AI_MAX_SQUAD_COUNT) and
        ((map.points - finalVengenceSquadCost) > 0) and
        (mRandom() < map.formSquadThreshold)
    then
        local squadPath, squadDirection = scoreNeighborsForFormation(getNeighborChunks(map, chunk.x, chunk.y),
                                                                     validUnitGroupLocation,
                                                                     scoreUnitGroupLocation,
                                                                     map)
        if (squadPath ~= -1) then
            local squad, squadPosition = placeSquad(map, chunk, squadDirection)
            if squad then
				squad.vengence = true
                squad.rabid = mRandom() < 0.03

                local foundUnits = fillSquad(map, squad, mMin(attackWaveScaling(map), getAttackWaveMaxSize(universe)*0.8))
                if (foundUnits > 0) then
                    squad.kamikaze = mRandom() < map.kamikazeThreshold
                    universe.groupNumberToSquad[squad.groupNumber] = squad
                    universe.squadCount = universe.squadCount + 1
					if (map.points < finalSquadCost*4) or (universe.aiDifficulty~="Hard") then
						map.vengenceLimiter = map.vengenceLimiter + 1
					else
						map.vengenceLimiter = map.vengenceLimiter + 0.5					
					end	
					
                    map.points = map.points - finalVengenceSquadCost
					printSpending(map, finalVengenceSquadCost, "Vengence", squadPosition)
					chunk.nextSquadTick = game.tick + 900	-- 15 sec
					if aiBrain.active(universe) then
						-- hunters do not walk one predictable line either
						squad.noise = 0.1
						squad.startSize = foundUnits
					end
                else
                    dropSquad(squad)
                end
            end
        end
    end
end

local spiderUnitWeight = 4

-- squads that found too few units take nearby spider units (each counts as spiderUnitWeight units)
local function addSpiders(map, squad, scaledWaveSize, foundUnits)
	if (scaledWaveSize - foundUnits) > spiderUnitWeight then
		local placesLeft = scaledWaveSize - foundUnits
		local foundSpiders = map.surface.find_entities_filtered({
			force  = squad.group.force,
			position = map.universe.position,
			radius = 64,
			type = "spider-unit"
			})
		for _, spiderUnit in pairs(foundSpiders) do
			squad.group.add_member(spiderUnit)
			foundUnits = foundUnits + 1
			placesLeft = placesLeft - spiderUnitWeight
			if placesLeft <= 0 then
				break
			end
		end
		if #foundSpiders > 0 then
			squad.hasSpiders = true
		end
	end
	return foundUnits
end

-- extra squads of two-squad tactics (second probe, second pincer arm) and the delayed main strike
local function formTacticExtras(map, chunk, tick, tactic, firstSquad, squadDirection, unitCount, finalSquadCost)
	local universe = map.universe
	local spec = TACTICS[tactic]
	local stage1 = spec.stage1
	local squads = {firstSquad}
	if stage1 and (stage1.count > 1) then
		for i = 2, stage1.count do
			local cost = mFloor(finalSquadCost * stage1.costK)
			if (universe.squadCount >= universe.AI_MAX_SQUAD_COUNT) or ((map.points - cost) < 0) then
				break
			end
			local squad, squadPosition = placeSquad(map, chunk, squadDirection)
			if not squad then
				break
			end
			local foundUnits = fillSquad(map, squad, unitCount)
			if foundUnits <= 0 then
				dropSquad(squad)
				break
			end
			squad.kamikaze = mRandom() < map.kamikazeThreshold
			map.points = map.points - cost
			universe.squadCount = universe.squadCount + 1
			universe.groupNumberToSquad[squad.groupNumber] = squad
			squad.startSize = foundUnits
			aiBrain.prepareSquad(map, squad, chunk, tactic, stage1, {excludeSector = firstSquad.goalSector}, tick)
			aiBrain.describeSquad(map, squad, "extra", foundUnits, squadPosition)
			printSpending(map, cost, "Squad", squadPosition)
			squads[#squads + 1] = squad
		end
	end
	if (stage1 and (stage1.approach == "pincer")) and aiBrain.heavy then
		aiBrain.heavy.preparePincer(map, squads, chunk, tick)
	end
	if spec.followUp then
		aiBrain.scheduleFollowUp(map, chunk, tactic, tick, {approach = spec.approach, refSector = firstSquad.goalSector})
	end
	-- flights strike elsewhere while the ground attack is under way
	local ai = aiBrain.getMapAI(map)
	ai.escortUntil = tick + 5400
	ai.escortX = (firstSquad.goal and firstSquad.goal.x) or (chunk.x + 16)
	ai.escortY = (firstSquad.goal and firstSquad.goal.y) or (chunk.y + 16)
	if (ai.nextFlightTick > tick + 600) and ((tick - (ai.lastFlightTick or 0)) > 1800) then
		ai.nextFlightTick = tick + 600
	end
end

-- plan (optional): delayed main strike of a two-stage tactic, from aiBrain.popDueFollowUp
function aiAttackWave.formSquads(map, chunk, tick, remoteInterfaceParameters, plan)
	if (not plan) and chunk.nextSquadTick and (chunk.nextSquadTick > tick) then
		return false
	end
    local universe = map.universe
	local squadCreated = false
	local squad
	local finalSquadCost = map.finalSquadCost
	local canCreateSquad = (remoteInterfaceParameters and remoteInterfaceParameters.ignoreSquadLimit) or (universe.squadCount < (universe.AI_MAX_SQUAD_COUNT*0.7))
	if remoteInterfaceParameters then
		finalSquadCost = mMin(finalSquadCost, map.points)
	end
    if canCreateSquad  and
        attackWaveValidCandidate(chunk, map) and
        ((map.points - finalSquadCost) >= 0) and
        (remoteInterfaceParameters or plan or (mRandom() < map.formSquadThreshold))
   then
        local squadPath, squadDirection = scoreNeighborsForFormation(getNeighborChunks(map, chunk.x, chunk.y),
                                                                     validUnitGroupLocation,
                                                                     scoreUnitGroupLocation,
                                                                     map)
        if (squadPath ~= -1) then
			local squadPosition
            squad, squadPosition = placeSquad(map, chunk, squadDirection)
            if squad then
				-- tactic (new behaviour only; remote-created squads keep the old one)
				local tactic
				local spec
				if not remoteInterfaceParameters then
					if plan then
						tactic = plan.tactic
					else
						tactic = aiBrain.chooseTactic(map, chunk, tick, config.getAttackWaveSize(map))
					end
					if tactic then
						spec = TACTICS[tactic]
						if (not plan) and spec.stage1 then
							spec = spec.stage1
						end
					end
				end
				if universe.undergroundAttack and (not remoteInterfaceParameters) and aiBrain.heavyScriptsAllowed(universe)
					and ((not tactic) or (tactic == "assault"))
					and (map.undergroundAttackProbability > 0) and (mRandom() < map.undergroundAttackProbability)  then
					squad.undergoundAttack = "common"
				end
                squad.rabid = mRandom() < 0.03

                local scaledWaveSize = attackWaveScaling(map)
				if map.supressionData and (map.supressionData.supressionType >=2) and (map.supressionData.supressionEndTick >= tick) then
					if not map.supressionData.artilleryEffectTick or (map.supressionData.artilleryEffectTick<game.tick) then
						scaledWaveSize = math.floor(scaledWaveSize*0.5)
						map.supressionData.supressionType = 1
					end				
				end
				local squadCost = finalSquadCost
				if spec then
					scaledWaveSize = mMax(spec.minSize or 1, mCeil(scaledWaveSize * spec.sizeK))
					squadCost = mFloor(finalSquadCost * spec.costK)
				end
				local unitCount = scaledWaveSize
				if remoteInterfaceParameters and remoteInterfaceParameters.size and remoteInterfaceParameters.size > 0 then
					unitCount = remoteInterfaceParameters.size
				end

                local foundUnits = fillSquad(map, squad, unitCount)
				foundUnits = addSpiders(map, squad, scaledWaveSize, foundUnits)
                if (foundUnits > 0) then
                    squad.kamikaze = mRandom() < map.kamikazeThreshold

                    map.points = map.points - squadCost
					map.vengenceLimiter = mMax(0, map.vengenceLimiter - 2)
					
					squadCreated = true
                    universe.squadCount = universe.squadCount + 1
                    universe.groupNumberToSquad[squad.groupNumber] = squad
					if tactic then
						squad.startSize = foundUnits
						aiBrain.prepareSquad(map, squad, chunk, tactic, spec, plan, tick)
						aiBrain.describeSquad(map, squad, plan and "follow-up" or nil, foundUnits, squadPosition)
						if not plan then
							formTacticExtras(map, chunk, tick, tactic, squad, squadDirection, scaledWaveSize, finalSquadCost)
						end
					end
					
                    if tick and (not plan) and ((map.state == AI_STATE_AGGRESSIVE) or (map.state ==AI_STATE_GROWING)) then
						map.squadsGenerated = (map.squadsGenerated or 0) + 1	-- this "attack-wave" only
						local chanceForAdditionalSquad = map.activeNests/15-map.squadsGenerated
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
					chunk.nextSquadTick = tick + 1800	-- 30 sec
					printSpending(map, squadCost, "Squad", squadPosition)
                else
					squadCreated = nil
                    dropSquad(squad)
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

---- emulation of base building
function aiAttackWave.processNonRampantBuilders(universe, tick)
	for group, members in pairs (universe.nonRampantBuilders) do
		if not group.valid then
			local surface
			local map
			local validMembers = 0
			local newGroup
			for _, entity in pairs (members) do			
				if entity.valid and (entity.type == "unit") then
					if validMembers == 0 then
						surface = entity.surface
						map = universe.maps[surface.index]
						if map then
							newGroup = surface.create_unit_group({position=entity.position, force = entity.force})
						end	
					end
					if map then
						newGroup.add_member(entity)
					end	
					validMembers = validMembers + 1
				end
			end
			universe.nonRampantBuilders[group] = nil

			if newGroup then
				local evo = newGroup.force.get_evolution_factor(map.surface)
				local buildCooldown
				if evo < 0.1 then
					buildCooldown = 3600
				elseif evo < 0.3 then
					buildCooldown = 40 * 60
				elseif evo < 0.5 then
					buildCooldown = 30 * 60
				else
					buildCooldown = 20 * 60				
				end
				local squad = createSquad(newGroup.position, map, newGroup, true)
				squad.excluded = true
				squad.onTheWay = true
				squad.nextCommandTick = tick + 36000	
				squad.checkTick = tick + 36000	-- some groups get stuck 
				squad.status = SQUAD_BUILDING
				local cmd = {type = defines.command.stop, ticks_to_wait = 3600*10, distraction = defines.distraction.none}
				newGroup.set_command(cmd)
				
				universe.builderSquads[squad] = {builded = 0, buildCooldown = buildCooldown, nextTick = tick}
				universe.groupNumberToSquad[squad.groupNumber] = squad
			end	
			
		end
	end
end

function aiAttackWave.processBuilders(universe, tick)
	
	local builderSquads = universe.builderSquads
	local processBuild
	local map
	local surface
	local group
	local validMembers
	-- local cnt_squads = 0	-- debug
	for squad, buildData in pairs (builderSquads) do
		-- cnt_squads = cnt_squads + 1	-- debug
		-- if squad and squad.group.valid then
			-- game.print("aiAttackWave.processBuilders: [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .. "," .. squad.group.surface.name .."]")
			-- game.print("group #"..squad.group.unique_id..": "..math.floor((buildData.nextTick - tick)/60).."seconds, builded = ".. buildData.builded)
		-- end
		processBuild = false
		if (not squad) or not (squad.group.valid)then
			builderSquads[squad] = nil
		elseif buildData.builded >= 20 then
			builderSquads[squad] = nil
		elseif buildData.nextTick <= tick then
			processBuild = true
		end
		if processBuild then
			map = squad.map
			if (not map) or (not map.surface.valid) then
				processBuild = false
			end
		end
		if processBuild and map.hasNonmoddedBiters then
			surface = map.surface
			group = squad.group
			validMembers = 0
			for _, entity in pairs(group.members) do
				if entity.valid and (entity.type == "unit") then
					validMembers = validMembers + 1
					local roll = math.random()
					local newPosition
					local entityName
					if roll < 0.4 then
						entityName = "medium-worm-turret"
						newPosition = surface.find_non_colliding_position(
							"chunk-scanner-turret-rampant",
							entity.position,
							16,
							1,
							true
						)
					else
						local spawner = entity.commandable.spawner
						if spawner then
							local hiveType = universe.buildingHiveTypeLookup[spawner.name]
							if hiveType then
								entityName = "biter-spawner"
							else
								entityName = spawner.name	-- non-rampant nest
							end
						else
							if (buildData.builded % 2) == 1 then
								entityName = "spitter-spawner"
							else	
								entityName = "biter-spawner"
							end
						end

						newPosition = surface.find_non_colliding_position(
							"chunk-scanner-nest-rampant",
							entity.position,
							16,
							1,
							true
						)
					end
											-- game.print("entityName = ".. tostring(entityName).." newPosition is ".. tostring(newPosition and true or false))	-- debug
					if newPosition then
						buildData.builded = buildData.builded + 1
						buildData.nextTick = tick + (buildData.buildCooldown or 3600)
						
						local newEntity = map.surface.create_entity({name = entityName, position = newPosition, force = entity.force, raise_built = false})
						if newEntity and newEntity.valid then
							newEntity.spawn_decorations()
							script.raise_event(defines.events.on_biter_base_built, {entity = newEntity, tick = tick}) 
						end						
						break
					end
					entity.destroy()
					
				end
			end
			if validMembers == 0 then
				builderSquads[squad] = nil	
			end
		end
	end
	-- game.print("aiAttackWave.processBuilders, cnt_squads = "..cnt_squads)	-- debug
end
---- 

aiAttackWaveG = aiAttackWave
return aiAttackWave
