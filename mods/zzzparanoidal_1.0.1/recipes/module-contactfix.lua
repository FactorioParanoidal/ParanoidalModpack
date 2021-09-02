data:extend({ 

{
    type = "recipe",
    name = "module-contact",
    normal =
    {
      energy_required = 5,
      enabled = false,
      ingredients =
      {
        {"silver-plate", 1},
        {"gold-plate", 1},
      },
      result = "module-contact",
      result_count = 3,
    },
    expensive =
    {
      energy_required = 6,
      enabled = false,
      ingredients =
      {
        {"silver-plate", 1},
        {"gold-plate", 1},
      },
      result = "module-contact",
      result_count = 2,
    },
  },
})

--[[
OV.patch_recipes(      {        {
          name = "module-contact",
          ingredients = {            {"!!"},
            {name = "copper-plate", amount = 1},
            {name = "silver-plate", amount = 1},          }        },
]]--