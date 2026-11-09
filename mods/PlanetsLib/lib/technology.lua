--- Technology-related functions.
--- Dependencies: util, lib.lib, lib.remove-replace-object
-- @module lib.technology.lua

local util = require("util")
local lib = require("lib.lib")
local rro = require("lib.objects")

local Public = {}

---Technology name goes in. Out comes an array of technology names that currently list that tech as a prerequisite. Throws an error if an invalid prototype name is passed.
---@param tech_name string
---@return string[] children
function Public.get_child_technologies(tech_name)
	assert(data.raw.technology[tech_name], "Invalid technology name: " .. tech_name)
	local children = {}
	for _, tech in pairs(data.raw.technology) do
		if tech.prerequisites then
			for _, prereq in ipairs(tech.prerequisites) do
				if prereq == tech_name then
					table.insert(children, tech.name)
					break
				end
			end
		end
	end
	return children
end

function Public.excise_tech_from_tech_tree(tech_name)
	log("PlanetsLib: Excising technology " .. tech_name .. " from tech tree")

	local tech = data.raw.technology[tech_name]
	if not tech then
		return
	end

	for _, other_tech in pairs(data.raw.technology) do
		if other_tech.prerequisites then
			local affected = false
			for i = #other_tech.prerequisites, 1, -1 do
				if other_tech.prerequisites[i] == tech_name then
					affected = true
					table.remove(other_tech.prerequisites, i)
				end
			end

			if affected then
				for _, prereq in pairs(tech.prerequisites or {}) do
					local already_present = false
					for _, existing in pairs(other_tech.prerequisites) do
						if existing == prereq then
							already_present = true
							break
						end
					end
					if not already_present then
						table.insert(other_tech.prerequisites, prereq)
					end
				end
			end
		end
	end

	data.raw.technology[tech_name].hidden = true
end

function Public.excise_recipe_from_tech_tree(name, include_productivity_effects)
	log("PlanetsLib: Excising recipe " .. name .. " from tech tree")

	for _, tech in pairs(data.raw.technology) do
		if tech.effects and #tech.effects > 0 then
			local new_effects = {}
			for _, effect in ipairs(tech.effects) do
				if not (effect.recipe == name and (effect.type == "unlock-recipe" or (include_productivity_effects and effect.type == "change-recipe-productivity"))) then
					table.insert(new_effects, effect)
				end
			end
			tech.effects = new_effects

			if #new_effects == 0 then
				Public.excise_tech_from_tech_tree(tech.name)
			end
		end
	end
	
	local recipe = include_productivity_effects and PlanetsLib.current_stage ~= "data-final-fixes" and data.raw.recipe[name]
	if recipe then
		recipe.PlanetsLib_blacklist_technology_updates = true
	end
end

function Public.excise_effect_from_tech_tree(effect)
	log("PlanetsLib: Excising effect " .. serpent.block(effect) .. " from tech tree")

	for _, tech in pairs(data.raw.technology) do
		if tech.effects and #tech.effects > 0 then
			local new_effects = {}
			for _, current_effect in ipairs(tech.effects) do
				local should_keep = true

				local effect_count, current_count = 0, 0
				for _ in pairs(effect) do
					effect_count = effect_count + 1
				end
				for _ in pairs(current_effect) do
					current_count = current_count + 1
				end

				if effect_count == current_count then
					should_keep = false
					for k, v in pairs(effect) do
						if not (current_effect[k] and current_effect[k] == v) then
							should_keep = true
							break
						end
					end
				else
					should_keep = true
				end

				if should_keep then
					table.insert(new_effects, current_effect)
				end
			end
			tech.effects = new_effects

			if #new_effects == 0 then
				Public.excise_tech_from_tech_tree(tech.name)
			end
		end
	end
end

function Public.cargo_drops_technology_base(planet, planet_technology_icon, planet_technology_icon_size)
	if not planet then
		error("PlanetsLib:cargo_drops_technology() - planet is required")
	end
	if not planet_technology_icon then
		error("PlanetsLib:cargo_drops_technology() - planet_technology_icon is required")
	end
	if not planet_technology_icon_size then
		error("PlanetsLib:cargo_drops_technology() - planet_technology_icon_size is required")
	end

	return {
		type = "technology",
		name = "planetslib-" .. planet .. "-cargo-drops",
		localised_name = { "", { "technology-name.cargo-drops", { "space-location-name." .. planet } } },
		localised_description = { "technology-description.cargo-drops", { "space-location-name." .. planet } },
		-- TODO: Switch to the iconized planet and show a constant symbol in front?
		effects = Public.technology_effect_cargo_drops(planet, {
			{
				icon = planet_technology_icon,
				icon_size = planet_technology_icon_size,
				scale = 0.65 * (256 / planet_technology_icon_size),
				draw_background = true,
			},
		}),
		icons = Public.technology_icons_planet_cargo_drops(planet_technology_icon, planet_technology_icon_size),
	}
end

function Public.technology_icons_planet_cargo_drops(planet_icon, icon_size, mini)
	icon_size = icon_size or 256
	return {
		{
			icon = "__PlanetsLib__/graphics/icons/cargo-drop-tech-pod.png",
			icon_size = 256,
			scale = 1,
			shift = { 0, 0 },
			draw_background = true,
		},
		{
			icon = planet_icon,
			icon_size = icon_size,
			scale = 0.65 * (256 / icon_size),
			shift = mini and { 0, 0 } or { -17, 55 },
			draw_background = true,
		},
		{
			icon = "__PlanetsLib__/graphics/icons/cargo-drop-tech-shadow.png",
			icon_size = 256,
			scale = 1,
			shift = { 0, 0 },
			tint = { r = 0, g = 0, b = 0, a = 0.5 },
			draw_background = true,
		},
		{
			icon = "__PlanetsLib__/graphics/icons/cargo-drop-tech-pod.png",
			icon_size = 256,
			scale = 1,
			shift = { 0, 0 },
			draw_background = true,
		},
	}
end

function Public.technology_effect_cargo_drops(planet_name, icons)
	return {
		{
			type = "nothing",
			icons = icons,
			effect_description = { "planetslib.cargo-drops-tech-description", "[space-location=" .. planet_name .. "]" },
		},
	}
end

---Create a moon discovery technology icon by adding a little moon icon on your technology icon, like in vanilla, but for moon type planets.
---@param tech_icon string The technology icon to add the moon icon
---@param icon_size integer Your icon size
---@param shadow_scale double Scale of planet relative to shadow icon. If nil, no shadow is drawn.
---@return data.IconData[]
function Public.technology_icon_moon(tech_icon, icon_size, shadow_scale)
	local icons = Public.technology_icon_planet(tech_icon, icon_size, shadow_scale)
	icons[#icons].icon = "__PlanetsLib__/graphics/icons/moon-technology-symbol.png"
	return icons
end

---Create a planet discovery technology icon by adding a little planet icon on your technology icon, like in vanilla.
---@param tech_icon string The technology icon to add the planet icon
---@param icon_size integer Your icon size
---@param shadow_scale number Scale of planet relative to shadow icon. If nil, no shadow is drawn.
---@return data.IconData[]
function Public.technology_icon_planet(tech_icon, icon_size, shadow_scale)
	icon_size = icon_size or 256
	local icons = util.technology_icon_constant_planet(tech_icon)
	icons[1].icon_size = icon_size
	if shadow_scale then
		icons[3] = icons[2]
		icons[2] = icons[1]
		icons[1] = {
			icon = "__PlanetsLib__/graphics/icons/planet-technology.png",
			icon_size = 256,
			shift = { 0, 10 },
		}
		icons[2].scale = shadow_scale * 128 / icon_size
		icons[2].shift = { 0, 10 }
	end
	-- End result is an icons object ressembling the following, as of 2.0.37. Future API changes might change this code,
	-- which is why this function is written to reference the base function instead of copying it by hand.
	-- local icons = {
	-- 	{
	-- 		icon = planet_icon,
	-- 		icon_size = icon_size,
	-- 	},
	-- 	{
	-- 		icon = "__core__/graphics/icons/technology/constants/constant-planet.png",
	-- 		icon_size = 128,
	-- 		scale = 0.5,
	-- 		shift = { 50, 50 },
	-- 		floating = true
	-- 	},
	-- }
	return icons
end

-- TODO: Apply use_icon_overlay_constant to the unlock if the planet is a moon

-- This function makes the technology use all sciences in the base lab.
-- Compatibility for technologies after prometheum science.
function Public.set_science_packs_from_lab(technology, lab)
	assert(technology, "PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - technology is required")
	assert(
		technology.unit,
		"PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - technology.unit is required"
	)
	assert(
		technology.unit.ingredients,
		"PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - technology.unit.ingredients is required"
	)
	assert(lab, "PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - lab is required")
	assert(lab.inputs, "PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - lab.inputs is required")

	technology.unit.ingredients = technology.unit.ingredients or {}

	local inputs = lab.inputs
	local existing_packs = {}

	for _, pack in pairs(technology.unit.ingredients) do
		existing_packs[pack[1]] = true
	end

	for _, value in pairs(inputs) do
		if not existing_packs[value] then
			local to_insert = true
			for _, effect in pairs(technology.effects) do --Check if this technology unlocks a science pack. If yes, don't make this technology require that pack.
				if effect.type == "unlock-recipe" and effect.recipe == value then
					to_insert = false
					break
				end
			end

			if to_insert then
				table.insert(technology.unit.ingredients, { value, 1 })
				existing_packs[value] = true
			end
		end
	end
end

function Public.add_science_packs_from_vanilla_lab_to_technology(technology)
	assert(
		data.raw["lab"]["lab"],
		"PlanetsLib:add_science_packs_from_vanilla_lab_to_technology() - data.raw['lab']['lab'] is required"
	)
	Public.set_science_packs_from_lab(technology, data.raw["lab"]["lab"])
end

local function try_find_item_prototype_by_name(name)
	for item_type in pairs(defines.prototypes.item) do
		local proto = (data.raw[item_type] or {})[name]
		if proto then
			return proto
		end
	end
end

function Public.sort_science_pack_names(science_pack_names_table)
	science_pack_names_table = util.table.deepcopy(science_pack_names_table)

	lib.sort(science_pack_names_table, function(left, right)
		local left_proto = try_find_item_prototype_by_name(left)
		local right_proto = try_find_item_prototype_by_name(right)
		if not (left_proto and right_proto) then
			return true
		end

		local left_order = left_proto.order or left_proto.name
		local right_order = right_proto.order or right_proto.name

		return left_order < right_order
	end)
	return science_pack_names_table
end

--New technologyPrototype field: PlanetsLib_recipe_productivity_effects
--Properties:
--  effects: array[ChangeResultProductivityModifier]
--  purge_other_effects: boolean. Default: false. Before adding effects added by PlanetsLib_recipe_productivity_effects, remove all effects not flagged with PlanetsLib_force_include.
--  allow_recipes_without_productivity: boolean. Default: false. Captures recipes that have "allow_producitivity" set to false.
--ChangeResultProductivityModifier
--Properties:
--  allow_multiple_results: boolean. Default: false. When false, only recipes with one result are added to the technology's effect list.
--  category (optional) (Either (name and type) or category required)
--Inherited from ChangeRecipeProductivityModifier https://lua-api.factorio.com/latest/types/ChangeRecipeProductivityModifier.html
--  type (optional)
--  name (optional)
--  change
--  icons (optional)
--  icon (optional)
--  icon_size (optional)
--  hidden (optional)
--  use_icon_overlay_constant (optional)

--New Modifier field: PlanetsLib_force_include
-- Makes this modifier immune to purge_other_effects.

--New recipe field: PlanetsLib_blacklist_technology_updates
-- Stops PlanetsLib from targeting this recipe in technology updates.

local function xor(a, b)
	return (a or b) and not (a and b)
end

---@param tech table (TechnologyPrototype)
---@author MeteorSwarm
function Public.process_technology_recipe_productivity_effects(tech)
	if not tech.PlanetsLib_recipe_productivity_effects then
		return
	end

	-- To stop techs that deepcopy vanilla productivity techs from wrongly getting vanilla productivity effects.
	if tech.PlanetsLib_recipe_productivity_effects.technology_name and tech.PlanetsLib_recipe_productivity_effects.technology_name ~= tech.name then
		tech.PlanetsLib_recipe_productivity_effects = nil
		return
	end
	if not tech.effects then
		tech.effects = {}
	end
	local new_effects = {}
	if tech.PlanetsLib_recipe_productivity_effects.purge_other_effects then
		for _, effect in pairs(tech.effects) do
			if effect.PlanetsLib_force_include then
				table.insert(new_effects, effect)
			end
		end
	else
		new_effects = table.deepcopy(tech.effects)
	end
	if not new_effects then
		new_effects = {}
	end

	local settings = tech.PlanetsLib_recipe_productivity_effects
	for _, effect in pairs(settings.effects) do
		local type = effect.type
		local name = effect.name
		local change = effect.change
		local category = effect.category
		assert(xor(name, category), "You may only filter either by result name or by category.")
		if name then
			assert(type, "You must provide a type if filtering by result name name.")
		else
			assert(
				tech.PlanetsLib_recipe_productivity_effects.category_blacklist == nil,
				"category_blacklist and category are incompatible."
			)
		end

		local category_blacklist = tech.PlanetsLib_recipe_productivity_effects.category_blacklist or
		{ "recycling" }                                                                                        --Excluded recipe categories

		for _, recipe in pairs(data.raw["recipe"]) do
			if not recipe.results then
				goto continue
			end

			local recipe_categories = recipe.categories or { "crafting" }
			if
				recipe.PlanetsLib_blacklist_technology_updates
				or PlanetsLib.rro.contains_any(category_blacklist, recipe_categories)
			then
				goto continue
			end

			local net_results = {} --Filter out results that cannot be affected by productivity
			for _, result in pairs(recipe.results) do
				if
					not result.ignored_by_productivity
					or result.ignored_by_productivity < (result.amount or result.amount_max)
				then
					if result.name and result.type then
						--Count multiple results with the same same name as a single result
						net_results[result.name] = result.type
					end
				end
			end
			local results_count = table_size(net_results)
			if
				results_count == 0
				or (not effect.allow_multiple_results and results_count > 1)
				or (not settings.allow_recipes_without_productivity and not recipe.allow_productivity)
			then
				goto continue
			end

			for result_name, result_type in pairs(net_results) do
				if
					(PlanetsLib.rro.contains(recipe_categories, category))
					or (result_type == type and result_name == name)
				then
					local new_effect = {
						type = "change-recipe-productivity",
						recipe = recipe.name,
						change = change,
						hidden = effect.hidden,
						use_icon_overlay_constant = effect.use_icon_overlay_constant,
						icons = effect.icons,
						icon = effect.icon,
						icon_size = effect.icon_size,
					}
					local contains = false
					for _, effect in pairs(new_effects) do
						if effect.recipe == new_effect.recipe then
							contains = true
							break
						end
					end
					if not contains then
						table.insert(new_effects, new_effect)
					end
					break --To stop the same recipe from being added multiple times per result item.
				end
			end
			::continue::
		end
		tech.effects = new_effects
	end
	if not (tech.PlanetsLib_recipe_productivity_effects.force_do_not_excise or next(tech.effects)) then
		Public.excise_tech_from_tech_tree(tech.name)
	end
	tech.PlanetsLib_recipe_productivity_effects = nil
end

return Public
