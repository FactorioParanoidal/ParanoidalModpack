data:extend({
{
    type = 'selection-tool',
    name = 'hero_downgrade',
    flags = {'hidden', 'only-in-cursor'},
    --subgroup = 'transport',
    stack_size = 1,
    --order = 'a[train-system]-w[naked-rails-nakedify]',
    selection_color = {r = 0, g = 0, b = 1, a = 0.2},
    alt_selection_color = {r = 0, g = 0, b = 0.5, a = 0.2},
    selection_mode = {'buildable-type'},
    alt_selection_mode = {'buildable-type'},
    selection_cursor_box_type = 'entity',
    alt_selection_cursor_box_type = 'copy',
    icon = "__base__/graphics/icons/tank-cannon.png",
    icon_size = 64, icon_mipmaps = 4,
}
})