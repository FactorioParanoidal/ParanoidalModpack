-- recipe/decoratives

if DECT.ENABLED["decoratives"] then

	data:extend({
		{
			type = "recipe",
			name = "dect-traffic-bollard",
			enabled = false,
			ingredients = {
				{type = "item", name = "plastic-bar", amount = 2},
				{type = "item", name = "iron-plate", amount = 1},
			},
			results = {
				{type = "item", name = "dect-traffic-bollard", amount = 1},
			}
		}
	})

end
