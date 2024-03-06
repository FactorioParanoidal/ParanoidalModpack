local constants = require ("__RampantFixed__.libs.Constants")
local FACTION_SET = constants.FACTION_SET

local immunityUpdates = {}


local function setResistancePercent(entity, resistanceType, setPercent)
	local entityResist
	for i = 1, #entity.resistances do
		if entity.resistances[i].type == resistanceType then
			entityResist = entity.resistances[i]
			break
		end
	end
	if not setPercent then
		if entityResist then
			return entityResist.percent or 0
		else
			return 0
		end	
	end
	if not entityResist then
		entity.resistances[#entity.resistances+1] = {type = resistanceType, decrease = 0, percent = 0}
		entityResist = entity.resistances[#entity.resistances]
	end	
	entityResist.percent = setPercent
	return entityResist.percent
end

local function setResistanceDecrease(entity, resistanceType, setDecrease)
	local entityResist
	for i = 1, #entity.resistances do
		if entity.resistances[i].type == resistanceType then
			entityResist = entity.resistances[i]
			break
		end
	end
	if not setDecrease then
		if entityResist then
			return entityResist.decrease or 0
		else
			return 0
		end	
	end
	if not entityResist then
		entity.resistances[#entity.resistances+1] = {type = resistanceType, decrease = 0, percent = 0}
		entityResist = entity.resistances[#entity.resistances]
	end	
	entityResist.decrease = setDecrease
	return entityResist.decrease
end


function immunityUpdates.setPlasmaImmunities()
	local names = {{"biter", "unit"}, {"spitter", "unit"}, {"spitter-spawner", "unit-spawner"}, {"biter-spawner", "unit-spawner"}, {"worm", "turret"}, {"hive", "unit-spawner"}}
	local immuneFactions = {"laser", "electric", "troll", "suicide", "nuclear", "energy-thief"}

	local bobPlasmaFound = data.raw["electric-turret"]["bob-plasma-turret-1"]
	
	local plasma = data.raw["damage-type"]["plasma"]
	for i=1,#immuneFactions do
		local factionName = immuneFactions[i]
		for u=1,#names do
			local name_type = names[u]
			for tier = 1, 10 do
				for variant = 1, 20 do
					entity_name = factionName .. "-" .. name_type[1] .. "-v"..variant.."-t" ..tier.."-rampant"
					local entity = data.raw[name_type[2]][entity_name]
					if not entity then
						break
					end
					
					if bobPlasmaFound then						
						electicResist = setResistancePercent(entity, "electric")
						electicResist = setResistancePercent(entity, "electric", math.max(electicResist, 70))
						
						entity.resistances[#entity.resistances+1] = {
							type = "plasma",
							decrease = 0,
							percent =  math.max(electicResist, 90)
							}
					else	
						electicResist = setResistancePercent(entity, "electric")
						entity.resistances[#entity.resistances+1] = {
							type = "plasma",
							decrease = 0,
							percent =  math.max(electicResist, 70)
							}
					end
					
				end	
			end	
		end
	end	
	
	local targetDummy = data.raw["radar"]["targetDummyPlasma-rampant"]
	if targetDummy then
		targetDummy.resistances[#targetDummy.resistances+1] = {
			type = "plasma",
			decrease = 0,
			percent = 100
			}
	end
	
end

function immunityUpdates.setPierceImmunities()
	local names = {{"biter", "unit"}, {"spitter", "unit"}, {"spitter-spawner", "unit-spawner"}, {"biter-spawner", "unit-spawner"}, {"worm", "turret"}, {"hive", "unit-spawner"}}
	--local immuneFactions = {"laser", "electric", "troll", "suicide", "nuclear", "energy-thief"}

	for i=1,#FACTION_SET do
		local factionName = FACTION_SET[i].type
		for u=1,#names do
			local name_type = names[u]
			for tier = 1, 10 do
				for variant = 1, 20 do
					entity_name = factionName .. "-" .. name_type[1] .. "-v"..variant.."-t" ..tier.."-rampant"
					local entity = data.raw[name_type[2]][entity_name]
					if not entity then
						break
					end
					local physResistance = 0
					for i = 1, #entity.resistances do
						if entity.resistances[i].type == "physical" then
							physResistance = entity.resistances[i]["percent"] or 0
							break
						end
					end
					if physResistance>0 then
						pierceResistance = physResistance + math.max((40 - physResistance)/4, 0.5)		-- just becouse no pierce "decrease"
						--error("pierceResistance = "..pierceResistance)
						if not (pierceResistance==0) then
							entity.resistances[#entity.resistances+1] = {
								type = "bob-pierce",
								decrease = 0,
								percent = math.min(pierceResistance+10, 100)
								}
						end	
					end	
				end	
			end	
		end
	end	
	
	local targetDummy = data.raw["radar"]["targetDummyPhysical-rampant"]
	--if targetDummy then
		targetDummy.resistances["bob-pierce"] = {
			type = "bob-pierce",
			percent = 100
			}
	--end
	
end

function immunityUpdates.setArmorLaserElectricImmunities()
	local electricResist
	local electricResist
	local laserResist
	local entity 
	
	entity = data.raw["armor"]["modular-armor"]
	fireResist = setResistancePercent(entity, "fire")
	electricResist = setResistancePercent(entity, "electric")
	laserResist = setResistancePercent(entity, "laser")
	setResistancePercent(entity, "electric", math.max(electricResist, fireResist*0.5))
	setResistanceDecrease(entity, "electric", 3)
	setResistancePercent(entity, "laser", math.max(laserResist, fireResist*0.5))
	
	entity = data.raw["armor"]["power-armor"]
	fireResist = setResistancePercent(entity, "fire")
	electricResist = setResistancePercent(entity, "electric")
	laserResist = setResistancePercent(entity, "laser")	
	setResistancePercent(entity, "electric", math.max(electricResist, fireResist*0.5))	
	setResistancePercent(entity, "laser", math.max(laserResist, fireResist*0.5))
	
	entity = data.raw["armor"]["power-armor-mk2"]
	fireResist = setResistancePercent(entity, "fire")
	electricResist = setResistancePercent(entity, "electric")
	laserResist = setResistancePercent(entity, "laser")	
	setResistancePercent(entity, "electric", math.max(electricResist, fireResist*0.5))	
	setResistancePercent(entity, "laser", math.max(laserResist, fireResist*0.5))
	
	entity = data.raw["armor"]["heavy-armor"]
	setResistancePercent(entity, "electric", 15)
	setResistanceDecrease(entity, "electric", 2)	
	setResistancePercent(entity, "laser", 10)
	
	entity = data.raw["armor"]["light-armor"]
	setResistancePercent(entity, "electric", 10)
	setResistanceDecrease(entity, "electric", 1)	
	
end

function immunityUpdates.setResistanceToUnknownDamageTypes()
	local knownDamageTypes = {}
	knownDamageTypes["impact"] = true
	knownDamageTypes["acid"] = true
	knownDamageTypes["fire"] = true
	knownDamageTypes["poison"] = true
	knownDamageTypes["physical"] = true
	knownDamageTypes["laser"] = true
	knownDamageTypes["electric"] = true
	knownDamageTypes["explosion"] = true
	knownDamageTypes["plasma"] = true
	knownDamageTypes["bob-pierce"] = true				
	
	knownDamageTypes["rampant-longRangeImmunity"] = true
	knownDamageTypes["rampant-overdamageProtection"] = true
	knownDamageTypes["healing"] = true
	
	local names = {{"biter", "unit"}, {"spitter", "unit"}, {"spitter-spawner", "unit-spawner"}, {"biter-spawner", "unit-spawner"}, {"worm", "turret"}, {"hive", "unit-spawner"}}
	
    for damageType, _ in pairs(data.raw["damage-type"]) do
		if not knownDamageTypes[damageType] then
			log("update immunities to "..damageType)
			for i=1,#FACTION_SET do
				local factionName = FACTION_SET[i].type
				for u=1,#names do
					local name_type = names[u]
					if not (factionName=="neutral") then
						for tier = 2, 10 do
							for variant = 1, 20 do
								entity_name = factionName .. "-" .. name_type[1] .. "-v"..variant.."-t" ..tier.."-rampant"
								local entity = data.raw[name_type[2]][entity_name]
								if not entity then
									break
								end
								entity.resistances[damageType] = {
									type = damageType,
									percent = math.min((tier - 1)*10, 70)
								}
							end	
						end
					end	
				end
			end	
		end	
    end		

	local entity
    for damageType, _ in pairs(data.raw["damage-type"]) do
		if not knownDamageTypes[damageType] then
			entity =  data.raw["radar"]["targetDummyPlasma-rampant"]
			entity.resistances[damageType] = {
				type = damageType,
				percent = 99.99
			}
			entity =  data.raw["radar"]["targetDummyFire-rampant"]
			entity.resistances[damageType] = {
				type = damageType,
				percent = 99.99
			}
			entity =  data.raw["radar"]["targetDummyPhysical-rampant"]
			entity.resistances[damageType] = {
				type = damageType,
				percent = 99.99
			}
			entity =  data.raw["radar"]["targetDummyLaser-rampant"]
			entity.resistances[damageType] = {
				type = damageType,
				percent = 99.99
			}
		end
	end	
end

return immunityUpdates
