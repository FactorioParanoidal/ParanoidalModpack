local show_formula = settings.startup["angels-show-chemical-formula"].value
local AF = angelsmods.functions

data:extend({
  -----------------------------------------------------------------------------
  -- VEGETABLES ---------------------------------------------------------------
  -----------------------------------------------------------------------------
  {
    type = "item",
    name = "solid-beans",
    icon = "__angelsbioprocessing__/graphics/icons/solid-beans.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-a",
    stack_size = 500,
  },
  {
    type = "item",
    name = "solid-corn",
    icon = "__angelsbioprocessing__/graphics/icons/solid-corn.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-b",
    stack_size = 500,
  },
  {
    type = "item",
    name = "solid-leafs",
    icon = "__angelsbioprocessing__/graphics/icons/solid-leafs.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-c",
    stack_size = 500,
  },
  {
    type = "item",
    name = "solid-nuts",
    icon = "__angelsbioprocessing__/graphics/icons/solid-nuts.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-d",
    stack_size = 500,
  },
  {
    type = "item",
    name = "solid-pips",
    icon = "__angelsbioprocessing__/graphics/icons/solid-pips.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-e",
    stack_size = 500,
  },
  {
    type = "item",
    name = "solid-fruit",
    icon = "__angelsbioprocessing__/graphics/icons/solid-fruit.png",
    icon_size = 32,
    subgroup = "bio-processor-nutrient",
    order = "a[vegetables]-f",
    stack_size = 500,
  },
  -----------------------------------------------------------------------------
  -- PROCESSING ---------------------------------------------------------------
  -----------------------------------------------------------------------------
  {
    type = "fluid",
    name = "liquid-nutrient-pulp",
    icons = AF.create_viscous_liquid_fluid_icon(nil, { { 214, 135, 010 }, nil, { 239, 168, 044 } }),
    subgroup = "bio-processor-nutrient",
    order = "b[processing]-a[vegetables]-a[pulp]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = { r = 214 / 255, g = 135 / 255, b = 010 / 255 },
    flow_color = { r = 239 / 255, g = 168 / 255, b = 044 / 255 },
  },
  {
    type = "fluid",
    name = "liquid-raw-vegetable-oil",
    icons = AF.create_viscous_liquid_fluid_icon(
      nil,
      { { 255, 184, 062 }, { 255, 184, 062 }, { 255, 221, 061, 0.8 }, { 255, 221, 061, 0.8 } }
    ),
    subgroup = "bio-processor-press-vegetables",
    order = "b[processing]-b[results]-a[oil]-a",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = { r = 194 / 255, g = 122 / 255, b = 29 / 255 },
    flow_color = { r = 194 / 255, g = 122 / 255, b = 29 / 255 },
  },
  {
    type = "fluid",
    name = "liquid-vegetable-oil",
    icons = AF.create_viscous_liquid_fluid_icon(
      nil,
      { { 255, 255, 060 }, { 255, 255, 060 }, { 255, 255, 000, 0.8 }, { 255, 255, 000, 0.8 } }
    ),
    subgroup = "bio-processor-press-vegetables",
    order = "b[processing]-b[results]-a[oil]-b",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = { r = 255 / 255, g = 255 / 255, b = 060 / 255 },
    flow_color = { r = 255 / 255, g = 255 / 255, b = 000 / 255 },
  },
  --[[{
    type = "item",
    name = "solid-flour",
    icon = "__angelsbioprocessing__/graphics/icons/solid-flour.png",
    icon_size = 32,
    subgroup = "bio-processor-press-vegetables",
    order = "b[processing]-b[results]-a[flour]",
    stack_size = 500
  },
  {
    type = "fluid",
    name = "liquid-plant-milk",
    icons = AF.create_viscous_liquid_fluid_icon(nil, { {255,255,255}, nil, {245,245,245,0.9} }),
    subgroup = "bio-processor-press-vegetables",
    order = "b[processing]-b[results]-b[milk]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = {r = 255/255, g = 255/255, b = 255/255},
    flow_color = {r = 245/255, g = 245/255, b = 245/255},
  },]]
  {
    type = "fluid",
    name = "gas-ethanol",
    localised_description = show_formula and {
      "tooltip-description.chemical-formula",
      "C[font=default-tiny-bold]2[/font]H[font=default-tiny-bold]6[/font]O",
    } or nil,
    icons = AF.create_gas_fluid_icon({ "__angelsbioprocessing__/graphics/icons/molecule-ethanol.png", 72 }, "COH"),
    subgroup = "bio-processor-fermentation",
    order = "b[processing]-d[ethanol]",
    default_temperature = 0,
    gas_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = AF.fluid_color("C2H6O"), --{r=184/255, g=171/255, b=28/255},
    flow_color = AF.flow_color("C2H6O"), --{r=184/255, g=171/255, b=28/255},
  },
  {
    type = "fluid",
    name = "liquid-fermentation-raw",
    icon = "__angelsbioprocessing__/graphics/icons/liquid-fermentation-raw.png",
    icon_size = 32,
    subgroup = "bio-processor-fermentation",
    order = "b[processing]-a[raw]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = { r = 184 / 255, g = 171 / 255, b = 28 / 255 },
    flow_color = { r = 184 / 255, g = 171 / 255, b = 28 / 255 },
  },
  {
    type = "fluid",
    name = "liquid-acetic-acid",
    localised_description = show_formula and {
      "tooltip-description.chemical-formula",
      "C[font=default-tiny-bold]2[/font]H[font=default-tiny-bold]4[/font]O[font=default-tiny-bold]2[/font]",
    } or nil,
    icons = AF.create_liquid_fluid_icon(
      { "__angelsbioprocessing__/graphics/icons/molecule-acetic-acid.png", 72 },
      "COH"
    ),
    subgroup = "bio-processor-fermentation",
    order = "b[processing]-b[acetic-acid]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = AF.fluid_color("C2H4O"), --{r=184/255, g=171/255, b=28/255},
    flow_color = AF.flow_color("C2H4O"), --{r=184/255, g=171/255, b=28/255},
  },
  {
    type = "fluid",
    name = "liquid-acetic-anhydride",
    localised_description = show_formula and {
      "tooltip-description.chemical-formula",
      "C[font=default-tiny-bold]4[/font]H[font=default-tiny-bold]6[/font]O[font=default-tiny-bold]3[/font]",
    } or nil,
    icons = AF.create_liquid_fluid_icon(
      { "__angelsbioprocessing__/graphics/icons/molecule-acetic-anhydride.png", 72 },
      "COH"
    ),
    subgroup = "bio-processor-fermentation",
    order = "b[processing]-c[acetic-anhydride]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = AF.fluid_color("C4H6O3"), --{r=184/255, g=171/255, b=28/255},
    flow_color = AF.flow_color("C4H6O3"), --{r=184/255, g=171/255, b=28/255},
  },
  {
    type = "fluid",
    name = "liquid-cellulose-acetate-mixture",
    icon = "__angelsbioprocessing__/graphics/icons/liquid-cellulose-acetate-mixture.png",
    icon_size = 32,
    subgroup = "bio-plastic",
    order = "b[processing]-a[cellulose-acetate]-a[mixture]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = { r = 184 / 255, g = 171 / 255, b = 28 / 255 },
    flow_color = { r = 184 / 255, g = 171 / 255, b = 28 / 255 },
  },
  {
    type = "fluid",
    name = "liquid-cellulose-acetate",
    localised_description = show_formula
        and {
          "tooltip-description.chemical-formula",
          "(C[font=default-tiny-bold]4[/font]H[font=default-tiny-bold]14[/font]O[font=default-tiny-bold]13[/font])[font=default-tiny-bold]n[/font]",
        }
      or nil,
    icons = AF.create_liquid_fluid_icon(
      { "__angelsbioprocessing__/graphics/icons/molecule-cellulose-acetate.png", 72 },
      "COH"
    ),
    subgroup = "bio-plastic",
    order = "b[processing]-a[cellulose-acetate]-b[full]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = AF.fluid_color("C4H14O13"), --{r=184/255, g=171/255, b=28/255},
    flow_color = AF.flow_color("C4H14O13"), --{r=184/255, g=171/255, b=28/255},
  },
  {
    type = "fluid",
    name = "liquid-propionic-acid",
    localised_description = show_formula and {
      "tooltip-description.chemical-formula",
      "C[font=default-tiny-bold]3[/font]H[font=default-tiny-bold]6[/font]O[font=default-tiny-bold]2[/font]",
    } or nil,
    icons = AF.create_liquid_fluid_icon(
      { "__angelsbioprocessing__/graphics/icons/molecule-propionic-acid.png", 72 },
      "COH"
    ),
    subgroup = "bio-plastic",
    order = "b[processing]-b[propionic-acid]",
    default_temperature = 0,
    max_temperature = 0,
    heat_capacity = "1KJ",
    base_color = AF.fluid_color("C3H6O2"), --{r=184/255, g=171/255, b=28/255},
    flow_color = AF.flow_color("C3H6O2"), --{r=184/255, g=171/255, b=28/255},
  },
})
