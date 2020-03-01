data:extend(
  {
    {
      type = "tile",
      name = "plastic-flooring",
      needs_correction = false,
      minable = {hardness = 0.2, mining_time = 0.5, result = "plastic-flooring"},
      mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
      collision_mask = {"ground-tile"},
      walking_speed_modifier = 1.5,
      layer = 61,
      decorative_removal_probability = 0.75,
      variants =
      {
        main =
        {
          {
            picture = "__base__/graphics/terrain/concrete/concrete1.png",
            count = 16,
            size = 1
          },
          {
            picture = "__base__/graphics/terrain/concrete/concrete2.png",
            count = 4,
            size = 2,
            probability = 0.39,
          },
          {
            picture = "__base__/graphics/terrain/concrete/concrete4.png",
            count = 4,
            size = 4,
            probability = 1,
          },
        },
        inner_corner =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-inner-corner.png",
          count = 32
        },
        outer_corner =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-outer-corner.png",
          count = 16
        },
        side =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-side.png",
          count = 16
        },
        u_transition =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-u.png",
          count = 16
        },
        o_transition =
        {
          picture = "__base__/graphics/terrain/concrete/concrete-o.png",
          count = 1
        }
      },
      walking_sound =
      {
        {
          filename = "__base__/sound/walking/concrete-01.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-02.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-03.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-04.ogg",
          volume = 1.2
        }
      },
      map_color={r=100, g=100, b=100},
      ageing=0,
      vehicle_friction_modifier = concrete_vehicle_speed_modifier
    },
    --[[{
      type = "tile",
      name = "hazard-concrete-left",
      needs_correction = false,
      next_direction = "hazard-concrete-right",
      transition_merges_with_tile = "concrete",
      minable = {hardness = 0.2, mining_time = 0.5, result = "hazard-concrete"},
      mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
      collision_mask = {"ground-tile"},
      walking_speed_modifier = 1.4,
      layer = 61,
      decorative_removal_probability = 0.25,
      variants =
      {
        main =
        {
          {
            picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete1-left.png",
            count = 16,
            size = 1
          },
          {
            picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete2-left.png",
            count = 4,
            size = 2,
            probability = 0.39,
          },
          {
            picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete4-left.png",
            count = 4,
            size = 4,
            probability = 1,
          },
        },
        inner_corner =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete-inner-corner-left.png",
          count = 32
        },
        outer_corner =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete-outer-corner-left.png",
          count = 16
        },
        side =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete-side-left.png",
          count = 16
        },
        u_transition =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete-u-left.png",
          count = 16
        },
        o_transition =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-left/hazard-concrete-o-left.png",
          count = 1
        }
      },
      walking_sound =
      {
        {
          filename = "__base__/sound/walking/concrete-01.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-02.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-03.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-04.ogg",
          volume = 1.2
        }
      },
      map_color={r=0.5, g=0.5, b=0},
      ageing=0,
      vehicle_friction_modifier = concrete_vehicle_speed_modifier
    },
    {
      type = "tile",
      name = "hazard-concrete-right",
      needs_correction = false,
      next_direction = "hazard-concrete-left",
      transition_merges_with_tile = "concrete",
      minable = {hardness = 0.2, mining_time = 0.5, result = "hazard-concrete"},
      mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
      collision_mask = {"ground-tile"},
      walking_speed_modifier = 1.4,
      layer = 61,
      decorative_removal_probability = 0.25,
      variants =
      {
        main =
        {
          {
            picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete1-right.png",
            count = 16,
            size = 1
          },
          {
            picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete2-right.png",
            count = 4,
            size = 2,
            probability = 0.39,
          },
          {
            picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete4-right.png",
            count = 4,
            size = 4,
            probability = 1,
          },
        },
        inner_corner =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete-inner-corner-right.png",
          count = 32
        },
        outer_corner =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete-outer-corner-right.png",
          count = 16
        },
        side =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete-side-right.png",
          count = 16
        },
        u_transition =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete-u-right.png",
          count = 16
        },
        o_transition =
        {
          picture = "__base__/graphics/terrain/hazard-concrete-right/hazard-concrete-o-right.png",
          count = 1
        }
      },
      walking_sound =
      {
        {
          filename = "__base__/sound/walking/concrete-01.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-02.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-03.ogg",
          volume = 1.2
        },
        {
          filename = "__base__/sound/walking/concrete-04.ogg",
          volume = 1.2
        }
      },
      map_color={r=0.5, g=0.5, b=0},
      ageing=0,
      vehicle_friction_modifier = concrete_vehicle_speed_modifier
    }]]
  })