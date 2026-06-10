local bob_coefficient = 1
local researchCost = settings.startup["SpaceX-research"].value or 1
local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local ftlRampUp = settings.startup["SpaceX-ftl-ramp-up"].value or false

local SpaceXTechs = {
	"space-assembly",
	"space-construction",
	"space-casings",
	"protection-fields",
	"fusion-reactor",
	"space-thrusters",
	"fuel-cells",
	"habitation",
	"life-support-systems",
	"spaceship-command",
	"laser-cannon",
	"astrometrics",
	"ftl-theory-A",
	"ftl-theory-B",
	"ftl-theory-C",
	"ftl-theory-D1",
	"ftl-theory-D2",
	"ftl-propulsion",
	"exploration-satellite",
	"space-ai-robots",
	"space-fluid-tanks",
	"space-cartography",
}

if bobmods.tech and bobmods.tech.advanced_logistic_science then

	-- Bob exclusive FTL Theory D
	table.insert(SpaceXTechs, "ftl-theory-D")
	if ftlRampUp then
		data:extend({
			{
				type = "technology",
				name = "ftl-theory-D",
				icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
				icon_size = 128,
				prerequisites = { "ftl-theory-C" },
				unit = {
					count = 100000 * researchCost,
					ingredients = {
						{ "automation-science-pack", 1 },
						{ "logistic-science-pack", 1 },
						{ "chemical-science-pack", 1 },
					},
					time = 60,
				},
				order = "k-o-a",
			},
		})
	else
		data:extend({
			{
				type = "technology",
				name = "ftl-theory-D",
				icon = "__SpaceModFeorasFork__/graphics/technology/ftl.png",
				icon_size = 128,
				prerequisites = { "ftl-theory-C" },
				unit = {
					count = 100000 * researchCost,
					ingredients = {
						{ "automation-science-pack", 1 },
						{ "logistic-science-pack", 1 },
						{ "chemical-science-pack", 1 },
						{ "bob-advanced-logistic-science-pack", 1 },
						{ "utility-science-pack", 1 },
					},
					time = 60,
				},
				order = "k-o-a",
			},
		})
	end

	bobmods.lib.tech.add_science_pack("space-assembly", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("space-construction", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("space-casings", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("protection-fields", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("fusion-reactor", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("space-thrusters", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("fuel-cells", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("habitation", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("life-support-systems", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("spaceship-command", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("laser-cannon", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("astrometrics", "bob-advanced-logistic-science-pack", 1)
	bobmods.lib.tech.add_science_pack("ftl-propulsion", "bob-advanced-logistic-science-pack", 1)
	if not classicMode then
		bobmods.lib.tech.add_science_pack("exploration-satellite", "bob-advanced-logistic-science-pack", 1)
		bobmods.lib.tech.add_science_pack("space-ai-robots", "bob-advanced-logistic-science-pack", 1)
		bobmods.lib.tech.add_science_pack("space-fluid-tanks", "bob-advanced-logistic-science-pack", 1)
		bobmods.lib.tech.add_science_pack("space-cartography", "bob-advanced-logistic-science-pack", 1)
	end

	if not classicMode then
		if not ftlRampUp then
			data.raw.technology["ftl-theory-A"].unit.count = 25000 * researchCost
			data.raw.technology["ftl-theory-B"].unit.count = 50000 * researchCost
			data.raw.technology["ftl-theory-C"].unit.count = 75000 * researchCost
			data.raw.technology["ftl-theory-D"].unit.count = 75000 * researchCost
			data.raw.technology["ftl-theory-D1"].unit.count = 100000 * researchCost
			data.raw.technology["ftl-theory-D2"].unit.count = 100000 * researchCost
			data.raw.technology["ftl-propulsion"].unit.count = 150000 * researchCost
			data.raw.technology["exploration-satellite"].unit.count = 175000 * researchCost
			data.raw.technology["space-ai-robots"].unit.count = 175000 * researchCost
			data.raw.technology["space-fluid-tanks"].unit.count = 175000 * researchCost
			data.raw.technology["space-cartography"].unit.count = 200000 * researchCost
		else
			data.raw.technology["ftl-theory-A"].unit.count = 50000 * researchCost
			data.raw.technology["ftl-theory-B"].unit.count = 65000 * researchCost
			data.raw.technology["ftl-theory-C"].unit.count = 80000 * researchCost
			data.raw.technology["ftl-theory-D"].unit.count = 90000 * researchCost
			data.raw.technology["ftl-theory-D1"].unit.count = 100000 * researchCost
			data.raw.technology["ftl-theory-D2"].unit.count = 100000 * researchCost
			data.raw.technology["ftl-propulsion"].unit.count = 150000 * researchCost
			data.raw.technology["exploration-satellite"].unit.count = 175000 * researchCost
			data.raw.technology["space-ai-robots"].unit.count = 175000 * researchCost
			data.raw.technology["space-fluid-tanks"].unit.count = 175000 * researchCost
			data.raw.technology["space-cartography"].unit.count = 200000 * researchCost
		end
	else
		for _, tech in pairs({
			"ftl-theory-A",
			"ftl-theory-B",
			"ftl-theory-C",
			"ftl-theory-D",
			"ftl-theory-D1",
			"ftl-theory-D2",
			"ftl-propulsion",
		}) do
			local rootTech = data.raw.technology[tech]
			if rootTech ~= nil then
				rootTech.unit.count = 200000 * researchCost
			end
		end
	end

	bobmods.lib.tech.replace_prerequisite("ftl-theory-D1", "ftl-theory-C", "ftl-theory-D")
	bobmods.lib.tech.replace_prerequisite("ftl-theory-D2", "ftl-theory-C", "ftl-theory-D")
end

bobmods.lib.tech.add_prerequisite("space-assembly", "bob-robots-3")

if bobmods.modules.EnableGodModules == true then
	bobmods.lib.tech.add_prerequisite("space-assembly", "bob-god-module")
else
	bobmods.lib.tech.add_prerequisite("space-assembly", "bob-speed-module-5")
	bobmods.lib.tech.replace_prerequisite("space-assembly", "efficiency-module-3", "bob-efficiency-module-5")
	bobmods.lib.tech.add_prerequisite("ftl-propulsion", "bob-productivity-module-5")
	bobmods.lib.tech.add_prerequisite("life-support-systems", "bob-productivity-module-5")
	bobmods.lib.tech.add_prerequisite("spaceship-command", "bob-productivity-module-5")
end

bobmods.lib.tech.add_prerequisite("drydock-assembly", "bob-advanced-processing-unit")
bobmods.lib.tech.add_prerequisite("astrometrics", "bob-advanced-research")
bobmods.lib.tech.add_prerequisite("space-construction", "bob-robo-modular-4")
bobmods.lib.tech.replace_prerequisite("space-construction", "solar-energy", "bob-solar-energy-3")
bobmods.lib.tech.replace_prerequisite("protection-fields", "energy-shield-mk2-equipment", "bob-energy-shield-equipment-6")
bobmods.lib.tech.replace_prerequisite("fusion-reactor", "fission-reactor-equipment", "bob-fission-reactor-equipment-4")

bobmods.lib.tech.replace_prerequisite("laser-cannon", "laser-turret", "bob-personal-laser-defense-equipment-6")

if not classicMode then
	bobmods.lib.tech.add_prerequisite("space-fluid-tanks", "bob-fluid-handling-4")

	bobmods.lib.tech.add_prerequisite("space-ai-robots", "bob-robots-4")
	bobmods.lib.tech.replace_prerequisite("space-ai-robots", "exoskeleton-equipment", "bob-exoskeleton-equipment-3")
	bobmods.lib.tech.replace_prerequisite("space-ai-robots", "battery-mk2-equipment", "bob-battery-equipment-6")
end

-- alternate protection field recipe enabler
bobmods.lib.tech.add_recipe_unlock("protection-fields", "protection-field-goopless")

-- Nerf Bob's end game
for i, tech in pairs(SpaceXTechs) do
	local rootTech = data.raw.technology[tech]
	if rootTech ~= nil then
		rootTech.unit.count = rootTech.unit.count * bob_coefficient
	end
end
