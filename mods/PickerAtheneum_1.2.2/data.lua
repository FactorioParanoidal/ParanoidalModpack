local Data = require('__stdlib__/stdlib/data/data')

require('prototypes/adjustment-pad')
require('prototypes/styles')
require('prototypes/pointer-beam')

Data {
    type = 'flying-text',
    name = 'picker-flying-text',
    flags = {'placeable-off-grid', 'not-on-map'},
    time_to_live = 150,
    speed = 0.05
}

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

Data('blueprint', 'blueprint'):copy('picker-blueprint-tool'):set_fields {
    draw_label_for_cursor_render = true,
    show_in_library = false,
    flags = {'hidden', 'only-in-cursor'},
    order = 'c[automated-construction]-a[blueprint]-no-picker'
}

Data('deconstruction-planner', 'deconstruction-item'):copy('picker-deconstruction-tool'):set_fields {
    flags = {'hidden', 'only-in-cursor'},
    show_in_library = false,
    order = 'c[automated-construction]-a[construction]-no-picker'
}
