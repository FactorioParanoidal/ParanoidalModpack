-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "storage-tank",
	icon_name = "petrochem-inline-tank",
	base_entity_name = "storage-tank",
	mod = "angels",
	group = "petrochem",
	tint = util.color("#c20600"), -- Red
	icon_layers = 1,
	particles = { ["big"] = 1 },
	make_remnants = false,
}

local name = "angels-storage-tank-3"

---@type data.StorageTankPrototype
local entity = data.raw[inputs.type][name]
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
	sheets = {
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-inline-tank/petrochem-inline-tank.png",
			priority = "extra-high",
			frames = 4,
			width = 142,
			height = 199,
			shift = util.by_pixel(0, -7.5),
			scale = 0.5,
		},
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-inline-tank/petrochem-inline-tank-shadow.png",
			priority = "extra-high",
			frames = 4,
			width = 207,
			height = 199,
			shift = util.by_pixel(16.5, 9),
			draw_as_shadow = true,
			scale = 0.5,
		},
	},
}
