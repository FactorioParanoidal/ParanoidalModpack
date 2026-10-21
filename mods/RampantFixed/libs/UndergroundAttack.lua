if (undergroundAttackG) then
    return undergroundAttackG
end
local undergroundAttack = {}

local customAlerts = require("CustomAlerts")
local mapUtils = require("libs/MapUtils")
local mathUtils = require("libs/MathUtils")
local scoreChunks = require("ScoreChunks")
local unitGroupUtils = require("libs/UnitGroupUtils")
local unitUtils = require("UnitUtils")
local foreignEnemies = require("ForeignEnemies")

local positionToChunkXY = mapUtils.positionToChunkXY
local getChunkListInRange = mapUtils.getChunkListInRange
local getChunkByXY = mapUtils.getChunkByXY
local showAlert = customAlerts.showAlert
local scoreAttackLocation = scoreChunks.scoreAttackLocation
local createSquad = unitGroupUtils.createSquad
local championUnits = unitUtils.championUnits
local isForeign = foreignEnemies.isForeign

local mRandom = math.random
local mMin = math.min
local sGsub = string.gsub

local DIG_OUT_AT_ONCE = 200	-- more units come out through the decompression queue
local RANDOM_TARGET_TRIES = 8	-- player chunks searched for a random target

local processingInterval = 120
local undergroundSpeed = 5	-- tiles
local undergroundScanRange = 15
local slowdownStickerName = "slowdown-sticker-rampant"	-- created in data.lua

local playerMilitaryInRange_Query = {
	--force = universe.activePlayerForces, 
	force = nil, 
	type = {"ammo-turret", "fluid-turret", "electric-turret", "radar"},
	position = nil,
	radius = undergroundScanRange,
	limit=1
	}
	
-- searched in single player chunks (was the whole surface)
local playerRandomUndergroundTarget_Query = {
	--force = universe.activePlayerForces, 
	force = nil, 
	area = {{0, 0}, {0, 0}},
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

local function removeConcreteTile(surface, tile)
	if tile.hidden_tile then
		surface.set_tiles({{name = tile.hidden_tile, position = {tile.position.x, tile.position.y}}},true,true,true,true)		
	else
		surface.set_tiles({{name = "landfill", position = {tile.position.x, tile.position.y}}},true,true,true,true)				
	end
end

-- local function showAlert(surface, entity, alertName, message)
	-- local planet = surface.planet
	-- local chunkX = math.floor(entity.position.x / 32)
	-- local chunkY = math.floor(entity.position.y / 32)

	-- local result = false
	-- for _, force in pairs(game.forces) do
		-- if not planet or force.is_space_location_unlocked(planet.name) then	
			-- for _, player in pairs(force.connected_players) do
				-- if force.is_chunk_visible(surface, {x = chunkX, y = chunkY}) then
					-- player.add_custom_alert(
					  -- entity,
					  -- {
						-- type = "virtual",
						-- name = alertName
					  -- },
					  -- message or "",
					  -- true
					-- )
					
					-- result = true					 
				-- end
			-- end
		-- end	
	-- end
	-- return result
-- end

local sideVectors = {{1,0}, {0,1}, {-1,0}, {0,-1}}

-- units dig out 6 per tile and at most ~200 at once, so more positions than this are never used
local DIG_OUT_POSITIONS_LIMIT = 40

-- walkable tile at x, y as a dig-out position; fast floors (concrete) slow the units down and cost them health
local function addDigOutPosition(surface, positions, x, y)
	local tile = surface.get_tile({x, y})
	if tile and (not tile.collides_with("player")) then
		local modifier = tile.prototype.walking_speed_modifier
		local healthRate
		if modifier >= 1.3 then
			if modifier >= 2 then
				healthRate = 0.5
			else
				healthRate = 0.5 + 0.5 * (2 - modifier) / 0.7
			end
		end
		positions[#positions+1] = {x = x, y = y, slowdown = (modifier >= 1.5), healthRate = healthRate}
	end
end

-- walkable tiles of the rectangle (x-major order) until DIG_OUT_POSITIONS_LIMIT positions are collected
local function addDigOutArea(surface, positions, x1, x2, stepX, y1, y2, stepY)
	for x = x1, x2, stepX do
		for y = y1, y2, stepY do
			if #positions >= DIG_OUT_POSITIONS_LIMIT then
				return
			end
			addDigOutPosition(surface, positions, x, y)
		end
	end
end
local function digOut(undergroundSquad, targetPosition)
	local map = undergroundSquad.map
	if (not map) or (not map.surface.valid) then
		return
	end
	local universe = map.universe
	local surface = map.surface
	
	if not undergroundSquad.digOutTick then
		local tile = surface.get_tile(undergroundSquad.position.x, undergroundSquad.position.y)
		if tile.prototype.walking_speed_modifier >= 1.5 then
			removeConcreteTile(surface, tile)
			undergroundSquad.digOutTick = game.tick + 3600
			
			local entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})
			showAlert(surface, entity, "undergroundDigout-warning-rampant", 
				{"", {"description.rampantFixed--undergroundAttackDigoutWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .. "," .. map.surface.name .."]")}
				)
			return
		end
	elseif game.tick < undergroundSquad.digOutTick then
		return
	end
		
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
		local px = undergroundSquad.position.x
		local py = undergroundSquad.position.y
		-------------------
		if targetPosition then
			local dx = (targetPosition.x > px) and 1 or -1
			local dy = (targetPosition.y > py) and 1 or -1
			-- behind the squad, then (if too few) towards the target; units come out 6 per tile, at most 200
			-- at once, so more than DIG_OUT_POSITIONS_LIMIT positions are never used
			addDigOutArea(surface, digOutPositions, px - 5*dx, px, dx, py - 5*dy, py, dy)
			if #digOutPositions < 5 then
				addDigOutArea(surface, digOutPositions, px, targetPosition.x, dx, py, targetPosition.y, dy)
			end
			if #digOutPositions == 0 then
				digOutPositions[1] = {x = targetPosition.x, y = targetPosition.y, slowdown = false}
				surface.set_tiles({{name = "landfill", position = {digOutPositions[1].x, digOutPositions[1].y}}},true,true,true,true)
			end
		else
			-- a cross of 4 rays, 5 tiles each (the old loop added every ray tile 5 times)
			for d = 1, 5 do
				for _, vector in pairs(sideVectors) do
					addDigOutPosition(surface, digOutPositions, px + d*vector[1], py + d*vector[2])
				end
			end
			if #digOutPositions == 0 then
				digOutPositions[1] = {x = px, y = py, slowdown = false}
				surface.set_tiles({{name = "landfill", position = {digOutPositions[1].x, digOutPositions[1].y}}},true,true,true,true)
			end
		end
		-------------------
		
		
		group = squad.group
	
		local undergroundTotal = 0
		local unitsInTile = 999
		local digOutIndex
		local digOutPosition
	
		for member, quality_count in pairs (members) do
			local entityName = sGsub(member, "nuclear", "suicide")	-- nuclear biters --> suicide biters
			if prototypes.entity[entityName] then	-- once per unit name (was a prototype query per unit)
				for quality, count in pairs (quality_count) do
					-- quality names; saves made before 9.02.14 may hold prototype objects or false here
					local qualityName
					if type(quality) == "string" then
						qualityName = quality
					elseif quality and quality.valid then
						qualityName = quality.name
					end
					local left = count
					while (left > 0) and (undergroundTotal < DIG_OUT_AT_ONCE) do
						if unitsInTile > 5 then
							unitsInTile = 0
							digOutIndex, digOutPosition = next(digOutPositions, digOutIndex)
							if not digOutIndex then
								digOutIndex, digOutPosition = next(digOutPositions, nil)
							end
						end
						left = left - 1
						local newEntity = surface.create_entity({
							name = entityName,
							position = {digOutPosition.x, digOutPosition.y},
							quality = qualityName,
							force = "enemy",
							})
						if newEntity and newEntity.valid then
							unitsInTile = unitsInTile + 1
							group.add_member(newEntity)

							newEntity.destructible = false
							universe.oneTickImmunityUnits[#universe.oneTickImmunityUnits+1] = {entity = newEntity, tick = game.tick + 1}
							undergroundTotal = undergroundTotal + 1

							if digOutPosition.slowdown then
								surface.create_entity({name = slowdownStickerName, position = {digOutPosition.x, digOutPosition.y}, target = newEntity})
							end

							if digOutPosition.healthRate then
								newEntity.health = newEntity.max_health * digOutPosition.healthRate
							end
						end
					end
					if left > 0 then
						-- over the limit: the rest comes out gradually (was one more unit per name and quality)
						queuedMembers[#queuedMembers + 1] = {
							count = left,
							name = entityName,
							position = {x = digOutPosition.x, y = digOutPosition.y},
							quality = qualityName,
							force = "enemy"
							}
						decomressLater = true
					end
				end
			end
		end
				
		if undergroundTotal > 0 then
			undergroundAttack.drawDigOutDust(surface, undergroundSquad.position)
			universe.squadCount = universe.squadCount + 1
            universe.groupNumberToSquad[squad.groupNumber] = squad
			squad.nextCommandTick = game.tick + 1800
			group.set_command({
				type = defines.command.compound,
				structure_type = defines.compound_command.return_last,
				commands = {
						{type = defines.command.wander,  ticks_to_wait = 1},
						{
							type = defines.command.attack_area,
							destination  = {x = undergroundSquad.position.x, y = undergroundSquad.position.y},
							distraction = defines.distraction.by_damage,
							radius = 32
						}
					}	
				})
			squad.onTheWay = true
			
			if undergroundSquad.digOutTick then	-- do not alert if "soft" ground
				local entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})
				showAlert(surface, entity, "undergroundDigout-warning-rampant",
				{"", {"description.rampantFixed--undergroundAttackDetectedWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .. "," .. map.surface.name .. "]")}				
				)
			end	
			
			if decomressLater then
				universe.decomressQueue[group] = queuedMembers
			end
		else
			group.destroy()	-- nothing came out: the empty group would stay
			squad = nil
		end	
		universe.undergroundSquads[undergroundSquad.groupNumber] = nil
	end
	
	
	return squad
end

-- a random target in a few random player chunks (was a search of the whole surface)
local function getRandomUndergroundTarget(map)
	local chunks = {}
	for chunk in pairs(map.chunkToPlayerBase) do
		chunks[#chunks + 1] = chunk
	end
	local count = #chunks
	if count == 0 then
		return nil
	end
	local surface = map.surface
	local query = playerRandomUndergroundTarget_Query
	local area = query.area
	for _ = 1, mMin(RANDOM_TARGET_TRIES, count) do
		local chunk = chunks[mRandom(count)]
		area[1][1] = chunk.x
		area[1][2] = chunk.y
		area[2][1] = chunk.x + 32
		area[2][2] = chunk.y + 32
		local entities = surface.find_entities_filtered(query)
		if #entities > 0 then
			return entities[mRandom(#entities)]
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

-- deadEntity (optional): the unit being killed (on_entity_died) - only the rest of its pack goes underground.
-- Champions, Big Monsters enemies and non-unit members stay above ground. Returns nil (and keeps the group) if no unit would dig in.
function undergroundAttack.createUndergroudAttack(map, squad, deadEntity)
	if (not squad) then
		return
	end
    local group = squad.group
	if not (group and group.valid) then
		return
	end	
	local universe = map.universe
	local compressedUnits = universe.compressedUnits
	local champions = championUnits(universe)

    local surface = map.surface
	local squadMembers = {total = 0, members = {}}
	local members = squadMembers.members
	local dustCloudPositions = {}
	local diggers = {}
	for _, entity in pairs(group.members) do
		if entity.valid and (entity.type == "unit") then
			local unitNumber = entity.unit_number
			if not (champions and champions[unitNumber]) and not isForeign(entity.name) then
				local compressedUnit = compressedUnits[unitNumber]
				local count = (compressedUnit and compressedUnit.count) or 1
				if entity == deadEntity then
					count = count - 1
				else
					diggers[#diggers + 1] = entity
				end
				if compressedUnit then
					compressedUnits[unitNumber] = nil
				end
				if count > 0 then
					local entityIndex = entity.name
					local quality = entity.quality.name
					local byQuality = members[entityIndex]
					if not byQuality then
						byQuality = {}
						members[entityIndex] = byQuality
					end
					byQuality[quality] = (byQuality[quality] or 0) + count
					squadMembers.total = squadMembers.total + count
				end
			end
		end
	end
	if squadMembers.total == 0 then
		return nil
	end
	for i = 1, #diggers do
		local entity = diggers[i]
		local position = entity.position
		dustCloudPositions["x" .. math.ceil(position.x) .. "y" .. math.ceil(position.y)] = position
		entity.destroy()
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
	-- squad will be deleted in squadAttack.processSquads
	return undergroundSquad
end

-- a squad unit killed by artillery or from afar: the squad may dig in. Returns true if it did
function undergroundAttack.onUnitKilled_DigIn(map, entity, cause)
	if not map.hasNonmoddedBiters then
		return false
	end	
	if (not entity) or not (entity.valid) then
		return false
	end
	local commandable = entity.commandable
	local group = commandable and commandable.parent_group
	if (not group) or (not group.is_unit_group) then
		return false
	end	
	local squad = map.universe.groupNumberToSquad[group.unique_id]		-- or universe.nonRampantCompressedSquads[group.unique_id]
	-- flights stay in the air (FlyerAI)
	if (not squad) or squad.flight or squad.rabid or squad.frenzy or squad.hasSpiders then
		return false
	end
	local roll = math.random()
	if roll < 0.2 then
		squad.undergoundAttack = "randomTarget"
	elseif (roll < 0.6) or not (cause and cause.valid) then
		squad.undergoundAttack = "common"
	else
		squad.undergoundAttack = "position"	
		local position = cause.position
		squad.targetPosition = {x = position.x, y = position.y}
	end
	return undergroundAttack.createUndergroudAttack(map, squad, entity) ~= nil
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
	if undergroundSquad.digOutTick then
		if (game.tick < undergroundSquad.digOutTick) then
			showFlyingText({text = tostring(undergroundSquad.squadMembers.total).." [entity=big-biter]", surface = surface, position = undergroundSquad.position, color = {1, 0, 0}, speed  = 1.5, time_to_live = 30})		
			return
		else
			digOut(undergroundSquad)		
			return
		end
	end
	
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
		if not undergroundSquad.detected then
			if not map.universe.firtstUndergroundAlertShown then
				local chunkX = math.floor(undergroundSquad.position.x / 32)
				local chunkY = math.floor(undergroundSquad.position.y / 32)
				if game.forces["player"].is_chunk_visible(surface, {x = chunkX, y = chunkY}) then
					game.print({"", {"description.rampantFixed--firstUndergroundAttackWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y  .. "," .. map.surface.name .."]")})
					map.universe.firtstUndergroundAlertShown = true
					undergroundSquad.detected = true
				end
			else
				local tile = surface.get_tile(undergroundSquad.position.x, undergroundSquad.position.y)
				if tile.prototype.walking_speed_modifier >= 1.5 then
					local entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})
					undergroundSquad.detected = showAlert(surface, entity, "undergroundPass-warning-rampant", 
						{"", {"description.rampantFixed--undergroundAttackDetectedWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .. "," .. map.surface.name .. "]")}
						)
					return
				end
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
		local map = undergroundSquad.map
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


function undergroundAttack.updateUndergroundAttackProbability(map)
	if not map.universe.undergroundAttack then
		return
	end
	if not map.hasNonmoddedBiters then
		map.undergroundAttackProbability = 0
		return
	end	
	
	local newUndergroundAttackProbability
	local evolution_factor = game.forces.enemy.get_evolution_factor(map.surface)
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
	if map.undergroundAttackProbability == 0 then
		map.undergroundAttackProbability = newUndergroundAttackProbability
		if (newUndergroundAttackProbability > 0) and not map.universe.firtstUndergroundAlertShown then	-- firtstUndergroundAlertShown - sometimes 1st attack occurs early (exmpl: long range squadkilling), so do not warn again
			game.print({"description.rampantFixed--undergroundAttackWarning", map.surface.name})
			game.print({"description.rampantFixed--undergroundAttackWarning2"})
		end
	else	
		map.undergroundAttackProbability = math.max(newUndergroundAttackProbability, 0.0001)
	end
end	

undergroundAttackG = undergroundAttack
return undergroundAttack
