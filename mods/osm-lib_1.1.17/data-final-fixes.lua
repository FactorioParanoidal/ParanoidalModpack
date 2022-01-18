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
end


-- View prototypes internal names
if settings.startup["view-internal-names"].value == true then
	for _, entity_type in pairs(OSM.entity_types) do
		if data.raw[entity_type] then
			for _, entity in pairs(data.raw[entity_type]) do
				if entity.name then
					local source_name = entity.name
					entity.localised_name = {"", source_name}
				end
			end
		end
	end
	
	for _, item in pairs(data.raw.item) do
		if item.name then
			local source_name = item.name
			item.localised_name = {"", source_name}
		end
	end
	
	for _, fluid in pairs(data.raw.fluid) do
		if fluid.name then
			local source_name = fluid.name
			fluid.localised_name = {"", source_name}
		end
	end
	
	for _, recipe in pairs(data.raw.recipe) do
		if recipe.name then
			local source_name = recipe.name
			recipe.localised_name = {"", source_name}
		end
	end
	
	for _, technology in pairs(data.raw.technology) do
		if technology.name then
			local source_name = technology.name
			technology.localised_name = {"", source_name}
		end
	end
end