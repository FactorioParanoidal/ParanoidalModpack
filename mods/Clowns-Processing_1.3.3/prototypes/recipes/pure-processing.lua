local rawmulti = angelsmods.marathon.rawmulti
if mods["Clowns-Extended-Minerals"] then
	data:extend(
	{
		{
			type = "recipe",
			name = "manganese-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore6-crushed", amount=2},
					{type="item", name="angels-ore2-crushed", amount=2},
					{type="item", name="catalysator-brown", amount=1},
				},
				results =
				{
					{type="item", name="manganese-ore", amount=4},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore6-crushed", amount=3 * rawmulti},
					{type="item", name="angels-ore2-crushed", amount=3 * rawmulti},
					{type="item", name="catalysator-brown", amount=1},
				},
				results =
				{
					{type="item", name="manganese-ore", amount=4},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__angelssmelting__/graphics/icons/ore-manganese.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
		{
			type = "recipe",
			name = "phosphorus-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore5-crushed", amount=2},
					{type="item", name="angels-ore6-crushed", amount=2},
					{type="item", name="catalysator-brown", amount=1},
				},
				results =
				{
					{type="item", name="phosphorus-ore", amount=4},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore5-crushed", amount=3 * rawmulti},
					{type="item", name="angels-ore6-crushed", amount=3 * rawmulti},
					{type="item", name="catalysator-brown", amount=1},
				},
				results =
				{
					{type="item", name="phosphorus-ore", amount=4},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__Clowns-Processing__/graphics/icons/phosphorus-ore.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
		{
			type = "recipe",
			name = "chrome-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore7-crystal", amount=2},
					{type="item", name="angels-ore1-crystal", amount=2},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="chrome-ore", amount=4},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore7-crystal", amount=3 * rawmulti},
					{type="item", name="angels-ore1-crystal", amount=3 * rawmulti},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="chrome-ore", amount=4},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__angelssmelting__/graphics/icons/ore-chrome.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
		{
			type = "recipe",
			name = "magnesium-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore4-chunk", amount=2},
					{type="item", name="clowns-resource1", amount=20},
					{type="item",name="angels-ore3-chunk",amount=2},
					{type="item",name="angels-ore4-chunk",amount=2},
					{type="item", name="catalysator-green", amount=1},
				},
				results =
				{
					{type="item", name="magnesium-ore", amount=6},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore4-chunk", amount=3*rawmulti},
					{type="item", name="clowns-resource1", amount=30*rawmulti},
					{type="item",name="angels-ore3-chunk",amount=3*rawmulti},
					{type="item",name="angels-ore4-chunk",amount=3*rawmulti},
					{type="item", name="catalysator-green", amount=1},
				},
				results =
				{
					{type="item", name="magnesium-ore", amount=6},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
		{
			type = "recipe",
			name = "platinum-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore2-pure", amount=2},
					{type="item", name="angels-ore4-pure", amount=2},
					{type="item", name="angels-ore5-pure", amount=2},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="platinum-ore", amount=6},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore2-pure", amount=3 * rawmulti},
					{type="item", name="angels-ore4-pure", amount=3 * rawmulti},
					{type="item", name="angels-ore5-pure", amount=3 * rawmulti},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="platinum-ore", amount=6},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__angelssmelting__/graphics/icons/ore-platinum.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
		{
			type = "recipe",
			name = "osmium-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore1-pure", amount=2},
					{type="item", name="angels-ore1-pure", amount=2},
					{type="item", name="angels-ore4-pure", amount=2},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="osmium-ore", amount=6},
				},
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore1-pure", amount=3 * rawmulti},
					{type="item", name="angels-ore1-pure", amount=3 * rawmulti},
					{type="item", name="angels-ore4-pure", amount=3 * rawmulti},
					{type="item", name="catalysator-orange", amount=1},
				},
				results =
				{
					{type="item", name="osmium-ore", amount=6},
				},
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__Clowns-Processing__/graphics/icons/osmium-ore.png",
					scale = 0.5,
					shift = {8, 8},
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		},
	}
)
end

if mods["Clowns-Extended-Minerals"] and mods["Clowns-Nuclear"] then
	data:extend(
	{
		{
			type = "recipe",
			name = "thorium-pure-processing",
			category = "ore-sorting",
			subgroup = "ore-sorting-advanced",
			energy_required = 1.5,
			allow_decomposition = false,
			normal =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore3-crystal", amount=2},
					{type="item", name="angels-ore2-crystal", amount=2},
					{type="item", name="angels-ore5-crystal", amount=2},
					{type="item", name="catalysator-orange", amount=1}
				},
				results =
				{
					{type="item", name="thorium-ore", amount=3}
				}
			},
			expensive =
			{
				enabled = false,
				ingredients =
				{
					{type="item", name="clowns-ore3-crystal", amount=3 * rawmulti},
					{type="item", name="angels-ore2-crystal", amount=3 * rawmulti},
					{type="item", name="angels-ore5-crystal", amount=3 * rawmulti},
					{type="item", name="catalysator-orange", amount=1}
				},
				results =
				{
					{type="item", name="thorium-ore", amount=3}
				}
			},
			icons =
			{
				{
					icon = "__Clowns-Processing__/graphics/icons/sorting.png"
				},
				{
					icon = "__Clowns-Nuclear__/graphics/icons/ore-5.png",
					scale = 0.5,
					shift = {8, 8},
					tint = {r = 1, g = 1, b = 0.25}
				},

			},
			icon_size = 32,
			order = "o-a"--Just after Uranium
		}
	}
)
end
