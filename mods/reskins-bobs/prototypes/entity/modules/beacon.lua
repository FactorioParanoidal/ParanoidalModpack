-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if mods["classic-beacon"] or not (reskins.bobs and reskins.bobs.triggers.modules.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.beacons = true
end

-- Set input parameters
local inputs = {
	type = "beacon",
	icon_name = "beacon",
	base_entity_name = "beacon",
	mod = "bobs",
	group = "modules",
	particles = { ["small"] = 3 },
}

local tier_map = {
	["beacon"] = { tier = 1, prog_tier = 3 },
	["bob-beacon-2"] = { tier = 2, prog_tier = 4 },
	["bob-beacon-3"] = { tier = 3, prog_tier = 5 },
}

--- Gets an animation for the remnants of a beacon, tinted with `tint`.
---@param tint data.Color The tint to apply to the remnant.
---@return data.RotatedAnimation
local function get_beacon_remnant_animation(tint)
	---@type data.RotatedAnimation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/beacon/remnants/beacon-remnants.png",
				direction_count = 1,
				width = 212,
				height = 206,
				shift = util.by_pixel(1, 5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/modules/beacon/remnants/beacon-remnants-mask.png",
				direction_count = 1,
				width = 212,
				height = 206,
				shift = util.by_pixel(1, 5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/modules/beacon/remnants/beacon-remnants-highlights.png",
				direction_count = 1,
				width = 212,
				height = 206,
				shift = util.by_pixel(1, 5),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	}

	return animation
end

---Gets the base set of sprites for a beacon with the given `beacon_tier` and tinted with `tint`.
---@param beacon_tier 1|2|3 An integer corresponding to the sprite set to use for the base animation.
---@param tint data.Color The tint to apply to the base animation.
---@return data.AnimationElement
local function get_beacon_base_animation_element(beacon_tier, tint)
	---@type data.AnimationElement
	local animation_element = {
		render_layer = "floor-mechanics",
		animation = {
			layers = {
				-- Base
				{
					filename = "__bobmodules__/graphics/entity/beacon/beacon-" .. beacon_tier .. "-bottom.png",
					width = 212,
					height = 192,
					scale = 0.5,
					shift = util.by_pixel(0.5, 1),
				},
				-- Mask
				{
					filename = "__reskins-bobs__/graphics/entity/modules/beacon/beacon-" .. beacon_tier .. "-bottom-mask.png",
					width = 212,
					height = 192,
					shift = util.by_pixel(0.5, 1),
					tint = tint,
					scale = 0.5,
				},
				-- Highlights
				{
					filename = "__reskins-bobs__/graphics/entity/modules/beacon/beacon-" .. beacon_tier .. "-bottom-highlights.png",
					width = 212,
					height = 192,
					shift = util.by_pixel(0.5, 1),
					blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					scale = 0.5,
				},
				-- Shadow
				{
					filename = "__base__/graphics/entity/beacon/beacon-shadow.png",
					width = 244,
					height = 176,
					scale = 0.5,
					draw_as_shadow = true,
					shift = util.by_pixel(12.5, 0.5),
				},
			},
		},
	}

	return animation_element
end

---Gets the antenna sprite for a beacon with the given `beacon_tier`.
---@param beacon_tier 1|2|3 An integer corresponding to the sprite set to use for the antenna sprite.
---@return data.AnimationElement
local function get_beacon_antenna_top_animation_element(beacon_tier)
	---@type data.AnimationElement
	local animation_element = {
		animation = {
			filename = "__reskins-bobs__/graphics/entity/modules/beacon/beacon-" .. beacon_tier .. "-top.png",
			width = 96,
			height = 140,
			scale = 0.5,
			repeat_count = 45,
			animation_speed = 0.5,
			shift = util.by_pixel(3, -19),
		},
	}

	return animation_element
end

---Gets the light sprite for a beacon. When `apply_tint` is true, the light will be tinted by the active modules.
---@param apply_tint boolean Whether or not to apply tint to the light.
---@return data.AnimationElement
local function get_beacon_light_animation_element(apply_tint)
	---@type data.AnimationElement
	local animation_element = {
		apply_tint = apply_tint,
		always_draw = false,
		animation = {
			filename = "__base__/graphics/entity/beacon/beacon-light.png",
			line_length = 9,
			width = 110,
			height = 186,
			frame_count = 45,
			animation_speed = 0.5,
			scale = 0.5,
			shift = util.by_pixel(0.5, -18),
			blend_mode = "additive",
		},
	}

	return animation_element
end

---Gets the overlay sprite for a beacon with the given `beacon_tier` and tinted with `tint`. Only used for multi-slot beacons.
---
---The module slot overlay is used to correct visual oddities related to the multi-slot beacons.
---@param beacon_tier 2|3 An integer corresponding to the sprite set to use for the overlay.
---@param tint data.Color The tint to apply to the overlay.
---@return data.AnimationElement
local function get_module_slot_overlay(beacon_tier, tint)
	---@type data.AnimationElement
	local animation_element

	if beacon_tier == 2 then
		animation_element = {
			render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
			animation = {
				layers = {
					{
						filename = "__bobmodules__/graphics/entity/beacon/beacon-2-bottom-slot-overlay.png",
						width = 212,
						height = 192,
						scale = 0.5,
						shift = util.by_pixel(0.5, 1),
					},
				},
			},
		}
	elseif beacon_tier == 3 then
		animation_element = {
			render_layer = "transport-belt-circuit-connector", -- Above modules, below lights
			animation = {
				layers = {
					-- Base
					{
						filename = "__bobmodules__/graphics/entity/beacon/beacon-3-bottom-slot-overlay.png",
						width = 212,
						height = 192,
						scale = 0.5,
						shift = util.by_pixel(0.5, 1),
					},
					-- Mask
					{
						filename = "__reskins-bobs__/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-mask.png",
						width = 212,
						height = 192,
						scale = 0.5,
						shift = util.by_pixel(0.5, 1),
						tint = tint,
					},
					-- Highlights
					{
						filename = "__reskins-bobs__/graphics/entity/modules/beacon/beacon-3-bottom-slot-overlay-highlights.png",
						width = 212,
						height = 192,
						scale = 0.5,
						shift = util.by_pixel(0.5, 1),
						blend_mode = reskins.lib.settings.blend_mode, -- "additive",
					},
				},
			},
		}
	end

	return animation_element
end

local module_slots_to_tier_map = {
	[2] = 1,
	[4] = 2,
	[6] = 3,
}

for name, map in pairs(tier_map) do
	---@type data.BeaconPrototype
	local beacon = data.raw[inputs.type][name]
	if not beacon then
		goto continue
	end

	local tier = (reskins.lib.settings.get_value("reskins-lib-tier-mapping") == "progression-map") and map.prog_tier or map.tier

	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	local remnant = data.raw["corpse"][name .. "-remnants"]
	local remnant_animation = get_beacon_remnant_animation(inputs.tint)
	remnant.animation = make_rotated_animation_variations_from_sheet(2, remnant_animation)

	local beacon_tier = module_slots_to_tier_map[beacon.module_slots] or 1

	beacon.graphics_set.animation_list = {
		get_beacon_base_animation_element(beacon_tier, inputs.tint),
		get_beacon_antenna_top_animation_element(beacon_tier),
		get_beacon_light_animation_element(true),
		get_beacon_light_animation_element(false), -- Base has a second copy of the light animation without tint.
	}

	-- Multi-slot beacons require adjustment layers to patch oddities related to the module slots.
	if beacon_tier ~= 1 then
		table.insert(beacon.graphics_set.animation_list, get_module_slot_overlay(beacon_tier, inputs.tint))
	end

	::continue::
end
