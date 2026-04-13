local BioInd = require('common')('Bio_Industries_2')
local ICONPATH = BioInd.modRoot .. "/graphics/icons/"
local ICONPATH_W = BioInd.modRoot .. "/graphics/icons/weapons/"
local ICONPATH_E = BioInd.modRoot .. "/graphics/icons/entity/"

local nitrogen = data.raw.fluid["kr-nitrogen"] and "kr-nitrogen" or "nitrogen"

data:extend({

    --- Seeds from Water (BASIC)
    {
        type = "recipe",
        name = "bi-seed-1",
        icon = ICONPATH .. "bio_seed1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bio_seed1.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 200,
        ingredients = {
            { type = "fluid", name = "water", amount = 100 },
            { type = "item",  name = "wood",  amount = 20 },
        },
        results = {
            { type = "item", name = "bi-seed", amount_min = 30, amount_max = 50 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-1",
        order = "a[bi]-ssw-a1[bi-seed-1]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seeds from Water & Ash
    {
        type = "recipe",
        name = "bi-seed-2",
        icon = ICONPATH .. "bio_seed2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bio_seed2.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 150,
        ingredients = {
            { type = "fluid", name = "water",  amount = 40 },
            { type = "item",  name = "wood",   amount = 20 },
            { type = "item",  name = "bi-ash", amount = 10 },
        },
        results = {
			{ type = "item", name = "bi-seed", amount_min = 40, amount_max = 60 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-1",
        order = "a[bi]-ssw-a1[bi-seed-2]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seeds from Water & fertilizer
    {
        type = "recipe",
        name = "bi-seed-3",
        icon = ICONPATH .. "bio_seed3.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bio_seed3.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 100,
        ingredients = {
            { type = "fluid", name = "water",      amount = 40 },
            { type = "item",  name = "wood",       amount = 20 },
            { type = "item",  name = "fertilizer", amount = 10 },
        },
        results = {
			{ type = "item", name = "bi-seed", amount_min = 50, amount_max = 70 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-1",
        order = "a[bi]-ssw-a1[bi-seed-3]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seeds from Water & Adv-fertilizer
    {
        type = "recipe",
        name = "bi-seed-4",
        icon = ICONPATH .. "bio_seed4.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bio_seed4.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 50,
        ingredients = {
            { type = "item",  name = "wood",              amount = 20 },
            { type = "item",  name = "bi-adv-fertilizer", amount = 10 },
            { type = "fluid", name = "water",             amount = 40 },
        },
        results = {
			{ type = "item", name = "bi-seed", amount_min = 60, amount_max = 100 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-1",
        order = "a[bi]-ssw-a1[bi-seed-4]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seedlings from Water (BASIC)
    {
        type = "recipe",
        name = "bi-seedling-1",
        icon = ICONPATH .. "Seedling1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling1.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 400,
        ingredients = {
            { type = "item",  name = "bi-seed", amount = 20 },
            { type = "fluid", name = "water",   amount = 100 },
        },
        results = {
			{ type = "item", name = "seedling", amount_min = 25, amount_max = 55 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-2",
        order = "b[bi]-ssw-b1[bi-Seedling_Mk1]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seedlings from Water & Ash
    {
        type = "recipe",
        name = "bi-seedling-2",
        icon = ICONPATH .. "Seedling2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling2.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 300,
        ingredients = {
            { type = "item",  name = "bi-seed", amount = 25 },
            { type = "item",  name = "bi-ash",  amount = 10 },
            { type = "fluid", name = "water",   amount = 100 },
        },
        results = {
			{ type = "item", name = "seedling", amount_min = 45, amount_max = 75 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-2",
        order = "b[bi]-ssw-b1[bi-Seedling_Mk2]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seedlings from Water & fertilizer
    {
        type = "recipe",
        name = "bi-seedling-3",
        icon = ICONPATH .. "Seedling3.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling3.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 200,
        ingredients = {
            { type = "item",  name = "bi-seed",    amount = 30 },
            { type = "item",  name = "fertilizer", amount = 10 },
            { type = "fluid", name = "water",      amount = 100 },
        },
        results = {
			{ type = "item", name = "seedling", amount_min = 75, amount_max = 105 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        subgroup = "bio-bio-farm-fluid-2",
        order = "b[bi]-ssw-b1[bi-Seedling_Mk3]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seedlings from Water & Adv-fertilizer
    {
        type = "recipe",
        name = "bi-seedling-4",
        icon = ICONPATH .. "Seedling4.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling4.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-greenhouse",
        energy_required = 100,
        ingredients = {
            { type = "item",  name = "bi-seed",           amount = 40 },
            { type = "fluid", name = "water",             amount = 100 },
            { type = "item",  name = "bi-adv-fertilizer", amount = 10 },
        },
        results = {
			{ type = "item", name = "seedling", amount_min = 140, amount_max = 180 },
        },
        main_product = "",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        subgroup = "bio-bio-farm-fluid-2",
        order = "b[bi]-ssw-b1[bi-Seedling_Mk4]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Raw Wood from Water (BASIC)
    {
        type = "recipe",
        name = "bi-logs-1",
        icon = ICONPATH .. "raw-wood-mk1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "raw-wood-mk1.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-farm",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        energy_required = 400,
        ingredients = {
            { type = "item",  name = "seedling", amount = 20 },
            { type = "fluid", name = "water",    amount = 100 },
        },
        results = {
			{ type = "item", name = "wood", amount_min = 25, amount_max = 55 },
			{ type = "item", name = "bi-woodpulp", amount_min = 65, amount_max = 95 },
        },
        main_product = "wood",
        subgroup = "bio-bio-farm-fluid-3",
        order = "c[bi]-ssw-c1[raw-wood1]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Raw Wood from Water & Ash
    {
        type = "recipe",
        name = "bi-logs-2",
        icon = ICONPATH .. "raw-wood-mk2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "raw-wood-mk2.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-farm",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        energy_required = 360,
        ingredients = {
            { type = "item",  name = "seedling", amount = 30 },
            { type = "item",  name = "bi-ash",   amount = 10 },
            { type = "fluid", name = "water",    amount = 100 },
        },
        results = {
			{ type = "item", name = "wood", amount_min = 60, amount_max = 90 },
			{ type = "item", name = "bi-woodpulp", amount_min = 135, amount_max = 165 },
        },
        main_product = "wood",
        subgroup = "bio-bio-farm-fluid-3",
        order = "c[bi]-ssw-c1[raw-wood2]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Raw Wood from Water & fertilizer
    {
        type = "recipe",
        name = "bi-logs-3",
        icon = ICONPATH .. "raw-wood-mk3.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "raw-wood-mk3.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-farm",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        energy_required = 300,
        ingredients = {
            { type = "item",  name = "seedling",   amount = 45 },
            { type = "item",  name = "fertilizer", amount = 10 },
            { type = "fluid", name = "water",      amount = 100 },
        },
        results = {
			{ type = "item", name = "wood", amount_min = 120, amount_max = 150 },
			{ type = "item", name = "bi-woodpulp", amount_min = 255, amount_max = 285 },
        },
        main_product = "wood",
        subgroup = "bio-bio-farm-fluid-3",
        order = "c[bi]-ssw-c1[raw-wood3]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Raw Wood from adv-fertilizer
    {
        type = "recipe",
        name = "bi-logs-4",
        icon = ICONPATH .. "raw-wood-mk4.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "raw-wood-mk4.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-farm",
        enabled = false,
		allow_productivity = true,
        always_show_made_in = true,
        allow_decomposition = false,
        energy_required = 100,
        ingredients = {
            { type = "item",  name = "seedling",          amount = 40 },
            { type = "fluid", name = "water",             amount = 100 },
            { type = "item",  name = "bi-adv-fertilizer", amount = 5 },
        },
        results = {
			{ type = "item", name = "wood", amount_min = 140, amount_max = 180 },
			{ type = "item", name = "bi-woodpulp", amount_min = 300, amount_max = 340 },
        },
        main_product = "wood",
        subgroup = "bio-bio-farm-fluid-3",
        order = "c[bi]-ssw-c1[raw-wood4]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Bio Greenhouse (ENTITY)
    {
        type = "recipe",
        name = "bi-bio-greenhouse",
        localised_name = { "entity-name.bi-bio-greenhouse" },
        localised_description = { "entity-description.bi-bio-greenhouse" },
        icon = ICONPATH_E .. "bio_greenhouse.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_E .. "bio_greenhouse.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 2.5,
        ingredients = {
            { type = "item", name = "iron-stick", amount = 10 },
            { type = "item", name = "stone-brick", amount = 10 },
            { type = "item", name = "small-lamp", amount = 5 },
        },
        results = { { type = "item", name = "bi-bio-greenhouse", amount = 1 } },
        main_product = "",
        allow_as_intermediate = true, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = false, -- Added for 0.18.34/1.1.4
        subgroup = "bio-bio-farm-fluid-entity",
        order = "a[bi]",
    },


    --- Bio Farm (ENTITY)
    {
        type = "recipe",
        name = "bi-bio-farm",
        localised_name = { "entity-name.bi-bio-farm" },
        localised_description = { "entity-description.bi-bio-farm" },
        icon = ICONPATH_E .. "bio_Farm_Icon.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_E .. "bio_Farm_Icon.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 5,
        ingredients = {
            { type = "item", name = "bi-bio-greenhouse", amount = 4 },
            { type = "item", name = "stone-crushed", amount = 10 },
            { type = "item", name = "copper-cable",  amount = 10 },
        },
        results = { { type = "item", name = "bi-bio-farm", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
        subgroup = "bio-bio-farm-fluid-entity",
        order = "b[bi]",
    },


    -- Woodpulp--
    {
        type = "recipe",
        name = "bi-woodpulp",
        icon = ICONPATH .. "Woodpulp_raw-wood.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Woodpulp_raw-wood.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-a[bi-1-woodpulp]",
        enabled = false,
        energy_required = 2,
        ingredients = { { type = "item", name = "wood", amount = 2 } },
        results = { { type = "item", name = "bi-woodpulp", amount = 4 } },
        main_product = "",
        allow_as_intermediate = true, -- Added for 0.18.34/1.1.4
		allow_productivity = true,
        allow_intermediates = true, -- Added for 0.18.35/1.1.5
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = false, -- Added for 0.18.34/1.1.4
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Resin recipe Pulp
    {
        type = "recipe",
        name = "bi-resin-pulp",
        icon = ICONPATH .. "bi_resin_pulp.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_resin_pulp.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-ba[bi-2-resin-2-pulp]",
        enabled = false,
        energy_required = 1,
        ingredients = {
            { type = "item", name = "bi-woodpulp", amount = 3 },
        },
        results = { { type = "item", name = "resin", amount = 1 } },
        main_product = "",
        allow_as_intermediate = true, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = false, -- Added for 0.18.34/1.1.4
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },



    -- Wood from pulp--
    {
        type = "recipe",
        name = "bi-wood-from-pulp",
        icon = ICONPATH .. "wood_from_pulp.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "wood_from_pulp.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-c[bi-3-wood_from_pulp]",
        enabled = false,
        energy_required = 2.5,
        ingredients = {
            { type = "item", name = "bi-woodpulp", amount = 8 },
            { type = "item", name = "resin",       amount = 2 },
        },
        results = { { type = "item", name = "wood", amount = 4 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false,   -- Added for 0.18.34/1.1.4
        allow_decomposition = false,   -- Added for 0.18.34/1.1.4
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },



    -- Wood Fuel Brick
    {
        type = "recipe",
        name = "bi-wood-fuel-brick",
        icon = ICONPATH .. "Fuel_Brick.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Fuel_Brick.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-bx[bi-4-woodbrick]",
        energy_required = 8,
        ingredients = { { type = "item", name = "bi-woodpulp", amount = 192 } },
        results = { { type = "item", name = "wood-bricks", amount = 6 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Changed for 0.18.34/1.1.4
        always_show_made_in = false,          -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    -- ASH --
    {
        type = "recipe",
        name = "bi-ash-1",
        icon = ICONPATH .. "ash_raw-wood.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "ash_raw-wood.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-cb[bi-5-ash-1]",
        enabled = false,
        energy_required = 3,
        ingredients = { { type = "item", name = "wood", amount = 5 } },
        results = { { type = "item", name = "bi-ash", amount = 5 } },
        main_product = "",
        allow_as_intermediate = true, -- Changed for 0.18.34/1.1.4
        always_show_made_in = false, -- Changed for 0.18.34/1.1.4
        allow_decomposition = true, -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    -- ASH 2--
    {
        type = "recipe",
        name = "bi-ash-2",
        icon = ICONPATH .. "ash_woodpulp.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "ash_woodpulp.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-ca[bi-5-ash-2]",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = false,          -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        energy_required = 2.5,
        ingredients = { { type = "item", name = "bi-woodpulp", amount = 12 } },
        results = { { type = "item", name = "bi-ash", amount = 6 } },
        main_product = "",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    -- CHARCOAL 1
    {
        type = "recipe",
        name = "bi-charcoal-1",
        icon = ICONPATH .. "charcoal_woodpulp.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "charcoal_woodpulp.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-d[bi-6-charcoal-1]",
        energy_required = 15,
        ingredients = { { type = "item", name = "bi-woodpulp", amount = 24 } },
        results = { { type = "item", name = "wood-charcoal", amount = 5 } },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    -- CHARCOAL 2
    {
        type = "recipe",
        name = "bi-charcoal-2",
        icon = ICONPATH .. "charcoal_raw-wood.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "charcoal_raw-wood.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-d[bi-6-charcoal-2]",
        category = "biofarm-mod-smelting",
        energy_required = 20,
        ingredients = { { type = "item", name = "wood", amount = 20 } },
        results = { { type = "item", name = "wood-charcoal", amount = 8 } },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
		allow_productivity = true,
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    -- COAL 1 --
    {
        type = "recipe",
        name = "bi-coal-1",
        icon = ICONPATH .. "coal_mk1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "coal_mk1.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-ea[bi-6-coal-1]",
        energy_required = 20,
        ingredients = { { type = "item", name = "wood-charcoal", amount = 10 } },
        results = { { type = "item", name = "coal", amount = 12 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = false,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,            -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,            -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },


    -- COAL 2 --
    {
        type = "recipe",
        name = "bi-coal-2",
        icon = ICONPATH .. "coal_mk2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "coal_mk2.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-eb[bi-6-coal-2]",
        energy_required = 20,
        ingredients = { { type = "item", name = "wood-charcoal", amount = 10 } },
        results = { { type = "item", name = "coal", amount = 16 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = false,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,            -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,            -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },


    -- Solid Fuel
    {
        type = "recipe",
        name = "bi-solid-fuel",
        icon = ICONPATH .. "bi_solid_fuel_wood_brick.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_solid_fuel_wood_brick.png",
                icon_size = 64,
            }
        },
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-fa[bi-7-solid_fuel]",
        category = "chemistry",
        energy_required = 2,
        ingredients = { { type = "item", name = "wood-bricks", amount = 3 } },
        results = { { type = "item", name = "solid-fuel", amount = 2 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Changed for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },


    -- Pellet-Coke from Coal -- Used to be Coke-Coal
    {
        type = "recipe",
        name = "bi-coke-coal",
        icon = ICONPATH .. "pellet_coke_coal.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "pellet_coke_coal.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-g[bi-8-coke-coal]-1",
        energy_required = 20,
        ingredients = { { type = "item", name = "coal", amount = 12 } },
        results = { { type = "item", name = "pellet-coke", amount = 2 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = false,     -- Added for 0.18.34/1.1.4
        always_show_made_in = true,        -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,        -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },


    -- Pellet-Coke from Solid Fuel -- Used to be Coke-Coal
    {
        type = "recipe",
        name = "bi-pellet-coke",
        icon = ICONPATH .. "pellet_coke_solid.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "pellet_coke_solid.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-smelting",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-g[bi-8-coke-coal]-3",
        energy_required = 6,
        ingredients = { { type = "item", name = "solid-fuel", amount = 5 } },
        results = { { type = "item", name = "pellet-coke", amount = 3 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = false,     -- Added for 0.18.34/1.1.4
        always_show_made_in = true,        -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,        -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- CRUSHED STONE from stone --
    {
        type = "recipe",
        name = "bi-crushed-stone-1",
        icon = ICONPATH .. "crushed-stone-stone.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "crushed-stone-stone.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-crushing",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z[bi-9-stone-crushed-1]",
        energy_required = 1.5,
        ingredients = { { type = "item", name = "stone", amount = 1 } },
        results = { { type = "item", name = "stone-crushed", amount = 2 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- CRUSHED STONE from concrete --
    {
        type = "recipe",
        name = "bi-crushed-stone-2",
        localised_description = { "recipe-description.bi-crushed-stone" },
        icon = ICONPATH .. "crushed-stone-concrete.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "crushed-stone-concrete.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-crushing",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z[bi-9-stone-crushed-2]",
        energy_required = 2.5, -- Increased crafting time
        ingredients = { { type = "item", name = "concrete", amount = 1 } },
        results = { { type = "item", name = "stone-crushed", amount = 2 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- CRUSHED STONE from hazard concrete --
    {
        type = "recipe",
        name = "bi-crushed-stone-3",
        localised_description = { "recipe-description.bi-crushed-stone" },
        icon = ICONPATH .. "crushed-stone-hazard-concrete.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "crushed-stone-hazard-concrete.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-crushing",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z[bi-9-stone-crushed-3]",
        energy_required = 2.5, -- Increased crafting time
        ingredients = { { type = "item", name = "hazard-concrete", amount = 1 } },
        results = { { type = "item", name = "stone-crushed", amount = 2 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,

    },

    -- CRUSHED STONE from refined concrete --
    {
        type = "recipe",
        name = "bi-crushed-stone-4",
        localised_description = { "recipe-description.bi-crushed-stone" },
        icon = ICONPATH .. "crushed-stone-refined-concrete.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "crushed-stone-refined-concrete.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-crushing",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z[bi-9-stone-crushed-4]",
        energy_required = 5, -- Increased crafting time
        ingredients = { { type = "item", name = "refined-concrete", amount = 1 } },
        results = { { type = "item", name = "stone-crushed", amount = 4 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- CRUSHED STONE from refined hazard concrete --
    {
        type = "recipe",
        name = "bi-crushed-stone-5",
        localised_description = { "recipe-description.bi-crushed-stone" },
        icon = ICONPATH .. "crushed-stone-refined-hazard-concrete.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "crushed-stone-refined-hazard-concrete.png",
                icon_size = 64,
            }
        },
        category = "biofarm-mod-crushing",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z[bi-9-stone-crushed-5]",
        energy_required = 5, -- Increased crafting time
        ingredients = { { type = "item", name = "refined-hazard-concrete", amount = 1 } },
        results = { { type = "item", name = "stone-crushed", amount = 4 } },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- STONE Brick--
    {
        type = "recipe",
        name = "bi-stone-brick",
        icon = ICONPATH .. "bi_stone_brick.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_stone_brick.png",
                icon_size = 64,
            }
        },
        --category = "smelting",
        category = "chemistry",
        subgroup = "bio-bio-farm-raw",
        order = "a[bi]-a-z2[bi-9-stone-brick]",
        energy_required = 5,
        ingredients = {
            { type = "item", name = "stone-crushed", amount = 6 },
            { type = "item", name = "bi-ash",        amount = 2 },
        },
        results = {
            { type = "item", name = "stone-brick", amount = 2 },
        },
        enabled = false,
        main_product = "",
        allow_as_intermediate = true,         -- Added for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
    },

    -- COKERY (ENTITY)--
    {
        type = "recipe",
        name = "bi-cokery",
        localised_name = { "entity-name.bi-cokery" },
        localised_description = { "entity-description.bi-cokery" },
        icon = ICONPATH_E .. "cokery.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_E .. "cokery.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 8,
        ingredients = {
            { type = "item", name = "stone-furnace", amount = 3 },
            { type = "item", name = "steel-plate", amount = 10 },
        },
        results = { { type = "item", name = "bi-cokery", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
        subgroup = "bio-bio-farm-raw-entity",
        order = "a[bi]",
    },


    -- STONE CRUSHER (ENTITY) --
    {
        type = "recipe",
        name = "bi-stone-crusher",
        localised_name = { "entity-name.bi-stone-crusher" },
        localised_description = { "entity-description.bi-stone-crusher" },
        icon = ICONPATH_E .. "stone_crusher.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_E .. "stone_crusher.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 3,
        ingredients = {
            { type = "item", name = "iron-plate",  amount = 10 },
            { type = "item", name = "steel-plate", amount = 10 },
            { type = "item", name = "iron-gear-wheel", amount = 5 },
        },
        results = { { type = "item", name = "bi-stone-crusher", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
		allow_productivity = true,
        subgroup = "bio-bio-farm-raw-entity",
        order = "b[bi]",
    },


    -- LIQUID-AIR --
    {
        type = "recipe",
        name = "bi-liquid-air",
        icon = ICONPATH .. "liquid-air.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "liquid-air.png",
                icon_size = 64,
            }
        },
        category = "chemistry",
        energy_required = 1,
        ingredients = {},
        results = {
            { type = "fluid", name = "liquid-air", amount = 10 }
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-bio-farm-intermediate-product",
        order = "aa",
    },

    ---NITROGEN --
    {
        type = "recipe",
        name = "bi-nitrogen",
        icon = ICONPATH .. "nitrogen.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "nitrogen.png",
                icon_size = 64,
            }
        },
        category = "chemistry",
        energy_required = 10,
        ingredients = {
            { type = "fluid", name = "liquid-air", amount = 20 }
        },
        results = {
            { type = "fluid", name = nitrogen, amount = 20 },
        },
		crafting_machine_tint = {
        primary = { r = 0.0, g = 0.8, b = 0.0, a = 0.000 },
        secondary = { r = 0.5, g = 1.0, b = 0.5, a = 0.000 },
        tertiary = { r = 0.25, g = 0.5, b = 0.25, a = 0.000 },
        },
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-bio-farm-intermediate-product",
        order = "ab",
    },


    -- fertilizer- Sulfur-
    {
        type = "recipe",
        name = "bi-fertilizer-1",
        icon = ICONPATH .. "fertilizer_sulfur.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "fertilizer_sulfur.png",
                icon_size = 64,
            }
        },
        category = "chemistry",
        energy_required = 5,
        ingredients = {
            { type = "item",  name = "sulfur",   amount = 1 },
            { type = "fluid", name = nitrogen, amount = 10 },
            { type = "item",  name = "bi-ash",   amount = 10 }
        },
        results = {
            { type = "item", name = "fertilizer", amount = 5 }
        },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Changed for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        subgroup = "bio-bio-farm-intermediate-product",
        order = "b[bi-fertilizer]",
    },


    -- Advanced fertilizer 1 --
    {
        type = "recipe",
        name = "bi-adv-fertilizer-1",
        icon = ICONPATH .. "fertilizer_advanced.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "fertilizer_advanced.png",
                icon_size = 64,
            }
        },
        category = "chemistry",
        energy_required = 50,
        ingredients = {
            { type = "item",  name = "fertilizer", amount = 25 },
            { type = "fluid", name = "bi-biomass", amount = 10 }, -- <== Need to add during Data Updates
            --{type = "fluid", name = "NE_enhanced-nutrient-solution", amount = 5}, -- Will be added if you have Natural Evolution Buildings Mod installed.
        },
        results = {
            { type = "item", name = "bi-adv-fertilizer", amount = 50 }
        },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Changed for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        subgroup = "bio-bio-farm-intermediate-product",
        order = "b[bi-fertilizer]-b[bi-adv-fertilizer-1]",
    },


    -- Advanced fertilizer 2--
    {
        type = "recipe",
        name = "bi-adv-fertilizer-2",
        icon = ICONPATH .. "fertilizer_advanced.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "fertilizer_advanced.png",
                icon_size = 64,
            }
        },
        category = "chemistry",
        energy_required = 50,
        ingredients = {
            { type = "item",  name = "fertilizer",  amount = 20 },
            { type = "fluid", name = "bi-biomass",  amount = 10 },
            { type = "item",  name = "bi-woodpulp", amount = 10 },
        },
        results = {
            { type = "item", name = "bi-adv-fertilizer", amount = 20 }
        },
        main_product = "",
        enabled = false,
        allow_as_intermediate = true,         -- Changed for 0.18.34/1.1.4
        always_show_made_in = true,           -- Changed for 0.18.34/1.1.4
        allow_decomposition = true,           -- Changed for 0.18.34/1.1.4
		allow_productivity = true,
        subgroup = "bio-bio-farm-intermediate-product",
        order = "b[bi-fertilizer]-b[bi-adv-fertilizer-2]",
        -- This is a custom property for use by "Krastorio 2" (it will change
        -- ingredients/results; used for wood/wood pulp)
        mod = "Bio_Industries_2",
    },


    --- Seed Bomb - Basic
    {
        type = "recipe",
        name = "bi-seed-bomb-basic",
        icon = ICONPATH_W .. "seed_bomb_icon_b.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_W .. "seed_bomb_icon_b.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 8,
        ingredients = {
            { type = "item", name = "bi-seed", amount = 400 },
            { type = "item", name = "rocket", amount = 1 },
        },
        results = { { type = "item", name = "bi-seed-bomb-basic", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
        subgroup = "bi-ammo",
        order = "a[rocket-launcher]-x[seed-bomb]-a",
    },


    --- Seed Bomb - Standard
    {
        type = "recipe",
        name = "bi-seed-bomb-standard",
        icon = ICONPATH_W .. "seed_bomb_icon_s.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_W .. "seed_bomb_icon_s.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 8,
        ingredients = {
            { type = "item", name = "bi-seed", amount = 400 },
            { type = "item", name = "fertilizer", amount = 200 },
            { type = "item", name = "rocket", amount = 1 },
        },
        results = { { type = "item", name = "bi-seed-bomb-standard", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
        subgroup = "bi-ammo",
        order = "a[rocket-launcher]-x[seed-bomb]-b",
    },


    --- Seed Bomb - Advanced
    {
        type = "recipe",
        name = "bi-seed-bomb-advanced",
        icon = ICONPATH_W .. "seed_bomb_icon_a.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_W .. "seed_bomb_icon_a.png",
                icon_size = 64,
            }
        },
        enabled = false,
        energy_required = 8,
        ingredients = {
            { type = "item", name = "bi-seed",       amount = 400 },
            { type = "item", name = "bi-adv-fertilizer", amount = 200 },
            { type = "item", name = "rocket",        amount = 1 },
        },
        results = { { type = "item", name = "bi-seed-bomb-advanced", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
        subgroup = "bi-ammo",
        order = "a[rocket-launcher]-x[seed-bomb]-c",
    },


    --- Arboretum (ENTITY)
    {
        type = "recipe",
        name = "bi-arboretum",
        localised_name = { "entity-name.bi-arboretum" },
        localised_description = { "entity-description.bi-arboretum" },
        icon = ICONPATH_E .. "arboretum_Icon.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH_E .. "arboretum_Icon.png",
                icon_size = 64,
            }
        },
        subgroup = "production-machine",
        order = "x[bi]-a[bi-arboretum]",
        enabled = false,
        energy_required = 10,
        ingredients = {
            { type = "item", name = "bi-bio-greenhouse", amount = 4 },
            { type = "item", name = "assembling-machine-2", amount = 2 },
            { type = "item", name = "stone-brick",      amount = 10 },
        },
        results = { { type = "item", name = "bi-arboretum-area", amount = 1 } },
        main_product = "",
        allow_as_intermediate = false, -- Added for 0.18.34/1.1.4
        always_show_made_in = false, -- Added for 0.18.34/1.1.4
        allow_decomposition = true,  -- Added for 0.18.34/1.1.4
    },


    ---     Arboretum -  Plant Trees
    {
        type = "recipe",
        name = "bi-arboretum-r1",
        icon = ICONPATH .. "Seedling_b.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "Seedling_b.png",
                icon_size = 64,
            }
        },
        category = "bi-arboretum",
        energy_required = 10000,
        ingredients = {
            { type = "item",  name = "seedling", amount = 1 },
            { type = "fluid", name = "water",    amount = 100 },
        },
        results = {
            { type = "item", name = "bi-arboretum-r1", amount = 1, probability = 0 },
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-arboretum-fluid",
        order = "a[bi]-ssw-a1[bi-arboretum-r1]",
    },


    ---     Arboretum - Change Terrain
    {
        type = "recipe",
        name = "bi-arboretum-r2",
        icon = ICONPATH .. "bi_change_1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_change_1.png",
                icon_size = 64,
            }
        },
        category = "bi-arboretum",
        energy_required = 10000,
        ingredients = {
            { type = "item",  name = "fertilizer", amount = 1 },
            { type = "fluid", name = "water",      amount = 100 },
        },
        results = {
            { type = "item", name = "bi-arboretum-r2", amount = 1, probability = 0 },
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-arboretum-fluid",
        order = "a[bi]-ssw-a1[bi-arboretum-r2]",
    },


    ---     Arboretum -  Change Terrain - Advanced
    {
        type = "recipe",
        name = "bi-arboretum-r3",
        icon = ICONPATH .. "bi_change_2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_change_2.png",
                icon_size = 64,
            }
        },
        category = "bi-arboretum",
        energy_required = 10000,
        ingredients = {
            { type = "item",  name = "bi-adv-fertilizer", amount = 1 },
            { type = "fluid", name = "water",             amount = 100 },
        },
        results = {
            { type = "item", name = "bi-arboretum-r3", amount = 1, probability = 0 },
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-arboretum-fluid",
        order = "a[bi]-ssw-a1[bi-arboretum-r3]",
    },


    ---     Arboretum -  Plant Trees & Change Terrain
    {
        type = "recipe",
        name = "bi-arboretum-r4",
        icon = ICONPATH .. "bi_change_plant_1.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_change_plant_1.png",
                icon_size = 64,
            }
        },
        category = "bi-arboretum",
        energy_required = 10000,
        ingredients = {
            { type = "item",  name = "seedling",   amount = 1 },
            { type = "item",  name = "fertilizer", amount = 1 },
            { type = "fluid", name = "water",      amount = 100 },
        },
        results = {
            { type = "item", name = "bi-arboretum-r4", amount = 1, probability = 0 },
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-arboretum-fluid",
        order = "a[bi]-ssw-a1[bi-arboretum-r4]",
    },


    ---     Arboretum -  Plant Trees & Change Terrain Advanced
    {
        type = "recipe",
        name = "bi-arboretum-r5",
        icon = ICONPATH .. "bi_change_plant_2.png",
        icon_size = 64,
        icons = {
            {
                icon = ICONPATH .. "bi_change_plant_2.png",
                icon_size = 64,
            }
        },
        category = "bi-arboretum",
        energy_required = 10000,
        ingredients = {
            { type = "item",  name = "seedling",          amount = 1 },
            { type = "item",  name = "bi-adv-fertilizer", amount = 1 },
            { type = "fluid", name = "water",             amount = 100 },
        },
        results = {
            { type = "item", name = "bi-arboretum-r5", amount = 1, probability = 0 },
        },
        main_product = "",
        enabled = false,
        always_show_made_in = true,
        allow_decomposition = false,
        allow_as_intermediate = false,
        subgroup = "bio-arboretum-fluid",
        order = "a[bi]-ssw-a1[bi-arboretum-r5]",
    },
})
