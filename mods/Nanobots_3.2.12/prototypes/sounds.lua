local Data = require('__stdlib__/stdlib/data/data')

-- TODO switch to sound type
local sound_creators = {
    type = 'explosion',
    name = 'nano-sound-build-tiles',
    flags = {'not-on-map'},
    rotate = false,
    animations = Data.Sprites.empty_animations(),
    sound = {
        aggregation = {
            max_count = 1,
            remove = true
        },
        variations = {
            {
                filename = '__base__/sound/walking/grass-01.ogg',
                volume = 1.0
            },
            {
                filename = '__base__/sound/walking/grass-02.ogg',
                volume = 1.0
            },
            {
                filename = '__base__/sound/walking/grass-03.ogg',
                volume = 1.0
            },
            {
                filename = '__base__/sound/walking/grass-04.ogg',
                volume = 1.0
            }
        }
    }
}

local sound_deconstruct = {
    type = 'explosion',
    name = 'nano-sound-deconstruct',
    flags = {'not-on-map'},
    rotate = false,
    animations = Data.Sprites.empty_animations(),
    sound = {
        aggregation = {
            max_count = 3,
            remove = true
        },
        filename = '__core__/sound/deconstruct-small.ogg',
        volume = 0.5
    }
}

local sound_repair = {
    type = 'explosion',
    name = 'nano-sound-repair',
    flags = {'not-on-map'},
    rotate = false,
    animations = Data.Sprites.empty_animations(),
    sound = {
        aggregation = {
            max_count = 1,
            remove = true
        },
        filename = '__core__/sound/manual-repair-advanced-1.ogg',
        volume = 0.15
    }
}

local sound_termites = {
    type = 'explosion',
    name = 'nano-sound-termite',
    rotate = false,
    flags = {'not-on-map'},
    animations = Data.Sprites.empty_animations(),
    sound = {
        aggregation = {
            max_count = 1,
            remove = true
        },
        filename = '__Nanobots__/sounds/sawing-wood.ogg',
        volume = 0.15
    }
}

data:extend({sound_creators, sound_deconstruct, sound_repair, sound_termites})
