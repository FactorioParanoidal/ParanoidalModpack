if(settings.startup["enable-new-craters"].value) then
	data.raw["tile"]["sand-1"].layer = 11
	data.raw["tile"]["sand-2"].layer = 12
	data.raw["tile"]["sand-3"].layer = 13


	local function make_tile_transition_from_template_variation(src_x, src_y, cnt_, line_len_, is_tall, normal_res_transition, high_res_transition)
	  return
	  {
		picture = normal_res_transition,
		count = cnt_,
		line_length = line_len_,
		x = src_x,
		y = src_y,
		tall = is_tall,
		hr_version =
		{
		  picture = high_res_transition,
		  count = cnt_,
		  line_length = line_len_,
		  x = 2 * src_x,
		  y = 2 * (src_y or 0),
		  tall = is_tall,
		  scale = 0.5
		}
	  }
	end
	local function water_transition_template_with_effect(to_tiles, normal_res_transition, high_res_transition, options)
	  return make_generic_transition_template(to_tiles, water_transition_group_id, nil, normal_res_transition, high_res_transition, options, true, false, true)
	end

	function make_generic_transition_template(to_tiles, group1, group2, normal_res_transition, high_res_transition, options, base_layer, background, mask)
	  local t = options.base or {}
	  t.to_tiles = to_tiles
	  t.transition_group = group1
	  t.transition_group1 = group2 and group1 or nil
	  t.transition_group2 = group2
	  local default_count = options.count or 16
	  for k,y in pairs({inner_corner = 0, outer_corner = 288, side = 576, u_transition = 864, o_transition = 1152}) do
		local count = options[k .. "_count"] or default_count
		if count > 0 and type(y) == "number" then
		  local line_length = options[k .. "_line_length"] or count
		  local is_tall = true
		  if (options[k .. "_tall"] == false) then
		    is_tall = false
		  end
		  if base_layer == true then
		    t[k] = make_tile_transition_from_template_variation(0, y, count, line_length, is_tall, normal_res_transition, high_res_transition)
		  end
		  if background == true then
		    t[k .. "_background"] = make_tile_transition_from_template_variation(544, y, count, line_length, is_tall, normal_res_transition, high_res_transition)
		  end
		  if mask == true then
		    t[k .. "_mask"] = make_tile_transition_from_template_variation(1088, y, count, line_length, nil, normal_res_transition, high_res_transition)
		  end

		  if options.effect_map ~= nil then
		    local effect_default_count = options.effect_map.count or 16
		    local effect_count = options.effect_map[k .. "_count"] or effect_default_count
		    if effect_count > 0 then
		      local effect_line_length = options.effect_map[k .. "_line_length"] or effect_count
		      local effect_is_tall = true
		      if (options.effect_map[k .. "_tall"] == false) then
		        effect_is_tall = false
		      end
		      t[k .. "_effect_map"] = make_tile_transition_from_template_variation(0, y, effect_count, effect_line_length, effect_is_tall, options.effect_map.filename_norm, options.effect_map.filename_high)
		    end
		  end
		end
	  end
	  return t
	end
	local nuclear_shallow_transitions =
	{
	  water_transition_template_with_effect
	  (
		{"nuclear-deep", "nuclear-crater", "nuclear-deep-fill", "nuclear-deep-shallow-fill", "nuclear-crater-shallow-fill"},
		"__base__/graphics/terrain/water-transitions/nuclear-ground.png",
		"__base__/graphics/terrain/water-transitions/hr-nuclear-ground.png",
		{
		  effect_map = {
			  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
			  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-mask.png",
			  count = 8,
			  o_transition_tall = false,
			  u_transition_count = 2,
			  o_transition_count = 1
			},
		  o_transition_tall = false,
		  u_transition_count = 2,
		  o_transition_count = 4,
		  side_count = 8,
		  outer_corner_count = 8,
		  inner_corner_count = 8
		}
	  ),
	  ground_to_out_of_map_transition
	}
	local nuclear_crater_transitions =
	{
	  water_transition_template_with_effect
	  (
		{"nuclear-deep", "nuclear-deep-shallow-fill"},
		"__base__/graphics/terrain/water-transitions/nuclear-ground.png",
		"__base__/graphics/terrain/water-transitions/hr-nuclear-ground.png",
		{
		  effect_map = {
			  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
			  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-mask.png",
			  count = 8,
			  o_transition_tall = false,
			  u_transition_count = 2,
			  o_transition_count = 1
			},
		  o_transition_tall = false,
		  u_transition_count = 2,
		  o_transition_count = 4,
		  side_count = 8,
		  outer_corner_count = 8,
		  inner_corner_count = 8
		}
	  ),
	  ground_to_out_of_map_transition
	}
	local tileNames = {"nuclear-deep", "nuclear-crater", "nuclear-deep-fill", "nuclear-deep-shallow-fill", "nuclear-crater-shallow-fill", "nuclear-shallow"}
	for _,tile in pairs(data.raw["tile"]) do
		table.insert(tileNames, tile.name)
	end
	local nuclear_high_transitions =
	{
	  water_transition_template_with_effect
	  (
		tileNames,
		"__base__/graphics/terrain/water-transitions/nuclear-ground.png",
		"__base__/graphics/terrain/water-transitions/hr-nuclear-ground.png",
		{
		  effect_map = {
			  filename_norm = "__base__/graphics/terrain/effect-maps/water-dirt-mask.png",
			  filename_high = "__base__/graphics/terrain/effect-maps/hr-water-dirt-mask.png",
			  count = 8,
			  o_transition_tall = false,
			  u_transition_count = 2,
			  o_transition_count = 1
			},
		  o_transition_tall = false,
		  u_transition_count = 2,
		  o_transition_count = 4,
		  side_count = 8,
		  outer_corner_count = 8,
		  inner_corner_count = 8
		}
	  ),
	  ground_to_out_of_map_transition
	}


	local nuclear_shallow = table.deepcopy(data.raw["tile"]["nuclear-ground"])
	nuclear_shallow.name = "nuclear-shallow"
	nuclear_shallow.collision_mask =
		{
		  -- Player collides only with player-layer and train-layer,
		  -- this can have any tile collision masks it doesn't matter for being walkable by player but not buildable.
		  -- Having water-tile prevents placing paths, ground-tile prevents placing landfill.
		  -- Not sure what other side effects could different combinations of tile masks cause.
		  "water-tile",
		  --"ground-tile",
		  "resource-layer",
		  "item-layer",
		  "object-layer",
		  "doodad-layer"
		}
	nuclear_shallow.transition_merges_with_tile = "water"
	nuclear_shallow.walking_speed_modifier = 0.7
	nuclear_shallow.layer = 10
	nuclear_shallow.map_color={r=46, g=38, b=33}
	nuclear_shallow.transitions = nuclear_shallow_transitions;

	data:extend{nuclear_shallow}

	local nuclear_crater = table.deepcopy(data.raw["tile"]["nuclear-ground"])
	nuclear_crater.name = "nuclear-crater"
	nuclear_crater.collision_mask =
		{
		  "water-tile",
		  "resource-layer",
		  "item-layer",
		  "player-layer",
		  "doodad-layer"
		}
	nuclear_crater.transition_merges_with_tile = "water"
	nuclear_crater.layer = 9
	nuclear_crater.map_color={r=43, g=35, b=31}
	nuclear_crater.transitions = nuclear_crater_transitions;

	data:extend{nuclear_crater}

	local nuclear_shallow_water_in_crater = table.deepcopy(data.raw["tile"]["water-mud"])
	nuclear_shallow_water_in_crater.name = "nuclear-crater-shallow-fill"
	nuclear_shallow_water_in_crater.walking_speed_modifier = 1
	nuclear_shallow_water_in_crater.autoplace = nil
	nuclear_shallow_water_in_crater.collision_mask =
		{
		  "water-tile",
		  "resource-layer",
		  "item-layer",
		  "player-layer",
		  "doodad-layer"
		}

	data:extend{nuclear_shallow_water_in_crater}



	local nuclear_deep = table.deepcopy(data.raw["tile"]["nuclear-ground"])
	nuclear_deep.name = "nuclear-deep"
	nuclear_deep.collision_mask =
		{
		  "water-tile",
		  "resource-layer",
		  "item-layer",
		  "player-layer",
		  "doodad-layer"
		}
	nuclear_deep.transition_merges_with_tile = "water"
	nuclear_deep.layer = 8
	nuclear_deep.map_color={r=39, g=31, b=28}
	nuclear_deep.transitions = nil;

	data:extend{nuclear_deep}


	local nuclear_shallow_water_in_deep = table.deepcopy(data.raw["tile"]["water-mud"])
	nuclear_shallow_water_in_deep.name = "nuclear-deep-shallow-fill"
	nuclear_shallow_water_in_deep.autoplace = nil
	nuclear_shallow_water_in_deep.walking_speed_modifier = 1
	nuclear_shallow_water_in_deep.collision_mask =
		{
		  "water-tile",
		  "resource-layer",
		  "item-layer",
		  "player-layer",
		  "doodad-layer"
		}
	data:extend{nuclear_shallow_water_in_deep}

	local nuclear_water_in_deep = table.deepcopy(data.raw["tile"]["water"])
	nuclear_water_in_deep.name = "nuclear-deep-fill"
	nuclear_water_in_deep.autoplace = nil
	nuclear_water_in_deep.collision_mask =
		{
		  "water-tile",
		  "resource-layer",
		  "item-layer",
		  "player-layer",
		  "doodad-layer"
		}
	data:extend{nuclear_water_in_deep}

	local nuclear_high = table.deepcopy(data.raw["tile"]["nuclear-ground"])
	nuclear_high.name = "nuclear-high"
	nuclear_high.minable = {mining_time = 0.1, result = "stone"}
	nuclear_high.can_be_part_of_blueprint = true
	nuclear_high.collision_mask =
		{
		  -- Player collides only with player-layer and train-layer,
		  -- this can have any tile collision masks it doesn't matter for being walkable by player but not buildable.
		  -- Having water-tile prevents placing paths, ground-tile prevents placing landfill.
		  -- Not sure what other side effects could different combinations of tile masks cause.
		  "ground-tile",
		  "item-layer",
		  "player-layer",
		  "object-layer",
		  "doodad-layer"
		}
	nuclear_high.transition_merges_with_tile = "water"
	nuclear_high.layer = 128
	nuclear_high.map_color={r=53, g=43, b=39}
	nuclear_high.transitions = nuclear_high_transitions;

	data:extend{nuclear_high}


	data:extend{{
		type = "item",
		name = "nuclear-crater-mound",
		icon = "__base__/graphics/icons/stone.png",
		icon_size = 64, icon_mipmaps = 4,
		subgroup = "terrain",
		order = "c[nuclear-crater-mound]",
		stack_size = 100,
		place_as_tile =
		{
		  result = "nuclear-high",
		  condition_size = 6,
		  condition = 
			{
			  "water-tile",
			  "ground-tile",
			  "item-layer",
			  "player-layer",
			  "object-layer",
			  "doodad-layer"
			}
		}
	  }}
	data.raw["tile"]["nuclear-deep"].allowed_neighbors = {};
	data.raw["tile"]["nuclear-deep-shallow-fill"].allowed_neighbors = {};
	data.raw["tile"]["nuclear-deep-fill"].allowed_neighbors = {};
	data.raw["tile"]["nuclear-crater"].allowed_neighbors = {};
	data.raw["tile"]["nuclear-crater-shallow-fill"].allowed_neighbors = {};
	data.raw["tile"]["nuclear-shallow"].allowed_neighbors = {};
end

