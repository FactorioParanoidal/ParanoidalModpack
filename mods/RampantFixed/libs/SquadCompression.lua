if (squadCompressionG) then
    return squadCompressionG
end
local squadCompression = {}

local constants = require("Constants")
local mapUtils = require("MapUtils")
local mathUtils = require("MathUtils")


local PLAYER_PHEROMONE = constants.PLAYER_PHEROMONE
local BASE_PHEROMONE = constants.BASE_PHEROMONE
local BASE_DETECTION_PHEROMONE = constants.BASE_DETECTION_PHEROMONE
local PLAYER_PHEROMONE_GENERATOR_AMOUNT = constants.PLAYER_PHEROMONE_GENERATOR_AMOUNT

local getChunkByXY = mapUtils.getChunkByXY
local getChunkByPosition =  mapUtils.getChunkByPosition
local positionToChunkXY = mapUtils.positionToChunkXY

local euclideanDistancePoints = mathUtils.euclideanDistancePoints

local mCeil = math.ceil
local mMax = math.max
local mMin = math.min
local mFloor = math.floor
local tInsert = table.insert

-- Reforged Paranoidal: gradual decompression. A compressed unit ("pack") keeps its count and releases units
-- over DECOMPRESS_SPREAD_TICKS; all surfaces together release at most DECOMPRESS_UNITS_PER_SECOND units.
local DECOMPRESS_SPREAD_TICKS = 120
local DECOMPRESS_UNITS_PER_SECOND = 200

local compressedColor = {r = 0.3, g = 0.5, b = 0, a = 0.3}
local smthCompressedColor = {r = 0.3, g = 0.5, b = 0, a = 0.3}	--{r = 0.7, g = 0.3, b = 0, a = 0.5}

local function draw_CompressedText(count, surface, entity, color, textId)
	local renderingObject
	if textId then
		renderingObject = rendering.get_object_by_id(textId)	
	end
	if renderingObject then
		renderingObject.text = tostring(count)
	else
		renderingObject = rendering.draw_text{text = tostring(count), 
		surface = surface, 
		target = entity, 
		only_in_alt_mode = false,
		color = (color or compressedColor), 
		scale = 2.5
		}
	end
	return renderingObject.id	 				
end

local function destroy_RenderingText(textId)
	if not textId then
		return
	end	
	local renderingObject
	if textId then
		renderingObject = rendering.get_object_by_id(textId)	
	end
	if renderingObject then
		renderingObject.destroy()
	end
end


function squadCompression.clearComresseData(universe, squad)
	if not squad then
		return
	end	
	local group = squad.group
	if group and group.valid then
		local compresseData
		for _, entity in pairs(group.members) do
			compresseData = universe.compressedUnits[entity.unit_number]
			if compresseData then
				if compresseData.textId then
					destroy_RenderingText(compresseData.textId)
					compresseData.textId = nil
				end
				universe.compressedUnits[entity.unit_number] = nil
			end
		end
	end	
	squad.compressed = nil
	squad.smoothCompressed = nil
end

-- Exactly DECOMPRESS_UNITS_PER_SECOND units over any 60 consecutive ticks (3 or 4 per tick).
local function decompressAllowance(tick)
	return mFloor(DECOMPRESS_UNITS_PER_SECOND * (tick + 1) / 60) - mFloor(DECOMPRESS_UNITS_PER_SECOND * tick / 60)
end

local function getDecompressList(universe)
	local list = universe.decompressSquads
	if not list then
		list = {}
		universe.decompressSquads = list
	end
	return list
end

-- entry.group is nil for a single unit outside of a group; settlers go first so they finish before building
local function newDecompressEntry(universe, group, groupId, priority)
	local entry = {group = group, groupId = groupId, packs = {}, packIndex = 1, extraTotal = 0, released = 0, startTick = game.tick}
	local list = getDecompressList(universe)
	if priority then
		tInsert(list, 1, entry)
	else
		list[#list + 1] = entry
	end
	return entry
end

local function findDecompressEntry(universe, groupId)
	local list = getDecompressList(universe)
	for i = 1, #list do
		local entry = list[i]
		if entry.groupId == groupId then
			return entry
		end
	end
end

local function addPackToEntry(entry, compressedUnit)
	compressedUnit.decompressing = true
	local packs = entry.packs
	packs[#packs + 1] = compressedUnit
	entry.extraTotal = entry.extraTotal + (compressedUnit.count - 1)
end

local function clearEntryMarks(entry)
	local packs = entry.packs
	for i = entry.packIndex, #packs do
		packs[i].decompressing = nil
	end
end

-- Releases up to the entry's due share (at most budget) units; returns released units and whether the entry is finished.
local function processDecompressEntry(universe, entry, tick, budget)
	local group = entry.group
	if group and not group.valid then
		return 0, true	-- packs keep their remaining count
	end
	local quota = budget
	local elapsed = tick - entry.startTick + 1
	if elapsed < DECOMPRESS_SPREAD_TICKS then
		quota = mMin(budget, mCeil(entry.extraTotal * elapsed / DECOMPRESS_SPREAD_TICKS) - entry.released)
	end
	if quota <= 0 then
		return 0, false
	end

	local compressedUnits = universe.compressedUnits
	local oneTickImmunityUnits = universe.oneTickImmunityUnits
	local packs = entry.packs
	local index = entry.packIndex
	local released = 0
	while released < quota do
		local compressedUnit = packs[index]
		if not compressedUnit then
			break
		end
		local entity = compressedUnit.entity
		local unitNumber = entity and entity.valid and entity.unit_number
		-- the record may have been replaced by recompression or dropped when the carrier died as the last unit
		if unitNumber and (compressedUnits[unitNumber] == compressedUnit) and (compressedUnit.count > 1) then
			local surface = entity.surface
			while (released < quota) and (compressedUnit.count > 1) do
				local newEntity = surface.create_entity({
					name = entity.name,
					position = entity.position,
					direction = entity.direction,
					force = entity.force,
					})
				if newEntity and newEntity.valid then
					if group then
						group.add_member(newEntity)
					end
					newEntity.destructible = false
					oneTickImmunityUnits[#oneTickImmunityUnits+1] = {entity = newEntity, tick = tick + 1}
				end
				compressedUnit.count = compressedUnit.count - 1
				released = released + 1
			end
			if compressedUnit.count > 1 then
				compressedUnit.textId = draw_CompressedText(compressedUnit.count, surface, entity, nil, compressedUnit.textId)
			else
				destroy_RenderingText(compressedUnit.textId)
				compressedUnit.textId = nil
				compressedUnits[unitNumber] = nil
				compressedUnit.decompressing = nil
				index = index + 1
			end
		else
			if unitNumber and (compressedUnits[unitNumber] == compressedUnit) then
				compressedUnits[unitNumber] = nil
			end
			compressedUnit.decompressing = nil
			index = index + 1
		end
	end
	entry.packIndex = index
	entry.released = entry.released + released
	return released, (packs[index] == nil)
end

-- Old saves and underground attacks keep using universe.decomressQueue (units without a carrier entity).
local function drainLegacyDecompressQueue(decomressQueue, budget)
	local spawned = 0
	local group, queuedMembers = next(decomressQueue, nil)
	while group and (spawned < budget) do
		local finished = true
		if group.valid then
			local surface = group.surface
			for compressIndex, compressedData in pairs(queuedMembers) do
				local decomressed = 0
				while (decomressed < compressedData.count) and (spawned < budget) do
					local newEntity = surface.create_entity({
						name = compressedData.name,
						quality = compressedData.quality,
						position = compressedData.position,
						direction = compressedData.direction,
						force = compressedData.force,
						})
					if newEntity and newEntity.valid then
						group.add_member(newEntity)
					end
					decomressed = decomressed + 1
					spawned = spawned + 1
				end
				compressedData.count = compressedData.count - decomressed
				if compressedData.count <= 0 then
					queuedMembers[compressIndex] = nil
				else
					finished = false
					break
				end
			end
		end
		if not finished then
			break
		end
		decomressQueue[group] = nil
		group, queuedMembers = next(decomressQueue, nil)
	end
end

-- Takes one unit out of a pack (the caller turns it into something else). Returns false if the entity is not a pack.
function squadCompression.takeUnitFromPack(universe, entity)
	local compressedUnits = universe.compressedUnits
	local unitNumber = entity.unit_number
	local compressedUnit = compressedUnits[unitNumber]
	if not compressedUnit then
		return false
	end
	if compressedUnit.count <= 1 then
		compressedUnits[unitNumber] = nil
		return false
	end
	compressedUnit.count = compressedUnit.count - 1
	if compressedUnit.count > 1 then
		compressedUnit.textId = draw_CompressedText(compressedUnit.count, entity.surface, entity, nil, compressedUnit.textId)
	else
		destroy_RenderingText(compressedUnit.textId)
		compressedUnit.textId = nil
		compressedUnits[unitNumber] = nil
	end
	return true
end

-- Units held in packs above the single carrier entity.
function squadCompression.countPackedUnits(universe, members)
	local compressedUnits = universe.compressedUnits
	local extra = 0
	for _, entity in pairs(members) do
		local compressedUnit = entity.valid and compressedUnits[entity.unit_number]
		if compressedUnit and (compressedUnit.count > 1) then
			extra = extra + compressedUnit.count - 1
		end
	end
	return extra
end

function squadCompression.decompressUnit(universe, surface, entity)
	local compressIndex = entity.unit_number
	local compressedUnit = universe.compressedUnits[compressIndex]
	if not compressedUnit then
		return 0
	end
	if compressedUnit.count > 1 then
		if not compressedUnit.decompressing then
			addPackToEntry(newDecompressEntry(universe, nil, nil, false), compressedUnit)
		end
		return compressedUnit.count
	end
	universe.compressedUnits[compressIndex] = nil
	return 1
end

function squadCompression.squadDecompress(universe, surface, squad, group, cause, forceDecompress)
	if not surface then
		return
	end
	
	if (not squad) then
		if not group then
			return
		end
	elseif not forceDecompress then
		if not squad.compressed then
			return	
		end	
	end	
	
	if not group then
		group = squad.group
	end	
	if group and group.valid then
		-- packs are queued, not spawned here: processDecompressQueue releases them gradually
		local compressedUnits = universe.compressedUnits
		local entry
		for _, entity in pairs(group.members) do
			local compressIndex = entity.unit_number
			local compressedUnit = compressedUnits[compressIndex]
			if compressedUnit then
				if (compressedUnit.count > 1) then
					if not compressedUnit.decompressing then
						if not entry then
							local groupId = group.unique_id
							entry = findDecompressEntry(universe, groupId)
								or newDecompressEntry(universe, group, groupId, squad and squad.settlers)
						end
						addPackToEntry(entry, compressedUnit)
					end
				else
					compressedUnits[compressIndex] = nil
				end
			end	
		end
	end	
	
	if squad then
		squad.compressed = nil
		squad.smoothCompressed = nil
		squad.compressTick = game.tick
		squad.decompressCause = cause
	end	
end

function squadCompression.processDecompressQueue(universe)
	local list = universe.decompressSquads
	local legacyQueue = universe.decomressQueue
	local hasList = list and (list[1] ~= nil)
	local hasLegacy = legacyQueue and (next(legacyQueue) ~= nil)
	if not (hasList or hasLegacy) then
		return
	end
	local tick = game.tick
	local budget = decompressAllowance(tick)
	if hasList then
		local count = #list
		local kept = 0
		for i = 1, count do
			local entry = list[i]
			local finished = false
			if budget > 0 then
				local released
				released, finished = processDecompressEntry(universe, entry, tick, budget)
				budget = budget - released
			end
			if finished then
				clearEntryMarks(entry)
			else
				kept = kept + 1
				list[kept] = entry
			end
		end
		for i = kept + 1, count do
			list[i] = nil
		end
	end
	if hasLegacy and (budget > 0) then
		drainLegacyDecompressQueue(legacyQueue, budget)
	end
end

local function squadCompress(map, squad)
	if not squad then
		return
	end	
	if squad.compressed then
		return
	end	
	
	if squad.compressTick and ((game.tick - squad.compressTick) < 3600) then
		return
	end
		
    local group = squad.group
	if not group then
		return
	end	

    local surface = map.surface
    local position
    local groupPosition = group.position
    local x, y = positionToChunkXY(groupPosition)
	
	if squad.decompressCause and squad.decompressCause.valid then
		local causeRange = mathUtils.euclideanDistancePoints(x, y, squad.decompressCause.position.x, squad.decompressCause.position.y)
		if causeRange < 100 then
			return
		end
	end
	
	squad.decompressCause = nil
	squad.compressTick = game.tick
		
	local compressedUnits = map.universe.compressedUnits
	local compressedUnit	
	local compressedMembers = {}
	local unitsCounter = 0
	
	local members = group.members
	if #members > 35 then
		for _, entity in pairs(members) do
			if entity.valid and (entity.type == "unit") then
				local compressIndex = entity.name
				if not compressedMembers[entity.name] then
					compressedMembers[entity.name] = {count = 0}
				end
				compressedUnit = compressedUnits[entity.unit_number]
				if compressedUnit then
					compressedMembers[entity.name].count = compressedMembers[entity.name].count + compressedUnit.count
					destroy_RenderingText(compressedUnit.textId)
					compressedUnits[entity.unit_number] = nil
				else
					compressedMembers[entity.name].count = compressedMembers[entity.name].count + 1
				end	
				if compressedMembers[entity.name].count > 1 then
					unitsCounter = unitsCounter + compressedMembers[entity.name].count
					entity.destroy()
				end
			end	
		end
		for _, entity in pairs(group.members) do
			if entity.valid and (entity.type == "unit") then
				local stackSize = compressedMembers[entity.name].count
				if stackSize > 1 then	
					compressedUnits[entity.unit_number] = {count = stackSize, entity = entity}
					if squad.nonRampantSquad then
						compressedUnits[entity.unit_number].textId = draw_CompressedText(compressedUnits[entity.unit_number].count, surface, entity, {r = 0, g = 0.5, b = 0, a = 0.3})
					else
						compressedUnits[entity.unit_number].textId = draw_CompressedText(compressedUnits[entity.unit_number].count, surface, entity, compressedColor)
					end	
				end	
			end	
		end
		squad.compressed = true

--		game.print("compressed: + "..unitsCounter.." units [gps=" .. group.position.x .. "," .. group.position.y .."]")	-- DEBUG
	end	
end

-----------------
--  compressDatas
--	name1	10 biters											
--	name2	20											
--	name3	15											
--	name4	25											
--	name5	30											
--	membersToCompress = 100
--  compressedSize = 30											
--	==>	averageStackSize = 4
--	result:									
--  name1	3			4	3	3						10
--  name2	5			4	4	4	4	4				20
--  name3	4			4	4	4	3					15
--  name4	7			4	4	4	4	3	3	3		25
--  name5	8			4	4	4	4	4	4	3	3	30
--  		27											100
local function squadSmoothCompress(map, squad, compressedSize)
	if not squad then
		return
	end	
	if not compressedSize then
		return
	end	
	if squad.smoothCompressed then
		return
	end
	
    local group = squad.group
	if not group then
		return
	end	
	
	local members = group.members
	if #members < (compressedSize + 5) then
		return
	end
	
	if not squad.compressed and (squad.compressTick and ((game.tick - squad.compressTick) < 3600)) then
		return
	end
	
	local compressedUnits = map.universe.compressedUnits		
	local compressedUnit	
    local surface = group.surface	

	------------------
	local compressDatas = {}
	local membersToCompress = 0
	local unitsCounter = 0	-- debug
	
	for _, entity in pairs(members) do
		if entity.valid and (entity.type == "unit") then
			if not compressDatas[entity.name] then
				compressDatas[entity.name] = {count = 0, entities = {}, unitSample = entity}
			end
			compressedUnit = compressedUnits[entity.unit_number]
			if compressedUnit then
				compressDatas[entity.name].count = compressDatas[entity.name].count + compressedUnit.count
				membersToCompress = membersToCompress + compressedUnit.count
				destroy_RenderingText(compressedUnit.textId)
				compressedUnits[entity.unit_number] = nil
			else
				compressDatas[entity.name].count = compressDatas[entity.name].count + 1
				membersToCompress = membersToCompress + 1
			end	
			local entities = compressDatas[entity.name].entities
			entities[#entities+1] = entity
		end	
	end
	local averageStackSize = mCeil(membersToCompress/compressedSize)
	for entityName, compressData in pairs(compressDatas) do
		compressData.maxStacks = mCeil(compressData.count / averageStackSize)
		
		local entities = compressData.entities
		local unitsToCreate = compressData.maxStacks - #entities
		if unitsToCreate > 0 then 
			for i = 1, unitsToCreate do
				local unitSample = compressData.unitSample
				local newEntity = surface.create_entity({
									name = unitSample.name,
									position = unitSample.position, 
									direction = unitSample.direction,
									force = unitSample.force,
									})
				if newEntity and newEntity.valid then 
					entities[#entities+1] = newEntity	
					group.add_member(newEntity)									
				end	
			end
		elseif unitsToCreate < 0 then
			for i = #entities, (compressData.maxStacks + 1), -1 do
				entities[i].destroy()
			end
		end	
		
		local unitsCounted = 0
		local stacksCreated = 0
		for i = compressData.maxStacks, 1, - 1 do
			local entity = entities[i]
			local stackSize = mCeil((compressData.count - unitsCounted) / i)
			unitsCounted = unitsCounted + stackSize
			if (stackSize > 1) and entity and entity.valid then
				compressedUnits[entity.unit_number] = {count = stackSize, entity = entity}
					if squad.nonRampantSquad then
						compressedUnits[entity.unit_number].textId = draw_CompressedText(compressedUnits[entity.unit_number].count, surface, entity, {r = 0, g = 0.5, b = 0, a = 0.3})
					else
						compressedUnits[entity.unit_number].textId = draw_CompressedText(compressedUnits[entity.unit_number].count, surface, entity, smthCompressedColor)
					end	
				unitsCounter = unitsCounter + stackSize -- debug
			end	
		end
	end	
	------------------	
	
	squad.compressed = true
	squad.smoothCompressed = true
	-- if unitsCounter > 0 then
		-- game.print("squadSmoothCompress: compressed: + "..unitsCounter.." units [gps=" .. group.position.x .. "," .. group.position.y .."]")	-- debug		
	-- end	
end

function squadCompression.processCompression(map, squad, chunk, fullCompressAllowed, debugMessages)
	if not map then
		return
	end	
	if chunk and (chunk ~= -1) then
		if not squad.compressed then
			if (chunk[PLAYER_PHEROMONE] < PLAYER_PHEROMONE_GENERATOR_AMOUNT * 0.008) then	-- ~6 chunks
				if fullCompressAllowed and (chunk[BASE_DETECTION_PHEROMONE] < 3138) then
					squadCompress(map, squad)
				elseif (chunk[BASE_DETECTION_PHEROMONE] < 5000) then
					local squadSize = 100
					if map.universe.squadCount < 5 then
						squadSize = 100
					else
						squadSize = mMax(20, mCeil(500 / (map.universe.squadCount)))
					end
					squadSmoothCompress(map, squad, squadSize)
				end
			else
				squad.compressTick = game.tick
			end	
		else
			if (chunk[BASE_DETECTION_PHEROMONE] > 7000) or (chunk[PLAYER_PHEROMONE] > PLAYER_PHEROMONE_GENERATOR_AMOUNT * 0.04) then	-- ~ 4 chunks
				if debugMessages then
					game.print("processCompression: squad#"..squad.groupNumber.." squadDecompress [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")	-- debug
				end
				squadCompression.squadDecompress(map.universe, map.surface, squad)	
			elseif (not squad.smoothCompressed) and (chunk[BASE_DETECTION_PHEROMONE] > 3874) then
				local squadSize = 100
				if map.universe.squadCount < 5 then
					squadSize = 100
				else
					squadSize = mMax(20, mCeil(500 / (map.universe.squadCount)))
				end
				
				if debugMessages then
					game.print("processCompression: squad#"..squad.groupNumber.." squadSmoothCompress [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")	-- debug
				end	
				squadSmoothCompress(map, squad, squadSize)	-- squadFullToSmoothCompress
			end	
		end	
	end
end

-- DEBUG
-- local renderColor = {0, 1, 0}
-- local renderColor2 = {1, 0, 0}


function squadCompression.nonRampantCompressedSquads(universe)
	local map
	local u = 0
	for i, squad in pairs(universe.nonRampantCompressedSquads) do
		u = u + 1
		map = squad.map
		if map and squad.group.valid then
			squadCompression.processCompression(map, squad, getChunkByPosition(map, squad.group.position), false, false)	-- debug	, true
			-- debug
			-- rendering.draw_circle{color = renderColor, filled = false, radius = 0.5, width = 2, target  = squad.group.position, surface = squad.group.surface, time_to_live = 600}
			-- rendering.draw_text{text = tostring(u), surface = squad.group.surface, target = squad.group.position, color = renderColor2, scale = 3, time_to_live = 600}
		else	
			squad.compressed = nil
		end	
		if not squad.compressed then
			universe.nonRampantCompressedSquads[i] = nil
		end	
	end
end

function squadCompression.onUnitKilled(universe, surface, entity, eventForce, cause)
	if (not entity) or not (entity.valid) then
		return
	end
	local compressedUnits = universe.compressedUnits
	local compressedUnit = compressedUnits[entity.unit_number]
	if not compressedUnit then
		return
	end	

	compressedUnit.count = compressedUnit.count - 1
	if compressedUnit.count < 1 then
		compressedUnits[entity.unit_number] = nil
	else
		local newEntity = surface.create_entity({
			name = entity.name,
			position = entity.position, 
			direction = entity.direction,
			force = entity.force,
			})
		if not newEntity then
			compressedUnits[entity.unit_number] = nil
			return
		end
		if newEntity.valid then	
			if compressedUnit.count > 1 then
				-- the same record moves to the new carrier, so a gradual decompression in progress continues
				compressedUnit.entity = newEntity
				compressedUnit.textId = draw_CompressedText(compressedUnit.count, surface, newEntity)
				compressedUnits[newEntity.unit_number] = compressedUnit
			end
		end	
		compressedUnits[entity.unit_number] = nil
		
		local group = (entity.commandable and entity.commandable.parent_group)
		if group and group.is_unit_group then
			group.add_member(newEntity)
		end	
		
		if eventForce and (eventForce.name ~= "enemy") and cause and cause.valid then
			if newEntity.valid then	
				newEntity.destructible = false
				universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 5}
			end	

			local incomingRange = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, cause.position.x, cause.position.y)
			if group then
				local squad = universe.groupNumberToSquad[group.unique_id] or universe.nonRampantCompressedSquads[group.unique_id]
				if incomingRange < 70 then
					squadCompression.squadDecompress(universe, surface, squad, group, cause, true)
				end	
			elseif (incomingRange < 20) and newEntity.valid then 
				squadCompression.decompressUnit(universe, surface, newEntity)
			end
		end					
	end
end

function squadCompression.onUnitPreKilled(universe, surface, entity, eventForce, cause)
	local compressedUnits = universe.compressedUnits
	local compressedUnit = compressedUnits[entity.unit_number]
	if not compressedUnit then
		return
	end	

	if compressedUnit.count < 2 then
		compressedUnits[entity.unit_number] = nil
	else
		destroy_RenderingText(compressedUnit.textId)
		
		entity.health = entity.max_health		
		compressedUnit.count = compressedUnit.count - 1
		if compressedUnit.count > 1 then
			compressedUnit.textId = draw_CompressedText(compressedUnit.count, surface, entity)	
		end

		local newEntity = surface.create_entity({
			name = entity.name,
			position = entity.position, 
			direction = entity.direction,
			force = entity.force,
			})			
		if newEntity and newEntity.valid then
			newEntity.health = 0
		end	
		
		if eventForce and (eventForce.name ~= "enemy") and cause and cause.valid then
			local incomingRange = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, cause.position.x, cause.position.y)
			local group = (entity.commandable and entity.commandable.parent_group)
			if group and group.is_unit_group then
				local squad = universe.groupNumberToSquad[group.unique_id] or universe.nonRampantCompressedSquads[group.unique_id]
				if incomingRange < 70 then
					squadCompression.squadDecompress(universe, surface, squad, group, cause, true)
				end
			elseif incomingRange < 20 then
				squadCompression.decompressUnit(universe, surface, entity)
			end
		end	
		
	end
end


function squadCompression.removeOneTickImmunity(universe)
 	for i,entityData in pairs(universe.oneTickImmunityUnits) do
		if game.tick >= entityData.tick then
			local entity = entityData.entity
			if entity.valid then
				entity.destructible = true
			end
			universe.oneTickImmunityUnits[i] = nil
		end
	end
end

function squadCompression.checkCompressedUnitsList(universe)
	if universe then
		local compressedUnits = universe.compressedUnits		
		for compressedIndex, compressedUnit in pairs(compressedUnits) do
			if (not compressedUnit.entity) or (not compressedUnit.entity.valid) then  
				compressedUnits[compressedIndex] = nil
			end	
		end
	end	
end

squadCompressionG = squadCompression
return squadCompression
