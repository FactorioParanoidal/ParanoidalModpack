data:extend({
  {
    type = "recipe",
    name = "probe-data-processing",
    enabled = false,
    icon = "__expanded-rocket-payloads-continued__/graphic/pluto-heart-32.png",
    icon_size = 32,
    auto_recycle = false,
    ingredients =
    {
      { type = "item", name = "probe-data", amount = 1 },
    },
    results = { { type = "item", name = "space-science-pack", amount = 2000 } },
    energy_required = 120,
    category = "satellite-crafting",
    subgroup = "satellite-data",
  },
})
