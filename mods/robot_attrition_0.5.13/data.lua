local robot_flame = table.deepcopy(data.raw.fire["fire-flame-on-tree"])
robot_flame.name = "robot-crash-flame"
robot_flame.damage_per_tick = {amount = 10 / 60, type = "fire"}
robot_flame.fade_in_duration = 10
robot_flame.fade_out_duration = 60
data:extend({
  robot_flame
})



data:extend({
  {
    type = "explosion",
    name = "robot-explosion",
    animations = {{
      filename = "__base__/graphics/entity/medium-explosion/medium-explosion.png",
      width = 112,
      height = 94,
      line_length = 6,
      frame_count = 54,
      animation_speed = 0.5,
      priority = "high",
      shift = { -0.56, -0.96 },
      scale = 0.75,
    }},
    created_effect = {
      type = "direct",
      action_delivery = {
        type = "instant",
        target_effects = {
          {
            type = "create-particle",
            particle_name = "explosion-remnants-particle",
            initial_height = 0.5,
            initial_vertical_speed = 0.082,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = { { -0.2, -0.2 }, { 0.2, 0.2 } },
            repeat_count = 3,
            speed_from_center = 0.03,
            speed_from_center_deviation = 0.05,
          },
          {
            frame_speed = 1,
            frame_speed_deviation = 0.361,
            initial_height = 0.1,
            initial_height_deviation = 0.5,
            initial_vertical_speed = 0.04,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = {
              {
                -0.5,
                -0.5
              },
              {
                0.5,
                0.5
              }
            },
            particle_name = "cable-and-electronics-particle-small-medium",
            repeat_count = 13,
            speed_from_center = 0.02,
            speed_from_center_deviation = 0.05,
            type = "create-particle"
          },
          {
            frame_speed = 1,
            frame_speed_deviation = 0.463,
            initial_height = 1.2,
            initial_height_deviation = 0.5,
            initial_vertical_speed = 0.08,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = {
              {
                -0.6953,
                -0.2969
              },
              {
                0.6953,
                0.2969
              }
            },
            particle_name = "logistic-robot-metal-particle-medium",
            repeat_count = 10,
            speed_from_center = 0.02,
            speed_from_center_deviation = 0.05,
            type = "create-particle"
          },
          {
            initial_height = 1.4,
            initial_height_deviation = 0.5,
            initial_vertical_speed = 0.082,
            initial_vertical_speed_deviation = 0.05,
            offset_deviation = {
              {
                -0.5938,
                -0.5977
              },
              {
                0.5938,
                0.5977
              }
            },
            particle_name = "logistic-robot-metal-particle-small",
            repeat_count = 20,
            speed_from_center = 0.03,
            speed_from_center_deviation = 0.05,
            type = "create-particle"
          },
          { type = "nested-result", action = { type = "area", radius = 0.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 40, type = "explosion" }}}},
          }},
          { type = "nested-result", action = { type = "area", radius = 1.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 20, type = "explosion" }}}},
          }},
          { type = "nested-result", action = { type = "area", radius = 2.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 10, type = "explosion" }}}},
          }},
          { type = "nested-result", action = { type = "area", radius = 3.5,
              action_delivery = { type = "instant", target_effects = { { type = "damage", damage = { amount = 5, type = "explosion" }}}},
          }},
        },
      },
    },
    flags = { "not-on-map" },
    light = { color = { r = 1, g = 0.9, b = 0.8 }, intensity = 1, size = 15 },
    sound = {
      aggregation = { max_count = 1, remove = true },
      variations = {
        { filename = "__base__/sound/small-explosion-1.ogg", volume = 0.4 },
        { filename = "__base__/sound/small-explosion-2.ogg", volume = 0.4 },
        { filename = "__base__/sound/fight/large-explosion-1.ogg", volume = 0.4 },
        { filename = "__base__/sound/fight/large-explosion-2.ogg", volume = 0.4 }
      }
    },
  },
  {
    type = "technology",
    name = "robot-attrition-explosion-safety",
    effects = { },
    icon = "__robot_attrition__/graphics/technology/robot-safety.png",
    icon_size = 128,
    order = "e-g",
    prerequisites = {
      "logistic-system"
    },
    max_level = "infinite",
    unit = {
     count_formula = "100*L^2",
     time = 30,
     ingredients = {
       { "logistic-science-pack", 1 },
       { "utility-science-pack", 1 },
     }
    },
    upgrade = true
  },
  {
    type = "container",
    name = "logistic-robot-dropped-cargo",
    icon = "__robot_attrition__/graphics/icons/dropped-cargo.png",
    placeable_by = {item="logistic-robot", count = 1}, -- blueprintable, deconstrucitble
    icon_size = 64,
    icon_mipmaps = 1,
    flags = {"hidden", "placeable-neutral", "player-creation", "placeable-off-grid", "not-blueprintable"},
    minable = {
      mining_time = 0.1,
    },
    max_health = 25,
    dying_explosion = "spark-explosion",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.43 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.43 },
    resistances =
    {
      {
        type = "fire",
        percent = 100
      },
      {
        type = "explosion",
        percent = 100
      }
    },
    scale_info_icons = true,
    create_ghost_on_death = false,
    se_allow_in_space = true,
    collision_mask = {},
    collision_box = {{-0.1,-0.1},{0.1,0.1}},
    selection_box = {{-0.2,-0.2},{0.2,0.2}},
    drawing_box = {{-0.2,-0.2},{0.2,0.2}},
    selection_priority = 51,
    damaged_trigger_effect = {
      entity_name = "spark-explosion",
      offset_deviation = { { -0.5, -0.5 }, { 0.5, 0.5 } },
      offsets = { { 0, 1 } },
      type = "create-entity"
    },
    inventory_size = 1,
    picture =
    {
      layers =
      {
        {
          filename = "__robot_attrition__/graphics/entity/dropped-cargo/dropped-cargo.png",
          width = 27,
          height = 28,
          scale = 0.5,
        },
        {
          draw_as_shadow = true,
          filename = "__robot_attrition__/graphics/entity/dropped-cargo/dropped-cargo-shadow.png",
          width = 36,
          height = 21,
          scale = 0.5,
          shift = {0.1,0.05},
        },
      }
    },
    circuit_wire_max_distance = 0
  }
})

se_prodecural_tech_exclusions = se_prodecural_tech_exclusions or {}
table.insert(se_prodecural_tech_exclusions, "robot-attrition")
