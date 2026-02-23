require("config")
require("prototypes.prototype_utils")

local IgnoredDataResources =
{
	["scrap"] = true,
	["fossil-roots"] = true,
	["tibGrowthNode"] = true,
	["lambent-nil-phosphorite"] = true
--	["termal"] = true,
--	["termal2"] = true
}

local IgnoredDataSpawners =
{
	["flying-electric-unit-spawner"] = true
}

function UseVanillaEnemySpawning()
	return settings.startup["rso-vanilla-biter-generation"].value or mods["bobenemies"]
end

function IsNotEnemyEntity(entityName)
	if UseVanillaEnemySpawning() and
		(data.raw['turret'][entityName] or data.raw['unit-spawner'][entityName]) then
		return false
	end
	return true
end

function splitStr(inputstr)
  local res = {}
  for str in string.gmatch(inputstr, "([^:]+)") do
    table.insert(res, str)
  end
  return res
end

for _, resource in pairs(data.raw.resource) do
	if (not IgnoredDataResources[resource.name] and not data.rso_ignore_resource_entities[resource.name]) 
		and resource.autoplace 
		and resource.autoplace.tile_restriction == nil 
	then
		resetRichness(resource)
	end
end

for _, planet in pairs(data.raw.planet) do
	local mapGenSettings = planet.map_gen_settings
	local propertyExpressionNames = mapGenSettings and mapGenSettings.property_expression_names or nil

	if not data.rso_ignore_planets[planet.name] and propertyExpressionNames then
		for name, expression in pairs(propertyExpressionNames) do
			local tokens = splitStr(name)
			if #tokens == 3 and tokens[1] == "entity"
				and IsNotEnemyEntity(tokens[2])
			then
				if not IgnoredDataResources[tokens[2]] then
					propertyExpressionNames[name] = 0
				end
			end
		end
		planet.map_gen_settings.property_expression_names = propertyExpressionNames
	end
end


if not UseVanillaEnemySpawning() then
		
	for _, spawner in pairs(data.raw["unit-spawner"]) do
		if not IgnoredDataSpawners[spawner.name] then
			removeProbability(spawner)
		end
	end

	for _, turret in pairs(data.raw.turret) do
		if turret.subgroup == "enemies" then
			removeProbability(turret)
		end
	end
end

if debug_items_enabled then
	data.raw["car"]["car"].max_health = 0x8000000
	data.raw["ammo"]["basic-bullet-magazine"].magazine_size = 1000
	data.raw["ammo"]["basic-bullet-magazine"].ammo_type.action[1].action_delivery[1].target_effects[2].damage.amount = 5000
end