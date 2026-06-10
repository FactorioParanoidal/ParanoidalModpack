local classicMode = settings.startup["SpaceX-classic-mode"].value or false

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

for _, t in pairs(SpaceXTechs) do
	local tech = data.raw.technology[t]
	if tech then
		local amount = tech.unit.count
		local has_military = false
		local has_space = false
		for _, ingredient in pairs(tech.unit.ingredients) do
			if ingredient[1] == "military-science-pack" or ingredient.name == "military-science-pack" then
				has_military = true
			end
			if ingredient[1] == "space-science-pack" or ingredient.name == "space-science-pack" then
				has_space = true
			end
		end
		if has_space and settings.startup["SpaceX-no-space-sci"].value == false then
			tech.unit.count = amount / 200
			tech.unit.time = 1200
			tech.unit.ingredients = {
				{ "automation-science-pack", 200 },
				{ "py-science-pack-1", 100 },
				{ "logistic-science-pack", 60 },
				{ "py-science-pack-2", 30 },
				{ "chemical-science-pack", 20 },
				{ "py-science-pack-3", 10 },
				{ "production-science-pack", 6 },
				{ "py-science-pack-4", 3 },
				{ "utility-science-pack", 2 },
				{ "space-science-pack", 1 },
			}
			if has_military then
				table.insert(tech.unit.ingredients, { "military-science-pack", 30 })
			end
		else
			tech.unit.count = amount / 100
			tech.unit.time = 600
			tech.unit.ingredients = {
				{ "automation-science-pack", 100 },
				{ "py-science-pack-1", 60 },
				{ "logistic-science-pack", 30 },
				{ "py-science-pack-2", 20 },
				{ "chemical-science-pack", 10 },
				{ "py-science-pack-3", 6 },
				{ "production-science-pack", 3 },
				{ "py-science-pack-4", 2 },
				{ "utility-science-pack", 1 },
			}
			if has_military then
				table.insert(tech.unit.ingredients, { "military-science-pack", 20 })
			end
		end
	end
end

if data.raw.technology["space-assembly"] then
	data.raw.technology["space-assembly"].unit.count = 1000
	table.insert(data.raw.technology["space-assembly"].prerequisites, "ht-robotics")
end

if data.raw.technology["space-construction"] then
	data.raw.technology["space-construction"].unit.count = 1100
	table.insert(data.raw.technology["space-construction"].prerequisites, "advanced-robotics")
	table.insert(data.raw.technology["space-construction"].prerequisites, "solar-mk04")
end

if data.raw.technology["space-casings"] then
	data.raw.technology["space-casings"].unit.count = 1100
	table.insert(data.raw.technology["space-casings"].prerequisites, "fusion-mk02")
end

if data.raw.technology["protection-fields"] then
	data.raw.technology["protection-fields"].unit.count = 1100
	table.insert(data.raw.technology["protection-fields"].prerequisites, "py-accumulator-mk03")
end

if data.raw.technology["fusion-reactor"] then
	data.raw.technology["fusion-reactor"].unit.count = 1100
	table.insert(data.raw.technology["fusion-reactor"].prerequisites, "fusion-mk03")
end

if data.raw.technology["space-thrusters"] then
	data.raw.technology["space-thrusters"].unit.count = 1100
end

if data.raw.technology["fuel-cells"] then
	data.raw.technology["fuel-cells"].unit.count = 1100
	table.insert(data.raw.technology["fuel-cells"].prerequisites, "nuclear-power-mk04")
end

if data.raw.technology["habitation"] then
	data.raw.technology["habitation"].unit.count = 1100
	table.insert(data.raw.technology["habitation"].prerequisites, "machine-components-mk04")
end

if data.raw.technology["life-support-systems"] then
	data.raw.technology["life-support-systems"].unit.count = 1100
end

if data.raw.technology["spaceship-command"] then
	data.raw.technology["spaceship-command"].unit.count = 1100
	table.insert(data.raw.technology["spaceship-command"].prerequisites, "machine-components-mk04")
end

if data.raw.technology["laser-cannon"] then
	data.raw.technology["laser-cannon"].unit.count = 1100
end

if data.raw.technology["astrometrics"] then
	data.raw.technology["astrometrics"].unit.count = 1100
	table.insert(data.raw.technology["astrometrics"].prerequisites, "biotech-machines-mk04")
end

if data.raw.technology["ftl-theory-A"] then
	data.raw.technology["ftl-theory-A"].unit.count = 1200
end

if data.raw.technology["ftl-theory-B"] then
	data.raw.technology["ftl-theory-B"].unit.count = 1300
end

if data.raw.technology["ftl-theory-C"] then
	data.raw.technology["ftl-theory-C"].unit.count = 1400
end

if data.raw.technology["ftl-theory-D1"] then
	data.raw.technology["ftl-theory-D1"].unit.count = 1500
end

if data.raw.technology["ftl-theory-D2"] then
	data.raw.technology["ftl-theory-D2"].unit.count = 1500
end

if data.raw.technology["ftl-propulsion"] then
	if settings.startup["SpaceX-no-space-sci"].value == false then
		data.raw.technology["ftl-propulsion"].unit.count = 875
	else
		data.raw.technology["ftl-propulsion"].unit.count = 1750
	end
end

if not classicMode then
	if data.raw.technology["exploration-satellite"] then
		data.raw.technology["exploration-satellite"].unit.count = 2000
	end

	if data.raw.technology["space-ai-robots"] then
		data.raw.technology["space-ai-robots"].unit.count = 2000
		table.insert(data.raw.technology["space-ai-robots"].prerequisites, "battery-mk04")
		table.insert(data.raw.technology["space-ai-robots"].prerequisites, "xeno-mk04")
	end

	if data.raw.technology["space-fluid-tanks"] then
		data.raw.technology["space-fluid-tanks"].unit.count = 2000
	end

	if data.raw.technology["space-cartography"] then
		if settings.startup["SpaceX-no-space-sci"].value == false then
			data.raw.technology["space-cartography"].unit.count = 1500
		else
			data.raw.technology["space-cartography"].unit.count = 3000
		end
	end
end
