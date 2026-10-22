data:extend(
{
	{
		type = 'shortcut',
		name = MergingChests.merge_shortcut_name,
		order = 'b[blueprints]-c[merge-chests]',
		action = 'spawn-item',
		item_to_spawn = MergingChests.merge_selection_tool_name,
		-- Paranoidal: стальной сундук в рамке вместо буквы M.
		icon = '__WideChests__/graphics/icons/merge-shortcut-64.png',
		icon_size = 64,
		small_icon = '__WideChests__/graphics/icons/merge-shortcut-32.png',
		small_icon_size = 32,
		associated_control_input = MergingChests.custom_input_names.merge_tool
	}
})
