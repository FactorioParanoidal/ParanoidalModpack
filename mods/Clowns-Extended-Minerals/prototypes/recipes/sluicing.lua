local OV = angelsmods.functions.OV
if not clowns.special_vanilla then
	data:extend(
		{
			{
				type = "recipe",
				name = "clowns-resource1-sluicing",
				category = "sluicing",
				enabled = false,
				icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-resource1.png",
				icon_size = 32,
				ingredients =
				{
					{ type = "item",  name = "clowns-resource1", amount = 10 },
					{ type = "fluid", name = "water",            amount = 10 }
				},
				results =
				{
					{ type = "fluid", name = "angels-water-saline", amount = 10 },
					{ type = "item",  name = "iron-ore",            amount = 1, probability = 0.2, },
					{ type = "item",  name = "angels-crystal-dust", amount = 1, probability = 0.1, },
					{ type = "item",  name = "angels-gold-ore",     amount = 1, probability = 0.05, },
					{ type = "item",  name = "angels-chrome-ore",   amount = 1, probability = 0.01, },
					{ type = "item",  name = "angels-platinum-ore", amount = 1, probability = 0.01, }
					--Rare earth metals, zirconium
				},
				energy_required = 5,
				subgroup = "angels-water-washing",
				order = "k-b-a",
			},

			{
				type = "recipe",
				name = "clowns-resource1-sluicing-advanced",
				category = "sluicing",
				enabled = false,
				icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-resource1.png",
				icon_size = 32,
				ingredients =
				{
					{ type = "item",  name = "clowns-resource1", amount = 10 },
					{ type = "fluid", name = "water",            amount = 10 }
				},
				results =
				{
					{ type = "fluid", name = "angels-water-saline", amount = 10 },
					{ type = "item",  name = "angels-gold-ore",     amount = 1, probability = 0.1, },
					{ type = "item",  name = "angels-chrome-ore",   amount = 1, probability = 0.03, },
					{ type = "item",  name = "angels-rutile-ore",   amount = 1, probability = 0.03, },
					{ type = "item",  name = "angels-platinum-ore", amount = 1, probability = 0.03, },
					{ type = "item",  name = "uranium-ore",         amount = 1, probability = 0.01, },
					{ type = "item",  name = "angels-thorium-ore",  amount = 1, probability = 0.01, },
				},
				energy_required = 5,
				subgroup = "angels-water-washing",
				order = "k-b-b",
			}
		}
	)
end

if mods["bobplates"] then
	OV.modify_output("clowns-resource1-sluicing",
		{ type = "item", name = "angels-tin-ore", amount = 1, probability = 0.1, }
	)
end
