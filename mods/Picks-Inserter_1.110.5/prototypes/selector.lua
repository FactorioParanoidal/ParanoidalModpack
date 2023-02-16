--[[ Copyright (c) 2019 - 2023 Picklock
 * Part of Picklocks Inserter
 * selector.lua
 * Version 1.110.5.53
 *
 * See LICENSE.MD in the project directory for license information.
--]]

--selector
	--item
		local mySelItem=
		{
			type = "selection-tool",
			name = "PI_inserter_selector",
			icon = myModName.."/graphics/icons/PI_selector_item.png",
			icon_size = 64, icon_mipmaps = 4,
			--flags = {"only-in-cursor", "hidden"}, -- bis V1.0
			flags = {"only-in-cursor", "hidden", "spawnable"}, -- ab V1.1
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
				--item_to_create="PI_inserter_selector", -- bis V1.0
				item_to_spawn="PI_inserter_selector", -- ab V1.1
				consuming = "none"
		}
	
	--shortcut
		local mySelShortcut=
		{
				type = "shortcut",
				name = "PI_inserter_selector_ui_sc",
				order = "a[alt-mode]-b[copy]",
				action = "lua",
				--item_to_create="PI_inserter_selector", -- bis V1.0
				item_to_spawn="PI_inserter_selector", -- ab V1.1
				localised_name = {"PicksInserter.PI_inserter_selector_ui_sc"},
				toggleable = true,
				icon = {
					filename = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x32.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					mipmap_count = 2,
					flags = {"gui-icon"}
				},
				small_icon = {
					filename = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x24.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 0.5,
					mipmap_count = 2,
					flags = {"gui-icon"}
				},
				disabled_icon = {
					filename = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x32_dis.png",
					priority = "extra-high-no-scale",
					size = 32,
					scale = 0.5,
					mipmap_count = 2,
					flags = {"gui-icon"}
				},
				disabled_small_icon = {
					filename = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x24_dis.png",
					priority = "extra-high-no-scale",
					size = 24,
					scale = 0.5,
					mipmap_count = 2,
					flags = {"gui-icon"}
				}
		}
	
	data:extend({mySelItem, mySelRecipe, mySelHotkey, mySelShortcut})

