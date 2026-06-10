-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check if reskinning needs to be done
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "valve",
	icon_name = "valve",
	base_entity_name = "pipe",
	mod = "bobs",
	group = "logistics",
	particles = { ["small"] = 2 },
	icon_layers = 2,
	make_remnants = false,
}

local tint_map = {
	["bob-valve"] = util.color("#2ac0ff"),
	["bob-overflow-valve"] = util.color("#ff3b29"),
	-- cspell: disable-next-line
	["bob-topup-valve"] = util.color("#4dff2a"),
}

-- Reskin entities, create and assign extra details
for name, tint in pairs(tint_map) do
	---@type data.ValvePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	-- Assign tint
	inputs.tint = tint

	reskins.lib.setup_standard_entity(name, 0, inputs)

	-- Reskin entities
	entity.animations = reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/valve/valve-base.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/valve/valve-mask.png",
				priority = "extra-high",
				width = 128,
				height = 128,
				tint = tint,
				scale = 0.5,
			},
		},
	})

	::continue::
end
