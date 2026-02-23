--[[ Copyright (c) 2019 - 2026 Picklock
 * Part of Picklocks Inserter
 * selector.lua
 * Version 2.1.4.62
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
			icon_size = 64, --icon_mipmaps = 4,
			flags = {"only-in-cursor", "spawnable"}, -- ab V2.0
			stack_size = 10,
			order = "c[automated-construction]-s[selection-tool]-s[PI]",
			select =
			{
				border_color = {0, 1, 0},
				mode = {"any-entity", "same-force"},
				cursor_box_type = "copy",
			},
			alt_select =
			{
				border_color = {0, 0.5, 1},
				mode = {"any-entity", "same-force"},
				cursor_box_type = "not-allowed",
			}
		}

	--recipe
		local mySelRecipe=
		{
				type = "recipe", 
				name = "PI_inserter_selector", 
				energy_required = 0.1,
				enabled = false,
				ingredients = {}, 
				results = {{type="item", name="PI_inserter_selector", amount=1}} -- ab V2.0
		}
		
	--hotkey
		local mySelHotkey=
		{
				type = "custom-input",
				name = "PI_inserter_selector_ui",
				key_sequence = "SHIFT + I",
				action = "lua",
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
				item_to_spawn="PI_inserter_selector", -- ab V1.1
				localised_name = {"PicksInserter.PI_inserter_selector_ui_sc"},
				toggleable = true,
				icon = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x56.png",
				icon_size = 56,
				small_icon = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x56.png",
				small_icon_size = 56,
				disabled_icon = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x56_dis.png",
				disabled_icon_size = 56,
				disabled_small_icon = myModName.."/graphics/icons/shortcut-toolbar/mip/pi_selector_x56_dis.png",
				disabled_small_icon_size = 56,
		}
	
	data:extend({mySelItem, mySelRecipe, mySelHotkey, mySelShortcut})

