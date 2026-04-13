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

	cmd = {type = defines.command.stop, ticks_to_wait = 3600*10}
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
	cmd = universe.compoundMoveCommand
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
	if numSettlers >= #members then
		numSettlers = #members - 1
	end
	for _, entity in pairs(members) do
		if numSettlers <= 0 then
			break
		end
		if entity.valid and (entity.type == "unit") then
			 local newEntity = surface.create_entity({
				name = newEntityName,
				quality = entity.quality,
				direction = entity.direction,
				position = entity.position, 
				force = entity.force,
				})
			if newEntity and newEntity.valid then
				newGroup.add_member(newEntity)
				surface.create_trivial_smoke({name = "digIn-dust-nonTriggerCloud-rampant", position = entity.position})
				entity.destroy()
				numSettlers = numSettlers - 1
			end	
		end
	end
	
	if #newGroup.members > 0 then
		universe.settleCommand.distraction = DEFINES_DISTRACTION_BY_ENEMY
		cmd = universe.compoundSettleCommand
		newGroup.set_command(cmd)	
	end
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
		
	if (chunk ~= -1) and (chunk[PLAYER_PHEROMONE] == 0) and (chunk[BASE_DETECTION_PHEROMONE] == 0) then
		if not squad.checkTick or ((game.tick + 600) < squad.checkTick) then
			squad.checkTick = game.tick + 600
		end	
		return
	end
		
	if not squad.hasSpiders and squad.kills and (squad.kills>5) then
	
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
                                                                       attackScorer)
																	   
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
		if (not squad.detected) and (#group.members > 0) then
			 squad.detected = showAlert(group.surface, group.members[1], "squadDetected-warning-rampant", {"", {"description.rampantFixed--squadDetectedWarning", #group.members}})
		end
        local status = squad.status
        if (status == SQUAD_RAIDING) then
            attackMove(map, squad)
        elseif (status == SQUAD_SETTLING) then
            settleMove(map, squad)
        elseif (status == SQUAD_RETREATING) then
			squad.compressed = true		-- some compressed units can join while retreating
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
