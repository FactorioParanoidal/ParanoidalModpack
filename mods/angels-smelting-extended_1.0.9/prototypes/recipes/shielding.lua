if mods["angelsindustries"] and angelsmods.industries.components then
    local function add_water_casting_recipe(metal)
        data:extend({
            {
                type = "recipe",
                name = "angels-shielding-coil-" .. metal .. "-casting",
                category = "strand-casting",
                subgroup = "angels-" .. metal .. "-casting",
                energy_required = 4,
                enabled = false,
                ingredients = {
                    { type = "fluid", name = "liquid-molten-" .. metal, amount = 40 },
                    { type = "fluid", name = "liquid-molten-copper", amount = 40 },
                    { type = "fluid", name = "water", amount = 40 }
                },
                results =
                {
                    { type = "item", name = "angels-shielding-coil-" .. metal, amount = 4 },
                },
            }
        })
    end

    local function add_coolant_casting_recipe(metal)
        data:extend({
            {
                type = "recipe",
                name = "angels-shielding-coil-" .. metal .. "-casting-fast",
                category = "strand-casting",
                subgroup = "angels-" .. metal .. "-casting",
                energy_required = 2,
                enabled = false,
                ingredients = {
                    { type = "fluid", name = "liquid-molten-" .. metal, amount = 70 },
                    { type = "fluid", name = "liquid-molten-copper", amount = 70 },
                    { type = "fluid", name = "liquid-coolant", amount = 40 }
                },
                results =
                {
                    { type = "item", name = "angels-shielding-coil-" .. metal, amount = 8 },
                    { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300 }
                },
                main_product = "angels-shielding-coil-" .. metal,
            }
        })
    end

    local function add_cutting_recipe(metal, tier)
        data:extend({
            {
                type = "recipe",
                name = "angels-shielding-coil-" .. metal .. "-converting",
                category = mods["bobelectronics"] and "electronics" or "crafting",
                subgroup = "angels-" .. metal .. "-casting",
                energy_required = 1,
                enabled = false,
                ingredients = {
                    { type = "item", name = "angels-shielding-coil-" .. metal, amount = 4 }
                },
                results =
                {
                    { type = "item", name = "cable-shielding-" .. tier, amount = 16 },
                },
                main_product = "cable-shielding-" .. tier,
            }
        })
    end

    -- Add regular recipe for copper shielding individually because it only takes one metal
    data:extend({
        {
            type = "recipe",
            name = "angels-shielding-coil-copper-casting",
            category = "strand-casting",
            subgroup = "angels-copper-casting",
            energy_required = 4,
            enabled = false,
            ingredients = {
                { type = "fluid", name = "liquid-molten-copper", amount = 80 },
                { type = "fluid", name = "water", amount = 40 }
            },
            results =
            {
                { type = "item", name = "angels-shielding-coil-copper", amount = 4 },
            },
        }
    })

    -- Add fast recipe for copper shielding individually because it only takes one metal
    data:extend({
        {
            type = "recipe",
            name = "angels-shielding-coil-copper-casting-fast",
            category = "strand-casting",
            subgroup = "angels-copper-casting",
            energy_required = 2,
            enabled = false,
            ingredients = {
                { type = "fluid", name = "liquid-molten-copper", amount = 140 },
                { type = "fluid", name = "liquid-coolant", amount = 40 }
            },
            results =
            {
                { type = "item", name = "angels-shielding-coil-copper", amount = 8 },
                { type = "fluid", name = "liquid-coolant-used", amount = 40, temperature = 300 }
            },
            main_product = "angels-shielding-coil-copper",
        }
    })

    -- Add regular recipes for each of the four other shielding types
    add_water_casting_recipe("tin")
    add_water_casting_recipe("silver")
    add_water_casting_recipe("gold")
    add_water_casting_recipe("platinum")

    -- Add fast recipes for each of the four other shielding types
    add_coolant_casting_recipe("tin")
    add_coolant_casting_recipe("silver")
    add_coolant_casting_recipe("gold")
    add_coolant_casting_recipe("platinum")

    -- Add cutting recipes for all five shielding types
    add_cutting_recipe("copper", 1)
    add_cutting_recipe("tin", 2)
    add_cutting_recipe("silver", 3)
    add_cutting_recipe("gold", 4)
    add_cutting_recipe("platinum", 5)
end