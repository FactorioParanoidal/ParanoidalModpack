-- note: planet temperature controls could be controlled by altering noise-expression parameters
-- allow snow decals near snow transition zone
--local noise = require("noise")
local Particles = require("particles")
local biomes = {}

local tile_noise_weight = 0.5
local tile_noise_enabled = true
--local tile_noise_persistence = 0.75

--local tile_noise_influence = 2/3
local size_control_influence = 1
local plateau_influence = 1
local beach_influence = 1
local beach_range = 5

local dimension_influence = nil
local noise_influence = 0.02 -- 0.05
local terrain_noise_scale = 4

local tint_matrices = require("prototypes/tint-matrices")
biomes.transitions = require("prototypes/tile/tile-transitions-static")
biomes.sounds = require("prototypes/tile/tile-sounds")
biomes.colors = require("prototypes/tile/tile-colors")
biomes.tile_alias = require("prototypes/tile/tile-alias")
biomes.axes = require("prototypes/biome/biome-axes")
biomes.spec = require("prototypes/biome/biome-spec")

---@class TileDef
---@field name string
---@field tags table<string, string>

---@type table<string, TileDef> Indexed by tile name, populated in build_tiles()
biomes.tiles_all = {}

biomes.all_tiles = function()
  return table.deepcopy(biomes.tiles_all)
end

biomes.add_tag = function(tile, tag)
  tile.tags[tag] = tag
end

-- biomes.require_tag((biomes.require_tag(biomes.all_tiles(), {"dirt", "sand"}), {"aubergine", "purple", "violet", "mauve"})
-- require ONE of many tags
biomes.require_tag = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    local valid = false
    for _, tag in pairs(tags) do
      if tile.tags[tag] then valid = true break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

-- require ALL of many tags
biomes.require_tags = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    local valid = true
    for _, tag in pairs(tags) do
      if not tile.tags[tag] then valid = false break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

-- add tile sets together
biomes.add_tiles = function(tiles_a, tiles_b)
  local tiles = {}
  for tile_key, tile in pairs(tiles_a) do
    tiles[tile_key] = tile
  end
  for tile_key, tile in pairs(tiles_b) do
    tiles[tile_key] = tile
  end
  return tiles
end

-- tiles only returned if they appear in both
biomes.multiply_tiles = function(tiles_a, tiles_b)
  local tiles = {}
  for tile_key, tile in pairs(tiles_a) do
    if tiles_b[tile_key] then
      tiles[tile_key] = tile
    end
  end
  return tiles
end

-- require NONE of many tags
biomes.exclude_tags = function(tiles, tags)
  for tile_key, tile in pairs(tiles) do
    local valid = true
    for _, tag in pairs(tags) do
      if tile.tags[tag] then valid = false break end
    end
    if not valid then tiles[tile_key] = nil end
  end
  return tiles
end

---@param tiles table<string, TileDef>
---@return table<string> Tile names
biomes.list_tiles = function(tiles)
  local list = {}
  for tile_key, tile in pairs(tiles) do
    table.insert(list, tile_key)
  end
  return list
end



local function scaled_noise_layer_expression(noise_name, scale)
  --if tile_noise_enabled == false then return noise.to_noise_expression(0) end
  return "multioctave_noise{x = x,\z
                            y = y,\z
                            persistence = 0.75,\z
                            seed0 = map_seed,\z
                            seed1 = '"..noise_name.."',\z
                            octaves = 5,\z
                            input_scale = 1/6/"..scale..",\z
                            output_scale = 0.666}"
  --[[
  return noise.function_application("factorio-multioctave-noise",
    {
      x = noise.var("x") / scale,
      y = noise.var("y") / scale,
      persistence = tile_noise_persistence,
      seed0 = noise.var("map_seed"),
      seed1 = noise.noise_layer_name_to_id(noise_name),
      input_scale = noise.fraction(1, 6),
      output_scale = tile_noise_influence,
      octaves = 5,
    }
  )
  ]]
end

local function terrain_noise_layer_expression(i)
  return "multioctave_noise{x = x,\z
                            y = y,\z
                            offset_x = 1000,\z
                            persistence = 0.75,\z
                            seed0 = map_seed,\z
                            seed1 = ".. (1000 + i)..",\z
                            octaves = 6,\z
                            input_scale = 1/6/4,\z
                            output_scale = 0.666}"
  --[[
  return noise.function_application("factorio-multioctave-noise",
    {
      x = noise.var("x") / terrain_noise_scale + 1000 * i,
      y = noise.var("y") / terrain_noise_scale,
      persistence = tile_noise_persistence,
      seed0 = noise.var("map_seed"),
      seed1 = noise.noise_layer_name_to_id("terrain-variation"),
      input_scale = noise.fraction(1, 6),
      output_scale = tile_noise_influence,
      octaves = 6,
    }
  )]]
end

data:extend({
  {
    type = "noise-function",
    name = "peak_to_noise_expression",
    parameters = {"variable", "optimal", "range"},
    expression = "range - ridge( variable - optimal, 0, 100000)",
  },
  {
    type = "noise-function",
    name = "plateau_peak_to_noise_expression",
    parameters = {"variable", "optimal", "range"},
    expression = "min(peak_to_noise_expression(variable, optimal, range) * 20, 1)",
  },
})

--[[
local function peak_to_noise_expression(variable, optimal, range)
  local distance_from_optimal = noise.ridge(variable - optimal, 0, math.huge)
  -- Idea is to have a plateau in the center of the rectangle,
  -- edges that taper off at a consistent slope for all rectangles (so that interactions between rectangles are predictable),
  return range - distance_from_optimal
end

local function plateau_peak_to_noise_expression(variable, optimal, range)
  -- Clamp rectangle-based peaks so that large rectangles don't become
  -- super powerful at their centers, because we want to be able to override
  -- them e.g. with beach peaks or whatever
  return noise.min(peak_to_noise_expression(variable, optimal, range) * 20, 1) * plateau_influence
end
]]
local function string_min(a, b)
  return "min(" .. a .. ", ".. b .. ")"
end

local function volume_to_noise_expression(volume)

  local result = nil
  if (volume["aux_min"] and  volume["aux_max"]) then
    local aux_center = (volume["aux_min"] + volume["aux_max"]) / 2
    local aux_range = math.abs(volume["aux_min"] - volume["aux_max"]) / 2

    --local aux_fitness = plateau_peak_to_noise_expression(noise.var("aux"), aux_center, aux_range)
    local aux_fitness = "plateau_peak_to_noise_expression(aux,"..aux_center..","..aux_range..")"
    result = aux_fitness
  end

  if (volume["moisture_min"] and  volume["moisture_max"]) then
    local moisture_center = (volume["moisture_min"] + volume["moisture_max"]) / 2
    local moisture_range = math.abs(volume["moisture_min"] - volume["moisture_max"]) / 2
    --local water_fitness = plateau_peak_to_noise_expression(noise.var("moisture"), water_center, water_range)
    local moisture_fitness = "plateau_peak_to_noise_expression(moisture,"..moisture_center..","..moisture_range..")"
    if(result == nil) then
      result = moisture_fitness
    else
      result = string_min(result, moisture_fitness)
    end
  end

  if (volume["temperature_min"] and  volume["temperature_max"]) then
    local temperature_center = (volume["temperature_min"] + volume["temperature_max"]) / 2
    local temperature_range = math.abs(volume["temperature_min"] - volume["temperature_max"]) / 2
    --local temperature_fitness = plateau_peak_to_noise_expression(noise.var("temperature"), temperature_center, temperature_range)
    local temperature_fitness = "plateau_peak_to_noise_expression(temperature,"..temperature_center..","..temperature_range..")"
    if(result == nil) then
      result = temperature_fitness
    else
      result = string_min(result, temperature_fitness)
    end
  end

  if (volume["elevation_min"] and  volume["elevation_max"]) then
    local elevation_center = (volume["elevation_min"] + volume["elevation_max"]) / 2
    local elevation_range = math.abs(volume["elevation_min"] - volume["elevation_max"]) / 2
    --local elevation_fitness = plateau_peak_to_noise_expression(noise.var("elevation"), elevation_center, elevation_range)
    local elevation_fitness = "plateau_peak_to_noise_expression(elevation,"..elevation_center..","..elevation_range..")"
    if(result == nil) then
      result = elevation_fitness
    else
      result = string_min(result, elevation_fitness)
    end
  end

  return result
end

local function apply_beach_expression(probability_expression, volume, beach_weight)

  beach_weight = (beach_weight ~= nil) and beach_weight or -1

  if (beach_weight < 0) then

      probability_expression = "(" .. probability_expression .. " + min(0, -1 + elevation / "..beach_range.."))"

  elseif(beach_weight > 0)then

      -- boost at beaches but it must be the right type of terrain.
      -- ignore the moisture axis
      local volume2 = table.deepcopy(volume)
      volume2.water_min = nil
      volume2.water_max = nil
      local sanswater = volume_to_noise_expression(volume2)
      local beach = "min(elevation, 0 - elevation) / " .. beach_range

      probability_expression = "max(" .. probability_expression .. ", " .. sanswater .. " + " .. beach .. ")"

  end

  return probability_expression

end



biomes.combine_volume_constraints = function(volume, axis, point_a, point_b)

  local r_point_a = point_a
  local r_point_b = point_b
  -- dimension can be flipped
  if biomes.axes[axis].reverse then
    r_point_a = 1 - point_a
    r_point_b = 1 - point_b
  end
  -- get real low and high (b might be lower than a)
  local point_l = math.min(r_point_a, r_point_b)
  local point_h = math.max(r_point_a, r_point_b)

  local dimension = biomes.axes[axis].dimension

  local low = biomes.axes[axis].low
  local high = biomes.axes[axis].high

  local d_point_a = low + (high - low) * point_l
  local d_point_b = low + (high - low) * point_h

  if(volume[dimension .. "_min"]) then
    volume[dimension .. "_min"] = math.max(d_point_a, volume[dimension .. "_min"]);
  else
    volume[dimension .. "_min"] = d_point_a;
  end

  if(volume[dimension .. "_max"]) then
    volume[dimension .. "_max"] = math.min(d_point_b, volume[dimension .. "_max"]);
  else
    volume[dimension .. "_max"] = d_point_b;
  end

  return volume
end

function tile_variations_template_ab(high_res_picture, high_res_transition, options)
  local function main_variation(size_)
    local y_ = ((size_ == 1) and 0) or ((size_ == 2) and 128) or ((size_ == 4) and 320) or 640
    local ret = {
      picture = high_res_picture,
      count = 16,
      size = size_,
      y = y_,
      line_length = (size_ == 8) and 8 or 16,
      scale = 0.5
    }

    if options[size_] then
      for k, v in pairs(options[size_]) do
        ret[k] = v
      end
    end

    return ret
  end

  local function make_transition_variation(x_, line_len_, cnt_)
    local ret = {
      spritesheet = high_res_transition,
      count = cnt_ or 8,
      line_length = line_len_ or 8,
      x = 2 * x_,
      scale = 0.5,
    }
    return ret
  end

  local main_ =
  {
    main_variation(1),
    main_variation(2),
    main_variation(4),
  }
  if (options.max_size == 8) then
    table.insert(main_, main_variation(8))
  end

  return
  {
    main = main_,
    transition = {
      layout = {
        mask = {
          inner_corner = make_transition_variation(0),
          outer_corner = make_transition_variation(288),
          side         = make_transition_variation(576),
          u_transition = make_transition_variation(864, 1, 1),
          o_transition = make_transition_variation(1152, 2, 1),
        }
      }
    }
  }
end

biomes.collapse = function ()
  local collapsed = {}
  for group_name, group in pairs(biomes.spec) do
    if group.axes then
      for axis_name, axis in pairs(group.axes) do
        for variant_name, variant in pairs(group.variants) do
          if variant.limit_axes then
            -- some varient only apply to axes types, i.e. grass varients 3 and 4 only exist on green grass
            local pass = false
            for _, allowed in pairs(variant.limit_axes) do
              if axis_name == allowed then pass = true end
            end
            if pass == false then break end
          end
          local volume = variant.volume and table.deepcopy(variant.volume) or {}
          for dimension_name, dimension in pairs(group.dimensions) do
            biomes.combine_volume_constraints( volume, dimension_name, dimension[1], dimension[2])
          end
          for dimension_name, dimension in pairs(axis.dimensions) do
            biomes.combine_volume_constraints( volume, dimension_name, dimension[1], dimension[2])
          end
          if variant.dimensions then
            for dimension_name, dimension in pairs(variant.dimensions) do
              biomes.combine_volume_constraints( volume, dimension_name, dimension[1], dimension[2])
            end
          end

          local biome = {volume = volume}
          biome.group = variant.group or group_name
          biome.axis = axis_name
          biome.variant = variant_name
          biome.transition = variant.transition
          biome.tags = variant.tags or {}
          biome.beach_weight = variant.beach_weight
          biome.frequency = variant.frequency
          biome.name = group_name .. "-" .. axis_name .. "-" .. variant_name
          collapsed[biome.name] = biome
        end
      end
    else
      for variant_name, variant in pairs(group.variants) do
        local volume = variant.volume and table.deepcopy(variant.volume) or {}
        for dimension_name, dimension in pairs(group.dimensions) do
          biomes.combine_volume_constraints( volume, dimension_name, dimension[1], dimension[2])
        end
        if variant.dimensions then
          for dimension_name, dimension in pairs(variant.dimensions) do
            biomes.combine_volume_constraints( volume, dimension_name, dimension[1], dimension[2])
          end
        end
        local biome = {volume = volume}
        biome.group = variant.group or group_name
        biome.variant = variant_name
        biome.transition = variant.transition
        biome.tags = variant.tags or {}
        biome.beach_weight = variant.beach_weight
        biome.weight = variant.weight or 1
        biome.name = group_name .. "-" .. variant_name
        collapsed[biome.name] = biome
      end
    end
  end
  biomes.collapsed = collapsed
end

biomes.collapse()

biomes.build_tiles = function ()

  -- Removing autoplace specifications cause Space Age to fail to load
  -- for name, tile in pairs(data.raw.tile) do
  --   if name ~= "water" and name ~= "deepwater" then
  --     data.raw.tile[name].autoplace = nil
  --   end
  -- end
  local layer = 0
  for biome_name, biome in pairs(biomes.collapsed) do
    local include_tile = true
    local setting_name = "alien-biomes-include-" .. biome.group
    if biome.axis then setting_name = setting_name .. "-" .. biome.axis end

    if settings.startup[setting_name] and settings.startup[setting_name].value == "Disabled" then
      include_tile = false
    end
    if include_tile then
      layer = layer + 1
      local control = biome.group
      if biome.axis then control = control .. "-" .. biome.axis end
      --local autoplace = { control = control, peaks = table.deepcopy(biome.peaks)}
      local tile = {
        name = biome_name,
        tags = {}
      }
      for _, tag in pairs(biome.tags) do
        biomes.add_tag(tile, tag)
      end
      biomes.add_tag(tile, biome.group)
      if biome.axis then
        biomes.add_tag(tile, biome.axis)
        biomes.add_tag(tile, biome.group .. "-" .. biome.axis) -- "grass-purple"
      end
      biomes.add_tag(tile, biome.variant)
      biomes.tiles_all[biome_name] = tile

      local probability_expression = volume_to_noise_expression(biome.volume)

        -- make larger patches of snow vs ice
      local snow_bias = 0.4
      local water_weight = 1
      local water_scale = 8
      if (biome.group == "frozen") then
        if (biome.variant == "snow-5") or
           (biome.variant == "snow-6") or
           (biome.variant == "snow-7") or
           (biome.variant == "snow-8") or
           (biome.variant == "snow-9") then
             -- ice
             probability_expression = probability_expression .. " - " .. (snow_bias - water_weight) .. " * " .. scaled_noise_layer_expression("water", water_scale)
        else
             probability_expression = probability_expression .. " + " .. (snow_bias + water_weight) .. " * " .. scaled_noise_layer_expression("water", water_scale)
        end
      end

      -- make patches of dirt in grass
      local grass_bias = 0.6
      local grass_noise_weight = 0.7
      local grass_noise_scale = 1
      if biome.group == "vegetation" then
        probability_expression = probability_expression .. " + " .. grass_bias .. " - " .. grass_noise_weight .. " * " .. scaled_noise_layer_expression("crater", grass_noise_scale)
      elseif biome.variant == "dirt-3" or biome.variant == "dirt-4" then  -- the ones in the grass moisture zone
        probability_expression = probability_expression .. " - " .. grass_bias .. " - " .. grass_noise_weight .. " * " .. scaled_noise_layer_expression("crater", grass_noise_scale)
      end

      probability_expression = apply_beach_expression(probability_expression, biome.volume, biome.beach_weight)
      probability_expression = probability_expression .. " + " .. tile_noise_weight .. " * " .. terrain_noise_layer_expression(layer)


      local tile_data = {
        type = "tile",
        name = biome_name,
        subgroup = "alien-biome-tiles",
        can_be_part_of_blueprint = false,
        collision_mask = {
          layers = {
            ground_tile = true
          },
        },
        autoplace = {probability_expression = probability_expression},
        --layer = layer,
        layer_group = "ground-natural",
        --layer = 190 - layer,
        variants = tile_variations_template_ab(
          (tint_matrices.tiles[biome_name] and tint_matrices.tiles[biome_name].picture)
            or "__Alien-biomes-Reforged__/graphics/terrain/"..biome_name..".png",
          "__base__/graphics/terrain/masks/transition-3.png",
          {
            max_size = 4,
            [1] = { weights = {0.085, 0.085, 0.085, 0.085, 0.087, 0.085, 0.065, 0.085, 0.045, 0.045, 0.045, 0.045, 0.005, 0.025, 0.045, 0.045 } },
            [2] = { probability = 1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
            [4] = { probability = 0.1, weights = {0.018, 0.020, 0.015, 0.025, 0.015, 0.020, 0.025, 0.015, 0.025, 0.025, 0.010, 0.025, 0.020, 0.025, 0.025, 0.010 }, },
            --[8] = { probability = 1.00, weights = {0.090, 0.125, 0.125, 0.125, 0.125, 0.125, 0.125, 0.025, 0.125, 0.005, 0.010, 0.100, 0.100, 0.010, 0.020, 0.020} },
          }
        ),
        transitions = biomes.transitions[biome.transition .. "_transitions"](),
        transitions_between_transitions = biomes.transitions[biome.transition .. "_transitions_between_transitions"](),

        walking_sound = table.deepcopy(biomes.sounds.dirt),
        map_color = biomes.colors[biome_name],
        absorptions_per_second={
          pollution = 0.000005,
          --pollen = 0.000005, --?
        },
        walking_speed_modifier = 1,
        vehicle_friction_modifier = 1,
      }
      if tint_matrices.tiles[biome_name] then
        tile_data.tint = tint_matrices.tiles[biome_name].tint
      end
      if biome.axis then
        tile_data.localised_name = { "tile-name.tile_colored", { "alien-biomes."..biome.axis }, { "alien-biomes."..biome.variant } }
      else
        tile_data.localised_name = { "tile-name.tile_single", { "alien-biomes."..biome.variant } }
      end
      if biome.group == "grass" then
        tile_data.walking_sound = table.deepcopy(biomes.sounds.grass)
        tile_data.walking_speed_modifier = 1
        tile_data.vehicle_friction_modifier = 1.6
        tile_data.absorptions_per_second={
          pollution = 0.0000075,
          --pollen = 0.0000075, --?
        }
      elseif biome.group == "dirt" then
        tile_data.walking_sound = table.deepcopy(biomes.sounds.dirt)
        tile_data.walking_speed_modifier = 1
        tile_data.vehicle_friction_modifier = 1.4
      elseif biome.group == "sand" then
        tile_data.walking_sound = table.deepcopy(biomes.sounds.sand)
        tile_data.walking_speed_modifier = 0.8
        tile_data.vehicle_friction_modifier = 2
        tile_data.absorptions_per_second={
          pollution = 0.0000025,
          --pollen = 0.0000025, --?
        }
      elseif biome.group == "frozen" then
        tile_data.walking_sound = table.deepcopy(biomes.sounds.snow)
        tile_data.walking_speed_modifier = 0.8
        tile_data.vehicle_friction_modifier = 2
        if biome.variant == "snow-5"
        or biome.variant == "snow-6"
        or biome.variant == "snow-7"
        or biome.variant == "snow-9" then -- ice
          tile_data.walking_sound = table.deepcopy(biomes.sounds.ice)
        end
      elseif biome.group == "volcanic" then
        tile_data.walking_sound = table.deepcopy(biomes.sounds.dirt)
        tile_data.absorptions_per_second={
          pollution = 0.0000025,
          --pollen = 0.0000025, --?
        }
        if biome.variant == "heat-1" then
          tile_data.walking_speed_modifier = 1
          tile_data.vehicle_friction_modifier = 2
        elseif biome.variant == "heat-2" then
          tile_data.walking_speed_modifier = 0.9
          tile_data.vehicle_friction_modifier = 4
        elseif biome.variant == "heat-3" then
          tile_data.walking_speed_modifier = 0.8
          tile_data.vehicle_friction_modifier = 8
        elseif biome.variant == "heat-4" then
          tile_data.walking_speed_modifier = 0.7
          tile_data.vehicle_friction_modifier = 16
        end
      end
      if tile_data.walking_speed_modifier < 1 then
        local mult = settings.startup['tile-speed-reduction'].value / 100
        tile_data.walking_speed_modifier = 1 - (1 - tile_data.walking_speed_modifier) * mult
      end

      data:extend({
        tile_data
      })

      -- Particles
      Particles.add_tile_particles(biome)

      if biome.group == "dirt" or biome.group == "sand" or biome.group == "volcanic" or biome.group == "frozen" then
        for _, character in pairs(data.raw.character) do
          if character.footprint_particles and character.footprint_particles[1] and character.footprint_particles[1].tiles then
            table.insert(character.footprint_particles[1].tiles, biome_name)
          end
        end
      end

    end
  end
end
biomes.build_tiles()
Particles.apply_tile_particles() -- bind to entities

if not(settings.startup["alien-biomes-include-inland-shallows"] and settings.startup["alien-biomes-include-inland-shallows"].value == "Disabled") then
  -- inland shallows, high moisture areas, allows decoratives
  data.raw.tile["water-mud"].autoplace = {
    probability_expression = volume_to_noise_expression({
      water_min = 0.9,
      water_max = 1.1,
      temperature_min = 0,
      temperature_max = 100
    })
    .. " + " .. tile_noise_weight .. " * min(" .. scaled_noise_layer_expression("water", 0.25)..", "..scaled_noise_layer_expression("water", 0.314) .. ")"
    .. " + min(0, -1 + elevation / " .. beach_range .. ")"
    .. " - 1.15"
  }
  data.raw.tile["water-mud"].map_color = {
    r = 54,
    g = 88,
    b = 90,
  }
  data.raw.tile["water-mud"].allowed_neighbors = nil
  data.raw.tile["water-mud"].collision_mask = {
      layers = {
        water_tile = true,
        floor = true,
        resource = true,
      },
  }
  data.raw.tile["water-mud"].walking_sound = table.deepcopy(biomes.sounds.water)
  data.raw.tile["water-mud"].walking_speed_modifier = 0.5
  data.raw.tile["water-mud"].vehicle_friction_modifier = 32
  biomes.tiles_all["water-mud"] = {
    name = "water-mud",
    tags = {"water-mud", "shallows"}
  }
end

--data.raw.tile.deepwater.autoplace = make_water_autoplace_settings(-5, 200)
data.raw.tile.deepwater.autoplace = {
  probability_expression = "min((-5 - elevation) * " .. math.huge .. ", 200 * min((-5 - elevation), 1))"
}

--data.raw.tile.water.autoplace = make_water_autoplace_settings(0, 100)
data.raw.tile.water.autoplace = {
  probability_expression = "min((0 - elevation) * " .. math.huge .. ", 100 * min((0 - elevation), 1))"
}

-- Coastal shallows / rivers
if settings.startup["alien-biomes-include-coastal-shallows"].value ~= "Disabled"
 or settings.startup["alien-biomes-include-rivers"].value ~= "Disabled" then

  data.raw.tile["water-shallow"].map_color = {
    r = 53,
    g = 97,
    b = 110,
  }
  data.raw.tile["water-shallow"].allowed_neighbors = nil
  data.raw.tile["water-shallow"].collision_mask = {
      layers = {
        water_tile = true,
        floor = true,
        resource = true,
        doodad = true,
      },
  }
  data.raw.tile["water-shallow"].walking_sound = table.deepcopy(biomes.sounds.water)
  data.raw.tile["water-shallow"].walking_speed_modifier = 0.5
  data.raw.tile["water-shallow"].vehicle_friction_modifier = 32

  local weight = 200
  --data.raw.tile["water-shallow"].autoplace = make_water_autoplace_settings(0, weight)
  data.raw.tile["water-shallow"].autoplace = {
    probability_expression = "min((0 - elevation) * " .. math.huge .. ", " .. weight .. " * min((0 - elevation), 1))"
  }
  local prob = data.raw.tile["water-shallow"].autoplace.probability_expression
  local coastal = prob
      .. " + " .. scaled_noise_layer_expression("water", 0.25) .. " * " .. weight .. " / 4"
      .. " + elevation  * " .. weight .. " / 2"
      .. " + min(temperature, 0) * " .. weight .. " * 50"

  -- rivers
  local ra = "abs("..scaled_noise_layer_expression("terrain-variation", "(2 + 2 / segmentation_multiplier)*2 ")..")"
  local rb = "abs("..scaled_noise_layer_expression("water", "(2 + 2 / segmentation_multiplier)*1 ")..")"
  local rc = "(0.05 * " .. ra .. " + 0.95 * min(" .. ra .. ", " .. rb .. "))"
  local rivers =
     "2 * (" .. volume_to_noise_expression({
       water_min = 0.66,
       water_max = 1.5,
       temperature_min = -20,
       temperature_max = 100
     }) .. " - 1)"
    .. "-0.6 * elevation"
    .. "+ (15 + -150 * " .. rc .. ")"

  if settings.startup["alien-biomes-include-coastal-shallows"].value ~= "Disabled" then
    data.raw.tile["water-shallow"].autoplace.probability_expression = coastal
    if settings.startup["alien-biomes-include-rivers"].value ~= "Disabled" then
      data.raw.tile["water-shallow"].autoplace.probability_expression = "max(" .. coastal .. ", " .. rivers .. ")"
    end
  else
    data.raw.tile["water-shallow"].autoplace.probability_expression = rivers
  end

  biomes.tiles_all["water-shallow"] = {
    name = "water-shallow",
    tags = {"water-shallow", "shallows"}
  }
end


--log( serpent.block( data.raw["tile"], {comment = false, numformat = '%1.8g' } ) )
--log( "biomes.tiles_all" .. serpent.block( biomes.tiles_all, {comment = false, numformat = '%1.8g' } ) )

return biomes
