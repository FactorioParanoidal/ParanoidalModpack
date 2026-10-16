require("particle-animations")
local sounds = require("__base__/prototypes/entity/sounds")
local tile_colors = require("prototypes/tile/tile-colors")

local default_smoke_trigger_effect = function()
  return
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-explosion-particle",
    starting_frame_deviation = 5,
    --starting_frame_speed_deviation = 5,
    offset_deviation = {{-0.06, -0.06}, {0.06, 0.06}},
    speed_from_center = 0.007
  }
end

local tiny_smoke_trigger_effect = function()
  return
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-explosion-particle-tiny",
    starting_frame_deviation = 0,
    --starting_frame_speed_deviation = 0,
    offset_deviation = {{-0.03, -0.03}, {0.03, 0.03}},
    speed_from_center = nil,
  }
end

local small_smoke_trigger_effect = function()
  return
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-explosion-particle-small",
    starting_frame_deviation = 0,
    --starting_frame_speed_deviation = 0,
    offset_deviation = {{-0.03, -0.03}, {0.03, 0.03}},
    speed_from_center = nil,
  }
end

local small_lower_smoke_trigger_effect = function()
  return
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-explosion-lower-particle-small",
    starting_frame_deviation = 0,
    --starting_frame_speed_deviation = 0,
    offset_deviation = {{-0.03, -0.03}, {0.03, 0.03}},
    speed_from_center = nil,
  }
end

local small_dust_smoke_trigger_effect = function()
  return
  {
    type = "create-trivial-smoke",
    smoke_name = "smoke-explosion-particle-stone-small",
    starting_frame_deviation = 0,
    --starting_frame_speed_deviation = 0,
    offset_deviation = {{-0.03, -0.03}, {0.03, 0.03}},
    speed_from_center = nil,
  }
end

local default_ended_in_water_trigger_effect = function()
  return
  {

    {
      type = "create-particle",
      probability = 1,
      affects_target = false,
      show_in_tooltip = false,
      particle_name = "tintable-water-particle",
      apply_tile_tint = "secondary",
      offset_deviation = { { -0.05, -0.05 }, { 0.05, 0.05 } },
      tile_collision_mask = nil,
      initial_height = 0,
      initial_height_deviation = 0.02,
      initial_vertical_speed = 0.05,
      initial_vertical_speed_deviation = 0.05,
      speed_from_center = 0.01,
      speed_from_center_deviation = 0.006,
      frame_speed = 1,
      frame_speed_deviation = 0,
      tail_length = 2,
      tail_length_deviation = 1,
      tail_width = 3
    },
    {
      type = "create-particle",
      repeat_count = 10,
      repeat_count_deviation = 6,
      probability = 0.03,
      affects_target = false,
      show_in_tooltip = false,
      particle_name = "tintable-water-particle",
      apply_tile_tint = "primary",
      offsets =
      {
        { 0, 0 },
        { 0.01563, -0.09375 },
        { 0.0625, 0.09375 },
        { -0.1094, 0.0625 }
      },
      offset_deviation = { { -0.2969, -0.1992 }, { 0.2969, 0.1992 } },
      tile_collision_mask = nil,
      initial_height = 0,
      initial_height_deviation = 0.02,
      initial_vertical_speed = 0.053,
      initial_vertical_speed_deviation = 0.005,
      speed_from_center = 0.02,
      speed_from_center_deviation = 0.006,
      frame_speed = 1,
      frame_speed_deviation = 0,
      tail_length = 9,
      tail_length_deviation = 0,
      tail_width = 1
    },
    {
      type = "play-sound",
      sound = sounds.small_splash,
    },
  }

end

local Particles = {}

Particles.particle_tints_dirt_sand = {
  tan = {193,162,127},
  white = {255,255,255},
  grey = {177,183,187},
  black = {50,50,50},
  purple = {169,177,239},
  red = {185,107,105},
  violet = {165,107,161},
  dustyrose = {180,148,137},
  cream = {234,216,179},
  brown = {162,117,88},
  beige = {178,164,138},
  aubergine = {126,115,156}
}
for i, tint in pairs(Particles.particle_tints_dirt_sand) do
local tint_2 = {
  r = tint[1]/255,
  g = tint[2]/255,
  b = tint[3]/255,
  a = 1
}
Particles.particle_tints_dirt_sand[i] = tint_2
end

Particles.particle_tints_vegetation = {
  turquoise = { r = 0.2, g = 0.7, b = 0.7, a = 1 },
  green     = { r = 0.2, g = 0.7, b = 0.2, a = 1 },
  olive     = { r = 0.5, g = 0.7, b = 0.2, a = 1 },
  yellow    = { r = 0.7, g = 0.7, b = 0.2, a = 1 },
  orange    = { r = 0.7, g = 0.5, b = 0.2, a = 1 },
  red       = { r = 0.7, g = 0.2, b = 0.2, a = 1 },
  violet    = { r = 0.7, g = 0.2, b = 0.5, a = 1 },
  purple    = { r = 0.5, g = 0.2, b = 0.7, a = 1 },
  mauve     = { r = 0.3, g = 0.2, b = 0.7, a = 1 },
  blue      = { r = 0.2, g = 0.2, b = 0.7, a = 1 },
}


Particles.make_particle = function(params)

  if not params then error("No params given to Particles.make_particle function") end
  local name = params.name or error("No name given")

  local ended_in_water_trigger_effect = params.ended_in_water_trigger_effect or default_ended_in_water_trigger_effect()
  if params.ended_in_water_trigger_effect == false then
    ended_in_water_trigger_effect = nil
  end

  local particle =
  {

    type = "optimized-particle",
    name = name,

    life_time = params.life_time or 60 * 15,
    fade_away_duration = params.fade_away_duration,

    render_layer = params.render_layer or "projectile",
    render_layer_when_on_ground = params.render_layer_when_on_ground or "corpse",

    regular_trigger_effect_frequency = params.regular_trigger_effect_frequency or 2,
    regular_trigger_effect = params.regular_trigger_effect,
    ended_in_water_trigger_effect = ended_in_water_trigger_effect,

    pictures = params.pictures,
    shadows = params.shadows,
    draw_shadow_when_on_ground = params.draw_shadow_when_on_ground,

    movement_modifier_when_on_ground = params.movement_modifier_when_on_ground,
    movement_modifier = params.movement_modifier,
    vertical_acceleration = params.vertical_acceleration,

    mining_particle_frame_speed = params.mining_particle_frame_speed,

  }

  return particle

end


function Particles.add_tile_particles(biome)
  Particles.particle_sets = Particles.particle_sets or {}
  Particles.entity_particle_sets = Particles.entity_particle_sets or {}

  -- biome = tile
  local tile_name = biome.name
  local biome_set_name = biome.group..(biome.axis and ("-"..biome.axis) or "")

  local particle_set = Particles.particle_sets[biome_set_name]
  if not particle_set then
    local set_tint
    local function multiply_tints (tint_a, tint_b)
      return {
        r = (tint_a.r or tint_a[1]) * tint_b.r,
        g = (tint_a.g or tint_a[2]) * tint_b.g,
        b = (tint_a.b or tint_a[3]) * tint_b.b,
        a = (tint_a.a or 1) * (tint_b.a or 1),
      }
    end

    if biome.group == "dirt" or biome.group == "sand" then
      set_tint = Particles.particle_tints_dirt_sand[biome.axis]
    elseif biome.group == "vegetation" then
      set_tint = Particles.particle_tints_vegetation[biome.axis]
    elseif biome.group == "volcanic" then
      set_tint = Particles.particle_tints_dirt_sand["black"]
    elseif biome.group == "frozen" then
      set_tint = Particles.particle_tints_dirt_sand["white"]
    end
    if tile_colors[tile_name] then
      set_tint = multiply_tints ({1/255,1/255,1/255},tile_colors[tile_name])
    end
    if not set_tint then -- fallback
      set_tint = Particles.particle_tints_dirt_sand["brown"]
    end

    particle_set = {
        dust = Particles.make_particle
        {
          name = biome_set_name.."-dust-particle",
          life_time = 30,
          pictures = particle_animations.get_general_dust_particle ({ tint =  multiply_tints(set_tint, { r = 0.9, g = 0.9, b = 0.9, a = 1.000 })}),  --({ tint = { r = 0.443, g = 0.333, b = 0.189, a = 0.502 }}),
          shadows = nil,
          ended_in_water_trigger_effect = false,
          movement_modifier = 0.1,
          movement_modifier_when_on_ground = 0,
          fade_away_duration = 40,
          render_layer = "lower-object",
        },

        dust_vehicle = Particles.make_particle
        {
          name = biome_set_name.."-dust-vehicle-particle",
          life_time = 20,
          pictures = particle_animations.get_general_dust_particle ({ tint = multiply_tints(set_tint, { r = 0.6, g = 0.6, b = 0.6, a = 0.502 })}),
          shadows = nil,
          ended_in_water_trigger_effect = false,
          movement_modifier = 0.1
        },

        dust_vehicle_front = Particles.make_particle -- front ram?
        {
          name = biome_set_name.."-dust-tank-front-particle",
          life_time = 30,
          pictures = particle_animations.get_general_dust_particle ({ tint = multiply_tints(set_tint, { r = 0.6, g = 0.6, b = 0.6, a = 0.502 })}),
          shadows = nil,
          ended_in_water_trigger_effect = false,
          movement_modifier = 0.1,
          movement_modifier_when_on_ground = 0,
          render_layer = "lower-object",
        },

        tiny = Particles.make_particle
        {
          name = biome_set_name.."-stone-particle-tiny",
          pictures = particle_animations.get_stone_particle_tiny_pictures ({ tint = multiply_tints(set_tint, { r = 1, g = 1, b = 1, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_tiny_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = default_ended_in_water_trigger_effect()
        },

        tiny_character = Particles.make_particle
        {
          name = biome_set_name.."-stone-character-particle-tiny",
          life_time = 20,
          pictures = particle_animations.get_stone_particle_tiny_pictures ({ tint = multiply_tints(set_tint, { r = 0.9, g = 0.9, b = 0.9, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_tiny_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = false,
          render_layer = "lower-object-above-shadow"
        },

        tiny_vehicle = Particles.make_particle
        {
          name = biome_set_name.."-stone-vehicle-particle-tiny",
          life_time = 30,
          pictures = particle_animations.get_stone_particle_tiny_pictures ({ tint = multiply_tints(set_tint, { r = 0.8, g = 0.8, b = 0.8, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_tiny_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = false,
          render_layer = "lower-object-above-shadow"
        },

        small = Particles.make_particle
        {
          name = biome_set_name.."-stone-particle-small",
          pictures = particle_animations.get_stone_particle_small_pictures ({ tint = multiply_tints(set_tint, { r = 1.000, g = 1, b = 1, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_small_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = tiny_smoke_trigger_effect(),
          ended_in_water_trigger_effect = default_ended_in_water_trigger_effect()
        },

        small_vehicle = Particles.make_particle
        {
          name = biome_set_name.."-stone-vehicle-particle-small",
          life_time = 30,
          pictures = particle_animations.get_stone_particle_small_pictures ({ tint = multiply_tints(set_tint, { r = 0.9, g = 0.9, b = 0.9, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_small_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = false,
          render_layer = "lower-object-above-shadow"
        },

        medium = Particles.make_particle
        {
          name = biome_set_name.."-stone-particle-medium",
          pictures = particle_animations.get_stone_particle_medium_pictures ({ tint = multiply_tints(set_tint, { r = 1.000, g = 1, b = 1, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_medium_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = small_smoke_trigger_effect(),
          ended_in_water_trigger_effect = default_ended_in_water_trigger_effect()
        },

        medium_lower = Particles.make_particle
        {
          name = biome_set_name.."-stone-lower-particle-medium",
          pictures = particle_animations.get_stone_particle_medium_pictures ({ tint = multiply_tints(set_tint, { r = 1.000, g = 1, b = 1, a = 1.000 })}),
          shadows = particle_animations.get_stone_particle_medium_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = small_smoke_trigger_effect(),
          ended_in_water_trigger_effect = false,
          render_layer = "lower-object-above-shadow"
        },

        vegetation_small = Particles.make_particle
        {
          name = biome_set_name.."-vegetation-particle-small-medium",
          pictures = particle_animations.get_vegetation_particle_small_medium_pictures({ tint = { r = 1.000, g = 1, b = 1, a = 1.000 }}),
          shadows =particle_animations.get_vegetation_particle_small_medium_pictures({ tint = shadowtint(), shift = util.by_pixel (0.5,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = false
        },

        vegetation_small_character = Particles.make_particle
        {
          name = biome_set_name.."-vegetation-character-particle-small-medium",
          life_time = 20,
          pictures = particle_animations.get_vegetation_particle_character_pictures ({ tint = { r = 1.000, g = 1, b = 1, a = 1.000 }}),
          shadows = nil,
          ended_in_water_trigger_effect = false,
          render_layer = "lower-object-above-shadow"
        },

        splinter = Particles.make_particle
        {
          name = biome_set_name.."-grass-wooden-splinter-particle-small",
          pictures = particle_animations.get_wooden_splinter_particle_small_pictures ({ tint = { r =  1, g = 1, b = 1, a = 1.000 }}),
          shadows = particle_animations.get_wooden_splinter_particle_small_pictures({ tint = shadowtint(), shift = util.by_pixel (1,0)}),
          regular_trigger_effect = nil,
          ended_in_water_trigger_effect = false
        },
    }
    Particles.particle_sets[biome_set_name] = particle_set
    for _, p in pairs(particle_set) do
      data:extend({p})
    end
  end

  for _, entity_type in pairs({"character", "car"}) do
    Particles.entity_particle_sets[entity_type] = Particles.entity_particle_sets[entity_type]  or {}
    local entity_particle_set = Particles.entity_particle_sets[entity_type][biome_set_name]
    if not entity_particle_set then
      -- make the set
      entity_particle_set = {
        tiles = { },
        actions = { }
      }
      Particles.entity_particle_sets[entity_type][biome_set_name] = entity_particle_set
      if entity_type == "character" then
        if biome.group == "vegetation" then
          entity_particle_set.actions =  {
            {
              type = "create-particle",
              repeat_count = 5,
              particle_name = particle_set.vegetation_small_character.name,
              probability = 1,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.01,
              frame_speed = 0.4,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
            {
              type = "create-particle",
              repeat_count = 4,
              particle_name = particle_set.tiny_character.name,
              probability = 1,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.01,
              frame_speed = 0.4,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
            {
              type = "create-particle",
              repeat_count = 2,
              particle_name = particle_set.dust_vehicle.name,
              probability = 0.75,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.01,
              frame_speed = 0.4,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
            {
              type = "create-particle",
              repeat_count = 1,
              particle_name = particle_set.splinter.name,
              probability = 0.25,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.01,
              frame_speed = 0.4,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
          }
        else
          entity_particle_set.actions =  {
            {
              type = "create-particle",
              repeat_count = 5,
              particle_name = particle_set.dust.name,
              probability = 1,
              initial_height = 0.2,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
            {
              type = "create-particle",
              repeat_count = 1,
              particle_name = particle_set.tiny_character.name,
              probability = 1,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.01,
              frame_speed = 0.4,
              initial_vertical_speed_deviation = 0.05,
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
            },
          }
        end
      else -- tanks and car together for now
        if biome.group == "vegetation" then
          entity_particle_set.actions =  {
            {
              type = "create-particle",
              repeat_count = 2,
              particle_name = particle_set.tiny_vehicle.name,
              probability = 0.05,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.8,-0.5},
                {-0.8,-0.5},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.2, -0.25}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 2,
              particle_name = particle_set.small.name,
              probability = 0.05,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.9,-0.5},
                {-0.8,-0.5},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 7,
              particle_name = particle_set.vegetation_small.name,
              probability = 0.07,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.8,-0.5},
                {-0.8,-0.5},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 5,
              particle_name = particle_set.dust.name,
              probability = 0.1,
              initial_height = 0.2,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.25, -0.25}, {0.25, 0.25}},
              rotate_offsets = true
            },
          }
        else
          entity_particle_set.actions =  {
            {
              type = "create-particle",
              repeat_count = 8,
              particle_name = particle_set.dust.name,
              probability = 0.3,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.7, 1},
                {-0.7,1}
              },
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 5,
              particle_name = particle_set.dust_vehicle_front.name,
              probability = 0.3,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.7, -1},
                {-0.7,-1}
              },
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 4,
              particle_name = particle_set.tiny_vehicle.name,
              probability = 0.05,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.8,-0.5},
                {-0.8,-0.5},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.2, -0.25}, {0.2, 0.2}},
              rotate_offsets = true
            },
            {
              type = "create-particle",
              repeat_count = 3,
              particle_name = particle_set.small_vehicle.name,
              probability = 0.05,
              initial_height = 0.1,
              speed_from_center = 0.01,
              speed_from_center_deviation = 0,
              initial_vertical_speed = 0.02,
              frame_speed = 1,
              initial_vertical_speed_deviation = 0.05,
              offsets =
              {
                {0.75, 1},
                {-0.75,1},
                {0.8,-0.5},
                {-0.8,-0.5},
                {0.8, -1},
                {-0.8,-1}
              },
              offset_deviation = {{-0.2, -0.2}, {0.2, 0.2}},
              rotate_offsets = true
            },
          }
        end
      end
    end
    table.insert(entity_particle_set.tiles, tile_name)
  end

end

function Particles.apply_tile_particles()

  if Particles.entity_particle_sets then
    for entity_type, entity_particle_set in pairs(Particles.entity_particle_sets) do
      for _, set in pairs(entity_particle_set) do
        if entity_type == "car" then
          for _, car in pairs(data.raw.car) do
            if car.track_particle_triggers then
              table.insert(car.track_particle_triggers, table.deepcopy(set))
            end
          end
        elseif entity_type == "character" then
          for _, character in pairs(data.raw.character) do
            if character.synced_footstep_particle_triggers then
              table.insert(character.synced_footstep_particle_triggers, table.deepcopy(set))
            end
          end
        end
      end
    end
  end

end

return Particles
