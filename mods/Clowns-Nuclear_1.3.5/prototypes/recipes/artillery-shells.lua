if settings.startup["artillery-shells"].value == true then
	data:extend(
	{
		{
			type = "recipe",
			name = "artillery-shell-nuclear",
			enabled = false,
			energy_required = 50,
			ingredients =
			{
				{"artillery-shell", 1},
				{"atomic-bomb", 1}
			},
			result = "artillery-shell-nuclear"
		},

		{
			type = "recipe",
			name = "artillery-shell-thermonuclear",
			enabled = false,
			energy_required = 50,
			ingredients =
			{
				{"artillery-shell", 1},
				{"thermonuclear-bomb", 1}
			},
			result = "artillery-shell-thermonuclear"
		},
	}
	)
end