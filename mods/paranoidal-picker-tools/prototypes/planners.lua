-- custom input for the planner menu
data:extend{{
    type = 'custom-input',
    name = 'picker-planner-menu',
    key_sequence = 'CONTROL + B',
    consuming = 'none'
}}

-- custom input for the planner cycler
data:extend{{
    type = 'custom-input',
    name = 'picker-next-planner',
    key_sequence = 'ALT + Q',
    consuming = 'none'
}}

-- Tape Measure -- Quick way to get bounding box sizes and distances.
if settings.startup['picker-tool-tape-measure'].value then
    data:extend{{
        type = 'selection-tool',
        name = 'picker-tape-measure',
        icon = '__paranoidal-picker-tools__/graphics/tape-measure-2.png',
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
    }}
end