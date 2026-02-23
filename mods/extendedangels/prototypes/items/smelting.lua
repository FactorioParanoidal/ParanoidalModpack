data:extend({
  -- Tungsten trioxide
  {
    type = "item",
    name = "angels-solid-tungsten-trioxide",
    icon = "__angelssmeltinggraphics__/graphics/icons/solid-tungsten-oxide.png",
    icon_size = 32,
    subgroup = "angels-tungsten",
    order = "e",
    stack_size = 200,
  },

  -- Tungsten hexachloride
  {
    type = "fluid",
    name = "angels-gas-tungsten-hexachloride",
    icon = "__extendedangels__/graphics/icons/gas-tungsten-hexachloride.png",
    icon_size = 32,
    default_temperature = 0,
    heat_capacity = "0kJ",
    base_color = { r = 138 / 255, g = 20 / 255, b = 230 / 255 },
    flow_color = { r = 138 / 255, g = 20 / 255, b = 230 / 255 },
    max_temperature = 0,
  },

  -- Sodium tungstate
  {
    type = "item",
    name = "angels-solid-sodium-tungstate",
    icon = "__extendedangels__/graphics/icons/solid-sodium-tungstate.png",
    icon_size = 32,
    subgroup = "angels-tungsten",
    order = "f",
    stack_size = 200,
  },

  -- Titanium concrete brick
  {
    type = "item",
    name = "angels-titanium-concrete-brick",
    icon = "__extendedangels__/graphics/icons/brick-titanium.png",
    icon_size = 32,
    subgroup = "angels-stone-casting",
    order = "k",
    stack_size = 1000,
    place_as_tile = {
      result = "angels-tile-reinforced-concrete-brick",
      condition_size = 2,
      condition = { layers = { water_tile = true } },
    },
  },
})
if mods["bobplates"] then
data:extend({
    -- Tungsten carbide powder mixture
  {
    type = "item",
    name = "angels-powder-copper-tungsten",
    icon = "__extendedangels__/graphics/icons/powder-copper-tungsten.png",
    icon_size = 64,
    subgroup = "angels-tungsten-casting",
    order = "a",
    stack_size = 200,
  },

    -- Tungsten carbide powder mixture
  {
    type = "item",
    name = "angels-powder-tungsten-carbide",
    icon = "__extendedangels__/graphics/icons/powder-tungsten-carbide.png",
    icon_size = 64,
    subgroup = "angels-tungsten-carbide",
    order = "a",
    stack_size = 200,
  },

})
end