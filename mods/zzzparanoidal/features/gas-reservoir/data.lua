local config = require("features.gas-reservoir.shared")
local legacy = data.raw["storage-tank"][config.legacy]
local item = data.raw.item[config.legacy]

-- Changing the old prototype's default filter would discard incompatible contents
-- during engine load, before Lua migrations run. Keep its ID and leave its prototype unfiltered.
local tank = table.deepcopy(legacy)
tank.name = config.tank
tank.localised_name = {"entity-name." .. config.legacy}
tank.localised_description = {"paranoidal-gas-reservoir.description"}
tank.fluid_box.filter = config.sealed
item.place_result = tank.name
item.localised_description = tank.localised_description
legacy.placeable_by = {item = item.name, count = 1} -- pipette, existing ghosts and old blueprints
legacy.hidden_in_factoriopedia = true
legacy.factoriopedia_alternative = tank.name

data:extend({tank, {
	type = "fluid",
	name = config.sealed,
	icon = "__core__/graphics/empty.png", icon_size = 64,
	hidden = true,
	hidden_in_factoriopedia = true,
	auto_barrel = false,
	default_temperature = 15,
	base_color = {0, 0, 0},
	flow_color = {0, 0, 0},
	localised_name = {"paranoidal-gas-reservoir.sealed"},
}})
