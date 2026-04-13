  data:extend(
  { --basic thorium processing
    {
      type = "recipe",
      name = "thorium-processing",
      energy_required = 10,
      enabled = false,
      category = "centrifuging",
      ingredients = {
        {type="item",name="angels-thorium-ore", amount=10}
      },
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
        {type="item", name="angels-thorium-232", amount=1},
      }
    },
    { --thorium fuel cells
      type = "recipe",
      name = "clowns-thorium-mixed-oxide",
      energy_required = 50,
      enabled = false,
      ingredients =
      {
        {type="item", name="angels-plate-lead", amount=2},
        {type="item", name="angels-plutonium-239", amount=2},
        {type="item", name="angels-thorium-232", amount=2}
      },
      icon = "__Clowns-Nuclear__/graphics/icons/thorium-nuclear-fuel-mixed-oxide.png",
      icon_size = 32,
      subgroup = "clowns-nuclear-cells",
      order = "d-b",
      results =
      {
        { type= "item", name = "angels-thorium-fuel-cell", amount = 2},
      },
      allow_decomposition = false
    },
    {
      type = "recipe",
      name = "clowns-thorium-fuel-cell",
      energy_required = 10,
      enabled = false,
      ingredients =
      {
        {type="item", name="angels-plate-lead", amount= 10},
        {type="item", name="55pc-uranium", amount= 1},
        {type="item", name="angels-thorium-232", amount= 19},
      },
      results = {
        {type= "item", name= "angels-thorium-fuel-cell", amount = 10}
      },
    },
    --thorium from ore
    {
      type = "recipe",
      name = "clowns-thorium-ore-processing",
      category = "angels-ore-refining-t3-5",
      energy_required = 30,
      enabled = false,
      ingredients = {
        {type="item", name="angels-thorium-ore", amount=10},
        {type="fluid",name="angels-liquid-hydrofluoric-acid",amount=100}
      },
      results = {
        {type="fluid",name="clowns-liquid-thorium-solution",amount=13},
        {type="fluid",name="steam", amount=90, temperature=650},
        {type="item", name="angels-slag",amount=2}
      },
      main_product = "clowns-liquid-thorium-solution",
    },
    {
      type = "recipe",
      name = "thorium-crystallisation",
      energy_required = 60,
      category = "chemistry",
      enabled = false,
      ingredients = {
        {type="fluid",name="clowns-liquid-thorium-solution",amount=26},
        {type="fluid",name="angels-water-purified",amount=180}
      },
      results = {
        {type="item", name="clowns-solid-thorium-salt",amount=20},
        {type="fluid",name="angels-water-greenyellow-waste", amount=200},
      },
      main_product="clowns-solid-thorium-salt",
    },
    {
      type = "recipe",
      name = "clowns-thorium-purification",
      energy_required = 18,
      category = "angels-washing-plant",
      enabled = false,
      ingredients = {
        {type="item", name="clowns-solid-thorium-salt",amount=13},
        {type="fluid",name="angels-liquid-naphtha",amount=200}
      },
      results = {
        {type="item", name="angels-thorium-232",amount=9},
        {type="fluid",name="angels-liquid-naphtha",amount=200},
        {type="item", name="angels-slag",amount=4}
      },
      main_product = "angels-thorium-232",
    }
  }
  )