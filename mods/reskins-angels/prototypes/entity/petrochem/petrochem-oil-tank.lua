-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Angel's Mods
--
-- See LICENSE.md in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.angels and reskins.angels.triggers.petrochem.entities) then
	return
end

---@type SetupStandardEntityInputs
local inputs = {
	type = "storage-tank",
	icon_name = "petrochem-oil-tank",
	base_entity_name = "roboport",
	mod = "angels",
	group = "petrochem",
	icon_layers = 1,
	particles = { ["medium"] = 2 },
	make_remnants = false,
}

local name = "angels-storage-tank-2"

---@type data.StorageTankPrototype
local entity = data.raw[inputs.type][name]
if not entity then
	return
end

reskins.lib.setup_standard_entity(name, 0, inputs)

entity.pictures.picture = {
	sheets = {
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-oil-tank/petrochem-oil-tank.png",
			priority = "extra-high",
			frames = 2,
			width = 273,
			height = 307,
			shift = util.by_pixel(0, -2),
			scale = 0.5,
		},
		{
			filename = "__reskins-angels__/graphics/entity/petrochem/petrochem-oil-tank/petrochem-oil-tank-shadow.png",
			priority = "extra-high",
			frames = 2,
			width = 335,
			height = 328,
			shift = util.by_pixel(16.5, 9.5),
			draw_as_shadow = true,
			scale = 0.5,
		},
	},
}
