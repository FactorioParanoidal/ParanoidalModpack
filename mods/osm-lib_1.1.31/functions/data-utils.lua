-- Convert single image to stripe
function OSM.utils.make_stripes(count, filename)
	local stripe = {filename=filename, width_in_frames=1, height_in_frames=1}
	local stripes = {}
	for i = 1, count do
		stripes[i] = stripe
	end
	return stripes
end

-- Returns table length
function OSM.utils.table_length(array)
	local count = 0
	for _ in pairs(array) do
		count = count+1
	end
	return count
end

-- Make empty sprite [frame count is optional]
function OSM.utils.make_empty_sprite(frame_count)
	if not frame_count then frame_count = 1 end
	return
	{
		filename = "__core__/graphics/empty.png",
		size=1,
		frame_count=frame_count
	}
end

-- Make item subgroup
function OSM.utils.make_item_subgroup(subgroup_name, subgroup_order, group_name)
	if not data.raw["item-subgroup"][subgroup_name] then
		local prototype_subgroup =
		{
			group = group_name,
			type = "item-subgroup",
			name = subgroup_name,
			order = subgroup_order,
		}	data:extend({prototype_subgroup})
	end
end

-- Make item placeholder
function OSM.utils.make_placeholder(placeholder_name)
	local OSM_placeholder =
	{
		type = "item",
		name = placeholder_name,
		icon = "__osm-lib__/graphics/albert-hofmann.png",
		icon_size = 64,
		OSM_placeholder = true,
		subgroup = "OSM-placeholder",
		flags = {"hidden"},
		order = "8==D",
		stack_size = 1
	}	data:extend({OSM_placeholder})
end

-- Make collision layer
function OSM.utils.make_collision_layer(layer_name, collision_mask, entity_name)

	if not collision_mask then error("Collision mask not defined") end
	
	local collision_box = {{0, 0}, {0, 0}}
	local selection_box = {{0, 0}, {0, 0}}

	local entity = OSM.lib.get_entity_prototype(entity_name, true)

	if entity and entity.collision_box then
		collision_box = entity.collision_box
	end
	
	if entity and entity.selection_box then
		selection_box = entity.selection_box
	end
	
	
	local collision_layer =
	{
		type = "simple-entity-with-force",
		name = "OSM-"..layer_name.."-collision-layer",
		subgroup = "OSM-placeholder",
		collision_mask = collision_mask,
		icon = "__osm-lib__/graphics/icons/utils/collision-layer.png",
		icon_size = 64,
		icon_mipmaps = 4,
		flags =
		{
			"hidden",
			"not-repairable",
			"not-blueprintable",
			"hide-alt-info",
			"not-on-map",
			"not-blueprintable",
			"not-deconstructable",
			"not-deconstructable",
			"not-selectable-in-game",
			"not-flammable"
		},
		order = layer_name.."-collision-placeholder",
		max_health = 100,
		collision_box = collision_box,
		selection_box = selection_box,
		tile_width = 1,
		tile_height = 1,
		picture = 
		{
			north =
			{
				filename = "__core__/graphics/empty.png",
				width = 1,
				height = 1
			},
			east =
			{
				filename = "__core__/graphics/empty.png",
				width = 1,
				height = 1
			},
			south =
			{
				filename = "__core__/graphics/empty.png",
				width = 1,
				height = 1
			},
			west =
			{
				filename = "__core__/graphics/empty.png",
				width = 1,
				height = 1
			}
		},
		allow_copy_paste = false,
		selectable_in_game = false,
		squeak_behaviour = false,
		localised_name = "OSM-"..layer_name.."-collision-layer"
	}	data:extend({collision_layer})
end

-- Returns true if prototype exists
function OSM.utils.prototype_valid(prototype_type, prototype_name)

	local function prototype_valid (prototype_type, prototype_name)
		if prototype_type == "entity" then
			for _, entity in pairs(OSM.entity_types) do
				if data.raw[entity][prototype_name] then return true end
			end
	
		elseif prototype_type == "recipe" then
			if data.raw.recipe[prototype_name] then return true end
	
		elseif prototype_type == "item" then
			for _, item in pairs(OSM.item_types) do
				if data.raw[item][prototype_name] then return true end
			end
	
		elseif prototype_type == "fluid" then
			if data.raw.fluid[prototype_name] then return true end
	
		elseif prototype_type == "technology" then
			if data.raw.technology[prototype_name] then return true end

		elseif prototype_type == "resource" then
			if data.raw.resource[prototype_name] then return true end
		end
	end

	if type(prototype_type) == "string" then
		return prototype_valid(prototype_type, prototype_name)
	elseif type(prototype_type) == "table" then
		for _, sub_type in pairs(prototype_type) do
			return prototype_valid(sub_type, prototype_name)
		end
	end
end