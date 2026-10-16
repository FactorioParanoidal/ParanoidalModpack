--local inspect = require('inspect')
require('tree-stump')

local data_util = require('data-util')
local util = require('util')
local merge = util.merge
local tree_models = require('tree-models')
local color_limit = 32
local starting_area_clearing_radius = 64
local starting_area_clearing_border_width = 32

local function index_to_letter(index, starting_at)
  return string.char(string.byte(starting_at or "a", 1) - 1 + index)
end

-- If the tree name contains a string that matches any string in this table
-- we do not want to disable it.
local trees_to_not_disable = {
  "rubber",
}

if mods["space-age"] then
  local space_age_trees = {
    "ashland-lichen-tree", -- vulcanus
    "cuttlepop", -- gleba
    "slipstack", -- gleba
    "funneltrunk", -- gleba
    "hairyclubnub", -- gleba
    "teflilly", -- gleba
    "lickmaw", -- gleba
    "stingfrond", -- gleba
    "boompuff", -- gleba
    "sunnycomb", -- gleba
  }
  data_util.concatenate_lists(trees_to_not_disable, space_age_trees)
end

-- disable existing trees
for _, tree in pairs(data.raw.tree) do
  local disable = true
  for _, string in pairs(trees_to_not_disable) do
    if string.find(tree.name, string, 1, true) then
      disable = false
    end
  end
  if disable then
    log("Disabling tree " .. tree.name)
    tree.autoplace = nil
  end
end

local water_bands = {
  [1] = {0.2, 0.4},
  [2] = {0.4, 0.6},
  [3] = {0.6, 0.9},
  [4] = {0.9, 1.1},
}

local function map_temperature(input)
  -- range is currently 0 - 100
  return input * 100
end

local starting_area_clearing_peak = {
  influence = -0.25,
  richness_influence = 0,
  distance_optimal = 0,
  distance_range = starting_area_clearing_radius - starting_area_clearing_border_width,
  distance_max_range = starting_area_clearing_radius + starting_area_clearing_border_width,
  distance_top_property_limit = starting_area_clearing_radius, -- must be halfway between range and max_range so that influence never becomes positive!
}

local next_tree_noise_layer_number = 1

-- static_influence is added
-- tree_noise_influence is multiplied by tree noise, the result of which is added
local function tree_autoplace_with_peaks(treedata)

  local tree_noise_influence = 0.65
  local density = (treedata.density or 1)
  local static_influence = -1 + treedata.density * 0.1
  local noise_layer_name = treedata.noise

  local max_peak_ranges = {
    ["moisture"] = 0.05,
    ["aux"] = 0.05,
    ["temperature"] = 0.05,
    ["elevation"] = 0.05,
  }

  local autoplace = {
    control = "trees",
    order = "z[tree]-b[forest]",
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=((0.5 * "..density.."/4) * sharpness_filter), amplitude=penalty}",
    richness_expression = 1,
    local_expressions = {
      max_probability = 0.5 * density/4,
      penalty = 0.02 + 0.01 * (1 - density/4),
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.25)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
      peak1_expr = -static_influence,
      peak2_expr = "clamp("..tree_noise_influence.." * peak2_noise_expression,"..-math.huge..","..tree_noise_influence..")",
      peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.6, seed0=map_seed, seed1='"..noise_layer_name.."', octaves=octaves-0.75, input_scale=1, output_scale=1}",
      peak3_expr = "peak3_distance_expression",
      peak3_distance_expression = "(1 - (peak3_total_distance * (2 / peak3_dimension_count)))",
      peak3_dimension_count = 0,
      peak4_expr = "clamp("..(tree_noise_influence*0.7).." * peak2_noise_expression,"..-math.huge..","..(tree_noise_influence*0.7)..")",
      peak4_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.6, seed0=map_seed, seed1='trees', octaves=octaves-0.65, input_scale=1, output_scale=1}",
      octaves = "10 - log2(var('control:trees:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 2.25 - (0.25 * density),
    },
    -- max_probability = 0.5 * density/4,
    -- random_probability_penalty = 0.02 + 0.01 * (1 - density/4);
    -- sharpness = 0.25,
    -- richness_base = 0.0, -- 0.0,
    -- richness_multiplier = 0.5,
    -- peaks = {
    --   {
    --     -- increase richness everywhere to reduce
    --     -- large groups of unhealthy trees
    --     influence = 0,
    --     richness_influence = 1.2
    --   },
    --   {
    --     influence = static_influence,
    --     richness_influence = -static_influence,
    --   },
    --   {
    --     -- Give each tree type its own noise layer to add some randomness
    --     -- to the boundaries between types of forests.
    --     -- This results in more forest coverage overall so has to be countered
    --     -- with more negative static influence.
    --     max_influence = tree_noise_influence,
    --     influence = tree_noise_influence,
    --     richness_influence = -tree_noise_influence,
    --     noise_layer = noise_layer_name,
    --     noise_persistence = 0.6,
    --     noise_octaves_difference = -0.75
    --   },
    --   {
    --     max_influence = tree_noise_influence * 0.7,
    --     influence = tree_noise_influence * 0.7,
    --     richness_influence = -tree_noise_influence,
    --     noise_layer = "trees",
    --     noise_persistence = 0.6,
    --     noise_octaves_difference = -0.65
    --   },
    --   dimensions_peak,
    --   starting_area_clearing_peak,
    -- },
  }
  local dimensions_peak = {
    influence = 1,
    richness_influence = 0.25,
  }
  if treedata.water_band then
    treedata.water_low = water_bands[treedata.water_band][1]
    treedata.water_high = water_bands[treedata.water_band][1]
  end
  if treedata.water_low and treedata.water_high then
    -- dimensions_peak.water_optimal = (treedata.water_low + treedata.water_high) * 0.5
    -- dimensions_peak.water_range = (treedata.water_high - treedata.water_low) * 0.5
    -- dimensions_peak.water_max_range = (treedata.water_high - treedata.water_low) * 0.5 + 0.05
    autoplace.local_expressions.peak3_dimension_count =autoplace.local_expressions.peak3_dimension_count + 1
    autoplace.local_expressions.peak3_total_distance = autoplace.local_expressions.peak3_total_distance and (autoplace.local_expressions.peak3_total_distance .. " + peak3_moisture_expr") or "peak3_moisture_expr"
    autoplace.local_expressions.peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)"
    autoplace.local_expressions.peak3_moisture_optimal = (treedata.water_low + treedata.water_high) * 0.5
    autoplace.local_expressions.peak3_moisture_range = (treedata.water_high - treedata.water_low) * 0.5
    autoplace.local_expressions.peak3_moisture_max_range = (treedata.water_high - treedata.water_low) * 0.5 + 0.05
  end

  if treedata.temperature_low and treedata.temperature_high then
    local temp_low = map_temperature(treedata.temperature_low)
    local temp_high = map_temperature(treedata.temperature_high)
    -- dimensions_peak.temperature_optimal = (temp_low + temp_high) * 0.5
    -- dimensions_peak.temperature_range = (temp_high - temp_low) * 0.5
    -- dimensions_peak.temperature_max_range = (temp_high - temp_low) * 0.5  + 0.05
    autoplace.local_expressions.peak3_dimension_count =autoplace.local_expressions.peak3_dimension_count + 1
    autoplace.local_expressions.peak3_total_distance = autoplace.local_expressions.peak3_total_distance and (autoplace.local_expressions.peak3_total_distance .. " + peak3_temperature_expr") or "peak3_temperature_expr"
    autoplace.local_expressions.peak3_temperature_expr = "ab_mimic_peak_dimension(temperature,peak3_temperature_optimal,peak3_temperature_range,peak3_temperature_max_range)"
    autoplace.local_expressions.peak3_temperature_optimal = (temp_low + temp_high) * 0.5
    autoplace.local_expressions.peak3_temperature_range = (temp_high - temp_low) * 0.5
    autoplace.local_expressions.peak3_temperature_max_range = (temp_high - temp_low) * 0.5  + 0.05
  end

  if treedata.aux_low and treedata.aux_high then
    local aux_low = treedata.aux_low
    local aux_high = treedata.aux_high
    -- dimensions_peak.aux_optimal = (aux_low + aux_high) * 0.5
    -- dimensions_peak.aux_range = (aux_high - aux_low) * 0.5
    -- dimensions_peak.aux_max_range = (aux_high - aux_low) * 0.5  + 0.05
    autoplace.local_expressions.peak3_dimension_count =autoplace.local_expressions.peak3_dimension_count + 1
    autoplace.local_expressions.peak3_total_distance = autoplace.local_expressions.peak3_total_distance and (autoplace.local_expressions.peak3_total_distance .. " + peak3_aux_expr") or "peak3_aux_expr"
    autoplace.local_expressions.peak3_aux_expr = "ab_mimic_peak_dimension(aux,peak3_aux_optimal,peak3_aux_range,peak3_aux_max_range)"
    autoplace.local_expressions.peak3_aux_optimal = (aux_low + aux_high) * 0.5
    autoplace.local_expressions.peak3_aux_range = (aux_high - aux_low) * 0.5
    autoplace.local_expressions.peak3_aux_max_range = (aux_high - aux_low) * 0.5  + 0.05
  end

  if treedata.elevation_low and treedata.elevation_high then
    -- dimensions_peak.elevation_optimal = (treedata.elevation_low + treedata.elevation_high) * 0.5
    -- dimensions_peak.elevation_range = (treedata.elevation_high - treedata.elevation_low) * 0.5
    -- dimensions_peak.elevation_max_range = (treedata.elevation_high - treedata.elevation_low) * 0.5  + 0.05
    autoplace.local_expressions.peak3_dimension_count =autoplace.local_expressions.peak3_dimension_count + 1
    autoplace.local_expressions.peak3_total_distance = autoplace.local_expressions.peak3_total_distance and (autoplace.local_expressions.peak3_total_distance .. " + peak3_elevation_expr") or "peak3_elevation_expr"
    autoplace.local_expressions.peak3_elevation_expr = "ab_mimic_peak_dimension(elevation,peak3_elevation_optimal,peak3_elevation_range,peak3_elevation_max_range)"
    autoplace.local_expressions.peak3_elevation_optimal = (treedata.elevation_low + treedata.elevation_high) * 0.5
    autoplace.local_expressions.peak3_elevation_range = (treedata.elevation_high - treedata.elevation_low) * 0.5
    autoplace.local_expressions.peak3_elevation_max_range = (treedata.elevation_high - treedata.elevation_low) * 0.5  + 0.05
  end
  -- data:extend{{type="noise-layer", name=noise_layer_name}}

  --log( treedata.name )
  --log( serpent.block( autoplace, {comment = false, numformat = '%1.8g' } ) )
  local excludes = {"volcanic", "frozen"}
  if treedata.water_band and treedata.water_band > 1 then
    table.insert(excludes, "sand")
  end
  autoplace.tile_restriction = treedata.tile_restriction or alien_biomes.list_tiles(alien_biomes.exclude_tags(alien_biomes.all_tiles(), excludes))
  return autoplace
end

data:extend({
  {
    type = "noise-expression",
    name = "trees_shared",
    expression = "multioctave_noise{\z
      x=base_x,\z
      y=base_y,\z
      persistence=0.6,\z
      seed0=map_seed,\z
      seed1='trees',\z
      octaves=3,\z
      input_scale=1/32 * input_scale_mod,\z
      output_scale=0.6\z
    }",
    local_expressions = {
      base_x = "x * var('control:trees:frequency')",
      base_y = "y * var('control:trees:frequency')",
      input_scale_mod = "1"--"var('control:trees:frequency')"
    }
  },
  {
    type = "noise-expression",
    name = "trees_basis_edge_breaker",
    expression = "basis_noise{\z
      x=x,\z
      y=y,\z
      seed0=map_seed,\z
      seed1=(map_seed % 255),\z
      input_scale=1/8,\z
      output_scale=1/4\z
    }"
  }
})

local function make_spec_tree_noise(name)
  if data.raw["noise-expression"][name] then
    return name
  else
    data:extend({
      {
        type = "noise-expression",
        name = name,
        expression = "multioctave_noise{\z
          x = base_x,\z
          y = base_y,\z
          persistence = 0.65,\z
          seed0 = map_seed,\z
          seed1 = '"..name.."',\z
          octaves=3,\z
          input_scale=1/32* input_scale_mod,\z
          output_scale=0.6\z
        }",
        local_expressions = {
          base_x = "x * var('control:trees:frequency')",
          base_y = "y * var('control:trees:frequency')",
          input_scale_mod = "1",--"var('control:trees:frequency')",
        }
      }
    })
    return name
  end
end

local function tree_autoplace_with_noise(treedata)
  local order = "z[tree]-b[forest]"
  local autoplace_control_name = "trees"
  
  local aux_function
  if treedata.aux_low and treedata.aux_high then
    aux_function = "asymmetric_ramps{\z
                      input=aux,\z
                      from_bottom="..treedata.aux_low-max_peak_ranges["aux"]..",\z
                      from_top="..treedata.aux_low..",\z
                      to_top="..treedata.aux_high..",\z
                      to_bottom="..treedata.aux_high+max_peak_ranges["aux"].."\z
                    }"
  end

  -- The water peak has a single point optimal value, not a range of optimal values
  -- So we can simplify the noise here
  local moisture_function
  local moisture_optimal
  local moist_mult = 1
  local max_range_mod = 0.05
  if treedata.water_band then
    moisture_optimal = water_bands[treedata.water_band][1]
    treedata.water_low = moisture_optimal - (moist_mult * max_range_mod)
    treedata.water_high = moisture_optimal + (moist_mult * max_range_mod)
  end
  if treedata.water_low and treedata.water_high then
    moisture_function = "asymmetric_ramps{\z
                          input=moisture,\z
                          from_bottom="..treedata.water_low-max_peak_ranges["moisture"]..",\z
                          from_top="..treedata.water_low..",\z
                          to_top="..treedata.water_high..",\z
                          to_bottom="..treedata.water_high+max_peak_ranges["moisture"].."\z
                        }"
  end

  local temp_low = map_temperature(treedata.temperature_low)
  local temp_high = map_temperature(treedata.temperature_high)
  local temp_function
  if treedata.temperature_low and treedata.temperature_high then
    temp_function = "asymmetric_ramps{\z
                       input=temperature,\z
                       from_bottom="..temp_low-max_peak_ranges["temperature"]..",\z
                       from_top="..temp_low..",\z
                       to_top="..temp_high..",\z
                       to_bottom="..temp_high+max_peak_ranges["temperature"].."\z
                     }"
  end

  local elev_function
  if treedata.elevation_low and treedata.elevation_high then
    elev_function = "asymmetric_ramps{\z
                       input=elevation,\z
                       from_bottom="..treedata.elevation_low-max_peak_ranges["elevation"]..",\z
                       from_top="..treedata.elevation_low..",\z
                       to_top="..treedata.elevation_high..",\z
                       to_bottom="..treedata.elevation_high+max_peak_ranges["elevation"].."\z
                     }"
  end

  -- A -inf to 0 range of values for every point on the map, where the maximum value of the function
  -- is the minimum of each individual function in the set.
  local dimensions_function = "min(0"
                            ..(aux_function and ","..aux_function or "")
                            ..(moisture_function and ","..moisture_function or "")
                            ..(temp_function and ","..temp_function or "")
                            ..(elev_function and ","..elev_function or "")
                            ..")"
  -- So if a tree is in it's optimal area, this will evaluate to 0 allowing the noise functions to
  -- bring the value positive.
                          

  local all_trees_noise_function = "trees_shared"
  local spec_tree_noise_function = make_spec_tree_noise(treedata.noise)

  local noise_function = ""..all_trees_noise_function.."+"..spec_tree_noise_function .."- 0.5 + 0.2 * var('control:trees:size')".."-trees_basis_edge_breaker"
  
  local random_penalty_max = 0.02 + 0.01 * (1 - (treedata.density or 1)/4)
  local starting_area_clearing = "min(0, distance/20 - 3)"

  local probability_expression = dimensions_function.." + "..noise_function.." + "..starting_area_clearing 

  local max_prob_function = "min(0.5*"..(treedata.density or 1).."/4,"..probability_expression..") - random_penalty_between(0,"..random_penalty_max..",1)"

  local richness_expression = "clamp(random_penalty_at(6,1), 0, 1)"

  local excludes = {"volcanic","frozen"}
  if treedata.water_band and treedata.water_band > 1 then
    table.insert(excludes,"sand")
  end

  local ret = {
    order = order,
    control = autoplace_control_name,
    probability_expression = max_prob_function,
    richness_expression = richness_expression,
    tile_restriction = treedata.tile_restriction or alien_biomes.list_tiles(alien_biomes.exclude_tags(alien_biomes.all_tiles(), excludes))
  }
  return ret
end

local function clamp_color(value)
  return math.min(math.max(value, 0), 255)
end

local function table_add_color(table, color)
  local step = 5
  color.r = clamp_color(math.ceil(color.r/5)*5)
  color.g = clamp_color(math.ceil(color.g/5)*5)
  color.b = clamp_color(math.ceil(color.b/5)*5)
  local key = color.r .. "-" .. color.g .. "-" .. color.b
  if not table[key] then
    table[key] = color
    table.count = table.count + 1
  end
end

local function lerp_color(color_a, color_b, value)
  return {
    r = math.ceil(color_a.r + (color_b.r - color_a.r) * value),
    b = math.ceil(color_a.b + (color_b.b - color_a.b) * value),
    g = math.ceil(color_a.g + (color_b.g - color_a.g) * value),
  }
end

local function expand_colors(all_colors)
  local source_colors = table.deepcopy(all_colors)
  for color_a_name, color_a in pairs(source_colors) do
    for color_b_name, color_b in pairs(source_colors) do
      if color_a_name ~= "count"
      and color_b_name ~= "count" and
      color_a_name ~= color_b_name and
      all_colors.count < color_limit then
        -- move 1/3 to the new color
        table_add_color(all_colors, lerp_color(color_a, color_b, 1/3) )
      end
    end
  end
end

local function lighten_color()

end

local function negate_channel(color, negate)
  -- the darker the negate the bigger the step needed towards white
  return math.ceil((1 - (1 - color / 255) * negate / 255) * 255)
end

local function make_tree(treedata)
  local all_colors = { count = 0 }
  for _, color in pairs(treedata.colors) do
    if treedata.negate_tint then
      table_add_color(all_colors, {
        r = negate_channel(color.r, treedata.negate_tint.r),
        g = negate_channel(color.g, treedata.negate_tint.g),
        b = negate_channel(color.b, treedata.negate_tint.b)
      })
    else
      table_add_color(all_colors, color)
    end
  end
  -- brown
  if treedata.model ~= "palm" then
    table_add_color(all_colors, {r = 75,  g = 60, b = 40,})
  end


  local step = 0
  while (all_colors.count < color_limit) and (step < 8) do
    step = step + 1
    expand_colors(all_colors)
  end

  -- get colors array
  local colors = {}
  for _, color in pairs(all_colors) do
    if _ ~= "count" then
      table.insert(colors, color)
    end
  end
  if tree_models[treedata.model] then
    treedata.model = tree_models[treedata.model]
    local ab = treedata.model.alien_biomes_texture == true
    local tree = {
      type = "tree",
      name = treedata.name,
      --icon =  ab and "__base__/graphics/icons/tree-01.png" or "__base__/graphics/icons/tree-" .. treedata.model.type_name .. ".png",
      icons = {
        {icon = "__Alien-biomes-Reforged__/graphics/icons/tree-" .. treedata.model.type_name .. "-trunk.png", icon_size = 64 },
        {icon = "__Alien-biomes-Reforged__/graphics/icons/tree-" .. treedata.model.type_name .. "-leaves.png", icon_size = 64, tint = colors[1] },
      },
      flags = {"placeable-neutral", "placeable-off-grid", "breaths-air"},
      selection_priority = 0,
      minable =
      {
        mining_particle = "wooden-particle",
        mining_time = 0.5,
        result = "wood",
        count = 4
      },
      corpse = treedata.stump or ("tree-" .. treedata.model.type_name .. "-stump"),
      remains_when_mined = treedata.stump or ("tree-" ..  treedata.model.type_name .. "-stump"),
      emissions_per_second = {
        pollution = -0.0015,-- -0.001,
      },
      max_health = 20,
      collision_box = {{-0.4, -0.4}, {0.4, 0.4}}, --{{-1/32, -1/32}, {1/32, 1/32}},
      selection_box = treedata.selection_box or {{-0.9, -2.2}, {0.9, 0.6}},
      drawing_box = treedata.model.drawing_box,
      subgroup = "trees",
      order = "a[tree]-b[alien-biomes]-a[" .. treedata.name .. "]",
      --vehicle_impact_sound =  { filename = "__base__/sound/car-wood-impact.ogg", volume = 1.0 },
      impact_category = "tree", --?
      autoplace = tree_autoplace_with_peaks(treedata),
      --autoplace = tree_autoplace_with_noise(treedata),
      variations = treedata.model.tree_variations,
      colors = colors,
      darkness_of_burnt_tree = 0.5,
      localised_name = { "alien-biomes.ab-tree", {"alien-biomes."..treedata.locale}, {"alien-biomes."..treedata.model.locale}},
      variation_weights = treedata.variation_weights,
    }
    data:extend({tree})
  else
    log( "Tree model load error:" )
    log( serpent.block( treedata, {comment = false, numformat = '%1.8g' } ) )
  end
end


local trees_data = require('tree-data')

for _, treedata in pairs(trees_data) do
  if not (treedata.enabled == false) then
    make_tree(treedata)
  end
end
--data.raw.tree["tree-wetland-c"].variations = data.raw.tree["tree-05"].variations

local not_extreme = alien_biomes.list_tiles(alien_biomes.exclude_tags(alien_biomes.all_tiles(), {"frozen", "volcanic"}))
local not_super_extreme = alien_biomes.list_tiles(alien_biomes.exclude_tags(alien_biomes.all_tiles(), {"heat-4", "heat-3", "ice"}))

local deadtrees = {
  ["dry-hairy-tree"] = {water_optimal = 0.8, tile_restriction = not_extreme},
  ["dead-grey-trunk"] = {water_optimal = 0.7, tile_restriction = not_extreme},
  ["dead-dry-hairy-tree"] = {water_optimal = 0.6, tile_restriction = not_extreme},
  ["dead-tree-desert"] = {water_optimal = 0.5, tile_restriction = not_extreme},
  ["dry-tree"] = {water_optimal = 0.4, tile_restriction = not_super_extreme},
}

for _, tree_data in pairs(deadtrees) do
  data.raw.tree[_].autoplace =
  {
    order = "z[tree]-b[forest]",
    control = "trees",
    tile_restriction = table.deepcopy(tree_data.tile_restriction),
    probability_expression = "random_penalty{x=x,y=y,seed=map_seed,source=(max_probability * sharpness_filter), amplitude=penalty}",
    local_expressions = {
      max_probability = 0.01,
      penalty = 0.01,
      sharpness_filter = "ab_sharpness_function(peaks_expr, 0.6)",
      peaks_expr = "influence_modifier + peak1_expr + peak2_expr + peak3_expr",
      peak1_expr = -0.7,
      peak2_expr = "peak2_noise_expression",
      peak2_noise_expression = "multioctave_noise{x=x, y=y, persistence=0.5, seed0=map_seed, seed1='trees', octaves=octaves-1.5, input_scale=1, output_scale=1}",
      peak3_expr = "peak3_distance_expression",
      peak3_distance_expression = "(1 - (peak3_total_distance * (2 / 1)))",
      peak3_total_distance = "peak3_moisture_expr",
      peak3_moisture_expr = "ab_mimic_peak_dimension(moisture,peak3_moisture_optimal,peak3_moisture_range,peak3_moisture_max_range)",
      peak3_moisture_optimal = tree_data.water_optimal,
      peak3_moisture_range = 0.3,
      peak3_moisture_max_range = 0.4,
      octaves = "8 - log2(var('control:trees:frequency'))",
      influence_modifier = "0.5 - quantile - 0.3",
      quantile = 0.6,
    },
    -- max_probability = 0.01,
    -- random_probability_penalty = 0.01,
    -- sharpness = 0.6,
    -- peaks = {
    --   {
    --     influence = -0.7,
    --     richness_influence = 0
    --   },
    --   {
    --     influence = 1,
    --     noise_layer = "trees",
    --     noise_octaves_difference = -1.5,
    --     noise_persistence = 0.5,
    --     richness_influence = 0
    --   },
    --   {
    --     influence = 1,
    --     richness_influence = 0,
    --     water_optimal = tree_data.water_optimal,
    --     water_max_range = 0.4,
    --     water_range = 0.3
    --   }
    -- },
  }
end

--[[
  How to convert a peak expresion to a noise expression:

  probability_expression = "random_penalty{x=x, y=y, seed=map_seed, source=(max_probability * sharpness_filter), amplitude=penalty}"

  --Unless otherwise specified, assume that numbers to be specified below are doubles.
  local_expressions = {
    penalty = (0,n], -- 0 simply means no penalty is applied, the same as if it wasn't defined.
    max_probability = (0,n],
    sharpness_filter = "clamp((clamp(peaks_expression,0,1)-(sharpness/2))/(1-(sharpness-0.01)),0,1)",
    sharpness = [0,1],
    peaks_expression = "influence_modifier + peak1_expression + peak2_expression + ...",
    
    -- Only include peak<X>_noise_expression if the peak has a noise_layer defined
    -- Only include peak<X>_distance_expression if the peak has dimensions defined
	-- Only include the clamp if either of peak<X>_min_influence or peak<X>_max_influence is defined.
    peak<X>_expression = "clamp(peak<X>_influence * peak<X>_distance_expression * peak<X>_noise_expression, peak<X>_min_influence, peak<X>_max_influence)"

    peak<X>_influence = [-n,n], -- Defaults to 1
    
    peak<X>_distance_expression = "(1 - (peak<X>_total_distance * (2 / #of_dimensions_specified_in_peak<X>)))",
    peak<X>_total_distance = "peak<X>_temperature_distance + peak<X>_moisture_distance + ...",
    peak<X>_<Y>_distance = "clamp((abs(min(peak<X>_<Y>_top_property, <Y>) - peak<X>_<Y>_optimal) - peak<X>_<Y>_range) * peak<X>_<Y>_scale_mult, 0, 1)",
    peak<X>_<Y>_top_property_limit = [-n,n] -- Default is the maximum double value
    peak<X>_<Y>_scale_mult = "1 / (peak<X>_<Y>_max_range - peak<X>_<Y>_range)", -- Don't let max_range and range be the same value.

    peak<X>_noise_expression = "multioctave_noise{x=x, y=y, persistence=peak<X>_persistence, seed0=map_seed, seed1='peak<X>_noise_layer', octaves=default_octaves + peak<X>_noise_octaves_diff, input_scale=1/peak<X>_noise_scale, output_scale=1}",
    peak<X>_noise_persistence = [0,1], -- Defaults to 0.5
    peak<X>_noise_scale = (0,n], -- Defaults to 1
    peak<X>_noise_octaves_diff = [-n,n], -- Defaults to 0
    peak<X>_noise_layer = '' --This is just the name of the noise_layer previosuly referenced. This will mean the nosie is not identical to the previously used noise.

    default_octaves = "10 - log2(var('control:<Z>:frequency'))"
	influence_modifier = 0.5 - quantile - total_static_influence
	quantile = [-n,n] -- A negative value increases the chance of placement, a positive value decreases the chance of placement.
	-- Finding the correct value for 'quantile' is a bit of guess work. In my converstions I've found that it's best to choose a value
	-- between -1 and 1 and then adjust based on what this produces in game, when you're in the rough area of where you want it to be,
	-- changing the value in steps of 0.1 to 0.05 increments feels reasonable.
	
	total_static_influence = Sum of the peak<X>_influence value of Peaks Without Noise defined. This must be manually computed.
]]