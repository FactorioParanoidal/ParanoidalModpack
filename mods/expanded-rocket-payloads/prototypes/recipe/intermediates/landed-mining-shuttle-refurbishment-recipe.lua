data:extend({
    {
        type = "recipe",
        name = "refurbish-mining-shuttle",
        energy_required = 2400,
        enabled = false,
        ingredients =
        {
          {type="fluid", name="water", amount=20000},
          {"landed-mining-shuttle", 1},
          {"rocket-fuel", 1000},
          {"stone-brick", 2000},
        },
        results=
        {
          {"copper-dropship", 7500},
          {"iron-dropship", 10000},
          {"mining-shuttle", 1},
        },
        icon = "__expanded-rocket-payloads__/graphic/landed-mining-shuttle-32.png",
        icon_size = 32,
        subgroup = "shuttle-processies",
        order = "b",
        category = "satellite-crafting",
    },
})