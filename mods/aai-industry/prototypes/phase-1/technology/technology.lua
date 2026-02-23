local util = require("data-util")

data.raw.technology["logistics"].prerequisites = {"basic-logistics", "automation-science-pack"}

data.raw.technology["automation"].unit.count = 100
data.raw.technology["automation"].prerequisites = {"electricity"}

data.raw.technology["automation-2"].unit.count = 150

data.raw.technology["lamp"].prerequisites = {"electricity", "glass-processing"}

data.raw.technology["gun-turret"].prerequisites = {"military"}

data.raw.technology["automation-science-pack"].research_trigger.item = "burner-lab"
data.raw.technology["automation-science-pack"].prerequisites = {"burner-mechanics"}

data.raw.technology["electronics"].prerequisites = {"electricity"}
data.raw.technology["electronics"].research_trigger = nil
data.raw.technology["electronics"].unit = {
    count = 30,
    ingredients = {
        {"automation-science-pack", 1},
    },
    time = 15
}

data.raw.technology["logistic-science-pack"].prerequisites = {"basic-logistics", "electricity"}

data.raw.technology["steam-power"].prerequisites = {"fluid-handling"}
data.raw.technology["steam-power"].order = "a"
data.raw.technology["steam-power"].research_trigger = nil
data.raw.technology["steam-power"].unit = {
    count = 100,
    ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
    },
    time = 20
}

data.raw.technology["laser"].prerequisites = {"lamp", "electronics", "chemical-science-pack"}

data.raw.technology["laser-turret"].prerequisites = {"gun-turret", "laser", "battery", "military-science-pack"}

data.raw.technology["flamethrower"].prerequisites = {"flammables", "engine", "military-science-pack"}

data.raw.technology["fluid-handling"].prerequisites = {"basic-fluid-handling", "steel-processing", "logistic-science-pack"}

data.raw.technology["concrete"].prerequisites = {"basic-fluid-handling", "logistic-science-pack"}

data.raw.technology["stone-wall"].order = "a"

data.raw.technology["gate"].order = "a"
data.raw.technology["gate"].prerequisites = {"electronics", "stone-wall", "military", "logistic-science-pack"}

data.raw.technology["toolbelt"].prerequisites = {"automation-science-pack"}
data.raw.technology["toolbelt"].icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256)
data.raw.technology["toolbelt"].unit = {
    count = 50,
    ingredients = {
        {"automation-science-pack", 1},
    },
    time = 10
}
data.raw.technology["toolbelt"].effects = { { modifier = 5, type = "character-inventory-slots-bonus" } }

-- effects are added in technology-update
data:extend{
    {
        type = "technology",
        name = "toolbelt-2",
        icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256),
        order = "c-k-m",
        prerequisites = { "toolbelt", "logistic-science-pack"},
        effects = { { modifier = 5, type = "character-inventory-slots-bonus" } },
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "toolbelt-3",
        icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256),
        order = "c-k-m",
        prerequisites = { "toolbelt-2", "chemical-science-pack" },
        effects = { { modifier = 5, type = "character-inventory-slots-bonus" } },
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "toolbelt-4",
        icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256),
        order = "c-k-m",
        prerequisites = { "toolbelt-3", "utility-science-pack" },
        effects = { { modifier = 5, type = "character-inventory-slots-bonus" } },
        unit = {
            count = 500,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "toolbelt-5",
        icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256),
        order = "c-k-m",
        prerequisites = { "toolbelt-4", "production-science-pack" },
        effects = { { modifier = 5, type = "character-inventory-slots-bonus" } },
        unit = {
            count = 1000,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
                {"production-science-pack", 1},
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "toolbelt-6",
        icons = util.technology_icon_constant_capacity("__base__/graphics/technology/toolbelt.png", 256),
        order = "c-k-m",
        prerequisites = { "toolbelt-5", "space-science-pack" },
        effects = { { modifier = 5, type = "character-inventory-slots-bonus" } },
        unit = {
            count = 2000,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"chemical-science-pack", 1},
                {"utility-science-pack", 1},
                {"production-science-pack", 1},
                {"space-science-pack", 1},
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "burner-mechanics",
        icon = "__base__/graphics/technology/engine.png",
        icon_size = 256,
        order = "a",
        research_trigger = {
            type = "craft-item",
            item = "iron-plate",
            count = 10,
        },
    },
    {
        type = "technology",
        name = "basic-logistics",
        icon = "__base__/graphics/technology/logistics-1.png",
        icon_size = 256,
        order = "a",
        prerequisites = {"burner-mechanics"},
        research_trigger = {
            type = "craft-item",
            item = "motor",
            count = 50,
        },
    },
    {
        type = "technology",
        name = "electricity",
        icon = "__base__/graphics/technology/electric-engine.png",
        icon_size = 256,
        order = "a",
        prerequisites = {settings.startup["aai-fuel-processor"].value and "fuel-processing" or "automation-science-pack"},
        unit = {
            count = 50,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "basic-fluid-handling",
        icon = "__base__/graphics/technology/fluid-handling.png",
        icon_size = 256,
        order = "a",
        prerequisites = {"electricity"},
        unit = {
            count = 50,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "electric-lab",
        icon = "__aai-industry__/graphics/technology/electric-lab.png",
        icon_size = 256,
        order = "a",
        prerequisites = {"electronics", "glass-processing"},
        unit = {
            count = 100,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "concrete-walls",
        icon = "__base__/graphics/technology/stone-wall.png",
        icon_size = 256,
        order = "b",
        prerequisites = {"stone-wall", "concrete"},
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 20
        },
    },
    {
        type = "technology",
        name = "steel-walls",
        icon = "__base__/graphics/technology/stone-wall.png",
        icon_size = 256,
        order = "c",
        prerequisites = {"concrete-walls", "military-science-pack"},
        unit = {
            count = 300,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "concrete-gates",
        localised_description = {"technology-description.gates"},
        icon = "__base__/graphics/technology/gate.png",
        icon_size = 256,
        order = "b",
        prerequisites = {"concrete-walls", "gate", "advanced-circuit", "military-science-pack"},
        unit = {
            count = 200,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "steel-gates",
        localised_description = {"technology-description.gates"},
        icon = "__base__/graphics/technology/gate.png",
        icon_size = 256,
        order = "c",
        prerequisites = {"steel-walls", "concrete-gates", "processing-unit"},
        unit = {
            count = 300,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
                {"military-science-pack", 1},
                {"chemical-science-pack", 1},
            },
            time = 30
        },
    },
    {
        type = "technology",
        name = "sand-processing",
        icon = "__aai-industry__/graphics/technology/sand-processing.png",
        icon_size = 256,
        order = "a",
        prerequisites = {"automation-science-pack"},
        unit = {
            count = 10,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "glass-processing",
        icon = "__aai-industry__/graphics/technology/glass-processing.png",
        icon_size = 256,
        order = "a",
        prerequisites = {"sand-processing"},
        unit = {
            count = 40,
            ingredients = {
                {"automation-science-pack", 1},
            },
            time = 10
        },
    },
    {
        type = "technology",
        name = "medium-electric-pole",
        icon =  data.raw.technology["electric-energy-distribution-1"].icon,
        icon_size = 256,
        order = "a",
        prerequisites = {"steel-processing", "electricity", "logistic-science-pack"},
        unit = {
            count = 75,
            ingredients = {
                {"automation-science-pack", 1},
                {"logistic-science-pack", 1},
            },
            time = 30
        },
    },
}
