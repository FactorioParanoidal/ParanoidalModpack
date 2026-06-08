-- Copyright (C) 2022  Dimm2101

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.


-- imports

local aiAttackWave = require("libs/AIAttackWave")
local aiPredicates = require("libs/AIPredicates")
local aiPlanning = require("libs/AIPlanning")
local baseUtils = require("libs/BaseUtils")
local bitersEnrage = require("libs/BitersEnrage")
local biterSupressors = require("libs/BiterSupressors")
local config = require("config")
local constants = require("libs/Constants")
local chunkProcessor = require("libs/ChunkProcessor")
local chunkPropertyUtils = require("libs/ChunkPropertyUtils")
local demolisherUtils = require("libs/DemolisherUtils")
local chunkUtils = require("libs/ChunkUtils")
local GUI_Elements = require("libs/GUI_Elements")
local mapProcessor = require("libs/MapProcessor")
local mapUtils = require("libs/MapUtils")
local mathUtils = require("libs/MathUtils")
local pheromoneUtils = require("libs/PheromoneUtils")
local powerup = require("libs/Powerup")
local squadAttack = require("libs/SquadAttack")
local squadCompression = require("libs/SquadCompression")
local squadDefense = require("libs/SquadDefense")
local stringUtils = require("libs/StringUtils")
local tests = require("libs/Tests")
local undergroundAttack = require("libs/UndergroundAttack")
local unitGroupUtils = require("libs/UnitGroupUtils")
local unitUtils = require("libs/UnitUtils")
local upgrade = require("Upgrade")

local hasSpaceAgeMod = script.active_mods["space-age"]

require("remote_interface")

-- constants
local BASE_CHANGING_CHANCE = constants.BASE_CHANGING_CHANCE

local AI_SETTLER_COST = constants.AI_SETTLER_COST

local RECOVER_NEST_COST = constants.RECOVER_NEST_COST
local RECOVER_WORM_COST = constants.RECOVER_WORM_COST

local RETREAT_GRAB_RADIUS = constants.RETREAT_GRAB_RADIUS

local RETREAT_SPAWNER_GRAB_RADIUS = constants.RETREAT_SPAWNER_GRAB_RADIUS

local PROCESS_QUEUE_SIZE = constants.PROCESS_QUEUE_SIZE

local DEFINES_WIRE_TYPE_RED = defines.wire_type.red
local DEFINES_WIRE_TYPE_GREEN = defines.wire_type.green

local ENERGY_THIEF_CONVERSION_TABLE = constants.ENERGY_THIEF_CONVERSION_TABLE
local ENERGY_THIEF_LOOKUP = constants.ENERGY_THIEF_LOOKUP

local SURFACE_IGNORED = constants.SURFACE_IGNORED
local OVERDAMAGEPROTECTION_THRESHOLD = constants.OVERDAMAGEPROTECTION_THRESHOLD 

local VANILLA_ENTITIES = constants.VANILLA_ENTITIES
-- imported functions

local processSupression = biterSupressors.processSupression
local biterSupressionType = biterSupressors.supressionType

local isRampantSetting = stringUtils.isRampantSetting

local canMigrate = aiPredicates.canMigrate

local convertTypeToDrainCrystal = unitUtils.convertTypeToDrainCrystal

local squadDispatch = squadAttack.squadDispatch
local processDecompressQueue = squadCompression.processDecompressQueue
local nonRampantCompressedSquads = squadCompression.nonRampantCompressedSquads
local removeOneTickImmunity = squadCompression.removeOneTickImmunity
local onUnitPreKilled = squadCompression.onUnitPreKilled

local createUndergroudAttack = undergroundAttack.createUndergroudAttack
local enrageBitersInRange = bitersEnrage.enrageBitersInRange
-- local addDebugButton = tests.addDebugButton
-- local onDebugElementClick = tests.onDebugElementClick
-- local debug_onUnitDamaged = tests.debug_onUnitDamaged
local in_debug_list = tests.in_debug_list

local cleanUpMapTables = mapProcessor.cleanUpMapTables

local positionToChunkXY = mapUtils.positionToChunkXY

local processMapAIs = aiPlanning.processMapAIs


local processVengence = mapProcessor.processVengence
local processSpawners = mapProcessor.processSpawners

local processStaticMap = mapProcessor.processStaticMap

local disperseVictoryScent = pheromoneUtils.disperseVictoryScent

local getChunkByPosition = mapUtils.getChunkByPosition

local entityForPassScan = chunkUtils.entityForPassScan
local needReplacement = chunkUtils.needReplacement

local processPendingChunks = chunkProcessor.processPendingChunks
local processScanChunks = chunkProcessor.processScanChunks
local processPendingMutations = chunkProcessor.processPendingMutations

local processMap = mapProcessor.processMap
local processPlayers = mapProcessor.processPlayers
local scanEnemyMap = mapProcessor.scanEnemyMap
local scanPlayerMap = mapProcessor.scanPlayerMap
local scanResourceMap = mapProcessor.scanResourceMap
local suspendClearedMaps = mapProcessor.suspendClearedMaps

local processNests = mapProcessor.processNests
local processGrowingBases = mapProcessor.processGrowingBases

local rallyUnits = aiAttackWave.rallyUnits
local processBuilders = aiAttackWave.processBuilders
local processNonRampantBuilders = aiAttackWave.processNonRampantBuilders

local recycleBases = baseUtils.recycleBases

local deathScent = pheromoneUtils.deathScent
local victoryScent = pheromoneUtils.victoryScent

local createSquad = unitGroupUtils.createSquad

local createBase = baseUtils.createBase
local findNearbyBase = baseUtils.findNearbyBase

local processActiveNests = mapProcessor.processActiveNests

local getDeathGenerator = chunkPropertyUtils.getDeathGenerator

local retreatUnits = squadDefense.retreatUnits

local accountPlayerEntity = chunkUtils.accountPlayerEntity
local unregisterEnemyBaseStructure = chunkUtils.unregisterEnemyBaseStructure
local registerEnemyBaseStructure = chunkUtils.registerEnemyBaseStructure
local makeImmortalEntity = chunkUtils.makeImmortalEntity

local registerResource = chunkUtils.registerResource
local unregisterResource = chunkUtils.unregisterResource

local processSquads = squadAttack.processSquads

local processCompression = squadCompression.processCompression

local upgradeEntity = baseUtils.upgradeEntity
local rebuildNativeTables = baseUtils.rebuildNativeTables

local mRandom = math.random

local tRemove = table.remove

local sFind = string.find
local sSub = string.sub
local ShowNewBaseAligments = baseUtils.ShowNewBaseAligments
local thisIsNewEnemyPosition = chunkPropertyUtils.thisIsNewEnemyPosition

local mMax = math.max
local mMin = math.min

local onUnitDamaged_oneshot = powerup.onUnitDamaged_oneshot

-- local references to global

local universe -- manages the chunks that make up the game universe

-- hook functions

local function onIonCannonFired(event)
    --[[
        event.force, event.surface, event.player_index, event.position, event.radius
    --]]
    local map = universe.maps[event.surface.index]
	if not map then
		return
	end	
	map.retribution = map.retribution + 1
	map.vengenceLimiter = 0
    map.ionCannonBlasts = map.ionCannonBlasts + 1
    map.points = map.points + 4000
    if universe.aiPointsPrintGainsToChat then
        game.print(map.surface.name .. ": Points: +" .. 4000 .. ". [Ion Cannon] Total: " .. string.format("%.2f", map.points))
    end

    local chunk = getChunkByPosition(map, event.position)
    if (chunk ~= -1) then
        rallyUnits(chunk, map, event.tick)
    end
end


local function hookEvents()
    if settings.startup["ion-cannon-radius"] ~= nil then
        script.on_event(remote.call("orbital_ion_cannon", "on_ion_cannon_fired"),
                        onIonCannonFired)
    end
end


local function onLoad()
    universe = storage.universe
    hookEvents()
end

local function onChunkGenerated(event)
    -- queue generated chunk for delayed processing, queuing is required because
    -- some mods (RSO) mess with chunk as they are generated, which messes up the
    -- scoring.
    universe.pendingChunks[event] = true
end

local function onChunkDeleted(event)
    local surfaceIndex = event.surface_index
    local map = universe.maps[surfaceIndex]
    if map then
        local positions = event.positions
        for i=1,#positions do
            local position = positions[i]
            local x = position.x * 32
            local y = position.y * 32
            local chunk = mapUtils.getChunkByXY(map, x, y)
            if chunk ~= -1 then
				mapUtils.removeChunkFromMap(map, chunk)
            end
        end
    end
end

local function prepMap(surface)
    local surfaceIndex = surface.index

    if not universe.maps then
        universe.maps = {}
    end
	
	if SURFACE_IGNORED(surface, universe) then
		return	
	end
	
    surface.print("Rampant, fixed - Indexing surface:" .. tostring(surface.index) .. ", please wait.")

    local map = universe.maps[surfaceIndex]
    if not map then
        map = {}
        universe.maps[surfaceIndex] = map
    end

    map.processedChunks = 0
    map.processQueue = {}
    map.processIndex = 1
    map.cleanupIndex = 1
    map.scanPlayerIndex = 1
    map.scanResourceIndex = 1
    map.scanEnemyIndex = 1
    map.processStaticIndex = 1
    map.outgoingScanWave = true
    map.outgoingStaticScanWave = true

	map.chunkToPlayerTurrets = {}
    map.chunkToBase = {}
    map.chunkToNests = {}
    map.chunkToTurrets = {}
    map.chunkToTraps = {}
    map.chunkToUtilities = {}
    map.chunkToHives = {}
    map.chunkToPlayerBase = {}
    map.chunkToPlayerBaseDetection = {}
    map.chunkToResource = {}

    map.chunkToSquad = {}

    map.chunkToRetreats = {}
    map.chunkToRallys = {}

    map.chunkToPassable = {}
    map.chunkToPathRating = {}
    map.chunkToDeathGenerator = {}
    map.chunkToDrained = {}
    map.chunkToVictory = {}
    map.chunkToActiveNest = {}
    map.chunkToActiveRaidNest = {}

    map.nextChunkSort = 0
    map.nextChunkSortTick = 0

    map.deployVengenceIterator = nil
    map.recycleBaseIterator = nil
    map.processActiveSpawnerIterator = nil
    map.processActiveRaidSpawnerIterator = nil
    map.processMigrationIterator = nil
    map.processNestIterator = nil
    map.victoryScentIterator = nil

    map.chunkScanCounts = {}
    map.chunkFactionCounts = {}

    map.enemiesToSquad = {}
    map.enemiesToSquad.len = 0
    map.chunkRemovals = {}
    map.processActiveNest = {}
    map.tickActiveNest = {}

    map.emptySquadsOnChunk = {}

    map.surface = surface
    map.universe = universe
	map.suspended = false

    map.vengenceQueue = {}
    map.points = 0
    map.state = constants.AI_STATE_AGGRESSIVE
    map.baseId = 0
    map.squads = nil
    map.pendingAttack = nil
    map.building = nil

    map.canAttackTick = 0
	map.canMigrateTick = 0
	
    map.drainPylons = {}
    map.groupNumberToSquad = {}
    map.activeRaidNests = 0
    map.activeNests = 0
    map.destroyPlayerBuildings = 0
    map.lostEnemyUnits = 0
    map.lostEnemyBuilding = 0
    map.rocketLaunched = 0
    map.builtEnemyBuilding = 0
    map.ionCannonBlasts = 0
    map.artilleryBlasts = 0

	map.vengenceLimiter = 0
	map.squadsGenerated = 0	-- (every 20 active Nests chunks = 1 max squad in agressive mode), aiAttackWave.formSquads
    map.temperament = 0.5
    map.temperamentScore = 0
    map.firstStateTick = 0
	map.truceEndTick = -1
	map.stateTick = 0

	map.nextPlayerScan = 0
	
	map.basesToGrow = {}
	
	-- universe settings before 2.0
	map.maxPoints = 0 
	map.attackWaveMaxSize = 0
	map.rallyThreshold = 0
	map.formSquadThreshold = 0
	map.raiding_minimum_base_threshold = 0
	map.no_pollution_attack_threshold = 0
	map.retribution = 0
	map.undergroundAttackProbability = 0
	
	map.finalSquadCost = 0
	map.finalVengenceSquadCost = 0
	map.attackWaveDeviation = 0
	map.attackWaveUpperBound = 0
	map.settlerWaveSize = 0
	map.settlerWaveDeviation = 0
	map.kamikazeThreshold = 0	
	map.buildingsLvl = 1
	
	map.replaceModedNests = constants.IS_VANILLA_BITERS_SURFACE(map.surface)		-- to do: Clean up the mess here 
	map.hasNonmoddedBiters = constants.IS_VANILLA_BITERS_SURFACE(map.surface)
	map.nextDemolisherAttackTick = 0
	map.supressionData = {supressionEndTick = 0, supressionType = 0, evo = nil}
	
	map.siegeTick = 0
	map.resourceSettleTick = 0
	--
	
    -- queue all current chunks that wont be generated during play
    local tick = game.tick
    local position = {0,0}
    map.nextChunkSort = 0
    for chunk in surface.get_chunks() do
        local x = chunk.x
        local y = chunk.y
        position[1] = x
        position[2] = y
        if surface.is_chunk_generated(position) then
            onChunkGenerated({ surface = surface,
                               area = { left_top = { x = x * 32,
                                                     y = y * 32}}})
        end
    end

     processPendingChunks(universe, tick, true)
end

local function setNewEnemySide()
	universe["ALLOW_OTHER_ENEMIES"] = settings.startup["rampantFixed--allowOtherEnemies"].value
	universe["NEW_ENEMIES_SIDE"] = settings.startup["rampantFixed--newEnemiesSide"].value
end

local additionalPoles = {}	-- reseted after save/load
local function entityIsImmortal(entity)	
	if (universe.safeEntities[entity.type] or universe.safeEntities[entity.name]) then
		return true						 
	elseif universe.safeEntities["big-electric-pole"] and (entity.type == "electric-pole") then
		if not additionalPoles[entity.name] then
			additionalPoles[entity.name] = {safe = ((entity.prototype.get_max_wire_distance() > 18) and (entity.prototype.get_supply_area_distance() < 7))}
		end
		if additionalPoles[entity.name].safe then 
			return true
		end
	end
	return false
end

local function onBuild(event)
    local entity = event.created_entity or event.entity
    if entity.valid then
--		game.print("onBuild.."..entity.name)
        local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
        if (entity.type == "resource") and (entity.force.name == "neutral") then
            registerResource(entity, map)
        else
            accountPlayerEntity(entity, map, true, false)
            if universe.safeBuildings then
                if entityIsImmortal(entity) then
                    entity.destructible = false
                end
            end
        end
    end
end

local function onMine(event)
    local entity = event.entity
    if entity.valid then
        local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
        if (entity.type == "resource") and (entity.force.name == "neutral") then
            if (entity.amount == 0) then
                unregisterResource(entity, map)
            end
        else
            accountPlayerEntity(entity, map, false, false)
        end
    end
end

-----------------
local landfillVectors = {{0,0}, {1,0}, {0,1}, {-1,0}, {0,-1}}

local function biters_landfill(entity)
	if (not entity) or (not entity.valid) then return end
	if entity.max_health < 300 then return end	
	local position = entity.position
	local surface = entity.surface
	for _, vector in pairs(landfillVectors) do
		local tile = surface.get_tile({position.x + vector[1], position.y + vector[2]})
		if tile.collides_with("water_tile") then
			surface.set_tiles({{name = "landfill", position = tile.position}},true,true,true,true)
			local particle_pos = {tile.position.x + 0.5, tile.position.y + 0.5}
			for _ = 1, 50, 1 do
				surface.create_particle({
					name = "stone-particle",
					position = particle_pos,
					frame_speed = 0.1,
					vertical_speed = 0.12,
					height = 0.01,
					movement = {-0.05 + mRandom(0, 100) * 0.001, -0.05 + mRandom(0, 100) * 0.001}
				})
			end
		end
	end
end
-----------------
local function onDeath(event)
    local entity = event.entity
    if entity.valid then
        local surface = entity.surface
        local map = universe.maps[surface.index]
		if not map then
			return
		end	
		if (entity.force.name == "neutral") then
			if (entity.name == "cliff") then
				entityForPassScan(map, entity)
			end
			return
		end
		if entity.prototype.has_flag("not-in-kill-statistics") then
			return
		end
        local entityPosition = entity.position
        local chunk = getChunkByPosition(map, entityPosition)
        local cause = event.cause
        local tick = event.tick
        local entityType = entity.type
        if (entity.force.name == "enemy") then

            local artilleryBlast = (cause and
                                    ((cause.type == "artillery-wagon") or (cause.type == "artillery-turret")))

			if (not artilleryBlast) and (entity.force.name == "enemy") then
				local incomingRange = 0
				if event.cause and event.cause.valid then
					incomingRange = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, event.cause.position.x, event.cause.position.y)
					if incomingRange >= 90 then
						artilleryBlast = true
					end
				end	
			
			
			end
			
            if artilleryBlast then
                map.artilleryBlasts = map.artilleryBlasts + 1
				map.vengenceLimiter = 0
				map.retribution = map.retribution + 0.002
				if map.supressionData then
					 map.supressionData.artilleryEffectTick = game.tick + 5 * 3600
				end
				
				if cause and cause.valid and (cause.type == "electric-turret") then
					if mRandom() < 0.005 then
						entity.surface.create_entity({
							name = "targetDummyPlasma-rampant",
							position = entityPosition, 
							force = "enemy",
							})	
					end		
				end
            end

            if (entityType == "unit") then
                if (chunk ~= -1) then
					if event.force and (event.force.name ~= "enemy") then
						biters_landfill(entity)
						-- drop death pheromone where unit died
						deathScent(map, chunk)

						map.lostEnemyUnits = map.lostEnemyUnits + 1
						local chainVengenceCoefficient = settings.global["rampantFixed--chainVengenceCoefficient"].value	-- 0.6 default
						local vengenceOffset = chainVengenceCoefficient ^ map.vengenceLimiter
						if (chunk.nextSquadTick and (chunk.nextSquadTick < tick)) and (not surface.peaceful_mode) and (mRandom() < (map.rallyThreshold * vengenceOffset)) then
							rallyUnits(chunk, map, tick)
						end
					end
					if artilleryBlast and universe.undergroundAttack then
						undergroundAttack.onUnitKilled_DigIn(map, entity, cause)
					else	
						squadCompression.onUnitKilled(universe, surface, entity, event.force, cause)
					end	
				end
			elseif (entityType == "segmented-unit") then	
				if map.nextDemolisherAttackTick then
					map.nextDemolisherAttackTick = mMax(game.tick, map.nextDemolisherAttackTick) + 5*3600
				end
            elseif event.force and (event.force.name ~= "enemy") and
                ((entityType == "unit-spawner") or (entityType == "turret"))
            then
				map.vengenceLimiter = 0
				local pointsGain = 0
                if (entityType == "unit-spawner") then
					if artilleryBlast then
						map.retribution = map.retribution + 0.018	-- additional retribution points					
					end
					if universe.aiDifficulty ~= "Hard" then
						pointsGain = RECOVER_NEST_COST * 0.2
					else
						pointsGain = RECOVER_NEST_COST
					end
                else
					if universe.aiDifficulty ~= "Hard" then
						pointsGain = RECOVER_WORM_COST * 0.01
					else
						pointsGain = RECOVER_WORM_COST
					end		
                end
				
				if artilleryBlast then
					pointsGain = pointsGain * 1.2						
				end
				
                map.points = map.points + pointsGain
                if universe.aiPointsPrintGainsToChat and (pointsGain > 0) then
                        game.print(map.surface.name .. ": Points: +" .. pointsGain .. ". [Worm or Nest Lost] Total: " .. string.format("%.2f", map.points))				
				end
				
				-- if (chunk ~= -1) then	-- spawn too many nests in late game
					-- local baseFromChunk = map.chunkToBase[chunk]
					-- if baseFromChunk then
						-- baseFromChunk.forcedGrowthTick = tick + 15*3600
						-- if not universe.growingBases[baseFromChunk.id] then
							-- universe.growingBases[baseFromChunk.id] = {tick = tick}
						-- end	
					-- end
				-- end
                unregisterEnemyBaseStructure(map, entity, event.damage_type)

                if (chunk ~= -1) then
					if (chunk.nextSquadTick and (chunk.nextSquadTick < tick)) then
						rallyUnits(chunk, map, tick)
					end	
					if cause and cause.valid and (cause.type == "character") then
						enrageBitersInRange(map, cause.position, getChunkByPosition(map, cause.position), tick)
						if not artilleryBlast then
							powerup.checkAndDropPowerup(entity, cause, universe, entity.force.get_evolution_factor(surface))
						end						
					end
                    -- if artilleryBlast and cause and cause.valid then
                        -- retreatUnits(chunk,
                                     -- cause,
                                     -- map,
                                     -- tick,
                                     -- RETREAT_SPAWNER_GRAB_RADIUS)
                    -- end
                end
            else
                local entityUnitNumber = entity.unit_number
                local pair = map.drainPylons[entityUnitNumber]
                if pair then
                    local target = pair[1]
                    local pole = pair[2]
                    if target == entity then
                        map.drainPylons[entityUnitNumber] = nil
                        if pole.valid then
                            map.drainPylons[pole.unit_number] = nil
                            pole.die()
                        end
                    elseif (pole == entity) then
                        map.drainPylons[entityUnitNumber] = nil
                        if target.valid then
                            map.drainPylons[target.unit_number] = nil
                            target.destroy()
                        end
                    end
                end
            end

        elseif (entity.force.name ~= "enemy") then
            local creditNatives = false
            if (event.force ~= nil) and (event.force.name == "enemy") then
                creditNatives = true
                if (chunk ~= -1) then
                    victoryScent(map, chunk, entityType)
                end

                local drained = (entityType == "electric-turret") and map.chunkToDrained[chunk]
                if cause or (drained and (drained - tick) > 0) then
                    if ((cause and ENERGY_THIEF_LOOKUP[cause.name]) or (not cause)) then
                        local conversion = ENERGY_THIEF_CONVERSION_TABLE[entityType]
                        if conversion then
                            local newEntity = surface.create_entity({
                                    position=entity.position,
                                    name=convertTypeToDrainCrystal(entity.force.get_evolution_factor(surface), conversion),
                                    direction=entity.direction
                            })
                            if (conversion == "pole") then
                                local targetEntity = surface.create_entity({
                                        position=entity.position,
                                        name="pylon-target-rampant",
                                        direction=entity.direction
                                })
                                targetEntity.backer_name = ""
                                local pair = {targetEntity, newEntity}
                                map.drainPylons[targetEntity.unit_number] = pair
                                map.drainPylons[newEntity.unit_number] = pair
                                local wire_connector = entity.get_wire_connector(defines.wire_connector_id.pole_copper)
								local newWire_connector = newEntity.get_wire_connector(defines.wire_connector_id.pole_copper)
								for _, wireConnection in pairs(wire_connector.connections) do
									newWire_connector.connect_to(wireConnection.target, true)
								end
                            elseif newEntity.backer_name then
                                newEntity.backer_name = ""
                            end
                        end
                    end
                end
            elseif (entity.type == "resource") and (entity.force.name == "neutral") then
                if (entity.amount == 0) then
                    unregisterResource(entity, map)
                end
            end
            if creditNatives then
				if universe.safeBuildings and entityIsImmortal(entity) then
					makeImmortalEntity(surface, entity)
				else	
					accountPlayerEntity(entity, map, false, creditNatives)
				end
				if (entityType ~= "wall") and cause and cause.valid and (cause.type == "unit") and cause.commandable and cause.commandable.parent_group then
					local squad = universe.groupNumberToSquad[cause.commandable.parent_group.unique_id]
					if squad then
						squad.kills = (squad.kills or 0) + 1
					end
				end
           else
                accountPlayerEntity(entity, map, false, creditNatives)
            end	
        end
    end
end

local function onEnemyBaseBuild(event)
    local entity = event.entity
    if entity.valid then
        local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
		
		if map.suspended then
			map.suspended = false
			map.suspendCheckTick = event.tick				
		end
		
        local chunk = getChunkByPosition(map, entity.position)
        if (chunk ~= -1) then
            local base
            if universe.NEW_ENEMIES then
				local thisIsRampantEnemy = false
                base = findNearbyBase(map, chunk, MAXIMUM_BASE_RADIUS, BASE_CHANGING_CHANCE)
                if not base then
					thisIsRampantEnemy = map.hasNonmoddedBiters and thisIsNewEnemyPosition(universe, chunk.x, chunk.y)
                    base = createBase(map,
                                      chunk,
                                      event.tick,
									  thisIsRampantEnemy)
                end
				if map.hasNonmoddedBiters and base and base.thisIsRampantEnemy then					
					if needReplacement(map, entity) then	-- if change this, look also chunkUtils.initialScan
						entity = upgradeEntity(entity,
										   base.alignment,
										   map ,nil, true)
					end					   
				end						   
            end
            if entity and entity.valid then
                event.entity = registerEnemyBaseStructure(map, entity, base)
            end
        else
            local x,y = positionToChunkXY(entity.position)
            onChunkGenerated({
                    surface = entity.surface,
                    area = {
                        left_top = {
                            x = x,
                            y = y
                        }
                    }
            })
        end
    end
end

local function onSurfaceTileChange(event)
    local surfaceIndex = event.surface_index or (event.robot and event.robot.surface and event.robot.surface.index)
    local map = universe.maps[surfaceIndex]
	if not map then
		return
	end	
    local surface = map.surface
    local chunks = {}
    local tiles = event.tiles
    if event.tile then
        if ((event.tile.name == "landfill") or sFind(event.tile.name, "water")) then
            for i=1,#tiles do
                local position = tiles[i].position
                local chunk = getChunkByPosition(map, position)

                if (chunk ~= -1) then
					local chunkData = {chunk.x, chunk.y, map.surface.index}
					local chunkIndex = "x"..chunkData[1].."y"..chunkData[2].."m"..chunkData[3]

                    universe.chunkToPassScan[chunkIndex] = chunkData
                else
                    local x,y = positionToChunkXY(position)
                    local addMe = true
                    for ci=1,#chunks do
                        local c = chunks[ci]
                        if (c.x == x) and (c.y == y) then
                            addMe = false
                            break
                        end
                    end
                    if addMe then
                        local chunkXY = {x=x,y=y}
                        chunks[#chunks+1] = chunkXY
                        onChunkGenerated({area = { left_top = chunkXY },
                                          surface = surface})
                    end
                end
            end
        end
    else
        for i=1,#tiles do
            local tile = tiles[i]
            if (tile.name == "landfill") or sFind(tile.name, "water") then
                local position = tile.position
                local chunk = getChunkByPosition(map, position)

                if (chunk ~= -1) then
					local chunkData = {chunk.x, chunk.y, map.surface.index}
					local chunkIndex = "x"..chunkData[1].."y"..chunkData[2].."m"..chunkData[3]

                    universe.chunkToPassScan[chunkIndex] = chunkData
                else
                    local x,y = positionToChunkXY(position)
                    local addMe = true
                    for ci=1,#chunks do
                        local c = chunks[ci]
                        if (c.x == x) and (c.y == y) then
                            addMe = false
                            break
                        end
                    end
                    if addMe then
                        local chunkXY = {x=x,y=y}
                        chunks[#chunks+1] = chunkXY
                        onChunkGenerated({area = { left_top = chunkXY },
                                          surface = surface})
                    end
                end
            end
        end
    end
end

local function onResourceDepleted(event)
    local entity = event.entity
    if entity.valid then
		local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
        unregisterResource(entity, map)
    end
end

local function onRobotCliff(event)
    local entity = event.robot
    if entity.valid then
        local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
        if (event.item.name == "cliff-explosives") then
            entityForPassScan(map, event.cliff)
        end
    end
end

local function onUsedCapsule(event)
    local surface = game.players[event.player_index].surface
    local map = universe.maps[surface.index]
	if not map then
		return
	end	
    if (event.item.name == "cliff-explosives") then
        local position2Top = universe.position2Top
        local position2Bottom = universe.position2Bottom
        position2Top.x = event.position.x-0.75
        position2Top.y = event.position.y-0.75
        position2Bottom.x = event.position.x+0.75
        position2Bottom.y = event.position.y+0.75
        local cliffs = surface.find_entities_filtered(universe.cliffQuery)
        for i=1,#cliffs do
            entityForPassScan(map, cliffs[i])
        end
    end
end

local function onRocketLaunch(event)
    -- local entity = event.rocket_silo or event.rocket
    -- if entity.valid then
        -- local map = universe.maps[entity.surface.index]
		-- local points
		-- if game.active_mods["space-exploration"] then
			-- map.retribution = map.retribution + 0.1
			-- points = 500
		-- else
			-- map.retribution = map.retribution + 10
			-- points = 5000
		-- end	
		-- if not map then
			-- return
		-- end	
 		-- map.vengenceLimiter = 0
        -- map.rocketLaunched = map.rocketLaunched + 1
        -- map.points = map.points + points
        -- if universe.aiPointsPrintGainsToChat then
            -- game.print(map.surface.name .. ": Points: +" .. points .. ". [Rocket Launch] Total: " .. string.format("%.2f", map.points))
        -- end
    -- end
end

local function onTriggerEntityCreated(event)
    local entity = event.entity

    if entity.valid and (entity.name  == "drain-trigger-rampant") then
		local map = universe.maps[entity.surface.index]
		if not map then
			return
		end	
		local chunk = getChunkByPosition(map, entity.position)
		if (chunk ~= -1) then
			map.chunkToDrained[chunk] = event.tick + 60
		end
		entity.destroy()
	end
end

local function onGroupFinishedGathering(event)
    local group = event.group
    if not group.valid or (group.force.name ~= "enemy") then
		return
	end
	local map = universe.maps[group.surface.index]
	if not map then 
		return		
	end
	local squad = universe.groupNumberToSquad[group.unique_id]
	if (not group.is_script_driven) or (squad and not squad.vengence) then
		if (not group.is_script_driven) and (not settings.global["rampantFixed--allowDaytimeNonRampantActions"].value) then
			if (map.state == constants.AI_STATE_PEACEFUL) or (universe.aiNocturnalMode and (group.surface.darkness <= 0.65)) then
				group.destroy()
				return		
			end	
		end	
	end
	
	if squad then
		if squad.onTheWay then
			return
		end	
		if (not squad.undergoundAttack) or squad.hasSpiders then
			processCompression(map, squad, getChunkByPosition(map, group.position), true)
		else
			createUndergroudAttack(map, squad)
		end
	elseif group.position and not group.is_script_driven then
		local nonRampantSquad = universe.nonRampantSquads[group.unique_id] or universe.nonRampantCompressedSquads[group.unique_id]
		if nonRampantSquad then
			return
		end	
		local nonRampantSquad = createSquad(group.position, map, group, false)
		nonRampantSquad.nonRampantSquad = true
		if (#group.members > 70) then
			processCompression(map, nonRampantSquad, getChunkByPosition(map, group.position), false)
		end	
		if nonRampantSquad.compressed then
			universe.nonRampantCompressedSquads[group.unique_id] = nonRampantSquad
		else
			universe.nonRampantSquads[group.unique_id] = nonRampantSquad				
		end
		-- 2025/07. AI bug. if no default units then group can't build new base 
		-- so, lets create 1 unit when group created + destroy it when group finish gathering
		if map.hasNonmoddedBiters then
			local members = group.members
			for _, entity in pairs(members) do
				entity.destroy()
				break
			end	
			
		end
	end
	-- group can be destroyed after createUndergroudAttack()
	if squad and group.valid and group.is_script_driven and not squad.onTheWay then
		squadDispatch(map, squad)
	end
end

-- debug
		-- 2025/07. AI bug. if no default units then group can't build new base 
		-- so, lets create 1 unit when group created + destroy it when group finish gathering
local function on_unit_group_created(event)
    local group = event.group
    if not group.valid or (group.force.name ~= "enemy") or group.is_script_driven then
		return
	end
	local map = universe.maps[group.surface.index]
	if not map then 
		return		
	end
	
	if map.hasNonmoddedBiters then
		local newEntity = group.surface.create_entity({
			name = "small-biter",
			position = group.position, 
			force = group.force,
			})
		group.add_member(newEntity)
	end
end
------

local function onForceCreated(event)
	upgrade.rebuildActivePlayerForces(universe)
	-- if event.force then
		-- if game.forces["enemy"].is_friend(event.force) then
			-- return
		-- end	
		-- if game.forces["enemy"].get_cease_fire(event.force) then
			-- return
		-- end	
	-- end
    -- universe.activePlayerForces[#universe.activePlayerForces+1] = event.force.name
end

local function onForceDiplomacyChanged(event)
	upgrade.rebuildActivePlayerForces(universe)
	-- local otherForce = event.force
	-- if event.force.name == "enemy" then
		-- otherForce = event.other_force
	-- end
	-- local thisIsEnemyFriend = game.forces["enemy"].is_friend(otherForce)
	-- thisIsEnemyFriend = thisIsEnemyFriend or game.forces["enemy"].get_cease_fire(otherForce)
	-- if thisIsEnemyFriend then
		-- for i=#universe.activePlayerForces,1,-1 do
			-- if (universe.activePlayerForces[i] == otherForce.name) then
				-- tRemove(universe.activePlayerForces, i)
				-- break
			-- end
		-- end
	-- else
		-- local forceFound = false
		-- for i=#universe.activePlayerForces,1,-1 do
			-- if (universe.activePlayerForces[i] == otherForce.name) then
				-- forceFound = true
				-- break
			-- end	
		-- end	
		-- if not forceFound then
			-- universe.activePlayerForces[#universe.activePlayerForces+1] = otherForce.name
		-- end
	-- end
end 

local function onForceMerged(event)
	upgrade.rebuildActivePlayerForces(universe)
    -- for i=#universe.activePlayerForces,1,-1 do
        -- if (universe.activePlayerForces[i] == event.source_name) then
            -- tRemove(universe.activePlayerForces, i)
            -- break
        -- end
    -- end
end

local function onSurfaceCreated(event)
	local surface = game.surfaces[event.surface_index]
	if not SURFACE_IGNORED(surface, universe) then
		prepMap(surface)
		local map = universe.maps[event.surface_index]
		if map then
			map.firstStateTick = game.tick
		end	
	end	
end

local function onSurfaceDeleted(event)
    local surfaceIndex = event.surface_index
    if (universe.mapIterator == surfaceIndex) then
        universe.mapIterator, universe.activeMap = next(universe.maps, universe.mapIterator)
    end
    if (universe.suspendMapsIterator == surfaceIndex) then
        universe.suspendMapsIterator = next(universe.maps, universe.suspendMapsIterator)
    end
	
	universe.maps[surfaceIndex] = nil
	--game.print("onSurfaceDeleted: surfaceIndex =".. tostring(surfaceIndex))	-- debug
	-- bases and squads will be deleted by baseUtils.recycleBases and squadAttack.cleanSquads
end

local function onBuilderArrived(event)
    local builder = event.group
    if not (builder and builder.valid) then
        builder = event.unit
        if not (builder and builder.valid and builder.force.name == "enemy") then
            return
        end
    elseif (builder.force.name ~= "enemy") then
        return
    end
    local targetPosition = universe.position
    targetPosition.x = builder.position.x
    targetPosition.y = builder.position.y

    if universe.aiPointsPrintSpendingToChat then
        game.print("Settled: [gps=" .. targetPosition.x .. "," .. targetPosition.y .. "," .. builder.surface.name .."]")		
    end
    builder.surface.create_entity(universe.createBuildCloudQuery)
	local map = universe.maps[builder.surface.index]
	if map then
		local chunk = mapUtils.getChunkByXY(map, builder.position.x, builder.position.y)
		if chunk and (chunk~=-1) then
			chunk.nextSquadTick = game.tick + 3600*5	-- temporary stop attacks from this chunk
		end
		local group = event.group
		if group and group.is_unit_group and not universe.groupNumberToSquad[group.unique_id] then
			local members = {}
			for _, entity in pairs(group.members) do 
				if entity.valid and (entity.type == "unit") then
					members[#members+1] = entity
				end
			end
			if #members > 0 then
				universe.nonRampantBuilders[group] = members
			end	
		end
	end	
end

local targetDummyArray= {}
targetDummyArray["targetDummyPlasma-rampant"] = true
targetDummyArray["targetDummyFire-rampant"] = true
targetDummyArray["targetDummyPhysical-rampant"] = true
targetDummyArray["targetDummyLaser-rampant"] = true

local protectedAreaUnitsQuery = {
		position = nil,
		radius = 6,
        force = "enemy",
        type={"unit"}
		}
 
local function onSectorScanned(event)
	local entity = event.radar
	if entity.valid then
		if targetDummyArray[entity.name] then
			-- canceled since 1.5.0
			-- if entity.name == "targetDummyPlasma-rampant" then
				-- protectedAreaUnitsQuery.position = entity.position
				-- local protectedEntities = entity.surface.find_entities_filtered(protectedAreaUnitsQuery)
				-- for i = 1, #protectedEntities do
					-- local protectedEntity = protectedEntities[i]
					-- protectedEntity.destructible = false
					-- universe.protectedUnits[protectedEntity.unit_number] = {entity = protectedEntity, tick = game.tick + 120}
					-- --game.print("tick:"..game.tick.. " add protection to "..universe.protectedUnits[protectedEntity.unit_number].tick)
				-- end	
			-- end
			entity.damage(3000, "neutral")
		elseif hasSpaceAgeMod and biterSupressionType(entity.name) then
			processSupression(entity)
		elseif entity.name == "test-rampant" then
			onEntitySpawned(event)
			entity.damage(1, "neutral")
		elseif entity.name == "regenerationCrystal-rampantFixed" then
			powerup.onRegenerationCrystalTick(entity, game.forces.enemy.get_evolution_factor(entity.surface))
		end
	end
	return
end

local function processProtectedUnits()
	-- if not universe then
		-- return
	-- end	
	for unitNumber, protectionData in pairs(universe.protectedUnits) do
		if not protectionData.entity.valid then
			universe.protectedUnits[unitNumber] = nil
		elseif protectionData.tick <= game.tick then
			protectionData.entity.destructible = true
			universe.protectedUnits[unitNumber] = nil	
			--game.print("tick:"..game.tick.." remove protection")
		end
	end
end


-- this variables reset after reloading (player can change/disable protecion at startup settings)
-- as practice has shown, local variables do not lead to desynchronization, unless it leads to different results
local unitsProtection = {}
local OP_EfficiencyPercent = settings.startup["rampantFixed--oneshotProtection_efficiency"].value
local LR_EfficiencyPercent = settings.startup["rampantFixed--longRangeImmunity_efficiency"].value 
local OP_efficienty = OP_EfficiencyPercent * 0.01
local LR_Efficiency = LR_EfficiencyPercent * 0.01
local LR_DamageKf = 1 - LR_Efficiency
local allowOneshotProtection = settings.startup["rampantFixed--allowOneshotProtection"]
local allowLongRangeImmunity = settings.startup["rampantFixed--allowLongRangeImmunity"]

local LR_exceptions = {}
LR_exceptions["fluid-turret"] = true
LR_exceptions["artillery-turret"] = true
LR_exceptions["artillery-wagon"] = true
local LR_exceptions_DamageKf = 0.5
 

local function fillAndReturnUnitProtections(entity)
	if unitsProtection[entity.name] then
		return unitsProtection[entity.name]
	else
		local longRangeImmunity
		local overdamageProtection
		if entity.prototype.resistances then
			for resistance, values in pairs(entity.prototype.resistances) do
				-- some checks, becouse mods can assign there resistances to their own units. And make them almost immortal
				if resistance == "rampant-longRangeImmunity" then
					if values.percent and (math.floor(100*values.percent+0.1) == LR_EfficiencyPercent) and (values.decrease > 10) then	-- 	-- bug: sometimes percent can differ (ex: 0.949000049)
						longRangeImmunity = values.decrease
					end	
				elseif resistance == "rampant-overdamageProtection" then
					if values.percent and (math.floor(100*values.percent+0.1) == OP_EfficiencyPercent) and (values.decrease > 5) then 
						overdamageProtection = values.decrease
					end	
				end					
			end
		end	
		unitsProtection[entity.name] = {longRangeImmunity = longRangeImmunity, overdamageProtection = overdamageProtection}
		-- game.print("LRI = "..tostring(longRangeImmunity).." , OP = "..tostring(overdamageProtection))	-- debug
		return unitsProtection[entity.name]
	end
end	
 
local function onEntityDamaged(event)
	if not event.entity then
		return
	end
	if event.entity.valid and event.entity.unit_number then
		local entity = event.entity
		 
		local unitProtection = fillAndReturnUnitProtections(event.entity)
		if (event.final_damage_amount > 0) and event.cause and (event.cause ~= event.entity) then
			if onUnitDamaged_oneshot(event, universe) then
				return
			 end
			-----------------
			if allowLongRangeImmunity and unitProtection.longRangeImmunity then
				local incomingRange = 0
				if event.cause and event.cause.valid then
					if LR_exceptions[event.cause.type] then
						incomingRange = -1
					else	
						incomingRange = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, event.cause.position.x, event.cause.position.y)
					end	
					if incomingRange == - 1 then
						local startHP = universe.unitProtectionData.unitCurrentHP[entity.unit_number] or (entity.max_health)
						event.final_damage_amount = event.final_damage_amount * LR_exceptions_DamageKf
						entity.health = startHP - event.final_damage_amount					
						event.final_health = entity.health					
					elseif incomingRange>unitProtection.longRangeImmunity then
						local startHP = universe.unitProtectionData.unitCurrentHP[entity.unit_number] or (entity.max_health)
						if LR_DamageKf > 0 then
							event.final_damage_amount = event.final_damage_amount * LR_DamageKf
						else
							event.final_damage_amount =	0
						end	
						entity.health = startHP - event.final_damage_amount					
						event.final_health = entity.health					
						-- game.print("LRI:"..startHP.."-("..event.original_damage_amount.."->"..event.final_damage_amount..")="..entity.health)	-- DEBUG
					end	
				end	
			end
			-----------------
			if allowOneshotProtection and unitProtection.overdamageProtection and (event.original_damage_amount > OVERDAMAGEPROTECTION_THRESHOLD) and (event.original_damage_amount >= event.final_damage_amount)  then
				local maxDamage = unitProtection.overdamageProtection
				local startHP = universe.unitProtectionData.unitCurrentHP[entity.unit_number] or (entity.max_health)
				if maxDamage<event.original_damage_amount then
					local final_damage_amount = maxDamage*(event.final_damage_amount/event.original_damage_amount)
					if OP_efficienty < 1 then
						final_damage_amount = event.final_damage_amount - (event.final_damage_amount - final_damage_amount) * OP_efficienty
					end
					event.final_damage_amount = final_damage_amount
					entity.health = startHP - final_damage_amount
				end	
				event.final_health = entity.health
				--game.print("OP:"..startHP.."-("..event.original_damage_amount.."->"..event.final_damage_amount..")="..entity.health..", source = ".. tostring(event.cause.name))		-- DEBUG
			end
		end
		
		-- canceled since 1.5.0
		-- if entity.health<=0 then 
			-- local compressedUnit = universe.compressedUnits[entity.unit_number]
			-- if compressedUnit and (compressedUnit.count > 1) then
				-- onUnitPreKilled(universe, entity.surface, entity, event.force, event.cause)
			-- end	
		-- end	
		
		if unitProtection.longRangeImmunity or unitProtection.overdamageProtection then
			if entity.health<=0 then
				universe.unitProtectionData.unitCurrentHP[entity.unit_number] = nil
			else
				universe.unitProtectionData.unitCurrentHP[entity.unit_number] = entity.health
			end
		end
	end		
end

local function onSegmentedEntityDamaged(event)
	demolisherUtils.onSegmentedEntityDamaged(event)
end

local function processPlanetAISettings()
	for planetName ,planetAISetting in pairs(universe.planetAISettings) do
		if planetAISetting.changed then
			if not (planetName == "others") then
				local surface = game.surfaces[planetName]
				if surface and (not constants.isExcludedSurface(surface.name)) then
					universe.surfaceIgnoringSet[surface.index] = nil
					if (planetAISetting.AI == 1) then
						if universe.maps[surface.index] then
							onSurfaceDeleted({surface_index = surface.index})
							-- game.print({"description.rampantFixed--AI_PlanetOff", planetName})	-- debug			
						end	
					else
						if not universe.maps[surface.index] then
							onSurfaceCreated({surface_index = surface.index})
							local map = universe.maps[surface.index]
							if map then
								map.firstStateTick = 0		-- prevent cheating by on/off AI
								map.truceEndTick = 0
							end
							-- game.print({"description.rampantFixed--AI_PlanetOn", planetName})	-- debug			
						end
					end

				end				
				planetAISetting.changed = false
			end
		end	
	end	
	
	local planetAISetting = universe.planetAISettings.others
	if planetAISetting and planetAISetting.changed then
		for _,surface in pairs(game.surfaces) do
			if (not constants.isExcludedSurface(surface.name)) and not universe.planetAISettings[surface.name] then
				if (planetAISetting.AI == 1) then
					if universe.maps[surface.index] then
						onSurfaceDeleted({surface_index = surface.index})
						-- game.print({"description.rampantFixed--AI_PlanetOff", surface.name})			
					end	
				else
					if not universe.maps[surface.index] then
						onSurfaceCreated({surface_index = surface.index})
						-- game.print({"description.rampantFixed--AI_PlanetOn", surface.name})			
					end
				end							
			end
		end
		planetAISetting.changed = false
	end
end
	
local function processNewSurfaceStasus(universe)
	if not universe.newSurfaceStasus then
		return
	end	
	for surface_index, newStasus in pairs (universe.newSurfaceStasus) do
		if newStasus == "create" then
			if not universe.maps[surface_index] then
				onSurfaceCreated({surface_index = surface_index})
			end	
		elseif newStasus == "delete" then
			if universe.maps[surface_index] then
				onSurfaceDeleted({surface_index = surface_index})
			end	
		end		
	end
	universe.newSurfaceStasus = nil	
end


local function showNewgameMessages()
	-- game.print({"description.rampantFixed--enableShootingAlerts"})	
	-- if universe.NEW_ENEMIES then
		-- game.print({"description.rampantFixed--EnemySettings1_1_10"})	
	-- end
end	


-- hooks
local function on_player_cursor_stack_changed(event)
	local player = game.players[event.player_index]
	if universe.powerupSettings[player.name] and universe.powerupSettings[player.name].endlessAmmo then
		powerup.on_player_cursor_stack_changed(player, universe.powerupSettings[player.name])
	end
end
script.on_event(defines.events.on_player_cursor_stack_changed, on_player_cursor_stack_changed)


local function on_player_ammo_inventory_changed(event)
	local player = game.players[event.player_index]
	if universe.powerupSettings[player.name] and universe.powerupSettings[player.name].endlessAmmo then
		powerup.endlessAmmo_onInventoryChanged(player, universe.powerupSettings[player.name])
	end
end
script.on_event(defines.events.on_player_ammo_inventory_changed, on_player_ammo_inventory_changed)

local function onScriptTriggerEffect(event)

	if event.effect_id == "powerup-combat5min-rampantFixed" and event.target_entity and event.target_entity.valid then
		powerup.applyCombatPowerup(event.target_entity.player, universe.powerupSettings, 3600*5)
	elseif hasSpaceAgeMod and (event.effect_id == "feed-the-demolisher-rampant" and event.target_entity and event.target_entity.valid) then
		demolisherUtils.feedDemolisher(event.target_entity, event.cause_entity, event.surface_index)
	elseif hasSpaceAgeMod and (event.effect_id == "fear-demolisher-rampant") then
		demolisherUtils.fearDemolishers(event.surface_index)
	end
end
 
local function onPlayerRespawned(event)
	local player = game.players[event.player_index]
	if (not player.valid) or (not player.character) then
		return
	end
	if universe.powerupSettings[player.name] then
		powerup.onPlayerRespawned(player, universe.powerupSettings)
		powerup.drawPowerups(player, universe.powerupSettings[player.name])
	end
end 
 
script.on_event(defines.events.on_tick,
                function ()
                    local gameRef = game
                    local tick = gameRef.tick
                    local pick = tick % 8
					local pick60 = tick % 60
					---------
					if tick == 1 then
						showNewgameMessages()
					end	
					---------
					removeOneTickImmunity(universe)
					processProtectedUnits()
					
                    local map = universe.activeMap
					local mapCounter = 0			-- it looks very much like some mods are able to remove the main world. If this happens and there are no worlds left with biters, it will turn out to be an endless cycle.
                    if (not map) or map.suspended or (universe.processedChunks > #map.processQueue) then
						repeat
							universe.mapIterator, map = next(universe.maps, universe.mapIterator)
							if not map then
								universe.mapIterator, map = next(universe.maps, nil)	
								break
							end
							mapCounter = mapCounter + 1
						until map and ((not map.suspended) or (map.surface.name == "nauvis") or (mapCounter > 1000))	-- nauvis cant be suspended, but just in case...
						
                        universe.processedChunks = 0
                        universe.activeMap = map
                    end
					if not map then
						if universe.mapIterator then 
							universe.maps[universe.mapIterator] = nil
							universe.mapIterator = nil
						end	
                        processPendingChunks(universe, tick)
                        processScanChunks(universe)
                        universe.processedChunks = universe.processedChunks + PROCESS_QUEUE_SIZE
						return
					end	
					

                    if (pick == 0) then
                        processPendingChunks(universe, tick)
                        processScanChunks(universe)
                        universe.processedChunks = universe.processedChunks + PROCESS_QUEUE_SIZE
                        if universe.NEW_ENEMIES then
                            recycleBases(universe, tick)
                        end
                        cleanUpMapTables(map, tick)
                    elseif (pick == 1) then
						processPlayers(gameRef.connected_players, universe, tick)
                    elseif (pick == 2) then
						processMap(map, tick)			
                    elseif (pick == 3) then
                        processStaticMap(map)
						disperseVictoryScent(map)
                        processVengence(map)
                     elseif (pick == 4) then
                        scanResourceMap(map, tick)		
                    elseif (pick == 5) then
                        scanEnemyMap(map, tick)
                        processSpawners(map, tick)
                    elseif (pick == 6) then
                        scanPlayerMap(map, tick)		
                        processNests(map, tick)			
                    elseif (pick == 7) then
						processGrowingBases(universe, tick)
                    end
					
					if pick60 == 0 then	
						processMapAIs(universe, tick)
					end

					if pick~=5 then
						processPendingMutations(universe)
					end	
                    processActiveNests(universe, tick)
					processDecompressQueue(universe)
                    processSquads(universe)
		end
)
script.on_nth_tick(30000, 
	function()
		if universe then
			local evo = game.forces.enemy.get_evolution_factor()
			if settings.startup["rampantFixed--JuggernautEnemy"].value and (not universe.JuggernautAlertShown) and (evo > 0.75) and (evo < 0.82) then
				universe.JuggernautAlertShown = true
				game.print({"description.rampantFixed--JuggernautAlert"})
			end
			baseUtils.setRandomBaseToMutate(universe)
			if hasSpaceAgeMod then
				demolisherUtils.vulcanusEvolution()	-- if you change the call frequency, then change the function
			end	
		end	
	end
)

script.on_nth_tick(5000,
	function()
		if universe then
			suspendClearedMaps(universe, game.tick)
			if hasSpaceAgeMod then
				demolisherUtils.processDemolishers()
			end	
			---
			if universe.nonRampantSquads then
				for i, squad in pairs(universe.nonRampantSquads) do
					if not squad.group.valid then
						universe.nonRampantSquads[i] = nil
					end	
				end
			end
		end	
	end
)

script.on_nth_tick(300, 
	function()
		if universe then
			processPlanetAISettings()
			processNewSurfaceStasus(universe)			
			-----------
			if storage.showAISettingsForPlayer and (game.tick >=300) and (#game.players > 0) then
				for playerIndex, player in pairs(game.players) do
					local player_settings = settings.get_player_settings(player)
					if player.admin or in_debug_list(player) then						
						if player_settings["rampantFixed--showPlanetAISettings"].value then
							GUI_Elements.openPlanetAISettings(player.index)
							break
						end
					end
				end			
				for playerIndex, player in pairs(game.players) do
					local player_settings = settings.get_player_settings(player)
					player_settings["rampantFixed--showPlanetAISettings"] = {value = false}
				end			
				
				storage.showAISettingsForPlayer = nil
			end
			-----------
			
			if hasSpaceAgeMod then
				demolisherUtils.processDemolisherTriggers()
			end	
		end	
	end
)
--- copressed and underground squads
script.on_nth_tick(60, 
	function()
		if universe then
			if universe.nonRampantCompressedSquads then
				nonRampantCompressedSquads(universe)
			end
		end
	end
)

script.on_nth_tick(30, 
	function()
		if universe then
			undergroundAttack.processUndergroundSquads(universe)
		end
	end
)
--------------
script.on_nth_tick(252, 
	function()
		if universe and (game.tick > 0) then
			processNonRampantBuilders(universe, game.tick)
			processBuilders(universe, game.tick)
		end
	end
)

script.on_nth_tick(3600,
	function()
		if universe then			
			for _, map in pairs(universe.maps) do
				if map and (not map.suspended) and map.surface.valid then
					undergroundAttack.updateUndergroundAttackProbability(map)
					map.buildingsLvl = baseUtils.evoToBuildingLvl(game.forces.enemy.get_evolution_factor(map.surface))
				end	
			end
			---------------
			mapProcessor.showGrowingCloud(universe)
		end
	end
)

script.on_nth_tick(36000, 
	function()
		squadCompression.checkCompressedUnitsList(universe)
	end
)

local function on_gui_click(event)
	GUI_Elements.on_gui_click(event)
	return
end

local function onModSettingsChange(event)

    if not isRampantSetting(event.setting) then
        return
    end

    -- game.print("onModSettingsChange() processing for Rampant")

    upgrade.compareTable(universe,
                         "safeBuildings",
                         settings.global["rampantFixed--safeBuildings"].value)
	------- curved rails					 
    upgrade.compareTable(universe.safeEntities,
                         "curved-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "legacy-curved-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "curved-rail-a",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "curved-rail-b",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
						 
	------- elevated rails					 
    upgrade.compareTable(universe.safeEntities,
                         "rail-ramp",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
						 
    upgrade.compareTable(universe.safeEntities,
                         "elevated-straight-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "elevated-half-diagonal-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "elevated-curved-rail-a",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "elevated-curved-rail-b",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "rail-support",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
	-------------------					 
    upgrade.compareTable(universe.safeEntities,
                         "straight-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
						 
    upgrade.compareTable(universe.safeEntities,
                         "half-diagonal-rail",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
						 
	-------------------					 
    upgrade.compareTable(universe.safeEntities,
                         "rail-signal",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "rail-chain-signal",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "train-stop",
                         settings.global["rampantFixed--safeBuildings-straightRail"].value)
    upgrade.compareTable(universe.safeEntities,
                         "lamp",
                         settings.global["rampantFixed--safeBuildings-lamps"].value)

    local changed, newValue = upgrade.compareTable(universe.safeEntities,
                                                   "big-electric-pole",
                                                   settings.global["rampantFixed--safeBuildings-bigElectricPole"].value)
    if changed then
        universe.safeEntities["big-electric-pole"] = newValue
        universe.safeEntities["big-electric-pole-2"] = newValue
        universe.safeEntities["big-electric-pole-3"] = newValue
        universe.safeEntities["big-electric-pole-4"] = newValue
        universe.safeEntities["lighted-big-electric-pole-4"] = newValue
        universe.safeEntities["lighted-big-electric-pole-3"] = newValue
        universe.safeEntities["lighted-big-electric-pole-2"] = newValue
        universe.safeEntities["lighted-big-electric-pole"] = newValue
		-- planned: chande "destructible" flag for enities on the map
    end

    upgrade.compareTable(universe,
                         "aiDifficulty",
                         settings.global["rampantFixed--aiDifficulty"].value)
    upgrade.compareTable(universe,
                         "raidAIToggle",
                         settings.global["rampantFixed--raidAIToggle"].value)
    upgrade.compareTable(universe,
                         "siegeAIToggle",
                         settings.global["rampantFixed--siegeAIToggle"].value)

    universe.undergroundAttack = settings.global["rampantFixed--undergroundAttack"].value

    upgrade.compareTable(universe,
                         "demolisherAttack_AdditionalTime",
                         settings.global["rampantFixed--demolisherAttack_AdditionalTime"].value)

    upgrade.compareTable(universe,
                         "attackPlayerThreshold",
                         settings.global["rampantFixed--attackPlayerThreshold"].value)
    upgrade.compareTable(universe,
                         "attackUsePlayer",
                         settings.global["rampantFixed--attackWaveGenerationUsePlayerProximity"].value)

    upgrade.compareTable(universe,
                         "attackWaveMaxSize",
                         settings.global["rampantFixed--attackWaveMaxSize"].value)
    upgrade.compareTable(universe,
                         "agressiveStart",
                         settings.global["rampantFixed--agressiveStart"].value)
    upgrade.compareTable(universe,
                         "attackWaveMaxSizeEvoPercent",
                         settings.global["rampantFixed--attackWaveMaxSizeEvoPercent"].value)
    upgrade.compareTable(universe,
                         "aiNocturnalMode",
                         settings.global["rampantFixed--permanentNocturnal"].value)
    upgrade.compareTable(universe,
                         "aiPointsScaler",
                         settings.global["rampantFixed--aiPointsScaler"].value)

    universe.aiPointsPrintGainsToChat = settings.global["rampantFixed--aiPointsPrintGainsToChat"].value
    universe.aiPointsPrintSpendingToChat = settings.global["rampantFixed--aiPointsPrintSpendingToChat"].value

    universe.enabledMigration = universe.expansion and settings.global["rampantFixed--enableMigration"].value
    universe.printAIStateChanges = settings.global["rampantFixed--printAIStateChanges"].value
    universe.debugTemperament = settings.global["rampantFixed--debugTemperament"].value

    upgrade.compareTable(universe,
                         "AI_MAX_SQUAD_COUNT",
                         settings.global["rampantFixed--maxNumberOfSquads"].value)
    upgrade.compareTable(universe,
                         "AI_MAX_BUILDER_COUNT",
                         settings.global["rampantFixed--maxNumberOfBuilders"].value)
	
	for playerIndex, player in pairs(game.players) do
		local player_settings = settings.get_player_settings(player)
		if player.admin or in_debug_list(player) then
			if player_settings["rampantFixed--showAdminMenu"].value then
				GUI_Elements.create_disableAdminMenuButton(player, true)
			else
				GUI_Elements.create_disableAdminMenuButton(player, false)			
			end	
			
			if player_settings["rampantFixed--showPlanetAISettings"].value then
				GUI_Elements.openPlanetAISettings(player.index)							
			end
		end
	end
	
    return true
end

local function onConfigChanged()
    local version = upgrade.attempt(universe)
    if version then
        if not universe then
            universe = storage.universe
        end
    end

    onModSettingsChange({setting="rampantFixed--"})

    upgrade.compareTable(universe,
                         "ENEMY_VARIATIONS",
                         settings.startup["rampantFixed--newEnemyVariations"].value)
    upgrade.compareTable(universe,
                         "NEW_ENEMIES",
                         settings.startup["rampantFixed--newEnemies"].value)

	upgrade.rebuildActivePlayerForces(universe)
	
    if universe.NEW_ENEMIES then
        rebuildNativeTables(universe)
		if not universe["NEW_ENEMIES_SIDE"] then
			setNewEnemySide()
		elseif (universe["NEW_ENEMIES_SIDE"] ~= settings.startup["rampantFixed--newEnemiesSide"].value)
			or (universe["ALLOW_OTHER_ENEMIES"] ~= settings.startup["rampantFixed--allowOtherEnemies"].value)
			then 
			game.print({"description.rampantFixed--NEW_ENEMIES_SIDE_ignored"})		
		end
    else
        universe.buildingHiveTypeLookup = {}
        universe.buildingHiveTypeLookup["biter-spawner"] = "biter-spawner"
        universe.buildingHiveTypeLookup["spitter-spawner"] = "spitter-spawner"
        universe.buildingHiveTypeLookup["small-worm-turret"] = "turret"
        universe.buildingHiveTypeLookup["medium-worm-turret"] = "turret"
        universe.buildingHiveTypeLookup["big-worm-turret"] = "turret"
        universe.buildingHiveTypeLookup["behemoth-worm-turret"] = "turret"
    end

    for _,surface in pairs(game.surfaces) do
        if not universe.maps then
            universe.maps = {}
        end
        if (not universe.maps[surface.index]) and (not SURFACE_IGNORED(surface, universe)) then
            prepMap(surface)
        end
    end
end

local function onInit()
    storage.universe = {}
    hookEvents()
    onConfigChanged()
	setNewEnemySide()
	
end

script.on_event(defines.events.on_surface_deleted, onSurfaceDeleted)
script.on_event(defines.events.on_surface_cleared, onSurfaceCreated)
script.on_event(defines.events.on_surface_created, onSurfaceCreated)

script.on_init(onInit)
script.on_load(onLoad)
script.on_event(defines.events.on_runtime_mod_setting_changed, onModSettingsChange)
script.on_configuration_changed(onConfigChanged)

script.on_event(defines.events.on_resource_depleted, onResourceDepleted)
script.on_event({defines.events.on_player_built_tile,
                 defines.events.on_robot_built_tile,
                 defines.events.script_raised_set_tiles}, onSurfaceTileChange)

script.on_event(defines.events.on_player_used_capsule, onUsedCapsule)

script.on_event(defines.events.on_trigger_created_entity, onTriggerEntityCreated)

script.on_event(defines.events.on_pre_robot_exploded_cliff, onRobotCliff)

script.on_event(defines.events.on_biter_base_built, onEnemyBaseBuild)
script.on_event({defines.events.on_player_mined_entity,
                 defines.events.on_robot_mined_entity}, onMine)

script.on_event({defines.events.on_built_entity,
                 defines.events.on_robot_built_entity,
                 defines.events.script_raised_built,
                 defines.events.script_raised_revive}, onBuild)


script.on_event(defines.events.on_rocket_launched, onRocketLaunch)
script.on_event({defines.events.on_entity_died,
                 defines.events.script_raised_destroy}, onDeath)
script.on_event(defines.events.on_chunk_generated, onChunkGenerated)
script.on_event(defines.events.on_chunk_deleted, onChunkDeleted)
script.on_event(defines.events.on_force_created, onForceCreated)
script.on_event(defines.events.on_forces_merged, onForceMerged)
script.on_event(defines.events.on_force_cease_fire_changed, onForceDiplomacyChanged)
script.on_event(defines.events.on_force_friends_changed, onForceDiplomacyChanged)

script.on_event(defines.events.on_unit_group_finished_gathering, onGroupFinishedGathering)

script.on_event(defines.events.on_build_base_arrived, onBuilderArrived)

script.on_event(defines.events.on_sector_scanned, onSectorScanned)
script.on_event(defines.events.on_script_trigger_effect, onScriptTriggerEffect)
script.on_event(defines.events.on_player_respawned, onPlayerRespawned)

script.on_event(defines.events.on_entity_damaged, onEntityDamaged, {
	{filter="type", type="unit"}, 
	{mode = "and", invert = true, filter="damage-type", type ="fire"},
	{mode = "and", invert = true, filter="damage-type", type ="acid"},
	{mode = "or", filter="original-damage-amount", value = 200, comparison = ">"},
	{mode = "or", filter="type", type="spider-unit"},	
	{mode = "or", filter="type", type="segmented-unit"},	
	})

script.on_event(defines.events.on_segmented_unit_damaged, onSegmentedEntityDamaged)	
	
script.on_event(defines.events.on_gui_click, on_gui_click)

script.on_event(defines.events.on_unit_group_created, on_unit_group_created)	-- debug!!


local function setSurfaces(event)
	GUI_Elements.setSurfaces(event)
end

commands.add_command('rampantSetSurfaces', "", setSurfaces)

local function rampantSetAIState(event)
    local surfaceIndex = game.players[event.player_index].surface.index
    local map = universe.maps[surfaceIndex]
	if not map then
		local surfaceName = game.players[event.player_index].surface.name
		game.print(surfaceName .. " is excluded from processing ")
		return
	end	

    game.print(map.surface.name .. " is in " .. constants.stateEnglish[map.state])

    if event.parameter then
        local target = tonumber(event.parameter)

        if (target == nil) then
            game.print("invalid param")
            return
        end

        if (target ~= constants.AI_STATE_PEACEFUL 
			and target ~= constants.AI_STATE_AGGRESSIVE 
			and target ~= constants.AI_STATE_RAIDING 
			and target ~= constants.AI_STATE_MIGRATING 
			and target ~= constants.AI_STATE_SIEGE 
			and target ~= constants.AI_STATE_ONSLAUGHT
			and target ~= constants.AI_STATE_GROWING
			) then
            game.print(target .. " is not a valid state")
            return
        else
            
			map.state = target
			if map.state == constants.AI_STATE_GROWING then
				aiPlanning.updateBasesToGrow(map, game.tick, false)
			end	
            game.print(map.surface.name .. " is now in " .. constants.stateEnglish[map.state])
        end
    end
end

commands.add_command('rampantSetAIState', "", rampantSetAIState)

local function rampantForceMutations(event)
    local i = 0
    local basesTotal = 0
	
	for id, base in pairs(universe.bases) do
		basesTotal = basesTotal + 1
		if base and base.thisIsRampantEnemy then
			base.tier = 0
			i = i + 1
		end
	end
	game.print("Bases forces to mutate: ".. i.."/"..basesTotal)
	
end

commands.add_command('rampantForceMutations', "", rampantForceMutations)

local function rampantCreateCompressedBiter(event)
	local newEntity = game.players[event.player_index].surface.create_entity({
		name = "small-biter",
		position = {0, 0} 
		})	
	if newEntity then
		local compressedUnits = universe.compressedUnits
		compressedUnits[newEntity.unit_number] = {count = 10, entity = newEntity}		
	end
	
end
--commands.add_command('rampantCreateCompressedBiter', "", rampantCreateCompressedBiter)

local function resetResourceSeetlerTick(event)
    local surfaceIndex = game.players[event.player_index].surface.index
    local map = universe.maps[surfaceIndex]
	if map then
		map.resourceSettleTick = 0
		game.print("resource settle tick reseted")
		return
	end	
end
commands.add_command('resetResourceSeetlerTick', "", resetResourceSeetlerTick)

local function rampantCreateDebugMenu(event)
	GUI_Elements.rampantCreateDebugMenu(event)		
end
commands.add_command('rampantDebugMenu', "", rampantCreateDebugMenu)

if hasSpaceAgeMod then
	local function startDemolisherAttack(event)
		local surface = game.players[event.player_index].surface
		local map = universe.maps[surface.index]
		if not map then
			return
		end	
		local demolishers = surface.find_entities_filtered({force = "enemy", type = "segmented-unit"})
		local demolishersCount = #demolishers
		
		local targetEntities
		local targetEntitiesCount
		if (demolishersCount > 0) then
			targetEntities = surface.find_entities_filtered({force = universe.activePlayerForces, type = {"accumulator", "assembling-machine", "furnace", "lab", "mining-drill", "rocket-silo", "solar-panel"}})
			targetEntitiesCount = #targetEntities 
			if (targetEntitiesCount > 0) then
				local demolisherSource = demolishers[mRandom(1, demolishersCount)]
				local demolisher = surface.create_entity({
					position= demolisherSource.position,
					name = demolisherSource.name,
					direction=demolisherSource.direction,
					force = demolisherSource.force
				})
				if not map.wildDemolishers then
					map.wildDemolishers = {}
				end 
				map.wildDemolishers[demolisher.unit_number] = {entity = demolisher, hunger = 1}
				local targetEntity = targetEntities[mRandom(1, targetEntitiesCount)]			
				universe.demolisherTriggers[demolisher.unit_number] = {
					surface = surface, 
					demolisher = demolisher, 
					target = targetEntity,
					detected = false
					}							
				-- game.print("startDemolisherAttack: [gps=" .. demolisher.position.x .. "," .. demolisher.position.y .. "," .. demolisher.surface.name .."]".. "unit_number="..demolisher.unit_number)	-- debug
			end
		end	
	end

	commands.add_command('startDemolisherAttack', "", startDemolisherAttack)
end	
