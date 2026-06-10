local classicMode = settings.startup["SpaceX-classic-mode"].value or false
local noSpace = settings.startup["SpaceX-no-space-sci"].value or false
local rampUp = settings.startup["SpaceX-ftl-ramp-up"].value or false

if not noSpace then
	local ftl = data.raw.technology["ftl-propulsion"]
	ftl.unit.ingredients = {
		{ "production-science-pack", 1 },
		{ "utility-science-pack", 1 },
		{ "space-science-pack", 1 },
		{ "kr-matter-tech-card", 1 },
		{ "kr-advanced-tech-card", 1 },
		{ "kr-singularity-tech-card", 1 },
	}
	ftl.unit.count = ftl.unit.count / 2
end

if data.raw.technology["space-construction"] then
	data.raw.technology["space-construction"].prerequisites = { "space-assembly", "kr-advanced-solar-panel", "kr-ai-core" }
end
if data.raw.technology["space-casings"] then
	table.insert(data.raw.technology["space-casings"].prerequisites, "kr-imersium-processing")
end
if data.raw.technology["space-thrusters"] then
	table.insert(data.raw.technology["space-thrusters"].prerequisites, "kr-steel-fluid-handling")
	table.insert(data.raw.technology["space-thrusters"].prerequisites, "kr-advanced-additional-engine-equipment")
end
if data.raw.technology["fuel-cells"] then
	data.raw.technology["fuel-cells"].prerequisites = { "space-construction", "kr-fusion-energy" }
end
if data.raw.technology["life-support-systems"] then
	table.insert(data.raw.technology["life-support-systems"].prerequisites, "kr-steel-fluid-handling")
	table.insert(data.raw.technology["life-support-systems"].prerequisites, "kr-greenhouse")
end
if data.raw.technology["exploration-satellite"] then
	data.raw.technology["exploration-satellite"].prerequisites = { "ftl-propulsion", "space-thrusters", "kr-fusion-energy" }
  data.raw.technology["exploration-satellite"].unit.ingredients = {
    { "production-science-pack", 1 },
    { "utility-science-pack", 1 },
    { "space-science-pack", 1 },
    { "kr-matter-tech-card", 1 },
    { "kr-advanced-tech-card", 1 },
    { "kr-singularity-tech-card", 1 },
  }

end
if data.raw.technology["space-fluid-tanks"] then
	data.raw.technology["space-fluid-tanks"].prerequisites = {
		"ftl-propulsion", "kr-steel-fluid-tanks", "kr-fusion-energy"
	}
  data.raw.technology["space-fluid-tanks"].unit.ingredients = {
    { "production-science-pack", 1 },
    { "utility-science-pack", 1 },
    { "space-science-pack", 1 },
    { "kr-matter-tech-card", 1 },
    { "kr-advanced-tech-card", 1 },
    { "kr-singularity-tech-card", 1 },
  }

end
if data.raw.technology["space-ai-robots"] then
	data.raw.technology["space-ai-robots"].prerequisites = {
		"ftl-propulsion",
		"kr-advanced-exoskeleton-equipment",
		"belt-immunity-equipment",
		"kr-battery-mk3-equipment",
		"kr-power-armor-mk3",
		"fission-reactor-equipment",
		"kr-advanced-radar",
		"kr-personal-laser-defense-mk3-equipment",
		"personal-roboport-mk2-equipment",
	}
  data.raw.technology["space-ai-robots"].unit.ingredients = {
    { "production-science-pack", 1 },
    { "utility-science-pack", 1 },
    { "space-science-pack", 1 },
    { "kr-matter-tech-card", 1 },
    { "kr-advanced-tech-card", 1 },
    { "kr-singularity-tech-card", 1 },
  }

end
if data.raw.technology["laser-cannon"] then
	data.raw.technology["laser-cannon"].prerequisites = { "space-construction", "circuit-network", "kr-laser-artillery-turret" }
end
if data.raw.technology["protection-fields"] then
	data.raw.technology["protection-fields"].prerequisites = { "space-construction", "kr-energy-shield-mk3-equipment" }
end

if rampUp then
	data.raw.technology["ftl-theory-A"].unit.ingredients = {
		{ "automation-science-pack", 1 },
	}
	data.raw.technology["ftl-theory-B"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
	}
	data.raw.technology["ftl-theory-C"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
	}
	data.raw.technology["ftl-theory-D1"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
		{ "production-science-pack", 1 },
	}
	data.raw.technology["ftl-theory-D2"].unit.ingredients = {
		{ "automation-science-pack", 1 },
		{ "logistic-science-pack", 1 },
		{ "chemical-science-pack", 1 },
		{ "utility-science-pack", 1 },
	}
	if noSpace then
		data.raw.technology["ftl-propulsion"].unit.ingredients = {
			{ "automation-science-pack", 1 },
			{ "logistic-science-pack", 1 },
			{ "chemical-science-pack", 1 },
			{ "production-science-pack", 1 },
			{ "utility-science-pack", 1 },
			{ "space-science-pack", 1 },
		}
	end
end

if not classicMode then
	if not noSpace then
		local sc = data.raw.technology["space-cartography"]
		sc.unit.ingredients = {
			{ "production-science-pack", 1 },
			{ "utility-science-pack", 1 },
			{ "space-science-pack", 1 },
			{ "kr-matter-tech-card", 1 },
			{ "kr-advanced-tech-card", 1 },
			{ "kr-singularity-tech-card", 1 },
		}
		sc.unit.count = sc.unit.count / 2
	end
end
