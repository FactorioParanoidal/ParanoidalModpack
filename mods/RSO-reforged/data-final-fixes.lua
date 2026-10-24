-- Other mods may list planets or resource entities RSO must leave to the vanilla generator
-- (data.rso_ignore_planets[name] = true, data.rso_ignore_resource_entities[name] = true).
data.rso_ignore_planets = data.rso_ignore_planets or {}
data.rso_ignore_resource_entities = data.rso_ignore_resource_entities or {}
local ignored_resources = data.rso_ignore_resource_entities
local ignored_planets = data.rso_ignore_planets

-- The vanilla autoplace of resources is switched off: RSO places the configured ones with its own
-- noise expressions (prototypes/noise.lua), the others are not placed. The autoplace stays
-- defined, so the map generator sliders keep working.
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
			if entity and data.raw.resource[entity] and not ignored_resources[entity] then
				names[key] = "0"
			end
		end
	end
end

-- The vanilla autoplace of enemy bases is switched off too: RSO places its spawners and worms with
-- noise expressions (prototypes/noise.lua). Enemies of Big Monsters and of the mferrari library
-- (bosses, giant worms) keep their own placement: those mods own them (Big Monsters has no autoplace
-- for its giant worms in the Paranoidal fork), as RampantFixed treats
-- them (libs/ForeignEnemies.lua).
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

require("prototypes.noise")(ignored_resources, ignored_planets)

-- No decoratives on and next to ore tiles and wells; no trees and rocks on them with
-- rso-remove-trees.
local function keep_off_ore(prototypes, free)
	for _, prototype in pairs(prototypes or {}) do
		local autoplace = prototype.autoplace
		if autoplace and autoplace.probability_expression ~= nil then
			autoplace.probability_expression = "(" .. tostring(autoplace.probability_expression) .. ") * " .. free
		end
	end
end
keep_off_ore(data.raw["optimized-decorative"], "rso_free_decor")
if settings.startup["rso-remove-trees"].value then
	keep_off_ore(data.raw.tree, "rso_free")
	keep_off_ore(data.raw["simple-entity"], "rso_free")
end
