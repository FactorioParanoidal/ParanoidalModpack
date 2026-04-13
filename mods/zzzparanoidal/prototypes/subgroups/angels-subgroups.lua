--добавляем новые группы и сабгруппы для рецептов
if not mods["angelsindustries"] then
	data:extend({
		{
			type = "item-group",
			name = "circuit",
			order = "ab",
			icon = "__base__/graphics/technology/circuit-network.png",
			icon_size = 256,
			icon_mipmaps = 4,
		},
		{ type = "item-subgroup", name = "circuit-connection", group = "circuit", order = "b" },
		{ type = "item-subgroup", name = "circuit-combinator", group = "circuit", order = "c" },
		{ type = "item-subgroup", name = "circuit-input", group = "circuit", order = "d" },
		{ type = "item-subgroup", name = "circuit-visual", group = "circuit", order = "e" },
		{ type = "item-subgroup", name = "circuit-auditory", group = "circuit", order = "f" },
		-------------------------------------------------------------------------------------------------
		{
			type = "item-group",
			name = "transport",
			order = "ac",
			icon = "__base__/graphics/technology/railway.png",
			icon_size = 256,
			icon_mipmaps = 4,
		},
		{ type = "item-subgroup", name = "transport-rail", group = "transport", order = "a" },
		{ type = "item-subgroup", name = "transport-rail-other", group = "transport", order = "b" },
		{ type = "item-subgroup", name = "artillery-wagon", group = "transport", order = "eg" },
		{ type = "item-subgroup", name = "spider", group = "transport", order = "x" },
		{ type = "item-subgroup", name = "aircraft", group = "transport", order = "y" },
		-------------------------------------------------------------------------------------------------
		{ type = "item-subgroup", name = "FluidMustFlow", group = "logistics", order = "d-a-3" },
		{ type = "item-subgroup", name = "FlowControl", group = "logistics", order = "d-a-4" },
		{ type = "item-subgroup", name = "wooden-pole", group = "logistics", order = "d-1" },
		{ type = "item-subgroup", name = "medium-electric-pole", group = "logistics", order = "d-2" },
		{ type = "item-subgroup", name = "big-electric-pole", group = "logistics", order = "d-3" },
		{ type = "item-subgroup", name = "substation", group = "logistics", order = "d-4" },
		{ type = "item-subgroup", name = "logistic-chests-1", group = "logistics", order = "f-1" },
		{ type = "item-subgroup", name = "logistic-chests-4", group = "logistics", order = "f-4" },
		{ type = "item-subgroup", name = "logistic-chests-5", group = "logistics", order = "f-5" },
	})
else
	data:extend({
		{ type = "item-subgroup", name = "transport-rail", group = "angels-vehicles", order = "a" },
		{ type = "item-subgroup", name = "transport-rail-other", group = "angels-vehicles", order = "b" },
	})
end

