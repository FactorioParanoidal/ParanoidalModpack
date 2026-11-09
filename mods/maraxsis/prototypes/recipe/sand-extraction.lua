data:extend {{
    type = "recipe-category",
    name = "maraxsis-sand-extraction"
}}

data:extend {{
    type = "recipe",
    name = "maraxsis-sand-extraction",
    categories = {"maraxsis-sand-extraction" },
    energy_required = 10,
    ingredients = {},
    results = {
        {type = "item", name = maraxsis_constants.SAND_ITEM_NAME, amount = 1}
    },
    enabled = false,
    show_amount_in_title = false,
    allow_decomposition = false,
    allow_productivity = true,
    auto_recycle = false,
    surface_conditions = maraxsis.shallow_surface_conditions(),
    maximum_productivity = 9999999,
    main_product = maraxsis_constants.SAND_ITEM_NAME,
    localised_name = {"item-name.sand"},
    localised_description = {"item-description.sand"},
}}

-- Mining drills placed on Maraxsis without nearby resources are converted into ground
-- diggers that extract sand. PlanetsLib shares one "<drill>-ground-digger" prototype per
-- drill across every planet that enables the feature, assigns the recipe when a digger
-- is built, and applies mining drill productivity to that recipe automatically.
PlanetsLib.enable_ground_diggers("maraxsis", "maraxsis-sand-extraction", {blacklist = {
        ["seafloor-drill"] = true,
        ["surface-drill"] = true,
    }})

