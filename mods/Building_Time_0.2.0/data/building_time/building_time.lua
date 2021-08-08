local make_smoke = function(size)

local smoke =
  {
    type = "smoke-with-trigger",
    name = "building-smoke-"..size,
    flags = {"not-on-map", "placeable-off-grid"},
    show_when_smoke_off = true,
    affected_by_wind = false,
    cyclic = true,
    duration = 2 ^ 31,
    fade_away_duration = 1,
    fade_in_duration = 2 ^ 30,
    spread_duration = 10,
    movement_slow_down_factor = 0,
    animation = util.empty_sprite(),
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "nested-result",
          action =
          {
            {
              type = "area",
              collision_mode = "distance-from-center",
              radius = 0,
              force = "same",
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  type = "damage",
                  damage =
                  {
                    amount = - shared.repair_rate / 60,
                    type = util.damage_type("building-time")
                  }
                }
              }
            },
            {
              type = "area",
              target_entities = false,
              probability = size / 60,
              radius = size / 2,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  type = "create-entity",
                  entity_name = "sparks-explosion"
                }
              }
            }
          }
        }
      }
    },
    action_cooldown = 1
  }
  data:extend{smoke}
end

local sparks_animations =
{
  {
    filename = "__base__/graphics/entity/sparks/sparks-01.png",
    width = 39,
    height = 34,
    frame_count = 19,
    line_length = 19,
    shift = {-0.109375, 0.3125},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  },
  {
    filename = "__base__/graphics/entity/sparks/sparks-02.png",
    width = 36,
    height = 32,
    frame_count = 19,
    line_length = 19,
    shift = {0.03125, 0.125},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  },
  {
    filename = "__base__/graphics/entity/sparks/sparks-03.png",
    width = 42,
    height = 29,
    frame_count = 19,
    line_length = 19,
    shift = {-0.0625, 0.203125},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  },
  {
    filename = "__base__/graphics/entity/sparks/sparks-04.png",
    width = 40,
    height = 35,
    frame_count = 19,
    line_length = 19,
    shift = {-0.0625, 0.234375},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  },
  {
    filename = "__base__/graphics/entity/sparks/sparks-05.png",
    width = 39,
    height = 29,
    frame_count = 19,
    line_length = 19,
    shift = {-0.109375, 0.171875},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  },
  {
    filename = "__base__/graphics/entity/sparks/sparks-06.png",
    width = 44,
    height = 36,
    frame_count = 19,
    line_length = 19,
    shift = {0.03125, 0.3125},
    tint = { r = 1.0, g = 0.9, b = 0.0, a = 1.0 },
    animation_speed = 0.3
  }
}

local random_sparks = function()
  return util.copy(sparks_animations[math.random(#sparks_animations)])
end

local make_spark_random_spark = function()
  local speed_modifier = 1 + ((math.random() - 0.5) / 4)
  local scale_modifier = 1 + ((math.random() - 0.5) / 4)
  local random_spark = random_sparks()
  random_spark.animation_speed = random_spark.animation_speed * speed_modifier
  random_spark.scale = 1 * speed_modifier
  random_spark.tint.a = math.random()
  return random_spark
end

local random_spark_animation = {}

for k = 1, 100 do
  random_spark_animation[k] = make_spark_random_spark()
end

local explosion =
{
  type = "explosion",
  name = "sparks-explosion",
  flags = {"not-on-map"},
  height = 0.1,
  light = {intensity = 0.5, size = 5, color = {r=1.0, g=1.0, b=0.3}},
  animations = random_spark_animation
}

data:extend
{
  explosion
}

for k = 1, 10 do
  --make_smoke(k)
end

local robot =
{
  type = "construction-robot",
  name = "repair-block-robot",
  localised_name = "UwU, you weren't meant to see me oUo",
  icon = "__base__/graphics/icons/construction-robot.png",
  icon_size = 32,
  flags = {"placeable-off-grid", "not-on-map"},
  max_health = 1000000000,
  collision_box = {{0, 0}, {0, 0}},
  selection_box = {{0, 0}, {0, 0}},
  hit_visualization_box = {{0, 0}, {0, 0}},
  max_payload_size = 1,
  speed = 0,
  max_energy = "15000MJ",
  energy_per_tick = "0.01J",
  speed_multiplier_when_out_of_energy = 1,
  energy_per_move = "0.01J",
  min_to_charge = 0.01,
  max_to_charge = 0.99,
  repairing_sound =
  {
    { filename = "__base__/sound/robot-repair-1.ogg", volume = 0},
  },
  cargo_centered = {0, 0},
  construction_vector = {0, 0},
  idle = util.empty_sprite(),
  idle_with_cargo = util.empty_sprite(),
  in_motion = util.empty_sprite(),
  in_motion_with_cargo = util.empty_sprite(),
  shadow_idle = util.empty_sprite(),
  shadow_idle_with_cargo = util.empty_sprite(),
  shadow_in_motion = util.empty_sprite(),
  shadow_in_motion_with_cargo = util.empty_sprite(),
  working = util.empty_sprite(),
  shadow_working = util.empty_sprite()
}

data:extend{robot}

local lines =
{
  "We're no strangers to love",
  "You know the rules and so do I",
  "A full commitment's what I'm thinking of",
  "You wouldn't get this from any other guy",
  "",
  "I just wanna tell you how I'm feeling",
  "Gotta make you understand",
  "",
  "Never gonna give you up",
  "Never gonna let you down",
  "Never gonna run around and desert you",
  "Never gonna make you cry",
  "Never gonna say goodbye",
  "Never gonna tell a lie and hurt you"
}

local make_turret = function(size)
  local turret =
  {
    type = "unit",
    name = "building-time-unit-"..size,
    icon = "__base__/graphics/icons/repair-pack.png",
    localised_name = lines[size] or "",
    order = string.rep("Z", size),
    icon_size = 64,
    flags = {"placeable-off-grid", "not-on-map"},
    max_health = 200000000,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{0, 0}, {0, 0}},
    collision_mask = {},
    run_animation = util.empty_sprite(),
    prepare_range = 1,
    movement_speed = 1,
    distance_per_frame = 1,
    pollution_to_join_attack = 10000000,
    distraction_cooldown = 1000000,
    vision_distance = 1,
    attack_parameters =
    {
      animation = util.empty_sprite(),
      type = "stream",
      cooldown = 1,
      range = 100,
      min_range = -1,
      ammo_type =
      {
        category = "building-time",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              {
                type = "damage",
                damage =
                {
                  amount = - shared.repair_rate / 60,
                  type = util.damage_type("building-time")
                }
              },
              {
                type = "nested-result",
                action =
                {
                  type = "area",
                  target_entities = false,
                  probability = size / 60,
                  radius = size / 2,
                  action_delivery =
                  {
                    type = "instant",
                    target_effects =
                    {
                      type = "create-entity",
                      entity_name = "sparks-explosion"
                    }
                  }
                }
              }
            }
          }
        }
      }
    },
    call_for_help_radius = 0
  }
  data:extend{turret}
end

for k = 1, 12 do
  make_turret(k)
end

local category =
{
  type = "ammo-category",
  name = "building-time"
}

data:extend{category}

local repair_block_roboport =
{
  type = "roboport",
  name = "repair-block-roboport",
  icon = "__base__/graphics/icons/roboport.png",
  icon_size = 64,
  flags = {"placeable-off-grid","not-on-map"},
  max_health = 50000000,
  collision_box = {{0, 0}, {0, 0}},
  selection_box = {{0, 0}, {0, 0}},
  energy_source =
  {
    type = "void",
    usage_priority = "secondary-input",
    input_flow_limit = "5MW",
    buffer_capacity = "100MJ"
  },
  recharge_minimum = "40MJ",
  energy_usage = "50kW",
  -- per one charge slot
  charging_energy = "1000kW",
  logistics_radius = 0,
  construction_radius = 1,
  charge_approach_distance = 0,
  robot_slots_count = 0,
  material_slots_count = 0,
  stationing_offset = {0, 0},
  charging_offsets = {},
  base =util.empty_sprite(),
  base_patch =util.empty_sprite(),
  base_animation =util.empty_sprite(),
  door_animation_up =util.empty_sprite(),
  door_animation_down =util.empty_sprite(),
  recharging_animation =util.empty_sprite(),
  request_to_open_door_timeout = 15,
  spawn_and_station_height = -0.1,

  draw_logistic_radius_visualization = false,
  draw_construction_radius_visualization = false,

  circuit_wire_connection_point = circuit_connector_definitions["roboport"].points,
  circuit_connector_sprites = circuit_connector_definitions["roboport"].sprites,
  circuit_wire_max_distance = default_circuit_wire_max_distance,

  default_available_logistic_output_signal = {type = "virtual", name = "signal-X"},
  default_total_logistic_output_signal = {type = "virtual", name = "signal-Y"},
  default_available_construction_output_signal = {type = "virtual", name = "signal-Z"},
  default_total_construction_output_signal = {type = "virtual", name = "signal-T"},
}

data:extend{repair_block_roboport}
