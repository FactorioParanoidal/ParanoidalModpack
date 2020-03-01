wood = "wood"
if mods["omnimatter_wood"] then
    wood = "omniwood"
end
data:extend({
  {
    type = "recipe",
    name = "JunkTrain",
	energy_required = 10,
    enabled = false,
    ingredients =
    {
      {"stone-furnace", 1},
      {"iron-gear-wheel", 10},
      {"pipe", 20}
    },
    result = "JunkTrain"
  },
  {
    type = "recipe",
    name = "ScrapTrailer",
	energy_required = 10,
    enabled = false,
    ingredients =
    {
      {wood, 20},
      {"iron-gear-wheel", 5},
      {"iron-chest", 1}
    },
    result = "ScrapTrailer"
  },
  {
    type = "recipe",
    name = "train-stop-scrap",
    enabled = false,
    ingredients =
    {
      {"iron-plate",4},
      {"small-lamp",2},
      {"copper-cable", 6},
      {wood, 10}
    },
    result = "train-stop-scrap"
  },
  {
    type = "recipe",
    name = "rail-signal-scrap",
    enabled = false,
    ingredients =
    {
      {"iron-stick",1},
      {"small-lamp",2},
      {"copper-cable", 6},
      {wood, 4}
    },
    result = "rail-signal-scrap"
  },
  {
    type = "recipe",
    name = "rail-chain-signal-scrap",
    enabled = false,
    ingredients =
    {
      {"iron-stick",1},
      {"small-lamp",2},
      {"copper-cable", 12},
      {wood, 4}
    },
    result = "rail-chain-signal-scrap"
  },
  {
    type = "recipe",
    name = "scrap-rail",
    energy_required = 1,
    enabled = false,
    ingredients =
    {
      {"stone", 1},
      {"iron-stick", 1},
      {wood, 1}
    },
    result = "scrap-rail",
    result_count = 2,
    requester_paste_multiplier = 4
  }
})