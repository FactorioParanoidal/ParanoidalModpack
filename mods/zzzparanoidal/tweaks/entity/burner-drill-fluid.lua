-- From zzzcompability (Tias): AAI burner drill fluid input, in data-updates.
local drill = data.raw["mining-drill"]["burner-mining-drill"]
local bbox = drill.collision_box
local anchor = bbox[2] or bbox.right_bottom
if not anchor then
	error("No map position found in BoundingBox: " .. serpent.block(bbox))
end
anchor = { (anchor[1] or anchor.x) / 2, (anchor[2] or anchor.y) / 2 }
drill.input_fluid_box = {
	volume = 1000,
	production_type = "input",
	pipe_connections = {
		{
			flow_direction = "input-output",
			direction = defines.direction.south,
			position = anchor,
		},
	},
}

local tech = data.raw.technology["burner-mechanics"]
assert(tech, "Given tech not found!")
tech.unit = nil
-- Later early-electronics-beta8 restores the science cost; the fluid-mining effect stays.
tech.research_trigger = {
	type = "mine-entity",
	entities = { "coal" },
}
table.insert(tech.effects, { type = "mining-with-fluid", modifier = true })
