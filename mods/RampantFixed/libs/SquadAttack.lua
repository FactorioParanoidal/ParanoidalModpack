if (squadAttackG) then
    return squadAttackG
end
local squadAttack = {}

-- imports

local constants = require("Constants")
local customAlerts = require("CustomAlerts")
local mapUtils = require("MapUtils")
local movementUtils = require("MovementUtils")
local mathUtils = require("MathUtils")
local chunkPropertyUtils = require("ChunkPropertyUtils")
local scoreChunks = require("ScoreChunks")
local squadCompression = require("SquadCompression")
local aiBrain = require("AIBrain")


-- constants

local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local BASE_PHEROMONE = constants.BASE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local RESOURCE_PHEROMONE = constants.RESOURCE_PHEROMONE
local PLAYER_PHEROMONE_GENERATOR_AMOUNT = constants.PLAYER_PHEROMONE_GENERATOR_AMOUNT
local MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK = constants.MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK


local TEN_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.TEN_DEATH_PHEROMONE_GENERATOR_AMOUNT
local FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT
local SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT = constants.SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT


local SQUAD_BUILDING = constants.SQUAD_BUILDING

local SQUAD_RAIDING = constants.SQUAD_RAIDING
local SQUAD_SETTLING = constants.SQUAD_SETTLING
local SQUAD_GUARDING = constants.SQUAD_GUARDING
local SQUAD_RETREATING = constants.SQUAD_RETREATING

local AI_STATE_SIEGE = constants.AI_STATE_SIEGE

local PLAYER_PHEROMONE_MULTIPLER = constants.PLAYER_PHEROMONE_MULTIPLER

local DEFINES_DISTRACTION_NONE = defines.distraction.none
local DEFINES_DISTRACTION_BY_ENEMY = defines.distraction.by_enemy
local DEFINES_DISTRACTION_BY_ANYTHING = defines.distraction.by_anything
local DEFINES_DISTRACTION_BY_DAMAGE = defines.distraction.by_damage	-- + !КДА 

-- imported functions
local showAlert = customAlerts.showAlert

local euclideanDistancePoints = mathUtils.euclideanDistancePoints

local findMovementPosition = movementUtils.findMovementPosition

local removeSquadFromChunk = chunkPropertyUtils.removeSquadFromChunk
local addDeathGenerator = chunkPropertyUtils.addDeathGenerator
local getDeathGenerator = chunkPropertyUtils.getDeathGenerator

local getNestCount = chunkPropertyUtils.getNestCount

local getNeighborChunks = mapUtils.getNeighborChunks
local addSquadToChunk = chunkPropertyUtils.addSquadToChunk
local getChunkByXY = mapUtils.getChunkByXY
local positionToChunkXY = mapUtils.positionToChunkXY
local addMovementPenalty = movementUtils.addMovementPenalty
local positionFromDirectionAndFlat = mapUtils.positionFromDirectionAndFlat


local euclideanDistanceNamed = mathUtils.euclideanDistanceNamed


local getPlayerBaseGenerator = chunkPropertyUtils.getPlayerBaseGenerator
local getResourceGenerator = chunkPropertyUtils.getResourceGenerator

local scoreNeighborsForAttack = movementUtils.scoreNeighborsForAttack
local scoreNeighborsForSettling = movementUtils.scoreNeighborsForSettling
local scoreNeighborsForRetreat = movementUtils.scoreNeighborsForRetreat
local getSquadsOnChunk = chunkPropertyUtils.getSquadsOnChunk
local getPlayerTurretCount = chunkPropertyUtils.getPlayerTurretCount

local scoreResourceLocationKamikaze = scoreChunks.scoreResourceLocationKamikaze
local scoreSiegeLocation = scoreChunks.scoreSiegeLocation
local scoreSiegeLocationKamikaze = scoreChunks.scoreSiegeLocationKamikaze
local scoreResourceLocation = scoreChunks.scoreResourceLocation
local scoreAttackLocation = scoreChunks.scoreAttackLocation
local scoreAttackKamikazeLocation = scoreChunks.scoreAttackKamikazeLocation

local validSiegeLocation = scoreChunks.validSiegeLocation
local validSettlerLocation = scoreChunks.validSettlerLocation

local processCompression = squadCompression.processCompression
local clearComresseData = squadCompression.clearComresseData

local mCeil = math.ceil
local mSqrt = math.sqrt
local mRandom = math.random

------------------squadCompression---------------------------------------

---------------------------------------------------------------------------

local function settleHere(map, group, squad, dontDistract)
	if not squad then
		return
	end	
    local universe = map.universe
    local targetPosition = universe.position
    local surface = map.surface
	--------- purple cloud
    local targetPosition = universe.position
    targetPosition.x = group.position.x
    targetPosition.y = group.position.y

    if universe.aiPointsPrintSpendingToChat then
        game.print("Settled: [gps=" .. targetPosition.x .. "," .. targetPosition.y .. "," .. group.surface.name .."]")		
    end
    group.surface.create_entity(universe.createBuildCloudQuery)	
	---------

	local cmd = {type = defines.command.stop, ticks_to_wait = 3600*10}
	if squad.kamikaze or dontDistract then
		cmd.distraction = DEFINES_DISTRACTION_NONE
	else
		cmd.distraction = DEFINES_DISTRACTION_BY_ENEMY
	end
	squad.status = SQUAD_BUILDING

	if squad.compressed then
		squadCompression.squadDecompress(universe, surface, squad, group)
	end	
	
	-- AI bug. if some non-default units ignore build_base command. Also, this destroy group after some failed commands
	-- also, group cam cancel building after 1st builded nest. so, lets build by replacing unit by nest/worm
	universe.builderSquads[squad] = {builded = 0, nextTick = game.tick + 5*60}
	
	group.set_command(cmd)
	squad.onTheWay = true
	squad.nextCommandTick = game.tick + 36000	
 	squad.checkTick = game.tick + 36000	-- some groups get stuck 
	
	if not squad.excluded then
		if squad.settlers then
			universe.builderCount = universe.builderCount - 1
		else
			universe.squadCount = universe.squadCount - 1
		end
		squad.excluded = true
	end	

	
end

local function goToLastvalidSettlerLocation(universe, group, squad)
	local cmd = universe.compoundMoveCommand
	cmd.commands[2].destination.x = squad.lastValidChunk.x
	cmd.commands[2].destination.y = squad.lastValidChunk.y
	group.set_command(cmd)
	squad.onTheWay = true

	squad.settleFirstChance	= true
	--game.print("settle ("..groupPosition.x..","..groupPosition.y..") - maxDistance, last valid chunk ("..squad.lastValidChunk.x..","..squad.lastValidChunk.y..")")			
	squad.lastValidChunk = nil
	squad.nextCommandTick = game.tick + 120	
 	squad.checkTick = game.tick + 18000 	
end

local function settleMove(map, squad)
	if not squad then
		return
	end	

    local universe = map.universe
    local targetPosition = universe.position
    local targetPosition2 = universe.position2
    local group = squad.group

    local groupPosition = group.position
    local x, y = positionToChunkXY(groupPosition)
    local chunk = getChunkByXY(map, x, y)
    local scoreFunction = scoreResourceLocation
 	local validFunction = validSettlerLocation
    if squad.siege then
		validFunction = validSiegeLocation
        if squad.kamikaze then
            scoreFunction = scoreSiegeLocationKamikaze
        else
            scoreFunction = scoreSiegeLocation
        end
    elseif squad.kamikaze then
        scoreFunction = scoreResourceLocationKamikaze
    end
	
	if chunk==-1 then	--bitters found unregistered chunk, and stopped on it... yes, this is really possible...
		chunk = squad.prevChunk
	end
    addDeathGenerator(map, chunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)			-- FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT
    addSquadToChunk(map, chunk, squad)
	if squad.prevChunk and (chunk == squad.prevChunk) then
		--game.print("settleMove, chunk = squad.prevChunk ("..chunk.x..","..chunk.y..")")	-- debug
	else	
		if validFunction(map, chunk) then
			squad.lastValidChunk = chunk
		end	
		addMovementPenalty(squad, chunk)
	end
    local distance = euclideanDistancePoints(groupPosition.x,
                                             groupPosition.y,
                                             squad.originPosition.x,
                                             squad.originPosition.y)
    local cmd
    local position
    local surface = map.surface

	if squad.settleFirstChance 
		and squad.lastValidChunk 
		and ((squad.lastValidChunk.x == chunk.x) and (squad.lastValidChunk.y == chunk.y))
		then
		settleHere(map, group, squad, true)
	elseif distance >= squad.maxDistance then
		if getNestCount(map, chunk) == 0 then
			settleHere(map, group, squad)
		elseif squad.lastValidChunk then
			goToLastvalidSettlerLocation(universe, group, squad)
		else
			squad.settleFirstChance	= true						--------------------------------------------------------------
			squad.maxDistance = squad.maxDistance + 1
		end
	elseif (getResourceGenerator(map, chunk) ~= 0) and (getNestCount(map, chunk) == 0) then
		settleHere(map, group, squad)
    else
        local attackChunk,
            attackDirection,
            nextAttackChunk,
            nextAttackDirection = scoreNeighborsForSettling(map,
                                                            chunk,
                                                            getNeighborChunks(map, x, y),
                                                            scoreFunction)
		local prevChunk 
		if not (squad.prevChunk and (squad.prevChunk ~= -1)) then
			prevChunk = {x = 1, y = 1}	-- we never find chunk(x=1, y=1) becouse coordinates are multiples of 32
		else
			prevChunk = squad.prevChunk
		end
		if (attackDirection ~= 0) and (prevChunk.x == attackChunk.x) and (prevChunk.y == attackChunk.y) then
			if (getNestCount(map, chunk) == 0) then
				settleHere(map, group, squad, true)
			elseif squad.lastValidChunk then
				goToLastvalidSettlerLocation(universe, group, squad)
			else
				settleHere(map, group, squad, true)
			end
		else
			if (attackChunk == -1) then
				settleHere(map, group, squad, true)
			elseif (attackDirection ~= 0) then
				local attackPlayerThreshold = universe.attackPlayerThreshold

				if (nextAttackChunk ~= -1) then
					attackChunk = nextAttackChunk
					positionFromDirectionAndFlat(attackDirection, groupPosition, targetPosition)
					positionFromDirectionAndFlat(nextAttackDirection, targetPosition, targetPosition2)
					position = findMovementPosition(surface, targetPosition2)
				else
					positionFromDirectionAndFlat(attackDirection, groupPosition, targetPosition)
					position = findMovementPosition(surface, targetPosition)
				end

				if position then
					targetPosition.x = position.x
					targetPosition.y = position.y
					if nextAttackChunk then
						addDeathGenerator(map, nextAttackChunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)			-- FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT
					else
						addDeathGenerator(map, attackChunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)			-- FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT
					end
				end

				if (getPlayerBaseGenerator(map, attackChunk) ~= 0) or
					(attackChunk[PLAYER_PHEROMONE] >= attackPlayerThreshold)
				then
					cmd = universe.compoundAttackCommand

					if not squad.rabid then
						squad.frenzy = true
						squad.frenzyPosition.x = groupPosition.x
						squad.frenzyPosition.y = groupPosition.y
					end
				else
					cmd = universe.compoundMoveCommand
					if squad.rabid or squad.kamikaze then
						cmd.commands[2].distraction = DEFINES_DISTRACTION_NONE
					else
						cmd.commands[2].distraction = DEFINES_DISTRACTION_BY_DAMAGE	-- DEFINES_DISTRACTION_BY_ENEMY
					end
				end
				group.set_command(cmd)
				squad.onTheWay = true
				squad.checkTick = game.tick + 18000 	
			else
				settleHere(map, group, squad, true)
			end
		end	
		squad.prevChunk = chunk	-- prevent 1-2-1-2-1-2-1.. moving
    end
end

local function applySpeedBuffToGroup(group)
	if (not group) or (not group.valid) then
		return
	end	
	local stickerName
	for _, entity in pairs(group.members) do
		if entity.valid and (entity.type == "unit") then
			stickerName = "2xSpeed-sticker-rampantFixed"
			if entity.speed < 0.8 then
				stickerName = "3xSpeed-sticker-rampantFixed"
			end
			-- if entity.speed >= 0.2 then		
				-- stickerName = "2xSpeed-sticker-rampantFixed"
			-- elseif entity.speed > 0.13 then
				-- stickerName = "3xSpeed-sticker-rampantFixed"
			-- elseif entity.speed > 0.1 then
				-- stickerName = "4xSpeed-sticker-rampantFixed"
			-- else	--if entity.speed > 0.8 then
				-- stickerName = "5xSpeed-sticker-rampantFixed"
			-- else
				-- stickerName = "6xSpeed-sticker-rampantFixed"
			-- else
				-- stickerName = "10xSpeed-sticker-rampantFixed"
			--end
		
		entity.surface.create_entity({name= stickerName, force = entity.force, position = entity.position, target = entity})
	
		end
	end
end

-- create non-rampant group and set command to create base. Original group has at least 1 member after this
local function partiallySettleHere(map, group, squad, numSettlers)
	if not squad then
		return
	end	
	if not map.hasNonmoddedBiters then
		return
	end
	local members = group.members
	if #members == 0 then
		return
	end
	local surface = map.surface
	local universe = map.universe
	if squad.compressed then
		squadCompression.squadDecompress(universe, surface, squad, group)
	end	

	local newGroup = surface.create_unit_group({position=group.position, force = group.force})
	local evo = group.force.get_evolution_factor(surface)
	local newEntityName
	if evo >= 0.9 then
		newEntityName = "behemoth-spitter"
	elseif evo >= 0.6 then
		newEntityName = "big-spitter"
	elseif evo >= 0.3 then
		newEntityName = "medium-spitter"
	else
		newEntityName = "small-spitter"
	end
	
    local targetPosition = universe.position
	targetPosition.x = group.position.x
	targetPosition.y = group.position.y
	local members = group.members
	-- decompression is gradual: units still held in packs count as members, and settlers are taken from packs first
	local membersTotal = #members + squadCompression.countPackedUnits(universe, members)
	if numSettlers >= membersTotal then
		numSettlers = membersTotal - 1
	end
	for _, entity in pairs(members) do
		if numSettlers <= 0 then
			break
		end
		while (numSettlers > 0) and entity.valid and (entity.type == "unit") do
			 local newEntity = surface.create_entity({
				name = newEntityName,
				quality = entity.quality,
				direction = entity.direction,
				position = entity.position, 
				force = entity.force,
				})
			if not (newEntity and newEntity.valid) then
				break
			end
			newGroup.add_member(newEntity)
			surface.create_trivial_smoke({name = "digIn-dust-nonTriggerCloud-rampant", position = entity.position})
			numSettlers = numSettlers - 1
			if not squadCompression.takeUnitFromPack(universe, entity) then
				entity.destroy()
			end
		end
	end
	
	if #newGroup.members > 0 then
		universe.settleCommand.distraction = DEFINES_DISTRACTION_BY_ENEMY
		local cmd = universe.compoundSettleCommand
		newGroup.set_command(cmd)	
	end
end

----------------------------------------------------------------------------------------------------------------------
-- Reforged Paranoidal: squads with a goal (AIBrain doctrines) and retreats

-- goal of the squad being moved; scoreGoalLocation reads it (set right before scoring, no closures)
local goalX = 0
local goalY = 0
local goalAvoidDanger = false

-- closer to the goal is better; unless the squad dashes, it skirts player turrets on the way
local function scoreGoalLocation(map, neighborChunk)
	local dx = neighborChunk.x + 16 - goalX
	local dy = neighborChunk.y + 16 - goalY
	local score = -mSqrt(dx * dx + dy * dy)
	if goalAvoidDanger then
		score = score - getPlayerTurretCount(map, neighborChunk) * 40
		if neighborChunk[BASE_DETECTION_PHEROMONE] >= MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK then
			score = score - 64
		end
	end
	return score
end

local function setMoveCommand(universe, group, squad, quiet)
	local cmd = universe.compoundMoveCommand
	if quiet or squad.rabid or squad.kamikaze then
		cmd.commands[2].distraction = DEFINES_DISTRACTION_NONE
	else
		cmd.commands[2].distraction = DEFINES_DISTRACTION_BY_DAMAGE
	end
	group.set_command(cmd)
	if group.valid then	-- the engine drops an emptied group on a new command
		group.start_moving()
	end
end

local function commandIssued(squad, tick)
	squad.nextCommandTick = tick + 60
	squad.checkTick = tick + 18000	-- some groups get stuck
	squad.onTheWay = true
end

-- Moves a squad towards squad.goal. Returns false when the goal is reached or dropped
-- (the caller then continues with the ordinary scent-following attack).
local function goalMove(map, squad, group, chunk, groupPosition)
	local goal = squad.goal
	local universe = map.universe
	local tick = game.tick
	if goal.untilTick < tick then
		squad.goal = nil
		return false
	end
	local dx = goal.x - groupPosition.x
	local dy = goal.y - groupPosition.y
	local distance = mSqrt(dx * dx + dy * dy)
	local kind = goal.kind
	if distance <= goal.reach then
		if kind == "strike" then
			-- hit the target area itself
			squad.goal = nil
			local targetPosition = universe.position
			targetPosition.x = goal.x
			targetPosition.y = goal.y
			if not squad.rabid then
				squad.frenzy = true
				squad.frenzyPosition.x = groupPosition.x
				squad.frenzyPosition.y = groupPosition.y
			end
			group.set_command(universe.compoundAttackCommand)
			if group.valid then
				group.start_moving()
			end
			commandIssued(squad, tick)
			return true
		elseif kind == "ambush" then
			-- wait for the player or a train to come by
			squad.goal = nil
			local wait = goal.wait or 10800
			group.set_command({type = defines.command.stop, ticks_to_wait = wait, distraction = DEFINES_DISTRACTION_BY_ENEMY})
			commandIssued(squad, tick)
			squad.checkTick = tick + wait + 18000
			-- after the wait: a weak spot nearby (ambush sites are often too far from the base for its scent)
			local entry = aiBrain.pickWeakTarget(map, goal.x, goal.y, 16 * 32)
			if entry then
				squad.pendingGoal = {x = entry.chunk.x + 16, y = entry.chunk.y + 16, kind = "strike", reach = 40,
									 untilTick = tick + wait + 5 * 3600}
			end
			return true
		elseif kind == "stage" then
			if aiBrain.heavy and aiBrain.heavy.onStageReached(map, squad, group, tick) then
				return true	-- holding until the other arm arrives
			end
			if squad.goal ~= goal then
				return goalMove(map, squad, group, chunk, groupPosition)	-- the wave was released: strike now
			end
		end
		-- approach waypoint reached (or a stage of a wave that is gone): attack from here
		squad.goal = nil
		return false
	end

	goalX = goal.x
	goalY = goal.y
	goalAvoidDanger = not goal.dash
	local x, y = positionToChunkXY(groupPosition)
	local stepChunk, stepDirection, nextStepChunk, nextStepDirection = scoreNeighborsForRetreat(chunk,
		getNeighborChunks(map, x, y), scoreGoalLocation, map)
	local targetPosition = universe.position
	local position
	if (distance < 72) or (stepChunk == -1) then
		-- close, or no registered chunk around (water, unscanned land): straight there
		targetPosition.x = goal.x
		targetPosition.y = goal.y
		position = findMovementPosition(map.surface, targetPosition)
	elseif (nextStepChunk ~= -1) then
		positionFromDirectionAndFlat(stepDirection, groupPosition, targetPosition)
		positionFromDirectionAndFlat(nextStepDirection, targetPosition, universe.position2)
		position = findMovementPosition(map.surface, universe.position2)
	else
		positionFromDirectionAndFlat(stepDirection, groupPosition, targetPosition)
		position = findMovementPosition(map.surface, targetPosition)
	end
	if not position then
		squad.goal = nil
		return false
	end
	targetPosition.x = position.x
	targetPosition.y = position.y
	if (chunk ~= -1) and (chunk[BASE_DETECTION_PHEROMONE] < (MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK*0.1))
		and (chunk[PLAYER_PHEROMONE] < (PLAYER_PHEROMONE_GENERATOR_AMOUNT*0.02)) then
		applySpeedBuffToGroup(group)
	end
	setMoveCommand(universe, group, squad, goal.dash)
	commandIssued(squad, tick)
	return true
end

local function scoreRetreatLocation(map, neighborChunk)
	return -neighborChunk[BASE_DETECTION_PHEROMONE]
		- getDeathGenerator(map, neighborChunk)
		- (neighborChunk[PLAYER_PHEROMONE] * PLAYER_PHEROMONE_MULTIPLER)
		- (getPlayerBaseGenerator(map, neighborChunk, BASE_PHEROMONE) * 1000)
end

-- Pulls a beaten squad two chunks back from the fight; after a short pause it regroups (squadDispatch).
function squadAttack.retreatSquad(map, squad)
	local group = squad.group
	if not (group and group.valid) then
		return false
	end
	local universe = map.universe
	local groupPosition = group.position
	local x, y = positionToChunkXY(groupPosition)
	local chunk = getChunkByXY(map, x, y)
	local exitChunk, exitDirection, nextExitChunk, nextExitDirection = scoreNeighborsForRetreat(chunk,
		getNeighborChunks(map, x, y), scoreRetreatLocation, map)
	if exitChunk == -1 then
		return false
	end
	local targetPosition = universe.position
	local position
	if (nextExitChunk ~= -1) then
		positionFromDirectionAndFlat(exitDirection, groupPosition, targetPosition)
		positionFromDirectionAndFlat(nextExitDirection, targetPosition, universe.position2)
		position = findMovementPosition(map.surface, universe.position2)
	else
		positionFromDirectionAndFlat(exitDirection, groupPosition, targetPosition)
		position = findMovementPosition(map.surface, targetPosition)
	end
	if not position then
		return false
	end
	squad.retreated = (squad.retreated or 0) + 1
	squad.status = SQUAD_RETREATING
	squad.regroup = true
	squad.frenzy = false
	squad.goal = nil
	group.set_command({
		type = defines.command.compound,
		structure_type = defines.compound_command.return_last,
		commands = {
			{type = defines.command.go_to_location, destination = {x = position.x, y = position.y}, radius = 6,
			 distraction = DEFINES_DISTRACTION_NONE},
			{type = defines.command.stop, ticks_to_wait = 900 + mRandom(900), distraction = DEFINES_DISTRACTION_BY_ENEMY}
		}
	})
	commandIssued(squad, game.tick)
	aiBrain.debugPrint(map, tostring(squad.tactic) .. " squad retreats after losing " .. tostring(squad.losses) .. "/"
		.. tostring(squad.startSize) .. " [gps=" .. math.floor(groupPosition.x) .. "," .. math.floor(groupPosition.y) .. "," .. map.surface.name .. "]")
	return true
end

-- another attack squad on the same or a neighbouring chunk
local function findRegroupPartner(map, squad)
	local chunk = squad.chunk
	if (not chunk) or (chunk == -1) then
		return nil
	end
	local function suitable(other)
		return (other ~= squad) and other.group and other.group.valid and (not other.settlers) and (not other.flight)
			and (not other.excluded) and (not other.merged) and (other.status ~= SQUAD_RETREATING)
			and (other.status ~= SQUAD_BUILDING) and (other.map == map)
	end
	for _, other in pairs(getSquadsOnChunk(map, chunk)) do
		if suitable(other) then
			return other
		end
	end
	local neighbors = getNeighborChunks(map, chunk.x, chunk.y)
	for i = 1, 8 do
		local neighbor = neighbors[i]
		if neighbor ~= -1 then
			for _, other in pairs(getSquadsOnChunk(map, neighbor)) do
				if suitable(other) then
					return other
				end
			end
		end
	end
	return nil
end

local function attackMove(map, squad)
	if not squad then
		return
	end	

    local universe = map.universe
    local targetPosition = universe.position
    local targetPosition2 = universe.position2

    local group = squad.group

    local surface = map.surface
    local position
    local groupPosition = group.position
    local x, y = positionToChunkXY(groupPosition)
    local chunk = getChunkByXY(map, x, y)
    local attackScorer = scoreAttackLocation
    if squad.kamikaze then
        attackScorer = scoreAttackKamikazeLocation
    end
	local brainOn = aiBrain.active(universe)

	-- doctrine goal first: approach waypoint, target, ambush site or pincer stage
	if brainOn and (squad.goal or squad.pendingGoal) then
		if not squad.goal then
			squad.goal = squad.pendingGoal
			squad.pendingGoal = nil
		end
		processCompression(map, squad, chunk, true)
		addSquadToChunk(map, chunk, squad)
		if goalMove(map, squad, group, chunk, groupPosition) then
			return
		end
	end
		
	if (chunk ~= -1) and (chunk[PLAYER_PHEROMONE] == 0) and (chunk[BASE_DETECTION_PHEROMONE] == 0) then
		if not squad.checkTick or ((game.tick + 600) < squad.checkTick) then
			squad.checkTick = game.tick + 600
		end	
		return
	end
		
	-- bridgehead: a squad that destroyed enough turns part of itself into a nest (heavy script)
	if not squad.hasSpiders and squad.kills and (squad.kills>5) and aiBrain.heavyScriptsAllowed(universe) then
	
		if surface.count_entities_filtered({
			position={groupPosition.x, groupPosition.y},
			radius = 20,
			force=universe.activePlayerForces,
			limit=1
			}) == 0 then
			
			partiallySettleHere(map, group, squad, 6)
			squad.kills = 0
				--return
		end	
	end
	
	processCompression(map, squad, chunk, true)

	if squad.chunk and (squad.chunk ~= -1) then
		addDeathGenerator(map, squad.chunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)			--FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT)
	end	

    addSquadToChunk(map, chunk, squad)
    addMovementPenalty(squad, chunk)
    squad.frenzy = (squad.frenzy and (euclideanDistanceNamed(groupPosition, squad.frenzyPosition) < 100))
    local attackChunk, attackDirection,
        nextAttackChunk, nextAttackDirection = scoreNeighborsForAttack(map,
                                                                       chunk,
                                                                       getNeighborChunks(map, x, y),
                                                                       attackScorer,
                                                                       brainOn and squad.noise,
                                                                       squad.prevAttackChunk)
	if brainOn then
		squad.prevAttackChunk = chunk
	end
																	   
	if (attackChunk ~= -1) and (attackChunk[BASE_DETECTION_PHEROMONE] == 0) then
		if (nextAttackChunk == -1) or (nextAttackChunk[BASE_DETECTION_PHEROMONE] == 0) then
			squad.disbandTick = game.tick
		end	
	end

    local cmd
	local cmd_type = "wander"
    if (attackChunk == -1) then
        cmd = universe.wonderCommand
        group.set_command(cmd)
		squad.onTheWay = true
        return
    elseif (nextAttackChunk ~= -1) then
        attackChunk = nextAttackChunk
        positionFromDirectionAndFlat(attackDirection, groupPosition, targetPosition)
        positionFromDirectionAndFlat(nextAttackDirection, targetPosition, targetPosition2)
        position = findMovementPosition(surface, targetPosition2)
    else
        positionFromDirectionAndFlat(attackDirection, groupPosition, targetPosition)
        position = findMovementPosition(surface, targetPosition)
    end

    if not position then
        cmd = universe.wonderCommand
        group.set_command(cmd)
		squad.onTheWay = true
        return
    else
        targetPosition.x = position.x
        targetPosition.y = position.y
        if nextAttackChunk then
            addDeathGenerator(map, nextAttackChunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)		--FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT)
        else
            addDeathGenerator(map, attackChunk, SQUAD_PATH_DEATH_PHEROMONE_GENERATOR_AMOUNT)			--FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT)
        end
    end

	if (chunk ~= -1) then
		if (chunk[BASE_DETECTION_PHEROMONE] < (MAX_BASE_DETECTION_PHEROMONES_IN_CHUNK*0.1)) then
			if chunk[PLAYER_PHEROMONE] < (PLAYER_PHEROMONE_GENERATOR_AMOUNT*0.02) then
				applySpeedBuffToGroup(group)
			-- else
				-- game.print(chunk[PLAYER_PHEROMONE].."[gps=" .. group.position.x .. "," .. group.position.y .."]")	-- debug
			end
		end
	end	
	
    if (chunk ~= -1) and (getPlayerBaseGenerator(map, chunk) ~= 0) then
		cmd_type = "attack"
	elseif (attackChunk ~= -1) and (getPlayerBaseGenerator(map, attackChunk) ~= 0) then
		cmd_type = "attack"
	elseif squad.kills and (squad.kills>0) then
		cmd_type = "attack"
    else
		cmd_type = "move"
    end
	
	if cmd_type == "attack" then
		cmd = universe.compoundAttackCommand
       if not squad.rabid then
            squad.frenzy = true
            squad.frenzyPosition.x = groupPosition.x
            squad.frenzyPosition.y = groupPosition.y
        end		
		group.set_command(cmd)
		if not group.valid then
			return	-- the engine dropped the emptied group: processSquads disbands the squad
		end
		group.start_moving()
		if squad.hasSpiders then	-- spider ignore group attack
			for _, entity in pairs(group.members) do
				if entity.prototype.type == "spider-unit" then
					entity.commandable.set_command(cmd)
				end
			end
		end
	elseif cmd_type == "move" then
        cmd = universe.compoundMoveCommand
		if (attackChunk ~= -1) and (chunk ~= -1) and (chunk[BASE_DETECTION_PHEROMONE] >= attackChunk[BASE_DETECTION_PHEROMONE]) then			
            cmd.commands[2].distraction = DEFINES_DISTRACTION_BY_ANYTHING
		elseif squad.rabid or squad.frenzy then
            cmd.commands[2].distraction = DEFINES_DISTRACTION_BY_ANYTHING
        else
            cmd.commands[2].distraction = DEFINES_DISTRACTION_BY_ENEMY
        end
		group.set_command(cmd)
		if not group.valid then
			return
		end
		group.start_moving()
	elseif cmd_type == "wander" then
		group.set_command(universe.wonderCommand)	
	end
	
	-- DEBUG
	-- if not squad.debugPath then
		-- squad.debugPath = {}
	-- end
	
	-- local lineColor = {0, 1, 0}
	-- if squad.frenzy then
		-- lineColor = {1, 0.5, 0}
	-- elseif squad.rabid then	
		-- lineColor = {1, 1, 0}
	-- elseif squad.kamikaze then
		-- lineColor = {1, 0, 0}
	-- end		
	-- squad.debugPath[#squad.debugPath+1] = rendering.draw_line{surface = group.surface, from = group.position, to = targetPosition, color = lineColor, width = 2}
	-- squad.debugPath[#squad.debugPath+1] = rendering.draw_text{text = (tostring((#squad.debugPath+1)*0.5).."("..targetPosition.x..","..targetPosition.y..")"), surface = group.surface, target = targetPosition, color = lineColor, scale = 3}	
	-- DEBUG
	
	squad.nextCommandTick = game.tick + 60	
 	squad.checkTick = game.tick + 18000	-- some groups get stuck 
	squad.onTheWay = true
end

local function buildMove(map, squad)
	if not squad then
		return
	end	
    local group = squad.group
	settleHere(map, group, squad, true)

    -- local universe = map.universe
    -- local position = universe.position
    -- local groupPosition = findMovementPosition(map.surface, group.position)

    -- if not groupPosition then
        -- groupPosition = group.position
    -- end
    -- position.x = groupPosition.x
    -- position.y = groupPosition.y

    -- group.set_command(universe.compoundSettleCommand)
	-- squad.onTheWay = true
 	-- squad.checkTick = game.tick + 18000	-- some groups get stuck 	
end

-- DEBUG
local function clearDebugLines(squad)
	if not squad.debugPath then
		return
	end
	local debugLen = #squad.debugPath + 0
	for i=1,debugLen do
		if squad.debugPath[i] then
			squad.debugPath[i].destroy()
		end	
	end
	squad.debugPath = {}
end
-- DEBUG

local function disbandSquad(universe, squads, groupId)
	local squad = squads[groupId]
	if squad.map and (squad.learn or squad.flight) then
		aiBrain.onSquadEnd(squad.map, squad, game.tick)	-- what the AI learns from this squad
	end
	if not squad.excluded then
		if squad.settlers then
			universe.builderCount = universe.builderCount - 1
		else
			universe.squadCount = universe.squadCount - 1
		end
	end	
	if squad.map then
		removeSquadFromChunk(squad.map, squad)
		local group = squad.group
		if group.valid then
			group.destroy()
		end	
		clearDebugLines(squad)	-- DEBUG
		clearComresseData(universe, squad)
	end	
	squads[groupId] = nil
end

-- A squad back from a retreat joins a nearby attack squad, or comes again from another side.
local function regroupSquad(map, squad)
	local universe = map.universe
	local group = squad.group
	local partner = findRegroupPartner(map, squad)
	if partner then
		local members = group.members
		local partnerGroup = partner.group
		local moved = 0
		for i = 1, #members do
			local member = members[i]
			if member.valid then
				partnerGroup.add_member(member)
				moved = moved + 1
			end
		end
		if partner.startSize then
			partner.startSize = partner.startSize + moved
		end
		squad.merged = true
		aiBrain.debugPrint(map, tostring(squad.tactic) .. " squad joins a " .. tostring(partner.tactic) .. " squad (" .. moved .. " units)")
		disbandSquad(universe, universe.groupNumberToSquad, squad.groupNumber)
		return true
	end
	if squad.originX then
		local originChunk = getChunkByXY(map, math.floor(squad.originX / 32) * 32, math.floor(squad.originY / 32) * 32)
		if originChunk ~= -1 then
			local excludeSector
			if squad.engageX then
				excludeSector = aiBrain.sectorOf(squad.engageX - squad.originX, squad.engageY - squad.originY)
			end
			local goal, sector = aiBrain.pickApproach(map, originChunk, "best", nil, excludeSector)
			if goal then
				goal.kind = "approach"
				goal.reach = 48
				goal.untilTick = game.tick + 3 * 3600
				squad.goal = goal
				squad.goalSector = sector
				aiBrain.debugPrint(map, tostring(squad.tactic) .. " squad tries another side [gps=" .. math.floor(goal.x) .. "," .. math.floor(goal.y) .. "," .. map.surface.name .. "]")
			end
		end
	end
	squad.status = SQUAD_RAIDING
	attackMove(map, squad)
	return true
end

function squadAttack.processSquads(universe)
    local squads = universe.groupNumberToSquad
    local groupId = universe.squadIterator
    local squad
    if not groupId then
        groupId, squad = next(squads, groupId)
    else
        squad = squads[groupId]
    end
    if not groupId then
        universe.squadIterator = nil
        if (table_size(squads) == 0) then
            -- this is needed as the next command remembers the max length a table has been
            universe.groupNumberToSquad = {}
        end
    else
		local map = squad.map
        local group = squad.group
        if not map then
			disbandSquad(universe, squads, groupId)
        elseif not group.valid then
			if squad.chunk and (squad.chunk ~= -1) then
				addDeathGenerator(map, squad.chunk, FIVE_DEATH_PHEROMONE_GENERATOR_AMOUNT)
			end	
			disbandSquad(universe, squads, groupId)
		elseif squad.disbandTick < game.tick then
			disbandSquad(universe, squads, groupId)
        elseif (group.state == defines.group_state.finished) then
            squadAttack.squadDispatch(map, squad)
		elseif squad.flight and squad.strikeUntil and (squad.strikeUntil < game.tick) then
			-- hit and run: flights do not stay long on a target
			if aiBrain.flyers then
				aiBrain.flyers.onStrikeTimeout(map, squad)
			else
				squad.strikeUntil = nil
			end
		elseif not squad.checkTick then
			squad.checkTick = game.tick + 18000	
		elseif squad.checkTick < game.tick then	-- some groups get stuck. stuck + ignoring new commands!
			disbandSquad(universe, squads, groupId)
        end
        universe.squadIterator = next(squads, groupId)
    end
end

function squadAttack.squadDispatch(map, squad)
	if not squad then
		return
	end	
	if squad.nextCommandTick and (game.tick < squad.nextCommandTick) then
		return	
	end
    local group = squad.group
    if group and group.valid then
		if not squad.detected then
			local members = group.members
			if #members > 0 then
				squad.detected = showAlert(group.surface, members[1], "squadDetected-warning-rampant", {"", {"description.rampantFixed--squadDetectedWarning", #members}})
			end
		end
		if squad.flight then
			if aiBrain.flyers then
				aiBrain.flyers.dispatch(map, squad)
			end
			return
		end
        local status = squad.status
        if (status == SQUAD_RAIDING) then
            attackMove(map, squad)
        elseif (status == SQUAD_SETTLING) then
            settleMove(map, squad)
        elseif (status == SQUAD_RETREATING) then
			squad.compressed = true		-- some compressed units can join while retreating
			if squad.regroup and (not squad.settlers) and aiBrain.active(map.universe) then
				squad.regroup = nil
				regroupSquad(map, squad)
				return
			end
            if squad.settlers then
                squad.status = SQUAD_SETTLING
                settleMove(map, squad)
            else
                squad.status = SQUAD_RAIDING
                attackMove(map, squad)
            end
        elseif (status == SQUAD_BUILDING) then
            removeSquadFromChunk(map, squad)
            buildMove(map, squad)
        elseif (status == SQUAD_GUARDING) then
            if squad.settlers then
                squad.status = SQUAD_SETTLING
                settleMove(map, squad)
            else
                squad.status = SQUAD_RAIDING
                attackMove(map, squad)
            end
        end
    end
end

squadAttackG = squadAttack
return squadAttack
