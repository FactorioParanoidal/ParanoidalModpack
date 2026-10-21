-- Порт 1.1 more-petrochem-hell под Angels 2.0: имена fluids/items/категорий/подгрупп
-- получили префикс angels- (chemical-smelting -> angels-chemical-smelting, gas-ethylene ->
-- angels-gas-ethylene и т.д.). Свои сущности (tetraethyllead/chloroethane/…) без изменений.
data:extend({
    {
        type = "recipe",
        name = "sodium-lead-alloy",
        category = "angels-chemical-smelting",
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
        icon = "__more-petrochem-hell2__/graphics/ingot-sodium-lead-alloy.png",
        icon_size = 32,
        order = "i",
    },
    {
        type = "recipe",
        name = "gas-chloroethane",
        category = "chemistry",
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
        icon = "__more-petrochem-hell2__/graphics/gas-chloroethane.png",
        icon_size = 32,
        order = "c[gas-chloroethane]",
    },
    {
        type = "recipe",
        name = "fluid-tetraethyllead",
        category = "angels-chemical-smelting",
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
        icon = "__more-petrochem-hell2__/graphics/fluid-tetraethyllead.png",
        icon_size = 32,
        order = "c[gas-chloroethane]",
    },
    {
        type = "recipe",
        name = "high-octane-enriched-fuel",
        category = "chemistry",
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
        icon = "__more-petrochem-hell2__/graphics/high-octane-enriched-fuel.png",
        icon_size = 32,
        order = "h",
    },
})
