require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.ElementUtils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.ElementUtils
local ElementUtils = {
	__class  = "KuxCoreLib.ElementUtils",
	__guid   = "08964aca-98c4-4e23-bf18-6d6e6b982e08",
	__origin = "Kux-CoreLib/lib/ElementUtils.lua",
}
if not KuxCoreLib.__classUtils.ctor(ElementUtils) then return self end
-----------------------------------------------------------------------------------------------------------------------
local TranslationService = KuxCoreLib.require.TranslationService
local LuaGenericPrototype = KuxCoreLib.require.LuaGenericPrototype

local idx_prototype_type_category = {} ---@type table<string, string>
local idx_prototype_category_types = {} ---@type table<string, string[]>

---@enum PrototypeCategories.name = {

---Member names of LuaPrototypes
local PrototypeCategories = {
	"achievement", "active_trigger", "airborne_pollutant", "ammo_category", "asteroid_chunk", "autoplace_control",
	"burner_usage", "collision_layer", "custom_event", "custom_input", "damage", "decorative", "entity", "equipment",
	"equipment_category", "equipment_grid", "fluid", "font", "fuel_category", "item", "item_group", "item_subgroup",
	"map_gen_preset", "mod_setting", "module_category", "named_noise_expression", "named_noise_function", "particle",
	"procession", "procession_layer_inheritance_group", "quality", "recipe", "recipe_category", "resource_category",
	"shortcut", "space_connection", "space_location", "style", "surface", "surface_property", "technology", "tile",
	"trivial_smoke", "virtual_signal"
}

ElementUtils.PrototypeSelectorCategories = {
	"item",	"tile", "entity","virtual_signal" ,"fluid" ,"recipe","decorative","item_group","achievement","equipment","technology"
}
local PrototypeSelectorCategoriesWithQuality = {
	"item",	"entity","recipe","equipment", -- item-with-quality", "entity-with-quality"...
}

local prototypes_without_type = {font = true, map_gen_preset=true, style = true}

do
	local temp = {}
	for _, cat_name in pairs(PrototypeCategories) do
		if prototypes_without_type[cat_name] then goto next_cat end
		idx_prototype_type_category[cat_name] = cat_name
		local cat = prototypes[cat_name]
		for _, v in pairs(cat) do
			idx_prototype_type_category[v.type] = cat_name
			idx_prototype_category_types[cat_name] = idx_prototype_category_types[cat_name] or {}
			if not temp[v.type] then
				temp[v.type] = true
				table.insert(idx_prototype_category_types[cat_name], v.type)
			end
		end
		::next_cat::
	end
end

---
---@param t any
---@param field "group"|"subgroup"|nil
local function sort(t, field)
	table.sort(t, function(a, b)
		if type(a) == "string" then
			local a_order = prototypes["item_"..field][a].order
			local b_order = prototypes["item_"..field][b].order
			if a_order ~= b_order then return a_order < b_order end
			return a < b
		end

		if a.order ~= b.order then return a.order < b.order end
		return a.name < b.name
	end)
end

---@type table<string, table<string, (LuaItemPrototype|LuaFluidPrototype)[]>>>
local idx_group_subgroup_elements = {}
for _, v in pairs(prototypes.item_group) do idx_group_subgroup_elements[v.name] = {} end
for _, v in pairs(prototypes.item_subgroup) do idx_group_subgroup_elements[v.group.name][v.name] = {} end
for _, v in pairs(prototypes.item) do table.insert(idx_group_subgroup_elements[v.subgroup.group.name][v.subgroup.name],v) end
for _, v in pairs(prototypes.fluid) do table.insert(idx_group_subgroup_elements[v.subgroup.group.name][v.subgroup.name],v) end

---@type table<string, table<table<(LuaItemPrototype|LuaFluidPrototype)[]>>>
elements_grouped = {}

for groupName, subgroups in pairs(idx_group_subgroup_elements) do
	local subgroupNames = {}---@type string[]
	for subgroupName in pairs(subgroups) do table.insert(subgroupNames, subgroupName) end
	sort(subgroupNames,"subgroup")

	local subgroupList = {}---@type table<(LuaItemPrototype|LuaFluidPrototype)[]>
	for _, name in ipairs(subgroupNames) do
		local elements = subgroups[name]
		if #elements > 0 then
			sort(elements)
			table.insert(subgroupList, elements)
		end
	end

	if #subgroupList > 0 then elements_grouped[groupName] = subgroupList end
end

---@class ElementFilter
--- --------------------
---@field search_text string  the text to search for name
---@field locale string       the locale to use for localized name
---@field show_disabled boolean    show disabled prototypes (recipe.enabled=false)
---@field show_hidden boolean      show hidden prototypes


---@param catalog ElementCatalog the grouped prototypes
---@param element KuxCoreLib.LuaGenericPrototype
---@param filter ElementFilter
---@return boolean #true if the element matches the filter, false otherwise
local function apply_filter(catalog, group_name, subgroup_idx, element, filter )
	local group = catalog.rows[group_name]
	local subgroup =group.rows[subgroup_idx]

	local inc = 1
	element.tags.filter_match = true
	if filter.search_text then
		local name = TranslationService.loc(element.localised_name, filter.locale)
		element.tags.filter_match = name:lower():find(filter.search_text:lower(),1,true)~=nil
		if not element.tags.filter_match then inc = 0 end
	end
	if filter.show_disabled==false and not element.is_craftable then inc = 0 end
	if filter.show_hidden==false and element.hidden then inc = 0 end

	catalog.count_total = catalog.count_total + 1
	catalog.count_filtered = catalog.count_filtered + inc

	group.count_total = group.count_total + 1
	group.count_filtered = group.count_filtered + inc

	subgroup.count_total = subgroup.count_total + 1
	subgroup.count_filtered = subgroup.count_filtered + inc

	return inc==1
end

---@param player LuaPlayer
---@param filter ElementFilter
---@return ElementCatalog #return the grouped prototypes
function ElementUtils.getAllElementsFiltered(player, filter)
	local catalog = {count_total=0, count_filtered=0, rows={}, idx_row_index_group_name={},idx_type_name_key={}}---@type ElementCatalog
	local row_index=0
	for group_name, group in pairs(elements_grouped) do
		row_index = row_index + 1
		catalog.idx_row_index_group_name[row_index] = group_name
		for subgroup_idx, subgroup in ipairs(group) do
			for index, element in ipairs(subgroup) do
				local pt = LuaGenericPrototype.new(element)
				pt.is_craftable = ElementUtils.isCraftable(player.force--[[@as LuaForce]], pt.name, pt.type)
				local groupRecord = catalog.rows[group_name] or {
					name = group_name, index=index, count_total=0, count_filtered=0, rows={}}--[[@as GroupRecord]]
				catalog.rows[group_name] = groupRecord
				local subGroupRecord = groupRecord.rows[subgroup_idx] or {count_total=0, count_filtered=0, rows={}} --[[@as SubGroupRecord]]
				groupRecord.rows[subgroup_idx] = subGroupRecord
				subGroupRecord.rows[index] = pt

				pt.tags.filter_match = apply_filter(catalog, group_name, subgroup_idx, pt, filter)

				catalog.idx_type_name_key = catalog.idx_type_name_key or {}
				catalog.idx_type_name_key[pt.supertype] = catalog.idx_type_name_key[pt.supertype] or {}
				catalog.idx_type_name_key[pt.supertype][element.name] = {group_name, subgroup_idx, index}
			end
		end
	end
	return catalog
end

---@param elementsCatalog ElementCatalog the grouped prototypes generated by getAllElementsFiltered
---@param filter ElementFilter
function ElementUtils.updateAllElementsFiltered(elementsCatalog, filter)
	elementsCatalog.count_filtered = 0
	for group_name, group in pairs(elementsCatalog.rows) do
		group.count_filtered = 0
		for subgroup_idx, subgroup in ipairs(group.rows) do
			subgroup.count_filtered = 0
			for element_index, element in ipairs(subgroup.rows) do
				element.tags.filter_match = apply_filter(elementsCatalog, group_name, subgroup_idx, element, filter)
			end
		end
	end
end

---@param elementsCatalog ElementCatalog the grouped prototypes generated by getAllElementsFiltered
---@param player LuaPlayer
function ElementUtils.updateProperties(elementsCatalog, player)
	elementsCatalog.count_filtered = 0
	for group_name, group in pairs(elementsCatalog.rows) do
		group.count_filtered = 0
		for subgroup_idx, subgroup in ipairs(group.rows) do
			subgroup.count_filtered = 0
			for element_index, element in ipairs(subgroup.rows) do
				element.is_craftable = ElementUtils.isCraftable(player.force--[[@as LuaForce]], element.name, element.type)
			end
		end
	end
end

---Gets the category/group name of the given type
---@param type string
---@return string?
---<p>The name of the category/group is the name used in `prototypes[type]`</p>
---<p>It's a shame it's not available directly from the prototype!</p>
function ElementUtils.getPrototypeGroup(type)
	return idx_prototype_type_category[type]
end

---@type table<int,  table<string,  table<int, table>>>
local force_fields_cache = {} -- [force_index][type][name] = {is_craftable=true|false}

---
---@param force LuaForce
---@param name string
---@param type string item|fluid
---@return boolean #true if the item is craftable, false otherwise
---@return boolean #true if the item is hand craftable, false otherwise
function ElementUtils.isCraftable(force, name, type)
	local type = ElementUtils.getPrototypeGroup(type) --convert special type to common type
	if type ~= "item" and type ~= "fluid" then return false,false end
	---@cast type "item"|"fluid"
	force_fields_cache[force.index] = force_fields_cache[force.index] or {}
	local force_cache = force_fields_cache[force.index]
	force_cache[type] = force_cache[type] or {}
	local type_cache = force_cache[type]
	type_cache[name] = type_cache[name] or {}
	local name_cache = type_cache[name]
	if name_cache.is_craftable ~= nil then return name_cache.is_craftable, name_cache.is_hand_craftable end

	local recipe_names = fdb.prototypes.recipes["by_"..type.."_products"][name] or {}
	for _, recipe_name in ipairs(recipe_names) do
		local r = force.recipes[recipe_name]
		if r and r.enabled and not r.hidden then
			name_cache.is_craftable=true
			name_cache.is_hand_craftable = r.category == "crafting" or r.category == "crafting-handonly"
			return true, name_cache.is_hand_craftable
		end
	end

	name_cache.is_craftable = false
	name_cache.is_hand_craftable = false
	return false, false
end

---@param force LuaForce
---@param name string
---@param type string item|fluid
function ElementUtils.isHandCraftable(force, name, type)
	local _,hand = ElementUtils.isCraftable(force, name, type)
	return hand
end

--[=[
---@param e EventData.on_research_finished|EventData.on_research_reversed
local function reset(e)
	local finished = e.name == defines.events.on_research_finished
	local reversed = e.name == defines.events.on_research_reversed
	local force_index = e.research.force.index
	local force = game.forces[force_index]
	for _, effect in pairs(e.research.prototype.effects) do
		if effect.type ~= "unlock-recipe" then goto next_effect end
		local recipe = game.forces[force_index].recipes[effect.recipe]
		if not recipe or not recipe.valid then goto next_effect end
		for _, product in ipairs(recipe.products) do
			if product.type ~= "item" and product.type ~= "fluid" then goto next_product end
			local name = product.name
			if not force_fields_cache[force_index] then goto next_product end
			if not force_fields_cache[force_index][product.type] then goto next_product end
			if not force_fields_cache[force_index][product.type][name] then goto next_product end
			local is_craftable = force_fields_cache[force_index][product.type][name].is_craftable
			if finished and is_craftable then goto next_product end
			if reversed and not is_craftable then goto next_product end
			::reset::
			is_craftable, is_hand_craftable = ElementUtils.isCraftable(force, name, product.type)
			force_fields_cache[force_index][product.type][name].is_craftable = is_craftable
			for _, player in pairs(force.players) do
				local plx = PlayerContext.get(player.index)
				local key = plx.ElementSelectorView.elements.idx_type_name_key[product.type][name]
				local elem = plx.ElementSelectorView.elements.rows[key[1]].rows[key[2]].rows[key[3]]
				elem.is_craftable = is_craftable
				elem.is_hand_craftable = is_hand_craftable
			end
			::next_product::
		end
		::next_effect::
	end
end
--]=]
--TODO: research changed
--Events.on_event(defines.events.on_research_finished, reset)
--Events.on_event(defines.events.on_research_reversed, reset)



local _getElemID_userdata_typeMap = {
	LuaEntity = "entity",
	LuaEntityPrototype = "entity",
	LuaItem = "item",
	LuaItemPrototype = "item",
	LuaFluidPrototype = "fluid",
	LuaRecipe = "recipe",
	LuaRecipePrototype = "recipe",
	LuaTile = "tile",
	LuaTilePrototype = "tile",
	LuaTechnology = "technology",
	LuaTechnologyPrototype = "technology"
}

---
---@param arg any
---@return ElemID? -- The element ID of the argument, or nil if it could not be determined.
---@return string? -- An error message if the argument could not be converted to an ElemID.
function _G.toElemID(arg)
	if not arg then return nil, "Invalid argument. 'arg' nil"
	elseif type(arg) == "userdata" then
		local t = _getElemID_userdata_typeMap[arg.object_name]
		if t then return {type = t, name = arg.name}
		elseif arg.object_name == "LuaItemStack" then return {type = "item", name = arg.name}
		else return nil, "Invaid argument. No mappingg for object_name="..tostring(arg.object_name)
		end
	elseif type(arg) == "table" then
		if arg["__class"] == "RecipeInfo" then --[[@cast arg RecipeInfo]]
			return {type = "recipe", name = arg.name}
		elseif (arg.type or arg.base_type) and (arg.name or arg.value) then
			local n = arg.name or arg.value; n = (type(n) == "string" and n) or (type(n) == "table" and n.name) or nil
			local t = arg.type or arg.base_type; t = type(t) == "string" and t or (type(t) == "table" and t.name) or nil
			if t then t = ElementUtils.getPrototypeGroup(t) or error("Unknwon type: "..tostring(t)) end
			return {type = t, name = n}
		end
	elseif type(arg) == "string" then -- sprite name (type/name)
		local typePart, namePart = string.match(arg, "([^/]+)/([^/]+)")
		if typePart and namePart then
			return {type = typePart, name = namePart}
		else
			return nil, "Invalid argument. string="..arg
		end
	else
		return nil, "Invalid argument. 'arg'"
	end
end

--[[
---
---@param arg any
---@return ElemID -- The element ID of the argument, or nil if it could not be determined.
---@deprecated -- Use `assert(toElemID)` instead.
function _G.toElemIDorError(arg)
	local elemId, err = toElemID(arg)
	if not elemId then error(err) end
	return elemId
end
]]

---
---@param elemId ElemID
function ElementUtils.exist(elemId)
	return elemId and prototypes[elemId.type] and prototypes[elemId.type][elemId.name]
end
-----------------------------------------------------------------------------------------------------------------------
return ElementUtils