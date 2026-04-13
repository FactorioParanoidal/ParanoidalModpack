-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "logistic-container",
	icon_name = "logistic-chest",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 1 },
	icon_layers = 2,
	untinted_icon_mask = true,
}

local material_tints = {
	["brass"] = util.color("#f9c854"),
	["titanium"] = util.color("#adadb2"),
}

local logistic_map = {
	["active-provider-chest"] = { tier = 1, prog_tier = 2 },
	["passive-provider-chest"] = { tier = 1, prog_tier = 2 },
	["storage-chest"] = { tier = 1, prog_tier = 2 },
	["buffer-chest"] = { tier = 1, prog_tier = 2 },
	["requester-chest"] = { tier = 1, prog_tier = 2 },
	["bob-active-provider-chest-2"] = { tier = 2, prog_tier = 3, material = "brass", chest_type = "active-provider" },
	["bob-passive-provider-chest-2"] = { tier = 2, prog_tier = 3, material = "brass", chest_type = "passive-provider" },
	["bob-storage-chest-2"] = { tier = 2, prog_tier = 3, material = "brass", chest_type = "storage" },
	["bob-buffer-chest-2"] = { tier = 2, prog_tier = 3, material = "brass", chest_type = "buffer" },
	["bob-requester-chest-2"] = { tier = 2, prog_tier = 3, material = "brass", chest_type = "requester" },
	["bob-active-provider-chest-3"] = { tier = 3, prog_tier = 4, material = "titanium", chest_type = "active-provider" },
	["bob-passive-provider-chest-3"] = { tier = 3, prog_tier = 4, material = "titanium", chest_type = "passive-provider" },
	["bob-storage-chest-3"] = { tier = 3, prog_tier = 4, material = "titanium", chest_type = "storage" },
	["bob-buffer-chest-3"] = { tier = 3, prog_tier = 4, material = "titanium", chest_type = "buffer" },
	["bob-requester-chest-3"] = { tier = 3, prog_tier = 4, material = "titanium", chest_type = "requester" },
}

-- Reskin entities, create and assign extra details
for name, map in pairs(logistic_map) do
	---@type data.LogisticContainerPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)

	-- Stick tier labels on the vanilla logistic chests
	if not map.material then
		reskins.lib.tiers.add_tier_labels_to_prototype_by_reference(tier, entity)
		goto continue
	end

	-- Construct inputs parameters
	inputs.base_entity_name = map.chest_type .. "-chest"
	inputs.icon_base = map.chest_type .. "-chest"
	inputs.icon_mask = map.material .. "-logistic-chest"
	inputs.tint = material_tints[map.material]

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	remnant.animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/logistic-chest/remnants/" .. map.chest_type .. "-chest-remnants.png",
				width = 116,
				height = 82,
				direction_count = 1,
				shift = util.by_pixel(10, -3),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/chest/remnants/" .. map.material .. "-logistic-chest-remnants.png",
				width = 116,
				height = 82,
				direction_count = 1,
				shift = util.by_pixel(10, -3),
				scale = 0.5,
			},
		},
	}

	-- Reskin entities
	entity.animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/logistic-chest/" .. map.chest_type .. "-chest.png",
				priority = "extra-high",
				width = 66,
				height = 74,
				frame_count = 7,
				shift = util.by_pixel(0, -2),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/chest/" .. map.material .. "-logistic-chest.png",
				priority = "extra-high",
				width = 66,
				height = 74,
				frame_count = 7,
				shift = util.by_pixel(0, -2),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__base__/graphics/entity/logistic-chest/logistic-chest-shadow.png",
				priority = "extra-high",
				width = 112,
				height = 46,
				repeat_count = 7,
				shift = util.by_pixel(12, 4.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	}

	::continue::
end

-- brass-chest
-- titanium-chest
