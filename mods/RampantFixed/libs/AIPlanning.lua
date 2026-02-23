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

local function planningUniverseMap(map, tick)
	local universe = map.universe
	local evo = game.forces.enemy.get_evolution_factor(map.surface)
	local evolution_factor = getEvoAI(universe, evo, tick)
    local maxPoints = mMax(AI_MAX_POINTS * evolution_factor, MINIMUM_AI_POINTS)
    map.maxPoints = maxPoints

    local attackWaveMaxSize = config.getAttackWaveMaxSize(universe)
    map.rallyThreshold = BASE_RALLY_CHANCE + (mMin(evolution_factor, 0.3) * BONUS_RALLY_CHANCE)
	local vengefulnessModifier = settings.global["rampantFixed--vengenceProbabilityPercent"].value*25	-- 0.04 is default
	if vengefulnessModifier ~= 1 then
		map.rallyThreshold = map.rallyThreshold * vengefulnessModifier
	end
    map.formSquadThreshold = mMax((0.35 * evolution_factor), 0.1)
	local thresholdKf = 1 / mMin((1 + map.retribution*0.01), 2.5)
	map.raiding_minimum_base_threshold = mFloor(RAIDING_MINIMUM_BASE_THRESHOLD * thresholdKf)
	map.no_pollution_attack_threshold = mFloor(NO_POLLUTION_ATTACK_THRESHOLD * thresholdKf)		
	
	local newWaveSize
	local evoForMaxWaveSize = mMin(evolution_factor / (universe.attackWaveMaxSizeEvoPercent * 0.01), 1)
	newWaveSize = mMin(mMax(attackWaveMaxSize * (evoForMaxWaveSize ^ 1.4), getMaxActiveRaidNests(universe)*0.02), attackWaveMaxSize)			
	map.attackWaveSize = newWaveSize + mMin(mFloor(map.retribution*0.1), 25)	
    if (map.attackWaveSize < 2) then
        map.attackWaveSize = 2
	end
	newWaveSize = config.getAttackWaveSize(map)	-- if universe.externalControlValues.attackWaveSize defined, then use this value
	
	----------
	local aiDifficultySquadCostModifier
	if universe.aiDifficulty == "Hard" then
		aiDifficultySquadCostModifier = 1 + mMax(newWaveSize / attackWaveMaxSize - 0.5, 0)*0.5
	else
		aiDifficultySquadCostModifier = 1 + mMax(newWaveSize / attackWaveMaxSize - 0.3, 0)*2
	end
	aiDifficultySquadCostModifier = aiDifficultySquadCostModifier * mMax(0.99^(mFloor(map.retribution*0.1)), 0.5)
	map.finalSquadCost = mFloor(constants.AI_SQUAD_COST * aiDifficultySquadCostModifier)
	map.finalVengenceSquadCost = mFloor(constants.AI_VENGENCE_SQUAD_COST * aiDifficultySquadCostModifier)
	----------
	
	map.attackWaveDeviation = (newWaveSize * 0.333)
	map.attackWaveUpperBound = newWaveSize + (newWaveSize * 0.35)

    map.settlerWaveSize = linearInterpolation(evolution_factor ^ 1.66667,
                                                   universe.expansionMinSize,
                                                   universe.expansionMaxSize)
    map.settlerWaveDeviation = (map.settlerWaveSize * 0.33)

    map.kamikazeThreshold = NO_RETREAT_BASE_PERCENT + (evolution_factor * NO_RETREAT_EVOLUTION_BONUS_MAX)
	
end

function aiPlanning.planningUniverse(universe, tick)
	for mapId, map in pairs(universe.maps) do
		if map and not map.suspended then
			planningUniverseMap(map, tick)
		end
	end
end


function aiPlanning.updateBasesToGrow(map, tick, ingnoreGrowingState)
	local universe = map.universe
	local basesToGrowSize = 0
	universe.growingBasesIterator = nil	
	for baseId, base in pairs (map.basesToGrow) do
		if (not base) or (not base.forcedGrowthTick) or (base.forcedGrowthTick < tick) then
			universe.growingBases[baseId] = nil
		end	
		basesToGrowSize = basesToGrowSize + 1
	end
	if (basesToGrowSize > 0) and ((map.state == AI_STATE_GROWING) or ingnoreGrowingState) then
		growCnt = mRandom(mMin(basesToGrowSize, 2), mMin(basesToGrowSize, 4))
		local growIndexes = mathUtils.getRandomElementIndexes(map.basesToGrow, growCnt)
		for i = 1, #growIndexes do
			local baseId = growIndexes[i]
			universe.growingBases[baseId] = {tick = tick}
		 end	
	 end	
end

local function endTruce(map, siegeAIToggle, raidAIToggle)
	if siegeAIToggle then
		map.state = AI_STATE_SIEGE
	elseif raidAIToggle then
		map.state = AI_STATE_RAIDING	
	else
		map.state = AI_STATE_GROWING
	end
	game.print({"description.rampantFixed--peacefullModeEndNotification", map.surface.name})
end

local function planningMap(map, tick)
	local activeRaidNests = map.activeRaidNests
	local activeNests =	map.activeNests
    local universe = map.universe
	
	local evo = game.forces.enemy.get_evolution_factor(map.surface)
	local evolution_factor = getEvoAI(universe, evo, tick)
	
	local activeRaidNests_evo = activeRaidNests +  mMin(mFloor(evolution_factor*50), 30)
	
	local noActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_NO_ACTIVE_NESTS))
	local tooLowActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_TOO_LOW_ACTIVE_NESTS))
	local lowActiveNests = (activeNests < mFloor(activeRaidNests_evo/K_LOW_ACTIVE_NESTS))
	local activeNestsModified = mMax(mMin(map.retribution, 1)*60,  activeNests)
	

    if not map.state then
		map.state = AI_STATE_AGGRESSIVE
	end	
	
    local maxPoints = map.maxPoints
    local maxOverflowPoints = maxPoints * 3
	local points
	
	if not (map.state == AI_STATE_PEACEFUL) then
		points = mMin(evolution_factor, 1)*100 + (activeNestsModified * 2) + mMin(evolution_factor*100, activeRaidNests)*0.1       	   	  	
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
			if map.supressionData and (map.supressionData.supressionEndTick > tick) and (map.supressionData.supressionType > 0) then
				points = math.floor(points*0.3)
			end
		else
			points = 0
		end
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
	local resetNextStateTick = true
	local siegeAIToggle = (universe.siegeAIToggle and map.hasNonmoddedBiters)
	local enabledMigration = (universe.enabledMigration and map.hasNonmoddedBiters)
	
	--------------------
	local truceEvo = 0
	local planetAISetting = universe.planetAISettings[map.surface.name]
	planetAISetting = planetAISetting or universe.planetAISettings["others"]
	if planetAISetting then
		truceEvo = planetAISetting.minEvo * 0.01
		local truceEndTick = map.firstStateTick + planetAISetting.peacePeriod * 3600		
		-----------------
		if ((truceEvo > evo) or (truceEndTick > tick)) then
			if not (map.state == constants.AI_STATE_PEACEFUL) then
				map.state = constants.AI_STATE_PEACEFUL
				map.truceEndTick = truceEndTick
				map.stateTick = mMax(truceEndTick, tick + 3600)
				mapStateChanged = true
				resetNextStateTick = false
				map.points = 400
				local truceLeft = mMax(math.floor((truceEndTick+5 - tick) / 3600), 0)
				if truceLeft > 0 then
					game.print({"description.rampantFixed--peacefullModeNotification", map.surface.name, truceLeft, planetAISetting.minEvo})
				else
					game.print({"description.rampantFixed--peacefullMode_LowEvoNotification", map.surface.name, planetAISetting.minEvo})
				end
			elseif (map.stateTick <= tick) then
				map.stateTick = mMax(truceEndTick, tick + 3600)
			end	
		elseif (map.state == constants.AI_STATE_PEACEFUL) then
			if (tick >= truceEndTick) and (evo >= truceEvo) then
				endTruce(map, siegeAIToggle,  universe.raidAIToggle)
				-- if siegeAIToggle then
					-- map.state = AI_STATE_SIEGE
				-- elseif universe.raidAIToggle then
					-- map.state = AI_STATE_RAIDING	
				-- else
					-- map.state = AI_STATE_GROWING
				-- end
				mapStateChanged = true
				resetNextStateTick = true
				-- game.print({"description.rampantFixed--peacefullModeEndNotification", map.surface.name})
			elseif	(tick >= truceEndTick) then
				if (map.stateTick <= tick) then
					map.stateTick = tick + 3600 				
					mapStateChanged = true	
					resetNextStateTick = false
				end	
			end
		end
	elseif (tick >= truceEndTick) and (map.state == constants.AI_STATE_PEACEFUL) then
		endTruce(map, siegeAIToggle,  universe.raidAIToggle)
		mapStateChanged = true
		resetNextStateTick = true	
	end	
	--------------------

	if not mapStateChanged then
		if universe.aiNocturnalMode 
			and siegeAIToggle
			and (map.stateTick <= tick)
			then
			local switchToSiege = false
			if map.temperament < 0.8 then
				if (map.surface.darkness < 0.65)	 --- if daytime and aiNocturnalMode...
					and ((activeRaidNests > 0) or (activeNests > 0))
					then
					switchToSiege = true
				elseif(universe.squadCount >= (universe.AI_MAX_SQUAD_COUNT*0.7))
					and (mRandom() < 0.5) then
					switchToSiege = true
				end
			end	
			if switchToSiege then
				map.state = AI_STATE_SIEGE
				mapStateChanged = true
				resetNextStateTick = true
			end
		end	
	end	

	if not mapStateChanged then
		if (map.stateTick <= tick) then
			--
			local basesToGrowCnt = table_size(map.basesToGrow)			
			--
			local roll = mRandom()
			if (evo < constants.highEvo) and (basesToGrowCnt > 0) and (mRandom() < 0.13) and (tick>36000) then	-- dont use "roll" variable here
				map.state = AI_STATE_GROWING
				mapStateChanged = true
			-- elseif (map.temperament < 0.7) and siegeAIToggle and (map.siegeTick <= tick) then
				-- mapStateChanged = true
				-- map.state = AI_STATE_SIEGE
			elseif (map.temperament < 0.05) then -- 0 - 0.05
				if enabledMigration then
					if (roll < 0.7) and siegeAIToggle then
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
				if (enabledMigration) then
					if (roll < 0.4) and siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.6) and universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_MIGRATING
					end
				else
					if (roll < 0.2) and siegeAIToggle then
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
				if (enabledMigration) then
					if (roll < 0.2) then
						map.state = AI_STATE_AGGRESSIVE
					elseif (roll < 0.4) and universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					elseif (roll < 0.6) and siegeAIToggle then
						map.state = AI_STATE_SIEGE				
					elseif (roll < 0.8) then
						map.state = AI_STATE_MIGRATING
					elseif (basesToGrowCnt > 0) then
						map.state = AI_STATE_GROWING
					else
						map.state = AI_STATE_MIGRATING
					end
				else
					if (roll < 0.7) then
						map.state = AI_STATE_AGGRESSIVE
					elseif (roll < 0.8) and universe.raidAIToggle then
						map.state = AI_STATE_RAIDING
					elseif (basesToGrowCnt > 0) and (roll < 0.9) then
						map.state = AI_STATE_GROWING
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				end
			elseif (map.temperament < 0.6) then -- 0.4 - 0.6
				if (roll < 0.6) then
					map.state = AI_STATE_AGGRESSIVE
				elseif siegeAIToggle and (roll < 0.65) then	
					map.state = AI_STATE_SIEGE			
				else
					if enabledMigration then
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
				else
					map.state = AI_STATE_AGGRESSIVE
				end
			elseif (map.temperament < 0.95) then -- 0.8 - 0.95
				if (enabledMigration and universe.raidAIToggle) then
					if (roll < 0.20) and siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.45) then
						map.state = AI_STATE_RAIDING
					elseif (roll < 0.85) then
						map.state = AI_STATE_ONSLAUGHT
					else
						map.state = AI_STATE_AGGRESSIVE
					end
				elseif (enabledMigration) then
					if (roll < 0.20) and siegeAIToggle then
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
				if (enabledMigration and universe.raidAIToggle) then
					if (roll < 0.30) and siegeAIToggle then
						map.state = AI_STATE_SIEGE
					elseif (roll < 0.65) then
						map.state = AI_STATE_RAIDING
					else
						map.state = AI_STATE_ONSLAUGHT
					end
				elseif (enabledMigration) then
					if (roll < 0.30) and siegeAIToggle then
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
				if activeNests< 70 and (map.retribution < 1)  then
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
				if siegeAIToggle and (tick>216000) then
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
			
			if (map.retribution < 1) and (map.state == AI_STATE_ONSLAUGHT) and (mapState == AI_STATE_ONSLAUGHT) then
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
		if (map.state == AI_STATE_SIEGE) then
			map.siegeTick = tick + 2 * 60*60*60
		end
		map.squadsGenerated = 0
		map.destroyPlayerBuildings = 0
		map.lostEnemyUnits = 0
		map.lostEnemyBuilding = 0
		map.rocketLaunched = 0
		map.builtEnemyBuilding = 0
		map.ionCannonBlasts = 0
		map.artilleryBlasts = 0
		
		if evo >= constants.highEvo then
			aiPlanning.updateBasesToGrow(map, tick, true)
		else
			aiPlanning.updateBasesToGrow(map, tick, false)
		end	
		if resetNextStateTick then
			map.stateTick = randomTickEvent(tick, AI_MIN_STATE_DURATION, AI_MAX_STATE_DURATION)
		end	
	elseif map.stateTick < tick then
		if resetNextStateTick then
			map.stateTick = randomTickEvent(tick, AI_MIN_STATE_DURATION, AI_MAX_STATE_DURATION)		
		end	
	end	
				
    if universe.printAIStateChanges and (game.tick % 3600 == 0) then
        game.print(map.surface.name .. ": AI is now: " .. constants.stateEnglish[map.state] .. ", Next state change is in " .. string.format("%.2f", (map.stateTick - tick) / (60*60)) .. " minutes @ " .. getTimeStringFromTick(map.stateTick) .. " playtime")
    end
end

local function temperamentPlanner(map)
    local destroyPlayerBuildings = map.destroyPlayerBuildings
    local lostEnemyUnits = map.lostEnemyUnits
    local lostEnemyBuilding = map.lostEnemyBuilding
    local builtEnemyBuilding = map.builtEnemyBuilding
    local ionCannonBlasts = map.ionCannonBlasts
    local artilleryBlasts = map.artilleryBlasts
    local activeNests = map.activeNests
    local activeRaidNests = map.activeRaidNests

    local currentTemperament = map.temperamentScore
    local delta = 0
	
	local universe = map.universe
	
	local evoK
	local evolutionLevel = game.forces.enemy.get_evolution_factor(map.surface)
	if evolutionLevel < 0.3 then
		 evoK = 0.025
	elseif evolutionLevel < 0.5 then
		 evoK = 0.0125
	elseif evolutionLevel < 0.7 then
		 evoK = 0.00625
	elseif evolutionLevel < 0.9 then
		 evoK = 0.003125
	elseif evolutionLevel < 0.95 then
		 evoK = 0.0015625
	else
		 evoK = 0.00078125
	end
	local balancingK = 0.5
	local attackWaveSize = config.getAttackWaveSize(map)
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
	
	-- local AN = mMax(activeNests - destroyPlayerBuildings*0.5 - lostEnemyBuilding*1.5 - LEU_evo, 0)
	local AN = activeNests
	local newTemp
	local ARN_AN = 0
	if AN == 0 then 
		ARN_AN = 1000
	else
		ARN_AN = (activeRaidNests)/AN
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
            game.print("temp: " .. map.temperament .. "-->" .. newTemp .. ", points:" .. math.floor(map.points).."/"..math.floor(map.maxPoints).. ", state:" .. constants.stateEnglish[map.state] .. ", surface:" .. map.surface.index .. " [" .. map.surface.name .. "]")
            game.print("aS:" .. universe.squadCount .. ", aB:" .. universe.builderCount .. ", atkSize:" .. attackWaveSize .. ", stlSize:" .. map.settlerWaveSize .. ", formGroup:" .. map.formSquadThreshold
				.. ", Rtrb = "..map.retribution)
            game.print("gTk="..game.tick..", stTk="..map.stateTick..", trEt="..map.truceEndTick..", nDAT = "..map.nextDemolisherAttackTick)
			game.print("next squad is: "..tostring(map.nextSquad))
			game.print("Next state change is in " .. string.format("%.2f", (map.stateTick - game.tick) / (60*60)))
          end
    end
end

function aiPlanning.processMapAIs(universe, tick)
	aiPlanning.planningUniverse(universe, tick)
	
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
				planningMap(map, tick)
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
