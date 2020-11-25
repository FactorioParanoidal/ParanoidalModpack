data:extend{
	{
		type = "technology",
		name = "enable-logistics-tab",
		icon_size = 256,
		icon = "__even-distribution__/graphics/tech.png",
		effects =
		{
		  {
			type = "character-logistic-requests",
			modifier = true
		  },
		  {
			type = "character-logistic-trash-slots",
			modifier = 10
		  }
		},
		unit =
		{
		  count = 1,
		  ingredients = {},
		  time = 1,
		},
		order = "zzzz",
	  },
}

-- remove additional trash slots, so we have the default 30 slots
local tech = data.raw.technology["logistic-robotics"]
if tech and tech.effects then
	for i,effect in pairs(tech.effects) do
		if effect.type == "character-logistic-trash-slots" and effect.modifier and effect.modifier > 10 then
			effect.modifier = effect.modifier - 10
			break
		end
	end
end