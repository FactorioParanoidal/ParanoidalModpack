local Data = require('__stdlib2__/stdlib/data/data')

Data{
    type = 'sound',
    name = 'nano-sound-build-tiles',
    aggregation = {max_count = 3, remove = true, count_already_playing = true},
    variations = {
        {filename = '__base__/sound/walking/grass-1.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-2.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-3.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-4.ogg', volume = 1.0}
    }
}

Data{
    type = 'sound',
    name = 'nano-sound-complete',
    aggregation = {max_count = 1, remove = true, count_already_playing = true, priority = "oldest"},
    priority = 50,
    audible_distance_modifier = 0.1,
    filename = '__nanobots-refined__/sounds/din-ding.ogg'
}

Data{
    type = 'sound',
    name = 'nano-sound-error',
    aggregation = {max_count = 1, remove = true, count_already_playing = true, priority = "oldest"},
    priority = 50,
    audible_distance_modifier = 0.1,
    filename = '__nanobots-refined__/sounds/error-buzz.ogg'
}