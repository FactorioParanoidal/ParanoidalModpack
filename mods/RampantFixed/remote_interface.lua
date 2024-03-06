-- Suggestions for additional functionality are welcome
-- look in RampantFixedRemote\remote_interface_example.lua for some tips

-- now you can: 
--	get/set maximum wave size: wave sizes are proportional to this value
--	get/set wave size: specifies the size of the waves directly and disables its recalculation
--  get array of LuaUnitGroup for rampant squads (only attack squads)
-- 	order to create an attack squad of a specified size or a default size. 
--  get array of all enemy bases stats, or get enemy base stats for specified position / specified Id
-- 	directly set enemy base factions
-- 	get/set AI points and AI state for specified surface
--	get pheromones for specified chunk
--  set enemy base to grow

-- setting parameters requires permission. Don't forget to check it out
-- all functions *_ExtCtrl do nothing and return nil, if startup setting "rampantFixed--allowExternalControl" (Remote interface: allow external control AI) disabled -- upd. 1.8.3+ "allowExternalControl" always true
-- it is recommended to issue a message to the user to enable setting

local aiPlanning = require("libs/AIPlanning")
local baseUtils = require("libs/BaseUtils")
local chunkPropertyUtils = require("libs/ChunkPropertyUtils")
local constants = require("Constants")
local mapProcessor = require("libs/MapProcessor")
local mapUtils = require("libs/MapUtils")
local config = require("__RampantFixed__/config")

local function getBaseStats(base)
	if not base then
		return nil
	end	
	local baseStats = {
	id = base.id,										-- number
	mapIndex = base.mapIndex,							-- its same as surface.index
	x = base.x,											-- 1st chunk, where base has been created. x, y coordinates
	y = base.y,
	thisIsRampantEnemy = base.thisIsRampantEnemy,		-- boolean. Only if true, base will mutate
	tierHandicap = base.tierHandicap,					-- 0..2. Lesser than base.tier. Actual tier = base.tier - base.tierHandicap. 
	tier = base.tier,									-- number 1..10
	factions = {},										-- {factionName1 = number, ..., factionNameN = number }. Sum of numbers must be equal 1
	chunks = {}											-- list of base chunks coordinates (upper left corner) {{x = number, y = number}, ... ...,{x = number, y = number}}
	}
	local alignment
	if base.newAlignmentAndSteps then
		alignment = base.newAlignmentAndSteps[2]
	else
		alignment = base.alignment
	end
	
	for faction, rate in pairs(alignment) do
		baseStats.factions[faction] = rate
	end
		
	for chunk, _ in pairs(base.chunks) do
		if chunk and (type(chunk) == "table") then
			baseStats.chunks[#baseStats.chunks + 1] = {x = chunk.x, y = chunk.y}
		end
	end
	return baseStats
end

local function getFactionsList()
	local factions = {}
	for i=1,#constants.FACTION_SET do
		local faction = constants.FACTION_SET[i]
		factions[faction.type] = {tierMin = faction.acceptRate[1], tierMax = faction.acceptRate[2]}
	end	
	return factions
end

local validAI_StateList = {}
validAI_StateList[constants.AI_STATE_PEACEFUL] = constants.stateEnglish[constants.AI_STATE_PEACEFUL]			-- [1]
validAI_StateList[constants.AI_STATE_AGGRESSIVE] = constants.stateEnglish[constants.AI_STATE_AGGRESSIVE]		-- [2]
validAI_StateList[constants.AI_STATE_RAIDING] = constants.stateEnglish[constants.AI_STATE_RAIDING]				-- [4]	-- its not typo. state 3 isn't exist
validAI_StateList[constants.AI_STATE_MIGRATING] = constants.stateEnglish[constants.AI_STATE_MIGRATING]			-- [5]
validAI_StateList[constants.AI_STATE_SIEGE] = constants.stateEnglish[constants.AI_STATE_SIEGE]					-- [6]
validAI_StateList[constants.AI_STATE_ONSLAUGHT] = constants.stateEnglish[constants.AI_STATE_ONSLAUGHT]			-- [7]
validAI_StateList[constants.AI_STATE_GROWING] = constants.stateEnglish[constants.AI_STATE_GROWING]				-- [8]


remote.add_interface("rampantFixed", {
	--------------------
	-- return true if external control is enabled
	-- note: all functions *_ExtCtrl do nothing and return nil, if allowExternalControl = false
	-- note: since the "rampantFixed--allowExternalControl" is a startup setting, it is enough to check it once (on every load)
	allowExternalControl = function()
		return global.universe.allowExternalControl
	end
	,
	--------------------
	-- set maximum wave size. Canceled if no value is passed, or a value outside the allowed range.
	-- parameters: {attackWaveMaxSize = number}
	-- return: number 
	setWaveMaxSize_ExtCtrl = function(parameters)
		if not global.universe.allowExternalControl then
			return nil
		end
		if parameters and parameters.attackWaveMaxSize and (type(parameters.attackWaveMaxSize) == "number") and (parameters.attackWaveMaxSize > 0) and (parameters.attackWaveMaxSize <= 1000) then
			global.universe.externalControlValues.attackWaveMaxSize = parameters.attackWaveMaxSize
		else
			global.universe.externalControlValues.attackWaveMaxSize = nil		
		end
		aiPlanning.planningUniverse(global.universe, game.forces.enemy.evolution_factor, game.tick)
		return config.getAttackWaveMaxSize(global.universe)
	end
	,
	--------------------
	-- return: number of maximum wave size
	-- note: Based on maximum wave size, the wave size is calculated
	getWaveMaxSize = function()
		return config.getAttackWaveMaxSize(global.universe)
	end
	,
	--------------------
	-- set and freeze wave size. Canceled if no value is passed, or a value outside the allowed range
	-- parameters: {attackWaveSize = number}
	-- return: number
	-- note: its average wave size, including all modifiers.  When forming attacking squads, this value is taken 
	-- note: starting from 50% of the maximum size, the cost of the squad increases
	setWaveSize_ExtCtrl = function(parameters)
		if not global.universe.allowExternalControl then
			return nil
		end
		if parameters and parameters.attackWaveSize and (type(parameters.attackWaveSize) == "number") and (parameters.attackWaveSize > 0) and (parameters.attackWaveSize <= 1000) then
			global.universe.externalControlValues.attackWaveSize = parameters.attackWaveSize
		else
			global.universe.externalControlValues.attackWaveSize = nil
		end
		aiPlanning.planningUniverse(global.universe, game.forces.enemy.evolution_factor, game.tick)
		return config.getAttackWaveSize(global.universe)
	end
	,
	--------------------
	-- return: number 
	-- note: its average wave size, including all modifiers.  When forming attacking squads, this value is taken 
	getWaveSize = function()
		return config.getAttackWaveSize(global.universe)
	end
	,
	--------------------
	-- return: array of luaUnitGroup. All surfaces. Only Rampant squads. Settlers and underground attacks are not in this list
	getRampantAttackGroups = function() 
		local groups = {}
		for groupNumber, squad in pairs(global.universe.groupNumberToSquad) do
			if squad.map and squad.group.valid then
				groups[#groups+1] = squad.group
			end
		end
		return groups
	end
	,
	--------------------
	-- Creates an attack squad based on the current AI mode. Won't spawn a squad if peaceful mode, no suitable nests, or no biters near nests or no player base
	-- It is not recommended to call many times per tick: the procedure for gathering a squad is resource-intensive.
	-- A newly created squad must first gather at a rally point before it is ready to attack.
	-- If the AI does not have enough action points, then squad will be free
	--
	-- parameters: {surfaceIndex = number, ignoreSquadLimit = bool, size = nil or numeric}
	-- 		ignoreSquadLimit - allow to create more squads then "rampantFixed--maxNumberOfSquads"
	-- 		size (optional)- number of squad members. If not specified, the default squad size is used. If there are no so many biters, then the actual size will be smaller
	--
	-- return: LuaUnitGroup or nil, if cant create squad
	createSquad_ExtCtrl = function(parameters) 
		if not global.universe.allowExternalControl then
			return nil
		end
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then 
			return nil
		end
		local remoteInterfaceParameters
		if parameters.size and (type(parameters.size) == "number") then
			remoteInterfaceParameters = {ignoreSquadLimit = parameters.ignoreSquadLimit, size = parameters.size}
		else
			remoteInterfaceParameters = {ignoreSquadLimit = parameters.ignoreSquadLimit}
		end
		
		for i = 1, 10 do
			remoteInterfaceParameters.i = i
			mapProcessor.processSpawners(map, game.tick, remoteInterfaceParameters)
			if remoteInterfaceParameters.squad then
				return remoteInterfaceParameters.squad.group
			end
		end	
		return nil
	end
	,
	--------------------
	-- parameters: {surfaceIndex = number, position = {x = number , y = number}}
	--
	-- return: table of base stats or nil, if no base
	-- see the list of props in the "local function getBaseStats "
	getBaseByPosition = function(parameters) 
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then 
			return nil
		end
		if not parameters.position then
			return nil
		end
		
		local chunk = mapUtils.getChunkByPosition(map, parameters.position)
		if (chunk == -1) then
			return nil
		end
		local base = chunkPropertyUtils.getChunkBase(map, chunk)
		if not base then
			return nil
		end
		return getBaseStats(base)
	end
	,
	--------------------
	-- parameters: {id = number} 
	-- return: table of base stats or nil, if no base
	getBaseById = function(parameters) 
		if parameters and parameters.id then
			return getBaseStats(global.universe.bases[parameters.id])
		else
			return nil
		end
	end
	,
	--------------------
	-- return array of bases stats (look at getBaseStats)
	getBases = function() 
		local bases = {}
		for i, base in pairs(global.universe.bases) do
			bases[#bases+1] = getBaseStats(base)
		end
		return bases
	end
	,
	--------------------
	-- Returns a factions based on the mod settings (players can disable factions in the launch options)
	-- return: table {
	-- 		factionName1 = {tierMin = Number, tierMax = Number}, 
	--		..., 
	--		factionNameN = ...}
	getFactions = function()
		return getFactionsList()
	end
	,
	--------------------
	-- Returns a factions for specified tier. 
	-- parameters: {tier = Number 1..10}
	-- return: table {
	-- 		factionName1 = {tierMin = Number, tierMax = Number}, 
	--		..., 
	--		factionNameN = ...}
	getFactionsByTier = function(parameters)
		local factions = {}
		if parameters and parameters.tier and (type(parameters.tier) == "number") then
			for i=1,#constants.FACTION_SET do
				local faction = constants.FACTION_SET[i]
				if (faction.acceptRate[1]<=parameters.tier) and faction.acceptRate[2]>=parameters.tier then
					factions[faction.type] = {tierMin = faction.acceptRate[1], tierMax = faction.acceptRate[2]}
				end	
			end
		end	
		return factions
	end
	
	,
	--------------------
	-- Assigns a set of factions to the base. The mutation will happen by itself, after some time
	--
	-- parameters: {id = number, factions = {factionName1 = rate1, factionName2 = rate2}}
	-- sum of rates must be = 1
	-- The number of factions should preferably be equal 2, although 1 or 3+ will also work.
	-- return: 
	--	-1 if no parameters or wrong parameters (wrong base id, missed "factions", etc...)
	--  -2 if sum of rates not equals 1
	-- 	1 if set is successful
	--
	-- note: missed factions will be write as "neutral" faction
	-- note: it can take up to 10 minutes between the installation of new genes and the actual mutation. Depends 
	-- 		  	on the size of the map and how long ago there was a mutation in the chunk. Mutation is not possible more than once every 10 minutes
	--			also, if there is already a mass mutation in the chunk at the time the command is issued, then the delay will increase
	setBaseFactions_ExtCtrl = function(parameters) 
		if not global.universe.allowExternalControl then
			return nil
		end
		if (not parameters) or (not parameters.id) then
			return -1
		end
		local base = global.universe.bases[parameters.id]
		if not base then
			return -1
		end
		if (not parameters) or (not parameters.factions) or (not type(parameters.factions) == "table") then
			return -1
		end
		-- lets check new factions for mistakes
		local factionsList = getFactionsList()
		local sumRates = 0
		local baseFactions = {}
		for faction, rate in pairs(parameters.factions) do
			if (type(faction) == "string") and (type(rate) == "number") then
				sumRates = sumRates + rate
				if factionsList[faction] then
					baseFactions[faction] = (baseFactions[faction] or 0) + rate
				else
					baseFactions["neutral"] = (baseFactions["neutral"] or 0) + rate		
				end
			end	
		end
		
		if (sumRates >= 0.99) and (sumRates <= 1.01) then
			local tick = game.tick
			base.newAlignmentAndSteps = nil
			base.alignment = baseFactions
			changingEntities = true
			base.nextMutationTick = tick + 54000	-- prevent ingame mutations for 15 min
			for chunk, _ in pairs(base.chunks) do
				chunk.nextMutationTick = tick
			end
			return 1
		else
			return -2
		end			
	end
	,
	--------------------
	-- parameters: {surfaceIndex = number} 
	-- return: nil or number of points
	getAI_points  = function(parameters) 
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then 
			return nil
		end
		return map.points
	end
	
	,
	--------------------
	-- set AI point for specified surface.  Return nil, if no surface, or surface is ignored by Rampant, or rampantFixed--allowExternalControl is disabled
	-- set points if parameters.points defined
	-- parameters: {surfaceIndex = number,  points = number} 
	-- return: nil or number of points
	-- note: attack squad cost 175 points (can vary from 90 to 350, depending on various modifiers). But it is worth focusing on the value 175
	setAI_points_ExtCtrl  = function(parameters) 
		if not global.universe.allowExternalControl then
			return nil
		end
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then 
			return nil
		end
		if parameters.points then		
			if parameters.points <= 0 then
				map.points = 0
			elseif parameters.points > 100000 then
				map.points = 100000
			else
				map.points = parameters.points	
			end
		end	
		return map.points
	end
	,
	--------------------
	-- set AI state for specified surface.  Return nil, if no surface, or surface is ignored by Rampant, or rampantFixed--allowExternalControl is disabled
	-- parameters: {surfaceIndex = number,  state = number} 
	-- return: nil or number (new AI state)
	setAI_state_ExtCtrl  = function(parameters) 
		if not global.universe.allowExternalControl then
			return nil
		end
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then
			return nil
		end	
		if (not parameters.state) or (not validAI_StateList[parameters.state]) then
			return nil
		end	

		map.state = parameters.state
		return {state = map.state, stateEnglish = validAI_StateList[map.state]}	
	end
	,
	--------------------
	-- parameters: {surfaceIndex = number} 
	-- return: nil or number
	getAI_state  = function(parameters) 
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then
			return nil
		end	
		return {state = map.state, stateEnglish = validAI_StateList[map.state]}		
	end
	,
	--------------------
	-- return: table {
	-- 	1 = "AI_STATE_PEACEFUL",
	-- 	2 = 
	--	..
	-- 	}
	getValidAI_StateList = function()
		return validAI_StateList
	end
	
	,
	--------------------
	-- Returns a pheromones in specificed chunk
	-- parameters: {surfaceIndex = number, position = {x = number , y = number}}
	-- return: table {BASE_PHEROMONE = number, BASE_DETECTION_PHEROMONE = number, PLAYER_PHEROMONE = number, RESOURCE_PHEROMONE = number} (or nil if surface ignored or	chunk isn't generated or not processed yet)	
	getPheromones = function(parameters) 
		if (not parameters) or (not parameters.surfaceIndex) then
			return nil
		end
		local map = global.universe.maps[parameters.surfaceIndex]
		if not map then
			return nil
		end	
		
		if not parameters.position then
			return nil
		end			
		local chunk = mapUtils.getChunkByPosition(map, parameters.position)
		if (chunk == -1) then
			return nil
		end
		local pheromones = {}
		pheromones["BASE_PHEROMONE"] = chunk[constants.BASE_PHEROMONE] or 0							-- most attacks go the way of increasing this pheromone. Reduced by 10% per chunk. Hugely reduced when passing through a chunk with a lot of defense. A large number of losses also reduces this value
		pheromones["BASE_DETECTION_PHEROMONE"] = chunk[constants.BASE_DETECTION_PHEROMONE] or 0		-- max value 10000. Reduced by 10% per chunk. Military biuldings set BASE_DETECTION_PHEROMONE to 10000. Other buildings are different. If there are few buildings, then there will be less than 10000
		pheromones["PLAYER_PHEROMONE"] = chunk[constants.PLAYER_PHEROMONE] or 0						-- max value 300, if player(s) inside this chunk (and no defence). Reduced by 55% per chunk
		pheromones["RESOURCE_PHEROMONE"] = chunk[constants.RESOURCE_PHEROMONE] or 0					-- normalized resource estimate. Find out empirically. 
		-- note: pheromones are weakened more if the chunk is poorly passable. 
		--			pheromones are not transmitted from an adjacent chunk if the rampant thinks there is no passage
		--			pheromones also spread diagonally
		--			Keep in mind that pheromones do not spread immediately, and the situation on the map changes
		return pheromones
	end	
	-- ,
	-- setBaseToGrow_ExtCtrl = function(parameters) 
		-- local universe = global.universe
		-- if not universe.allowExternalControl then
			-- return nil
		-- end
		-- if (not parameters) or (not parameters.id) then
			-- return -1
		-- end
		-- local base = universe.bases[parameters.id]
		-- if not base then
			-- return -1
		-- end
		
		-- universe.growingBases[base.id] = {tick = 0, nests = 5, worms = 5}
		-- return 1
	-- end
	}
)