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
	type = "inserter",
	mod = "bobs",
	group = "logistics",
	particles = { ["medium"] = 1 },
}

local inserter_map
if reskins.lib.settings.get_value("bobmods-logistics-inserteroverhaul") == false then
	inserter_map = {
		-- Standard inserters
		["burner-inserter"] = { tier = 0 },
		["inserter"] = { tier = 1 },
		["long-handed-inserter"] = { tier = 2 },
		["fast-inserter"] = { tier = 3 },
		["bob-express-inserter"] = { tier = 4, particle_tint = "30d79c", file_name = "express-inserter" },

		-- Bulk inserters
		["bulk-inserter"] = { tier = 3 },
		["bob-express-bulk-inserter"] = { tier = 4, particle_tint = "2dcd3f", file_name = "express-bulk-inserter" },
	}
else
	inserter_map = {
		["burner-inserter"] = { tier = 0 },
	}
end

-- Inserter Remnants
local function inserter_remnants(parameters)
	return make_rotated_animation_variations_from_sheet(4, {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/standard/" .. parameters.file_name .. "/remnants/" .. parameters.file_name .. "-remnants.png",
		width = 134,
		height = 94,
		direction_count = 1,
		shift = util.by_pixel(3, -1.5),
		scale = 0.5,
	})
end

-- Inserter Arms
local function inserter_arm_picture(parameters)
	return {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/standard/" .. parameters.file_name .. "/" .. parameters.file_name .. "-arm.png",
		priority = "extra-high",
		width = 32,
		height = 136,
		scale = 0.25,
	}
end

local function inserter_arm_shadow()
	return {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/shadows/inserter-arm-shadow.png",
		priority = "extra-high",
		width = 32,
		height = 136,
		draw_as_shadow = true,
		scale = 0.25,
	}
end

-- Hand open, closed for bulk, standard, and long-handed inserters
local function inserter_hand_picture(parameters)
	return {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/standard/" .. parameters.file_name .. "/" .. parameters.hand_name .. "-hand-" .. parameters.hand .. ".png",
		priority = "extra-high",
		width = 130,
		height = 164,
		scale = 0.25,
	}
end

local function inserter_hand_shadow(parameters)
	-- Long-handed inserter types share a shadow with standard inserters
	if parameters.type == "long-inserter" then
		parameters.shadow = "inserter"
	else
		parameters.shadow = parameters.type
	end
	return {
		filename = "__reskins-bobs__/graphics/entity/logistics/inserter/shadows/" .. parameters.shadow .. "-hand-" .. parameters.hand .. "-shadow.png",
		priority = "extra-high",
		width = 130,
		height = 164,
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
				filename = "__reskins-bobs__/graphics/entity/logistics/inserter/standard/" .. parameters.file_name .. "/" .. parameters.file_name .. "-platform.png",
				priority = "extra-high",
				width = 106,
				height = 80,
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
	---@type data.InserterPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local file_name = map.file_name or name
	local tier = reskins.lib.tiers.get_tier(map)

	-- Only do complete setup for non-vanilla inserters
	if map.particle_tint then
		inputs.tint = util.color(map.particle_tint)
		inputs.make_explosions = true
		inputs.make_remnants = true
	else
		inputs.tint = nil
		inputs.make_explosions = false
		inputs.make_remnants = false
	end

	-- Handle base_entity
	if string.find(file_name, "bulk%-inserter") then
		inputs.base_entity_name = "bulk-inserter"
	else
		inputs.base_entity_name = "inserter"
	end

	-- Handle tier labels
	if reskins.lib.settings.get_value("reskins-bobs-do-inserter-tier-labeling") == false then
		inputs.tier_labels = false
	end

	inputs.icon_filename = "__reskins-bobs__/graphics/icons/logistics/inserter/standard/" .. file_name .. "-icon.png"

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Handle the type of inserter we're dealing with
	local inserter_type, hand_name
	if string.find(file_name, "bulk") then
		inserter_type = "bulk-inserter"
		hand_name = file_name
	elseif mods["bobinserters"] and file_name ~= "long-handed-inserter" then
		inserter_type = "long-inserter"
		hand_name = "long-" .. file_name
	else
		inserter_type = "inserter"
		hand_name = file_name
	end

	-- Fetch remnant
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnant
	remnant.animation = inserter_remnants({ file_name = file_name })

	-- Common to all inserters
	entity.hand_base_picture = inserter_arm_picture({ file_name = file_name })
	entity.hand_base_shadow = inserter_arm_shadow()
	entity.platform_picture = inserter_platform_picture({ file_name = file_name })

	-- Inserter hands
	entity.hand_open_picture = inserter_hand_picture({ file_name = file_name, hand_name = hand_name, hand = "open" })
	entity.hand_closed_picture = inserter_hand_picture({ file_name = file_name, hand_name = hand_name, hand = "closed" })
	entity.hand_open_shadow = inserter_hand_shadow({ type = inserter_type, hand = "open" })
	entity.hand_closed_shadow = inserter_hand_shadow({ type = inserter_type, hand = "closed" })

	::continue::
end
