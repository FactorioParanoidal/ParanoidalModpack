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
	icon_name = "petrochem-gas-tank",
	base_entity_name = "oil-refinery",
	mod = "angels",
	group = "petrochem",
	icon_layers = 1,
	particles = { ["medium-long"] = 4, ["big-tint"] = 5, ["medium"] = 2 },
	make_remnants = false,
}

local name = "angels-storage-tank-1"

---@type data.StorageTankPrototype
local entity = data.raw[inputs.type][name]

-- Check if entity exists, if not, skip this iteration
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
	sheets = {
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-gas-tank/petrochem-gas-tank.png",
			priority = "extra-high",
			frames = 1,
			width = 334,
			height = 387,
			shift = util.by_pixel(-0.5, -6),
			scale = 0.5,
		},
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-gas-tank/petrochem-gas-tank-shadow.png",
			priority = "extra-high",
			frames = 1,
			width = 437,
			height = 237,
			shift = util.by_pixel(26, 32),
			draw_as_shadow = true,
			scale = 0.5,
		},
	},
}
