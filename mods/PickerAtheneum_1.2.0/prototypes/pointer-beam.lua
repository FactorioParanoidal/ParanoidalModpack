local Data = require('__stdlib__/stdlib/data/data')

local marker_beams = Data('electric-beam-no-sound', 'beam'):copy('picker-pointer-beam')

marker_beams.width = 1.0
marker_beams.damage_interval = 2000000000
marker_beams.action = nil
marker_beams.start = Data.Sprites.empty_pictures()
marker_beams.start_light = Data.Sprites.empty_picture()
marker_beams.ending = Data.Sprites.empty_pictures()
marker_beams.ending_light = Data.Sprites.empty_picture()
marker_beams.head = {
    filename = '__PickerAtheneum__/graphics/markers/beam-arrow.png',
    line_length = 1,
    width = 64,
    height = 64,
    frame_count = 1,
    animation_speed = 1,
    scale = 0.5
}
marker_beams.head_light = Data.Sprites.empty_picture()
marker_beams.tail = {
    filename = '__PickerAtheneum__/graphics/markers/beam-arrow.png',
    line_length = 1,
    width = 64,
    height = 64,
    frame_count = 1,
    animation_speed = 1,
    scale = 0.5
}
marker_beams.tail_light = Data.Sprites.empty_picture()
marker_beams.body = Data.Sprites.empty_animations()
marker_beams.body_light = Data.Sprites.empty_animations()
