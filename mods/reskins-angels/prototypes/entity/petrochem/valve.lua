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
	icon_name = "valve",
	base_entity_name = "pipe",
	mod = "angels",
	group = "petrochem",
	particles = { ["small"] = 2 },
	icon_layers = 2,
	make_remnants = false,
}

local valves = {
	["angels-valve-inspector"] = { tint = util.color("#8dd24e"), type = "storage-tank" },
	["angels-valve-overflow"] = { tint = util.color("#689ed3"), type = "valve" },
	["angels-valve-one-way"] = { tint = util.color("#d4933f"), type = "valve" },
	["angels-valve-top-up"] = { tint = util.color("#fcfcfc"), type = "valve" },
}

local function cardinal_pictures(x, tint)
	local x_hr = 128 * x

	return {
		layers = {
			-- Base
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/valve/valve-base.png",
				priority = "extra-high",
				x = x_hr,
				width = 128,
				height = 128,
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-angels__/graphics/entity/petrochem/valve/valve-mask.png",
				priority = "extra-high",
				x = x_hr,
				width = 128,
				height = 128,
				tint = tint,
				scale = 0.5,
			},
		},
	}
end

for name, map in pairs(valves) do
	---@type data.ValvePrototype|data.StorageTankPrototype
	local entity = data.raw[map.type][name]
	if not entity then
		goto continue
	end

	inputs.tint = map.tint
	inputs.type = map.type

	reskins.lib.setup_standard_entity(name, 0, inputs)

	-- Reskin entities
	local animations = {
		north = cardinal_pictures(0, inputs.tint),
		east = cardinal_pictures(1, inputs.tint),
		south = cardinal_pictures(2, inputs.tint),
		west = cardinal_pictures(3, inputs.tint),
	}

	if map.type == "storage-tank" then
		entity.pictures = {
			picture = animations,
		}
	else
		entity.animations = animations
	end

	-- Add pipe overs
	entity.fluid_box.pipe_covers = pipecoverspictures()

	::continue::
end
