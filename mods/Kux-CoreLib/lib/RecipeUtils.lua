require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.RecipeUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.RecipeUtils
-- replaces script (LuaBootstrap) for all event actions
local RecipeUtils = {
	__class  = "KuxCoreLib.RecipeUtils",
	__guid   = "08964aca-98c4-4e23-bf18-6d6e6b982e08",
	__origin = "Kux-CoreLib/lib/RecipeUtils.lua",
	__writableMembers={"getDisplayName","registerName"}
}
if not KuxCoreLib.__classUtils.ctor(RecipeUtils) then return self end
-----------------------------------------------------------------------------------------------------------------------
local FactorioDatabase = KuxCoreLib.require.FactorioDatabase
local LocalizationUtils = KuxCoreLib.require.LocalizationUtils
local Version = KuxCoreLib.require.Version

function RecipeUtils.generateRecipeCatalog()
	local fdb = FactorioDatabase
	fdb.prototypes.recipes = {} ---@diagnostic disable-line: missing-fields
	local set = fdb.prototypes.recipes
	fdb.prototypes.recipes.rows = {}
	local rows = fdb.prototypes.recipes.rows
	fdb.prototypes.recipe = fdb.prototypes.recipes.rows -- alias

	set.idx_item_product_recipe_names = {} -- by_item_products
	set.idx_fluid_product_recipe_names = {} --by_fluid_products
	set.idx_item_ingedient_recipe_names = {} --by_item_ingredients
	set.idx_fluid_ingedient_recipe_names = {} --by_fluid_ingredients
	set.idx_tile_ingedient_recipe_names = {} --by_tile_ingredients
	set.idx_entity_ingedient_recipe_names = {} --by_entity_ingredients
	set.idx_research_product_recipe_names = {} --by_research_products

	set.by_item_products = set.idx_item_product_recipe_names-- alias
	set.by_fluid_products = set.idx_fluid_product_recipe_names-- alias
	set.by_item_ingredients = set.idx_item_ingedient_recipe_names-- alias
	set.by_fluid_ingredients = set.idx_fluid_ingedient_recipe_names-- alias
	set.by_tile_ingredients = set.idx_tile_ingedient_recipe_names-- alias
	set.by_entity_ingredients = set.idx_entity_ingedient_recipe_names-- alias
	set.by_research_products = set.idx_research_product_recipe_names-- alias

	local num_items = 0
	for item_name, value in pairs(prototypes.item) do
		num_items=num_items+1
		set.idx_item_product_recipe_names[item_name] = {}
		set.idx_item_ingedient_recipe_names[item_name] = {}
	end

	local num_fluids = 0
	for fluid_name, value in pairs(prototypes.fluid) do
		num_fluids=num_fluids+1
		set.idx_fluid_product_recipe_names[fluid_name] = set.idx_fluid_product_recipe_names[fluid_name] or {}
		set.idx_fluid_ingedient_recipe_names[fluid_name] = set.idx_fluid_ingedient_recipe_names[fluid_name] or {}
	end

	set.count_total=0

	local function add(recipe_name, recipe)
		set.count_total = set.count_total+1
		rows[recipe_name] = recipe
		for _, ingredient in pairs(recipe.ingredients) do
			local index_name = "by_"..ingredient.type.."_ingredients"
			set[index_name][ingredient.name] = set[index_name][ingredient.name] or {}
			table.insert(set[index_name][ingredient.name], recipe_name)
		end
		for _, product in pairs(recipe.products) do
			if product.type == "research-progress" then
				table.insert(set.idx_item_product_recipe_names[product.research_item], recipe_name)
				set.idx_research_product_recipe_names[product.research_item] = set.idx_research_product_recipe_names[product.research_item] or {}
				table.insert(set.idx_research_product_recipe_names[product.research_item], recipe_name)
			else
				table.insert(set["by_"..product.type.."_products"][product.name], recipe_name)
			end
		end
	end

	for recipe_name, recipe in pairs(prototypes.recipe) do
		add(recipe_name, recipe)
	end
	for recipe_name, recipe in pairs(RecipeUtils.getImplicitRecipes()) do
		add(recipe_name, recipe)
	end

	local num_research_items = #Dictionary.getKeys(set.idx_research_product_recipe_names)
	print(string.format("Factorium: %d items, %d fluids, %d recipes, %d research item", num_items, num_fluids, set.count_total, num_research_items))
end

---
---@param player LuaPlayer
---@param entity_name string
function is_entity_enabled(player, entity_name)
	if entity_name=="character" then return true end
	--TODO: works only correct if the item has the same name as the entity
	local recipe_names = fdb.prototypes.recipes.idx_item_product_recipe_names[entity_name] or {}
	for _, recipe_name in ipairs(recipe_names) do
		local r = player.force.recipes[recipe_name]
		if r and r.enabled and not r.hidden then return true end
	end
	return false
end

---@param player LuaPlayer
---@param recipe LuaRecipePrototype?
---@return MadeInInfo[]
function RecipeUtils.made_in(player, recipe)
	if not recipe then return {} end
	local list = {}
	local function default_sort(a, b)
		if a.entity_name == "character" then return true end if b.entity_name == "character" then return false end
		if a.entity_enabled ~= b.entity_enabled then return a.entity_enabled and not b.entity_enabled end
		return a.crafting_time > b.crafting_time
	end

	---@param entity LuaEntityPrototype
	---@return number
	local function get_crafting_speed(entity)
		if entity.type == "character" then
			return 1
		elseif entity.type == "offshore-pump" then
			return 60 * entity.get_pumping_speed("normal")
		elseif entity.type == "mining-drill" then
			return 60 * (entity.mining_speed or 1)
			--TODO: missing API get_mining_speed
		elseif entity.get_crafting_speed then
			return entity.get_crafting_speed("normal")
		else
			return 1
		end
	end

	---@param crafting_entity LuaEntityPrototype The entity in which the product is made
	---@return number
	local function get_crafting_time(crafting_entity)
		local speed = get_crafting_speed(crafting_entity)
		if crafting_entity.type == "character" then
			if prototypes.recipe_category[recipe.category] then -- crafting
				return recipe.energy / speed -- *(1 + total_speed_bonus))
			elseif prototypes.resource_category[recipe.category] then --mining
				local resource = prototypes.entity[recipe.ingredients[1].name]
				return resource.mineable_properties.mining_time / speed
			else -- offshore?
				return 0
			end
		elseif crafting_entity.type == "offshore-pump" then
			return 1 / speed
		elseif crafting_entity.type == "mining-drill" then
			local resource = prototypes.entity[recipe.ingredients[1].name]
			return resource.mineable_properties.mining_time / speed
		elseif crafting_entity.get_crafting_speed then
			return recipe.energy / speed
		else
			return 1
		end
	end

	local function add(entity_name)
		local entity = prototypes.entity[entity_name]
		local crafting_time = get_crafting_time(entity)
		local crafting_time_rounded = math.floor(crafting_time * 100 + 0.5) / 100
		local time_tooltip = entity.name=="character" and {"", {"Kux-GuiLib.Time_to_craft_with_character"}, ": ", crafting_time_rounded}
			or {"", {"Kux-GuiLib.Time_to_craft_in_building"}, ": ", crafting_time_rounded}
		local entity_enabled = is_entity_enabled(player, entity_name)
		local style_name = entity_enabled and "inventory_slot" or "red_inventory_slot"

		---@type MadeInInfo
		local madeIn ={
			__class = "MadeInInfo",
			crafting_time = crafting_time,
			crafting_time_rounded = crafting_time_rounded,
			entity_name = entity_name,
			entity = entity,
			entity_enabled = entity_enabled,
			localised_name = LocalizationUtils.localised_name(entity),
			time_tooltip = time_tooltip,
			style_name = style_name,
		}
		table.insert(list, madeIn)
	end


	-- crafting
	local categories = Version.compare(script.active_mods.base, "2.0.49")>=0 and recipe.additional_categories or {}
	table.insert(categories, 1, recipe.category)
	for _, category in ipairs(categories) do
		entities = fdb.prototypes.entities.by_crafting_category[category] or {}
		for _, entity_name in pairs(entities) do add(entity_name) end
	end


	-- mining
	entities = fdb.prototypes.entities.by_resource_category[recipe.category] or {}
	for _, entity_name in pairs(entities) do
		add(entity_name)
	end
	-- offshore
	if recipe.category=="offshore" then
		entities = fdb.prototypes.entities.by_type["offshore-pump"] or {}
		for _, entity_name in pairs(entities) do
			add(entity_name)
		end
	end

	table.sort(list, default_sort)
	return list
end

---@param recipe LuaRecipe|LuaRecipePrototype|nil
---@param enabled boolean? override enabled state
---@return string
function RecipeUtils.recipe_label_style(recipe, enabled)
	if not recipe then return "bold_grey_label" end
	if recipe.hidden then return "bold_grey_label" end
	enabled = enabled ~= nil and enabled or recipe.enabled
	if not enabled then return "bold_red_label" end
	return "bold_green_label"
end

---@param recipe LuaRecipe|LuaRecipePrototype|nil
---@param enabled boolean? override enabled state
---@return string
function RecipeUtils.recipe_slot_style(recipe, enabled)
	if not recipe then return "slot" end
	if recipe.hidden then return "slot" end
	enabled = enabled ~= nil and enabled or recipe.enabled
	if not enabled then return "red_slot" end
	return "green_slot"
end

---@param player LuaPlayer
---@param recipe_name string
function RecipeUtils.getRecipeInfo(player, recipe_name)
	if not recipe_name then return nil end
	local recipe = player.force.recipes[recipe_name]
	local prototype = recipe and recipe.prototype or nil
	recipe = recipe or fdb.prototypes.recipe[recipe_name]
	prototype = prototype or recipe


	---@type RecipeInfo
	local info = {
		__class        = "RecipeInfo",
		name           = recipe_name,
		prototype      = prototype,
		localised_name = LocalizationUtils.localised_name(recipe),
		recipe         = recipe,
		enabled        = recipe.enabled,
		hidden         = recipe.hidden,
		name_style     = RecipeUtils.recipe_label_style(recipe),
		button_style   = recipe.enabled and "inventory_slot" or "red_inventory_slot",
		subgroup_order = recipe.subgroup.order,
		order		   = recipe.order,
	}
	return info
end

---@param a RecipeInfo
---@param b RecipeInfo
---@return boolean
local function default_recipe_sort(a,b)
	if a.hidden ~= b.hidden then return not a.hidden end
	if a.enabled ~= b.enabled then return a.enabled end
	if a.subgroup_order ~= b.subgroup_order then return a.subgroup_order < b.subgroup_order end
	if a.order ~= b.order then return a.order < b.order end
	return a.name < b.name
end

function RecipeUtils.sort_recipes(t, plx)
	local infos = {}
	for _, value in ipairs(t) do
		local info = RecipeUtils.getRecipeInfo(plx, value)
		table.insert(infos, info)
	end
	table.sort(infos, default_recipe_sort)
	local recipe_names = Table.select(infos, "name")
	return recipe_names
end

---
---@param t string[]
---@param options {show_disabled:boolean, show_hidden:boolean}
---@return string[]
function RecipeUtils.filter_and_sort_recipes(player, t, options)

	local infos = {}
	for _, value in ipairs(t) do
		local info = RecipeUtils.getRecipeInfo(player, value)
		if not info then goto next end
		if options.show_disabled==false and not info.enabled then goto next end
		if options.show_hidden==false and info.hidden then goto next end
		table.insert(infos, info)
		::next::
	end
	table.sort(infos, default_recipe_sort)
	local recipe_names = Table.select(infos, "name")
	return recipe_names
end

---@param pt LuaEntityPrototype|LuaTilePrototype
---@return LuaRecipePrototype
local function new_recipe_prototype(pt)
	local minable = pt.object_name=="LuaEntityPrototype" and pt.mineable_properties and pt.mineable_properties.minable
	local offshore = pt.object_name=="LuaTilePrototype"
	local elemId = assert(toElemID(pt))
	local recipe = { ---@type LuaRecipePrototype
		type = "recipe",
		name = pt.name,
		localised_name = pt.localised_name or {minable and "entity" or "fluid" ..".".. pt.name},
		enabled = true,
		hidden = false,
		ingredients = { { type = elemId.type, name = elemId.name, amount = 1 } },---@diagnostic disable-line: assign-type-mismatch
		products = (minable and pt.mineable_properties.products or {}) or { { name = pt.fluid.name, amount = 1, type = "fluid" } } ,
		category = (minable and pt.resource_category) or (offshore and "offshore") or error("category is unknown"),
		additional_categories = {}, -- NEW in 2.0.49
		has_category = function () error("not implemented")	end,-- TODO: NEW in 2.0.49
		group = pt.group,
		subgroup = pt.subgroup,
		order = pt.order,
		energy = 1,
		allow_as_intermediate = true, allow_decomposition = true, allow_inserter_overload = false,
		allow_intermediates=false, always_show_made_in = true, always_show_products = true,
		crafting_machine_tints = {}, emissions_multiplier = 1, hidden_from_flow_stats = false,
		hidden_from_player_crafting = false, hide_from_flow_stats = false, hide_from_player_crafting = true,
		hide_from_signal_gui = false, maximum_productivity = 1, overload_multiplier=1,
		preserve_products_in_machine_output = false, request_paste_multiplier = 1,
		show_amount_in_title = true, unlock_results = false,
		hidden_in_factoriopedia = pt.hidden_in_factoriopedia,
		is_parameter = false, parameter = false, valid = true,
		object_name = "LuaRecipePrototype", --if type(recipe)=="table"=> virtual|"userdata"=> real prototype

		mining_time = minable and pt.mineable_properties.mining_time
	}
	if minable and pt.mineable_properties.required_fluid then
		table.insert(recipe.ingredients, {
			type   = 'fluid',
			name   = pt.mineable_properties.required_fluid,
			amount = pt.mineable_properties.fluid_amount or 1,
		})
	end
	return recipe
end


function RecipeUtils.getImplicitRecipes()
	local recipes = {}
	--print("Implicit recipes for items")
	for _, proto in pairs(prototypes.entity) do
		if not proto.mineable_properties or not proto.resource_category then goto next_prototype end
		local recipe = new_recipe_prototype(proto)
		recipes[recipe.name] = recipe
		::next_prototype::
	end

	--print("Implicit recipes for tiles")
	local seen = {}
	for _, proto in pairs(prototypes.tile) do
		if not proto.fluid then goto next_prototype end
		if seen[proto.fluid.name] then goto next_prototype end
		local recipe = new_recipe_prototype(proto)
		recipes[recipe.name] = recipe
		::next_prototype::
	end
	return recipes
end


-----------------------------------------------------------------------------------------------------------------------
return RecipeUtils
-----------------------------------------------------------------------------------------------------------------------


--- @class RecipeInfo
--- ----------------
--- @field __class "RecipeInfo"
--- @field name string
--- @field localised_name LocalisedString
--- @field enabled boolean
--- @field hidden boolean
--- @field subgroup_order string
--- @field order string
--- @field button_style string
--- @field name_style string
--- @field prototype LuaRecipePrototype


--- @class MadeInInfo
--- ----------------
--- @field __class "MadeInInfo"
--- @field crafting_time number
--- @field crafting_time_rounded number
--- @field entity_name string
--- @field entity LuaEntityPrototype
--- @field localised_name LocalisedString
--- @field time_tooltip LocalisedString
--- @field style_name string
--- @field entity_enabled boolean


--- @class RecipeCatalog --fdb.prototypes.recipes
--- --------------------
--- @field __class "RecipeCatalog"
--- @field rows table<string, LuaRecipePrototype>  recipe_name -> recipe]
--- @field count_total number                      total number of prototypes in the catalog
---
--- @field idx_item_product_recipe_names table<string, string[]>      index by item products
--- @field idx_fluid_product_recipe_names table<string, string[]>     index by fluid products
--- @field idx_item_ingedient_recipe_names table<string, string[]>    index by item ingredients
--- @field idx_fluid_ingedient_recipe_names table<string, string[]>   index by fluid ingredients
--- @field idx_entity_ingedient_recipe_names table<string, string[]>  index by entity ingredients
--- @field idx_tile_ingedient_recipe_names table<string, string[]>    index by tile ingredients
--- @field idx_research_product_recipe_names table<string, string[]>  index by research products
---
--- @field by_item_products table<string, string[]>                   index by item products
--- @field by_fluid_products table<string, string[]>                  index by fluid products
--- @field by_item_ingredients table<string, string[]>                index by item ingredients
--- @field by_fluid_ingredients table<string, string[]>               index by fluid ingredients
--- @field by_tile_ingredients table<string, string[]>                index by tile ingredients
--- @field by_entity_ingredients table<string, string[]>              index by entity ingredients
--- @field by_research_products table<string, string[]>               index by research products
---