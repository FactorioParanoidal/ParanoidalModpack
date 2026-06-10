local researchCost = settings.startup["SpaceX-research"].value or 1
local ignoreMult = settings.startup["SpaceX-ignore-tech-multiplier"].value or false
local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local ftlRampUp = settings.startup["SpaceX-ftl-ramp-up"].value or false

local marathon_adj
if ignoreMult then
	marathon_adj = 4
else
	marathon_adj = 1
end

data:extend({
	{
		type = "technology",
		name = "space-assembly",
		icon = "__SpaceModFeorasFork__/graphics/technology/space-assembly.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "assembly-robot",
			},
			{
				type = "unlock-recipe",
				recipe = "spacex-combinator",
			},
		},
		prerequisites = { "rocket-silo", "construction-robotics", "efficiency-module-3" },
		unit = {
			count = 6000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-b",
	},
	{
		type = "technology",
		name = "space-construction",
		icon = "__SpaceModFeorasFork__/graphics/technology/space-construction.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "drydock-assembly",
			},
			{
				type = "unlock-recipe",
				recipe = "drydock-structural",
			},
		},
		prerequisites = { "space-assembly", "solar-energy" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-c",
	},
	{
		type = "technology",
		name = "space-casings",
		icon = "__SpaceModFeorasFork__/graphics/technology/space-casings.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "hull-component",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-d",
	},
	{
		type = "technology",
		name = "protection-fields",
		icon = "__SpaceModFeorasFork__/graphics/technology/protection-fields.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "protection-field",
			},
		},
		prerequisites = { "space-construction", "energy-shield-mk2-equipment" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "utility-science-pack", 1 },
				{ "production-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-e",
	},
	{
		type = "technology",
		name = "fusion-reactor",
		icon = "__SpaceModFeorasFork__/graphics/technology/fusion-reactor.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "fusion-reactor",
			},
		},
		prerequisites = { "space-construction", "fission-reactor-equipment" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "military-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-f",
	},
	{
		type = "technology",
		name = "space-thrusters",
		icon = "__SpaceModFeorasFork__/graphics/technology/space-thrusters.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "space-thruster",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 6000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-g",
	},
	{
		type = "technology",
		name = "fuel-cells",
		icon = "__SpaceModFeorasFork__/graphics/technology/fuel-cells.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "fuel-cell",
			},
		},
		prerequisites = { "space-construction", "nuclear-power" },
		unit = {
			count = 6000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-h",
	},
	{
		type = "technology",
		name = "habitation",
		icon = "__SpaceModFeorasFork__/graphics/technology/habitation.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "habitation",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-i",
	},
	{
		type = "technology",
		name = "life-support-systems",
		icon = "__SpaceModFeorasFork__/graphics/technology/life-support.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "life-support",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 12000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-j",
	},
	{
		type = "technology",
		name = "astrometrics",
		icon = "__SpaceModFeorasFork__/graphics/technology/astrometrics.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "astrometrics",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 14000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-k",
	},
	{
		type = "technology",
		name = "spaceship-command",
		icon = "__SpaceModFeorasFork__/graphics/technology/command.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "command",
			},
		},
		prerequisites = { "space-construction" },
		unit = {
			count = 24000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-l",
	},
	{
		type = "technology",
		name = "laser-cannon",
		icon = "__SpaceModFeorasFork__/graphics/technology/laser-cannon.png",
		icon_size = 128,
		effects = {
			{
				type = "unlock-recipe",
				recipe = "laser-cannon",
			},
		},
		prerequisites = { "space-construction", "circuit-network", "laser-turret" },
		unit = {
			count = 24000 * researchCost / marathon_adj,
			ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
				{ "military-science-pack", 1 },
			},
			time = 60,
		},
		order = "k-m",
	},
})

if classicMode then
	data:extend({
		{
			type = "technology",
			name = "ftl-theory-A",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "space-construction" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-n",
		},
		{
			type = "technology",
			name = "ftl-theory-B",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-A" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-o",
		},
		{
			type = "technology",
			name = "ftl-theory-C",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-B" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D1",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D2",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-propulsion",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "ftl-drive",
				},
			},
			prerequisites = { "ftl-theory-D1", "ftl-theory-D2", "space-science-pack" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "space-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-q",
		},
	})
elseif ftlRampUp then
	data:extend({
		{
			type = "technology",
			name = "ftl-theory-A",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "space-construction" },
			unit = {
				count = 50000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-n",
		},
		{
			type = "technology",
			name = "ftl-theory-B",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-A" },
			unit = {
				count = 65000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-o",
		},
		{
			type = "technology",
			name = "ftl-theory-C",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-B" },
			unit = {
				count = 80000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D1",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 100000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D2",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 100000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-propulsion",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "ftl-drive",
				},
			},
			prerequisites = { "ftl-theory-D1", "ftl-theory-D2", "space-science-pack" },
			unit = {
				count = 150000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "space-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-q",
		},
	})
else
	data:extend({
		{
			type = "technology",
			name = "ftl-theory-A",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "space-construction" },
			unit = {
				count = 25000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-n",
		},
		{
			type = "technology",
			name = "ftl-theory-B",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-A" },
			unit = {
				count = 50000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-o",
		},
		{
			type = "technology",
			name = "ftl-theory-C",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-B" },
			unit = {
				count = 75000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D1",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 100000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-theory-D2",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			prerequisites = { "ftl-theory-C" },
			unit = {
				count = 100000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-p",
		},
		{
			type = "technology",
			name = "ftl-propulsion",
			icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "ftl-drive",
				},
			},
			prerequisites = { "ftl-theory-D1", "ftl-theory-D2", "space-science-pack" },
			unit = {
				count = 150000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "space-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-q",
		},
	})
end

if not classicMode then
	data:extend({
		{
			type = "technology",
			name = "exploration-satellite",
			icon = "__SpaceModFeorasFork__/graphics/technology/exploration-satellite.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "exploration-satellite",
				},
			},
			prerequisites = { "ftl-propulsion", "space-thrusters", "kovarex-enrichment-process" },
			unit = {
				count = 175000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-r",
		},
		{
			type = "technology",
			name = "space-ai-robots",
			icon = "__SpaceModFeorasFork__/graphics/technology/space-ai-robots.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "space-ai-robot",
				},
				{
					type = "unlock-recipe",
					recipe = "space-ai-robot-frame",
				},
			},
			prerequisites = {
				"ftl-propulsion",
				"exoskeleton-equipment",
				"belt-immunity-equipment",
				"battery-mk2-equipment",
				"power-armor-mk2",
				"fission-reactor-equipment",
			},
			unit = {
				count = 175000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "military-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-s",
		},
		{
			type = "technology",
			name = "space-fluid-tanks",
			icon = "__SpaceModFeorasFork__/graphics/technology/space-fluid-tanks.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "space-water-tank",
				},
				{
					type = "unlock-recipe",
					recipe = "space-oxygen-tank",
				},
				{
					type = "unlock-recipe",
					recipe = "space-fuel-tank",
				},
				{
					type = "unlock-recipe",
					recipe = "space-oxygen-barrel",
				},
			},
			prerequisites = { "ftl-propulsion", "kovarex-enrichment-process" },
			unit = {
				count = 175000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-t",
		},
		{
			type = "technology",
			name = "space-cartography",
			icon = "__SpaceModFeorasFork__/graphics/technology/space-cartography.png",
			icon_size = 128,
			effects = {
				{
					type = "unlock-recipe",
					recipe = "space-map",
				},
			},
			prerequisites = { "exploration-satellite" },
			unit = {
				count = 200000 * researchCost / marathon_adj,
				ingredients = {
					{ "automation-science-pack", 1 },
					{ "logistic-science-pack", 1 },
					{ "chemical-science-pack", 1 },
					{ "production-science-pack", 1 },
					{ "utility-science-pack", 1 },
					{ "space-science-pack", 1 },
				},
				time = 60,
			},
			order = "k-v",
		},
	})
end

local noSpace = settings.startup["SpaceX-no-space-sci"].value or false
if noSpace then
	local techs_with_space_science = { "ftl-propulsion", "space-cartography" }
	for _, tech in pairs(techs_with_space_science) do
		local fix = data.raw.technology[tech]
		if fix ~= nil then
			fix.unit.ingredients = {
				{ "automation-science-pack", 1 },
				{ "logistic-science-pack", 1 },
				{ "chemical-science-pack", 1 },
				{ "production-science-pack", 1 },
				{ "utility-science-pack", 1 },
			}
		end
	end
	data.raw.technology["ftl-propulsion"].prerequisites = { "ftl-theory-D1", "ftl-theory-D2" }
end

local combinatorSplit = settings.startup["SpaceX-split-combinator"].value or false
if combinatorSplit then
	local fix = data.raw.technology["space-assembly"]
	fix.effects = {
		{
			type = "unlock-recipe",
			recipe = "assembly-robot",
		},
		{
			type = "unlock-recipe",
			recipe = "spacex-combinator",
		},
		{
			type = "unlock-recipe",
			recipe = "spacex-combinator-stage",
		},
	}
end

local replaceNuclear = settings.startup["SpaceX-no-nuclear"].value or false
if replaceNuclear or classicMode then
	data.raw.technology["fuel-cells"].prerequisites = { "space-construction" }
	if not classicMode then
		data.raw.technology["space-fluid-tanks"].prerequisites = { "ftl-propulsion" }
		data.raw.technology["exploration-satellite"].prerequisites = { "ftl-propulsion", "space-thrusters" }
	end
end
