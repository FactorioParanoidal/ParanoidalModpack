if (undergroundAttackG) then
    return undergroundAttackG
end
local undergroundAttack = {}

local customAlerts = require("CustomAlerts")
local mapUtils = require("libs/MapUtils")
local mathUtils = require("libs/MathUtils")
local scoreChunks = require("ScoreChunks")
local unitGroupUtils = require("libs/UnitGroupUtils")

local positionToChunkXY = mapUtils.positionToChunkXY
local getChunkListInRange = mapUtils.getChunkListInRange
local getChunkByXY = mapUtils.getChunkByXY
local showAlert = customAlerts.showAlert
local scoreAttackLocation = scoreChunks.scoreAttackLocation
local createSquad = unitGroupUtils.createSquad

local mRandom = math.random

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
			
			entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})			
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
					if tile and (not tile.collides_with("player")) then
						local healthRate
						if tile.prototype.walking_speed_modifier >= 1.3 then
							if tile.prototype.walking_speed_modifier >= 2 then
								healthRate = 0.5
							else
								healthRate = 0.5 + 0.5 * (2 - tile.prototype.walking_speed_modifier) / 0.7
							end
						end
						digOutPositions[#digOutPositions+1] = {x = x, y = y, slowdown = (tile.prototype.walking_speed_modifier >= 1.5), healthRate = healthRate}
						-- if tile.prototype.walking_speed_modifier >= 1.5 then
							-- removeConcreteTile(surface, tile)
						-- end
					end
				end
			end
			
			if #digOutPositions < 5 then
				for x = undergroundSquad.position.x, targetPosition.x, dx do
					for y = undergroundSquad.position.y, targetPosition.y, dy do
						local tile = surface.get_tile({x , y})
						if tile and (not tile.collides_with("player")) then
							local healthRate
							if tile.prototype.walking_speed_modifier >= 1.3 then
								if tile.prototype.walking_speed_modifier >= 2 then
									healthRate = 0.5
								else
									healthRate = 0.5 + 0.5 * (2 - tile.prototype.walking_speed_modifier) / 0.7
								end
							end
							digOutPositions[#digOutPositions+1] = {x = x, y = y, slowdown = (tile.prototype.walking_speed_modifier >= 1.5), healthRate = healthRate}
							-- if tile.prototype.walking_speed_modifier >= 1.5 then
								-- removeConcreteTile(surface, tile)
							-- end
						end
					end
				end			
			end
			
			if #digOutPositions == 0 then
				digOutPositions[1] = {x = targetPosition.x, y = targetPosition.y, slowdown = false}
				surface.set_tiles({{name = "landfill", position = {digOutPositions[1].x, digOutPositions[1].y}}},true,true,true,true)
			end
			
		else

			for dx = 1, 5 do
				for dy = 1, 5 do
					for _, vector in pairs(sideVectors) do
						local x = undergroundSquad.position.x + dx*vector[1]
						local y = undergroundSquad.position.y + dx*vector[2]
						local tile = surface.get_tile({x, y})
						if tile and (not tile.collides_with("player")) then
							local healthRate
							if tile.prototype.walking_speed_modifier >= 1.3 then
								if tile.prototype.walking_speed_modifier >= 2 then
									healthRate = 0.5
								else
									healthRate = 0.5 + 0.5 * (2 - tile.prototype.walking_speed_modifier) / 0.7
								end
							end
							digOutPositions[#digOutPositions+1] = {x = x, y = y, slowdown = (tile.prototype.walking_speed_modifier >= 1.5), healthRate = healthRate}
							-- if tile.prototype.walking_speed_modifier >= 1.5 then
								-- removeConcreteTile(surface, tile)
							-- end
						end
					end	
				end
				if #digOutPositions == 0 then
					digOutPositions[1] = {x = undergroundSquad.position.x, y = undergroundSquad.position.y, slowdown = false}
					surface.set_tiles({{name = "landfill", position = {digOutPositions[1].x, digOutPositions[1].y}}},true,true,true,true)
				end
			end
		
		end
		-------------------
		
		
		group = squad.group
	
		local undergroundTotal = 0
		local unitsInTile = 999
		local digOutIndex
		local digOutPosition
	
		for member, quality_count in pairs (members) do
			for quality, count in pairs (quality_count) do
				if count > 0 then
					for i = 1, count do
						if unitsInTile > 5 then
							unitsInTile = 0
							digOutIndex, digOutPosition = next(digOutPositions, digOutIndex)
							if not digOutIndex then
								digOutIndex, digOutPosition = next(digOutPositions, nil)
							end
						end	
						local entityName = string.gsub(member, "nuclear", "suicide")	-- nuclear biters --> suicide biters
						local prototypeList = prototypes.get_entity_filtered({{filter = "name", name = entityName}})
						
						if prototypeList and (#prototypeList>0) then
							local newEntity = surface.create_entity({
								name = entityName,
								position = {digOutPosition.x, digOutPosition.y},
								quality = (quality or nil),
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
								
								if undergroundTotal >= 200 then
									queuedMembers[newEntity.unit_number] = {
										count = count - i,
										name = entityName,
										position = {x = newEntity.position.x, y = newEntity.position.y}, 
										direction = newEntity.direction,
										quality = (quality or nil),
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
				entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})			
				showAlert(surface, entity, "undergroundDigout-warning-rampant",
				{"", {"description.rampantFixed--undergroundAttackDetectedWarning"},": ", ("[gps=" .. undergroundSquad.position.x .. "," .. undergroundSquad.position.y .. "," .. map.surface.name .. "]")}				
				)
			end	
			
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
			if (entity.type == "unit") then
				local positionIndex = "x"..math.ceil(entity.position.x).."y"..math.ceil(entity.position.y)
				local entityIndex = entity.name
				local quality
				if entity.quality and entity.quality.valid then
					quality = entity.quality
				else
					quality = false
				end
				if not members[entityIndex] then
					members[entityIndex] = {}
				end
				local compressedUnit = compressedUnits[entity.unit_number]
				if compressedUnit then
					members[entityIndex][quality] = (members[entityIndex][quality] or 0) + compressedUnit.count
					squadMembers.total = squadMembers.total + compressedUnit.count
					
					compressedUnits[entity.unit_number] = nil
				else
					members[entityIndex][quality] = (members[entityIndex][quality] or 0) + 1
					squadMembers.total = squadMembers.total + 1
				end
				dustCloudPositions[positionIndex] = {x = entity.position.x, y = entity.position.y}
			end	
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
	-- squad will be deleted in squadAttack.processSquads
	return undergroundSquad
end

function undergroundAttack.onUnitKilled_DigIn(map, entity, cause)
	if not map.hasNonmoddedBiters then
		return
	end	
	if (not entity) or not (entity.valid) then
		return
	end
	local group = (entity.commandable and entity.commandable.parent_group)
	if (not group) or (not group.is_unit_group) then
		return
	end	
	local squad = map.universe.groupNumberToSquad[group.unique_id]		-- or universe.nonRampantCompressedSquads[group.unique_id]
	if (not squad) or squad.rabid or squad.frenzy then
		return
	end
	if squad.hasSpiders then
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
					entity = surface.create_entity({name = "undeground-dust-cloud-rampant", position = {undergroundSquad.position.x, undergroundSquad.position.y}})			
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
		if newUndergroundAttackProbability > 0 then
			game.print({"description.rampantFixed--undergroundAttackWarning", map.surface.name})
			game.print({"description.rampantFixed--undergroundAttackWarning2"})
		end
	else	
		map.undergroundAttackProbability = math.max(newUndergroundAttackProbability, 0.0001)
	end
end	

undergroundAttackG = undergroundAttack
return undergroundAttack
