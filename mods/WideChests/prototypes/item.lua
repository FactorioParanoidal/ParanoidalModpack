data:extend({
	{
		type = 'selection-tool',
		name = MergingChests.merge_selection_tool_name,
		icon = '__WideChests__/graphics/icons/merge-chest-selector.png',
		icon_size = 32,
		subgroup = 'tool',
		order = 'c[automated-construction]-a[merge-chest]',
		stack_size = 1,
		draw_label_for_cursor_render = true,
		selection_color = { r = 0, g = 0, b = 1 },
		alt_selection_color = { r = 1, g = 0, b = 0 },
		flags = { 'only-in-cursor', 'spawnable' },
		select = {
			border_color = {0, 0, 1},
			cursor_box_type = 'entity',
			mode = 'deconstruct',
			entity_filters = {}
		},
		alt_select = {
			border_color = {1, 0, 0},
			cursor_box_type = 'entity',
			mode = 'deconstruct',
			entity_filters = {}
		}
	}
})
