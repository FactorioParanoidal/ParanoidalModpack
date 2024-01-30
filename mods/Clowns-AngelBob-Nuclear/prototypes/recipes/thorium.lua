if data.raw.item["thorium-fuel-cell"] then
  data:extend(
  { --basic thorium processing
    {
      type = "recipe",
      name = "thorium-processing",
      energy_required = 10,
      enabled = false,
      category = "centrifuging",
      ingredients = {{"thorium-ore", 10}},
      icon = "__Clowns-Nuclear__/graphics/icons/thorium-processing.png",
      icon_size = 32,
      crafting_machine_tint =
      {
        primary = {r = 1, g = 1, b = 0}, -- thorium
        secondary = {r = 1, g = 1, b = 0}, -- thorium
        tertiary = {r = 1, g = 1, b = 0}, -- thorium
      },
      subgroup = "clowns-nuclear-cells",
      order = "z",
      results =
      {
        {type="item", name="thorium-232", amount=1},
      }
    },
    { --thorium fuel cells
      type = "recipe",
      name = "thorium-mixed-oxide",
      energy_required = 50,
      enabled = false,
      ingredients =
      {
        {type="item", name="iron-plate", amount=2},
        {type="item", name="plutonium-239", amount=2},
        {type="item", name="thorium-232", amount=2}
      },
      icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-mixed-oxide.png",
      icon_size = 32,
      subgroup = "clowns-nuclear-cells",
      order = "d-b",
      results =
      {
        {
          name = "thorium-fuel-cell",
          amount = 2
        },
      },
      allow_decomposition = false
    },
    {
      type = "recipe",
      name = "thorium-fuel-cell",
      energy_required = 10,
      enabled = false,
      ingredients =
      {
        {"iron-plate", 10},
        {"55%-uranium", 1},
        {"thorium-232", 19},
      },
      result = "thorium-fuel-cell",
      result_count = 10,
    },
    --thorium from ore
    {
      type = "recipe",
      name = "thorium-ore-processing",
      category = "ore-refining-t3-5",
      energy_required = 30,
      enabled = false,
      ingredients = {
        {"thorium-ore",10},
        {type="fluid",name="liquid-hydrofluoric-acid",amount=100}
      },
      results = {
        {type="fluid",name="thorium-solution",amount=13},
        {type="fluid",name="steam", amount=90, temperature=650},
        {"slag",2}
      },
      main_product = "thorium-solution",
    },
    {
      type = "recipe",
      name = "thorium-crystallisation",
      energy_required = 60,
      category = "chemistry",
      enabled = false,
      ingredients = {
        {type="fluid",name="thorium-solution",amount=26},
        {type="fluid",name="water-purified",amount=180}
      },
      results = {
        {"thorium-salt",20},
        {type="fluid",name="water-greenyellow-waste", amount=200},
      },
      main_product="thorium-salt",
    },
    {
      type = "recipe",
      name = "thorium-purification",
      energy_required = 18,
      category = "washing-plant",
      enabled = false,
      ingredients = {
        {"thorium-salt",13},
        {type="fluid",name="liquid-naphtha",amount=200}
      },
      results = {
        {"thorium-232",9},
        {type="fluid",name="liquid-naphtha",amount=200},
        {"slag",4}
      },
      main_product = "thorium-232",
    }
  }
  )
end