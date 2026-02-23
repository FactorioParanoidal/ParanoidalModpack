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
				{type="item",name="artillery-shell", amount=1},
				{type="item",name="atomic-bomb",amount= 1}
			},
			results = {{type="item",name="artillery-shell-nuclear", amount=1}}
		},

		{
			type = "recipe",
			name = "artillery-shell-thermonuclear",
			enabled = false,
			energy_required = 50,
			ingredients =
			{
				{type="item",name="artillery-shell", amount=1},
				{type="item",name="thermonuclear-bomb",amount= 1}
			},
			results = {{type="item",name="artillery-shell-thermonuclear", amount=1}}
		},
	}
	)
end