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

local compressedColor = {r = 0.3, g = 0.5, b = 0, a = 0.3}
local smthCompressedColor = {r = 0.3, g = 0.5, b = 0, a = 0.3}	--{r = 0.7, g = 0.3, b = 0, a = 0.5}


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
				if compresseData.textId and rendering.is_valid(compresseData.textId) then
					rendering.destroy(compresseData.textId) 
				end
				universe.compressedUnits[entity.unit_number] = nil
			end
		end
	end	
	squad.compressed = nil
	squad.smoothCompressed = nil
end

function squadCompression.decompressUnit(universe, surface, entity)
	compressIndex = entity.unit_number
	compressedUnit = universe.compressedUnits[compressIndex]
	if compressedUnit then
		local decompressed = 1
		if (compressedUnit.count > 1) then
			for i = 2, compressedUnit.count do
				local newEntity = surface.create_entity({
					name = entity.name,
					position = entity.position, 
					direction = entity.direction,
					force = entity.force,
					})	
				if newEntity and newEntity.valid then 
					newEntity.destructible = false
					universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 1}
				end	
				decompressed = decompressed + 1
			end
			if compressedUnit.textId and rendering.is_valid(compressedUnit.textId) then
				rendering.destroy(compressedUnit.textId) 
			end
		end
		universe.compressedUnits[compressIndex] = nil
		return decompressed
	else
		return 0
	end
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
	local decomressedTotal = 0
	local queuedMembers = {}
	local decomressLater = false
	local compressedUnit
	local compressIndex
	if group and group.valid then
		for _, entity in pairs(group.members) do
			compressIndex = entity.unit_number
			compressedUnit = universe.compressedUnits[compressIndex]
			if compressedUnit then
				if (compressedUnit.count > 1) then
					local decomressed = 1
					for i = 2, compressedUnit.count do
						if decomressedTotal >= 200 then
							break
						end	
						local newEntity = surface.create_entity({
							name = entity.name,
							position = entity.position, 
							direction = entity.direction,
							force = entity.force,
							})	
						if newEntity.valid then 
							group.add_member(newEntity)
						end	
						newEntity.destructible = false
						universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 1}
						decomressedTotal = decomressedTotal + 1
						decomressed = decomressed + 1
					end
					if decomressed < compressedUnit.count then
						queuedMembers[compressIndex] = {
							count = compressedUnit.count - decomressed,
							name = entity.name,
							position = {x = entity.position.x, y = entity.position.y}, 
							direction = entity.direction,
							force = entity.force
							}
						decomressLater = true	
					end
					if compressedUnit.textId and rendering.is_valid(compressedUnit.textId) then
						rendering.destroy(compressedUnit.textId) 
					end
				end
				universe.compressedUnits[compressIndex] = nil
			end	
		end
		if decomressLater then
			universe.decomressQueue[group] = queuedMembers 
		end	
		--game.print(group.group_number..": decompressed: + "..decomressedTotal.." units [gps=" .. group.position.x .. "," .. group.position.y .."]")	-- DEBUG
	end	
	
	if squad then
		squad.compressed = nil
		squad.smoothCompressed = nil
		squad.compressTick = game.tick
		squad.decompressCause = cause
	end	
end

function squadCompression.processDecompressQueue(universe)
	local decomressQueue = universe.decomressQueue
	local group
	local queuedMembers
	group, queuedMembers = next(decomressQueue, nil)
	if group then
		local decomresseFinished = true
		if group.valid then
			local decomressedTotal = 0
			
			for compressIndex, compressedData in pairs (queuedMembers)	do
				if decomressedTotal >= 50 then
					decomresseFinished = false
					break
				end	
				local decomressed = 0
				for i = 1, compressedData.count do
					if decomressedTotal >= 50 then
						decomresseFinished = false
						break
					end	
					local newEntity = group.surface.create_entity({
						name = compressedData.name,
						position = compressedData.position, 
						direction = compressedData.direction,
						force = compressedData.force,
						})	
					if newEntity.valid then 
						group.add_member(newEntity)
					end	
					decomressedTotal = decomressedTotal + 1
					decomressed = decomressed + 1
				end
				compressedData.count = compressedData.count - decomressed
				if compressedData.count <= 0 then
					queuedMembers[compressIndex] = nil
				end		
			end	
		end	
		if decomresseFinished then
			decomressQueue[group] = nil
		end
	end	
end

local function draw_CompressedText(count, surface, entity, color, textId)
	if textId and rendering.is_valid(textId) then
		rendering.destroy(textId)
	end
	return rendering.draw_text{text = tostring(count), 
		surface = surface, 
		target = entity, 
		only_in_alt_mode = false,
		color = (color or compressedColor), 
		scale = 2.5
		}
	 				
end

local function destroy_CompressedText(textId)
	if textId and rendering.is_valid(textId) then
		rendering.destroy(textId)
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
	
	if #group.members > 35 then		
		for _, entity in pairs(group.members) do
			if entity.valid then
				compressIndex = entity.name
				if not compressedMembers[entity.name] then
					compressedMembers[entity.name] = {count = 0}
				end
				compressedUnit = compressedUnits[entity.unit_number]
				if compressedUnit then
					compressedMembers[entity.name].count = compressedMembers[entity.name].count + compressedUnit.count
					destroy_CompressedText(compressedUnit.textId)
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
			if entity.valid then
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
	
	if #group.members  < (compressedSize + 5) then		
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
	
	for _, entity in pairs(group.members) do
		if entity.valid then
			if not compressDatas[entity.name] then
				compressDatas[entity.name] = {count = 0, entities = {}, unitSample = entity}
			end
			compressedUnit = compressedUnits[entity.unit_number]
			if compressedUnit then
				compressDatas[entity.name].count = compressDatas[entity.name].count + compressedUnit.count
				membersToCompress = membersToCompress + compressedUnit.count
				destroy_CompressedText(compressedUnit.textId)
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
				local entity = surface.create_entity({
									name = unitSample.name,
									position = unitSample.position, 
									direction = unitSample.direction,
									force = unitSample.force,
									})
				entities[#entities+1] = entity	
				group.add_member(entity)									
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
			if stackSize > 1 then
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


function squadCompression.processNonRampantSquads(universe)
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
		newEntity = surface.create_entity({
			name = entity.name,
			position = entity.position, 
			direction = entity.direction,
			force = entity.force,
			})	
		if compressedUnit.count > 1 then
			compressedUnits[newEntity.unit_number] = {count = compressedUnit.count, entity = newEntity}
			compressedUnits[newEntity.unit_number].textId = draw_CompressedText(compressedUnits[newEntity.unit_number].count, surface, newEntity)	
		end
		compressedUnits[entity.unit_number] = nil
		
		local group = entity.unit_group
		if group then
			group.add_member(newEntity)
		end	
		
		if eventForce and (eventForce.name ~= "enemy") and cause and cause.valid then
			newEntity.destructible = false
			universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 5}

			local incomingRange = mathUtils.euclideanDistancePoints(entity.position.x, entity.position.y, cause.position.x, cause.position.y)
			if group then
				local squad = universe.groupNumberToSquad[group.group_number] or universe.nonRampantCompressedSquads[group.group_number]
				if incomingRange < 70 then
					squadCompression.squadDecompress(universe, surface, squad, group, cause, true)
				end	
			elseif incomingRange < 20 then 
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
		destroy_CompressedText(compressedUnit.textId)
		
		entity.health = entity.prototype.max_health		
		compressedUnit.count = compressedUnit.count - 1
		if compressedUnit.count > 1 then
			compressedUnit.textId = draw_CompressedText(compressedUnit.count, surface, entity)	
		end

		newEntity = surface.create_entity({
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
			if group then
				local squad = universe.groupNumberToSquad[group.group_number] or universe.nonRampantCompressedSquads[group.group_number]
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
