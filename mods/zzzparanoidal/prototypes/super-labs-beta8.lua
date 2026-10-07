-- BigLab 9.1.1 from the supplied Beta 8, with separate IDs from BigLabFork.
-- Keep this template private: final-fixes restores its values after generic patches.
local graphics = "__zzzparanoidal__/graphics/super-labs-beta8/"
local big = "paranoidal-beta8-big-lab"
local hyper = "paranoidal-beta8-hyper-lab"
local inputs = {
    "automation-science-pack", "logistic-science-pack", "chemical-science-pack",
    "military-science-pack", "production-science-pack", "utility-science-pack",
    "space-science-pack", "bob-advanced-logistic-science-pack", "bob-science-pack-gold",
    "bob-alien-science-pack", "bob-alien-science-pack-blue", "bob-alien-science-pack-orange",
    "bob-alien-science-pack-purple", "bob-alien-science-pack-yellow",
    "bob-alien-science-pack-green", "bob-alien-science-pack-red", "angels-token-bio",
}

local definitions = {
    {
        name = big, asset = "big-lab", health = 1500, power = "250MW", speed = 50,
        slots = 6, scale = 2, volume = 2, craft_time = 20,
        collision = {{-9.5, -7.5}, {9.5, 7.5}}, selection = {{-10, -8}, {10, 8}},
        ingredients = {
            {type = "item", name = "concrete", amount = 5000},
            {type = "item", name = "bob-titanium-plate", amount = 1000},
            {type = "item", name = "processing-unit", amount = 500},
            {type = "item", name = "bob-lab-2", amount = 30},
        },
        prerequisites = {"bob-advanced-research"}, order = "c-k-m-a",
        unit = {count = 250, time = 60, ingredients = {
            {"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
        }},
    },
    {
        name = hyper, asset = "hyper-lab", health = 5000, power = "1GW", speed = 128,
        slots = 8, scale = 10, volume = 5, craft_time = 1000,
        collision = {{-49, -39}, {49, 39}}, selection = {{-50, -40}, {50, 40}},
        ingredients = {
            {type = "item", name = "refined-concrete", amount = 10000},
            {type = "item", name = "bob-nitinol-alloy", amount = 1000},
            {type = "item", name = "bob-advanced-processing-unit", amount = 500},
            {type = "item", name = big, amount = 10},
        },
        prerequisites = {big, "space-science-pack"}, order = "c-k-m-b",
        unit = {count = 1000, time = 120, ingredients = {
            {"automation-science-pack", 1}, {"logistic-science-pack", 1}, {"chemical-science-pack", 1},
            {"military-science-pack", 1}, {"production-science-pack", 2}, {"utility-science-pack", 2},
            {"bob-advanced-logistic-science-pack", 2}, {"space-science-pack", 1},
        }},
    },
}

local prototypes = {}
for _, spec in ipairs(definitions) do
    local name = spec.name
    local icon = graphics .. "icon/" .. spec.asset .. ".png"
    local animation = {
        filename = graphics .. "lab/" .. spec.asset .. ".png",
        width = 320, height = 320, frame_count = 1, scale = spec.scale,
        shift = {0, 1.5 / 32},
    }
    local on_animation = table.deepcopy(animation)
    on_animation.line_length = 1
    on_animation.animation_speed = 0.01
    prototypes[#prototypes + 1] = {
        type = "item", name = name, icon = icon, icon_size = 64,
        subgroup = "production-machine", order = "h[lab]", stack_size = 1,
        place_result = name,
        localised_description = {"technology-description." .. name},
    }
    prototypes[#prototypes + 1] = {
        type = "recipe", name = name, enabled = false, energy_required = spec.craft_time,
        ingredients = spec.ingredients,
        results = {{type = "item", name = name, amount = 1}},
        allow_productivity = false,
        show_amount_in_title = false, always_show_products = true,
        always_show_made_in = false, allow_decomposition = true,
    }
    prototypes[#prototypes + 1] = {
        type = "lab", name = name, icon = icon, icon_size = 64,
        flags = {"placeable-player", "player-creation"},
        minable = {mining_time = 5, result = name}, max_health = spec.health,
        corpse = "big-remnants", dying_explosion = "massive-explosion",
        collision_box = spec.collision, selection_box = spec.selection,
        on_animation = {layers = {on_animation}}, off_animation = {layers = {animation}},
        working_sound = {
            sound = {filename = graphics .. "sound/lab.ogg", volume = spec.volume},
        },
        -- 2.0 replaces vehicle_impact_sound with impact categories.
        impact_category = "metal",
        energy_source = {type = "electric", usage_priority = "secondary-input"},
        energy_usage = spec.power, researching_speed = spec.speed,
        inputs = table.deepcopy(inputs), module_slots = spec.slots,
        allowed_effects = {"speed", "productivity", "consumption", "pollution"},
        localised_description = {"technology-description." .. name},
    }
    prototypes[#prototypes + 1] = {
        type = "technology", name = name,
        icon = graphics .. "tech/" .. spec.asset .. ".png", icon_size = 128,
        order = spec.order, prerequisites = spec.prerequisites, unit = spec.unit,
        effects = {{type = "unlock-recipe", recipe = name}},
    }
end
return prototypes
