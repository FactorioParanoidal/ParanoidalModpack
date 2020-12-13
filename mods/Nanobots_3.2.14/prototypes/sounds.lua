local Data = require('__stdlib__/stdlib/data/data')

Data{
    type = 'sound',
    name = 'nano-sound-build-tiles',
    aggregation = {max_count = 3, remove = true, count_already_playing = true},
    variations = {
        {filename = '__base__/sound/walking/grass-01.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-02.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-03.ogg', volume = 1.0},
        {filename = '__base__/sound/walking/grass-04.ogg', volume = 1.0}
    }
}
