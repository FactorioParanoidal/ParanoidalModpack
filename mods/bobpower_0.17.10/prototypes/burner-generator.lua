if settings.startup["bobmods-power-burnergenerator"].value == true then

function bobmods.power.burner_generator_structure()
  return {
    filename = "__bobpower__/graphics/burner-generator/burner-generator.png",
    priority = "extra-high",
    width = 180,
    height = 190,
    frame_count = 1,
    shift = util.by_pixel(40, 12),
  }
end


data:extend(
{
  {
    type = "item",
    name = "burner-generator",
    icon = "__bobpower__/graphics/icons/burner-generator.png",
    icon_size = 64,
    subgroup = "bob-energy-fluid-generator",
    order = "burner-generator",
    place_result = "burner-generator",
    stack_size = 10,
  },
  {
    type = "recipe",
    name = "burner-generator",
    normal =
    {
      ingredients =
      {
        {"stone-furnace", 1},
        {"iron-plate", 8},
        {"iron-gear-wheel", 5},
      },
      result = "burner-generator"
    },
    expensive =
    {
      ingredients =
      {
        {"stone-furnace", 1},
        {"iron-plate", 15},
        {"iron-gear-wheel", 10},
      },
      result = "burner-generator"
    }
  },
  {
    type = "generator",
    name = "burner-generator",
    icon = "__bobpower__/graphics/icons/burner-generator.png",
    icon_size = 64,
    flags = {"placeable-neutral","player-creation"},
    minable = {mining_time = 0.5, result = "burner-generator"},
    max_health = 200,
    corpse = "big-remnants",
    dying_explosion = "medium-explosion",
    effectivity = 0.75,
    max_power_output = "400kW",
    resistances =
    {
      {
        type = "fire",
        percent = 70
      },
      {
        type = "impact",
        percent = 30
      }
    },
    fast_replaceable_group = "burner-generator",
    collision_box = {{-1.35, -1.35}, {1.35, 1.35}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-output",
      emissions_per_minute = 8,
    },
    burner =
    {
      fuel_category = "chemical",
      effectivity = 0.75,
      fuel_inventory_size = 1,
      emissions_per_minute = 15,
    },
    horizontal_animation = bobmods.power.burner_generator_structure(),
    vertical_animation = bobmods.power.burner_generator_structure(),
    smoke =
    {
      {
        name = "smoke",
        position = util.by_pixel(0, -50),
        frequency = 0.5,
        starting_vertical_speed = 0.0,
        starting_frame_deviation = 60
      },
    },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/steam-engine-90bpm.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    min_perceived_performance = 0.25,
    performance_to_sound_speedup = 0.5
  },
}
)

end
