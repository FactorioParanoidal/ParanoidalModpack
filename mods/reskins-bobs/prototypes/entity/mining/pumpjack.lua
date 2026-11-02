-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.mining.entities) then
	return
end

-- Set input parameters
local inputs = {
	type = "mining-drill",
	icon_name = "pumpjack",
	base_entity_name = "pumpjack",
	mod = "bobs",
	group = "mining",
	particles = { ["small"] = 3 },
}

local tier_map = {
	["pumpjack"] = { tier = 1, prog_tier = 2 },
	["bob-pumpjack-1"] = { tier = 2, prog_tier = 3 },
	["bob-pumpjack-2"] = { tier = 3, prog_tier = 4 },
	["bob-pumpjack-3"] = { tier = 4, prog_tier = 5 },
	["bob-water-miner-1"] = { tier = 1, is_water_miner = true },
	["bob-water-miner-2"] = { tier = 2, is_water_miner = true },
	["bob-water-miner-3"] = { tier = 3, is_water_miner = true },
	["bob-water-miner-4"] = { tier = 4, is_water_miner = true },
}

-- Rescale pumpjack animation playback speed to something visually appealing
local max_playback = 2 -- Maximum animation playback speed
local min_playback = 0.5 -- Minimum animation playback speed

local pumpjack_speeds = {}
local index = 1

-- Loop through all the pumpjacks, figure out the mining speeds
for name, _ in pairs(tier_map) do
	---@type data.MiningDrillPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	-- Fetch mining speed
	pumpjack_speeds[index] = data.raw[inputs.type][name].mining_speed
	index = index + 1

	::continue::
end

-- Determine max and min mining speeds
table.sort(pumpjack_speeds)
local max_speed = pumpjack_speeds[#pumpjack_speeds]
local min_speed = pumpjack_speeds[1]

---@param tint data.Color
---@param is_water_miner boolean When `true`, uses the water pumpjack base sprite, otherwise, uses the pumpjack base sprite.
---@return data.RotatedAnimation
local function get_remnant_animation(tint, is_water_miner)
	---@type data.RotatedAnimation
	local remnant_animation = {
		layers = {
			-- Base
			{
				filename = is_water_miner and "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/water-pumpjack-remnants-base.png" or "__base__/graphics/entity/pumpjack/remnants/pumpjack-remnants.png",
				width = 274,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(0, 3.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/pumpjack-remnants-mask.png",
				width = 274,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(0, 3.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/remnants/pumpjack-remnants-highlights.png",
				width = 274,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(0, 3.5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return remnant_animation
end

-- Reskin entities, create and assign extra details
for name, map in pairs(tier_map) do
	---@type data.MiningDrillPrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end
	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	-- Setup icon base details
	if map.is_water_miner then
		inputs.icon_base = "water-pumpjack"
	else
		inputs.icon_base = "pumpjack"
	end

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Calculate new animation speed
	local animation_speed
	if max_speed - min_speed == 0 then
		animation_speed = entity.mining_speed
	else
		animation_speed = ((entity.mining_speed / (max_speed - min_speed)) - (min_speed / (max_speed - min_speed))) * max_playback + ((max_speed / (max_speed - min_speed)) - (entity.mining_speed / (max_speed - min_speed))) * min_playback
	end

	-- Reskin base particles if we're a water pump
	if map.is_water_miner then
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["big"], 1, util.color("#3083bf"))
		reskins.lib.create_particle(name, inputs.base_entity_name, reskins.lib.particle_index["medium"], 2, util.color("#3083bf"))
	end

	-- Fetch remnants
	local remnant = data.raw["corpse"][name .. "-remnants"]

	-- Reskin remnants
	local remnant_animation = get_remnant_animation(inputs.tint, map.is_water_miner)
	remnant.animation = make_rotated_animation_variations_from_sheet(2, remnant_animation)

	-- Reskin entities
	-- Factorio 2.1: the pumpjack base is an always drawn working visualisation (base_picture was removed, Bob's pumpjacks
	-- copy the 2.1 vanilla graphics). Only the water miners get their own base, in place of Bob's water miner base.
	if map.is_water_miner then
		local visualisations = entity.graphics_set and entity.graphics_set.working_visualisations
		local base = visualisations and visualisations[1]
		if base and base.always_draw then
			for _, direction in pairs({ "north", "east", "south", "west" }) do
				local animation = base[direction .. "_animation"]
				local layer = animation and animation.layers and animation.layers[1]
				if layer then
					layer.filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/water-pumpjack-base.png"
				end
			end
		end
	end

	entity.graphics_set.animation = {
		north = {
			layers = {
				-- Base (Factorio 2.1: the vanilla horsehead was redrawn with 206x172 frames; the water miner art keeps 2.0 frames)
				{
					priority = "high",
					filename = map.is_water_miner and "__reskins-bobs__/graphics/entity/mining/pumpjack/water-pumpjack-horsehead.png" or "__base__/graphics/entity/pumpjack/pumpjack-horsehead.png",
					animation_speed = animation_speed,
					repeat_count = 6,
					scale = 0.5,
					line_length = 8,
					width = 206,
					height = map.is_water_miner and 202 or 172,
					frame_count = 40,
					shift = map.is_water_miner and util.by_pixel(-4, -24) or util.by_pixel(-4.5, -29),
				},
				-- Mask
				{
					priority = "high",
					filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/pumpjack-horsehead-mask.png",
					animation_speed = animation_speed,
					repeat_count = 6,
					scale = 0.5,
					line_length = 8,
					width = 206,
					height = 202,
					frame_count = 40,
					shift = util.by_pixel(-4, -24),
					tint = inputs.tint,
				},
				-- Highlights
				{
					priority = "high",
					filename = "__reskins-bobs__/graphics/entity/mining/pumpjack/pumpjack-horsehead-highlights.png",
					animation_speed = animation_speed,
					repeat_count = 6,
					scale = 0.5,
					line_length = 8,
					width = 206,
					height = 202,
					frame_count = 40,
					shift = util.by_pixel(-4, -24),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				},
				-- Shadow (Factorio 2.1 vanilla frames 292x78)
				{
					priority = "high",
					filename = "__base__/graphics/entity/pumpjack/pumpjack-horsehead-shadow.png",
					animation_speed = animation_speed,
					repeat_count = 6,
					draw_as_shadow = true,
					line_length = 8,
					width = 292,
					height = 78,
					frame_count = 40,
					scale = 0.5,
					shift = util.by_pixel(17.75, 14.5),
				},
			},
		},
	}
	-- Factorio 2.1: a flipped pumpjack draws graphics_set_flipped (its own flipped base); the head is the same.
	if entity.graphics_set_flipped then
		entity.graphics_set_flipped.animation = util.copy(entity.graphics_set.animation)
	end

	::continue::
end
