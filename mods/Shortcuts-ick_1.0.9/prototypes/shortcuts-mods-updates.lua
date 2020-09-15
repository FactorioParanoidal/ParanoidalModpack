if mods["Orbital Ion Cannon"] and data.raw.item["ion-cannon-targeter"] and settings.startup["ion-cannon-targeter"].value == true then
	data:extend(
	{
		{
			type = "shortcut",
			name = "ion-cannon-targeter",
			order = "e[mods]-c[ion-cannon-targeter]",
			action = "lua",
			localised_name = {"item-name.ion-cannon-targeter"},
			style = "red",
			icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x32-white.png",
				priority = "extra-high-no-scale",
				size = 32,
				scale = 1,
				flags = {"icon"}
			},
			small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x24.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
			disabled_small_icon =
			{
				filename = "__Shortcuts-ick__/graphics/ion-cannon-targeter-x24-white.png",
				priority = "extra-high-no-scale",
				size = 24,
				scale = 1,
				flags = {"icon"}
			},
		}
	})
end
