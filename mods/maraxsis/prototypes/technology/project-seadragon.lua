data:extend {{
    type = "technology",
    name = "maraxsis-project-seadragon",
    icon = "__maraxsis__/graphics/technology/project-seadragon.png",
    icon_size = 256,
    effects = {
        {
            type = "nothing",
            use_icon_overlay_constant = true,
            icon = "__maraxsis__/graphics/technology/project-seadragon.png",
            icon_size = 256,
            effect_description = {"modifier-description.maraxsis-project-seadragon"}
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-super-sealant-substance"
        },
        {
            type = "unlock-recipe",
            recipe = "maraxsis-bio-oil"
        }
    },
    prerequisites = {"hydraulic-science-pack"},
    unit = {
        count = 500,
        ingredients = {
            {"hydraulic-science-pack", 1},
        },
        time = 30,
    },
    order = "ea[seadragon]",
}}

-- Paranoidal fork: no own rocket part: the Maraxsis silo builds the Paranoidal rocket part, one rocket everywhere
-- (ПР-078 rule 4). Upstream copied the rocket part recipe before the build set it (Bob's parts + super sealant).

data:extend {{
    type = "recipe",
    name = "maraxsis-super-sealant-substance",
    enabled = false,
    energy_required = 5,
    ingredients = {
        {type = "item",  name = "sulfur", amount = 3},
        {type = "fluid", name = "heavy-oil", amount = 200},
        {type = "fluid", name = "hydrogen", amount = 100},
    },
    results = {
        {type = "item", name = "maraxsis-super-sealant-substance", amount = 1},
    },
    categories = {"chemistry", "cryogenics"},
    allow_productivity = true,
    auto_recycle = false,
    sort_item_ingredients = false
}}

local super_sealant_substance_variants = {}
for i = 1, 3 do
    super_sealant_substance_variants[i] = {
        filename = "__maraxsis__/graphics/icons/super-sealant-substance-" .. i .. ".png",
        width = 64,
        height = 64,
        scale = 1 / 2,
        flags = {"icon"}
    }
end

data:extend {{
    type = "item",
    name = "maraxsis-super-sealant-substance",
    icon = "__maraxsis__/graphics/icons/super-sealant-substance-1.png",
    icon_size = 64,
    stack_size = data.raw.item["rocket-fuel"].stack_size,
    weight = data.raw.item["rocket-fuel"].weight,
    pictures = super_sealant_substance_variants,
}}

-- Adapted from Rubia & Alternative Rocket Sprite Extension.
local rocket = util.table.deepcopy(data.raw["rocket-silo-rocket"]["rocket-silo-rocket"])
rocket.name = "maraxsis-rocket-silo-rocket"
rocket.localised_name = {"entity-name.rocket-silo-rocket"}
rocket.localised_description = {"entity-description.rocket-silo-rocket"}
rocket.hidden = true
rocket.hidden_in_factoriopedia = true
if settings.startup["maraxsis-fish-rocket"].value == true then
    rocket.rocket_sprite = {
        filename = "__maraxsis__/graphics/entity/rocket-silo/rocket.png",
        height = 290,
        width = 290,
        scale = 1.2,
        shift = {0, 6}
    }
    rocket.rocket_rise_offset = {0, -7}
    rocket.rocket_smoke_bottom1_animation.scale = 0.01
    rocket.rocket_smoke_bottom1_animation.hr_version = nil
    rocket.rocket_smoke_bottom2_animation.scale = 0.01
    rocket.rocket_smoke_bottom2_animation.hr_version = nil
    rocket.rocket_smoke_top1_animation.scale = 0.01
    rocket.rocket_smoke_top1_animation.hr_version = nil
    rocket.rocket_smoke_top2_animation.scale = 0.01
    rocket.rocket_smoke_top2_animation.hr_version = nil
    rocket.rocket_smoke_top3_animation.scale = 0.01
    rocket.rocket_smoke_top3_animation.hr_version = nil
end

data:extend { rocket }

for surface in pairs(maraxsis_constants.MARAXSIS_SURFACES) do
    PlanetsLib.create_planet_entity_variant(
        surface,
        data.raw["rocket-silo"]["rocket-silo"],
        {
            name = "maraxsis-rocket-silo",
            localised_name = {"entity-name.rocket-silo"},
            localised_description = {"entity-description.rocket-silo"},
            rocket_entity = "maraxsis-rocket-silo-rocket",
            fixed_recipe = "rocket-part", -- Paranoidal fork: the Paranoidal rocket part
            disabled_when_recipe_not_researched = true,
            placeable_by = {{item = "rocket-silo", count = 1}},
            flags = {"placeable-player", "player-creation", "not-in-made-in"},
            hidden = true,
            hidden_in_factoriopedia = true,
        },
        "maraxsis-runtime-entity-replacement",
        "rocket-silo"
    )

    -- Paranoidal fork: no rocket part assignment (the silo variant has the fixed Paranoidal rocket part).
end
