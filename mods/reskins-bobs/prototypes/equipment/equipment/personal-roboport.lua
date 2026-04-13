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
	icon_name = "personal-roboport",
	mod = "bobs",
	group = "equipment",
	technology_icon_size = 256,
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local personal_roboports = {
	["personal-roboport-equipment"] = { tier = 1, prog_tier = 2, base = 1 },
	["personal-roboport-mk2-equipment"] = { tier = 2, prog_tier = 3, base = 1 },
	["bob-personal-roboport-mk3-equipment"] = { tier = 3, prog_tier = 4, base = 2 },
	["bob-personal-roboport-mk4-equipment"] = { tier = 4, prog_tier = 5, base = 2 },
}

-- Reskin equipment
for name, map in pairs(personal_roboports) do
	-- Fetch equipment
	local equipment = data.raw["roboport-equipment"][name]
	if not equipment then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- Setup icon handling
	inputs.icon_base = inputs.icon_name .. "-" .. map.base
	inputs.icon_mask = inputs.icon_base
	inputs.icon_highlights = inputs.icon_base
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Construct icon
	reskins.lib.construct_icon(name, tier, inputs)

	-- Reskin the equipment
	equipment.sprite = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/personal-roboport/" .. inputs.icon_base .. "-equipment-base.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/personal-roboport/" .. inputs.icon_base .. "-equipment-mask.png",
				size = 128,
				priority = "medium",
				flags = { "no-crop" },
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/equipment/equipment/personal-roboport/" .. inputs.icon_base .. "-equipment-highlights.png",
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
