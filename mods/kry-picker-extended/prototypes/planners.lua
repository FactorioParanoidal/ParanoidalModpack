local Data = require('__kry_stdlib__/stdlib/data/data')

-- custom input for the planner menu
Data {
    type = 'custom-input',
    name = 'picker-planner-menu',
    key_sequence = 'CONTROL + B',
    consuming = 'none'
}

-- custom input for the planner cycler
Data {
    type = 'custom-input',
    name = 'picker-next-planner',
    key_sequence = 'ALT + Q',
    consuming = 'none'
}

-- Tape Measure -- Quick way to get bounding box sizes and distances.
if settings.startup['picker-tool-tape-measure'].value then
    Data {
        type = 'selection-tool',
        name = 'picker-tape-measure',
        icon = '__kry-picker-extended__/graphics/tape-measure-2.png',
        icon_size = 64,
        flags = {'only-in-cursor', 'not-stackable'},
        subgroup = 'tool',
        order = 'c[selection-tool]-a[tape-measure]',
        stack_size = 1,
        always_include_tiles = true,
        hidden = true,
		select =
		{
		  border_color = {r = 0, g = 1, b = 0},
		  mode = {"any-tile"},
		  cursor_box_type = "copy",
		},
		alt_select =
		{
		  border_color = {r = 0, g = 1, b = 0},
		  mode = {"any-tile"},
		  cursor_box_type = "copy",
		},
    }
end