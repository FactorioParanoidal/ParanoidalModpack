-- Final normal-mode Beta 8 costs; only the Bob 2.0 item IDs are remapped.
data:extend({
  {
    type = "recipe",
    name = "subterranean-belt",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "iron-plate", amount = 200},
      {type = "item", name = "transport-belt", amount = 250},
    },
    results = {{type = "item", name = "subterranean-belt", amount = 2}},
    requester_paste_multiplier = 4,
  },
  {
    type = "recipe",
    name = "fast-subterranean-belt",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "bob-steel-gear-wheel", amount = 100},
      {type = "item", name = "fast-transport-belt", amount = 250},
      {type = "item", name = "subterranean-belt", amount = 2},
    },
    results = {{type = "item", name = "fast-subterranean-belt", amount = 2}},
    requester_paste_multiplier = 4,
  },
  {
    type = "recipe",
    name = "express-subterranean-belt",
    category = "crafting-with-fluid",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "bob-titanium-gear-wheel", amount = 100},
      {type = "item", name = "express-transport-belt", amount = 250},
      {type = "item", name = "fast-subterranean-belt", amount = 2},
      {type = "fluid", name = "lubricant", amount = 400},
    },
    results = {{type = "item", name = "express-subterranean-belt", amount = 2}},
  },
  {
    type = "recipe",
    name = "subterranean-pipe",
    enabled = false,
    energy_required = 10,
    ingredients = {
      {type = "item", name = "bob-steel-pipe", amount = 250},
      {type = "item", name = "steel-plate", amount = 200},
    },
    results = {{type = "item", name = "subterranean-pipe", amount = 2}},
    requester_paste_multiplier = 4,
  },
})
