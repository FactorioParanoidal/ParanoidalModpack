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
	mod = "bobs",
	group = "vehicle-equipment",
}

-- Setup defaults
reskins.lib.set_inputs_defaults(inputs)

local categories = {
	"robot",
	"chargepad",
	"antenna",
}

local properties = {
	{ suffix = "", tier = 1, prog_tier = 2 },
	{ suffix = "-2", tier = 2, prog_tier = 3 },
	{ suffix = "-3", tier = 3, prog_tier = 4 },
	{ suffix = "-4", tier = 4, prog_tier = 5 },
}

-- Reskin equipment
for _, category in pairs(categories) do
	for index, map in pairs(properties) do
		local name = "bob-personal-roboport-" .. category .. "-equipment" .. map.suffix

		local equipment = data.raw["roboport-equipment"][name]
		if not equipment then
			goto continue
		end

		local tier = reskins.lib.tiers.get_tier(map)

		-- Setup icon handling
		inputs.icon_name = "vehicle-part-" .. category

		local equipment_path
		if category ~= "robot" then
			equipment_path = "vehicle-part-" .. category .. "-" .. index
			inputs.icon_base = "vehicle-part-" .. category .. "-" .. index
		else
			equipment_path = "vehicle-part-" .. category
			inputs.icon_base = nil
		end

		inputs.tint = reskins.lib.tiers.get_tint(tier)

		-- Construct icon
		reskins.lib.construct_icon(name, tier, inputs)

		-- Reskin the equipment
		equipment.sprite = {
			layers = {
				-- Base
				{
					filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-part-" .. category .. "/" .. equipment_path .. "-equipment-base.png",
					size = 64,
					priority = "medium",
					flags = { "no-crop" },
					scale = 0.5,
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-part-" .. category .. "/vehicle-part-" .. category .. "-equipment-mask.png",
					size = 64,
					priority = "medium",
					flags = { "no-crop" },
					tint = inputs.tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/equipment/vehicle-equipment/vehicle-part-" .. category .. "/vehicle-part-" .. category .. "-equipment-highlights.png",
					size = 64,
					priority = "medium",
					flags = { "no-crop" },
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
			},
		}

		-- Label to skip to next iteration
		::continue::
	end
end
