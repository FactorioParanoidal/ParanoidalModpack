local upgrade = {}

-- imports

local constants = require("libs/Constants")

-- constants

local DEFINES_COMMAND_GROUP = defines.command.group
local DEFINES_COMMAND_WANDER = defines.command.wander
local DEFINES_COMMAND_BUILD_BASE = defines.command.build_base
local DEFINES_COMMAND_ATTACK_AREA = defines.command.attack_area
local DEFINES_COMMAND_GO_TO_LOCATION = defines.command.go_to_location
local DEFINES_COMMMAD_COMPOUND = defines.command.compound
local DEFINES_COMMAND_FLEE = defines.command.flee
local DEFINES_COMMAND_STOP = defines.command.stop

local DEFINES_COMPOUND_COMMAND_RETURN_LAST = defines.compound_command.return_last

local DEFINES_DISTRACTION_NONE = defines.distraction.none
local DEFINES_DISTRACTION_BY_ENEMY = defines.distraction.by_enemy
local DEFINES_DISTRACTION_BY_ANYTHING = defines.distraction.by_anything

local CHUNK_SIZE = constants.CHUNK_SIZE
local TRIPLE_CHUNK_SIZE = constants.TRIPLE_CHUNK_SIZE

-- imported functions

-- module code

local function addCommandSet(queriesAndCommands)
    -- preallocating memory to be used in code, making it fast by reducing garbage generated.
    queriesAndCommands.neighbors = {
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1,
            -1
    }
    queriesAndCommands.cardinalNeighbors = {
            -1,
            -1,
            -1,
            -1
    }
    queriesAndCommands.position = {
        x=0,
        y=0
    }
    queriesAndCommands.position2 = {
        x=0,
        y=0
    }
    queriesAndCommands.position3 = {
        x=0,
        y=0
    }

    queriesAndCommands.chunkOverlapArray = {
            -1,
            -1,
            -1,
            -1
    }

    queriesAndCommands.position2Top = {0, 0}
    queriesAndCommands.position2Bottom = {0, 0}
    --this is shared between two different queries
    queriesAndCommands.area = {
        {0, 0},
        {0, 0}
    }
    queriesAndCommands.area2 = {
        queriesAndCommands.position2Top,
        queriesAndCommands.position2Bottom
    }
    queriesAndCommands.buildPositionTop = {0, 0}
    queriesAndCommands.buildPositionBottom = {0, 0}
    queriesAndCommands.buildArea = {
        queriesAndCommands.buildPositionTop,
        queriesAndCommands.buildPositionBottom
    }
    queriesAndCommands.countResourcesQuery = {
        area=queriesAndCommands.area,
        type="resource"
    }
	
    queriesAndCommands.hasPlayerStructuresQuery = {
        area=queriesAndCommands.area,
		force=queriesAndCommands.activePlayerForces,
        limit=1
    }
-- autofill from constants
	local GENERATOR_PHEROMONE_LEVEL = constants.GENERATOR_PHEROMONE_LEVEL
	local BUILDING_PHEROMONES = constants.BUILDING_PHEROMONES
	queriesAndCommands.filteredEntities_player_pheromones = {}
	for lvlName, values in pairs(GENERATOR_PHEROMONE_LEVEL) do
		queriesAndCommands.filteredEntities_player_pheromones[lvlName] = {
				area=queriesAndCommands.area,
				force=queriesAndCommands.activePlayerForces,
				type = {}
			}
		local filtered_types = queriesAndCommands.filteredEntities_player_pheromones[lvlName].type
		---------
		for entityType, entitylvlName in pairs(BUILDING_PHEROMONES) do				
			if entitylvlName == lvlName then
				filtered_types[#filtered_types+1] = entityType
			end	
		end
		if #filtered_types==0 then
			queriesAndCommands.filteredEntities_player_pheromones[lvlName] = nil
		end
	end	
-- - !КДА 

	 -- Factorissimo. Yes, this is a "storage-tank" enities
    queriesAndCommands.filteredEntitiesPlayerQueryFactorissimo = {
        area=queriesAndCommands.area,
        force=queriesAndCommands.activePlayerForces,
        collision_mask = "player-layer",
        type={"storage-tank"}
    }
	
	
    queriesAndCommands.filteredEntitiesUnitQuery = {
        area=queriesAndCommands.area,
        force="enemy",
        type="unit"
    }
    queriesAndCommands.filteredEntitiesEnemyStructureQuery = {
        area=queriesAndCommands.area,
        force="enemy",
        type={
            "turret",
            "unit-spawner"
        }
    }

	
    queriesAndCommands.filteredEntitiesPointQueryLimited = {
        position = queriesAndCommands.position,
        radius = 10,
        limit = 1,
        force = "enemy",
        type = {
            "unit-spawner",
            "turret"
        }
    }
	
	
    queriesAndCommands.createBuildCloudQuery = {
        name = "build-clear-cloud-rampant",
        position = queriesAndCommands.position
    }

    queriesAndCommands.activePlayerForces = {"player"}
    queriesAndCommands.nonPlayerForces = {"neutral", "enemy"}

    for _,force in pairs(game.forces) do
        local add = true

        if (force.name ~= "neutral") and (force.name ~= "enemy") then
            for i=1,#queriesAndCommands.activePlayerForces do
                if (queriesAndCommands.activePlayerForces[i] == force.name) then
                    add = false
                    break
                end
            end

            if add then
                queriesAndCommands.activePlayerForces[#queriesAndCommands.activePlayerForces+1] = force.name
			else
                queriesAndCommands.nonPlayerForces[#queriesAndCommands.nonPlayerForces+1] = force.name			
            end
        end
    end

    queriesAndCommands.filteredEntitiesChunkNeutral = {
        area=queriesAndCommands.area,
        collision_mask = "player-layer",
        type={
            "tree",
            "simple-entity"
        }
    }

    local sharedArea = {
        {0,0},
        {0,0}
    }
    queriesAndCommands.filteredEntitiesCliffQuery = {
        area=sharedArea,
        type="cliff",
        limit = 1
    }
    queriesAndCommands.filteredTilesPathQuery = {
        area=sharedArea,
        collision_mask="water-tile",
        limit = 1
    }
    queriesAndCommands.cliffQuery = {
        area=queriesAndCommands.area2,
        type="cliff"
    }
    queriesAndCommands.canPlaceQuery = {
        name="",
        position={0,0}
    }
    queriesAndCommands.filteredTilesQuery = {
        collision_mask="water-tile",
        area=queriesAndCommands.area
    }

    queriesAndCommands.upgradeEntityQuery = {
        name = "",
        position = nil
    }

    queriesAndCommands.attackCommand = {
        type = DEFINES_COMMAND_ATTACK_AREA,
        destination = queriesAndCommands.position,
        radius = CHUNK_SIZE * 1.5,
        distraction = DEFINES_DISTRACTION_BY_ANYTHING
    }

    queriesAndCommands.moveCommand = {
        type = DEFINES_COMMAND_GO_TO_LOCATION,
        destination = queriesAndCommands.position,
        pathfind_flags = { cache = true },
        distraction = DEFINES_DISTRACTION_BY_ENEMY
    }

    queriesAndCommands.settleCommand = {
        type = DEFINES_COMMAND_BUILD_BASE,
        destination = queriesAndCommands.position,
        distraction = DEFINES_DISTRACTION_BY_ENEMY,
        ignore_planner = true
    }

    queriesAndCommands.wonderCommand = {
        type = DEFINES_COMMAND_WANDER,
        wander_in_group = false,
        radius = TRIPLE_CHUNK_SIZE*2,
        ticks_to_wait = 36000
    }

    queriesAndCommands.stopCommand = {
        type = DEFINES_COMMAND_STOP
    }

    queriesAndCommands.compoundSettleCommand = {
        type = DEFINES_COMMMAD_COMPOUND,
        structure_type = DEFINES_COMPOUND_COMMAND_RETURN_LAST,
        commands = {
            queriesAndCommands.wonder2Command,
            queriesAndCommands.settleCommand
        }
    }

    queriesAndCommands.retreatCommand = {
        type = DEFINES_COMMAND_GROUP,
        group = nil,
        distraction = DEFINES_DISTRACTION_BY_ANYTHING,
        use_group_distraction = true
    }

    queriesAndCommands.fleeCommand = {
        type = DEFINES_COMMAND_FLEE,
        from = nil,
        distraction = DEFINES_DISTRACTION_NONE
    }

    queriesAndCommands.compoundRetreatGroupCommand = {
        type = DEFINES_COMMMAD_COMPOUND,
        structure_type = DEFINES_COMPOUND_COMMAND_RETURN_LAST,
        commands = {
            queriesAndCommands.stopCommand,
            queriesAndCommands.fleeCommand,
            queriesAndCommands.retreatCommand
        }
    }

    queriesAndCommands.formGroupCommand = {
        type = DEFINES_COMMAND_GROUP,
        group = nil,
        distraction = DEFINES_DISTRACTION_BY_ANYTHING,
        use_group_distraction = false
    }

    queriesAndCommands.formCommand = {
        command = queriesAndCommands.formGroupCommand,
        unit_count = 0,
        unit_search_distance = TRIPLE_CHUNK_SIZE
    }

    queriesAndCommands.formRetreatCommand = {
        command = queriesAndCommands.compoundRetreatGroupCommand,
        unit_count = 1,
        unit_search_distance = CHUNK_SIZE
    }
end

function upgrade.rebuildActivePlayerForces(universe)
	universe.activePlayerForces = {}
	universe.nonPlayerForces = {}
	local forceIgnored
	for _,force in pairs(game.forces) do
		forceIgnored = false
		if (force.name == "neutral") or (force.name == "enemy") then
			forceIgnored = true
		elseif game.forces["enemy"].is_friend(force) then
			forceIgnored = true
		end	
		if game.forces["enemy"].get_cease_fire(force) then
			forceIgnored = true
		end	
		if forceIgnored then
			universe.nonPlayerForces[#universe.nonPlayerForces+1] = force.name			
		else
			universe.activePlayerForces[#universe.activePlayerForces+1] = force.name	
		end	
	end
	addCommandSet(universe)
end

function upgrade.attempt(universe)
    local starting = global.version
    if not global.version or global.version < 114 then
        global.version = 114

        if not universe then
            universe = {}
            global.universe = universe
        end
        game.forces.enemy.kill_all_units()

        universe.safeEntities = {}

        universe.aiPointsScaler = settings.global["rampantFixed--aiPointsScaler"].value

        universe.aiPointsPrintGainsToChat = settings.global["rampantFixed--aiPointsPrintGainsToChat"].value
        universe.aiPointsPrintSpendingToChat = settings.global["rampantFixed--aiPointsPrintSpendingToChat"].value

        universe.aiNocturnalMode = settings.global["rampantFixed--permanentNocturnal"].value

        universe.mapIterator = nil
        universe.retreatThreshold = 0
        universe.rallyThreshold = 0
        universe.formSquadThreshold = 0
        universe.attackWaveSize = 0
        universe.attackWaveDeviation = 0
        universe.attackWaveUpperBound = 0
        universe.unitRefundAmount = 0
        universe.regroupIndex = 1

        game.map_settings.path_finder.min_steps_to_check_path_find_termination =
            constants.PATH_FINDER_MIN_STEPS_TO_CHECK_PATH

        universe.evolutionTableAlignment = {}

        universe.kamikazeThreshold = 0
        universe.attackWaveLowerBound = 1

        universe.expansion = game.map_settings.enemy_expansion.enabled
        universe.expansionMaxDistance = game.map_settings.enemy_expansion.max_expansion_distance * CHUNK_SIZE
        universe.expansionMaxDistanceDerivation = universe.expansionMaxDistance * 0.33
        universe.expansionMinTime = game.map_settings.enemy_expansion.min_expansion_cooldown
        universe.expansionMaxTime = game.map_settings.enemy_expansion.max_expansion_cooldown
        universe.expansionMinSize = game.map_settings.enemy_expansion.settler_group_min_size
        universe.expansionMaxSize = game.map_settings.enemy_expansion.settler_group_max_size

        universe.settlerWaveDeviation = 0
        universe.settlerWaveSize = 0

        universe.enabledMigration = universe.expansion and settings.global["rampantFixed--enableMigration"].value
        universe.peacefulAIToggle = settings.global["rampantFixed--peacefulAIToggle"].value
        universe.printAIStateChanges = settings.global["rampantFixed--printAIStateChanges"].value
        universe.debugTemperament = settings.global["rampantFixed--debugTemperament"].value

        universe.enemyAlignmentLookup = {}

        game.map_settings.unit_group.min_group_radius = constants.UNIT_GROUP_MAX_RADIUS * 0.5
        game.map_settings.unit_group.max_group_radius = constants.UNIT_GROUP_MAX_RADIUS

        game.map_settings.unit_group.max_member_speedup_when_behind = constants.UNIT_GROUP_MAX_SPEED_UP
        game.map_settings.unit_group.max_member_slowdown_when_ahead = constants.UNIT_GROUP_MAX_SLOWDOWN
        game.map_settings.unit_group.max_group_slowdown_factor = constants.UNIT_GROUP_SLOWDOWN_FACTOR

        game.map_settings.max_failed_behavior_count = 3
        game.map_settings.unit_group.member_disown_distance = 10
        game.map_settings.unit_group.tick_tolerance_when_member_arrives = 60
        game.forces.enemy.ai_controllable = true

        universe.evolutionLevel = game.forces.enemy.evolution_factor
        global.pendingChunks = nil
        global.natives = nil
        global.map = nil

        universe.builderCount = 0
        universe.squadCount = 0

        addCommandSet(universe)
    end
    if global.version < 116 then
        global.version = 116

        universe.maxPoints = 0

        -- if (universe.maps) then
        --     for _,map in pairs(universe.maps) do
        --         for _,base in pairs(map.bases) do
        --             base.damagedBy = {}
        --             base.deathEvents = 0
        --         end
        --     end
        -- end

        --game.print("Rampant - Version 1.1.0, Rampant")
    end
	if global.version < 118 then
		local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
        global.version = 118
	    addCommandSet(universe)
		universe.retribution = 0
		if universe.maps then
			for _, map in pairs(universe.maps) do
--		local map = universe.maps[1]
		
			------- add new map fields
			-- map
				if not map.chunkToPlayerBaseDetection then
					map.chunkToPlayerBaseDetection = {}	
				end	
				if not map.chunkFactions then
					map.chunkFactions = {}	
				end	
				if not map.chunkFactionCounts then
					map.chunkFactionCounts = {}	
				end	
				if not map.chunkFactionCounts then
					map.squadsGenerated = 0
				end	
				-- chunk[BASE_DETECTION_PHEROMONE]
				local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
				local chunksProcessed = 0
				for x, nestsY in pairs(map) do
					if (type(x) == "number") and (math.floor(x)==x) then
						for y, chunk in pairs(nestsY) do
							if not chunk[BASE_DETECTION_PHEROMONE] then
								chunk[BASE_DETECTION_PHEROMONE] = 0
								chunksProcessed = chunksProcessed + 1
							end	
						end
					end
				end
				if chunksProcessed>0 then
					game.print("update, "..chunksProcessed.." chunks processed")
				end
				
				-- bases
				local bases = map.chunkToBase
				local basesProcessed = 0
				for chunk, base in pairs(bases) do
					if base and base.id and not base.chunkFactions then
						base.chunkFactions = {}
						if universe.evolutionLevel<0.15 then
							base.tier = 1
						elseif 	universe.evolutionLevel<0.30 then
							base.tier = 2
						elseif 	universe.evolutionLevel<0.50 then
							base.tier = 3
						elseif 	universe.evolutionLevel<0.75 then
							base.tier = 5
						elseif 	universe.evolutionLevel<0.90 then
							base.tier = 8
						else
							base.tier = 10
						end	
						base.tierHandicap = 0
						newAlignment = {}
						if not base.alignment[2] then					
							newAlignment[base.alignment[1]] = 1
						else
							newAlignment[base.alignment[1]] = 0.8
							newAlignment[base.alignment[2]] = 0.2
						end
						base.alignment = newAlignment
						basesProcessed = basesProcessed + 1
					end	
				end
				if basesProcessed>0 then
					game.print("update, "..basesProcessed.." bases processed")
				end
			end	
			--game.print("Rampant fixed, Version 1.0.8")
		end	
		
	end	
	if global.version < 119 then
        global.version = 119
		universe.retribution = 0	
	end
	
	if global.version < 120 then
        global.version = 120
		if universe.maps then
			local builderCount = 0
			local squadCount = 0
			for _, map in pairs(universe.maps) do
				local squads = map.groupNumberToSquad
				for groupNumber, squad in pairs(squads) do
					--game.print(serpent.dump(groupNumber))
					if squad.settlers then
						builderCount = builderCount + 1
					else 
						squadCount = squadCount + 1
					end	
				end
			end	
			universe.builderCount = builderCount
			universe.squadCount = squadCount
		end
		--game.print("Rampant fixed, Version 1.0.13. Recaclulate active squads")
	end
	
	if global.version < 121 then
        global.version = 121
	    addCommandSet(universe)
		if universe.maps then
			local mapsCounter = 0
			local mapsToDelete = {}
			local lastMap
			local deleteMap = false
			local squadsCleared = 0
			for surfaceIndex, map in pairs(universe.maps) do
				local surface = map.surface
				deleteMap = constants.SURFACE_IGNORED(surface, universe)
				if deleteMap then
					mapsToDelete[#mapsToDelete+1] = surfaceIndex
				end
			end
			for i = 1,#mapsToDelete do
				local surfaceIndex = mapsToDelete[i]
				local map = universe.maps[surfaceIndex]	
				--- squads check
				local squads = map.groupNumberToSquad			-- im sure, no nests, bases, squads in factory floor! But just in case, we'll check the squads..
				local builderCount = 0
				local squadCount = 0
				for groupNumber, squad in pairs(squads) do
					if squad.settlers then
						builderCount = builderCount + 1
					else 
						squadCount = squadCount + 1
					end	
                    if squad.group and squad.group.valid then
                        squad.group.destroy()
                    end
					universe.builderCount = universe.builderCount - builderCount
					universe.squadCount = universe.squadCount - squadCount
					squadsCleared = squadsCleared + 1					
				end	
				-----
				if universe.mapIterator == surfaceIndex then
					universe.mapIterator = nil
				end	
				universe.maps[surfaceIndex] = nil
				
				mapsCounter = mapsCounter + 1				
			end
			
			if mapsCounter>0 then
				game.print("Rampant fixed, Version 1.0.14. Factorissimo surfaces are excluded:"..mapsCounter..", squads removed: "..squadsCleared)
			end
		end
		
 	end
	
	if global.version < 122 then
		--game.print("Rampant fixed, Version 1.0.18")
		global.version = 122
		
        universe.processActiveNest = {}
        universe.processActiveNestIterator = nil
		
		universe.pendingMutations = {
		["chunks"] = {},			-- {x, y, surface.index}
		["entities"] = {}
		}
	end
	if global.version < 124 then	-- Version 1.1
		global.version = 124
		universe.surfaceIgnoringSet = {}
		universe.surfaceRemoteSettings = {}
		universe.chunkToPassScan = {}
		universe.pendingChunks = {}
		
		if universe.maps then
			local mapsCounter = 0
			local mapsToDelete = {}
			local lastMap
			local deleteMap = false
			local squadsCleared = 0
			for surfaceIndex, map in pairs(universe.maps) do
				local surface = map.surface
				deleteMap = constants.SURFACE_IGNORED(surface, universe)
				if deleteMap then
					mapsToDelete[#mapsToDelete+1] = surfaceIndex
				end
			end
			for i = 1,#mapsToDelete do
				local surfaceIndex = mapsToDelete[i]
				local map = universe.maps[surfaceIndex]	
				--- squads check
				local squads = map.groupNumberToSquad			
				local builderCount = 0
				local squadCount = 0
				for groupNumber, squad in pairs(squads) do
					if squad.settlers then
						builderCount = builderCount + 1
					else 
						squadCount = squadCount + 1
					end	
                    if squad.group and squad.group.valid then
                        squad.group.destroy()
                    end
					universe.builderCount = universe.builderCount - builderCount
					universe.squadCount = universe.squadCount - squadCount
					squadsCleared = squadsCleared + 1					
				end	
				-----
				if universe.mapIterator == surfaceIndex then
					universe.mapIterator = nil
				end	
				universe.maps[surfaceIndex] = nil
				
				mapsCounter = mapsCounter + 1				
			end
			
			if mapsCounter>0 then
				game.print("Rampant fixed, Version 1.1.0 Surfaces excluded:"..mapsCounter..", squads removed: "..squadsCleared)
			end
			
			for surfaceIndex, map in pairs(universe.maps) do
				for event,_ in pairs(map.pendingChunks) do
					universe.pendingChunks[event] = true
				end	
				map.pendingChunks = nil
				
				for chunk,_ in pairs(map.chunkToPassScan) do
					local chunkIndex = {chunk.x, chunk.y, map.surface.index}
					universe.chunkToPassScan[chunkIndex] = true
				end	
				
			end
		end
	end
	
	if global.version < 126 then	-- Version 1.1.1
		global.version = 126	
		if universe.maps then
			for surfaceIndex, map in pairs(universe.maps) do
				map.vengenceLimiter = 0
			end
		end
	end
	if global.version < 127 then	-- Version 1.1.6
		global.version = 127	
		universe.aiDifficulty = settings.global["rampantFixed--aiDifficulty"].value
		universe.finalSquadCost = 1		
		universe.finalVengenceSquadCost = 1		
	end
	
	if global.version < 128 then	-- Version 1.1.9
		global.version = 128
		if universe.maps then
			for surfaceIndex, map in pairs(universe.maps) do
				for i, base in pairs(map.bases) do
					base.thisIsRampantEnemy = true
				end
			end	
		end
		game.print({"description.rampantFixed--EnemySettings1_1_9"})	
	end
	
	if global.version < 129 then	-- Version 1.1.10
		global.version = 129
		if universe.NEW_ENEMIES then
			game.print({"description.rampantFixed--EnemySettings1_1_10"})	
		end
	end	

	if global.version < 131 then	-- Version 1.1.11
		global.version = 131
		if universe.maps then
			for surfaceIndex, map in pairs(universe.maps) do
				map.chunkToPlayerTurrets = {}
			end
		end
	end	
	
	if global.version < 135 then	-- Version 1.2.0
		global.version = 135
		universe.attackWaveMaxSizeEvoPercent = settings.global["rampantFixed--attackWaveMaxSizeEvoPercent"].value
		universe.chunkToPlayerCount = {}
		universe.processActiveNestIterator = nil
		universe.processActiveNest = {}
		universe.decomressQueue = {}
		if universe.maps then
			for surfaceIndex, map in pairs(universe.maps) do
				map.chunkToPlayerCount = nil
				map.playerToChunk = nil
				for chunk, value in pairs (map.chunkToDeathGenerator) do
					if (value > - 1) and (value < 1) then
						map.chunkToDeathGenerator[chunk] = nil
					end
				end
			end
		end
	end	

	if global.version < 136 then	-- Version 1.2.3
		global.version = 136
		upgrade.rebuildActivePlayerForces(universe)
		universe.groupNumberToSquad = {}
		
		if universe.maps then
			for surfaceIndex, map in pairs(universe.maps) do
				for groupNumber, squad in pairs(map.groupNumberToSquad) do
					squad.map = map
					if squad.settlers then
						squad.disbandTick = game.tick + 72000
					else
						squad.disbandTick = game.tick + 18000					
					end
					universe.groupNumberToSquad[squad.groupNumber] = squad
				end
				map.groupNumberToSquad = nil
				map.squadIterator = nil
			end
		end		
	end
	
	if global.version < 137 then	-- Version 1.2.5
		global.version = 137
		universe.unitProtectionData = {}
		-- if game.active_mods["space-exploration"] and game.active_mods["combat-mechanics-overhaul"] and game.active_mods["Krastorio2"] then
			 -- if not settings.startup["rampantFixed--useBlockableSteamAttacks"].value then
				-- game.print({"description.rampantFixed--K2_SE_CMO_incompatibilityWarning"})
			 -- end			
		-- end
	end
	
	if global.version < 138  then	-- Version 1.2.8
		local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
		global.version = 138
		if universe.maps and starting and settings.startup["rampantFixed--newEnemies"].value then
			for surfaceIndex, map in pairs(universe.maps) do
				local buildings = map.surface.find_entities_filtered({force = "enemy", type={"turret"}})
				local buildingsTotal = #buildings
				local rndNumber = 0
				if buildingsTotal >= 70000 then
					rndNumber = 0.95
				elseif buildingsTotal >= 35000 then	
					rndNumber = 0.9
				elseif buildingsTotal >= 15000 then	
					rndNumber = 0.6
				end
				if rndNumber > 0 then
					local wormsDeleted = 0
					for i=1,buildingsTotal do
						local building = buildings[i]
						if math.random() < rndNumber then
							building.destroy()
							wormsDeleted = wormsDeleted + 1			
						end	
					end	
					if wormsDeleted > 0 then
						game.print("update 1.2.8: "..map.surface.name..":".. wormsDeleted.." worm(s) removed")
					end
				end	
			end
		end	
		
	end
		
	if global.version < 139  then	-- Version 1.2.11
		global.version = 139
		universe.unitProtectionData.unitCurrentHP = {}
	end
	
	if global.version < 142  then	-- Version 1.3
		global.version = 142
		universe.nonRampantCompressedSquads = {}
		universe.bases = {}
		universe.baseId = 1
		universe.recycleBaseIterator = nil
		universe.raiding_minimum_base_threshold = constants.RAIDING_MINIMUM_BASE_THRESHOLD
		universe.no_pollution_attack_threshold = constants.NO_POLLUTION_ATTACK_THRESHOLD		
		universe.AI_MAX_SQUAD_COUNT = settings.global["rampantFixed--maxNumberOfSquads"].value
		if universe.maps then
			-- local chunkToBaseCleared = 0
			local newId = 1
			local basesList = {}
			for _, map in pairs(universe.maps) do
				local bases = map.chunkToBase
				local basesProcessed = 0
				
				local evoTier = 1
				for tier = 10,1,-1 do
					if universe.evoToTierMapping[tier] <= map.evolutionLevel then
						evoTier = tier
						break
					end
				end
									
				for chunk, base in pairs(bases) do
					if base and base.id then
--						local distance = ((base.x - chunk.x)^2 + (base.y - chunk.y)^2) ^ 0.5
						if not basesList[base] then
							basesList[base] = base.id
							base.id = newId
							base.mapIndex = map.surface.index
							base.chunks = {}
							base.state = BASE_AI_STATE_ACTIVE
							if universe.NEW_ENEMIES and (not universe.ALLOW_OTHER_ENEMIES) then
								if not base.thisIsRampantEnemy then
									base.tier = math.max(evoTier - base.tierHandicap, 1)

									base.thisIsRampantEnemy = true
								end	
							end
							newId = newId + 1
							universe.bases[base.id] = base
						end		
						--if distance <= 150 then
							base.chunks[chunk] = true
						-- else
							-- chunkToBaseCleared = chunkToBaseCleared + 1
							-- bases[chunk] = nil
						-- end	
					end
				end
				map.bases = nil
				map.baseIndex = nil
				map.baseIncrement = nil
				map.baseId = nil
				map.recycleBaseIterator = nil
				map.chunkFactions = nil
			end	
			-- if chunkToBaseCleared > 0 then
				-- game.print("chunkToBase links deleted:"..chunkToBaseCleared)
			-- end
			
			universe.baseId = newId			
		end		
        addCommandSet(universe)
	end
	
	if global.version < 143  then	-- Version 1.4.0
		global.version = 143
		universe.oneTickImmunityUnits = {}
		universe.compressedUnits = {}
		local compressedUnits = universe.compressedUnits
		for groupNumber, squad in pairs(universe.groupNumberToSquad) do
			local group = squad.group
			if group and squad.compressedMembers then
				if squad.smoothCompressed then
					local unitNumber
					for _, entity in pairs(group.members) do
						unitNumber = entity.unit_number
						local compressData = squad.compressedMembers[unitNumber]
						if compressData then
							compressedUnits[unitNumber] = {count = compressData.count, textId = compressData.textId, entity = entity}
						end	
					end
					
				else
					for _, entity in pairs(group.members) do
						unitNumber = entity.unit_number
						entityName = entity.name
						local compressData = squad.compressedMembers[entityName]
						if compressData then
							compressedUnits[unitNumber] = {count = compressData.count, textId = compressData.textId, entity = entity}
							squad.compressedMembers[entityName] = nil
						end	
					end
				
				end
				squad.compressedMembers = nil
				squad.compressed = true
			end	
		end	
	end
	
	if global.version < 144  then	-- Version 1.4.2
		global.version = 144
		universe.protectedUnits = {}
	end	
	
	if global.version < 150  then	-- Version 1.5
		global.version = 150
		universe.undergroundSquads = {}
		universe.undergroundAttackProbability = 0
	end	
	
	if global.version < 152  then	-- Version 1.5.2
		global.version = 152
		universe.undergroundAttack =  settings.global["rampantFixed--undergroundAttack"].value
	end	
	
	if global.version < 161  then	-- Version 1.6.1
		global.version = 161
		for chunkIndex,_ in pairs(universe.chunkToPassScan) do
			if chunkIndex and (type(attribute) == "table") then
				local chunkIndexNew = "x"..chunkIndex[1].."y"..chunkIndex[2].."m"..chunkIndex[3]
				local chunkData = {}
				for i = 1, 3 do
					chunkData[i] = chunkIndex[i]
				end	
				universe.chunkToPassScan[chunkIndexNew] = chunkData
				universe.chunkToPassScan[chunkIndex] = nil
				
			end	
		end	
		
		universe.pendingMutations = {
		["chunks"] = {},			-- {"x"..x.."y"..y.."m"..surface.index}
		["entities"] = {}
		}
		universe.pendingMutationsIterator = nil	
		
		universe.externalControlValues = {}
	end	
	
	if global.version < 164  then	-- Version 1.6.4
		global.version = 164
		universe.evolveTick = 0
		universe.lvlupTick = 0
	end	

	if global.version < 170  then	-- Version 1.7.0
		global.version = 170
	end	
	
	if global.version < 172  then	-- Version 1.7.2
		global.version = 172
	    universe.randomGenerator = nil
	end	

	if global.version < 180  then	-- Version 1.8.0
		global.version = 180
	    universe.growingBases = {}
		if universe.maps then
			for _, map in pairs(universe.maps) do
				map.basesToGrow = {}
			end
		end	
	end	

	if global.version < 183  then	-- Version 1.8.3
		global.version = 183
	    universe.debugSettings = {}
		universe.allowExternalControl = true
	end	
	
	return (starting ~= global.version) and global.version
end

function upgrade.compareTable(entities, option, new)
    local changed = false
    if (entities[option] ~= new) then
        entities[option] = new
        changed = true
    end
    return changed, new
end

return upgrade
