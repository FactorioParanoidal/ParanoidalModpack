--local util = require("__core__/lualib/util")

-- Add keybindings
if isV1 then
	data:extend({
		{   -- SelectionToolPrototype
			type = "selection-tool",
			name = "Kux-BlueprintExtensions_cloned-blueprint",
			icon = "__Kux-BlueprintExtensions__/graphics/icons/cloned-blueprint.png",
			icon_size = 32,
			subgroup = "tool",
			order = "c[automated-construction]-a[blueprint]-no-picker",
			stack_size = 1,
			stackable = false,
			selection_color = { r = 0, g = 1, b = 0 },
			alt_selection_color = { r = 0, g = 1, b = 0 },
			selection_mode = { "blueprint" },
			alt_selection_mode = { "blueprint" },
			selection_cursor_box_type = "copy",
			alt_selection_cursor_box_type = "copy",
			show_in_library = false
		},
	})
elseif isV2 then
	-- TODO FACTORIO 2.0 test this
	data:extend({
		{   -- SelectionToolPrototype
			type = "selection-tool",
			name = "Kux-BlueprintExtensions_cloned-blueprint",
			icon = "__Kux-BlueprintExtensions__/graphics/icons/cloned-blueprint.png",
			icon_size = 32,
			subgroup = "tool",
			order = "c[automated-construction]-a[blueprint]-no-picker",
			stack_size = 1,
			stackable = false,
			select = {
				border_color = { r = 0, g = 1, b = 0 },  -- selection_color
				mode = { "blueprint" },                  -- selection_mode
				cursor_box_type = "copy",                -- selection_cursor_box_type
			},
			alt_select = {
				border_color = { r = 0, g = 1, b = 0 },  -- alt_selection_color
				mode = { "blueprint" },                  -- alt_selection_mode
				cursor_box_type = "copy",                -- alt_selection_cursor_box_type
			},

			--?? show_in_library = false
		},
	})
end

--local bp = util.table.deepcopy(data.raw.blueprint.blueprint)
--bp.name = "BPEX_Test_Blueprint"
--data:extend{bp}
