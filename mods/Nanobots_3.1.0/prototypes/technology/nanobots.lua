local tech1 = {
    type = 'technology',
    name = 'nanobots',
    icon = '__Nanobots__/graphics/technology/tech-nanobots.png',
    icon_size = 128,
    effects = {},
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
