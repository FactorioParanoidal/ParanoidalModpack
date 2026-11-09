data:extend {{
    type = "recipe",
    name = "maraxsis-stone-centrifuging",
    categories = {"centrifuging"},
    enabled = false,
    energy_required = 2,
    ingredients = {
        {type = "item", name = "stone", amount = 10}
    },
    results = {
        {type = "item", name = "uranium-ore", amount = 1, independent_probability = 0.1},
    },
    icon = "__maraxsis__/graphics/icons/stone-centrifuging.png",
    icon_size = 64,
    main_product = "uranium-ore",
    auto_recycle = false,
    allow_decomposition = false,
    allow_productivity = true,
    localised_name = {"technology-name.maraxsis-stone-centrifuging"},
    localised_description = {"technology-description.maraxsis-stone-centrifuging"},
    subgroup = "uranium-processing",
    order = "b[uranium-products]-e[stone-centrifuging]"
}}

data:extend {{
    type = "technology",
    name = "maraxsis-stone-centrifuging",
    icon = "__maraxsis__/graphics/technology/stone-centrifuging.png",
    icon_size = 256,
    effects = {
        {
            type = "unlock-recipe",
            recipe = "maraxsis-stone-centrifuging"
        }
    },
    -- Paranoidal fork: Kovarex enrichment is not researchable in the build; uranium processing brings the centrifuge.
    prerequisites = {"uranium-processing", "maraxsis-project-seadragon", "metallurgic-science-pack"},
    unit = {
        count = 5000,
        ingredients = {
            {"metallurgic-science-pack", 1},
            {"hydraulic-science-pack", 1},
        },
        time = 60
    },
}}