if (squadCompressionG) then
    return squadCompressionG
end
local squadCompression = {}

local constants = require("Constants")
local mapUtils = require("MapUtils")
local mathUtils = require("MathUtils")
local unitUtils = require("UnitUtils")
local foreignEnemies = require("ForeignEnemies")

local championUnits = unitUtils.championUnits
local isForeign = foreignEnemies.isForeign


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
    if squad then
        squad.compressed = nil
        squad.smoothCompressed = nil
    end
end

-- Exactly 200 release attempts across all queues over any 60 consecutive ticks.
local function decompressAllowance(tick)
    return mFloor(DECOMPRESS_UNITS_PER_SECOND * (tick + 1) / 60) - mFloor(DECOMPRESS_UNITS_PER_SECOND * tick / 60)
end

local function getDecompressList(universe)
    if not universe.decompressSquads then universe.decompressSquads = {} end
    if not universe.decompressByGroup then universe.decompressByGroup = {} end
    return universe.decompressSquads, universe.decompressByGroup
end

local function newDecompressEntry(universe, groupId, priority)
    local entry = {groupId = groupId, packs = {}, packIndex = 1, extraTotal = 0, released = 0, startTick = game.tick}
    local list, byGroup = getDecompressList(universe)
    list[#list + 1] = entry
    if groupId then byGroup[groupId] = entry end
    if priority then universe.decompressPriority = entry end
    return entry
end

local function findDecompressEntry(universe, groupId)
    local _, byGroup = getDecompressList(universe)
    return byGroup[groupId]
end

local function addPackToEntry(entry, pack)
    pack.decompressing = true
    entry.packs[#entry.packs + 1] = pack
    entry.extraTotal = entry.extraTotal + pack.count - (pack.detached and 0 or 1)
end

local function addImmunity(universe, entity, tick)
    entity.destructible = false
    local pending = universe.oneTickImmunityUnits
    pending[#pending + 1] = {entity = entity, tick = tick}
end

local function qualityName(entity)
    local quality = entity.quality
    return quality and quality.name or "normal"
end

-- One pack visit per call, including stale packs and temporary failures.
local function processDecompressEntry(universe, entry, tick, budget)
    local index = entry.packIndex
    local pack = entry.packs[index]
    if not pack then return 0, true end
    if pack.retryTick and pack.retryTick > tick then return 0, false end
    local elapsed = tick - entry.startTick + 1
    local quota = budget
    if elapsed < DECOMPRESS_SPREAD_TICKS then
        quota = mMin(budget, mCeil(entry.extraTotal * elapsed / DECOMPRESS_SPREAD_TICKS) - entry.released)
    end
    local entity = pack.entity
    local id = entity and entity.valid and entity.unit_number
    local detached = pack.detached
    local hasCarrier = id and universe.compressedUnits[id] == pack
    if (not hasCarrier and not detached) or pack.count <= (detached and 0 or 1) then
        if hasCarrier then universe.compressedUnits[id] = nil end
        pack.decompressing = nil
        entry.packIndex = index + 1
        return 0, not entry.packs[index + 1]
    end
    local surface = hasCarrier and entity.surface
    if detached then
        surface = detached.surface or (not detached.nativeSurface and game.surfaces[detached.surfaceIndex])
    end
    if not (surface and surface.valid) then
        -- A removed surface has no valid destination. Preserve the record without
        -- retrying on a different world or consuming budget every tick.
        universe.unplacedDecompression = universe.unplacedDecompression or {}
        universe.unplacedDecompression[#universe.unplacedDecompression + 1] = detached
        if detached then detached.count = pack.count end
        pack.decompressing = nil
        entry.packIndex = index + 1
        return 0, not entry.packs[index + 1]
    end
    local commandable = hasCarrier and entity.commandable
    local group = (commandable and commandable.parent_group) or (detached and detached.group)
    local spawn = detached and detached.spawn or {
        name = entity.name, position = entity.position, direction = entity.direction,
        force = entity.force, quality = qualityName(entity)
    }
    local attempts, released = 0, 0
    local left = detached and 0 or 1
    while attempts < quota and pack.count > left do
        attempts = attempts + 1
        local newEntity = surface.create_entity(spawn)
        if not (newEntity and newEntity.valid) then
            pack.retryDelay = mMin((pack.retryDelay or 15) * 2, 3600)
            pack.retryTick = tick + pack.retryDelay
            break
        end
        pack.retryDelay, pack.retryTick = nil, nil
        pack.count = pack.count - 1
        released = released + 1
        if group and group.valid and group.is_unit_group then group.add_member(newEntity) end
        addImmunity(universe, newEntity, tick + 1)
    end
    if hasCarrier and released > 0 then
        if pack.count > 1 then
            pack.textId = draw_CompressedText(pack.count, surface, entity, nil, pack.textId)
        else
            destroy_RenderingText(pack.textId)
            pack.textId = nil
            universe.compressedUnits[id] = nil
        end
    end
    if pack.count <= left then
        pack.decompressing = nil
        entry.packIndex = index + 1
    end
    entry.released = entry.released + released
    return attempts, not entry.packs[entry.packIndex]
end

-- Legacy underground queue: convert one record at a time, even if its group
-- has dissolved. A save that has already lost both references is ambiguous.
local function importLegacyPack(universe)
    local legacy = universe.decomressQueue
    if not legacy then return end
    local group = universe.legacyDecompressionCursor
    if not (group and legacy[group]) then group = next(legacy) end
    if not group then return end
    local members = legacy[group]
    universe.legacyDecompressionCursor = next(legacy, group)
    local key, record = next(members)
    if key then
        local surface = group and group.valid and group.surface
        local surfaceIndex = record.surfaceIndex or (surface and surface.index)
        local detached = {count = record.count, spawn = {
            name = record.name, quality = record.quality, position = record.position,
            direction = record.direction, force = record.force
        }, surfaceIndex = surfaceIndex, group = group and group.valid and group or nil}
        if surfaceIndex then
            local entry = newDecompressEntry(universe)
            entry.startTick = game.tick - DECOMPRESS_SPREAD_TICKS
            addPackToEntry(entry, {count = record.count, detached = detached})
        else
            universe.unplacedDecompression = universe.unplacedDecompression or {}
            universe.unplacedDecompression[#universe.unplacedDecompression + 1] = detached
        end
        members[key] = nil
    end
    if not next(members) then legacy[group] = nil end
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
			addPackToEntry(newDecompressEntry(universe), compressedUnit)
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
								or newDecompressEntry(universe, groupId, squad and squad.settlers)
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
    importLegacyPack(universe)
    local list = universe.decompressSquads
    if not list or not list[1] then return end
    local _, byGroup = getDecompressList(universe)
    local tick = game.tick
    local budget = decompressAllowance(tick)
    local index = universe.decompressCursor or 1
    local visits = mMin(16, #list)
    local priority = universe.decompressPriority
    if priority and #list > 1 and list[index] ~= priority and tick % 2 == 0 then
        local attempts, done = processDecompressEntry(universe, priority, tick, 1)
        visits = visits - 1
        budget = budget - attempts
        if done then universe.decompressPriority = nil end
    end
    for _ = 1, visits do
        if budget <= 0 or #list == 0 then break end
        index = index > #list and 1 or index
        local entry = list[index]
        if entry.groupId and not byGroup[entry.groupId] then byGroup[entry.groupId] = entry end
        local attempts, done = processDecompressEntry(universe, entry, tick, budget)
        budget = budget - attempts
        if done then
            if entry.groupId and byGroup[entry.groupId] == entry then byGroup[entry.groupId] = nil end
            if entry == universe.decompressPriority then universe.decompressPriority = nil end
            local last = #list
            list[index] = list[last]
            list[last] = nil
        else
            index = index + 1
        end
    end
    universe.decompressCursor = index
end

-- Paranoidal: champions and hour bosses (libs/Champions.lua) and Big Monsters enemies (their script tracks them,
-- libs/ForeignEnemies.lua) are never packed or used as pack carriers
local function packable(entity, champions)
	return entity.valid and (entity.type == "unit") and not (champions and champions[entity.unit_number])
		and not isForeign(entity.name)
end

local function packKey(entity)
    return entity.name .. ":" .. qualityName(entity)
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
	local champions = championUnits(map.universe)
	if #members > 35 then
		for _, entity in pairs(members) do
			if packable(entity, champions) then
				local key = packKey(entity)
				if not compressedMembers[key] then
					compressedMembers[key] = {count = 0}
				end
				local id = entity.unit_number
				compressedUnit = compressedUnits[id]
				local cohort = compressedMembers[key]
				local count = compressedUnit and compressedUnit.count or 1
				if not cohort.carrier then
					cohort.carrier = entity
					cohort.count = count
					if compressedUnit then
						destroy_RenderingText(compressedUnit.textId)
						compressedUnits[id] = nil
					end
				elseif entity.destroy() then
					cohort.count = cohort.count + count
					if compressedUnit then
						destroy_RenderingText(compressedUnit.textId)
						compressedUnits[id] = nil
					end
				end
			end	
		end
		for _, entity in pairs(group.members) do
			if packable(entity, champions) then
				local cohort = compressedMembers[packKey(entity)]
				local stackSize = cohort.count
				if stackSize > 1 and cohort.carrier == entity then
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
	
	local champions = championUnits(map.universe)
	for _, entity in pairs(members) do
		if packable(entity, champions) then
			local key = packKey(entity)
			if not compressDatas[key] then
				compressDatas[key] = {count = 0, entities = {}, unitSample = entity}
			end
			compressedUnit = compressedUnits[entity.unit_number]
			if compressedUnit then
				compressDatas[key].count = compressDatas[key].count + compressedUnit.count
				membersToCompress = membersToCompress + compressedUnit.count
				destroy_RenderingText(compressedUnit.textId)
				compressedUnits[entity.unit_number] = nil
			else
				compressDatas[key].count = compressDatas[key].count + 1
				membersToCompress = membersToCompress + 1
			end	
			local entities = compressDatas[key].entities
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
									quality = qualityName(unitSample),
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
				if entities[i].destroy() then table.remove(entities, i) end
			end
		end	
		
		local unitsCounted = 0
		local stacksCreated = 0
		for i = #entities, 1, -1 do
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
				if fullCompressAllowed and (chunk[BASE_DETECTION_PHEROMONE] < 4000) then	-- ~9+ chunks from turrets/radars (was 3138, ~12+)
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
					game.print("processCompression: отряд №"..squad.groupNumber.." отряд разжат [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")	-- debug
				end
				squadCompression.squadDecompress(map.universe, map.surface, squad)	
			elseif (not squad.smoothCompressed) and (chunk[BASE_DETECTION_PHEROMONE] > 4300) then	-- ~8 chunks; above the full-compression threshold (was 3874)
				local squadSize = 100
				if map.universe.squadCount < 5 then
					squadSize = 100
				else
					squadSize = mMax(20, mCeil(500 / (map.universe.squadCount)))
				end
				
				if debugMessages then
					game.print("processCompression: отряд №"..squad.groupNumber.." отряд плавно сжат [gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")	-- debug
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
		if map and squad.group and squad.group.valid then
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
        local spawn = {name = entity.name, position = entity.position, direction = entity.direction,
                       force = entity.force, quality = qualityName(entity)}
        local group = entity.commandable and entity.commandable.parent_group
        local newEntity = surface.create_entity(spawn)
        destroy_RenderingText(compressedUnit.textId)
        compressedUnit.textId = nil
        if not (newEntity and newEntity.valid) then
            compressedUnits[entity.unit_number] = nil
            compressedUnit.entity = nil
            compressedUnit.detached = {surface = surface, nativeSurface = true, surfaceIndex = surface.index, spawn = spawn, group = group}
            compressedUnit.retryTick = game.tick + 30
            if not compressedUnit.decompressing then
                addPackToEntry(newDecompressEntry(universe), compressedUnit)
            end
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
		
        if group and group.valid and group.is_unit_group then
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
            quality = qualityName(entity),
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
			if entity and entity.valid then
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
