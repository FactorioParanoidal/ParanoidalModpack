local tech1 = {
    type = 'technology',
    name = 'nanobots',
    icon = '__nanobots-refined__/graphics/technology/tech-nanobots.png',
    icon_size = 254,
    effects = {
        {
            type = "create-ghost-on-entity-death",
            modifier = true
        }
    },
    prerequisites = {'logistics', 'repair-pack'},
    unit = {
        count = 30,
        ingredients = {
            {'automation-science-pack', 1}
        },
        time = 15
    },
    order = 'a-b-ab'
}
data:extend {tech1}

local tech2 = {
    type = 'technology',
    name = 'nanobots-cliff',
    icon = '__nanobots-refined__/graphics/technology/tech-nanobots-cliff.png',
    icon_size = 256,
    effects = {
        {
            type = "cliff-deconstruction-enabled",
            modifier = true
        },
        {
            type = "nothing",
            effect_description = {"modifier-description.nano-explosives"},
            icon = "__nanobots-refined__/graphics/technology/cliff_grenade.png"
        }
    },
    prerequisites = {'nanobots', 'military-2'},
    unit = {
        count = 200,
        ingredients = {
            {'automation-science-pack', 1},
            {'logistic-science-pack', 1}
        },
        time = 30
    },
    order = 'a-b-ac'
}

if settings.startup["nanobots-disable-nano-explosives"].value then
    tech2.hidden = true
end

data:extend {tech2}
