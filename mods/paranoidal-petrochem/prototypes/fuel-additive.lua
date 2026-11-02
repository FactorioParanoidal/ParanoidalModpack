-- Fuel additive chain (after More Petrochem Hell by Claviduck): tetraethyllead for high octane enriched fuel.
data:extend(
{
  {
    type = "fluid",
    name = "fluid-tetraethyllead",
    subgroup = "angels-petrochem-basic-fluids",
    default_temperature = 25,
    heat_capacity = "0.1kJ",
    base_color = {r=0.3, g=0.05, b=0.4},
    flow_color = {r=0.3, g=0.05, b=0.4},
    max_temperature = 250,
    icon = "__paranoidal-petrochem__/graphics/fuel-additive/fluid-tetraethyllead.png",
    icon_size = 32,
    order = "i"
  },
  {
    type = "fluid",
    name = "gas-chloroethane",
    icon = "__paranoidal-petrochem__/graphics/fuel-additive/gas-chloroethane.png",
    icon_size = 32,
    subgroup = "angels-petrochem-basic-fluids",
    default_temperature = 25,
    heat_capacity = "0.1kJ",
    base_color = {r = 0.35, g = 0.35, b = 0.35},
    flow_color = {r = 0.35, g = 0.35, b = 0.35},
    max_temperature = 100,
  },
  {
    type = "item",
    name = "ingot-sodium-lead-alloy",
    icon = "__paranoidal-petrochem__/graphics/fuel-additive/ingot-sodium-lead-alloy.png",
    icon_size = 32,
    subgroup = "angels-lead",
    order = "f",
    stack_size = 200
  },
  {
    type = "item",
    name = "high-octane-enriched-fuel",
    icon = "__paranoidal-petrochem__/graphics/fuel-additive/high-octane-enriched-fuel.png",
    icon_size = 32,
    fuel_categories = {"chemical"},
    fuel_value = "40MJ",
    fuel_acceleration_multiplier = 1.9,
    fuel_top_speed_multiplier = 1.3,
    fuel_emissions_multiplier = 1.8,
    subgroup = "bob-resource",
    order = "e[enriched-fuel]",
    stack_size = 20
  },
})

data:extend({
    {
        type = "recipe",
        name = "sodium-lead-alloy",
        categories = {"angels-chemical-smelting"},
        subgroup = "angels-lead",
        enabled = false,
        energy_required = 8,
        ingredients = {
            {type="item", name="angels-ingot-lead", amount=10},
            {type="item", name="angels-solid-sodium", amount=2},
        },
        results = {
            {type="item", name="ingot-sodium-lead-alloy", amount=12},
        },
        icon = "__paranoidal-petrochem__/graphics/fuel-additive/ingot-sodium-lead-alloy.png",
        icon_size = 32,
        order = "i",
    },
    {
        type = "recipe",
        name = "gas-chloroethane",
        categories = {"chemistry"},
        subgroup = "angels-petrochem-chlorine",
        energy_required = 4,
        enabled = false,
        ingredients = {
            {type="fluid", name="angels-gas-ethylene", amount=50},
            {type="fluid", name="angels-liquid-hydrochloric-acid", amount=50},
        },
        results = {
            {type="fluid", name="gas-chloroethane", amount=100},
        },
        icon = "__paranoidal-petrochem__/graphics/fuel-additive/gas-chloroethane.png",
        icon_size = 32,
        order = "c[gas-chloroethane]",
    },
    {
        type = "recipe",
        name = "fluid-tetraethyllead",
        categories = {"angels-chemical-smelting"},
        subgroup = "angels-lead",
        energy_required = 6,
        enabled = false,
        ingredients = {
            {type="fluid", name="gas-chloroethane", amount=50},
            {type="item", name="ingot-sodium-lead-alloy", amount=5},
            {type="fluid", name="steam", amount=100},
        },
        results = {
            {type="fluid", name="fluid-tetraethyllead", amount=25},
            {type="item", name="angels-slag", amount=2},
        },
        icon = "__paranoidal-petrochem__/graphics/fuel-additive/fluid-tetraethyllead.png",
        icon_size = 32,
        order = "c[gas-chloroethane]",
    },
    {
        type = "recipe",
        name = "high-octane-enriched-fuel",
        categories = {"angels-advanced-chemistry"},
        subgroup = "angels-petrochem-fuel",
        energy_required = 4,
        enabled = false,
        ingredients = {
            {type="fluid", name="fluid-tetraethyllead", amount=5},
            {type="fluid", name="angels-liquid-toluene", amount=10},
            {type="fluid", name="angels-liquid-naphtha", amount=85},
        },
        results = {
            {type="item", name="high-octane-enriched-fuel", amount=2},
        },
        icon = "__paranoidal-petrochem__/graphics/fuel-additive/high-octane-enriched-fuel.png",
        icon_size = 32,
        order = "h",
    },
})

data:extend({
  {
    type = "technology",
    name = "Fuel-Additive",
    icon = "__paranoidal-petrochem__/graphics/fuel-additive/Fuel-Additive.png",
    icon_size = 64,
    prerequisites = {"angels-steam-cracking-1", "angels-chlorine-processing-1", "angels-sodium-processing-1", "angels-lead-smelting-1"},
    effects =
    {
      { type = "unlock-recipe", recipe = "sodium-lead-alloy" },
      { type = "unlock-recipe", recipe = "gas-chloroethane" },
      { type = "unlock-recipe", recipe = "fluid-tetraethyllead" },
      { type = "unlock-recipe", recipe = "high-octane-enriched-fuel" },
    },
    unit =
    {
      count = 100,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
      },
      time = 30
    },
    order = ""
  },
})
