local Public = {}

function Public.assign_rocket_part_recipe(planet, recipe, lock_silo)
	local planet_name = type(planet) == "table" and planet.name or planet
	local recipe_name = type(recipe) == "table" and recipe.name or recipe
	local recipe_obj = data.raw["recipe"][recipe_name]

	-- If exactly one planet uses this rocket part recipe, restrict the recipe to that
	-- planet. Once a second planet is assigned, remove the restriction and never
	-- reapply it (see changelog: the restriction is not reapplied).
	if recipe_obj and data.raw["planet"][planet_name] and not recipe_obj.PlanetsLib_rocket_part_shared then
		local exclusive_to = recipe_obj.PlanetsLib_rocket_part_exclusive_to
		if exclusive_to and exclusive_to ~= planet_name then
			PlanetsLib.remove_surface_condition(recipe_obj, "PlanetsLib-is-" .. exclusive_to)
			recipe_obj.PlanetsLib_rocket_part_exclusive_to = nil
			recipe_obj.PlanetsLib_rocket_part_shared = true
		elseif not exclusive_to then
			PlanetsLib.restrict_to_planet(recipe_obj, planet_name)
			recipe_obj.PlanetsLib_rocket_part_exclusive_to = planet_name
		end
	end

	data.raw["mod-data"]["Planetslib-planet-rocket-part-recipe"].data[planet_name] = recipe_name
	if recipe_name ~= "_other" then
		if lock_silo == nil then
			lock_silo = true
		end
		data.raw["mod-data"]["Planetslib-planet-lock-rocket-silos"].data[planet_name] = lock_silo
	end
end

local function initialize_planet_cargo_drops_whitelist(planet_name)
	data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists[planet_name] = data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists[planet_name]
		or {
			entity_types = {},
			item_names = {},
		}
end

function Public.add_item_name_to_planet_cargo_drops_whitelist(planet_name, item_name)
	initialize_planet_cargo_drops_whitelist(planet_name)

	data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists[planet_name].item_names[item_name] = true
end

function Public.add_entity_type_to_planet_cargo_drops_whitelist(planet_name, entity_type)
	initialize_planet_cargo_drops_whitelist(planet_name)

	data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists[planet_name].entity_types[entity_type] = true
end

function Public.add_item_name_to_global_cargo_drops_whitelist(item_name)
	data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists.all.item_names[item_name] = true
end

function Public.add_entity_type_to_global_cargo_drops_whitelist(entity_type)
	data.raw["mod-data"].Planetslib.data.planet_cargo_drop_whitelists.all.entity_types[entity_type] = true
end

return Public
