-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.logistics.entities) then
	return
end
if not reskins.lib.settings.get_value("bobmods-logistics-inserteroverhaul") then
	return
end

-- Set input parameters
local inputs = {
	type = "inserter",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 1 },
	tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-inserter-tier-labeling") or false,
}

-- Determine inserter permutations
local bulk_inserter_icon_name = reskins.lib.settings.get_value("reskins-bobs-flip-bulk-inserter-icons") and "flipped-bulk-inserter" or "bulk-inserter"
local bulk_inserter_type = "bulk-inserter"

local inserter_icon_name = "inserter"
local inserter_type = (mods["bobinserters"] or reskins.lib.settings.get_value("bobmods-logistics-inserteroverhaul")) and "long-inserter" or "inserter"

local inserter_map = {
	-- Standard inserters
	["inserter"] = { tier = 1, type = inserter_type, icon_name = inserter_icon_name },
	["bob-red-inserter"] = { tier = 2, type = inserter_type, icon_name = inserter_icon_name },
	["long-handed-inserter"] = { tier = 2, type = inserter_type, icon_name = inserter_icon_name },
	["fast-inserter"] = { tier = 3, type = inserter_type, icon_name = inserter_icon_name },
	["bob-turbo-inserter"] = { tier = 4, type = inserter_type, icon_name = inserter_icon_name },
	["bob-express-inserter"] = { tier = 5, type = inserter_type, icon_name = inserter_icon_name },

	-- Bulk inserters
	["bob-red-bulk-inserter"] = { tier = 2, is_bulk_inserter = true, type = bulk_inserter_type, icon_name = bulk_inserter_icon_name },
	["bulk-inserter"] = { tier = 3, is_bulk_inserter = true, type = bulk_inserter_type, icon_name = bulk_inserter_icon_name },
	["bob-turbo-bulk-inserter"] = { tier = 4, is_bulk_inserter = true, type = bulk_inserter_type, icon_name = bulk_inserter_icon_name },
	["bob-express-bulk-inserter"] = { tier = 5, is_bulk_inserter = true, type = bulk_inserter_type, icon_name = bulk_inserter_icon_name },
}

-- Inserter Remnants
local function inserter_remnants(parameters)
	-- Remap long-inserter type to inserter
	local prefix = (parameters.type == "long-inserter") and "inserter" or parameters.type

	local remnant = make_rotated_animation_variations_from_sheet(4, {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/remnants/" .. prefix .. "-remnants-base.png",
				width = 134,
				height = 94,
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/remnants/" .. prefix .. "-remnants-mask.png",
				width = 134,
				height = 94,
				tint = parameters.tint,
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/remnants/" .. prefix .. "-remnants-highlights.png",
				width = 134,
				height = 94,
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				direction_count = 1,
				shift = util.by_pixel(3, -1.5),
				scale = 0.5,
			},
		},
	})
	return remnant
end

-- Inserter Arms
local function inserter_arm_picture(parameters)
	local arm_picture = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/arms/inserter-arm-base.png",
				priority = "extra-high",
				width = 32,
				height = 136,
				flags = { "no-crop" },
				scale = 0.25,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/arms/inserter-arm-mask.png",
				priority = "extra-high",
				width = 32,
				height = 136,
				flags = { "no-crop" },
				tint = parameters.tint,
				scale = 0.25,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/arms/inserter-arm-highlights.png",
				priority = "extra-high",
				width = 32,
				height = 136,
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.25,
			},
		},
	}

	return arm_picture
end

local function inserter_arm_shadow()
	return {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/shadows/inserter-arm-shadow.png",
		priority = "extra-high",
		width = 32,
		height = 136,
		flags = { "no-crop" },
		draw_as_shadow = true,
		scale = 0.25,
	}
end

-- Hand open, closed for bulk, standard, and long-handed inserters
local function inserter_hand_picture(parameters)
	local hand_picture = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/hands/" .. parameters.type .. "-hand-" .. parameters.hand .. "-base.png",
				priority = "extra-high",
				width = 130,
				height = 164,
				flags = { "no-crop" },
				scale = 0.25,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/hands/" .. parameters.type .. "-hand-" .. parameters.hand .. "-mask.png",
				priority = "extra-high",
				width = 130,
				height = 164,
				flags = { "no-crop" },
				tint = parameters.tint,
				scale = 0.25,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/hands/" .. parameters.type .. "-hand-" .. parameters.hand .. "-highlights.png",
				priority = "extra-high",
				width = 130,
				height = 164,
				flags = { "no-crop" },
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.25,
			},
		},
	}

	return hand_picture
end

local function inserter_hand_shadow(parameters)
	-- Long-handed inserter types share a shadow with standard inserters
	if parameters.type == "long-inserter" then
		parameters.shadow = "inserter"
	else
		parameters.shadow = parameters.type
	end
	return
	-- Shadow
	{
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/shadows/" .. parameters.shadow .. "-hand-" .. parameters.hand .. "-shadow.png",
		priority = "extra-high",
		width = 130,
		height = 164,
		flags = { "no-crop" },
		draw_as_shadow = true,
		scale = 0.25,
	}
end

-- Platform
local function inserter_platform_picture(parameters)
	return {
		sheets = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/platform/inserter-platform-base.png",
				priority = "extra-high",
				width = 106,
				height = 80,
				shift = util.by_pixel(1.75, 6.75),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/platform/inserter-platform-mask.png",
				priority = "extra-high",
				width = 106,
				height = 80,
				tint = parameters.tint,
				shift = util.by_pixel(1.75, 6.75),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/platform/inserter-platform-highlights.png",
				priority = "extra-high",
				width = 106,
				height = 80,
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				shift = util.by_pixel(1.75, 6.75),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/shadows/inserter-platform-shadow.png",
				priority = "extra-high",
				width = 106,
				height = 80,
				draw_as_shadow = true,
				shift = util.by_pixel(1.75, 6.75),
				scale = 0.5,
			},
		},
	}
end

-- Reskin entities, create and assign extra details
for name, map in pairs(inserter_map) do
	---@type SetupStandardEntityInputs
	local inputs = util.copy(inputs)

	---@type data.InserterPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Construct input properties from map properties
	inputs.base_entity_name = map.is_bulk_inserter and "bulk-inserter" or "inserter"
	inputs.icon_name = map.icon_name

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnant
	remnant.animation = inserter_remnants({ type = map.type, tint = inputs.tint })

	-- Common to all inserters
	entity.hand_base_picture = inserter_arm_picture({ tint = inputs.tint })
	entity.hand_base_shadow = inserter_arm_shadow()
	entity.platform_picture = inserter_platform_picture({ tint = inputs.tint })

	-- Inserter hands
	entity.hand_open_picture = inserter_hand_picture({ type = map.type, tint = inputs.tint, hand = "open" })
	entity.hand_closed_picture = inserter_hand_picture({ type = map.type, tint = inputs.tint, hand = "closed" })
	entity.hand_open_shadow = inserter_hand_shadow({ type = map.type, hand = "open" })
	entity.hand_closed_shadow = inserter_hand_shadow({ type = map.type, hand = "closed" })

	::continue::
end
