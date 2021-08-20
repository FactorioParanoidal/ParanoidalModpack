-- прямой паровой манипулятор
if bobmods.logistics then
  --существует модификация "Логистика Боба" - нужно обновить паровой манипулятор
  data.raw.inserter["steam-inserter"].icon = "__steam-inserter-patch__/graphics/icons/straight-steam-inserter.png"
  data.raw.inserter["steam-inserter"].energy_source.fluid_box.base_area = 0.1
  data.raw.inserter["steam-inserter"].energy_source.fluid_box.height = 0.2
  data.raw.inserter["steam-inserter"].energy_source.fluid_box.base_level = 0
  data.raw.inserter["steam-inserter"].light_flicker =
  {
    color = {0,0,0},
    minimum_intensity = 0,
    maximum_intensity = 0
  }
else
  --модификация "Логистика Боба" не существует - нужно создавать паровой манипулятор заново
data:extend({
util.merge{data.raw.inserter["inserter"],{
    name = "steam-inserter",
    icon = "__steam-inserter-patch__/graphics/icons/straight-steam-inserter.png",
    icon_size = 32,
    minable = {result = "steam-inserter"},
    max_health = 100,
    extension_speed = 0.125,
    rotation_speed = 0.05,
    energy_per_movement = "10KJ",
    energy_per_rotation = "10KJ",
    light_flicker = 
    {
      color = {0,0,0},
      minimum_intensity = 0,
      maximum_intensity = 0
    },
  }}
})
data.raw.inserter["steam-inserter"].icon_mipmaps = nil
data.raw.inserter["steam-inserter"].hand_base_picture = 
  {
    filename = "__steam-inserter-patch__/graphics/entity/inserter/white-inserter-hand-base.png",
    priority = "extra-high",
    width = 8,
    height = 34,
    hr_version = {
      filename = "__steam-inserter-patch__/graphics/entity/inserter/hr-white-inserter-hand-base.png",
      priority = "extra-high",
      width = 32,
      height = 136,
      scale = 0.25
    }
  }
data.raw.inserter["steam-inserter"].hand_closed_picture = 
  {
    filename = "__steam-inserter-patch__/graphics/entity/inserter/white-inserter-hand-closed.png",
    priority = "extra-high",
    width = 18,
    height = 41,
    hr_version = {
      filename = "__steam-inserter-patch__/graphics/entity/inserter/hr-white-inserter-hand-closed.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    }
  }
data.raw.inserter["steam-inserter"].hand_open_picture = 
  {
    filename = "__steam-inserter-patch__/graphics/entity/inserter/white-inserter-hand-open.png",
    priority = "extra-high",
    width = 18,
    height = 41,
    hr_version = {
      filename = "__steam-inserter-patch__/graphics/entity/inserter/hr-white-inserter-hand-open.png",
      priority = "extra-high",
      width = 72,
      height = 164,
      scale = 0.25
    }
  }
data.raw.inserter["steam-inserter"].platform_picture = 
  {
    sheet=
    {
      filename = "__steam-inserter-patch__/graphics/entity/inserter/white-inserter-platform.png",
      priority = "extra-high",
      width = 46,
      height = 46,
      shift = {0.09375, 0},
      hr_version = {
        filename = "__steam-inserter-patch__/graphics/entity/inserter/hr-white-inserter-platform.png",
        priority = "extra-high",
        width = 105,
        height = 79,
        shift = util.by_pixel(1.5, 7.5-1),
        scale = 0.5
      }
    }
  }
data.raw.inserter["steam-inserter"].energy_source =
{
  type = "fluid",
  effectivity = 1,
  fluid_box =
  {
    base_area = 0.1,
    height = 0.2,
    base_level = 0,
    pipe_connections =
    {
      {type = "input-output", position = {1, 0}},
      {type = "input-output", position = {-1, 0}}
    },
    pipe_covers = pipecoverspictures(),
    pipe_picture = assembler3pipepictures(),
    production_type = "input-output",
    filter = "steam"
  },
  burns_fluid = false,
  scale_fluid_usage = false,
  fluid_usage_per_tick = (0.7/60),
  maximum_temperature = 765,
  smoke =
  {
    {
      name = "light-smoke",
      frequency = 10 / 32,
      starting_vertical_speed = 0.08,
      slow_down_factor = 1,
      starting_frame_deviation = 60
    }
  }
}
end

-- угловой паровой манипулятор
data:extend({
util.merge{data.raw.inserter["steam-inserter"],{
    name = "corner-steam-inserter",
    icon = "__steam-inserter-patch__/graphics/icons/corner-steam-inserter.png",
    minable = {result = "corner-steam-inserter"},
  }}
})
data.raw.inserter["corner-steam-inserter"].energy_source.fluid_box.pipe_connections =
{
  {type = "input-output", position = {-1, 0}},
  {type = "input-output", position = {0, 1}}
}
