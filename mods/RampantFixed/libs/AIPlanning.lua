if aiPlanningG then
    return aiPlanningG
end
local aiPlanning = {}

-- imports

local constants = require("Constants")
local mathUtils = require("MathUtils")
local config = require("__RampantFixed__/config")

-- local aiPredicates = require("AIPredicates")

-- constants

local NO_RETREAT_BASE_PERCENT = constants.NO_RETREAT_BASE_PERCENT
local NO_RETREAT_EVOLUTION_BONUS_MAX = constants.NO_RETREAT_EVOLUTION_BONUS_MAX
local RAIDING_MINIMUM_BASE_THRESHOLD = constants.RAIDING_MINIMUM_BASE_THRESHOLD
local NO_POLLUTION_ATTACK_THRESHOLD = constants.NO_POLLUTION_ATTACK_THRESHOLD

local AI_STATE_PEACEFUL = constants.AI_STATE_PEACEFUL
local AI_STATE_AGGRESSIVE = constants.AI_STATE_AGGRESSIVE
local AI_STATE_RAIDING = constants.AI_STATE_RAIDING
local AI_STATE_MIGRATING = constants.AI_STATE_MIGRATING
local AI_STATE_ONSLAUGHT = constants.AI_STATE_ONSLAUGHT
local AI_STATE_SIEGE = constants.AI_STATE_SIEGE
local AI_STATE_GROWING = constants.AI_STATE_GROWING

local AI_UNIT_REFUND = constants.AI_UNIT_REFUND

local AI_MAX_POINTS = constants.AI_MAX_POINTS
local AI_POINT_GENERATOR_AMOUNT = constants.AI_POINT_GENERATOR_AMOUNT

local AI_MIN_STATE_DURATION = constants.AI_MIN_STATE_DURATION
local AI_MAX_STATE_DURATION = constants.AI_MAX_STATE_DURATION

local BASE_RALLY_CHANCE = constants.BASE_RALLY_CHANCE
local BONUS_RALLY_CHANCE = constants.BONUS_RALLY_CHANCE

local RETREAT_MOVEMENT_PHEROMONE_LEVEL_MIN = constants.RETREAT_MOVEMENT_PHEROMONE_LEVEL_MIN
local RETREAT_MOVEMENT_PHEROMONE_LEVEL_MAX = constants.RETREAT_MOVEMENT_PHEROMONE_LEVEL_MAX
local MINIMUM_AI_POINTS = constants.MINIMUM_AI_POINTS

local K_NO_ACTIVE_NESTS = constants.K_NO_ACTIVE_NESTS
local K_TOO_LOW_ACTIVE_NESTS = constants.K_TOO_LOW_ACTIVE_NESTS
local K_LOW_ACTIVE_NESTS = constants.K_LOW_ACTIVE_NESTS


-- imported functions

local randomTickEvent = mathUtils.randomTickEvent

local linearInterpolation = mathUtils.linearInterpolation

local mFloor = math.floor

local mRandom = math.random

local mMax = math.max
local mMin = math.min

-- module code

local function getTimeStringFromTick(tick)

    local tickToSeconds = tick / 60

    local days = math.floor(tickToSeconds / 86400)
    local hours = math.floor((tickToSeconds % 86400) / 3600)
    local minutes = math.floor((tickToSeconds % 3600) / 60)
    local seconds = math.floor(tickToSeconds % 60)
    return days .. "d " .. hours .. "h " .. minutes .. "m " .. seconds .. "s"
end

local function getEvoAI(universe, evolution_factor, tick)
	if universe.agressiveStart then
		return mMax(evolution_factor,mMin(0.3, 0.1 + 0.2 * tick / 216000))	-- 432000 = 60*60*60
	end
	return evolution_factor
end

local function getMaxActiveRaidNests(universe)
	local activeRaidNests = 0
	for mapId, map in pairs(universe.maps) do
		if map and not map.suspended then
			activeRaidNests = mMax(activeRaidNests, map.activeRaidNests)
		end
	end
	return activeRaidNests
end

function aiPlanning.planningUniverse(universe, evo, tick)
	local evolution_factor = getEvoAI(universe, evo, tick)
    universe.evolutionLevel = evolution_factor	
    local maxPoints = mMax(AI_MAX_POINTS * evolution_factor, MINIMUM_AI_POINTS)
    universe.maxPoints = maxPoints

    local attackWaveMaxSize = config.getAttackWaveMaxSize(universe)
    universe.retreatThreshold = linearInterpolation(evolution_factor,
                                                    RETREAT_MOVEMENT_PHEROMONE_LEVEL_MIN,
                                                    RETREAT_MOVEMENT_PHEROMONE_LEVEL_MAX)
    universe.rallyThreshold = BASE_RALLY_CHANCE + (mMin(evolution_factor, 0.3) * BONUS_RALLY_CHANCE)
	local vengefulnessModifier = settings.global["rampantFixed--vengenceProbabilityPercent"].value*25	-- 0.04 is default
	if vengefulnessModifier ~= 1 then
		universe.rallyThreshold = universe.rallyThreshold * vengefulnessModifier
	end
    universe.formSquadThreshold = mMax((0.35 * evolution_factor), 0.1)
	local thresholdKf = 1 / mMin((1 + universe.retribution*0.01), 2.5)
	universe.raiding_minimum_base_threshold = mFloor(RAIDING_MINIMUM_BASE_THRESHOLD * thresholdKf)
	universe.no_pollution_attack_threshold = mFloor(NO_POLLUTION_ATTACK_THRESHOLD * thresholdKf)		
	
	local newWaveSize
	local evoForMaxWaveSize = mMin(evolution_factor / (universe.attackWaveMaxSizeEvoPercent * 0.01), 1)
	newWaveSize = mMin(mMax(attackWaveMaxSize * (evoForMaxWaveSize ^ 1.4), getMaxActiveRaidNests(universe)*0.02), attackWaveMaxSize)			
	universe.attackWaveSize = newWaveSize + mMin(mFloor(universe.retribution*0.3), 50)	
    if (universe.attackWaveSize < 2) then
        universe.attackWaveSize = 2
	end
	newWaveSize = config.getAttackWaveSize(universe)	-- if universe.externalControlValues.attackWaveSize defined, then use this value
	
	----------
	local aiDifficultySquadCostModifier
	if universe.aiDifficulty == "Hard" then
		aiDifficultySquadCostModifier = 1 + mMax(newWaveSize / attackWaveMaxSize - 0.5, 0)*0.5
	else
		aiDifficultySquadCostModifier = 1 + mMax(newWaveSize / attackWaveMaxSize - 0.3, 0)*2
	end
	aiDifficultySquadCostModifier = aiDifficultySquadCostModifier * mMax(0.99^(mFloor(universe.retribution*0.1)), 0.5)
	universe.finalSquadCost = mFloor(constants.AI_SQUAD_COST * aiDifficultySquadCostModifier)
	universe.finalVengenceSquadCost = mFloor(constants.AI_VENGENCE_SQUAD_COST * aiDifficultySquadCostModifier)
	----------
	
	universe.attackWaveDeviation = (newWaveSize * 0.333)
	universe.attackWaveUpperBound = newWaveSize + (newWaveSize * 0.35)

    universe.settlerWaveSize = linearInterpolation(evolution_factor ^ 1.66667,
                                                   universe.expansionMinSize,
                                                   universe.expansionMaxSize)
    universe.settlerWaveDeviation = (universe.settlerWaveSize * 0.33)

    universe.kamikazeThreshold = NO_RETREAT_BASE_PERCENT + (evolution_factor * NO_RETREAT_EVOLUTION_BONUS_MAX)
	
end


function aiPlanning.updateBasesToGrow(map, tick, ingnoreGrowingState)
	local universe = map.universe
	local basesToGrowSize = 0
	universe.growingBasesIterator = nil	
	-- local basesIdList = ""	-- debug
	for baseId, base in pairs (map.basesToGrow) do
		universe.growingBases[baseId] = nil
		basesToGrowSize = basesToGrowSize + 1
		
		-- -- debug
		-- if basesIdList == "" then
			-- basesIdList = tostring(baseId)
		-- else	
			-- basesIdList = basesIdList .. ", " .. tostring(baseId)	
		-- end
	end
	-- game.print(" aiPlanning.updateBasesToGrow: clear bases, universe.growingBases = "..serpent.dump(universe.growingBases))
	-- game.print(" aiPlanning.updateBasesToGrow: clear bases, map.basesToGrow = "..basesIdList)
	--

	if (basesToGrowSize > 0) and ((map.state == AI_STATE_GROWING) or ingnoreGrowingState)then
		growCnt = mRandom(mMin(basesToGrowSize, 3))
		local growIndexes = mathUtils.getRandomElementIndexes(map.basesToGrow, growCnt)
		-- game.print(" aiPlanning.updateBasesToGrow:growIndexes "..serpent.dump(growIndexes))	-- debug
		for i = 1, #growIndexes do
			local baseId = growIndexes[i]
			universe.growingBases[baseId] = {tick = tick}
			-- game.print("base #"..baseId.." selected to grow")	-- debug
		end	
	end	
end

local function planningMap(map, evolution_factor, tick)
	local activeRaidNests = map.activeRaidNests
	local activeNests =	map.activeNests
    local universe = map.universe
	
    map.evolutionLevel = evolution_factor
	local activeRaidNests_evo = activeRaidNests +  mMin(mFloor(evolution_factor*50), 30)
	
	local noActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_NO_ACTIVE_NESTS))
	local tooLowActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_TOO_LOW_ACTIVE_NESTS))
	local lowActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_LOW_ACTIVE_NESTS))
	local activeNestsModified = mMax(mMin(universe.retribution, 1)*60,  activeNests)
	

    if not map.state then
		map.state = AI_STATE_AGGRESSIVE
	end	
	
    local maxPoints = universe.maxPoints
    local maxOverflowPoints = maxPoints * 3
		
    local points = mMin(universe.evolutionLevel, 1)*100 + (activeNestsModified * 2) + mMin(universe.evolutionLevel*100, activeRaidNests)*0.1       	   	  	
	if (map.temperament < 0.05)	then	-- settlers cost a lot AP
        points = points + 180	
    elseif map.temperament > 0.95 then
        points = points + 120
    elseif (map.temperament < 0.25) or (map.temperament > 0.75) then
        points = points + 90
    elseif (map.temperament < 0.40) or (map.temperament > 0.60) then
        points = points + 60
    end
	if points > 1200 then
		points = 1200
	end

    if (map.state == AI_STATE_ONSLAUGHT) then
        points = points * 2
    end
	
	if (map.pointsTick) and (tick > map.pointsTick) then
		points = math.floor(points * universe.aiPointsScaler * ((tick - map.pointsTick)/360))*0.1
	else
		points = 0
	end
	map.pointsTick = tick

    local currentPoints = map.points

    if (currentPoints < maxPoints) then
        map.points = currentPoints + points
    end

    if (currentPoints > maxOverflowPoints) then
        map.points = maxOverflowPoints
    end
	
	local mapState = map.state
	local mapStateChanged = false
		
	if (map.surface.index == 1) and (map.stateTick == 0) and (tick<=72000) and (universe.peacefulAIToggle) then 
		if not (map.state == AI_STATE_PEACEFUL) and settings.global["rampantFixed--peacePeriod"].value > 0 then
			game.print("<Rampant Fixed>:"..map.surface.name.." surface. Passive mode for the first ".. settings.global["rampantFixed--peacePeriod"].value.." minutes")
			map.state = AI_STATE_PEACEFUL
			map.stateTick = settings.global["rampantFixed--peacePeriod"].value*3600
		end
	elseif (universe.aiNocturnalMode and map.surface.darkness < 0.65) 		-- if daytime and aiNocturnalMode...
		and (tick>216000)
		and universe.siegeAIToggle 
		and (activeRaidNests > 0) 
		then		
		if (map.stateTick <= tick) then
			map.state = AI_STATE_SIEGE
			mapStateChanged = true
		end	
	else	
		if (map.stateTick <= tick) then
			--
			local basesToGrowCnt = table_size(map.basesToGrow)
			--
			local roll = mRandom()
			if (basesToGrowCnt > 0) and (mRandom() < 0.1) and (tick>36000) then	-- dont use "roll" variable here
				map.state = AI_STATE_GROWING
				mapStateChanged = true		
			elseif (map.temperament < 0.05) then -- 0 - 0.05
				if universe.enabledMigration then
					if (roll < 0.7) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					else
						map.state = AI_STATE_MIGRATING
					end
				else
					if universe.raidAIToggle then
						if roll < 0.85 then	
							map.state = AI_STATE_AGGRESSIVE
						else
							map.state = AI_STATE_RAIDING
						end
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			elseif (map.temperament < 0.20) then -- 0.05 - 0.2
				if (universe.enabledMigration) then
					if (roll < 0.4) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.6) and universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_MIGRATING
					end
				else
					if (roll < 0.2) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE				
					elseif universe.raidAIToggle then
						if (roll < 0.95) then
							map.state = AI_STATE_AGGRESSIVE
						else
							map.state = AI_STATE_RAIDING
						end
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			elseif (map.temperament < 0.4) then -- 0.2 - 0.4
				if (universe.enabledMigration) then
					if (roll < 0.2) then
						map.state = AI_STATE_AGGRESSIVE
					elseif (roll < 0.4) and universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					elseif (roll < 0.6) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE				
					elseif (roll < 0.8) then
						map.state = AI_STATE_MIGRATING
					elseif universe.peacefulAIToggle and (map.destroyPlayerBuildings > 0) then
						map.state = AI_STATE_PEACEFUL
					else
						map.state = AI_STATE_MIGRATING
					end
				else
					if (roll < 0.6) then
						map.state = AI_STATE_AGGRESSIVE
					elseif universe.peacefulAIToggle and (map.destroyPlayerBuildings > 0) then
						map.state = AI_STATE_PEACEFUL
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			elseif (map.temperament < 0.6) then -- 0.4 - 0.6
				if (roll < 0.6) then
					map.state = AI_STATE_AGGRESSIVE
				elseif universe.siegeAIToggle and (roll < 0.65) then	
					map.state = AI_STATE_SIEGE			
				elseif universe.peacefulAIToggle and (map.destroyPlayerBuildings > 0) then
					map.state = AI_STATE_PEACEFUL
				else
					if universe.enabledMigration then
						map.state = AI_STATE_MIGRATING
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			elseif (map.temperament < 0.8) then -- 0.6 - 0.8
				if (roll < 0.4) then
					map.state = AI_STATE_AGGRESSIVE
				elseif (roll < 0.6) then
					map.state = AI_STATE_ONSLAUGHT
				elseif (roll < 0.8) then
					if universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_AGGRESSIVE				
					end					
				elseif universe.peacefulAIToggle and (map.destroyPlayerBuildings > 0) then
					map.state = AI_STATE_PEACEFUL
				else
					map.state = AI_STATE_AGGRESSIVE
				end
			elseif (map.temperament < 0.95) then -- 0.8 - 0.95
				if (universe.enabledMigration and universe.raidAIToggle) then
					if (roll < 0.20) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.45) then
						map.state = AI_STATE_RAIDING
					elseif (roll < 0.85) then
						map.state = AI_STATE_ONSLAUGHT
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				elseif (universe.enabledMigration) then
					if (roll < 0.20) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.75) then
						map.state = AI_STATE_ONSLAUGHT
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				elseif (universe.raidAIToggle) then
					if (roll < 0.45) then
						map.state = AI_STATE_ONSLAUGHT
					elseif (roll < 0.75) then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				else
					if (roll < 0.65) then
						map.state = AI_STATE_ONSLAUGHT
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			else
				if (universe.enabledMigration and universe.raidAIToggle) then
					if (roll < 0.30) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.65) then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_ONSLAUGHT
					end
				elseif (universe.enabledMigration) then
					if (roll < 0.30) and universe.siegeAIToggle then
						map.state = AI_STATE_SIEGE
					else
						map.state = AI_STATE_ONSLAUGHT
					end
				elseif (universe.raidAIToggle) then
					if (roll < 0.45) then
						map.state = AI_STATE_ONSLAUGHT
					else
						map.state = AI_STATE_RAIDING
					end
				else
					map.state = AI_STATE_ONSLAUGHT
				end
			end

			

			-- post-processing
			roll = mRandom()
			if map.state == AI_STATE_ONSLAUGHT then
				if activeNests< 70 and (universe.retribution < 1)  then
					map.state = AI_STATE_AGGRESSIVE
				end	
			elseif map.state == AI_STATE_SIEGE then
				-- if tick<=216000 or ((not lowActiveNests) and (activeRaidNests< 40)) then		-- no siege if 1'st hour (60*60*60)
					-- if universe.raidAIToggle and (roll<0.5) then
						-- map.state = AI_STATE_RAIDING
					-- else
						-- map.state = AI_STATE_AGGRESSIVE
					-- end	
				-- end
			else	
				if universe.siegeAIToggle and (tick>216000) then
					if (map.state == AI_STATE_MIGRATING) and lowActiveNests then
						 map.state = AI_STATE_SIEGE
					elseif (map.state == AI_STATE_AGGRESSIVE) and (
						(noActiveNests or (tooLowActiveNests and (roll<0.3)) or (lowActiveNests and (roll< (0.05 + mMin(0.1,activeRaidNests*0.00005)))   ))
						) then	 
						 map.state = AI_STATE_SIEGE
					end
				end	
				if (universe.raidAIToggle) then
					if (map.state == AI_STATE_AGGRESSIVE) 
					and (
						((activeNests == 0) and (activeRaidNests > 0))
						or tooLowActiveNests 
						or ((map.points>=maxPoints*0.9) and ((roll> 0.3) and (roll< 0.6)))
						)
					then
						map.state = AI_STATE_RAIDING
					end			
				end
			end	
			
			if (universe.retribution < 1) and (map.state == AI_STATE_ONSLAUGHT) and (mapState == AI_STATE_ONSLAUGHT) then
				if universe.raidAIToggle then
					map.state = AI_STATE_RAIDING
				else
					map.state = AI_STATE_AGGRESSIVE
				end
			end
			------	
			mapStateChanged = true		
		end
	end	

	if mapStateChanged then
		map.squadsGenerated = 0
		map.destroyPlayerBuildings = 0
		map.lostEnemyUnits = 0
		map.lostEnemyBuilding = 0
		map.rocketLaunched = 0
		map.builtEnemyBuilding = 0
		map.ionCannonBlasts = 0
		map.artilleryBlasts = 0
		
		aiPlanning.updateBasesToGrow(map, tick, false)

		map.stateTick = randomTickEvent(tick, AI_MIN_STATE_DURATION, AI_MAX_STATE_DURATION)
	elseif map.stateTick < tick then
		map.stateTick = randomTickEvent(tick, AI_MIN_STATE_DURATION, AI_MAX_STATE_DURATION)		
	end	
	
			
    if universe.printAIStateChanges and game.tick % 3600 == 0 then
        game.print(map.surface.name .. ": AI is now: " .. constants.stateEnglish[map.state] .. ", Next state change is in " .. string.format("%.2f", (map.stateTick - tick) / (60*60)) .. " minutes @ " .. getTimeStringFromTick(map.stateTick) .. " playtime")
    end
end

local function temperamentPlanner(map)
    local destroyPlayerBuildings = map.destroyPlayerBuildings
    local lostEnemyUnits = map.lostEnemyUnits
    local lostEnemyBuilding = map.lostEnemyBuilding
    local rocketLaunched = map.rocketLaunched
    local builtEnemyBuilding = map.builtEnemyBuilding
    local ionCannonBlasts = map.ionCannonBlasts
    local artilleryBlasts = map.artilleryBlasts
    local activeNests = map.activeNests
    local activeRaidNests = map.activeRaidNests

    local currentTemperament = map.temperamentScore
    local delta = 0
	
	local universe = map.universe
	
	local evoK
	if map.evolutionLevel < 0.3 then
		 evoK = 0.025
	elseif map.evolutionLevel < 0.5 then
		 evoK = 0.0125
	elseif map.evolutionLevel < 0.7 then
		 evoK = 0.00625
	elseif map.evolutionLevel < 0.9 then
		 evoK = 0.003125
	elseif map.evolutionLevel < 0.95 then
		 evoK = 0.0015625
	else
		 evoK = 0.00078125
	end
	local balancingK = 0.5
	local attackWaveSize = config.getAttackWaveSize(universe)
	if attackWaveSize > 0 then
		evoK = balancingK * evoK
	end	
	if universe.aiPointsScaler > 1 then
		evoK = evoK / universe.aiPointsScaler  
	end
	if attackWaveSize > 75 then
		evoK = evoK * (75 / attackWaveSize)		
	end
	local LEU_evo =	lostEnemyUnits * evoK
	
	local AN = mMax(activeNests - destroyPlayerBuildings*0.5 - lostEnemyBuilding*1.5 - LEU_evo, 0)
	local newTemp
	local ARN_AN = 0
	if AN == 0 then 
		ARN_AN = 1000
	else
		ARN_AN = activeRaidNests/AN
	end
	if ARN_AN>=1000 then
		newTemp = 0	
	elseif ARN_AN >= K_NO_ACTIVE_NESTS then		-- 40 - 1000
		local percent = (ARN_AN - K_NO_ACTIVE_NESTS) / (1000 - K_NO_ACTIVE_NESTS)
		newTemp = linearInterpolation(percent, 0.05, 0)	-- ARN_AN = 40 =>0.05, ARN_AN = 1000 => 0
	elseif ARN_AN >= K_TOO_LOW_ACTIVE_NESTS then	-- 20 - 40
		local percent = (ARN_AN - K_TOO_LOW_ACTIVE_NESTS) / (K_NO_ACTIVE_NESTS - K_TOO_LOW_ACTIVE_NESTS)
		newTemp = linearInterpolation(percent, 0.2, 0.05)
	elseif ARN_AN >= K_LOW_ACTIVE_NESTS then		-- 10 - 20
		local percent = (ARN_AN - K_LOW_ACTIVE_NESTS) / (K_TOO_LOW_ACTIVE_NESTS - K_LOW_ACTIVE_NESTS)
		newTemp = linearInterpolation(percent, 0.7, 0.2)
	elseif ARN_AN >= (K_LOW_ACTIVE_NESTS*0.5) then	-- 5 - 10
		local percent = (ARN_AN - (K_LOW_ACTIVE_NESTS*0.5)) / (K_LOW_ACTIVE_NESTS-(K_LOW_ACTIVE_NESTS*0.5))
		newTemp = linearInterpolation(percent, 0.95, 0.7)
	elseif ARN_AN >= 1 then	-- 1 - 5
		local percent = (ARN_AN - 1) / ((K_LOW_ACTIVE_NESTS*0.5)-1)
		newTemp = linearInterpolation(percent, 1, 0.95)
	else	
		newTemp = 1	
	end	
	map.temperament = newTemp
	
    if universe.debugTemperament then
        if game.tick % 1800 == 0 then
            game.print("Rampant Stats:")
            game.print("aN:" .. map.activeNests .. ", aRN:" .. map.activeRaidNests .. ", dPB:" .. map.destroyPlayerBuildings ..
                       ", lEU:" .. map.lostEnemyUnits .."(evoK="..evoK..", LEU_evo:"..LEU_evo.. "), lEB:" .. map.lostEnemyBuilding ..", ARN_AN:"..ARN_AN)
            game.print("temp: " .. map.temperament .. "-->" .. newTemp .. ", points:" .. math.floor(map.points).."/"..math.floor(universe.maxPoints).. ", state:" .. constants.stateEnglish[map.state] .. ", surface:" .. map.surface.index .. " [" .. map.surface.name .. "]")
            game.print("aS:" .. universe.squadCount .. ", aB:" .. universe.builderCount .. ", atkSize:" .. attackWaveSize .. ", stlSize:" .. universe.settlerWaveSize .. ", formGroup:" .. universe.formSquadThreshold
				.. ", Rtrb = "..universe.retribution)
			
			game.print("Next state change is in " .. string.format("%.2f", (map.stateTick - game.tick) / (60*60)))
        end
    end
end

-- universe.evolutionLevel - takes into account the setting "rampantFixed--agressiveStart". Affects squad size and AI behavior
-- map.evolutionLevel - equals the actual evolution. Affects biter tier and nest/worm levels
function aiPlanning.processMapAIs(universe, evo, tick)
	aiPlanning.planningUniverse(universe, evo, tick)
	
    local mapId = universe.processMapAIIterator
	local map
	if not mapId then
        mapId, map = next(universe.maps, nil)
	else
		map = universe.maps[mapId]
	end
	
	local mapCnt = 0
	while mapId do
		if map then
			if not map.suspended then
				planningMap(map, evo, tick)
				temperamentPlanner(map)
			end
		end	
        mapId, map = next(universe.maps, mapId)		
		mapCnt = mapCnt + 1
		if (mapCnt>=15) then
			break
		end
	end
	
	universe.processMapAIIterator = mapId	
end

aiPlanningG = aiPlanning
return aiPlanning
