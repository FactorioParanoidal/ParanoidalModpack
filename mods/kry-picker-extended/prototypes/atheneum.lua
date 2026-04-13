-- this was originally part of the Picker Atheneum's data.lua
-- some part of these lines were needed to for Belt Brush functionality

local Data = require('__kry_stdlib__/stdlib/data/data')

Data {
    type = 'highlight-box',
    name = 'picker-highlight-box'
}

Data {
    name = 'picker-buffer-corpse-instant',
    type = 'character-corpse',
    picture = Data.Sprites.empty_pictures(),
    selection_priority = 0,
    time_to_live = 1
}

Data {
    name = 'picker-buffer-corpse-inf',
    type = 'character-corpse',
    picture = Data.Sprites.empty_pictures(),
    selection_priority = 0,
    time_to_live = 2147483647
}