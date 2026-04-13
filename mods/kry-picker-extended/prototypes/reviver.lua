data:extend{
	-- Shortcut adds the button to the shortcut bar
    {
		type = "shortcut",
		name = 'toggle-ghost-revive',
		order = "c[toggles]-g[ghost-revive]",
		icon = "__kry-picker-extended__/graphics/icons/ghost-revive-x56.png",
		icon_size = 56,
		small_icon = "__kry-picker-extended__/graphics/icons/ghost-revive-x24.png",
		small_icon_size = 24,
		action = "lua",
		-- this links the hotkey to the shortcut
		associated_control_input = "toggle-ghost-revive",
		toggleable = true,
    },
	-- Custom input adds the hotkey to the list of controls
    {
		type = 'custom-input',
		name = 'toggle-ghost-revive',
		key_sequence = 'SHIFT + G',
        consuming = "none",
    }
 }
 