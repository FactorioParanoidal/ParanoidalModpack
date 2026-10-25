local util = require("util")

-- Multiple functions used with permission from boblibrary per Bobmeister Nov 7 2024
-- https://discord.com/channels/351216213327609858/497860215010754560/1304116352017109013

if not yi then
	yi = {}
end
if not yi.lib then
	yi.lib = {}
end
if not yi.lib.recipe then
	yi.lib.recipe = {}
end
if not yi.lib.item then
	yi.lib.item = {}
end

-- Workaround for now for the broken turret direction images
blank_sprite = {
	base_visualisation = {
		animation = {
			layers = {
				{
					filename = "__Yuoki__/graphics/blank.png",
					priority = "high",
					width = 1,
					height = 1,
					shift = { 0, 0 },
					direction_count = 1,
					frame_count = 1,
					line_length = 1,
					axially_symmetrical = false,
				},
			},
		},
	},
}

-- internal helper for quantity conversion between items and fluids
local function quantity_convertion(amount, old, new)
	if yi.lib.item.get_type(old) == "fluid" and yi.lib.item.get_type(new) == "item" then
		amount = math.ceil(amount / 10)
	end
	if yi.lib.item.get_type(old) == "item" and yi.lib.item.get_type(new) == "fluid" then
		amount = amount * 10
	end
	return amount
end

-- internal helper to scan ingredients
local function get_old_quantity(ingredients, old)
	local amount = 0
	for i, ingredient in pairs(ingredients) do
		local item = yi.lib.item.ingredient_simple(ingredient)
		if item then
			if item.name == old then
				amount = item.amount + amount
			end
		else
			log("recipe contains an invalid ingredient")
		end
	end
	return amount
end

function yi.lib.item.hide(item_name)
	if type(item_name) == "string" then
		-- Updated to check 2.0 item types via get_type
		local p_type = yi.lib.item.get_type(item_name)
		if p_type and data.raw[p_type] and data.raw[p_type][item_name] then
			data.raw[p_type][item_name].hidden = true
		end
	else
		log(debug.traceback())
		yi.lib.error.item(item_name)
	end
end

function yi.lib.item.get_type(name) --returns actual item type
	local item_type = nil
	if type(name) == "string" then
		-- 2.0 now includes more item types in data.raw
		local search_types = { "item", "tool", "ammo", "gun", "armor", "capsule", "module", "item-with-entity-data" }
		for _, type_name in ipairs(search_types) do
			if data.raw[type_name] and data.raw[type_name][name] then
				item_type = type_name
				break
			end
		end
		if not item_type and data.raw.fluid and data.raw.fluid[name] then
			item_type = "fluid"
		end
	else
		log("Item name is not a string")
	end
	return item_type
end

function yi.lib.item.ingredient_simple(inputs) --doesn't care if the item actually exists or not, returns if a valid ingredient structure can be determined.
	local item = {}

	if type(inputs) == "table" then
		-- Factorio 2.0: Short-hand array {"item", 1} is invalid.
		-- This parser ensures results always use the explicit table format.
		if inputs.name and type(inputs.name) == "string" then
			item.name = inputs.name
		else
			log(debug.traceback())
			log("Unable to determine an ingredient name")
			return nil
		end

		if inputs.amount and type(inputs.amount) == "number" then
			item.amount = inputs.amount
		else
			log(debug.traceback())
			log("Unable to determine an ingredient amount")
			return nil
		end

		if inputs.type then
			item.type = inputs.type
		else
			-- Check if it is a fluid or item for 2.0 type enforcement
			item.type = yi.lib.item.get_type(item.name) or "item"
		end

		if item.type ~= "fluid" then
			if type(item.amount) ~= "number" or item.amount < 1 then
				item.amount = 1
			else
				item.amount = math.floor(item.amount)
			end
		else
			item.temperature = inputs.temperature
			item.minimum_temperature = inputs.minimum_temperature
			item.maximum_temperature = inputs.maximum_temperature
			item.fluidbox_index = inputs.fluidbox_index
			item.fluidbox_multiplier = inputs.fluidbox_multiplier
		end

		item.ignored_by_stats = inputs.ignored_by_stats
		return item
	else
		log(debug.traceback())
		yi.lib.error.ingredient(inputs)
		return nil
	end
end

function yi.lib.item.get_basic_type_simple(name) --assumes type is item, even if the item doesn't exist
	local item_type = "item"
	if data.raw.fluid and data.raw.fluid[name] then
		item_type = "fluid"
	end
	return item_type
end

--Same as ingredient, but has support for amount_min, amount_max and probability
function yi.lib.item.result_simple(inputs)
	local item = {}

	if type(inputs) == "table" then
		if inputs.name and type(inputs.name) == "string" then
			item.name = inputs.name
		else
			log(debug.traceback())
			log("Unable to determine a result name")
			return nil
		end

		if inputs.amount and type(inputs.amount) == "number" then
			item.amount = inputs.amount
		elseif inputs.amount_min and inputs.amount_max then
			item.amount_min = inputs.amount_min
			item.amount_max = inputs.amount_max
		else
			log(debug.traceback())
			log("Unable to determine a result amount")
			return nil
		end

		if inputs.probability then
			item.probability = inputs.probability
		end

		if inputs.type then
			item.type = inputs.type
		else
			item.type = yi.lib.item.get_basic_type_simple(item.name)
		end

		if item.type ~= "fluid" then
			if item.amount then
				if type(item.amount) ~= "number" or item.amount < 1 then
					item.amount = 1
				else
					item.amount = math.floor(item.amount)
				end
			end
			if item.amount_min then
				item.amount_min = math.floor(item.amount_min or 0)
			end
			if item.amount_max then
				item.amount_max = math.ceil(item.amount_max or 1)
			end
			item.extra_count_fraction = inputs.extra_count_fraction
			item.percent_spoiled = inputs.percent_spoiled
		else
			item.fluidbox_index = inputs.fluidbox_index
			item.temperature = inputs.temperature
		end

		item.ignored_by_stats = inputs.ignored_by_stats
		item.ignored_by_productivity = inputs.ignored_by_productivity
		item.show_details_in_recipe_tooltip = inputs.show_details_in_recipe_tooltip
	end

	-- 2.0 Validation check
	if type(item.name) == "string" and (item.type == "item" or item.type == "fluid") then
		return item
	else
		log(debug.traceback())
		yi.lib.error.result(item)
		return nil
	end
end

function yi.lib.item.result(inputs) --returns a valid result only if the item exists.
	local item = yi.lib.item.result_simple(inputs)
	if item then
		return item
	end
end

function yi.lib.item.remove(list, item)
	if type(list) == "table" and type(item) == "string" then
		for i = #list, 1, -1 do
			if list[i].name == item then
				table.remove(list, i)
			end
		end
	else
		log(debug.traceback())
		yi.lib.error.item(item)
	end
end

function yi.lib.item.bulk_retire(replacement_table)
	-- replacement_table format: { ["old-item"] = "new-item", ... }
	for old_name, new_name in pairs(replacement_table) do
		yi.lib.item.retire(old_name)
		log("Yi-Lib: Retired " .. old_name .. " in favor of " .. new_name)
	end
end

function yi.lib.item.combine(item1_in, item2_in)
	local item = {}
	local item1 = yi.lib.item.result(item1_in)
	local item2 = yi.lib.item.result(item2_in)

	if item1 and item2 then
		item.name = item1.name
		item.type = item1.type

		if item1.amount and item2.amount then
			item.amount = item1.amount + item2.amount
		elseif item1.amount_min and item1.amount_max and item2.amount_min and item2.amount_max then
			item.amount_min = item1.amount_min + item2.amount_min
			item.amount_max = item1.amount_max + item2.amount_max
		end

		if item1.probability and item2.probability then
			item.probability = (item1.probability + item2.probability) / 2
		end

		item.ignored_by_productivity = item1.ignored_by_productivity or item2.ignored_by_productivity
		item.ignored_by_stats = item1.ignored_by_stats or item2.ignored_by_stats
		item.fluidbox_index = item1.fluidbox_index or item2.fluidbox_index

		return item
	else
		return nil
	end
end

function yi.lib.item.add(list, item_in) --increments amount if exists
	local item = yi.lib.item.result(item_in)
	if type(list) == "table" and item then
		local addit = true
		for i, object in pairs(list) do
			if object.name == item.name then
				addit = false
				list[i] = yi.lib.item.combine(object, item)
			end
		end
		if addit then
			table.insert(list, item)
		end
	end
end

local function replace_ingredient(ingredients, old, new, new_type)
	local amount = get_old_quantity(ingredients, old)
	if amount > 0 then
		amount = quantity_convertion(amount, old, new)
		yi.lib.item.remove(ingredients, old)
		-- Using explicit 2.0 table format
		yi.lib.item.add(ingredients, { type = new_type, name = new, amount = amount })
		return true
	end
	return false
end

function yi.lib.item.retire(old_item_name)
	-- 1. Hide the item from all menus and signals
	local p_type = yi.lib.item.get_type(old_item_name)
	if p_type and data.raw[p_type][old_item_name] then
		local item = data.raw[p_type][old_item_name]
		item.hidden = true
		item.factorio_enabled = false -- Prevents it from appearing in various UI lists

		-- 2. Disable Recycling (Space Age specific)
		-- Setting this to nil or false prevents the Recycler from processing it
		item.hidden_in_factoriopedia = true

		-- In 2.0, we can also set the 'subgroup' to a hidden one
		item.subgroup = "other"
	end

	-- 3. Scrub all recipes that produce this item
	for _, recipe in pairs(data.raw.recipe) do
		-- Check if this recipe results in the retired item
		local is_target = false
		if recipe.results then
			for _, result in ipairs(recipe.results) do
				if result.name == old_item_name then
					is_target = true
				end
			end
		elseif recipe.result == old_item_name then
			is_target = true
		end

		if is_target then
			recipe.enabled = false
			recipe.hidden = true
			-- Disable recycling for this specific recipe as well
			recipe.auto_recycle = false
		end
	end
end
--------------------------------------------------------------------------------
-- ERROR HANDLING
--------------------------------------------------------------------------------

if not yi.lib.error then
	yi.lib.error = {}
end

function yi.lib.error.recipe(recipe, name, desc)
	name = name or "Recipe"
	desc = desc or name
	if recipe == nil then
		log(name .. " variable not passed")
	elseif not data.raw.recipe[recipe] then
		log(desc .. " " .. tostring(recipe) .. " does not exist.")
	end
end

function yi.lib.error.item(item, name)
	name = name or "Item"
	if item == nil then
		log(name .. " variable not passed")
	else
		local item_type = yi.lib.item.get_type(item)
		if not item_type then
			log(name .. " " .. tostring(item) .. " not a valid item of any type.")
		end
	end
end

function yi.lib.error.ingredient(ingredient, name)
	name = name or "Ingredient"
	if ingredient == nil then
		log(name .. " variable not passed")
	elseif type(ingredient) == "table" then
		if not ingredient.name then
			log(name .. " missing name")
		end
		if not ingredient.amount then
			log(name .. " missing amount")
		end
	end
end

--------------------------------------------------------------------------------
-- RECIPE FUNCTIONS
--------------------------------------------------------------------------------

function yi.lib.recipe.replace_ingredient(recipe, old, new)
	if type(recipe) == "string" and type(old) == "string" and type(new) == "string" and data.raw.recipe[recipe] then
		local retval = false
		local new_type = yi.lib.item.get_type(new)

		if new_type and data.raw.recipe[recipe].ingredients then
			new_type = new_type == "fluid" and "fluid" or "item"
			if replace_ingredient(data.raw.recipe[recipe].ingredients, old, new, new_type) then
				retval = true
			end
		end
		return retval
	else
		log(debug.traceback())
		yi.lib.error.recipe(recipe)
		return false
	end
end

function yi.lib.recipe.replace_ingredient_in_all(old, new)
	if type(old) == "string" and type(new) == "string" then
		for i, recipe in pairs(data.raw.recipe) do
			yi.lib.recipe.replace_ingredient(recipe.name, old, new)
		end
	end
end

function yi.lib.recipe.add_result(recipe, item_in)
	local item = yi.lib.item.result(item_in)
	if type(recipe) == "string" and data.raw.recipe[recipe] and item then
		data.raw.recipe[recipe].results = data.raw.recipe[recipe].results or {}
		yi.lib.item.add(data.raw.recipe[recipe].results, item)
	else
		yi.lib.error.recipe(recipe)
	end
end

function yi.lib.recipe.remove_result(recipe, item)
	if type(recipe) == "string" and data.raw.recipe[recipe] then
		if data.raw.recipe[recipe].results then
			yi.lib.item.remove(data.raw.recipe[recipe].results, item)
		end
	end
end

-- Usage: yi.lib.recipe.replace_result("recipe-name", "old-item", "new-item", amount)
function yi.lib.recipe.replace_result(recipe, old, new, amount)
	-- 1. Add the new item (defaults to 'item' type)
	yi.lib.recipe.add_result(recipe, { type = "item", name = new, amount = amount })

	-- 2. Remove the old item
	yi.lib.recipe.remove_result(recipe, old)
end

--------------------------------------------------------------------------------
-- ATOMICS LOGIC
--------------------------------------------------------------------------------

if not yi.lib.recipe.atomics then
	yi.lib.recipe.atomics = {}
end

-- Internal helper to generate icons table for Atomics
-- Supports both items and fluids automatically
local function generate_atomics_icon(name, direction, fallback_size)
	local p_type = yi.lib.item.get_type(name)
	local source = p_type and data.raw[p_type][name]

	if not source then
		return nil
	end

	local res = {}
	if source.icons then
		res = util.table.deepcopy(source.icons)
	else
		table.insert(res, {
			icon = source.icon,
			icon_size = source.icon_size or fallback_size or 64,
			scale = 32 / (source.icon_size or fallback_size or 64),
			mipmaps = source.mipmaps,
		})
	end

	local arrow = (direction == "up") and "up-arrow" or "down-arrow"
	table.insert(res, {
		icon = "__Yuoki__/graphics/icons/atomics/atomics-" .. arrow .. ".png",
		icon_size = 128,
		scale = 0.25,
	})
	return res
end

-- Used to make icons for Item -> Unicomp recipes
function yi.lib.recipe.atomics.item_down(icon_name, size)
	return generate_atomics_icon(icon_name, "down", size)
end

-- Used to make icons for Unicomp -> Item recipes
function yi.lib.recipe.atomics.item_up(icon_name, size)
	return generate_atomics_icon(icon_name, "up", size)
end

-- Used to make icons for Fluid -> Unicomp recipes
function yi.lib.recipe.atomics.fluid_down(icon_name, size)
	return generate_atomics_icon(icon_name, "down", size)
end

-- Used to make icons for Unicomp -> Fluid recipes
function yi.lib.recipe.atomics.fluid_up(icon_name, size)
	return generate_atomics_icon(icon_name, "up", size)
end

-- Used to make atomics recipes
-- Usage: yi.lib.recipe.atomics.recipes_make_item("iron-ore", 64, 10, 1, "ore")
--      iron-ore    - item name you want to use for the recipe
--      64          - icon size of existing item
--      10          - how many units of item for the recipe (example 10x iron-ore)
--      1           - how many units of Unicomp is the results (usually this is 1)
--      ore         - sub_group classification this is optional..
--                      (Values: ore, ore-space-age, ore-int)
function yi.lib.recipe.atomics.recipes_make_item(icon_name, size, item_amount, uni_amount, sub_group)
	local item_n = icon_name
	local item_amt = item_amount or 20
	local unicomp = uni_amount or 1

	local groups = {
		["ore"] = { g1 = "j-y-atomics-2", g2 = "j-y-atomics-11" },
		["ore-space-age"] = { g1 = "j-y-atomics-3", g2 = "j-y-atomics-12" },
		["ore-int"] = { g1 = "j-y-atomics-4", g2 = "j-y-atomics-13" },
		["default"] = { g1 = "j-y-atomics-4", g2 = "j-y-atomics-13" },
	}
	local selected = groups[sub_group] or groups["default"]

	local item_recipe = {
		type = "recipe",
		name = "y-ac-" .. item_n .. "2uc",
		localised_name = { "recipe-name.y-ac", { "item-name." .. item_n } },
		order = "a",
		energy_required = 2,
		enabled = true,
		ingredients = { { type = "item", name = item_n, amount = item_amt } },
		results = { { type = "item", name = "y-unicomp-a2", amount = unicomp } },
		main_product = "y-unicomp-a2",
		subgroup = selected.g1,
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_down(item_n, size),
		auto_recycle = false,
		allow_quality = false,
	}
	local uni_recipe = {
		type = "recipe",
		name = "y-ac-uc2" .. item_n,
		localised_name = { "recipe-name.y-ac-uc2", { "item-name." .. item_n } },
		order = "a",
		energy_required = 2.0,
		enabled = true,
		ingredients = { { type = "item", name = "y-unicomp-a2", amount = unicomp } },
		results = { { type = "item", name = item_n, amount = item_amt } },
		main_product = item_n,
		subgroup = selected.g2,
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.item_up(item_n, size),
		auto_recycle = false,
		allow_quality = false,
	}

	data:extend({ item_recipe, uni_recipe })
	return item_recipe, uni_recipe
end

-- Used to make atomics recipes
-- Usage: yi.lib.recipe.atomics.recipes_make_fluid("crude-oil", 64, 80, 1, "fluid")
--      crude-oil   - fluid name you want to use for the recipe
--      64          - icon size of existing item
--      80          - how many units of item for the recipe (example 10x iron-ore)
--      1           - how many units of Unicomp is the results (usually this is 1)
--      fluid       - sub_group classification this is optional..
--                      (Values: fluid, fluid-space-age, fluid-int)
function yi.lib.recipe.atomics.recipes_make_fluid(icon_name, size, item_amount, uni_amount, sub_group)
	local item_n = icon_name
	local item_amt = item_amount or 20
	local unicomp = uni_amount or 1

	local groups = {
		["fluid"] = { g1 = "j-y-atomics-7", g2 = "j-y-atomics-14" },
		["fluid-space-age"] = { g1 = "j-y-atomics-8", g2 = "j-y-atomics-14" },
		["fluid-int"] = { g1 = "j-y-atomics-9", g2 = "j-y-atomics-15" },
		["default"] = { g1 = "j-y-atomics-9", g2 = "j-y-atomics-15" },
	}
	local selected = groups[sub_group] or groups["default"]

	local item_recipe = {
		type = "recipe",
		name = "y-ac-" .. item_n .. "2uc",
		localised_name = { "recipe-name.y-ac", { "fluid-name." .. item_n } },
		order = "a",
		energy_required = 2,
		enabled = true,
		ingredients = { { type = "fluid", name = item_n, amount = item_amt } },
		results = { { type = "item", name = "y-unicomp-a2", amount = unicomp } },
		main_product = "y-unicomp-a2",
		subgroup = selected.g1,
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.fluid_down(item_n, size),
		auto_recycle = false,
		allow_quality = false,
	}
	local uni_recipe = {
		type = "recipe",
		name = "y-ac-uc2" .. item_n,
		localised_name = { "recipe-name.y-ac-uc2", { "fluid-name." .. item_n } },
		order = "a",
		energy_required = 2.0,
		enabled = true,
		ingredients = { { type = "item", name = "y-unicomp-a2", amount = unicomp } },
		results = { { type = "fluid", name = item_n, amount = item_amt } },
		main_product = item_n,
		subgroup = selected.g2,
		category = "yuoki-atomics",
		icons = yi.lib.recipe.atomics.fluid_up(item_n, size),
		auto_recycle = false,
		allow_quality = false,
	}

	data:extend({ item_recipe, uni_recipe })
	return item_recipe, uni_recipe
end

-- Update Atomics recipes with up or down arrow
-- This function requires the source and target types to be declared
function yi.lib.recipe.atomics.update_d_icon(source_type, source_name, target_type, target_name, direction)
	local target = data.raw[target_type] and data.raw[target_type][target_name]
	if not target then
		return
	end

	local new_icons = generate_atomics_icon(source_name, direction)
	if new_icons then
		target.icons = new_icons
		target.icon = nil
		target.icon_size = nil
		target.icon_mipmaps = nil
	end
end

-- Update Atomics recipes with up or down arrow
-- This function does not require the source type to be known
function yi.lib.recipe.atomics.update_auto_icon(source_name, target_name, direction)
	local search_tables =
		{ "item", "fluid", "recipe", "tool", "capsule", "ammo", "gun", "module", "armor", "item-with-entity-data" }
	local t_type = nil

	for _, t in ipairs(search_tables) do
		if data.raw[t] and data.raw[t][target_name] then
			t_type = t
			break
		end
	end

	if t_type then
		yi.lib.recipe.atomics.update_d_icon(nil, source_name, t_type, target_name, direction)
	else
		log("yi.lib smart-error: Could not find target " .. target_name)
	end
end

--------------------------------------------------------------------------------
-- CRUSHING LOGIC
--------------------------------------------------------------------------------

if not yi.lib.recipe.crushing then
	yi.lib.recipe.crushing = {}
end

-- Internal helper to handle layering and shifting for 2.0
local function build_asteroid_grid(input_slots)
	local res = {}
	for _, slot in ipairs(input_slots) do
		local p_type = yi.lib.item.get_type(slot.name)
		local source = p_type and data.raw[p_type][slot.name]

		if source then
			if source.icons then
				for _, layer in ipairs(source.icons) do
					local l = util.table.deepcopy(layer)
					l.scale = (l.scale or (32 / (source.icon_size or 64))) * slot.scale
					l.shift = {
						(l.shift and l.shift[1] or 0) + slot.shift[1],
						(l.shift and l.shift[2] or 0) + slot.shift[2],
					}
					table.insert(res, l)
				end
			else
				table.insert(res, {
					icon = source.icon,
					icon_size = source.icon_size or slot.size,
					scale = slot.scale,
					shift = slot.shift,
					mipmaps = source.mipmaps,
				})
			end
		end
	end
	return res
end

-- Layout: 1 Background type + 1 Result
-- Replicates the overlapping cluster style
function yi.lib.recipe.crushing.asteroid_1_plus_1(icon_bg, size_bg, icon_main, size_main)
	local slots = {
		{ name = icon_bg, size = size_bg or 64, shift = { -8, -8 }, scale = 0.2 },
		{ name = icon_main, size = size_main or 64, shift = { 0, 0 }, scale = 0.35 },
	}
	return build_asteroid_grid(slots)
end

-- Layout: 2 Background types + 1 Result
-- Matches your original visual 'asteroid_2' perfectly
function yi.lib.recipe.crushing.asteroid_2_plus_1(icon_bg1, size_bg1, icon_bg2, size_bg2, icon_main, size_main)
	local slots = {
		{ name = icon_bg1, size = size_bg1 or 64, shift = { -8, -8 }, scale = 0.2 },
		{ name = icon_bg1, size = size_bg1 or 64, shift = { 8, -8 }, scale = 0.2 },
		{ name = icon_bg2, size = size_bg2 or 64, shift = { -8, 8 }, scale = 0.2 },
		{ name = icon_bg2, size = size_bg2 or 64, shift = { 8, 8 }, scale = 0.2 },
		{ name = icon_main, size = size_main or 64, shift = { 0, 0 }, scale = 0.35 },
	}
	return build_asteroid_grid(slots)
end

-- Layout: 3 Background types + 1 Result
function yi.lib.recipe.crushing.asteroid_3_plus_1(icon1, s1, icon2, s2, icon3, s3, icon_main, s_main)
	local slots = {
		{ name = icon1, size = s1 or 64, shift = { -8, -8 }, scale = 0.2 },
		{ name = icon2, size = s2 or 64, shift = { 8, -8 }, scale = 0.2 },
		{ name = icon3, size = s3 or 64, shift = { 0, 8 }, scale = 0.2 },
		{ name = icon_main, size = s_main or 64, shift = { 0, 0 }, scale = 0.35 },
	}
	return build_asteroid_grid(slots)
end

function yi.lib.recipe.crushing.asteroid_2(icon1, s1, icon2, s2, icon3, s3)
	return yi.lib.recipe.crushing.asteroid_2_plus_1(icon1, s1, icon2, s2, icon3, s3)
end

--------------------------------------------------------------------------------
-- ENERGY QUALITY
--------------------------------------------------------------------------------

-- Wrap the quality multiplier in a function or a safe check
function yi.lib.get_quality_multiplier()
	-- Safe check for 2.0 prototypes global
	local is_space_age = false
	if _G["prototypes"] and prototypes.item["quality-module"] then
		is_space_age = true
	end

	if is_space_age then
		return {
			normal = 1,
			uncommon = 1.15,
			rare = 1.25,
			epic = 1.35,
			legendary = 1.45,
		}
	end
	return { normal = 1 }
end

-- Update the variable using the safe function
yi_energy_usage_quality_multiplier = yi.lib.get_quality_multiplier()
--------------------------------------------------------------------------------
-- MIGRATION
--------------------------------------------------------------------------------

yi.lib.migration = {}

function yi.lib.migration.bulk_replace(replacement_table)
	for old_name, new_name in pairs(replacement_table) do
		yi.lib.migration.global_replace_item(old_name, new_name)
	end
	yi.lib.migration.remove_unknown_ghosts()
end

-- Global item migration function for Factorio 2.0
-- Handles ground, inventories, belts, filters, and active recipes.
function yi.lib.migration.global_replace_item(old_name, new_name)
	local new_prototype = prototypes.item[new_name]
	if not new_prototype then
		log("Migration Error: Target item " .. new_name .. " does not exist.")
		return
	end

	for _, surface in pairs(game.surfaces) do
		local entities = surface.find_entities_filtered({
			type = {
				"container",
				"logistic-container",
				"assembling-machine",
				"furnace",
				"inserter",
				"splitter",
				"transport-belt",
				"underground-belt",
				"item-entity",
				"character",
				"cargo-wagon",
				"loader",
				"loader-1x1",
				"logistic-robot",
				"construction-robot",
			},
		})

		for _, entity in ipairs(entities) do
			-- A. Items on Ground
			if entity.type == "item-entity" then
				if entity.stack and entity.stack.valid_for_read and entity.stack.name == old_name then
					local pos = entity.position
					local count = entity.stack.count
					entity.destroy()
					surface.create_entity({
						name = "item-on-ground",
						stack = { name = new_name, count = count },
						position = pos,
					})
				end

			-- B. Check Transport Belts / Splitters / Loaders
			elseif
				entity.type == "transport-belt"
				or entity.type == "underground-belt"
				or entity.type == "splitter"
				or entity.type == "loader"
				or entity.type == "loader-1x1"
			then
				local line_count = entity.get_max_transport_line_index()
				for i = 1, line_count do
					local line = entity.get_transport_line(i)
					local count = line.get_item_count(old_name)
					if count > 0 then
						line.remove_item({ name = old_name, count = count })
						line.insert_at_back({ name = new_name, count = count })
					end
				end

				if entity.type == "splitter" then
					-- 1. Clear stuck items in the internal buffer
					for i = 1, 2 do
						local inv = entity.get_inventory(i)
						if inv and inv.valid then
							local count = inv.get_item_count(old_name)
							if count > 0 then
								inv.remove({ name = old_name, count = count })
								inv.insert({ name = new_name, count = count })
							end
						end
					end

					-- 2. Update the Filter
					-- In 2.0, the engine treats the filter as a "SignalID"
					if entity.splitter_filter and entity.splitter_filter.name == old_name then
						local side = entity.splitter_output_priority
						entity.splitter_filter = nil -- Reset first
						-- Use the most basic 2.0 compatible table
						entity.splitter_filter = { type = "item", name = new_name }
						entity.splitter_output_priority = side
					end
				end

			-- C. Inserter Filters
			elseif entity.type == "inserter" then
				for slot = 1, entity.filter_slot_count do
					if entity.get_filter(slot) == old_name then
						entity.set_filter(slot, new_name)
					end
				end

			-- D. Logistic Containers
			elseif entity.type == "logistic-container" then
				if entity.prototype.logistic_mode == "storage" then
					if entity.storage_filter and entity.storage_filter.name == old_name then
						entity.storage_filter = new_prototype
					end
				end

				local logic_point = entity.get_logistic_point(0)
				if logic_point then
					for i = 1, logic_point.sections_count do
						local section = logic_point.get_section(i)
						if section then
							for j = 1, section.filters_count do
								local filter = section.get_slot(j)
								if filter and filter.value and filter.value.name == old_name then
									section.set_slot(j, { value = new_name, min = filter.min, max = filter.max })
								end
							end
						end
					end
				end
			end

			-- E. Inventory Scrub
			for i = 1, entity.get_max_inventory_index() do
				local inv = entity.get_inventory(i)
				if inv and inv.valid then
					local count = inv.get_item_count(old_name)
					if count > 0 then
						local removed = inv.remove({ name = old_name, count = count })
						inv.insert({ name = new_name, count = removed })
					end
				end
			end
		end
	end

	-- F. Player Hand and Logistics
	for _, player in pairs(game.players) do
		if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == old_name then
			player.cursor_stack.set_stack({ name = new_name, count = player.cursor_stack.count })
		end
		if player.character then
			local lp = player.character.get_logistic_point(0)
			if lp then
				for i = 1, lp.sections_count do
					local section = lp.get_section(i)
					if section then
						for j = 1, section.filters_count do
							local f = section.get_slot(j)
							if f and f.value and f.value.name == old_name then
								section.set_slot(j, { value = new_name, min = f.min, max = f.max })
							end
						end
					end
				end
			end
		end
	end
end

-- Global fluid migration function
-- Handles pipes, tanks, and internal fluidboxes of machines.
function yi.lib.migration.global_replace_fluid(old_name, new_name)
	if not prototypes.fluid[new_name] then
		log("Migration Error: Target fluid " .. new_name .. " does not exist.")
		return
	end

	for _, surface in pairs(game.surfaces) do
		-- Find everything that can hold fluids
		local entities = surface.find_entities_filtered({
			type = {
				"pipe",
				"pipe-to-ground",
				"storage-tank",
				"assembling-machine",
				"furnace",
				"generator",
				"boiler",
				"pump",
				"fluid-wagon",
				"offshore-pump",
			},
		})

		for _, entity in ipairs(entities) do
			-- Loop through all fluidboxes in the entity
			for i = 1, #entity.fluidbox do
				local box = entity.fluidbox[i]
				if box and box.name == old_name then
					-- Store the amount and temperature
					local amount = box.amount
					local temp = box.temperature

					-- Replace the fluid
					entity.fluidbox[i] = {
						name = new_name,
						amount = amount,
						temperature = temp,
					}
				end
			end
		end
	end
	log("Yi Migration: Successfully replaced fluid " .. old_name .. " with " .. new_name)
end

function yi.lib.migration.fix_splitters(old_name, new_name)
	local new_proto = prototypes.item[new_name]
	if not new_proto then
		return
	end

	for _, surface in pairs(game.surfaces) do
		local splitters = surface.find_entities_filtered({ type = "splitter" })
		for _, splitter in ipairs(splitters) do
			-- Check if the filter is set to the old item
			if splitter.splitter_filter and splitter.splitter_filter.name == old_name then
				-- 1. Store the exact priority state
				local current_priority = splitter.splitter_output_priority

				-- 2. Clear both to "unlock" the state
				splitter.splitter_output_priority = "none"
				splitter.splitter_filter = nil

				-- 3. Set the new item
				splitter.splitter_filter = new_proto

				-- 4. Re-apply the priority (e.g., "right")
				-- This order is critical in 2.0 to force the UI to update
				splitter.splitter_output_priority = current_priority
			end
		end
	end
end

function yi.lib.migration.remove_unknown_ghosts()
	for _, surface in pairs(game.surfaces) do
		-- FIXED: Check for type "entity-ghost" and "tile-ghost" specifically
		local ghosts = surface.find_entities_filtered({ type = { "entity-ghost", "tile-ghost" } })
		for _, ghost in ipairs(ghosts) do
			if not ghost.ghost_prototype then
				ghost.destroy()
			end
		end

		local combinators = surface.find_entities_filtered({ type = "constant-combinator" })
		for _, entity in ipairs(combinators) do
			local control = entity.get_control_behavior()
			if control then
				for i = 1, control.sections_count do
					local section = control.get_section(i)
					if section then
						for j = 1, section.filters_count do
							local slot = section.get_slot(j)
							if slot and slot.value and slot.value.name and not prototypes.item[slot.value.name] then
								section.clear_slot(j)
							end
						end
					end
				end
			end
		end
	end
end
