local tech1 = {
    type = 'technology',
    name = 'nano-range-1',
    icon = '__Nanobots__/graphics/technology/tech-nano-range.png',
    icon_size = 128,
    effects = {
        {
            type = 'ammo-damage',
            ammo_category = 'nano-ammo',
            modifier = '1'
        }
    },
    prerequisites = {'nanobots'},
    unit = {
        count = 100,
        ingredients = {
            {'automation-science-pack', 1}
        },
        time = 30
    },
    order = 'a-b-ab',
    upgrade = true
}

local tech2 = {
    type = 'technology',
    name = 'nano-range-2',
    icon = '__Nanobots__/graphics/technology/tech-nano-range.png',
    icon_size = 128,
    effects = {
        {
            type = 'ammo-damage',
            ammo_category = 'nano-ammo',
            modifier = '1'
        }
    },
    prerequisites = {'engine', 'nano-range-1'},
    unit = {
        count = 100,
        ingredients = {
            {'automation-science-pack', 1},
            {'logistic-science-pack', 1}
        },
        time = 60
    },
    order = 'a-b-ac',
    upgrade = true
}

local tech3 = {
    type = 'technology',
    name = 'nano-range-3',
    icon = '__Nanobots__/graphics/technology/tech-nano-range.png',
    icon_size = 128,
    effects = {
        {
            type = 'ammo-damage',
            ammo_category = 'nano-ammo',
            modifier = '1'
        }
    },
    prerequisites = {'electric-engine', 'nano-range-2'},
    unit = {
        count = 100,
        ingredients = {
            {'automation-science-pack', 3},
            {'logistic-science-pack', 3}
        },
        time = 90
    },
    order = 'a-b-ad',
    upgrade = true
}

local tech4 = {
    type = 'technology',
    name = 'nano-range-4',
    icon = '__Nanobots__/graphics/technology/tech-nano-range.png',
    icon_size = 128,
    effects = {
        {
            type = 'ammo-damage',
            ammo_category = 'nano-ammo',
            modifier = '1'
        }
    },
    prerequisites = {'robotics', 'nano-range-3'},
    unit = {
        count = 100,
        ingredients = {
            {'automation-science-pack', 4},
            {'logistic-science-pack', 4}
            --{"science-pack-3", 4}
        },
        time = 120
    },
    order = 'a-b-ae',
    upgrade = true
}

data:extend({tech1, tech2, tech3, tech4})
