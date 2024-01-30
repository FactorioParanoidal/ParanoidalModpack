data:extend({
    {
        type = "item-subgroup",
        name = "angels-copper-tungsten",
        group = "angels-smelting",
        order = "t",
    },

    {
        type = "item-subgroup",
        name = "angels-copper-tungsten-casting",
        group = "angels-casting",
        order = "u",
    },
    {
        type = "item-subgroup",
        name = "petrochem-argon",
        group = "petrochem-refining",
        order = "cab",
    },
    {
        type = "item-subgroup",
        name = "angels-tungsten-carbide",
        group = "angels-smelting",
        order = "v",
    },
    {
        type = "item-subgroup",
        name = "angels-tungsten-carbide-casting",
        group = "angels-casting",
        order = "w",
    },
})

-- Storage categories
if mods["angelsaddons-storage"] then
    data:extend({
        {
            type = "item-subgroup",
            name = "angels-warehouses-2",
            group = "logistics",
            order = "zf",
        },
        {
            type = "item-subgroup",
            name = "angels-warehouses-3",
            group = "logistics",
            order = "zg",
        },
        {
            type = "item-subgroup",
            name = "angels-warehouses-4",
            group = "logistics",
            order = "zh",
        },
    })
end

-- Subgrouping adjustments
if settings.startup["extangels-adjust-ordering"].value then
    data:extend({
        -- Petrochem building sorting
        {
            type = "item-subgroup",
            name = "petrochem-buildings-air-filter",
            group = "petrochem-refining",
            order = "za[buildings]-aa",
        },
        {
            type = "item-subgroup",
            name = "petrochem-buildings-liquifier",
            group = "petrochem-refining",
            order = "za[buildings]-ab",
        },
        {
            type = "item-subgroup",
            name = "petrochem-buildings-advanced-chemical-plant",
            group = "petrochem-refining",
            order = "za[buildings]-ba",
        },
        {
            type = "item-subgroup",
            name = "petrochem-buildings-advanced-gas-refinery",
            group = "petrochem-refining",
            order = "za[buildings]-ca",
        },
        {
            type = "item-subgroup",
            name = "petrochem-buildings-separator",
            group = "petrochem-refining",
            order = "za[buildings]-da",
        },
    })

    if angelsmods.bioprocessing then
        data:extend({
            -- Bioprocessing building sorting
            {
                type = "item-subgroup",
                name = "bio-processing-buildings-nauvis-b",
                group = "bio-processing-nauvis",
                order = "za",
            },
            {
                type = "item-subgroup",
                name = "bio-processing-buildings-vegetabilis-c",
                group = "bio-processing-vegetables",
                order = "z[buildings]-c",
            },
            {
                type = "item-subgroup",
                name = "bio-processing-buildings-vegetabilis-d",
                group = "bio-processing-vegetables",
                order = "z[buildings]-d",
            },
            {
                type = "item-subgroup",
                name = "bio-processing-buildings-vegetabilis-e",
                group = "bio-processing-vegetables",
                order = "z[buildings]-e",
            },
            {
                type = "item-subgroup",
                name = "bio-processing-buildings-alien-b",
                group = "bio-processing-alien",
                order = "zb",
            },
        })
    end
end
