-- Other mods may list planets or resource entities RSO must leave to the vanilla generator
-- (data.rso_ignore_planets[name] = true, data.rso_ignore_resource_entities[name] = true).
data.rso_ignore_planets = data.rso_ignore_planets or {}
data.rso_ignore_resource_entities = data.rso_ignore_resource_entities or {}

-- One row of the map generator for all RSO fields: frequency (density of fields), size and
-- richness of every field of the map, on top of the rows of the single resources.
data:extend({{
	type = "autoplace-control",
	name = "rso-fields",
	localised_description = {"autoplace-control-description.rso-fields"},
	category = "resource",
	richness = true,
	can_be_disabled = true,
	order = "a-a[rso-fields]",
}})
