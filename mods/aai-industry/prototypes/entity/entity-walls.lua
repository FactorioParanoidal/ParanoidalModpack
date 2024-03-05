local util = require("data-util")

util.replace_filenames_recursive(data.raw.wall["stone-wall"].pictures, "__base__", "__aai-industry__")
data.raw.wall["stone-wall"].max_health = 350

local concrete = table.deepcopy(data.raw.wall["stone-wall"])
concrete.name = "concrete-wall"
concrete.minable.result = "concrete-wall"
util.replace_filenames_recursive(concrete.pictures, "stone-wall", "concrete-wall")
concrete.max_health = 1000
data:extend({concrete})

local steel = table.deepcopy(data.raw.wall["concrete-wall"])
steel.name = "steel-wall"
steel.minable.result = "steel-wall"
util.replace_filenames_recursive(steel.pictures, "concrete-wall", "steel-wall")
steel.max_health = 1200

-- this kind of code can be used for having walls mirror the effect
-- there can be multiple reaction items
steel.attack_reaction =
{
  {
    ---- how far the mirroring works
    range = 2,
    ---- what kind of damage triggers the mirroring
    ---- if not present then anything triggers the mirroring
    damage_type = "physical",
    ---- caused damage will be multiplied by this and added to the subsequent damages
    reaction_modifier = 0.1,
    action =
    {
      type = "direct",
      action_delivery =
      {
        type = "instant",
        target_effects =
        {
          type = "damage",
          ---- always use at least 0.1 damage
          damage = {amount = 0.1, type = "physical"}
        }
      }
    },
  }
}
steel.pictures =
{
  single =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-single.png",
        priority = "extra-high",
        width = 36,--22,
        height = 47,--42,
        shift = {0, -0.15625 -5/64},
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-single-shadow.png",
        priority = "extra-high",
        width = 47,
        height = 32,
        shift = {0.359375, 0.5},
        draw_as_shadow = true
      }
    }
  },
  straight_vertical =
  {
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-1.png",
          priority = "extra-high",
          width = 37,--22,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-shadow.png",
          priority = "extra-high",
          width = 47,
          height = 60,
          shift = {0.390625, 0.625},
          draw_as_shadow = true
        }
      }
    },
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-2.png",
          priority = "extra-high",
          width = 37,--22,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-shadow.png",
          priority = "extra-high",
          width = 47,
          height = 60,
          shift = {0.390625, 0.625},
          draw_as_shadow = true
        }
      }
    },
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-3.png",
          priority = "extra-high",
          width = 37,--22,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-vertical-shadow.png",
          priority = "extra-high",
          width = 47,
          height = 60,
          shift = {0.390625, 0.625},
          draw_as_shadow = true
        }
      }
    }
  },
  straight_horizontal =
  {
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-1.png",
          priority = "extra-high",
          width = 32,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-shadow.png",
          priority = "extra-high",
          width = 59,
          height = 32,
          shift = {0.421875, 0.5},
          draw_as_shadow = true
        }
      }
    },
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-2.png",
          priority = "extra-high",
          width = 32,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-shadow.png",
          priority = "extra-high",
          width = 59,
          height = 32,
          shift = {0.421875, 0.5},
          draw_as_shadow = true
        }
      }
    },
    {
      layers =
      {
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-3.png",
          priority = "extra-high",
          width = 32,
          height = 47,--42,
          shift = {0, -0.15625 -5/64}
        },
        {
          filename = "__aai-industry__/graphics/entity/steel-wall/wall-straight-horizontal-shadow.png",
          priority = "extra-high",
          width = 59,
          height = 32,
          shift = {0.421875, 0.5},
          draw_as_shadow = true
        }
      }
    }
  },
  corner_right_down =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-corner-right-down.png",
        priority = "extra-high",
        width = 36, --27,
        height = 48, --42,
        shift = {0.078125 -5/64, -0.15625 -6/64}
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-corner-right-down-shadow.png",
        priority = "extra-high",
        width = 53,
        height = 61,
        shift = {0.484375, 0.640625},
        draw_as_shadow = true
      }
    }
  },
  corner_left_down =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-corner-left-down.png",
        priority = "extra-high",
        width = 36, --27,
        height = 46, --42,
        shift = {-0.078125 +7/64, -0.15625 -4/64}
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-corner-left-down-shadow.png",
        priority = "extra-high",
        width = 53,
        height = 60,
        shift = {0.328125, 0.640625},
        draw_as_shadow = true
      }
    }
  },
  t_up =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-t-down.png",
        priority = "extra-high",
        width = 32,
        height = 47, --42,
        shift = {0, -0.15625 -5/64}
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-t-down-shadow.png",
        priority = "extra-high",
        width = 71,
        height = 61,
        shift = {0.546875, 0.640625},
        draw_as_shadow = true
      }
    }
  },
  ending_right =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-ending-right.png",
        priority = "extra-high",
        width = 37, --27,
        height = 47, --42,
        shift = {0.078125 -4/64, -0.15625 -5/64}
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-ending-right-shadow.png",
        priority = "extra-high",
        width = 53,
        height = 32,
        shift = {0.484375, 0.5},
        draw_as_shadow = true
      }
    }
  },
  ending_left =
  {
    layers =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-ending-left.png",
        priority = "extra-high",
        width = 36, --27,
        height = 47, --42,
        shift = {-0.078125 +7/64, -0.15625 -5/64}
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-ending-left-shadow.png",
        priority = "extra-high",
        width = 53,
        height = 32,
        shift = {0.328125, 0.5},
        draw_as_shadow = true
      }
    }
  },
  water_connection_patch =
  {
    sheets =
    {
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-patch.png",
        priority = "extra-high",
        width = 52,
        height = 68,
        shift = {0/32, -2/32},
      },
      {
        filename = "__aai-industry__/graphics/entity/steel-wall/wall-patch-shadow.png",
        priority = "extra-high",
        draw_as_shadow = true,
        width = 74,
        height = 96,
        shift =  {6/32, 13/32},
      }
    }
  }
}
steel.mined_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 }
steel.vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 1.0 }
data:extend({steel})
