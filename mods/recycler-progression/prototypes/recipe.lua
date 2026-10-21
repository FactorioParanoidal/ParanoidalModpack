-- Paranoidal: each tier uses the materials of the matching assembling-machine tier and the
-- previous recycler. Defined in data.lua so Quality generates recycling recipes from these
-- ingredients in its data-updates.

data:extend({

  -- Recycler 1: available from the start (wind turbine + small pole power it).
  {
    type = "recipe",
    name = "recycler-1",
    enabled = true,
    energy_required = 3,
    ingredients = {
      {type = "item", name = "iron-plate",     amount = 20},
      {type = "item", name = "iron-gear-wheel", amount = 10},
      {type = "item", name = "electric-motor",  amount = 2},
      {type = "item", name = "stone-brick",     amount = 10},
    },
    results = {{type = "item", name = "recycler-1", amount = 1}},
  },

  -- Recycler 2: assembling-machine-2 tier.
  {
    type = "recipe",
    name = "recycler-2",
    enabled = false,
    energy_required = 3,
    ingredients = {
      {type = "item", name = "recycler-1",                 amount = 1},
      {type = "item", name = "steel-plate",                amount = 10},
      {type = "item", name = "electronic-circuit",         amount = 5},
      {type = "item", name = "electric-motor",             amount = 4},
      {type = "item", name = "basic-structure-components", amount = 1},
    },
    results = {{type = "item", name = "recycler-2", amount = 1}},
  },

  -- Recycler 3: assembling-machine-3 tier.
  {
    type = "recipe",
    name = "recycler-3",
    enabled = false,
    energy_required = 3,
    ingredients = {
      {type = "item", name = "recycler-2",                        amount = 1},
      {type = "item", name = "steel-plate",                       amount = 10},
      {type = "item", name = "advanced-circuit",                  amount = 4},
      {type = "item", name = "electric-engine-unit",              amount = 3},
      {type = "item", name = "intermediate-structure-components", amount = 1},
    },
    results = {{type = "item", name = "recycler-3", amount = 1}},
  },

})

-- Recycler 4 = vanilla recycler: requires Recycler 3, the rest is reduced from vanilla.
data.raw.recipe["recycler"].ingredients = {
  {type = "item", name = "recycler-3",      amount = 1},
  {type = "item", name = "processing-unit", amount = 4},
  {type = "item", name = "steel-plate",     amount = 10},
  {type = "item", name = "iron-gear-wheel", amount = 20},
  {type = "item", name = "concrete",        amount = 10},
}
