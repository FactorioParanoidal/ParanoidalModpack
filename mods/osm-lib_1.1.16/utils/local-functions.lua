---------------
---- LOCAL ----
---------------

-- Setup local functions host
local OSM_local = {}

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- DISABLE entity
function OSM_local.disable_entity(entity_name, OSM_mod)
	for _, entity_type in pairs(OSM.entity_types) do
		if data.raw[entity_type] and data.raw[entity_type][entity_name] then
			
			local entity = data.raw[entity_type][entity_name]
			local source_name = entity.name
			local item_name = {}
			if entity.minable.result or entity.placeable_by then
				item_name = entity.minable.result or entity.placeable_by
			else
				item_name = nil
			end

			entity.flags = {"hidden"}
			entity.subgroup = "OSM-removed"
			entity.OSM_removed = true
			entity.next_upgrade = nil
			entity.placeable_by = nil
			entity.minable.result = nil
			entity.localised_name = {"", source_name}
			entity.localised_description = {"", "Disabled by: "..OSM_mod}
			
			-- Make icon
			if item_name ~= nil then
				local item = table.deepcopy(data.raw.item[item_name])
				if not item.OSM_removed then
					local source_name = item.name
					local entity_name = {}
					local item_name = {}
					local icon_name = {}
					local scale = {}
					local mipmaps = {}
					
					-- Set inputs for icon layering
					if item.icon_mipmaps then
						mipmaps = item.icon_mipmaps
					else
						mipmaps = nil
					end
				
					-- Layer ban icon on item with single icon
					if item.icon then
						item.icons =
						{
							{
								icon = item.icon,
								scale = item.scale,
								icon_size = item.icon_size
							},
							{
								icon = "__osm-lib__/graphics/ban.png",
								scale = 0.50,
								icon_size = 64,
							}
						}
						item.icon = nil
						item.icon_size = 64
						item.icon_mipmaps = mipmaps
	
					-- Layer ban icon on item with multiple icons
					elseif item.icons then
						for _, icon in ipairs(item.icons) do
							item.scale = (icon.scale or 1) * 0.50
							item.icon_size = item.icon_size
						end
						table.insert(item.icons, {icon = "__osm-lib__/graphics/ban.png", icon_size = 64, scale = 0.50})
						item.icon_size = 64
						item.icon_mipmaps = mipmaps
					end
					entity.icons = item.icons
				else
					entity.icons = item.icons
				end
			else
				if entity.icon_mipmaps then
					mipmaps = entity.icon_mipmaps
				else
					mipmaps = nil
				end

				-- Layer ban icon on entity with single icon
				if entity.icon then
					entity.icons =
					{
						{
							icon = entity.icon,
							scale = entity.scale,
							icon_size = entity.icon_size
						},
						{
							icon = "__osm-lib__/graphics/ban.png",
							scale = 0.50,
							icon_size = 64,
						}
					}
					entity.icon = nil
					entity.icon_size = 64
					entity.icon_mipmaps = mipmaps

				-- Layer ban icon on entity with multiple icons
				elseif entity.icons then
					for _, icon in ipairs(entity.icons) do
						entity.scale = (icon.scale or 1) * 0.50
						entity.icon_size = entity.icon_size
					end
					table.insert(entity.icons, {icon = "__osm-lib__/graphics/ban.png", icon_size = 64, scale = 0.50})
					entity.icon_size = 64
					entity.icon_mipmaps = mipmaps
				end
			end
		-- Index icon in table for removed prototypes
		table.insert(OSM.table.removed_icons, {source_name, "entity", entity.icons})
		end
	end
end

-- DISABLE item
function OSM_local.disable_item(item_name, OSM_mod)
	if data.raw.item[item_name] then

		OSM.lib.item.remove_achievement_requirement(item_name)

		local item = data.raw.item[item_name]
		local source_name = item.name
		local entity_name = {}
		local scale = {}
		local mipmaps = {}
		
		item.flags = {"hidden"}
		item.subgroup = "OSM-removed"
		item.OSM_removed = true
		
		item.localised_name = {"", source_name}
		item.localised_description = {"", "Disabled by: "..OSM_mod}
		
		-- Set inputs for icon layering
		if item.icon_mipmaps then
			mipmaps = item.icon_mipmaps
		else
			mipmaps = nil
		end
	
		-- Layer ban icon on item with single icon
		if item.icon then
			item.icons =
			{
				{
					icon = item.icon,
					scale = item.scale,
					icon_size = item.icon_size
				},
				{
					icon = "__osm-lib__/graphics/ban.png",
					scale = 0.50,
					icon_size = 64,
				}
			}
			item.icon = nil
			item.icon_size = 64
			item.icon_mipmaps = mipmaps

		-- Layer ban icon on item with multiple icons
		elseif item.icons then
			for _, icon in ipairs(item.icons) do
				item.scale = (icon.scale or 1) * 0.50
				item.icon_size = item.icon_size
			end
			table.insert(item.icons, {icon = "__osm-lib__/graphics/ban.png", icon_size = 64, scale = 0.50})
			item.icon_size = 64
			item.icon_mipmaps = mipmaps
		end

		-- Remove place result and get entity name
		if item.place_result then
			entity_name = item.place_result
			item.place_result = nil
		else
			entity_name = nil
		end

		-- Index icon in table for removed prototypes
		table.insert(OSM.table.removed_icons, {source_name, "item", item.icons})
	end
end

-- DISABLE recipe
function OSM_local.disable_recipe(recipe_name, OSM_mod)

	if data.raw.recipe[recipe_name] then

		OSM.lib.technology.remove_unlock(recipe_name)
		OSM.lib.recipe.remove_limitation(recipe_name)

		local recipe = data.raw.recipe[recipe_name]
		local source_name = recipe.name

		recipe.hidden = true
		recipe.subgroup = "OSM-removed"
		recipe.OSM_removed = true

		recipe.enabled = false
		recipe.icon = "__osm-lib__/graphics/ban-recipe.png"
		recipe.icon_size = 64
		recipe.icon_mipmaps = nil
		recipe.icons = nil
		recipe.category = nil

		recipe.localised_name = {"", source_name}
		recipe.localised_description = {"", "Disabled by: "..OSM_mod}


		-- Get recipe difficulty
		if recipe.normal or recipe.expensive then
			if recipe.normal then
				recipe = recipe.normal

				recipe.ingredients = {}
				recipe.results = {{type="item", name="OSM_void", amount=1, probability=0}}
				recipe.main_product = "OSM_void"
				recipe.result = nil	
			end
			if recipe.expensive then
				recipe = recipe.expensive

				recipe.ingredients = {}
				recipe.results = {{type="item", name="OSM_void", amount=1, probability=0}}
				recipe.main_product = "OSM_void"
				recipe.result = nil
			end
		else
			recipe.ingredients = {}
			recipe.results = {{type="item", name="OSM_void", amount=1, probability=0}}
			recipe.main_product = "OSM_void"
			recipe.result = nil
		end
	end
end

-- DISABLE technology
function OSM_local.disable_technology(technology_name, OSM_mod)
	if data.raw.technology[technology_name] then

		local technology = data.raw.technology[technology_name]
		
		technology.enabled = false
		technology.hidden = true
		technology.OSM_removed = true
		technology.prerequisites = {}
		technology.effects = {}
		technology.localised_description = {"", "Disabled by: "..OSM_mod}

		-- Removes technology from other techs prerequisites
		for _, technology in pairs(data.raw.technology) do
			if technology.prerequisite then
				for i, prerequisite in pairs (technology.prerequisites) do
					if prerequisite == technology_name then
						table_remove(technology.prerequisites, i)
					end
				end
			end		
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

return OSM_local