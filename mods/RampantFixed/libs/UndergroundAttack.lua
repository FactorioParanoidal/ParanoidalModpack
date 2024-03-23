if (undergroundAttackG) then
    return undergroundAttackG
end
local undergroundAttack = {}

local mapUtils = require("libs/MapUtils")
local mathUtils = require("libs/MathUtils")
local scoreChunks = require("ScoreChunks")
local unitGroupUtils = require("libs/UnitGroupUtils")

local positionToChunkXY = mapUtils.positionToChunkXY
local getChunkListInRange = mapUtils.getChunkListInRange
local getChunkByXY = mapUtils.getChunkByXY
local scoreAttackLocation = scoreChunks.scoreAttackLocation
local createSquad = unitGroupUtils.createSquad

local mRandom = math.random

local processingInterval = 120
local undergroundSpeed = 5	-- tiles
local undergroundScanRange = 15
local playerMilitaryInRange_Query = {
	--force = universe.activePlayerForces, 
	force = nil, 
	type = {"ammo-turret", "fluid-turret", "electric-turret", "radar"},
	position = nil,
	radius = undergroundScanRange,
	limit=1
	}
	
local playerRandomUndergroundTarget_Query = {
	--force = universe.activePlayerForces, 
	force = nil, 
	type = {"mining-drill", "generator", "artillery-turret", "radar", "train-stop"}
	}
	

function undergroundAttack.drawDigInDust(surface, position)
	surface.create_trivial_smoke({name = "digIn-dust-nonTriggerCloud-rampant", position = position})
end

function undergroundAttack.drawDigOutDust(surface, position)
	surface.create_entity({name = "digOut-dust-cloud-rampant", position = position})
end

function undergroundAttack.drawUndegroundDust(surface, position)
	surface.create_entity({name = "undeground-dust-cloud-rampant", position = position})
	surface.create_trivial_smoke({name = "undergroundTrace-dust-nonTriggerCloud-rampant", position = position})
	
end

local sideVectors = {{1,0}, {0,1}, {-1,0}, {0,-1}}
local function digOut(undergroundSquad, targetPosition)
	local map = undergroundSquad.map
	if (not map) or (not map.surface.valid) then
		return
	end
	local universe = map.universe
	local surface = map.surface
		
	local squadMembers = undergroundSquad.squadMembers
	local members = squadMembers.members
	-- game.print("digOut: [gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .."]")	-- debug
	local queuedMembers = {}
	local decomressLater = false
    local squad = createSquad(undergroundSquad.position, map, nil, false)
	local group
	squad.disbandTick = game.tick + 18000
	
	if squad and squad.group and squad.group.valid then
		squad.rabid = true
		local digOutPositions = {}
		-------------------
		if targetPosition then
			digOutPositions = {}
			local dx
			local dy
			if targetPosition.x > undergroundSquad.position.x then
				dx = 1
			else
				dx = -1				
			end
			if targetPosition.y > undergroundSquad.position.y then
				dy = 1
			else
				dy = -1				
			end
			for x = undergroundSquad.position.x - 5*dx, undergroundSquad.position.x, dx do
				for y = undergroundSquad.position.y - 5*dy, undergroundSquad.position.y, dy do
					local tile = surface.get_tile({x, y})
					if tile and (not tile.collides_with("resource-layer")) then
						digOutPositions[#digOutPositions+1] = {x = x, y = y}
					end
				end
			end
			
			if #digOutPositions < 5 then
				for x = undergroundSquad.position.x, targetPosition.x, dx do
					for y = undergroundSquad.position.y, targetPosition.y, dy do
						local tile = surface.get_tile({x , y})
						if tile and (not tile.collides_with("resource-layer")) then
							digOutPositions[#digOutPositions+1] = {x = x, y = y}
						end
					end
				end			
			end
			
			if #digOutPositions == 0 then
				digOutPositions[1] = {x = targetPosition.x, y = targetPosition.y}
			end
			
		else

			for dx = 1, 5 do
				for dy = 1, 5 do
					for _, vector in pairs(sideVectors) do
						local x = undergroundSquad.position.x + dx*vector[1]
						local y = undergroundSquad.position.y + dx*vector[2]
						local tile = surface.get_tile({x, y})
						if tile and (not tile.collides_with("resource-layer")) then
							digOutPositions[#digOutPositions+1] = {x = x, y = y}
						end
					end	
				end
				if #digOutPositions == 0 then
					digOutPositions[1] = {x = undergroundSquad.position.x, y = undergroundSquad.position.y}
				end
			end
		
		end
		-------------------
		
		
		group = squad.group
	
		local undergroundTotal = 0
		local unitsInTile = 999
		local digOutIndex
		local digOutPosition
	
		for entityName, count in pairs (members) do
			if count > 1 then
				for i = 1, count do
					if unitsInTile > 5 then
						unitsInTile = 0
						digOutIndex, digOutPosition = next(digOutPositions, digOutIndex)
						if not digOutIndex then
							digOutIndex, digOutPosition = next(digOutPositions, nil)
						end
					end	
					local prototypeList = game.get_filtered_entity_prototypes({{filter = "name", name = entityName}})
					
					if prototypeList and (#prototypeList>0) then
						local newEntity = surface.create_entity({
							name = entityName,
							position = digOutPosition, 
							force = "enemy",
							})	
						if newEntity and newEntity.valid then 
							unitsInTile = unitsInTile + 1
							group.add_member(newEntity)
							
							newEntity.destructible = false
							universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 1}
							undergroundTotal = undergroundTotal + 1
							
							if undergroundTotal >= 200 then
								queuedMembers[newEntity.unit_number] = {
									count = count - i,
									name = entityName,
									position = {x = newEntity.position.x, y = newEntity.position.y}, 
									direction = newEntity.direction,
									force = "enemy"
									}
								decomressLater = true	
								break
							end											
						end	
					end	
				end								
			end
		end
		
		if undergroundTotal > 0 then
			undergroundAttack.drawDigOutDust(surface, undergroundSquad.position)
			universe.squadCount = universe.squadCount + 1
            universe.groupNumberToSquad[squad.groupNumber] = squad
		end	
		universe.undergroundSquads[undergroundSquad.groupNumber] = nil
		
		if decomressLater then
			universe.decomressQueue[group] = queuedMembers 
		end	
	end
	
	
	return squad
end

local function getRandomUndergroundTarget(map)
	local surface = map.surface
	local entities = surface.find_entities_filtered(playerRandomUndergroundTarget_Query) 
	if #entities > 0 then	
		local entity = entities[mRandom(1, #entities)]
		if entity.valid then
			return entity
		else
			return nil
		end		
	end
	return nil	
end

local function showFlyingText(parameters)
    for i, player in pairs(game.connected_players) do
		if player.valid then
			if (not parameters.surface) or (parameters.surface.index == ((player.surface and player.surface.index) or 0)) then
				player.create_local_flying_text(parameters)
			end	
		end	
    end
end

function undergroundAttack.createUndergroudAttack(map, squad)
	if (not squad) then
		return
	end
    local group = squad.group
	if not group then
		return
	end	
	local universe = map.universe
	local compressedUnits = universe.compressedUnits

    local surface = map.surface
	local squadMembers = {total = 0, members = {}}
	local members = squadMembers.members
	local dustCloudPositions = {}
	for _, entity in pairs(group.members) do
		if entity.valid then
			local positionIndex = "x"..math.ceil(entity.position.x).."y"..math.ceil(entity.position.y)
			local entityIndex = entity.name
			local compressedUnit = compressedUnits[entity.unit_number]
			if compressedUnit then
				members[entityIndex] = (members[entityIndex] or 0) + compressedUnit.count
				squadMembers.total = squadMembers.total + compressedUnit.count
				
				compressedUnits[entity.unit_number] = nil
			else
				members[entityIndex] = (members[entityIndex] or 0) + 1
				squadMembers.total = squadMembers.total + 1
			end
			dustCloudPositions[positionIndex] = {x = entity.position.x, y = entity.position.y}
			entity.destroy()
		end
	end
	
    local undergroundSquad = createSquad(group.position, map, group, false)
	undergroundSquad.position = {x = group.position.x, y = group.position.y}
	undergroundSquad.nextTick = game.tick + processingInterval
	undergroundSquad.squadMembers = squadMembers
	if squad.undergoundAttack == "randomTarget" then
		playerRandomUndergroundTarget_Query.force = universe.activePlayerForces
		local target = getRandomUndergroundTarget(map)
		if target then
			undergroundSquad.targetPosition = {x = target.position.x, y = target.position.y}
		end
	elseif (squad.undergoundAttack == "position") and (squad.targetPosition) then	
		undergroundSquad.targetPosition = {x = squad.targetPosition.x, y = squad.targetPosition.y}
	end	
	-- debug
	-- if undergroundSquad.targetPosition then
		-- rendering.draw_line{surface = group.surface, from = group.position, to = undergroundSquad.targetPosition, color = {1,0,0}, width = 2, time_to_live = 3600}			
	-- end
	
	for _, position in pairs(dustCloudPositions) do
		undergroundAttack.drawDigInDust(surface, position)
	end
	
	map.universe.undergroundSquads[undergroundSquad.groupNumber] = undergroundSquad 
	-- game.print(undergroundSquad.groupNumber..": undergroundAttack.nextTick = "..undergroundSquad.nextTick.."[gps=" .. squad.group.position.x .. "," .. squad.group.position.y .."]")	-- debug

	group.destroy()
	-- squad will be deleted in squadAttack.cleanSquads
	return undergroundSquad
end

function undergroundAttack.onUnitKilled_DigIn(map, entity, cause)
	if (not entity) or not (entity.valid) then
		return
	end
	local group = entity.unit_group
	if not group then
		return
	end	
	local squad = map.universe.groupNumberToSquad[group.group_number]		-- or universe.nonRampantCompressedSquads[group.group_number]
	if (not squad) or squad.rabid or squad.frenzy then
		return
	end
	local roll = math.random()
	if roll < 0.2 then
		squad.undergoundAttack = "randomTarget"
	elseif roll < 0.6 then
		squad.undergoundAttack = "common"
	else
		squad.undergoundAttack = "position"	
		squad.targetPosition = {x = cause.position.x, y = cause.position.y}
	end
	undergroundAttack.createUndergroudAttack(map, squad)
end

local function findNextAttackChunk(map, undergroundSquad)
    local x, y = positionToChunkXY(undergroundSquad.position)
    local chunk = getChunkByXY(map, x, y)
	local chunkList =  getChunkListInRange(map, x, y, undergroundSquad.range or 2)
	
	local highestScore = -1
	local highestChunk = -1
	if chunk ~= -1 then
		highestScore = scoreAttackLocation(map, chunk)
	end	
	for i = 1, #chunkList do
		local neighborChunk = chunkList[i] 
		if neighborChunk~=-1 then
			local score = scoreAttackLocation(map, neighborChunk)
			if (score > highestScore) then
				highestScore = score
				highestChunk = neighborChunk
			end
		end	
	end
	return highestChunk
end

-- move to target position, check for military, dig out.
local function processUndergroundSquad(map, undergroundSquad)
    local surface = map.surface
	
	local traveled = 0
	local dx = 0
	local dy = 0
	local range = 1
	if undergroundSquad.targetPosition then
		dx = undergroundSquad.targetPosition.x - undergroundSquad.position.x
		dy = undergroundSquad.targetPosition.y - undergroundSquad.position.y
		range = mathUtils.euclideanDistancePoints(undergroundSquad.position.x, undergroundSquad.position.y, undergroundSquad.targetPosition.x, undergroundSquad.targetPosition.y)
	end
	
	if range <= undergroundSpeed then
		if undergroundSquad.targetPosition then 
			undergroundSquad.position.x = undergroundSquad.targetPosition.x
			undergroundSquad.position.y = undergroundSquad.targetPosition.y
		end	
		local nextAttackChunk = findNextAttackChunk(map, undergroundSquad)
		if nextAttackChunk == - 1 then
			--game.print("processUndergroundSquad : no nextAttackChunk")	-- debug
			digOut(undergroundSquad)
			return
		else
			undergroundSquad.targetPosition = {x = nextAttackChunk.x, y = nextAttackChunk.y}
			traveled = range
			
			dx = undergroundSquad.targetPosition.x - undergroundSquad.position.x
			dy = undergroundSquad.targetPosition.y - undergroundSquad.position.y
			range = mathUtils.euclideanDistancePoints(undergroundSquad.position.x, undergroundSquad.position.y, undergroundSquad.targetPosition.x, undergroundSquad.targetPosition.y)
		end
	end	
	local kf =  math.min((undergroundSpeed - traveled)/ range , 1)
	undergroundSquad.position.x = math.ceil(undergroundSquad.position.x + dx * kf)
	undergroundSquad.position.y = math.ceil(undergroundSquad.position.y + dy * kf)
	undergroundSquad.nextTick = game.tick + processingInterval


	playerMilitaryInRange_Query.force = map.universe.activePlayerForces
	playerMilitaryInRange_Query.position = undergroundSquad.position
	local entities = surface.find_entities_filtered(playerMilitaryInRange_Query) 
	if #entities > 0 then
		-- game.print("processUndergroundSquad : digOut, military ")	-- debug
		digOut(undergroundSquad, entities[1].position)
	else	
		undergroundAttack.drawUndegroundDust(surface, undergroundSquad.position)
		showFlyingText({text = tostring(undergroundSquad.squadMembers.total).." [entity=big-biter]", surface = surface, position = undergroundSquad.position, color = {1, 0, 0}, speed  = 1, time_to_live = 30})
		if not map.universe.firtstUndergroundAlertShown then
			local chunkX = math.floor(undergroundSquad.position.x / 32)
			local chunkY = math.floor(undergroundSquad.position.y / 32)
			if game.forces["player"].is_chunk_visible(surface, {x = chunkX, y = chunkY}) then
				game.print({"", {"description.rampantFixed--firstUndergroundAttackWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .."]")})
				map.universe.firtstUndergroundAlertShown = true
			end
		end
	end
end

local maxSquadsPerProcessing = 10
function undergroundAttack.processUndergroundSquads(universe)
	if not universe.undergroundAttack then
		return
	end
	local squadsProcessed = 0
	for i, undergroundSquad in pairs(universe.undergroundSquads) do
		map = undergroundSquad.map
		if map and map.surface and map.surface.valid then
			if undergroundSquad.nextTick <= game.tick then
				processUndergroundSquad(map, undergroundSquad)
				squadsProcessed = squadsProcessed + 1
				if squadsProcessed >= maxSquadsPerProcessing then
					break
				end
			end	
		else	
			universe.undergroundSquads[i] = nil
		end
	end
end


function undergroundAttack.updateUndergroundAttackProbability(universe)
	if not universe.undergroundAttack then
		return
	end
	
	local newUndergroundAttackProbability
	local evolution_factor = game.forces.enemy.evolution_factor
	local minEvo = 0.4
	local maxEvo = 0.8
	if evolution_factor <= minEvo then
		newUndergroundAttackProbability = 0
	elseif evolution_factor >= maxEvo then
		newUndergroundAttackProbability = settings.global["rampantFixed--undergroundAttackProbability"].value
	else
		newUndergroundAttackProbability =  settings.global["rampantFixed--undergroundAttackProbability"].value * ((evolution_factor - minEvo) / (maxEvo - minEvo))
		if newUndergroundAttackProbability < 0.001 then
			newUndergroundAttackProbability = 0
		end
	end
	if universe.undergroundAttackProbability == 0 then
		universe.undergroundAttackProbability = newUndergroundAttackProbability
		if newUndergroundAttackProbability > 0 then
			game.print({"description.rampantFixed--undergroundAttackWarning"})
		end
	else	
		universe.undergroundAttackProbability = math.max(newUndergroundAttackProbability, 0.0001)
	end
end	

undergroundAttackG = undergroundAttack
return undergroundAttack
