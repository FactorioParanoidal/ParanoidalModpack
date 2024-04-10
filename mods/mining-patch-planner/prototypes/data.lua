local graphics = "__mining-patch-planner__/graphics/"

data:extend{
	{
		type="selection-tool",
		name="mining-patch-planner",
		icon=graphics.."drill-icon.png",
		icon_size = 64,
		flags = {"only-in-cursor", "hidden", "spawnable", "not-stackable"},
		stack_size = 1,
		order="c[automated-construction]-e[miner-planner]",
		draw_label_for_cursor_render = false,
		selection_color = {r=0, g=0, b=1, a=0.5},
		selection_cursor_box_type="entity",
		selection_mode={"any-entity"},
		entity_filter_mode="whitelist",
		entity_type_filters = {"resource"},
		tile_filter_mode = "whitelist",
		tile_filters = {"water-wube"},
		alt_selection_color = {r=0, g=0, b=1, a=0.5},
		alt_selection_cursor_box_type="entity",
		alt_selection_mode={"any-entity"},
		reverse_selction_color = {1, 1, 0, 1},
		reverse_selection_mode={"any-entity"},
		reverse_selection_cursor_box_type="pair",
		reverse_entity_filter_mode="whitelist",
		reverse_entity_type_filters = {"resource"},
		reverse_tile_filters = {"water-wube" },
	},
	{
		type="custom-input",
		name="mining-patch-planner-keybind",
		key_sequence="CONTROL + M",
		action="spawn-item",
		item_to_spawn="mining-patch-planner",
	},
	{
		type="shortcut",
		name="mining-patch-planner-shortcut",
		icon={
			filename=graphics.."drill-icon-toolbar-white.png",
			priority = "extra-high-no-scale",
			size=32,
			flags={"gui-icon"}
		},
		small_icon={
			filename=graphics.."drill-icon-toolbar-white.png",
			priority = "extra-high-no-scale",
			size=32,
			scale=1,
			flags={"gui-icon"}
		},
		disabled_small_icon={
			filename=graphics.."drill-icon-toolbar-disabled.png",
			priority = "extra-high-no-scale",
			size=32,
			scale=1,
			flags={"gui-icon"}
		},
		order="b[blueprints]-i[miner-planner]",
		action = "spawn-item",
		icon_size = 64,
		item_to_spawn="mining-patch-planner",
		style="blue",
		associated_control_input="mining-patch-planner-keybind",
	},
}
