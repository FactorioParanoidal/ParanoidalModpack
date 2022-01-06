------------------
---- data.lua ----
------------------

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Setup function host
if not OSM.lib.prototype then OSM.lib.prototype = {} end

-- Disable prototype
function OSM.lib.prototype.disable_prototype(prototype_name, prototype_type)

	local prototype_index = {prototype_name, prototype_type, OSM.mod_name}

	if prototype_type == "all" then
		table.insert(OSM.table.removed_prototypes, prototype_index)
	elseif prototype_type == "entity" then
		table.insert(OSM.table.removed_prototypes, prototype_index)
	elseif prototype_type == "recipe" then
		table.insert(OSM.table.removed_prototypes, prototype_index)
	elseif prototype_type == "item" then
		table.insert(OSM.table.removed_prototypes, prototype_index)
	elseif prototype_type == "technology" then
		table.insert(OSM.table.removed_prototypes, prototype_index)
	else 
		error("Specified prototype: "..prototype_type.."does not exist")
	end
end

-- Enable prototype [overrides disable prototype]
function OSM.lib.prototype.enable_prototype(prototype_name, prototype_type)

	local prototype_index = {prototype_name, prototype_type}

	if prototype_type == "all" then
		table.insert(OSM.table.enabled_prototypes, prototype_index)
	elseif prototype_type == "entity" then
		table.insert(OSM.table.enabled_prototypes, prototype_index)
	elseif prototype_type == "recipe" then
		table.insert(OSM.table.enabled_prototypes, prototype_index)
	elseif prototype_type == "item" then
		table.insert(OSM.table.enabled_prototypes, prototype_index)
	elseif prototype_type == "technology" then
		table.insert(OSM.table.enabled_prototypes, prototype_index)
	else 
		error("Specified prototype: "..prototype_type.."does not exist")
	end
end

-- Assign subgroup to prototype [order is optional]
function OSM.lib.prototype.assign_subgroup(prototype_name, subgroup, order)
	if data.raw.item[prototype_name] then OSM.lib.item.assign_subgroup(prototype_name, subgroup, order) end
	if data.raw.recipe[prototype_name] then OSM.lib.recipe.assign_subgroup(prototype_name, subgroup, order) end
end

-- Safely nuke prototype into outer space (kind of...)
function OSM.lib.prototype.super_duper_proto_nuker(nuke_list)
	
	-- Nukes entities from the game
	local function NUKE_EM_HIGH(old_object, new_object)

		-- Scans all ingredients of all recipes and replaces old_object with new_object
		OSM.lib.recipe.replace_ingredient(old_object, new_object)
		
		-- Scans all results of all recipes and replaces old_object with new_object
		OSM.lib.recipe.replace_result(old_object, new_object)

		-- NUKE 'EM HIGH!!!
		OSM.lib.prototype.disable_prototype(old_object)
	end

	-- Deployment in: 3, 2 , 1...
	for old_object, new_object in pairs(nuke_list) do
		NUKE_EM_HIGH(old_object, new_object)
	end
end