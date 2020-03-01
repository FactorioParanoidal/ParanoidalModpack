if settings.startup['picker-tool-pipe-clamps'].value then
    data:extend {
        {
            type = 'selection-tool',
            name = 'picker-pipe-clamper',
            icon = '__PickerPipeTools__/graphics/icons/hr-lock.png',
            icon_size = 64,
            flags = {'hidden', 'only-in-cursor'},
            subgroup = 'tool',
            order = 'c[selection-tool]-a[pipe-cleaner]',
            stack_size = 1,
            stackable = false,
            selection_color = {r = 1, g = 0, b = 0},
            alt_selection_color = {r = 0, g = 1, b = 0},
            selection_mode = {'buildable-type', 'items-to-place'},
            alt_selection_mode = {'buildable-type', 'items-to-place'},
            selection_cursor_box_type = 'copy',
            alt_selection_cursor_box_type = 'copy',
            always_include_tiles = false,
            show_in_library = true
        }
    }
end
