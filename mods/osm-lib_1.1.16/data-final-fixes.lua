------------------------------
---- data-final-fixes.lua ----
------------------------------

-- Get local functions
local OSM_local = require("utils.local-functions")

-- Check for re-enabled prototypes
for i, removed_prototype in pairs(OSM.table.removed_prototypes) do
	local removed_name = removed_prototype[1]
	local removed_type = removed_prototype[2]

	for _, enabled_prototype in pairs(OSM.table.enabled_prototypes) do
		local enabled_name = removed_prototype[1]
		local enabled_type = removed_prototype[2]
		
		if enabled_name == removed_name and enabled_type == removed_type then
			table.remove(OSM.table.removed_prototypes, i)
		end
	end
end

-- Remove prototypes enlisted for disabling
for _, removed_prototype in pairs(OSM.table.removed_prototypes) do
	
	local prototype_name = removed_prototype[1]
	local prototype_type = removed_prototype[2]
	local mod_name = removed_prototype[3]
	
	if prototype_type == "all" then
		OSM_local.disable_entity(prototype_name, mod_name)
		OSM_local.disable_recipe(prototype_name, mod_name)
		OSM_local.disable_item(prototype_name, mod_name)
		OSM_local.disable_technology(prototype_name, mod_name)
	end
	
	if prototype_type == "entity" then
		OSM_local.disable_entity(prototype_name, mod_name)
	end
	
	if prototype_type == "recipe" then
		OSM_local.disable_recipe(prototype_name, mod_name)
	end

	if prototype_type == "item"  then
		OSM_local.disable_item(prototype_name, mod_name)
	end
	
	if prototype_type == "technology"  then
		OSM_local.disable_technology(prototype_name, mod_name)
	end
	
	OSM.lib.mod_fixes(prototype_name, prototype_type, mod_name)
end