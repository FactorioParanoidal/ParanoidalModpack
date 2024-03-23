if (squadAttackG) then
    return squadAttackG
end
local squadAttack = {}

-- imports

local constants = require("Constants")
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
    local groupPosition = group.position
	position = findMovementPosition(surface, groupPosition)

	if not position then
		position = groupPosition
	end

	targetPosition.x = position.x
	targetPosition.y = position.y

	cmd = universe.settleCommand
	if squad.kamikaze or dontDistract then
		cmd.distraction = DEFINES_DISTRACTION_NONE
	else
		cmd.distraction = DEFINES_DISTRACTION_BY_ENEMY
	end

	squad.status = SQUAD_BUILDING

	group.set_command(cmd)
 	squad.checkTick = game.tick + 36000	-- some groups get stuck 	
	
end

local function goToLastvalidSettlerLocation(universe, group, squad)
	cmd = universe.moveCommand
	cmd.destination.x = squad.lastValidChunk.x
	cmd.destination.y = squad.lastValidChunk.y
	group.set_command(cmd)

	squad.settleFirstChance	= true
	--game.print("settle ("..groupPosition.x..","..groupPosition.y..") - maxDistance, last valid chunk ("..squad.lastValidChunk.x..","..squad.lastValidChunk.y..")")			
	squad.lastValidChunk = nil
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
		--game.print("settleMove, chunk = squad.prevChunk ("..chunk.x..","..chunk.y..")")
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
					cmd = universe.attackCommand

					if not squad.rabid then
						squad.frenzy = true
						squad.frenzyPosition.x = groupPosition.x
						squad.frenzyPosition.y = groupPosition.y
					end
				else
					cmd = universe.moveCommand
					if squad.rabid or squad.kamikaze then
						cmd.distraction = DEFINES_DISTRACTION_NONE
					else
						cmd.distraction = DEFINES_DISTRACTION_BY_DAMAGE	-- DEFINES_DISTRACTION_BY_ENEMY
					end
				end
				group.set_command(cmd)
				squad.checkTick = game.tick + 18000 	
			else
				settleHere(map, group, squad, true)
			end
		end	
		squad.prevChunk = chunk	-- prevent 1-2-1-2-1-2-1.. moving
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
    local cmd
    if (attackChunk == -1) then
        cmd = universe.wonderCommand
        group.set_command(cmd)
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

    if (getPlayerBaseGenerator(map, attackChunk) ~= 0) and
        (attackChunk[PLAYER_PHEROMONE] >= universe.attackPlayerThreshold)
    then
        cmd = universe.attackCommand

        if not squad.rabid then
            squad.frenzy = true
            squad.frenzyPosition.x = groupPosition.x
            squad.frenzyPosition.y = groupPosition.y
        end
    else
        cmd = universe.moveCommand
        if squad.rabid or squad.frenzy then
            cmd.distraction = DEFINES_DISTRACTION_BY_ANYTHING
        else
            cmd.distraction = DEFINES_DISTRACTION_BY_ENEMY
        end
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
	-- squad.debugPath[#squad.debugPath+1] = rendering.draw_text{text = tostring((#squad.debugPath+1)*0.5), surface = group.surface, target = targetPosition, color = lineColor, scale = 3}	
	-- DEBUG
	
 	squad.checkTick = game.tick + 18000	-- some groups get stuck 
    group.set_command(cmd)
end

local function buildMove(map, squad)
	if not squad then
		return
	end	
    local group = squad.group
    local universe = map.universe
    local position = universe.position
    local groupPosition = findMovementPosition(map.surface, group.position)

    if not groupPosition then
        groupPosition = group.position
    end

    position.x = groupPosition.x
    position.y = groupPosition.y

    group.set_command(universe.compoundSettleCommand)
 	squad.checkTick = game.tick + 18000	-- some groups get stuck 	
	
end

-- DEBUG
local function clearDebugLines(squad)
	if not squad.debugPath then
		return
	end
	local debugLen = #squad.debugPath + 0
	for i=1,debugLen do
		rendering.destroy(squad.debugPath[i])
	end
	squad.debugPath = {}
end
-- DEBUG

local function disbandSquad(universe, squads, groupId)
	local squad = squads[groupId]
	if squad.settlers then
		universe.builderCount = universe.builderCount - 1
	else
		universe.squadCount = universe.squadCount - 1
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

function squadAttack.cleanSquads(universe)
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
        elseif (group.state == 4) then
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
    local group = squad.group
    if group and group.valid then
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
