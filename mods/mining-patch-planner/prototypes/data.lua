local graphics = "__mining-patch-planner__/graphics/"

data:extend{
	{
		type="selection-tool",
		name="mining-patch-planner",
		icon=graphics.."drill-icon.png",
		icon_size = 64,
		flags = {"only-in-cursor", "spawnable", "not-stackable"},
		-- hidden_in_factoriopedia = true,
		hidden = true,
		stack_size = 1,
		order="c[automated-construction]-e[miner-planner]",
		draw_label_for_cursor_render = false,
		-- selection_cursor_box_type="entity",
		select = {
			border_color = {r=100/255, g=149/255, b=237/255, a=1},
			cursor_box_type = "entity",
			mode = "any-entity",
			entity_filter_mode = "whitelist",
			entity_type_filters = {"resource"},
			tile_filter_mode = "whitelist",
			tile_filters = {"water-wube"},
		},
		alt_select = {
			border_color = {r=237/255, g=149/255, b=100/255, a=1},
			cursor_box_type = "entity",
			mode = "any-entity",
			entity_filter_mode = "whitelist",
			entity_type_filters = {"resource"},
			tile_filter_mode = "whitelist",
			tile_filters = {"water-wube"},
		}
		-- selection_mode={"any-entity"},
		-- entity_filter_mode="whitelist",
		-- entity_type_filters = {"resource"},
		-- tile_filter_mode = "whitelist",
		-- tile_filters = {"water-wube"},
		-- alt_selection_color = {r=0, g=1, b=0, a=1},
		-- alt_selection_cursor_box_type="entity",
		-- alt_selection_mode={"any-entity"},
		-- alt_tile_filter_mode = "whitelist",
		-- alt_tile_filters = {"water-wube"},
		-- alt_entity_filter_mode="whitelist",
		-- alt_entity_type_filters = {"resource"},
		-- reverse_selection_mode={"any-entity"},
		-- reverse_selection_cursor_box_type="pair",
		-- reverse_entity_filter_mode="whitelist",
		-- reverse_entity_type_filters = {"resource"},
		-- reverse_tile_filters = {"water-wube" },
	},
	{
		type="custom-input",
		name="mining-patch-planner-keybind",
		key_sequence="CONTROL + M",
		action="spawn-item",
		item_to_spawn="mining-patch-planner",
	},
	{
		type="custom-input",
		name="mining-patch-planner-keybind-rotate",
		key_sequence="R",
		action="lua",
		include_selected_prototype = true,
	},
	{
		type="custom-input",
		name="mining-patch-planner-keybind-rotate-reversed",
		key_sequence="SHIFT + R",
		action="lua",
		include_selected_prototype = true,
	},
	{
		type="shortcut",
		name="mining-patch-planner-shortcut",
		icon = graphics.."drill-icon-toolbar-white.png",
		-- icon={
		-- 	filename=graphics.."drill-icon-toolbar-white.png",
		-- 	priority = "extra-high-no-scale",
		-- 	size=32,
		-- 	flags={"gui-icon"}
		-- },
		small_icon = graphics.."drill-icon-toolbar-white.png",
		-- small_icon={
		-- 	filename=graphics.."drill-icon-toolbar-white.png",
		-- 	priority = "extra-high-no-scale",
		-- 	size=32,
		-- 	scale=1,
		-- 	flags={"gui-icon"}
		-- },
		-- disabled_small_icon={
		-- 	filename=graphics.."drill-icon-toolbar-disabled.png",
		-- 	priority = "extra-high-no-scale",
		-- 	size=32,
		-- 	scale=1,
		-- 	flags={"gui-icon"}
		-- },
		order="b[blueprints]-i[miner-planner]",
		action = "spawn-item",
		icon_size = 32,
		small_icon_size = 32,
		item_to_spawn="mining-patch-planner",
		style="blue",
		associated_control_input="mining-patch-planner-keybind",
	},
}

local mpp_blueprint = table.deepcopy(data.raw["blueprint"]["blueprint"]) --[[@as data.BlueprintItemPrototype]]

mpp_blueprint.name = "mpp-blueprint-belt-planner"
mpp_blueprint.hidden = true
mpp_blueprint.hidden_in_factoriopedia = true
mpp_blueprint.auto_recycle = false
mpp_blueprint.flags = mpp_blueprint.flags or {}
table.insert(mpp_blueprint.flags, "only-in-cursor")

data.extend{mpp_blueprint}
