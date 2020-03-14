if settings.startup["shortcut-tool"].value then
	data:extend(
	{
		{
			type = "shortcut",
			name = "merge-chest-selector",
			order = "b[blueprints]-c[merge-chests]",
			action = "lua",
			icon =
			{
				filename = "__WideChests__/graphics/icons/merge-shortcut.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = { "icon" }
			}
		}
	})
end