-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.equipment.equipment) then
	return
end

-- Note that for equipment, the icons property is not used, so omit type information
-- so that an icon is not set on the equipment prototype.
local inputs = {
	icon_name = "night-vision",
	mod = "bobs",
	group = "equipment",
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local night_vision = {
	["night-vision-equipment"] = { tier = 1, prog_tier = 2 },
	["bob-night-vision-equipment-2"] = { tier = 2, prog_tier = 3 },
	["bob-night-vision-equipment-3"] = { tier = 3, prog_tier = 5 },
}

-- Reskin equipment
for name, map in pairs(night_vision) do
	-- Fetch equipment
	local equipment = data.raw["night-vision-equipment"][name]
	if not equipment then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Construct icon
	reskins.lib.construct_icon(name, tier, inputs)

	-- Reskin the equipment
	equipment.sprite = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/equipment/night-vision-equipment.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/night-vision/night-vision-equipment-mask.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/night-vision/night-vision-equipment-highlights.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	::continue::
end
