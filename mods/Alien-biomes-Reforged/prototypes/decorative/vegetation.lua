local util = require('data-util')

local any = alien_biomes.require_tag
local all = alien_biomes.require_tags
local exclude = alien_biomes.exclude_tags
local list = alien_biomes.list_tiles
local tiles = alien_biomes.all_tiles

local not_harsh = list(exclude(tiles(), {'frozen', 'volcanic', 'sand'}))
local not_extreme = list(exclude(tiles(), {'frozen', 'volcanic'}))
local not_frozen = list(exclude(tiles(), {'frozen'}))
local not_ice = list(exclude(tiles(), {'frozen'}))

-- update some vanilla ones
local vanilla_restrictions = {
  ['red-croton'] = not_extreme,
  ['red-pita'] = not_extreme,
  ['red-pita-mini'] = not_extreme,  -- doesn't exist in vanilla data?
  ['red-asterisk'] = not_frozen,
  ['red-asterisk-mini'] = not_frozen, -- doesn't exist in vanilla data?
  ['brown-asterisk'] = not_extreme,
  ['brown-asterisk-mini'] = not_extreme,
  ['brown-fluff'] = not_frozen,
  ['brown-fluff-dry'] = not_frozen,
  ['brown-hairy-grass'] = not_ice,
  ['brown-carpet-grass'] = not_ice,
  ['brown-small-grass'] = not_ice, -- doesn't exist in vanilla data?
  ['red-desert-bush'] = not_frozen,
  ['white-desert-bush'] = not_ice,
}
for prototype_name, restriction in pairs(vanilla_restrictions) do
  if data.raw['optimized-decorative'][prototype_name] and data.raw['optimized-decorative'][prototype_name].autoplace then
    data.raw['optimized-decorative'][prototype_name].autoplace.tile_restriction = table.deepcopy(restriction)
  end
end

require("vegetation-vanilla")

-- get base plants
local base_plants_list = require("vegetation-base")
local base_plants = {}
-- log(serpent.block(data.raw["planet"]["nauvis"]))
for _, plant in pairs(base_plants_list) do
  base_plants[plant.name] = plant
  local old = data.raw['optimized-decorative']['green-'..plant.name]

  --Space Age fails to load due to "Error while running setup for space-location prototype "nauvis": green-asterisk does not have an autoplace specification"
  -- if old then old.autoplace = nil end
  for _, proto in pairs(data.raw.planet) do
    if proto.map_gen_settings and proto.map_gen_settings.autoplace_settings.decorative.settings["green-"..plant.name] then
      proto.map_gen_settings.autoplace_settings.decorative.settings["green-"..plant.name] = nil
    end
  end
end

local veg_spec = alien_biomes.spec.vegetation
local biome_axes = alien_biomes.axes
local temperature_range = {0.25, 0.75}

local dimension_autoplace = function(local_expressions, peak_string, axis, point_a, point_b)
  r_point_a = point_a
  r_point_b = point_b
  if biome_axes[axis].reverse then
    r_point_a = 1 - point_a
    r_point_b = 1 - point_b
  end
  local point_l = math.min(r_point_a, r_point_b)
  local point_h = math.max(r_point_a, r_point_b)

  local dimension = biome_axes[axis].dimension
  local low = biome_axes[axis].low
  local high = biome_axes[axis].high
  local d_point_a = low + (high - low) * point_l
  local d_point_b = low + (high - low) * point_h

  local optimal = (d_point_a + d_point_b) / 2
  local range = math.abs(d_point_a - d_point_b) * 0.5
  local max_range = math.abs(d_point_a - d_point_b) * 0.5 + 0.03 -- bigger overlap

  local d_str = peak_string.."_"..dimension.."_distance"
  local o_str = peak_string.."_"..dimension.."_optimal"
  local r_str = peak_string.."_"..dimension.."_range"
  local mr_str = peak_string.."_"..dimension.."_max_range"

  local_expressions[peak_string.."_distance_expression"] = "(1 - ("..peak_string.."_total_distance * (2 / "..peak_string.."_num_distances)))"
  local_expressions[peak_string.."_num_distances"] = local_expressions[peak_string.."_num_distances"] and (local_expressions[peak_string.."_num_distances"] + 1) or 2
  local_expressions[peak_string.."_total_distance"] = local_expressions[peak_string.."_total_distance"].." + "..d_str
  local_expressions[d_str] = "ab_mimic_peak_dimension("..dimension..","..o_str..","..r_str..","..mr_str..")"
  local_expressions[o_str] = optimal
  local_expressions[r_str] = range
  local_expressions[mr_str] = max_range
end



-- biome color -> plant color
local match = {
  ["green"] = "green",
  ["olive"] = "olive",
  ["yellow"] = "yellow",
  ["orange"] = "orange",
  ["red"] = "red",
  ["violet"] = "violet",
  ["purple"] = "purple",
  ["mauve"] = "mauve",
  ["blue"] = "blue",
  ["turquoise"] = "turquoise",
}
local clockwise = {
  ["green"] = "olive",
  ["olive"] = "yellow",
  ["yellow"] = "orange",
  ["orange"] = "red",
  ["red"] = "violet",
  ["violet"] = "purple",
  ["purple"] = "mauve",
  ["mauve"] = "blue",
  ["blue"] = "turquoise",
  ["turquoise"] = "green",
}
local clockwise2 = {
  ["green"] = "yellow",
  ["olive"] = "orange",
  ["yellow"] = "red",
  ["orange"] = "violet",
  ["red"] = "purple",
  ["violet"] = "mauve",
  ["purple"] = "blue",
  ["mauve"] = "turquoise",
  ["blue"] = "green",
  ["turquoise"] = "olive",
}
local anticlockwise = {
  ["green"] = "turquoise",
  ["olive"] = "green",
  ["yellow"] = "olive",
  ["orange"] = "yellow",
  ["red"] = "orange",
  ["violet"] = "red",
  ["purple"] = "violet",
  ["mauve"] = "purple",
  ["blue"] = "mauve",
  ["turquoise"] = "blue",
}

local vegetation_map = {
  ["carpet-grass"] = match,
  ["small-grass"] = match,
  ["hairy-grass"] = match,
  ["asterisk"] = clockwise,
  ["asterisk-mini"] = clockwise,
  ["bush-mini"] = match,
  ["desert-bush"] = clockwise,
  ["croton"] = clockwise2,
  ["pita"] = match,
  ["pita-mini"] = match,
}

local tints = {
  green = {90,125,39},
  olive = {132,139,46},
  yellow = {182, 161, 60},-- yellow = {217,196,75},
  orange = {180, 92, 40},
  red = {175, 46, 46},
  violet = {164,57,115},
  purple = {105,73,173},
  mauve = {100,98,202},
  blue = {51,89,166},
  turquoise = {79, 112, 81},
}
for _, tint in pairs(tints) do
  local tint2 = {}
  tint2.a = 1
  tint2.r = tint[1]/255
  tint2.g = tint[2]/255
  tint2.b = tint[3]/255
  tints[_] = tint2
end

-- Get the nauvis planet decorative specification
local nauvis = data.raw.planet.nauvis
local nauvis_deco_settings
if    nauvis
  and nauvis.map_gen_settings
  and nauvis.map_gen_settings.autoplace_settings
  and nauvis.map_gen_settings.autoplace_settings.decorative
then
  nauvis_deco_settings = nauvis.map_gen_settings.autoplace_settings.decorative.settings
end

for plant_name, color_map in pairs(vegetation_map) do
  for biome_color, plant_color in pairs(color_map) do
    local axis = veg_spec.axes[biome_color]
    local plant = table.deepcopy(base_plants[plant_name])
    plant.name = plant_name .. '-' .. plant_color
    plant.localised_name = { "alien-biomes.ab-decorative", {"alien-biomes."..plant_color}, {"alien-biomes."..plant_name}}
    local tint = table.deepcopy(tints[plant_color])
    if plant_name == "asterisk" and plant_color == "blue" then
      tint = {60,80,100}
    end
    --util.replace_filenames_recursive(plant.pictures, '|color|', plant_color)
    for _, pic in pairs(plant.pictures) do
      pic.tint = tint
    end

    -- local peak = nil
    -- for _, test_peak in pairs(plant.autoplace.peaks) do
    --   if test_peak["water_optimal"] then
    --     peak = test_peak
    --   end
    -- end
    -- if not peak then
    --   peak = {}
    --   peak["water_optimal"] = 1
    --   peak["water_range"] = 0.3
    --   peak["water_max_range"] = 0.4
    --   table.insert(plant.autoplace.peaks, peak)
    -- end

    local peak_string
    for expression, expr in pairs(plant.autoplace.local_expressions) do
      if string.find(expression, "_moisture_optimal") then
        peak_string = string.sub(expression, 1, 5)
      end
    end
    if not peak_string then
      peak_string = "new_peak"
      local exprs = plant.autoplace.local_expressions
      exprs["peaks_expr"] = exprs["peaks_expr"].." + "..peak_string.."_expr"
      exprs[peak_string.."_expr"] = peak_string.."_distance_expression"
      exprs[peak_string.."_distance_expression"] = "(1 - ("..peak_string.."_total_distance * (2 / 1)))"
      exprs[peak_string.."_total_distance"] = peak_string.."_moisture_expr"
      exprs[peak_string.."_moisture_expr"] = "ab_mimic_peak_dimension(moisture,"..peak_string.."_moisture_optimal,"..peak_string.."_moisture_range,"..peak_string.."_moisture_max_range)"
      exprs[peak_string.."_moisture_optimal"] = 1
      exprs[peak_string.."_moisture_range"] = 0.3
      exprs[peak_string.."_moisture_max_range"] = 0.4
    end

    for dimension_name, dimension in pairs(axis.dimensions) do
      dimension_autoplace(plant.autoplace.local_expressions, peak_string, dimension_name, dimension[1], dimension[2])
    end
    --log(plant.name.." AUTOPLACE: "..serpent.block(plant.autoplace.local_expressions))
    if plant_name == "asterisk" then
      plant.autoplace.tile_restriction = table.deepcopy(not_extreme)
    elseif plant_name ~= "desert-bush" then
      plant.autoplace.tile_restriction = table.deepcopy(not_harsh)
    end
    if plant.autoplace.tile_restriction == nil or table_size(plant.autoplace.tile_restriction) > 0 then
      data:extend({plant})
      --Add the decorative to nauvis planet description
      if nauvis_deco_settings then
        nauvis_deco_settings[plant.name] = {}
      end
    end
  end
end
