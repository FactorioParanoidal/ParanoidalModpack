data:extend(
{
    {
    type = "fluid",
    name = "liquid-molten-copper-tungsten",
    icon = "__extendedangels__/graphics/icons/molten-copper-tungsten.png",
	icon_size = 32,
	default_temperature = 100,
    heat_capacity = "0KJ",
    base_color = {r = 152/255, g = 74/255, b = 58/255},
    flow_color = {r = 152/255, g = 74/255, b = 58/255},
    max_temperature = 100,
	pressure_to_speed_ratio = 0.4,
    flow_to_energy_ratio = 0.59,
	auto_barrel = false
    },

    {
      type = "item",
      name = "solid-tungsten-trioxide",
      icon = "__angelssmelting__/graphics/icons/solid-tungsten-oxide.png",
    icon_size = 32,
      subgroup = "angels-tungsten",
      order = "e",
      stack_size = 200
    },

    {
        type = "fluid",
        name = "gas-tungsten-hexachloride",
        icon = "__extendedangels__/graphics/icons/gas-tungsten-hexachloride.png",
        icon_size = 32,
        default_temperature = 100,
        heat_capacity = "0KJ",
        base_color = {r = 138/255, g = 20/255, b = 230/255},
        flow_color = {r = 138/255, g = 20/255, b = 230/255},
        max_temperature = 100,
        pressure_to_speed_ratio = 0.4,
        flow_to_energy_ratio = 0.59,
      },

      {
        type = "item",
        name = "solid-sodium-tungstate",
        icon = "__extendedangels__/graphics/icons/solid-sodium-tungstate.png",
        icon_size = 32,
        subgroup = "angels-tungsten",
        order = "f",
        stack_size = 200
      },


      {
        type = "item",
        name = "powder-zinc",
        icon = "__angelssmelting__/graphics/icons/powder-zinc.png",
        icon_size = 32,
        subgroup = "angels-zinc",
        order = "i",
        stack_size = 200
      },

      {
        type = "item",
        name = "powder-tungsten-carbide",
        icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
        icon_size = 32,
        subgroup = "angels-tungsten-carbide",
        order = "a",
        stack_size = 200
      },

    {
        type = "item",
        name = "titanium-concrete-brick",
        icon = "__extendedangels__/graphics/icons/brick-titanium.png",
        icon_size = 32,
        subgroup = "angels-stone",
        order = "i",
        stack_size = 1000,
        place_as_tile =
        {
          result = "concrete",
          condition_size = 4,
          condition = { "water-tile" }
        }
      },

}
)
