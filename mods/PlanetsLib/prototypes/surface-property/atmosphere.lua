if settings.startup["PlanetsLib-enable-oxygen"].value == true then
	data:extend({
		{
			type = "surface-property",
			name = "oxygen",
			default_value = 21,
			localised_unit_key = "surface-property-unit.percentage", --(2.0.28) An engine bug seems to cause Factorio to ignore this line.
			order = "z[gas]a",
		},
	})

	--Convention:
	--Burners should be inoperable when oxygen == 0

	data.raw.surface["space-platform"].surface_properties.oxygen = 0
	data.raw.planet["nauvis"].surface_properties.oxygen = 21
	data.raw.planet["vulcanus"].surface_properties.oxygen = 3
	data.raw.planet["fulgora"].surface_properties.oxygen = 20
	data.raw.planet["gleba"].surface_properties.oxygen = 35
	data.raw.planet["aquilo"].surface_properties.oxygen = 15
end

if settings.startup["PlanetsLib-enable-nitrogen"].value == true then
	data:extend({
		{
			type = "surface-property",
			name = "nitrogen",
			default_value = 78,
			localised_unit_key = "surface-property-unit.percentage", --(2.0.28) An engine bug seems to cause Factorio to ignore this line.
			order = "z[gas]c",
		},
	})

	data.raw.surface["space-platform"].surface_properties.nitrogen = 0
	data.raw.planet["nauvis"].surface_properties.nitrogen = 78
	data.raw.planet["vulcanus"].surface_properties.nitrogen = 3
	data.raw.planet["fulgora"].surface_properties.nitrogen = 18
	data.raw.planet["gleba"].surface_properties.nitrogen = 35
	data.raw.planet["aquilo"].surface_properties.nitrogen = 84
end

if settings.startup["PlanetsLib-enable-carbon-dioxide"].value == true then
	data:extend({
		{
			type = "surface-property",
			name = "carbon-dioxide",
			default_value = 0.0275,
			localised_unit_key = "surface-property-unit.percentage", --(2.0.28) An engine bug seems to cause Factorio to ignore this line.
			order = "z[gas]b",
		},
	})

	data.raw.surface["space-platform"].surface_properties["carbon-dioxide"] = 0
	data.raw.planet["nauvis"].surface_properties["carbon-dioxide"] = 0.0275 --Earth's preindustrial CO2 content
	data.raw.planet["vulcanus"].surface_properties["carbon-dioxide"] = 93 --Venus' CO2 content
	data.raw.planet["fulgora"].surface_properties["carbon-dioxide"] = 0.06 --Assuming Fulgora is a polluted Earth-like planet.
	data.raw.planet["gleba"].surface_properties["carbon-dioxide"] = 0.1 --CO2 during cretaceous period
	data.raw.planet["aquilo"].surface_properties["carbon-dioxide"] = 0
end

if settings.startup["PlanetsLib-enable-argon"].value == true then
	data:extend({
		{
			type = "surface-property",
			name = "argon",
			default_value = 0.9,
			localised_unit_key = "surface-property-unit.percentage", --(2.0.28) An engine bug seems to cause Factorio to ignore this line.
			order = "z[gas]d",
		},
	})

	data.raw.surface["space-platform"].surface_properties["argon"] = 0
	data.raw.planet["nauvis"].surface_properties["argon"] = 0.9
	data.raw.planet["vulcanus"].surface_properties["argon"] = 0
	data.raw.planet["fulgora"].surface_properties["argon"] = 0.9
	data.raw.planet["gleba"].surface_properties["argon"] = 0.9
	data.raw.planet["aquilo"].surface_properties["argon"] = 0
end
