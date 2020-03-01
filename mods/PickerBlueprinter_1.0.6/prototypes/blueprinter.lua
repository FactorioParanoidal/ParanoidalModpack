local Data = require('__stdlib__/stdlib/data/data')

local snap = settings.startup['picker-bp-snap'].value or false
local updater = settings.startup['picker-tool-bp-updater'].value or false

Data {
    type = 'custom-input',
    name = 'picker-mirror-blueprint',
    key_sequence = 'ALT + R'
}
Data {
    type = 'custom-input',
    name = 'picker-make-ghost',
    key_sequence = 'CONTROL + Q'
}

--(( Snap Keys ))--
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-n',
    key_sequence = 'PAD 8',
    enabled = snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-e',
    key_sequence = 'PAD 6',
    enabled =  snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-s',
    key_sequence = 'PAD 2',
    enabled =  snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-w',
    key_sequence = 'PAD 4',
    enabled =  snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-nw',
    key_sequence = 'PAD 7',
    enabled =  snap
}

Data {
    type = 'custom-input',
    name = 'picker-bp-snap-ne',
    key_sequence = 'PAD 9',
    enabled =  snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-sw',
    key_sequence = 'PAD 1',
    enabled = snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-se',
    key_sequence = 'PAD 3',
    enabled = snap
}
Data {
    type = 'custom-input',
    name = 'picker-bp-snap-center',
    key_sequence = 'PAD 5',
    enabled = snap
} --))

Data {
    type = 'custom-input',
    name = 'picker-bp-update',
    key_sequence = 'SHIFT + U',
    enabled = updater
}

if updater then
    Data {
        type = 'selection-tool',
        name = 'picker-bp-updater',
        icon = '__PickerBlueprinter__/graphics/cloned-blueprint.png',
        icon_size = 32,
        flags = {'hidden'},
        subgroup = 'tool',
        order = 'c[automated-construction]-a[blueprint-updater]-no-picker',
        stack_size = 1,
        stackable = false,
        selection_color = {r = 0, g = 1, b = 0},
        alt_selection_color = {r = 0, g = 1, b = 0},
        selection_mode = {'blueprint'},
        alt_selection_mode = {'blueprint'},
        selection_cursor_box_type = 'copy',
        alt_selection_cursor_box_type = 'copy',
        show_in_library = false
    }
end
Data {
    type = 'custom-input',
    name = 'picker-add-empty-bp-to-book',
    key_sequence = 'KP_PLUS',
    linked_game_control = 'larger-terrain-building-area'
}
Data {
    type = 'custom-input',
    name = 'picker-clean-empty-bps-in-book',
    key_sequence = 'KP_MINUS',
    linked_game_control = 'smaller-terrain-building-area'
}
