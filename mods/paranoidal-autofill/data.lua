local PATH = "__paranoidal-autofill__/graphics/"

data:extend({
	{
		-- Top panel button, same size as the GUI Unifier buttons (64 px at scale 0.5).
		type = "sprite",
		name = "paranoidal-autofill-button",
		filename = PATH .. "button.png",
		width = 64,
		height = 64,
		scale = 0.5,
		flags = { "gui-icon" },
		priority = "extra-high-no-scale",
	},
	{
		type = "custom-input",
		name = "paranoidal-autofill-refill",
		key_sequence = "SHIFT + ALT + F",
		consuming = "none",
	},
	{
		type = "shortcut",
		name = "paranoidal-autofill-refill",
		order = "z[paranoidal-autofill]",
		action = "lua",
		associated_control_input = "paranoidal-autofill-refill",
		icon = PATH .. "shortcut-56.png",
		icon_size = 56,
		small_icon = PATH .. "shortcut-24.png",
		small_icon_size = 24,
	},
})
