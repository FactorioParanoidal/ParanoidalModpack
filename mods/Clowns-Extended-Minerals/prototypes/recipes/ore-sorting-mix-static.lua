if not clowns.special_vanilla then
	data:extend(
		{
			{
				type = "recipe",
				name = "angels-manganese-pure-processing",
				category = "angels-ore-sorting-2",
				subgroup = "angels-ore-sorting-advanced",
				localised_name = { "item-name.angels-manganese-ore" },
				allow_decomposition = false,
				enabled = false,
				energy_required = 1,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore6-crushed",      amount = 2 },
					{ type = "item", name = "angels-ore2-crushed",      amount = 2 },
					{ type = "item", name = "angels-catalysator-brown", amount = 1 },
				},
				results = {
					{ type = "item", name = "angels-manganese-ore", amount = 4 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png",     icon_size = 32, },
					{ icon = "__angelssmeltinggraphics__/graphics/icons/ore-manganese.png", icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
			{
				type = "recipe",
				name = "clowns-phosphorus-pure-processing",
				localised_name = { "item-name.clowns-phosphorus-ore" },
				category = "angels-ore-sorting",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore5-crushed",      amount = 2 },
					{ type = "item", name = "angels-ore6-crushed",      amount = 2 },
					{ type = "item", name = "angels-catalysator-brown", amount = 1 },
				},
				results = {
					{ type = "item", name = "clowns-phosphorus-ore", amount = 4 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32, },
					{ icon = "__Clowns-Processing__/graphics/icons/phosphorus-ore.png", icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
			{
				type = "recipe",
				name = "angels-chrome-pure-processing",
				localised_name = { "item-name.angels-chrome-ore" },
				category = "angels-ore-sorting-3",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1.5,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore7-crystal",       amount = 2 },
					{ type = "item", name = "angels-ore1-crystal",       amount = 2 },
					{ type = "item", name = "angels-catalysator-orange", amount = 1 },
				},
				results = {
					{ type = "item", name = "angels-chrome-ore", amount = 4 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png",  icon_size = 32, },
					{ icon = "__angelssmeltinggraphics__/graphics/icons/ore-chrome.png", icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
			{
				type = "recipe",
				name = "clowns-magnesium-pure-processing",
				localised_name = { "item-name.clowns-magnesium-ore" },
				category = "angels-ore-sorting-2",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore4-chunk",        amount = 2 },
					{ type = "item", name = "clowns-resource1",         amount = 20 },
					{ type = "item", name = "angels-ore3-chunk",        amount = 2 },
					{ type = "item", name = "angels-ore4-chunk",        amount = 2 },
					{ type = "item", name = "angels-catalysator-green", amount = 1 },
				},
				results = {
					{ type = "item", name = "clowns-magnesium-ore", amount = 6 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32, },
					{ icon = "__Clowns-Processing__/graphics/icons/magnesium-ore.png",  icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
			{
				type = "recipe",
				name = "clowns-platinum-pure-processing",
				localised_name = { "item-name.angels-platinum-ore" },
				category = "angels-ore-sorting-4",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1.5,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore2-pure",          amount = 2 },
					{ type = "item", name = "angels-ore4-pure",          amount = 2 },
					{ type = "item", name = "angels-ore5-pure",          amount = 2 },
					{ type = "item", name = "angels-catalysator-orange", amount = 1 },
				},
				results = {
					{ type = "item", name = "angels-platinum-ore", amount = 6 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png",    icon_size = 32 },
					{ icon = "__angelssmeltinggraphics__/graphics/icons/ore-platinum.png", icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
			{
				type = "recipe",
				name = "clowns-osmium-pure-processing",
				localised_name = { "item-name.clowns-osmium-ore" },
				category = "angels-ore-sorting-4",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1.5,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore1-pure",          amount = 2 },
					{ type = "item", name = "angels-ore1-pure",          amount = 2 },
					{ type = "item", name = "angels-ore4-pure",          amount = 2 },
					{ type = "item", name = "angels-catalysator-orange", amount = 1 },
				},
				results = {
					{ type = "item", name = "clowns-osmium-ore", amount = 6 },
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32, },
					{ icon = "__Clowns-Processing__/graphics/icons/osmium-ore.png",     icon_size = 32, scale = 0.5, shift = { 8, 8 }, },
				},
				order = "r-a" --Just after Platinum
			},
		}
	)
end

if mods["Clowns-AngelBob-Nuclear"] then
	data:extend(
		{
			{
				type = "recipe",
				name = "angels-thorium-pure-processing",
				category = "angels-ore-sorting-4",
				subgroup = "angels-ore-sorting-advanced",
				allow_decomposition = false,
				enabled = false,
				energy_required = 1.5,
				allow_productivity = true,
				ingredients = {
					{ type = "item", name = "clowns-ore3-crystal",       amount = 2 },
					{ type = "item", name = "angels-ore2-crystal",       amount = 2 },
					{ type = "item", name = "angels-ore5-crystal",       amount = 2 },
					{ type = "item", name = "angels-catalysator-orange", amount = 1 }
				},
				results = {
					{ type = "item", name = "angels-thorium-ore", amount = 3 }
				},
				icons = {
					{ icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32, },
					{ icon = "__Clowns-Nuclear__/graphics/icons/ore-5.png",             icon_size = 32, scale = 0.5, shift = { 8, 8 }, tint = { r = 1, g = 1, b = 0.25 } },
				},
				order = "r-a" --Just after Platinum
			}
		}
	)
end
