local tech1 = {
    type = 'technology',
    name = 'nanobots',
    icon = '__Nanobots__/graphics/technology/tech-nanobots.png',
    icon_size = 128,
    effects = {
        {
            type = "ghost-time-to-live",
            modifier = 60 * 60 * 60 * 24 * 7
        }
    },
    prerequisites = {'logistics'},
    unit = {
        count = 30,
        ingredients = {
            {'automation-science-pack', 1}
        },
        time = 30
    },
    order = 'a-b-ab'
}
data:extend {tech1}

local tech2 = {
    type = 'technology',
    name = 'nanobots-cliff',
    icon = '__Nanobots__/graphics/technology/tech-nanobots-cliff.png',
    icon_size = 128,
    effects = {},
    prerequisites = {'nanobots'},
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
data:extend {tech2}
