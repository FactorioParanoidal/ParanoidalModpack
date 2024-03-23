if baseUtilsG then
    return baseUtilsG
end
local baseUtils = {}

-- imports

local mathUtils = require("MathUtils")
local constants = require("Constants")
local chunkPropertyUtils = require("ChunkPropertyUtils")
local mapUtils = require("MapUtils")

-- constants

local FACTION_CHANGING_MAPPING = constants.FACTION_CHANGING_MAPPING
local FACTION_EVOLVE_MAPPING = constants.FACTION_EVOLVE_MAPPING

local MAGIC_MAXIMUM_NUMBER = constants.MAGIC_MAXIMUM_NUMBER

local BASE_AI_STATE_ACTIVE = constants.BASE_AI_STATE_ACTIVE
local BASE_AI_STATE_MUTATE = constants.BASE_AI_STATE_MUTATE
local BASE_EVOLVE_THRESHOLD = constants.BASE_EVOLVE_THRESHOLD
local GLOBAL_EVOLVE_COOLDOWN = constants.GLOBAL_EVOLVE_COOLDOWN

local FACTION_SET = constants.FACTION_SET

local BASE_DEADZONE_TTL = constants.BASE_DEADZONE_TTL

local BASE_AI_MIN_STATE_DURATION = constants.BASE_AI_MIN_STATE_DURATION
local BASE_AI_MAX_STATE_DURATION = constants.BASE_AI_MAX_STATE_DURATION

local HIVE_BUILDINGS_COST = constants.HIVE_BUILDINGS_COST

local BASE_DISTANCE_THRESHOLD = constants.BASE_DISTANCE_THRESHOLD
local BASE_DISTANCE_LEVEL_BONUS = constants.BASE_DISTANCE_LEVEL_BONUS
local BASE_DISTANCE_TO_EVO_INDEX = constants.BASE_DISTANCE_TO_EVO_INDEX

local BASE_COLLECTION_THRESHOLD = constants.BASE_COLLECTION_THRESHOLD

local CHUNK_SIZE = constants.CHUNK_SIZE

-- imported functions

local randomTickEvent = mathUtils.randomTickEvent
local euclideanDistancePoints = mathUtils.euclideanDistancePoints

local getChunkByPosition = mapUtils.getChunkByPosition

local gaussianRandomRange = mathUtils.gaussianRandomRange

local linearInterpolation = mathUtils.linearInterpolation

local mFloor = math.floor

local mMin = math.min
local mMax = math.max
local distort = mathUtils.distort

local getChunkBase = chunkPropertyUtils.getChunkBase
local setChunkBase = chunkPropertyUtils.setChunkBase
local getResourceGenerator = chunkPropertyUtils.getResourceGenerator
local getNestCount = chunkPropertyUtils.getNestCount
local getHiveCount = chunkPropertyUtils.getHiveCount
local getTurretCount = chunkPropertyUtils.getTurretCount
local getEnemyStructureCount = chunkPropertyUtils.getEnemyStructureCount
local getNestActiveness = chunkPropertyUtils.getNestActiveness

local next = next

local mRandom = math.random

-- module code

local function evoToTier(universe, evolutionFactor)
    local v
   for i=10,1,-1 do
        if universe.evoToTierMapping[i] <= evolutionFactor then
            v = i
            if mRandom() <= 0.65 then
                break
            end
        end
    end
    return v
end

-- + !КДА 2021.11
local function evoToTierNorandom(universe, evolutionFactor)
    local v
    for i=10,1,-1 do
        if universe.evoToTierMapping[i] <= evolutionFactor then
            v = i
            break
        end
    end
    return v
end
-- - !КДА 2021.11

function baseUtils.findNearbyBase(map, chunk, maxDistance, baseChangingChance)	
    local x = chunk.x
    local y = chunk.y

 	local closest = MAGIC_MAXIMUM_NUMBER	
	local foundBase = getChunkBase(map, chunk)
	if not foundBase then
		if baseChangingChance and (mRandom() < baseChangingChance) then
			return nil
		else
			local bases = map.universe.bases
			local basesScanned = 0
			for i, base in pairs(bases) do
				if base.mapIndex == map.surface.index then
					basesScanned = basesScanned + 1
					local distance = euclideanDistancePoints(base.x, base.y, x, y)
					if (distance <= base.distanceThreshold) and (distance < closest) then
						closest = distance
						foundBase = bases[i]	--base
					end
				end	
			end
			if maxDistance and (closest > maxDistance) then
				foundBase = nil
			end
		end	
	end
    return foundBase
end

-- + !КДА 2021.11
-- return faction name.
local function getFactionFromAligment(baseAlignment)
	if not baseAlignment then
		return "neutral"
	end	
	local factions = {}
	local factionTotal = 0
	local ratesTotal = 0
	for faction, rate in pairs(baseAlignment) do
		factionTotal = factionTotal + 1
		factions[factionTotal] = faction
		ratesTotal = ratesTotal + mMax(rate,0)
	end
	if factionTotal == 0 then
		return "neutral"
	end	
	if factionTotal == 1 then
		return factions[1]
	end
	
    local roll = mRandom()*ratesTotal
	for faction, rate in pairs(baseAlignment) do
		roll = roll - mMax(rate,0)
        if (roll <= 0) then
			return faction
		end	
	end
	return factions[1]
end
-- - !КДА 2021.11

-- return faction name. "neutral", "troll, etc..
local function findBaseMutation(map, targetEvolution, targetTier)
    local universe = map.universe
	local tier
	if targetTier then
		tier = targetTier
	else	
		tier = evoToTierNorandom(universe, targetEvolution or map.evolutionLevel)	
	end	
	
    local alignments = universe.evolutionTableAlignment[tier]
    local roll = mRandom()
    for i=1,#alignments do
        local alignment = alignments[i]

        roll = roll - alignment[1]

        if (roll <= 0) then
			return alignment[2]
        end
    end
    return (alignments[#alignments] or "neutral")
end

-- example: exceptFactions = {"neutral", "acid"}
-- alignments[x] = {0.2, "neutral"}...
-- filteredAligments{neutral = 0.2, acid = 0.1, ...}
-- mutationRates = {n1, n2,...}	==> return {faction1 = n1, faction2 = n2,...} 
-- return {troll = 1, electic = 1,...}
local function findBaseMutations(map, targetEvolution, targetTier, mutationCount, mutationRates,exceptFactions)
    local universe = map.universe
	local tier
	if targetTier then
		tier = targetTier
	else	
		tier = evoToTierNorandom(universe, targetEvolution or map.evolutionLevel)	
	end	
    local alignments = universe.evolutionTableAlignment[tier]

	local filteredAligments = {}
	local aligmentsCount = 0
	local ratesSum = 0
    for i=1,#alignments do
        local alignment = alignments[i]
		local FactionEnabled = true
		if exceptFactions then
			for u=1,#exceptFactions do
				if alignment[2] == exceptFactions[u] then
					FactionEnabled = false
					break
				end
			end
		end			
		if FactionEnabled then
			aligmentsCount = aligmentsCount + 1
			ratesSum = ratesSum + alignment[1]
			filteredAligments[alignment[2]] = alignment[1]
		end	
	end

	
	local maxMutations = 1
	if mutationCount then
		maxMutations = mutationCount
	end
	local result = {}
	for u = 1, maxMutations do
		local roll = mRandom()*ratesSum
		for faction, rate in pairs(filteredAligments) do
			local alignment = alignments[i]
			roll = roll - filteredAligments[faction]
			if (roll <= 0) then
				if mutationRates and mutationRates[u] then
					result[faction] = mutationRates[u]
				else
					result[faction] = 1
				end	
				
				aligmentsCount = aligmentsCount - 1
				ratesSum = ratesSum - filteredAligments[faction]
				filteredAligments[faction] = nil
				break
			end
		end	
		if aligmentsCount == 0 then
			break
		end	
	end
	return result
end
 
local function initialEntityUpgrade(faction, tier, maxTier, map, useHiveType)
    local evolutionTable = map.universe.buildingEvolveLookup
    local entity

    local useTier

    local tierRoll = mRandom()
    if (tierRoll < 0.4) then
        useTier = maxTier
    elseif (tierRoll < 0.7) then
        useTier = mMax(maxTier - 1, tier)
    elseif (tierRoll < 0.9) then
        useTier = mMax(maxTier - 2, tier)
    else
        useTier = mMax(maxTier - 3, tier)
    end

	local upgradesTier = evolutionTable[faction]
	if not upgradesTier then
		upgradesTier = evolutionTable["neutral"]
	end
    local upgrades = upgradesTier[useTier]

    if upgrades then
        if useHiveType then
            for ui=1,#upgrades do
                local upgrade = upgrades[ui]
                if upgrade[3] == useHiveType then
                    entity = upgrade[2][mRandom(#upgrade[2])]
                    break
                end
            end
        end
        if not entity then
            local roll = mRandom()

            for ui=1,#upgrades do
                local upgrade = upgrades[ui]

                roll = roll - upgrade[1]

                if (roll <= 0) then
                    entity = upgrade[2][mRandom(#upgrade[2])]
                    break
                end
            end
        end
   end
	
    return entity
end

local function entityEvolve(originalEntity, map)
    local universe = map.universe
    local hiveType = universe.buildingHiveTypeLookup[originalEntity.name]
	if not hiveType then
		return originalEntity.name		
	end	
	local mapTypes = FACTION_EVOLVE_MAPPING[hiveType]			
	if not mapTypes then
		return originalEntity.name
	end	
	
	local faction = universe.enemyAlignmentLookup[originalEntity.name]
	if not faction then		
		return originalEntity.name
	end
	
	local tier = universe.buildingTierLookup[originalEntity.name]
	if not tier then		
		return originalEntity.name
	end


    local evolutionTable = map.universe.buildingEvolveLookup
	local upgradesTier = evolutionTable[faction]
	if not upgradesTier then
		upgradesTier = evolutionTable["neutral"]
	end
    local upgrades = upgradesTier[tier]
    if not upgrades then
		return originalEntity.name		
	end

	-- example: evolutionTable["troll"][3][1]={0.1, buildingSet, "biter-spawner"}	(tier 3)
	
	local factionUpgrades = {}
	local ratesSum = 0
	for i=1, #upgrades do
		local upgrade = upgrades[i]
		if mapTypes[upgrade[3]] then
			ratesSum = ratesSum + upgrade[1]
			factionUpgrades[#factionUpgrades+1] = {upgrade[1], upgrade[2], upgrade[3]}
		end
	end
	local initRoll = mRandom()*ratesSum
	local roll = initRoll + 0
	for i = 1,#factionUpgrades do 
		local upgrade = factionUpgrades[i]
		roll = roll - upgrade[1]
		if roll<=0 then
			local buildingSet = upgrade[2]
--			if (upgrade[3]~= hiveType) and (oldFaction==faction) then
--				game.print("entityUpgrade---------------start")
				-- for u = 1,#factionUpgrades do 
					-- game.print(""..u..":"..factionUpgrades[u][1].."," .. factionUpgrades[u][3]..( (u == 1 and "<--here") or ""))				
				-- end
--				game.print("entityUpgrade---------------end")
--			end
			return buildingSet[mRandom(#buildingSet)]
		end
	end

	return originalEntity.name		

end


local function entityUpgrade(faction, tier, maxTier, originalEntity, map)
	local universe = map.universe
    local hiveType = universe.buildingHiveTypeLookup[originalEntity.name]
	if not hiveType then
		return originalEntity.name		
	end	
	
	local oldFaction = universe.enemyAlignmentLookup[originalEntity.name]
	local mapTypes = {}
	if oldFaction==faction then
		 mapTypes[hiveType] = 0	
	else	
		mapTypes = FACTION_CHANGING_MAPPING[hiveType]			
		if not mapTypes then
			return originalEntity.name
		end	
	end	

    local useTier
	if tier == maxTier then
		useTier = maxTier
	else		
		local tierRoll = mRandom()
		if (tierRoll < 0.4) then
			useTier = maxTier
		elseif (tierRoll < 0.7) then
			useTier = mMax(maxTier - 1, tier)
		elseif (tierRoll < 0.9) then
			useTier = mMax(maxTier - 2, tier)
		else
			useTier = mMax(maxTier - 3, tier)
		end
	end	
	
    local evolutionTable = map.universe.buildingEvolveLookup
	if not evolutionTable[faction] then
		return originalEntity.name		
	end
    local upgrades = evolutionTable[faction][useTier]
    if not upgrades then
		return originalEntity.name		
	end
	
	-- example: evolutionTable["troll"][3][1]={0.1, buildingSet, "biter-spawner"}	(tier 3)
	local factionUpgrades = {}
	local ratesSum = 0
	for i=1, #upgrades do
		local upgrade = upgrades[i]
		if mapTypes[upgrade[3]] then
			ratesSum = ratesSum + upgrade[1]
			factionUpgrades[#factionUpgrades+1] = {upgrade[1], upgrade[2], upgrade[3]}
		end
	end
	local initRoll = mRandom()*ratesSum
	local roll = initRoll + 0
	for i = 1,#factionUpgrades do 
		local upgrade = factionUpgrades[i]
		roll = roll - upgrade[1]
		if roll<=0 then
			local buildingSet = upgrade[2]
--			if (upgrade[3]~= hiveType) and (oldFaction==faction) then
--				game.print("entityUpgrade---------------start")
				-- for u = 1,#factionUpgrades do 
					-- game.print(""..u..":"..factionUpgrades[u][1].."," .. factionUpgrades[u][3]..( (u == 1 and "<--here") or ""))				
				-- end
--				game.print("entityUpgrade---------------end")
--			end
			return buildingSet[mRandom(#buildingSet)]
		end
	end
	return originalEntity.name		
end

local function findEntityUpgrade(faction, currentEvo, evoIndex, originalEntity, map, evolve)
    local universe = map.universe
    local adjCurrentEvo = mMax(
        ((faction ~= universe.enemyAlignmentLookup[originalEntity.name]) and 0) or currentEvo,
        0
    )

    local tier = evoToTier(universe, adjCurrentEvo)
    local maxTier = evoToTierNorandom(universe, evoIndex)

    if (tier > maxTier) then
		tier = maxTier
--        return nil
    end

    if evolve then
        local chunk = getChunkByPosition(map, originalEntity.position)
		local makeHive = false
		if not chunk == -1 then
			if getResourceGenerator(map, chunk) > 0 then 
				if mRandom() < 0.2 then
					makeHive = true
				end
			else 	
				if mRandom() < 0.02 then
					makeHive = true
				end
			end
		end	
		return initialEntityUpgrade(faction, tier, maxTier, map, (makeHive and "hive"))
    else
        return entityUpgrade(faction, tier, maxTier, originalEntity, map)
    end
end

local function findBaseInitialAlignment(map, evoIndex)
    local dev = evoIndex * 0.3
	local evoTop = evoIndex

    local result
    if mRandom() < 0.05 then
        result = findBaseMutations(map, evoTop, nil, 2, {0.5, 0.5}) --{troll = 0.5, acid = 0.5}	-- + !КДА 2021.11
    else
		result = findBaseMutations(map, evoTop, nil, 2, {0.8, 0.2}) 
    end

    return result
end

function baseUtils.recycleBases(universe)
	if not universe.bases then
		return
	end
    local bases = universe.bases
	local id = universe.recycleBaseIterator
    if not id then
        id, base = next(bases, nil)
    end
    if not id then
        universe.recycleBaseIterator = nil
    else
		local base
		base = bases[id]
		if base then
			local map = universe.maps[base.mapIndex]
			if not map then
				universe.growingBases[id] = nil
				if universe.growingBasesIterator == id then
					universe.growingBasesIterator = nil
				end
				bases[id] = nil
				return
			end	
			for chunk, _ in pairs(base.chunks) do
				chunkBase = getChunkBase(map, chunk)
				if (not chunkBase) then
					setChunkBase(map, chunk, base)
					--game.print("restore lost chunk [gps=" .. chunk.x .. "," .. chunk.y .."] to base [gps=" .. base.x .. "," .. base.y .."]")	-- debug
				elseif chunkBase.id ~= base.id then
					base.chunks[chunk] = nil
					chunkBase.chunks[chunk] = true
					--game.print("reassign chunk [gps=" .. chunk.x .. "," .. chunk.y .."]".." from [gps=" .. base.x .. "," .. base.y .."] to [gps=" .. chunkBase.x .. "," .. chunkBase.y .."]")	-- debug
				end
			end
			
			local chunk = next(base.chunks, nil)
			if not chunk then
				--game.print("recycled base [gps=" .. base.x .. "," .. base.y .."]".. serpent.dump(base.chunks)) 	-- debug
				universe.growingBases[id] = nil
				if universe.growingBasesIterator == id then
					universe.growingBasesIterator = nil
				end
				map.basesToGrow[id] = nil
				bases[id] = nil
			end
		end	
        universe.recycleBaseIterator = next(bases, id)
    end
end


local function deleteAssociatedUnits(entity)
	if entity.valid and (entity.type == "unit-spawner") then
		if entity.units then
			for i, unit in pairs(entity.units) do
				if unit and unit.valid and (unit.type == "unit") and (not unit.unit_group) then
					unit.destroy()		--unit.die(unit.force)
				end
			end
		end
	end		
end

-- baseAlignment{fire = 0.8, acid = 0.2,...}
function baseUtils.upgradeEntity(entity, baseAlignment, map, disPos, evolve, addEntity)	
    local surface = map.surface
    local position = entity.position
    local currentEvo = (addEntity and 0) or entity.prototype.build_base_evolution_requirement or 0
    local universe = map.universe

	local faction
	if type(baseAlignment)=="string" then
		faction = baseAlignment
	else
		faction = getFactionFromAligment(baseAlignment)
	end

	if not faction then
		if not addEntity then
			entity.destroy()
		end	
		return nil
    end

    local distance = mMin(1, euclideanDistancePoints(position.x, position.y, 0, 0) * BASE_DISTANCE_TO_EVO_INDEX)
    local evoIndex = mMax(distance, map.evolutionLevel)	

    local spawnerName = findEntityUpgrade(faction,
                                          currentEvo,
                                          evoIndex,
                                          entity,
                                          map,
                                          evolve)
 	

   if spawnerName and (addEntity or (spawnerName~=entity.name)) then
		--game.print(entity.name.."->"..spawnerName.." [gps=" .. entity.position.x .. "," .. entity.position.y .."]")	-- debug
		if not addEntity then
			deleteAssociatedUnits(entity)
			entity.destroy()
		end	
        local name = universe.buildingSpaceLookup[spawnerName] or spawnerName
        local query = universe.upgradeEntityQuery		
        query.name = name		
        query.position = disPos or position

        if addEntity or (not surface.can_place_entity(query)) then
            local newPosition = surface.find_non_colliding_position(
                (addEntity and "chunk-scanner-squad-rampant") or name,
                disPos or position,
                CHUNK_SIZE,
                1,
                true
            )
			-- if addEntity then
				-- game.print(entity.name.."baseUtils.upgradeEntity: add source = "..entity.name .." [gps=" .. entity.position.x .. "," .. entity.position.y .."]")	-- debug			
			-- end
			if addEntity and not newPosition then
				return nil
			end	
            query.position = newPosition or disPos or position
        end

		query.name = spawnerName
        if remote.interfaces["kr-creep"] then
            remote.call("kr-creep", "spawn_creep_at_position", surface, query.position)
        end

        local newEntity = surface.create_entity(query)
		return newEntity

    end
    return nil
end

function baseUtils.evolveEntity(entity, map)
	if not entity.valid then		
		return nil
	end
	
	local oldName = entity.name
    local spawnerName = entityEvolve(entity, map)
    if spawnerName and (spawnerName~=oldName)then
		-- game.print("evolve "..entity.name.."-->"..spawnerName)  -- debug
		local surface = map.surface
		local position = entity.position
		local universe = map.universe

		deleteAssociatedUnits(entity)
        entity.destroy()
        local name = universe.buildingSpaceLookup[spawnerName] or spawnerName
        local query = universe.upgradeEntityQuery
        query.name = name
        query.position = position

        if not surface.can_place_entity(query) then
            local newPosition = surface.find_non_colliding_position(
                name,
                position,
                CHUNK_SIZE,
                1,
                true
            )
            query.position = newPosition or position
        end

		query.name = spawnerName
        if remote.interfaces["kr-creep"] then
            remote.call("kr-creep", "spawn_creep_at_position", surface, query.position)
        end
       return surface.create_entity(query)
	else   
		--game.print("cant evolve "..entity.name)
	end
   return nil
	

end

function baseUtils.changeEntityTier(entity, newTier, map)
    local surface = map.surface
    local position = entity.position
    local universe = map.universe
	
	local oldFaction = universe.enemyAlignmentLookup[entity.name]
	if not oldFaction then	
		return nil
	end
	local oldName = entity.name	
	--local tier = universe.buildingTierLookup[entity.name]
    local spawnerName = entityUpgrade(oldFaction, newTier, newTier, entity, map)
		
    if spawnerName and (spawnerName~=oldName)then
        local name = spawnerName
		local query = {}
        query.name = name
        query.position = position	--position
		query.move_stuck_players = true

		local NewEntity = surface.create_entity(query)  
		if NewEntity then
			deleteAssociatedUnits(entity)
			entity.destroy()
			return NewEntity		
		end	
	end
	return nil
	
		
    -- if not (spawnerName==oldName)then
        -- entity.destroy()
        -- local name = universe.buildingSpaceLookup[spawnerName] or spawnerName
        -- local query = universe.upgradeEntityQuery
        -- query.name = name
        -- query.position = position

        -- if not surface.can_place_entity(query) then
            -- local newPosition = surface.find_non_colliding_position(
                -- name,
                -- position,
                -- CHUNK_SIZE,
                -- 1,
                -- true
            -- )
            -- query.position = newPosition or position
        -- end

		-- query.name = spawnerName
        -- if remote.interfaces["kr-creep"] then
            -- remote.call("kr-creep", "spawn_creep_at_position", surface, query.position)
        -- end
		-- local newEntity = surface.create_entity(query)
		-- if newEntity.valid then
			-- return newEntity
		-- else
			-- return nil
		-- end		
   -- end
   -- return nil
	
end


function baseUtils.changeEntityAligment(entity, newAlignments, map)
	if not entity.valid then
		return nil	
	end
    local surface = map.surface
    local position = entity.position
    local universe = map.universe
	local newFaction
	if type(newAlignments)=="string" then
		newFaction = newAlignments
	else
		newFaction = getFactionFromAligment(newAlignments)
	end
    if not newFaction then		
        return nil
    end
	local oldFaction = universe.enemyAlignmentLookup[entity.name]
	if oldFaction == newFaction then
        return nil
    end
	
	local oldName = entity.name
	local tier = universe.buildingTierLookup[entity.name]
    local spawnerName = entityUpgrade(newFaction, tier, tier, entity, map)
    if spawnerName and (spawnerName~=oldName) then
        local name = spawnerName
		local query = {}
        query.name = name
        query.position = position	--position
		query.move_stuck_players = true

		local NewEntity = surface.create_entity(query)  
		if NewEntity then
			deleteAssociatedUnits(entity)
			entity.destroy()
			return NewEntity		
		end	
	end
   return nil
	
end
-- - !КДА 2021.11


local function replaceDeletedFactions(baseAlignment, map)
    local evolutionTable = map.universe.buildingEvolveLookup
	local factionsArray = {}
	local alignmentCount = 0
	for faction, rate in pairs(baseAlignment) do
		alignmentCount = alignmentCount + 1
		if not evolutionTable[faction] then
			factionsArray[#factionsArray+1] = faction
		end	
	end
	for i = 1,#factionsArray do
		alignmentCount = alignmentCount - 1
		baseAlignment[factionsArray[i]] = nil
--		game.print("Removeing deleted faction:"..factionsArray[i])
	end
	if alignmentCount == 0 then
		baseAlignment["neutral"] = 1
	end
end

local function baseAlignmentAsString(baseAlignment)
	local baseAlignmentAsString = ""
	for faction, rate in pairs(baseAlignment) do
		baseAlignmentAsString = baseAlignmentAsString..faction.."="..rate.."%, "
	end
	return baseAlignmentAsString
end

-- base.baseAlignment{troll = 0.7, acid = .3}
-- upgradeType = 0 - change rates: instant changes (changing base.alignment)
--	1 - change rates, allow change lowest rated faction: instant changes 
--	2 - change lowest rated faction: lasting changes (changing base.newAlignmentAndSteps)
--	3 - new aligments (new tier, for example): lasting changes
--  4 - new rates for same factions: lasting changes
local function upgradeBase(map, base, upgradeType)
	local RateStep = 0.05
	local result = false
	local oldAlignment
	if base.newAlignmentAndSteps then
		oldAlignment = base.newAlignmentAndSteps[2]
	else
		oldAlignment = base.alignment
	end
	local baseAlignment = base.alignment
	local baseTier = base.tier
	-- debug
	-- local alignmentStr = ""
	-- for faction, rate in pairs(oldAlignment) do
		-- alignmentStr = alignmentStr .. faction .. ": "..rate.."," 
	-- end
	--
	if (upgradeType == 0) or (upgradeType == 1) then		-- not used since v1.3. So, mistakes possible
		local factions = {}
		local factionTotal = 0
		for faction, rate in pairs(oldAlignment) do
			factionTotal = factionTotal + 1
			factions[factionTotal] = faction
		end
		if factionTotal>1 then
			local roll = mRandom(factionTotal)
			local roll2 = mRandom(factionTotal-1)			
			if roll2 >= roll then roll2 = roll2+1 end
			
			if (oldAlignment[factions[roll]] - RateStep) < 0.005 then	-- if rate too low, then do nothing or change faction
				if upgradeType == 1 then
					newFaction = findBaseMutation(map, nil, baseTier)
					if not oldAlignment[newFaction] then
						oldAlignment[newFaction] = oldAlignment[factions[roll]]
						oldAlignment[factions[roll]] = nil
						factions[roll] = newFaction	-- optional, but let it be
						result = true
					end
				end
			else
				oldAlignment[factions[roll]] = oldAlignment[factions[roll]] - RateStep
				oldAlignment[factions[roll2]] = oldAlignment[factions[roll2]] + RateStep
				result = true
			end				 
		end
	elseif upgradeType == 2 then
		local newFaction = findBaseMutation(map, nil, baseTier)
		if not oldAlignment[newFaction] then
			local oldFaction
			local newAlignmentAndSteps = {10, {}}
			local newAlignment = newAlignmentAndSteps[2]
			
			for faction, rate in pairs(oldAlignment) do
				newAlignment[faction] = rate
				if not oldFaction or rate<oldAlignment[oldFaction] then	-- looking for lowest rate
					oldFaction = faction
				end	
			end
			if oldFaction then
				if not newAlignment[newFaction] then
					newAlignment[newFaction] = newAlignment[oldFaction]
					newAlignment[oldFaction] = nil
					base.newAlignmentAndSteps = newAlignmentAndSteps
					result = true
				end
			end	
		end			

	elseif upgradeType == 3 then
		local factionTotal = 0
		local factionRates = {}
		for faction, rate in pairs(oldAlignment) do
			factionTotal = factionTotal + 1
			factionRates[factionTotal] = rate
		end
		base.newAlignmentAndSteps = {30, findBaseMutations(map, nil, baseTier, factionTotal, factionRates)}
		result = true
	elseif upgradeType == 4 then
		local newAlignmentAndSteps = {30, {}}
		local newAlignment = newAlignmentAndSteps[2]
		local ratesTotal = 0
		for faction, rate in pairs(oldAlignment) do
			newAlignment[faction] = mRandom(1, 10)
			ratesTotal = ratesTotal + newAlignment[faction]
		end
		
		local finalRatesTotal = 0
		for faction, rate in pairs(newAlignment) do
			newAlignment[faction] = math.floor(100* newAlignment[faction] / ratesTotal) * 0.01
			finalRatesTotal = finalRatesTotal + newAlignment[faction]
		end
		
		local faction = next(newAlignment, nil)
		if faction then
			newAlignment[faction] = newAlignment[faction] + (1 - finalRatesTotal)
			base.newAlignmentAndSteps = newAlignmentAndSteps
			result = true		
		end
	end
	
	-- debug
	-- local newAlignmentDebug
	-- if base.newAlignmentAndSteps then
		-- newAlignmentDebug = base.newAlignmentAndSteps[2]
	-- else
		-- newAlignmentDebug = base.baseAlignment
	-- end
	-- if newAlignmentDebug then
		-- alignmentStr = alignmentStr.."->"
		-- for faction, rate in pairs(newAlignmentDebug) do
			-- alignmentStr = alignmentStr .. faction .. ": "..rate.."," 
		-- end
		-- game.print("upgradeBase #"..base.id..", type = " ..upgradeType.." "..alignmentStr.." [gps=" .. base.x .. "," .. base.y .."]")
		-- alignmentStr = ""
		-- for chunk, _ in pairs(base.chunks) do
			-- alignmentStr = alignmentStr .. "[gps=" .. chunk.x .. "," .. chunk.y .."]"
		-- end
		-- game.print(alignmentStr)
	-- end
	return result
end

local function updateBaseFactionsTotal(base)
	local factionsTotal = {}
	local totalCount = 0
	for chunk, counts in pairs(base.chunkFactions) do
		for faction,count in pairs(counts) do
			if count>0 then			
				factionsTotal[faction] = (factionsTotal[faction] or 0) + count
				totalCount = totalCount + count
			end	
		end
	end
	base.factionsTotal = {totalCount, factionsTotal}

end


local function calculateDynamicRates(dynamicRates, factionsTotal)
	if not factionsTotal then
		return
	end
	local totalDynamicRate = 0
	local changesCnt = 0	-- recommended changes
	local obsoleteCnt = 0
	local dynamicRatesTable	= dynamicRates.dynamicRatesTable
	dynamicRatesTable.dynamicRate = {}
	local fieldRate = dynamicRatesTable.rate
	local fieldDynamicRate = dynamicRatesTable.dynamicRate
	local fieldReqCount = dynamicRatesTable.reqCount
	
	for faction,rates in pairs(fieldRate) do
		fieldDynamicRate[faction] = fieldReqCount[faction] - (factionsTotal[faction] or 0)
		local dynamicRate = fieldDynamicRate[faction]
		if dynamicRate>0 then 
			totalDynamicRate = totalDynamicRate + dynamicRate
		end	
		changesCnt = changesCnt + mMax(mFloor(dynamicRate), 0)
		if (fieldRate[faction] or 0) <=0 and (factionsTotal[faction] or 0)>0 then
			obsoleteCnt = obsoleteCnt + 1
		end	
	end
	if totalDynamicRate == 0 then totalDynamicRate = 1 end
	dynamicRates.totalDynamicRate = totalDynamicRate
	dynamicRates.changesCnt = changesCnt
	dynamicRates.obsoleteCnt = obsoleteCnt
end

-- return {totalRate=N, totalDynamicRate=N, changesCnt=N, obsoleteCnt=N, dynamicRatesTable={rate={},reqCount = {},dynamicRate = {}})
-- example : base.factionsTotal{{"acid",7},{"fire", 3}}, base.alignment{{"acid",0.8},{"troll",0.2}}
-- => totalCount=10, totalRate = 1
-- => dynamicRatesTable["reqCount"] = {acid = 10*(0.8/1)=8, troll = 10*(0.2/1)=2, fire = 10*0=0 }
-- => dynamicRatesTable["dynamicRate"] = {acid = 8-7=1, troll = 2 - 0 = 2, fire = 0-3 =>0 } , totalDynamicRate = 1+2=3 
-- => 33% acid, 67% troll, 0% fire  
function baseUtils.getDynamicRates(base)	
	local msgSting = "baseUtils.getDynamicRates: ("..tostring(base.x)..","..tostring(base.y)..")" 	-- + !КДА 2021.11

	local aligments
	aligments = base.alignment
	local totalRate = 0
	local dynamicRates = {totalRate = 0, totalDynamicRate = 0, changesCnt = 0, obsoleteCnt = 0, dynamicRatesTable={}}
	local dynamicRatesTable = {rate={}}
	local fieldRate = dynamicRatesTable.rate
	for faction,rate in pairs(aligments) do
		totalRate = totalRate + rate
		fieldRate[faction] = rate
	end	
	if totalRate == 0 then totalRate = 1 end
	
	local totalCount
	if not(base.factionsTotal) or base.factionsTotal[1]==0 then 
		totalCount = 0
	else
		totalCount = base.factionsTotal[1]
	end	
	local factionsTotal = base.factionsTotal[2]	
	for faction,rate in pairs(factionsTotal) do
		if not fieldRate[faction] then
			fieldRate[faction] = 0
		end	
	end	
	
	dynamicRatesTable.reqCount = {}
	local fieldReqCount = dynamicRatesTable.reqCount
	for faction,rates in pairs(fieldRate) do
		fieldReqCount[faction] = totalCount*(fieldRate[faction]/totalRate)
	end
	dynamicRates.dynamicRatesTable = dynamicRatesTable 
	
	calculateDynamicRates(dynamicRates, factionsTotal)
	
	dynamicRates.totalRate = totalRate
		
	return dynamicRates	
end

function baseUtils.changeEntityAndUpdateDynamicRates(entity, dynamicRates, map, base)
	local universe = map.universe
	local oldCnt = 0
	local newFaction

	if not universe.buildingHiveTypeLookup[entity.name] then
		return nil
	end	

	local oldFaction = universe.enemyAlignmentLookup[entity.name]
	if not oldFaction then		
		return nil
	end
	local dynamicRatesTable = dynamicRates.dynamicRatesTable
	if (dynamicRates.dynamicRatesTable.dynamicRate[oldFaction] or 0)>0 then
		return nil
	end
	-- preventing the "flashing" of the hive. 
	if (universe.buildingHiveTypeLookup[entity.name] == "hive") and (dynamicRates.dynamicRatesTable.dynamicRate[oldFaction] or 0)>-0.3 then
		return nil
	end
	
	if entity.type =="unit-spawner" then
		oldCnt = 1
		newFaction = getFactionFromAligment(dynamicRates.dynamicRatesTable.dynamicRate)
		 
	else	
		newFaction = getFactionFromAligment(dynamicRates.dynamicRatesTable.rate)
	end	
	if oldFaction == newFaction then
		return nil
	end
	
	local newEntity = baseUtils.changeEntityAligment(entity, newFaction, map)
		
	if newEntity then
		if base and base.factionsTotal then 	
			local factionsTotal = base.factionsTotal[2]	
			local newCnt = 0
			if newEntity.type =="unit-spawner" then
				newCnt = 1
			end	
			if oldCnt > 0 then
				factionsTotal[oldFaction] = (factionsTotal[oldFaction] or 0) - oldCnt
			end	
			if newCnt > 0 then
				factionsTotal[newFaction] = (factionsTotal[newFaction] or 0) - newCnt
			end	
			base.factionsTotal[1] = base.factionsTotal[1] + newCnt - oldCnt 
			if oldCnt>0  or newCnt>0 then
				calculateDynamicRates(dynamicRates, factionsTotal)
			end	
		end	
		return newEntity
	end	
    return nil
end

local function updateBaseStats(base)
	local aligments
	aligments = base.alignment
	if not aligments then
		return false
	end	
	
	-- base.factionsTotal = {totalCount, factionsTotal}
	
	updateBaseFactionsTotal(base)
	dynamicRates = baseUtils.getDynamicRates(base)	-- => {totalRate=N, totalDynamicRate=N, changesCnt=N, obsoleteCnt=N, dynamicRatesTable=Table)
			
	base.changingEntities = false
	-- if dynamicRates.obsoleteCnt > 0 then
		-- base.changingEntities = true
	-- else
	if base.factionsTotal then 
		local totalCount = base.factionsTotal[1]
		local thresholdCount = 0
		if totalCount <= 3 then
			thresholdCount = 1
		elseif totalCount<10 then
			thresholdCount = 2
		else	
			thresholdCount = mMin(totalCount*0.2, 8)
		end	
		if dynamicRates.changesCnt >= thresholdCount then
			base.changingEntities = true
		end		
	end
	
end

-- alignmentAndStep{N, alignment}
-- be careful: changing alignmentAndStep[1]
local function convertAlignment(alignment, alignmentAndStep, writeToalignment)
	if not alignmentAndStep then
		return alignment
	end
	local steps = alignmentAndStep[1]
	if steps<=1 then
		if not writeToalignment then
			alignmentAndStep[1] = 0
			return alignmentAndStep[2]
		else
			alignmentAndStep[1] = 1
		end	
	end
	
	local newAlignment = {}	
	for faction,rate in pairs(alignmentAndStep[2]) do
		newAlignment[faction] = rate
	end		
	for faction,rate in pairs(alignment) do
		newAlignment[faction] = (newAlignment[faction] or 0) - rate 
	end		
	local TableToChange 
	if writeToalignment then
		TableToChange = alignment
	else
		TableToChange = newAlignment
	end
	
	for faction,rate in pairs(newAlignment) do
		TableToChange[faction] = (alignment[faction] or 0) + rate/steps			
		if TableToChange[faction]<=0 then TableToChange[faction]=nil end 
	end
	alignmentAndStep[1] = alignmentAndStep[1] - 1
	return TableToChange
end

function baseUtils.chunkCanGrow(map, chunk)
	if chunk.growFails and (chunk.growFails > 5) then
		return false
	end
	local nestCount = getNestCount(map, chunk) + getHiveCount(map, chunk)
	local turretCount = getTurretCount(map, chunk)
	if (nestCount < 3) or ((nestCount + turretCount) < 10) then
		return true
	end		
	--game.print("baseUtils.chunkCanGrow: [gps=" .. chunk.x .. "," .. chunk.y .."] = false" )	-- debug
	return false
end

function baseUtils.processBase(chunk, map, tick, base)
    if not base.alignment then
        return
    end
	if not tick then
        return
    end
	if not chunk then
        return
    end
	if not base.thisIsRampantEnemy then		
		base.tick = tick+36000
        return
	end
	
    local surface = map.surface
    local universe = map.universe
    local point = universe.position

    point.x = chunk.x + (CHUNK_SIZE * mRandom())
    point.y = chunk.y + (CHUNK_SIZE * mRandom())
	local newTier = evoToTierNorandom(map.universe, map.evolutionLevel) - base.tierHandicap
	if base.tier < newTier then
		base.tier = newTier
		base.nextMutationTick = tick + 36000
		upgradeBase(map, base, 3)
		base.state = BASE_AI_STATE_ACTIVE
	elseif (base.state == BASE_AI_STATE_MUTATE) and ((base.nextMutationTick or 0) < tick) and (not base.changingEntities) and (not base.newAlignmentAndSteps) then
		local mutateRoll = mRandom()		
		--base.nextMutationTick = tick + 36000
		if (mutateRoll < 0.05) then
			upgradeBase(map, base, 3)
		 elseif (mutateRoll< 0.3) then	
			upgradeBase(map, base, 2)
		else	
			upgradeBase(map, base, 4)
		end
		base.state = BASE_AI_STATE_ACTIVE
 	end	

	replaceDeletedFactions(base.alignment, map)
	if base.newAlignmentAndSteps then
		replaceDeletedFactions(base.newAlignmentAndSteps[2], map)
	end
	
	updateBaseStats(base)
	------- growing
	local baseCanGrow = false
	local chunksCount = 0 
	local activeChunks = 0 
	for chunk, _ in pairs(base.chunks) do
		if (getNestActiveness(map, chunk) > 0) then
			activeChunks = activeChunks + 1
			-- baseCanGrow = baseCanGrow or baseUtils.chunkCanGrow(map, chunk)	 -- only active chunk
		end
		chunksCount = chunksCount + 1
	end
	if (activeChunks > 0) and (chunksCount <= 5) then
		for chunk, _ in pairs(base.chunks) do
			baseCanGrow = baseCanGrow or baseUtils.chunkCanGrow(map, chunk)	 -- only active chunk
		end		
	end
	
	if baseCanGrow then
		if not map.basesToGrow[base.id] then
			map.basesToGrow[base.id] = base
			-- game.print("add base to growing list: #"..base.id)	-- debug
		end		
	else
		if map.basesToGrow[base.id] then
			universe.growingBases[base.id] = nil
			map.basesToGrow[base.id] = nil
			if universe.growingBasesIterator == base.id then
				universe.growingBasesIterator = nil
			end
			-- game.print("base stop growing: #"..base.id.." activeChunks = "..activeChunks..", baseCanGrow =".. tostring(baseCanGrow)..", chunksCount = "..chunksCount)	-- debug	
		end	
	end
	-------
	
	if base.newAlignmentAndSteps then	
		convertAlignment(base.alignment, base.newAlignmentAndSteps, true)
		if base.newAlignmentAndSteps[1] == 0 then base.newAlignmentAndSteps = nil end 
	end
	if (universe.evolveTick <=tick) and (not base.changingEntities) and (not base.newAlignmentAndSteps) and ((base.evolveTick or 0) <= tick) then
        local entities = surface.find_entities_filtered(universe.filteredEntitiesPointQueryLimited)
        if #entities ~= 0 then
            local entity = entities[1]
            local cost = universe.costLookup[entity.name]
			if cost then
				local newEntity = baseUtils.evolveEntity(entity, map)
				if newEntity then
					base.evolveTick = tick + cost
					universe.evolveTick = tick + GLOBAL_EVOLVE_COOLDOWN
				end
			end	
		end	
 	end	

    base.tick = tick
end

function baseUtils.createBase(map, chunk, tick, thisIsRampantEnemy)
	if not tick then
        return nil
    end
	if not chunk then
        return nil
    end
		
	local universe = map.universe
    local x = chunk.x
    local y = chunk.y
    local distance = euclideanDistancePoints(x, y, 0, 0)

    local meanLevel = mFloor(distance * 0.005)

    local distanceIndex = mMin(1, distance * BASE_DISTANCE_TO_EVO_INDEX)
    local evoIndex = mMax(distanceIndex, map.evolutionLevel)

	local tier = evoToTierNorandom(map.universe, evoIndex)
	local tierHandicap 
	if tier == 1 then
		if mRandom()<0.7 then 
			tierHandicap = 0
		else
			tierHandicap = 1
		end
	else
		tierHandicap = mRandom(mMin(3, tier))-1
	end	

    local baseTick = (tick or 0)
    local alignment
	
	alignment = findBaseInitialAlignment(map, evoIndex) or {neutral = 1}

	
    local baseLevel = gaussianRandomRange(meanLevel, meanLevel * 0.3, meanLevel * 0.50, meanLevel * 1.50)
    local baseDistanceThreshold = gaussianRandomRange(BASE_DISTANCE_THRESHOLD,
                                                      BASE_DISTANCE_THRESHOLD * 0.2,
                                                      BASE_DISTANCE_THRESHOLD * 0.75,
                                                      BASE_DISTANCE_THRESHOLD * 1.50)
    local distanceThreshold = (baseLevel * BASE_DISTANCE_LEVEL_BONUS) + baseDistanceThreshold

    local base = {
        x = x,
        y = y,
        distanceThreshold = distanceThreshold,	-- not used, but maybe later...
        tick = baseTick,
        alignment = alignment,
        state = BASE_AI_STATE_ACTIVE,
        damagedBy = {},
        stateTick = 0,
        createdTick = (tick or 0),
		evolveTick = (tick or 0) + BASE_EVOLVE_THRESHOLD,
		nextMutationTick = tick + 36000,
        points = 0,
		thisIsRampantEnemy = thisIsRampantEnemy,
		mapIndex = map.surface.index,
		chunks = {},
		basesToGrow = {},
        id = universe.baseId
		, chunkFactions = {}, factionsTotal = nil, changingEntities = false, tier = tier, tierHandicap = tierHandicap, newAlignmentAndSteps = nil 
    }
    universe.baseId = universe.baseId + 1

    setChunkBase(map, chunk, base)

    universe.bases[base.id] = base
    return base
end

-- + !КДА 2021.11
function baseUtils.findNewBaseAligment(map, chunk)
	if not chunk then
        return {neutral = 1}
    end

	local x = chunk.x
    local y = chunk.y
    local distance = euclideanDistancePoints(x, y, 0, 0)

    local distanceIndex = mMin(1, distance * BASE_DISTANCE_TO_EVO_INDEX)
    local evoIndex = mMax(distanceIndex, map.evolutionLevel)
    local alignment = findBaseInitialAlignment(map, evoIndex) or {neutral = 1}
	return alignment
end
-- - !КДА 2021.11

function baseUtils.rebuildNativeTables(universe)
    local alignmentSet = {}
    universe.evolutionTableAlignment = alignmentSet
    local buildingSpaceLookup = {}
    universe.buildingSpaceLookup = buildingSpaceLookup
    local enemyAlignmentLookup = {}
    universe.enemyAlignmentLookup = enemyAlignmentLookup
    local evoToTierMapping = {}
    universe.evoToTierMapping = evoToTierMapping
    local upgradeLookup = {}
    universe.upgradeLookup = upgradeLookup
    local buildingEvolveLookup = {}
    universe.buildingEvolveLookup = buildingEvolveLookup
    local costLookup = {}
    universe.costLookup = costLookup
    local buildingHiveTypeLookup = {}
    universe.buildingHiveTypeLookup = buildingHiveTypeLookup
    local buildingTierLookup = {}	-- + !КДА 2021.11
    universe.buildingTierLookup = buildingTierLookup

    for i=1,10 do
        evoToTierMapping[#evoToTierMapping+1] = (((i - 1) * 0.1) ^ 0.8) - 0.01
	end

    for i=1,#FACTION_SET do
        local faction = FACTION_SET[i]

        local factionUpgradeLookup = {}
        upgradeLookup[faction.type] = factionUpgradeLookup
        local factionBuildingPicker = {}
        buildingEvolveLookup[faction.type] = factionBuildingPicker

        for t=1,10 do
            local alignments = alignmentSet[t]
            if not alignments then
                alignments = {}
                alignmentSet[t] = alignments
            end

            --[[
                alignments table is a table that is used for selecting what factions are available
                to pick given an evolution level.

                evolutionTable is a table that given a faction allows the selection of a building
                type based on the propabilities given. Once the the building type is selected given
                a faction, then the evolution decides what level of building to select
            --]]
            local factionAcceptRate = faction.acceptRate

            local low = factionAcceptRate[1]
            local high = factionAcceptRate[2]
            if (low <= t) and (t <= high) then
                alignments[#alignments+1] = {linearInterpolation((t - low) / (high - low), factionAcceptRate[3], factionAcceptRate[4]), faction.type}                
            end

            local tieredUpgradeBuildingSet = factionUpgradeLookup[t]
            if not tieredUpgradeBuildingSet then
                tieredUpgradeBuildingSet = {}
                factionUpgradeLookup[t] = tieredUpgradeBuildingSet
            end

            local tieredBuildingPickerSet = factionBuildingPicker[t]
            if not tieredBuildingPickerSet then
                tieredBuildingPickerSet = {}
                factionBuildingPicker[t] = tieredBuildingPickerSet
            end

            for b=1,#faction.buildings do
                local building = faction.buildings[b]

                local buildingSet = tieredUpgradeBuildingSet[building.type]
                if not buildingSet then
                    buildingSet = {}
                    tieredUpgradeBuildingSet[building.type] = buildingSet
                end

                local variationSet = {}
                for v=1,universe.ENEMY_VARIATIONS do
                    local entry = faction.type .. "-" .. building.name .. "-v" .. v .. "-t" .. t .. "-rampant"
                    enemyAlignmentLookup[entry] = faction.type
                    costLookup[entry] = HIVE_BUILDINGS_COST[building.type]
                    buildingHiveTypeLookup[entry] = building.type
					buildingTierLookup[entry] = t
					if v==1 then
						variationSet[#variationSet+1] = entry
					end	
                end

                local buildingAcceptRate = building.acceptRate

                local buildingLow = buildingAcceptRate[1]
                local buildingHigh = buildingAcceptRate[2]
                if (buildingLow <= t) and (t <= buildingHigh) then
                    for vi=1,#variationSet do
                        local variation = variationSet[vi]
                        buildingSet[#buildingSet+1] = variation
                    end
                    tieredBuildingPickerSet[#tieredBuildingPickerSet+1] = {
                        linearInterpolation((t - buildingLow) / (buildingHigh - buildingLow),
                                    buildingAcceptRate[3],
                                    buildingAcceptRate[4]),
                        variationSet,
                        building.type
                    }
                end

            end
        end
    end

    for t=1,10 do
        local alignments = alignmentSet[t]
        local totalAlignment = 0
        for i=1,#alignments do		
            totalAlignment = totalAlignment + alignments[i][1]
        end
        for i=1,#alignments do
            alignments[i][1] = alignments[i][1] / totalAlignment
        end

        for fi=1,#FACTION_SET do
            local faction = FACTION_SET[fi]
            local factionBuildingSet = buildingEvolveLookup[faction.type][t]
            local totalBuildingSet = 0
            for i=1,#factionBuildingSet do
                totalBuildingSet = totalBuildingSet + factionBuildingSet[i][1]
            end
            for i=1,#factionBuildingSet do
                factionBuildingSet[i][1] = factionBuildingSet[i][1] / totalBuildingSet
            end
        end
    end
	

	
	local cnt = 0	---------------------------
    if universe.maps then
		for _,base in pairs(universe.bases) do
			local map = universe.maps[base.mapIndex]
			if map then
				local evoIndex = evoToTier(universe, map.evolutionLevel)
				cnt = cnt + 1
				for x=1,#base.alignment do
					local alignment = base.alignment[x]
					if not universe.buildingEvolveLookup[alignment] then
						base.alignment = findBaseInitialAlignment(map, evoIndex) or {neutral = 1}
						break
					end
				end
			end	
		end
    end
end

function baseUtils.setRandomBaseToMutate(universe)
	if not universe.NEW_ENEMIES then
		return
	end	
	if game.tick < 2000 then
		return
	end
	
	local basesId = {}
	for _,base in pairs(universe.bases) do
		if base and base.thisIsRampantEnemy and base.alignment and (base.state ~= BASE_AI_STATE_MUTATE) and (base.tier > 1) then	
			basesId[#basesId + 1] = base.id
		end		
	end
	if #basesId == 0 then
		return
	end
	local base = universe.bases[basesId[mRandom(1, #basesId)]]
	base.state = BASE_AI_STATE_MUTATE
end

-- + !КДА 2021.10 debug
function baseUtils.ShowNewBaseAligments(universe, targetEvolution)
	if universe == nil then
		return ""
	end	
    local tier = evoToTierNorandom(universe, targetEvolution)
    local alignments = universe.evolutionTableAlignment[tier]
	game.print("Evo = "..tostring(targetEvolution*100).."%, tier:"..tostring(tier)) 
	for i=1,#alignments do
		local alignment = alignments[i]
		local aligmentStats = tostring(i)..":"
		for x=1,#alignment do
			aligmentStats = aligmentStats .. ", " .. alignment[x] 
		end	
		game.print(aligmentStats)
	end
	return ""
end

function baseUtils.ShowEvoToTierMapping(universe)
	for i=10,1,-1 do
		game.print(tostring(i)..":"..tostring(universe.evoToTierMapping[i]))
	end	
	return ""
end

-- - !КДА



baseUtilsG = baseUtils
return baseUtils
