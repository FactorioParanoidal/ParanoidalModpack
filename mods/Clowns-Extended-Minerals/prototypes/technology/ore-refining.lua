local crushing_eff, sorting_eff, flotation_eff, leeching_eff, refining_eff = {}, {}, {}, {}, {}
local ore = clowns.special_vanilla and { 1, 4, 5, 7 } or { 1, 2, 3, 4, 5, 6, 7, 8, 9 }
for _, i in pairs(ore) do --clowns-ore count, excluding blendded
	--add static recipe unlocks
	crushing_eff[#crushing_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-crushed" }
	crushing_eff[#crushing_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-crushed-processing" }
	flotation_eff[#flotation_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-chunk" }
	flotation_eff[#flotation_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-chunk-processing" }
	leeching_eff[#leeching_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-crystal" }
	leeching_eff[#leeching_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-crystal-processing" }
	refining_eff[#refining_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-pure" }
	refining_eff[#refining_eff + 1] = { type = "unlock-recipe", recipe = "clowns-ore" .. i .. "-pure-processing" }
	--add dynamic recipe unlocks
	if data.raw.recipe["clowns-crushed-mix" .. i .. "-processing"] then
		sorting_eff[#sorting_eff + 1] = { type = "unlock-recipe", recipe = "clowns-crushed-mix" .. i .. "-processing" }
	end
	if data.raw.recipe["clowns-chunk-mix" .. i .. "-processing"] then
		flotation_eff[#flotation_eff + 1] = { type = "unlock-recipe", recipe = "clowns-chunk-mix" .. i .. "-processing" }
	end
	if data.raw.recipe["clowns-crystal-mix" .. i .. "-processing"] then
		leeching_eff[#leeching_eff + 1] = { type = "unlock-recipe", recipe = "clowns-crystal-mix" .. i .. "-processing" }
	end
	if data.raw.recipe["clowns-pure-mix" .. i .. "-processing"] then
		refining_eff[#refining_eff + 1] = { type = "unlock-recipe", recipe = "clowns-pure-mix" .. i .. "-processing" }
	end
end
data:extend(
	{
		{
			type = "technology",
			name = "clowns-ore-crushing",
			icon_size = 256,
			icon = "__angelsrefininggraphics__/graphics/technology/mechanical-refining.png",
			effects = crushing_eff,
			prerequisites = { "angels-ore-crushing" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
				},
				time = 15,
				count = 20
			},
			order = "c-b"
		},
		{
			type = "technology",
			name = "clowns-advanced-ore-refininhg",
			icon_size = 256,
			icon = "__angelsrefininggraphics__/graphics/technology/ore-sorting.png",
			effects = sorting_eff,
			prerequisites = { "clowns-ore-crushing", "angels-ore-powderizer" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
				},
				time = 15,
				count = 20
			},
			order = "c-b"
		},
		{
			type = "technology",
			name = "clowns-ore-floatation",
			icon_size = 256,
			icon = "__angelsrefininggraphics__/graphics/technology/hydro-refining.png",
			effects = flotation_eff,
			prerequisites = { "angels-ore-floatation", "angels-slag-processing-2", "clowns-advanced-ore-refininhg" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
				},
				time = 30,
				count = 80
			},
			order = "c-b"
		},
		{
			type = "technology",
			name = "clowns-ore-leaching",
			icon_size = 128,
			icon = "__angelsrefininggraphics__/graphics/technology/chemical-refining.png",
			effects = leeching_eff,
			prerequisites = { "angels-ore-leaching", "angels-ore-electro-whinning-cell", "clowns-ore-floatation", "phosphorus-processing-2", "angels-slag-processing-3" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
				},
				time = 30,
				count = 80
			},
			order = "c-b"
		},
		{
			type = "technology",
			name = "clowns-ore-refining",
			icon_size = 256,
			icon = "__angelsrefininggraphics__/graphics/technology/thermal-refining.png",
			effects = refining_eff,
			prerequisites = { "angels-ore-refining", "clowns-ore-leaching" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
				},
				time = 30,
				count = 80
			},
			order = "c-b"
		},
		{
			type = "technology",
			name = "clowns-ore-electro-whinning-cell",
			icon_size = 128,
			effects = {},
			icon = "__angelsrefininggraphics__/graphics/technology/electro-whinning-cell-tech.png",
			prerequisites = { "clowns-ore-refining", "utility-science-pack" },
			unit =
			{
				ingredients =
				{
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack",   1 },
					{ "chemical-science-pack",   1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack",    1 },
				},
				time = 30,
				count = 80
			},
			order = "c-b"
		}
	}
)
if not clowns.special_vanilla then --add in the mixed sorting recipes to the techs
	table.insert(data.raw.technology["clowns-advanced-ore-refininhg"].effects,
		{ type = "unlock-recipe", recipe = "angels-manganese-pure-processing" })
	table.insert(data.raw.technology["clowns-advanced-ore-refininhg"].effects,
		{ type = "unlock-recipe", recipe = "clowns-phosphorus-pure-processing" })
	table.insert(data.raw.technology["clowns-ore-leaching"].effects,
		{ type = "unlock-recipe", recipe = "angels-chrome-pure-processing" })
	table.insert(data.raw.technology["clowns-ore-floatation"].effects,
		{ type = "unlock-recipe", recipe = "clowns-magnesium-pure-processing" })
	table.insert(data.raw.technology["clowns-ore-refining"].effects,
		{ type = "unlock-recipe", recipe = "clowns-osmium-pure-processing" })
	table.insert(data.raw.technology["clowns-ore-refining"].effects,
		{ type = "unlock-recipe", recipe = "clowns-platinum-pure-processing" })
	if mods["Clowns-AngelBob-Nuclear"] then
		--add in thorium
		table.insert(data.raw.technology["clowns-ore-leaching"].effects,
			{ type = "unlock-recipe", recipe = "angels-thorium-pure-processing" })
	end
end

--add in advanced ore stuffs
if not clowns.special_vanilla then
	for i = 11, 15, 1 do
		table.insert(data.raw.technology["angels-ore-advanced-crushing"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-crushed" })
		table.insert(data.raw.technology["angels-ore-advanced-crushing"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-crushed-processing" })
		table.insert(data.raw.technology["angels-ore-powderizer"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-powder" })
		table.insert(data.raw.technology["angels-ore-powderizer"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-powder-processing" })
		table.insert(data.raw.technology["angels-ore-advanced-floatation"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-sludge" })
		table.insert(data.raw.technology["angels-ore-advanced-floatation"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-dust" })
		table.insert(data.raw.technology["angels-ore-advanced-floatation"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-dust-processing" })
		table.insert(data.raw.technology["clowns-ore-electro-whinning-cell"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-solution" })
		table.insert(data.raw.technology["clowns-ore-electro-whinning-cell"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-anode-sludge-filtering" })
		table.insert(data.raw.technology["clowns-ore-electro-whinning-cell"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-anode-sludge" })
		table.insert(data.raw.technology["clowns-ore-electro-whinning-cell"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-crystal" })
		table.insert(data.raw.technology["clowns-ore-electro-whinning-cell"].effects,
			{ type = "unlock-recipe", recipe = "clownsore" .. i .. "-crystal-processing" })
	end
else --special vanilla case
	--table.insert(data.raw.technology["angels-ore-advanced-crushing"].effects,{type = "unlock-recipe",recipe = "clownsore"..i.."-crushed"})
end
