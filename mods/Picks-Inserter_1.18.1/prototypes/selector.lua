--[[ Copyright (c) 2019 - 2020 Picklock
 * Part of Picklocks Inserter
 * selector.lua
 * Version 1.18.1.44
 *
 * See LICENSE.MD in the project directory for license information.
--]]

--selector
	--item
		local mySelItem=
		{
			type = "selection-tool",
			name = "PI_inserter_selector",
			icon = "__Picks-Inserter__/graphics/icons/PI_selector.png",
			icon_size = 32,
			flags = {"only-in-cursor", "hidden"},
			stack_size = 10,
			order = "c[automated-construction]-s[selection-tool]-s[PI]",
			selection_color = { r = 0, g = 1, b = 0 },
			alt_selection_color = { r = 0, g = 0.5, b = 1 },
			selection_mode = {"any-entity", "same-force"},
			alt_selection_mode = {"any-entity", "same-force"},
			selection_cursor_box_type = "copy",
			alt_selection_cursor_box_type = "not-allowed"
		}

	--recipe
		local mySelRecipe=
		{
				type = "recipe", 
				name = "PI_inserter_selector", 
				energy_required = 0.1,
				enabled = false,
				ingredients = {}, 
				result = "PI_inserter_selector"
		}
		
	--hotkey
		local mySelHotkey=
		{
				type = "custom-input",
				name = "PI_inserter_selector_ui",
				key_sequence = "SHIFT + I",
				action = "lua",
				--action = "create-blueprint-item",
				item_to_create="PI_inserter_selector",
				consuming = "none"
		}
	
	--shortcut
		local mySelShortcut=
		{
				type = "shortcut",
				name = "PI_inserter_selector_ui_sc",
				order = "a[alt-mode]-b[copy]",
				action = "lua",
				--action = "create-blueprint-item",
				item_to_create="PI_inserter_selector",
				localised_name = {"PicksInserter.PI_inserter_selector_ui_sc"},
				toggleable = true,
				icon = {
					filename = "__Picks-Inserter__/graphics/icons/PI_selector_64.png",
					priority = "extra-high-no-scale",
					width = 64,
					height = 64,
					scale = 1,
					flags = {"icon"}
				},
				small_icon = {
					filename = "__Picks-Inserter__/graphics/icons/PI_selector.png",
					priority = "extra-high-no-scale",
					width = 32,
					height = 32,
					scale = 1,
					flags = {"icon"}
				},
				disabled_icon = {
					filename = "__Picks-Inserter__/graphics/icons/PI_selector_disabled_64.png",
					priority = "extra-high-no-scale",
					width = 64,
					height = 64,
					scale = 1,
					flags = {"icon"}
				},
				disabled_small_icon = {
					filename = "__Picks-Inserter__/graphics/icons/PI_selector_disabled_64.png",
					priority = "extra-high-no-scale",
					width = 64,
					height = 64,
					scale = 1,
					flags = {"icon"}
				}
		}
	
	data:extend({mySelItem, mySelRecipe, mySelHotkey, mySelShortcut})

