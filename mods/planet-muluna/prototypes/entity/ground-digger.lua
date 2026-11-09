--forked from Maraxsis

Muluna:extend {{
    type = "recipe-category",
    name = "ground-digging"
}}

Muluna:extend {{
    type = "recipe",
    name = "muluna-regolith-digging",
    categories = {"ground-digging"},
    energy_required = 2,
    ingredients = {},
    results = {
        {type = "item", name = "muluna-lunar-regolith", amount = 1,shared_probability = {min = 0, max = 0.2}},
        {type = "item", name = "muluna-breccia", amount = 1,shared_probability = {min = 0.2, max = 1},rigor_product = true}
    },
    rigor_invert = true,
    enabled = false,
    show_amount_in_title = false,
    allow_decomposition = false,
    allow_productivity = true,
    maximum_productivity = 9999999,
    main_product = "muluna-lunar-regolith",
    --rigor_no_results=true,
    auto_recycle = false,
    rigor_whitelist=mods["rigor-module"] and true
    --localised_name = {"item-name.sand"},
    --localised_description = {"item-description.sand"},
}}

-- PlanetsLib generates the shared "<drill>-ground-digger" prototypes and assigns this
-- recipe when a digger is built on Muluna. Any square, placeable mining drill without a
-- fluid output is eligible, including non-electric drills. Drills that output fluids
-- (such as pumpjacks) and the blacklisted drills below are skipped.
PlanetsLib.enable_ground_diggers("muluna", "muluna-regolith-digging", {
    blacklist = {
        ["seafloor-drill"] = true,
        ["surface-drill"] = true,
    },
})
