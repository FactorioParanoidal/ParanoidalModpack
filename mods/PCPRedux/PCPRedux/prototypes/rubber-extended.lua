local function create_icon(name, number_icon_layer)
  return angelsmods.functions.add_icon_layer(angelsmods.functions.get_object_icons(name), number_icon_layer)
end

--[[Rubber Additions]] --
--[[
==--Hexadragon's Suggestions:--==
Aside from styrene-butadiene rubbers, there are also butyl rubbers, which the production chain could go
==Butyl Rubber==
butane --(isomerization)
--> isobutane --(dehydrogenation)
--> isobutylene --(polymerization)
--> polyisobutylene + small amount of isoprene--(could be raw bio rubber or get it from cracking naphtha like butadiene)
--> rubber

--[[AB rubber options:
Angels styrene-butadiene (20 Styrene+20 butadiene-->10 liq rubber) (40 liq rubber-->4 rubber)
Angels Biorubber (5 sand+2 Des Tree Seed+1 Fert+50 saline-->3 tree+4 raw biorubber )(1 raw biorubber+20 acetone-->5 liq rubber)
Bobs resin cooking (1 resin-->1 rubber)[Allows Prod]
]] --
--NERF THE HELL OUT OF BOBS METHOD-- may change this with the addition of liquid rubber post processing
if mods.bobplates or mods.apm_resource_pack_ldinc and (data.raw.item["angels-solid-rubber"] or data.raw.item["bob-rubber"]) then
  if data.raw.recipe["bob-rubber"] and type(data.raw.recipe["bob-rubber"].ingredients) == "table" then
    data.raw.recipe["bob-rubber"].ingredients = { { type = "item", name = "bob-resin", amount = 5 } }  --25
  end
  if data.raw.recipe["bob-resin-wood"] and type(data.raw.recipe["bob-resin-wood"].ingredients) == "table" then
    data.raw.recipe["bob-resin-wood"].ingredients = { { type = "item", name = "wood", amount = 5 } }  --8
  end
  --Boost Angels method(s)--
  if data.raw.recipe["liquid-rubber-1"] then
    data.raw.recipe["liquid-rubber-1"].results = { { type = "fluid", name = "liquid-rubber", amount = 40 } }
    if data.raw.item["angels-solid-rubber"] and data.raw.item["bob-rubber"] then
      data.raw.recipe["angels-solid-rubber"].results = { { type = "item", name = "bob-rubber", amount = 8 } }
    else
      data.raw.recipe["angels-solid-rubber"].results = { { type = "item", name = "angels-solid-rubber", amount = 8 } }
    end
  end
  --Boost Angels method(s)--

  -- New Rubber Recipe that uses: 175 ethylene and 75 Butane--
  -- 8/6*175 ethylene
  -- 8/6*75 benzene
  -- 2 1/3 ethy to benz (7 ethylene per 3 benzene)


  --[[
==Chloroprene from Butane Path==
add recipes for butate->butadiene (butane+GMC+steam=butadiene+H2+frame)
Two step chlorination
add chlorination butadiene +  Cl2 --> dichlorobutene mixture (butadiene+chlorine->DCB)
add dehydrochlorination DCB+NaOH--> chlorobutadiene + saline
add chlorobutadiene polymerisation chlorobutadiene-->liquid rubber]]
  data:extend({
    {
      type = "recipe",
      name = "catalyst-steam-cracking-butane-2",
      category = "angels-steam-cracking",
      subgroup = "angels-petrochem-cracking",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "angels-gas-butane",           amount = 60 },
        { type = "fluid", name = "steam",                       amount = 120 },
        { type = "item",  name = "angels-catalyst-metal-green", amount = 1 }, --Ag
      },
      results =
      {
        { type = "fluid", name = "angels-gas-butadiene",          amount = 70 },
        { type = "fluid", name = "angels-gas-residual",           amount = 10 },
        { type = "item",  name = "angels-catalyst-metal-carrier", amount = 1 },
      },
      icons = angelsmods.functions.create_gas_recipe_icon(
        { { "__angelspetrochemgraphics__/graphics/icons/molecules/butadiene.png", 72 } }, "CHSg"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-gas-butadiene"),
      order = "d[catalyst-steam-cracking-butane-2]",
    },
    {
      type = "recipe",
      name = "butadiene-chlorination",
      category = "chemistry",
      subgroup = "angels-petrochem-chlorine-2",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "angels-gas-butadiene", amount = 60 },
        { type = "fluid", name = "angels-gas-chlorine",  amount = 60 },
      },
      results =
      {
        { type = "fluid", name = "liquid-dichlorobutene", amount = 120 },
      },
      icons = angelsmods.functions.create_liquid_recipe_icon(
        { { icon = "__PCPRedux__/graphics/icons/raw/dichlorobutene.png", icon_size = 72 } }, "CClH"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-dichlorobutene"),
      order = "d[butadiene-chlorination]",
    },
    {
      type = "recipe",
      name = "dichlorobutene-dechlorination",
      category = "chemistry",
      subgroup = "angels-petrochem-chlorine-2",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-dichlorobutene",         amount = 100 },
        { type = "item",  name = "angels-solid-sodium-hydroxide", amount = 1 },
      },
      results =
      {
        { type = "fluid", name = "liquid-chlorobutadiene", amount = 100 },
        { type = "fluid", name = "angels-water-saline",    amount = 100 },
      },
      icons = angelsmods.functions.create_liquid_recipe_icon(
        { { icon = "__PCPRedux__/graphics/icons/raw/chloroprene.png", icon_size = 72 } }, "CClH"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-chlorobutadiene"),
      order = "d[dichlorbutene-dechlorination]",
    },
    {
      type = "recipe",
      name = "liquid-rubber-2",
      category = "chemistry",
      subgroup = "angels-petrochem-solids-2",
      energy_required = 2,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-chlorobutadiene", amount = 100 },
      },
      results =
      {
        { type = "fluid", name = "angels-liquid-rubber", amount = 100 },
      },
      icons = create_icon("angels-liquid-rubber", {
        icon = "__angelsrefininggraphics__/graphics/icons/num_2.png",
        icon_size = 32,
        tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
        scale = 0.32,
        shift = { -12, -12 },
      }),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-rubber"),
      order = "b[rubber]-a[liquid]-a",
    },
  }) --[[
  ==Chloroprene from Acetylene Path==
  add acetylene ethylene + RMC --> acetlyene + H2 (dehydrogenation)
  add acetylene diomerisation 2 acetylene -->vinyl acetylene (VAC)
  add vinyl acetlyene chlorination VAC+HCl-->chlorobutadiene]]
  data:extend({
    {
      type = "recipe",
      name = "catalyst-steam-cracking-acetylene",
      category = "angels-steam-cracking",
      subgroup = "angels-petrochem-cracking",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "angels-gas-ethylene",       amount = 60 },
        { type = "fluid", name = "steam",                     amount = 120 },
        { type = "item",  name = "angels-catalyst-metal-red", amount = 1 }, --cu
      },
      results =
      {
        { type = "fluid", name = "gas-acetylene",                 amount = 70 },
        { type = "fluid", name = "angels-gas-residual",           amount = 10 },
        { type = "item",  name = "angels-catalyst-metal-carrier", amount = 1 },
      },
      icons = angelsmods.functions.create_gas_recipe_icon(
        { { icon = "__PCPRedux__/graphics/icons/raw/acetylene.png", icon_size = 72 } }, "CHSg"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-acetylene"),
      order = "d[catalyst-steam-cracking-acetylene]",
    },
    {
      type = "recipe",
      name = "acetylene-diomerisation",
      category = "chemistry",
      subgroup = "angels-petrochem-chemistry",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "gas-acetylene", amount = 60 },
      },
      results =
      {
        { type = "fluid", name = "gas-vinyl-acetylene", amount = 30 },
      },
      icons = angelsmods.functions.create_gas_recipe_icon(
        { { icon = "__PCPRedux__/graphics/icons/raw/vinyl-acetylene.png", icon_size = 72 } }, "CCH"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("gas-vinyl-acetylene"),
      order = "d[acetylene-diomerisation]",
    },
    {
      type = "recipe",
      name = "vinyl-acetlyene-chlorination",
      category = "chemistry",
      subgroup = "angels-petrochem-chlorine-2",
      energy_required = 4,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "gas-vinyl-acetylene",          amount = 30 },
        { type = "fluid", name = "angels-gas-hydrogen-chloride", amount = 40 },
      },
      results =
      {
        { type = "fluid", name = "liquid-chlorobutadiene", amount = 50 },
      },
      icons = angelsmods.functions.create_liquid_recipe_icon(
        { { icon = "__PCPRedux__/graphics/icons/raw/chloroprene.png", icon_size = 72 } }, "CClH"),
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-chlorobutadiene"),
      order = "d[acetylene-diomerisation]",
    },
  }) --[[
  ==Rubber Solidification==
  rubber additive 1 (5 carbon->2rubber additive) 0.5
  rubber additive 2 (2 carbon+4 spent rubber->3rubber additive) 0.5

  25Liquid Rubber + 2rubber additive -> 35masterbatch rubber(liquid) - 2chemplant 1
  70masterbatch rubber+4sulfur -> 90pre-rubber (liquid) -1chemplant 1
  45pre-rubber+160water->5rubber block -2chemplant 1
  (1)sawblade+11rubber block->33rubber slab+sawblade(0.9) -1assembly 0.5
  6rubber slab->24rubber pellets+1spent rubber -3pellet press 0.25
  32rubber pellets->48rubber powder -6powderiser 1
  72rubber powder+100air -> 6vulcanised rubber -2steam reformer 0.5
  4vulcanised rubber+100water->1rubber coil -3casting machine 0.5
  4rubber coil->16rubber -1assembly (allow prod) 0.5]]
  data:extend({
    --rubber additive 1 (5 carbon->2rubber additive) 0.5
    {
      type = "recipe",
      name = "rubber-additive-1",
      category = "chemistry",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-solid-carbon", amount = 5 },
      },
      results =
      {
        { type = "item", name = "solid-rubber-additive", amount = 2 },
      },
      icons = {
        { icon = "__PCPRedux__/graphics/icons/solid-rubber-additive.png", icon_size = 64 },
        {
          icon = "__angelsrefininggraphics__/graphics/icons/num_1.png",
          icon_size = 32,
          tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
          scale = 0.32,
          shift = { -12, -12 },
        },
      },
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("angels-liquid-rubber"),
      order = "f[rubber-additive]",
    },
    --rubber additive 2 (2 carbon+4 spent rubber->3rubber additive) 0.5
    {
      type = "recipe",
      name = "rubber-additive-2",
      category = "chemistry",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-solid-carbon", amount = 2 },
        { type = "item", name = "solid-rubber-waste",  amount = 4 }
      },
      results =
      {
        { type = "item", name = "solid-rubber-additive", amount = 3 },
      },
      icons = {
        { icon = "__PCPRedux__/graphics/icons/solid-rubber-additive.png", icon_size = 64 },
        {
          icon = "__angelsrefininggraphics__/graphics/icons/num_2.png",
          tint = { r = 0.8, g = 0.8, b = 0.8, a = 0.5 },
          icon_size = 32,
          scale = 0.32,
          shift = { -12, -12 },
        }
      },
      order = "f[rubber-additive]",
    },
    --4rubber coil->16rubber -1assembly (allow prod) 0.5
    {
      type = "recipe",
      name = "angels-roll-rubber-converting",
      category = "crafting",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item", name = "angels-roll-rubber", amount = 1 },
      },
      results =
      {
        { type = "item", name = "angels-solid-rubber", amount = 4 },
      },
      icons = {
        {
          icon = "__angelspetrochemgraphics__/graphics/icons/solid-rubber.png",
          icon_size = 32
        },
        {
          icon = "__PCPRedux__/graphics/icons/roll-blank.png",
          tint = { r = 0.1, g = 0.1, b = 0.1 },
          scale = 0.4375,
          shift = { -10, -10 }
        }
      },
      icon_size = 32,
      order = "yb",
    },
    --4vulcanised rubber+100water->1rubber coil -3casting machine 0.5
    {
      type = "recipe",
      name = "angels-roll-rubber-casting",
      category = "advanced-crafting",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item",  name = "solid-rubber-vulcanised", amount = 4 },
        { type = "fluid", name = "water",                   amount = 100 }
      },
      results =
      {
        { type = "item", name = "angels-roll-rubber", amount = 1 },
      },
      order = "ya",
    },
    --72rubber powder+100air -> 6vulcanised rubber -2steam reformer 0.5
    {
      type = "recipe",
      name = "vulcanised-rubber-reforming",
      category = "angels-steam-cracking",
      subgroup = "angels-petrochem-feedstock",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item",  name = "solid-rubber-powder",       amount = 72 },
        { type = "fluid", name = "angels-gas-compressed-air", amount = 100 }
      },
      results =
      {
        { type = "item", name = "solid-rubber-vulcanised", amount = 6 },
      },
      order = "ya",
    },
    --32rubber pellets->48rubber powder -6powderiser 1
    {
      type = "recipe",
      name = "rubber-powderisation",
      category = "crafting",
      subgroup = "angels-petrochem-solids",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "item", name = "solid-rubber-pellet", amount = 32 },
      },
      results =
      {
        { type = "item", name = "solid-rubber-powder", amount = 48 },
      },
      order = "ya",
    },
    --6rubber slab->24rubber pellets+1spent rubber -3pellet press 0.25
    {
      type = "recipe",
      name = "rubber-pelletisation",
      category = "crafting",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.25,
      enabled = false,
      ingredients = {
        { type = "item", name = "solid-rubber-slab", amount = 6 },
      },
      results =
      {
        { type = "item", name = "solid-rubber-pellet", amount = 24 },
        { type = "item", name = "solid-rubber-waste",  amount = 1 },
      },
      order = "ya",
      icons = { { icon = "__PCPRedux__/graphics/icons/solid-rubber-pellet.png", icon_size = 64, } },
    },
    --(1)sawblade+11rubber block->33rubber slab+sawblade(0.9) -1assembly 0.5
    {
      type = "recipe",
      name = "rubber-slabbing",
      category = "crafting",
      subgroup = "angels-petrochem-solids",
      energy_required = 0.5,
      enabled = false,
      ingredients = {
        { type = "item", name = "solid-rubber-block", amount = 11 },
      },
      results =
      {
        { type = "item", name = "solid-rubber-slab", amount = 33 },
      },
      order = "ya",
      icons = { { icon = "__PCPRedux__/graphics/icons/solid-rubber-slab.png", icon_size = 64, } },
    },
    --45pre-rubber+160water->5rubber block -2chemplant 1
    {
      type = "recipe",
      name = "rubber-block-molding",
      category = "chemistry",
      subgroup = "angels-petrochem-solids",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-rubber-pre", amount = 45 },
        { type = "fluid", name = "water",             amount = 160 }
      },
      results =
      {
        { type = "item", name = "solid-rubber-block", amount = 5 },
      },
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-rubber-pre"),
      order = "ya",
    },
    --25Liquid Rubber + 2rubber additive -> 35masterbatch rubber(liquid) - 2chemplant 1
    {
      type = "recipe",
      name = "rubber-masterbatching",
      category = "chemistry",
      subgroup = "angels-petrochem-solids",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "angels-liquid-rubber",  amount = 25 },
        { type = "item",  name = "solid-rubber-additive", amount = 2 }
      },
      results =
      {
        { type = "fluid", name = "liquid-rubber-masterbatch", amount = 35 },
      },
      order = "ya",
    },
    crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-rubber-masterbatch"),
    --70masterbatch rubber+4sulfur -> 90pre-rubber (liquid) -1chemplant 1
    {
      type = "recipe",
      name = "pre-rubber-mixing",
      category = "chemistry",
      subgroup = "angels-petrochem-solids",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "fluid", name = "liquid-rubber-masterbatch", amount = 70 },
        { type = "item",  name = "sulfur",                    amount = 4 }
      },
      results =
      {
        { type = "fluid", name = "liquid-rubber-pre", amount = 90 },
      },
      crafting_machine_tint = angelsmods.functions.get_fluid_recipe_tint("liquid-rubber-pre"),
      order = "ya",
    },
    {
      type = "technology",
      name = "rubber-processing",
      icon = "__angelspetrochemgraphics__/graphics/technology/separator-tech.png",
      icon_size = 128,
      prerequisites =
      {
        "angels-rubber",
        angelsmods.bioprocessing and "angels-bio-arboretum-1" or nil
      },
      effects =
      {
        {
          type = "unlock-recipe",
          recipe = "rubber-block-molding"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-masterbatching"
        },
        {
          type = "unlock-recipe",
          recipe = "pre-rubber-mixing"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-slabbing"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-powderisation"
        },
        {
          type = "unlock-recipe",
          recipe = "vulcanised-rubber-reforming"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-roll-rubber-casting"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-additive-2"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-additive-1"
        },
        {
          type = "unlock-recipe",
          recipe = "angels-roll-rubber-converting"
        },
        {
          type = "unlock-recipe",
          recipe = "rubber-pelletisation"
        },
      },
      unit =
      {
        count = 75,
        ingredients = {
          { "automation-science-pack", 1 },
          { "logistic-science-pack",   1 },
          { "chemical-science-pack",   1 },
        },
        time = 30
      },
    },
  })
end
