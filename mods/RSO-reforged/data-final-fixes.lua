-- RSO places resources and enemy bases from control.lua, so their vanilla autoplace is switched
-- off here. Autoplace stays defined: the map generator sliders and the autoplace controls keep
-- working and are read by control.lua.
local ignored_resources = data.rso_ignore_resource_entities
local ignored_planets = data.rso_ignore_planets

for name, resource in pairs(data.raw.resource) do
	local autoplace = resource.autoplace
	if autoplace and autoplace.tile_restriction == nil and not ignored_resources[name] then
		autoplace.richness_expression = "0"
		autoplace.probability_expression = "0"
	end
end

-- planet overrides of the form "entity:<name>:<property>"
for planet_name, planet in pairs(data.raw.planet) do
	local names = planet.map_gen_settings and planet.map_gen_settings.property_expression_names
	if names and not ignored_planets[planet_name] then
		for key in pairs(names) do
			local entity = key:match("^entity:([^:]+):[^:]+$")
			if entity and not ignored_resources[entity] then
				names[key] = 0
			end
		end
	end
end

-- Enemies of Big Monsters and of the mferrari library (bosses, giant worms) keep their own
-- placement: those mods own them, as RampantFixed treats them (libs/ForeignEnemies.lua).
local FOREIGN_ENEMY_PREFIXES = {"bm-", "bm_", "maf", "mf_"}

local function is_foreign(name)
	for _, prefix in ipairs(FOREIGN_ENEMY_PREFIXES) do
		if name:sub(1, #prefix) == prefix then return true end
	end
	return false
end

for name, spawner in pairs(data.raw["unit-spawner"]) do
	if spawner.autoplace and not is_foreign(name) then spawner.autoplace.probability_expression = "0" end
end
for name, turret in pairs(data.raw.turret) do
	if turret.subgroup == "enemies" and turret.autoplace and not is_foreign(name) then
		turret.autoplace.probability_expression = "0"
	end
end
