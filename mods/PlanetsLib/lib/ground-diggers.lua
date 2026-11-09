--- PlanetsLib ground diggers
--- Allows a planet to convert mining drills placed without nearby resources
--- into "ground digger" machines that craft a recipe over time.
--- Ported from "Muluna, Moon of Nauvis" (which was itself forked from Maraxsis).
---
--- All planets share a single ground digger prototype per mining drill, using the
--- naming scheme "<drill>-ground-digger". This matches the prototypes used by Muluna,
--- so saves that placed those entities keep working. The recipe is assigned at runtime,
--- since a shared prototype cannot hard-code a per-planet recipe.
-- @module lib.ground-diggers

local util = require("util")
local rro = require("lib.objects")
local lib = require("lib.lib")

local Public = {}

-- Hidden surface property marking every planet that enabled ground diggers. Each shared
-- digger prototype gets a surface condition on it, so diggers can only exist on
-- participating planets even though the prototypes themselves are shared.
local SURFACE_PROPERTY_NAME = "PlanetsLib-has-ground-diggers"

--== Helpers ==--

---Normalizes a list/array of names into a dictionary keyed by name.
-- Accepts both {"a","b"} and {a = true, b = true} forms.
-- @param list table
-- @return table|nil
local function normalize_name_set(list)
	if not list then
		return nil
	end
	local normalized = {}
	for key, value in pairs(list) do
		if type(key) == "number" then
			if value then
				normalized[value] = true
			end
		elseif value then
			normalized[key] = true
		end
	end
	return normalized
end

local function is_square(entity)
	if not entity.selection_box then
		return false
	end
	local width = entity.selection_box[2][1] - entity.selection_box[1][1]
	local height = entity.selection_box[2][2] - entity.selection_box[1][2]
	return math.ceil(width) == math.ceil(height)
end

-- Some mods create per-quality or per-resource copies of a drill with the quality/resource
-- name baked into the entity name. Those are variants of a drill, not distinct machines.
local function contains_quality_or_resource_name(name)
	for quality_name in pairs(data.raw["quality"] or {}) do
		if string.find(name, quality_name, 1, true) then
			return true
		end
	end
	for resource_name in pairs(data.raw["resource"] or {}) do
		if string.find(name, resource_name, 1, true) then
			return true
		end
	end
	return false
end

-- Drills that cannot mine ordinary solid resources can only be placed on specific
-- resource sites (pumpjacks on oil, anomaly collectors on warp anomalies, ...).
-- Turning those into ground diggers would let players place them anywhere.
local function can_mine_solid_resources(drill)
	if not drill.resource_categories then
		return true
	end
	for _, category in pairs(drill.resource_categories) do
		if category == "basic-solid" then
			return true
		end
	end
	return false
end

---Whether a mining drill can be converted into a ground digger.
-- Diggers are assembling machines, so the drill must be square and placeable, must
-- not output fluids (pumpjacks are mining drills), and must be able to mine ordinary
-- solid resources rather than only specific resource sites. Any energy source is
-- allowed, so non-electric drills are eligible too.
-- @param drill table
-- @param item_lookup table Dictionary of entity name -> placing item name.
-- @return boolean
function Public.is_eligible_drill(drill, item_lookup)
	if not drill then
		return false
	end
	if drill.PlanetsLib_do_not_generate_variants then
		return false
	end
	if drill.output_fluid_box then
		return false
	end
	if not can_mine_solid_resources(drill) then
		return false
	end
	if not is_square(drill) then
		return false
	end
	if not item_lookup[drill.name] then
		return false
	end
	if contains_quality_or_resource_name(drill.name) then
		return false
	end
	return true
end

---The shared ground digger prototype name for a mining drill.
-- Deliberately matches Muluna's naming scheme for backwards compatibility.
-- @param drill_name string
-- @return string
function Public.ground_digger_name(drill_name)
	return drill_name .. "-ground-digger"
end

---Creates the hidden shared surface property used to restrict diggers to participating planets.
local function ensure_ground_digger_surface_property()
	if data.raw["surface-property"][SURFACE_PROPERTY_NAME] then
		return
	end
	data:extend({
		{
			name = SURFACE_PROPERTY_NAME,
			type = "surface-property",
			hidden = true,
			hidden_in_factoriopedia = true,
			default_value = 0,
			order = "zzz",
			localised_name = { "surface-property-name.planet-str" },
			localised_unit_key = "surface-property-name.planet-str",
		},
	})
end

--== Public API ==--

--- PlanetsLib.enable_ground_diggers(planet, recipe, options)
--- Enables ground diggers on a planet. Whenever a supported mining drill is placed on the
--- planet where no resources are nearby, it is converted into a ground digger that crafts
--- `recipe`. Each planet may have a single ground digger recipe.
--- @param planet string|table Planet name or planet prototype.
--- @param recipe string Name of the recipe the ground diggers will craft.
--- @param options table|nil Optional fields:
---   `drills` (table): Only generate diggers for these mining drill entity names.
---   `blacklist` (table): Never generate diggers for these mining drill entity names.
function Public.enable_ground_diggers(planet, recipe, options)
	local planet_name = type(planet) == "table" and planet.name or planet
	if type(planet_name) ~= "string" then
		error(
			"PlanetsLib.enable_ground_diggers(planet,recipe,options) - 'planet' must be a planet name or prototype. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	if type(recipe) ~= "string" then
		error(
			"PlanetsLib.enable_ground_diggers(planet,recipe,options) - 'recipe' must be a recipe name. See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
	end
	options = options or {}

	local config = PlanetsLib.constants.ground_diggers[planet_name]
	if not config then
		config = {}
		PlanetsLib.constants.ground_diggers[planet_name] = config
	end
	config.recipe = recipe
	config.drills = normalize_name_set(options.drills)
	config.blacklist = normalize_name_set(options.blacklist)
	config.diggers = nil

	-- If the automatic final-fixes pass has already run, generate the new planet immediately.
	if PlanetsLib.current_stage == "data-final-fixes" then
		Public.generate_ground_diggers()
	end
end

---Builds the shared ground digger entity for a single drill.
-- @param drill table The mining drill prototype to copy.
-- @param digger_name string Name of the generated prototype.
-- @param item_name string The item that places the drill (and so the digger).
-- @param categories table The crafting categories the digger accepts.
-- @return table The generated assembling-machine prototype (not yet extended).
function Public.create_ground_digger(drill, digger_name, item_name, categories)
	local digger = util.table.deepcopy(drill)
	local original_localised_name = digger.localised_name or { "entity-name." .. drill.name }

	digger.name = digger_name
	digger.type = "assembling-machine"
	digger.crafting_categories = util.table.deepcopy(categories)
	digger.crafting_speed = digger.mining_speed or digger.crafting_speed or 1
	digger.placeable_by = { item = item_name, count = 1 }
	digger.fast_replaceable_group = (drill.fast_replaceable_group or drill.name) .. "-ground-digger"
	digger.next_upgrade = nil
	digger.allowed_effects = { "productivity", "consumption", "speed", "pollution", "quality" }
	digger.localised_name = { "entity-name.PlanetsLib-ground-digger", original_localised_name }
	digger.localised_description = { "entity-description.PlanetsLib-ground-digger" }
	digger.hidden_in_factoriopedia = false

	-- Keep the drill's own surface conditions, then additionally restrict the digger to
	-- planets that enabled ground diggers.
	local conditions = drill.surface_conditions and util.table.deepcopy(drill.surface_conditions) or {}
	table.insert(conditions, {
		property = SURFACE_PROPERTY_NAME,
		min = 1,
		max = 1,
	})
	digger.surface_conditions = conditions

	-- Fields that only make sense on mining drills.
	digger.mining_speed = nil
	digger.resource_categories = nil
	digger.resource_drain_rate_percent = nil
	digger.resource_searching_radius = nil

	-- Replicates the default drain of mining drills. Assembling machines automatically apply some drain to machines with undefined drain levels.
	if digger.energy_source.type == "electric" and not digger.energy_source.drain then
		digger.energy_source.drain = "0MW"
	end
	digger.flags = digger.flags or {}
	rro.soft_insert(digger.flags, "not-in-made-in")
	rro.soft_insert(digger.flags, "not-in-bonus-gui")

	return digger
end

-- Resolves which drills a planet can convert, populating config.diggers as a map of
-- placing item name -> {drill = entity name, digger = shared digger entity name}.
local function resolve_planet_diggers(planet_name, item_lookup)
	local config = PlanetsLib.constants.ground_diggers[planet_name]
	if not config then
		return
	end

	local drill_names = {}
	if config.drills then
		-- Accept both array/list and dictionary forms, including configs injected
		-- directly into PlanetsLib.constants.ground_diggers.
		for drill_name in pairs(normalize_name_set(config.drills) or {}) do
			drill_names[drill_name] = true
		end
	else
		for drill_name, drill in pairs(data.raw["mining-drill"] or {}) do
			if Public.is_eligible_drill(drill, item_lookup) then
				drill_names[drill_name] = true
			end
		end
	end
	if config.blacklist then
		for drill_name in pairs(normalize_name_set(config.blacklist) or {}) do
			drill_names[drill_name] = nil
		end
	end

	config.diggers = {}
	for drill_name in pairs(drill_names) do
		local drill = data.raw["mining-drill"][drill_name]
		if not drill then
			error(
				"PlanetsLib.enable_ground_diggers() - Mining drill not found: "
					.. drill_name
					.. " (configured for planet "
					.. planet_name
					.. ")."
			)
		end
		if Public.is_eligible_drill(drill, item_lookup) then
			local item_name = item_lookup[drill_name]
			config.diggers[item_name] = {
				drill = drill_name,
				digger = Public.ground_digger_name(drill_name),
			}
		end
	end
end

---Applies mining drill productivity technologies to the given ground digger recipes,
-- so that ground diggers benefit from mining productivity research.
local function apply_mining_productivity(recipes)
	for _, technology in pairs(data.raw["technology"] or {}) do
		if technology.effects then
			for _, effect in pairs(technology.effects) do
				if effect.type == "mining-drill-productivity-bonus" and effect.modifier then
					for recipe_name in pairs(recipes) do
						rro.soft_insert(technology.effects, {
							type = "change-recipe-productivity",
							recipe = recipe_name,
							change = effect.modifier,
							hidden = true,
						})
					end
				end
			end
		end
	end
end

-- Paranoidal fork: no Factoriopedia note on the drills: they are home drills and keep their texts before the rocket;
-- the planet technology that opens ground digging (Muluna's regolith digging) explains it.

---Generates all ground digger variants configured by mods.
---Called automatically during data-final-fixes. May also be called by a mod during
---data-final-fixes after defining a recipe late.
function Public.generate_ground_diggers()
	local planets = PlanetsLib.constants.ground_diggers

	local item_lookup = {}
	for item_name, item in pairs(data.raw["item"] or {}) do
		if item.place_result then
			item_lookup[item.place_result] = item_name
		end
	end

	-- Pass 1: validate each planet, resolve its eligible drills, and collect recipes.
	local recipes = {}
	for planet_name, config in pairs(planets) do
		local planet = data.raw["planet"][planet_name]
		assert(
			planet,
			"PlanetsLib.enable_ground_diggers() - Planet not found: "
				.. tostring(planet_name)
				.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)

		-- Mark the planet as participating so the shared digger prototypes can be built here.
		ensure_ground_digger_surface_property()
		planet.surface_properties = planet.surface_properties or {}
		planet.surface_properties[SURFACE_PROPERTY_NAME] = 1

		local recipe_name = config.recipe
		assert(
			recipe_name,
			"PlanetsLib.enable_ground_diggers() - No recipe assigned to planet '" .. planet_name .. "'."
		)
		assert(
			data.raw["recipe"][recipe_name],
			"PlanetsLib.enable_ground_diggers() - Recipe not found: "
				.. recipe_name
				.. ". See the PlanetsLib documentation at https://mods.factorio.com/mod/PlanetsLib."
		)
		recipes[recipe_name] = true

		resolve_planet_diggers(planet_name, item_lookup)
	end

	-- All ground diggers share one prototype per drill, so they must accept every
	-- configured recipe's category. Recipes are assigned per planet at runtime.
	local categories = {}
	for recipe_name in pairs(recipes) do
		local recipe = data.raw["recipe"][recipe_name]
		for _, category in pairs(recipe.categories or { "crafting" }) do
			categories[category] = true
		end
	end
	local categories_list = {}
	for category in pairs(categories) do
		table.insert(categories_list, category)
	end

	-- Pass 2: create (or refresh) the shared prototype for each drill.
	local processed = {}
	for _, config in pairs(planets) do
		for item_name, info in pairs(config.diggers or {}) do
			if not processed[info.digger] then
				processed[info.digger] = true
				local drill = data.raw["mining-drill"][info.drill]
				local existing = data.raw["assembling-machine"][info.digger]
				if existing then
					existing.crafting_categories = util.table.deepcopy(categories_list)
				else
					data:extend({
						Public.create_ground_digger(drill, info.digger, item_name, categories_list),
					})
				end
				lib.detailed_log(
					"[PlanetsLib] Generated ground digger " .. info.digger .. " for " .. info.drill
				)
			end
		end
	end

	apply_mining_productivity(recipes)
end

return Public
