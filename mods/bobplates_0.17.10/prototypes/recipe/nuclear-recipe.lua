if data.raw.item["thorium-ore"] then

data.raw.recipe["uranium-processing"].crafting_machine_tint =
{
  primary = {r=0, g=1, b=0},
  secondary = {r=0, g=1, b=0},
  tertiary = {r=0, g=1, b=0},
}
data.raw.recipe["kovarex-enrichment-process"].crafting_machine_tint =
{
  primary = {r=0, g=1, b=0},
  secondary = {r=0, g=1, b=0},
  tertiary = {r=0, g=1, b=0},
}
data.raw.recipe["nuclear-fuel"].crafting_machine_tint =
{
  primary = {r=0, g=1, b=0},
  secondary = {r=0, g=1, b=0},
  tertiary = {r=0, g=1, b=0},
}
data.raw.recipe["nuclear-fuel-reprocessing"].crafting_machine_tint =
{
  primary = {r=0, g=1, b=0},
  secondary = {r=0, g=1, b=0},
  tertiary = {r=0, g=1, b=0},
}

data:extend(
{
  {
    type = "recipe",
    name = "thorium-processing",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-processing.png",
    icon_size = 32,
    subgroup = "bob-resource",
    order = "l[thorium-processing]",
    energy_required = 12,
    enabled = false,
    category = "centrifuging",
    ingredients =
    {
      {"thorium-ore", 10}
    },
    result = "thorium-232",
    crafting_machine_tint =
    {
      primary = {r=1, g=1, b=0},
      secondary = {r=1, g=1, b=0},
      tertiary = {r=1, g=1, b=0},
    },
  },
  {
    type = "recipe",
    name = "thorium-fuel-cell",
    energy_required = 10,
    enabled = false,
    ingredients =
    {
      {"lead-plate", 10},
      {"uranium-235", 1},
      {"thorium-232", 19},
    },
    result = "thorium-fuel-cell",
    result_count = 10,
  },
  {
    type = "recipe",
    name = "thorium-plutonium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-plutonium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[thorium-processing]-a[thorium-fuel-cell-2]",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {type="item", name="lead-plate", amount=2},
      {type="item", name="plutonium-239", amount=2},
      {type="item", name="thorium-232", amount=2}
    },
    result = "thorium-plutonium-fuel-cell",
    result_count = 2,
    allow_decomposition = false
  },
  {
    type = "recipe",
    name = "thorium-fuel-reprocessing",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-nuclear-fuel-reprocessing.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[thorium-processing]-b[thorium-fuel-reprocessing]",
    energy_required = 60,
    enabled = false,
    category = "centrifuging",
    ingredients = 
    {
      {"used-up-thorium-fuel-cell", 5}
    },
    results =
    {
      {type="item", name="thorium-232", amount=3},
      {type="item", name="plutonium-239", amount=1},

      {type="item", name="lead-plate", amount=5},
      {type="item", name="thorium-232", amount=1, probability=0.05},
      {type="item", name="plutonium-239", amount=1, probability=0.1},
    },
    crafting_machine_tint =
    {
      primary = {r=1, g=1, b=0},
      secondary = {r=1, g=0.7, b=0},
      tertiary = {r=1, g=1, b=0},
    },
    allow_decomposition = false
  },
  {
    type = "recipe",
    name = "bobingabout-enrichment-process",
    icon = "__bobplates__/graphics/icons/nuclear/bobingabout-enrichment-process.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[thorium-processing]-c[bobingabout-enrichment-process]",
    energy_required = 60,
    enabled = false,
    category = "centrifuging",
    ingredients =
    {
      {"plutonium-239", 40},
      {"uranium-238", 5}
    },
    results =
    {
      {"plutonium-239", 41},
      {"uranium-238", 2}
    },
    crafting_machine_tint =
    {
      primary = {r=1, g=0.7, b=0},
      secondary = {r=0, g=1, b=0},
      tertiary = {r=1, g=0.7, b=0},
    },
    allow_decomposition = false
  },
}
)

end

data:extend(
{
  {
    type = "recipe",
    name = "deuterium-fuel-cell",
    category = "crafting-with-fluid",
    energy_required = 10,
    enabled = false,
    ingredients =
    {
      {"lead-plate", 10},
      {type = "fluid", name = "deuterium", amount = 200},
    },
    result = "deuterium-fuel-cell",
    result_count = 10,
  },
  {
    type = "recipe",
    name = "deuterium-fuel-reprocessing",
    icon = "__bobplates__/graphics/icons/nuclear/deuterium-nuclear-fuel-reprocessing.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "t[deuterium-processing]-b[deuterium-fuel-reprocessing]",
    energy_required = 60,
    enabled = false,
    category = "centrifuging",
    ingredients = 
    {
      {"used-up-deuterium-fuel-cell", 5}
    },
    results =
    {
      {type="item", name="lead-plate", amount_min=3, amount_max=7},
      {type="item", name="lithium", amount=1, probability=0.05},
    },
    crafting_machine_tint =
    {
      primary = {r = 1, g = 0, b = 0.57},
      secondary = {r = 0, g = 1, b = 0.85}, --Lithium
      tertiary = {r = 1, g = 0, b = 0.57},
    },
    allow_decomposition = false
  },
}
)

if settings.startup["bobmods-plates-bluedeuterium"].value == true then
  data.raw.recipe["deuterium-fuel-reprocessing"].icon = "__bobplates__/graphics/icons/nuclear/deuterium-nuclear-fuel-reprocessing-blue.png"
  data.raw.recipe["deuterium-fuel-reprocessing"].crafting_machine_tint.primary = {r = 0, g = 0.7, b = 1}
  data.raw.recipe["deuterium-fuel-reprocessing"].crafting_machine_tint.tertiary = {r = 0, g = 0.7, b = 1}
end
