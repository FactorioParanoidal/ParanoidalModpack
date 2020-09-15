--Nuclear Furnace
local nuclear_furnace = table.deepcopy(data.raw.furnace["electric-furnace"])
local furnace_internal = table.deepcopy(data.raw.boiler["heat-exchanger"])
nuclear_furnace.name = "nuclear-furnace"
nuclear_furnace.energy_source = furnace_internal.energy_source
nuclear_furnace.max_health = 500
nuclear_furnace.energy_usage = "360kW"
nuclear_furnace.minable = {mining_time = 1, result = "nuclear-furnace"}
nuclear_furnace.target_temperature = 600
nuclear_furnace.crafting_categories = {"nuclear-smelting"}
nuclear_furnace.tint = {r = 0.0, g = 0.0, b = 1, a = 0.5}
nuclear_furnace.energy_source.connections =
    {
        {
          position = {0, -1},
          direction = defines.direction.north
        },
        {
          position = {0, 1},
          direction = defines.direction.south
        }
    }
nuclear_furnace.animation =
    {
      layers =
      {
        {
          filename = "__OberNuclear__/graphics/nuclear-furnace-base.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          hr_version =
          {
            filename = "__OberNuclear__/graphics/hr-nuclear-furnace.png",
            priority = "high",
            width = 239,
            height = 219,
            frame_count = 1,
            shift = util.by_pixel(0.75, 5.75),
            scale = 0.5
          }
        },
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-shadow.png",
          priority = "high",
          width = 129,
          height = 100,
          frame_count = 1,
          shift = {0.421875, 0},
          draw_as_shadow = true,
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-shadow.png",
            priority = "high",
            width = 227,
            height = 171,
            frame_count = 1,
            draw_as_shadow = true,
            shift = util.by_pixel(11.25, 7.75),
            scale = 0.5
          }
        }
      }
    }
nuclear_furnace.working_visualisations =
    {
      {
        animation =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-heater.png",
          priority = "high",
          width = 25,
          height = 15,
          frame_count = 12,
          animation_speed = 0.5,
          shift = {0.015625, 0.890625},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-heater.png",
            priority = "high",
            width = 60,
            height = 56,
            frame_count = 12,
            animation_speed = 0.5,
            shift = util.by_pixel(1.75, 32.75),
            scale = 0.5
          }
        },
        light = {intensity = 0.4, size = 6, shift = {0.0, 1.0}, color = {r = 1.0, g = 1.0, b = 1.0}}
      },
      {
        animation =
        {
          filename = "__OberNuclear__/graphics/nuclear-furnace-glow-1.png",
          priority = "high",
          width = 19,
          height = 13,
          frame_count = 7,
          animation_speed = 0.2,
          shift = {-0.671875, -0.640625},
          hr_version =
          {
            filename = "__OberNuclear__/graphics/hr-nuclear-furnace-glow-1.png",
            priority = "high",
            width = 37,
            height = 25,
            frame_count = 7,
            animation_speed = 0.2,
            shift = util.by_pixel(-20.5, -18.5),
            scale = 0.5
          },
        }
      },
      {
        animation =
        {
          filename = "__base__/graphics/entity/electric-furnace/electric-furnace-propeller-2.png",
          priority = "high",
          width = 12,
          height = 9,
          frame_count = 4,
          animation_speed = 0.5,
          shift = {0.0625, -1.234375},
          hr_version =
          {
            filename = "__base__/graphics/entity/electric-furnace/hr-electric-furnace-propeller-2.png",
            priority = "high",
            width = 23,
            height = 15,
            frame_count = 4,
            animation_speed = 0.5,
            shift = util.by_pixel(3.5, -38),
            scale = 0.5
          }
        }
      }
    }
data:extend({
    {
        type = "recipe-category",
        name = "nuclear-smelting",
    },
    nuclear_furnace,
    {
        type = "item",
        name = "nuclear-furnace",
        icon = "__OberNuclear__/graphics/nuclear-furnace.png",
        icon_size = 32,
        subgroup = "smelting-machine",
        order = "c[nuclear-furnace]",
        place_result = "nuclear-furnace",
        stack_size = 50
    },
    {
        type = "recipe",
        name = "ober-nuclear-furnace",
        ingredients = {
            {"electric-furnace",1},
            {"processing-unit",10},
            {"refined-concrete",20},
        },
        subgroup = "smelting-machine",
        order = "d[nuclear-furnace]",
        result = "nuclear-furnace",
        energy_required = 10,
        enabled = false,
    },
})