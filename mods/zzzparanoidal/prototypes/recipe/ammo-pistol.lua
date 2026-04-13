data:extend({
	--патроны из пистолета
	{
		type = "recipe",
		name = "pistol-rearm-ammo",
		energy_required = 5,
		-- enabled = true,
		ingredients = { { type = "item", name = "pistol", amount = 1 } },
		results = {
			{ type = "item", name = "firearm-magazine", amount = 3 },
		},
	},
})
