data:extend({
  -- Sodium fluoride
  {
    type = "item",
    name = "angels-solid-sodium-fluoride",
    icon = "__extendedangels__/graphics/icons/solid-sodium-fluoride.png",
    icon_size = 32,
    subgroup = "angels-petrochem-sodium",
    order = "j",
    stack_size = 200,
  },

  -- Argon
  {
    type = "fluid",
    name = "angels-gas-argon",
    icons = { { icon = "__extendedangels__/graphics/icons/gas-argon.png", icon_size = 32 } },
    default_temperature = 0,
    heat_capacity = "0kJ",
    base_color = { r = 0 / 255, g = 0 / 255, b = 0 / 255 },
    flow_color = { r = 30 / 255, g = 143 / 255, b = 216 / 255 },
    max_temperature = 0,
  },
})

if mods["Clowns-Processing"] then
  data:extend({
    -- Disodium phosphate
    {
      type = "item",
      name = "angels-solid-disodium-phosphate",
      icons = {
        {
          icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
          icon_size = 32,
        },
      },
      subgroup = "angels-petrochem-sodium",
      order = "k",
      stack_size = 200,
    },

    -- Tetrasodium pyrophosphate
    {
      type = "item",
      name = "angels-solid-tetrasodium-pyrophosphate",
      icons = { {
        icon = "__Clowns-Processing__/graphics/icons/solid-white-phosphorus.png",
        icon_size = 32,
      } },
      subgroup = "angels-petrochem-sodium",
      order = "l",
      stack_size = 200,
    },
  })
end
