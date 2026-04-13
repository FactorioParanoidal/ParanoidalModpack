-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.assembly.entities) then
	return
end

-- Flag available for Mini-Machines compatibility pass
if reskins.compatibility then
	reskins.compatibility.triggers.minimachines.centrifuges = true
end

-- Set input parameters
local inputs = {
	type = "assembling-machine",
	icon_name = "centrifuge",
	base_entity_name = "centrifuge",
	mod = "bobs",
	group = "assembly",
	particles = { ["big"] = 1, ["medium"] = 2 },
}

local tier_map = {
	["centrifuge"] = { tier = 1, prog_tier = 3 },
	["bob-centrifuge-2"] = { tier = 2, prog_tier = 4 },
	["bob-centrifuge-3"] = { tier = 3, prog_tier = 5 },
}

for name, map in pairs(tier_map) do
	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	local tier = reskins.lib.tiers.get_tier(map)
	inputs.tint = reskins.lib.tiers.get_tint(tier)

	reskins.lib.setup_standard_entity(name, tier, inputs)

	local remnant = data.raw["corpse"][name .. "-remnants"]
	remnant.animation = make_rotated_animation_variations_from_sheet(1, {
		layers = {
			-- Base
			{
				filename = "__base__/graphics/entity/centrifuge/remnants/centrifuge-remnants.png",
				width = 286,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/remnants/centrifuge-remnants-mask.png",
				width = 286,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				tint = inputs.tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/remnants/centrifuge-remnants-highlights.png",
				width = 286,
				height = 284,
				direction_count = 1,
				shift = util.by_pixel(7, 4),
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
			},
		},
	})

	-- Reskin entities
	entity.graphics_set.idle_animation = {
		layers = {
			-- Centrifuge C
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-C.png",
				priority = "high",
				scale = 0.5,
				line_length = 8,
				width = 237,
				height = 214,
				frame_count = 64,
				shift = util.by_pixel(-0.25, -26.5),
			},
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-C-shadow.png",
				draw_as_shadow = true,
				priority = "high",
				scale = 0.5,
				line_length = 8,
				width = 279,
				height = 152,
				frame_count = 64,
				shift = util.by_pixel(16.75, -10),
			},
			-- Centrifuge B
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-B.png",
				priority = "high",
				scale = 0.5,
				line_length = 8,
				width = 156,
				height = 234,
				frame_count = 64,
				shift = util.by_pixel(23, 6.5),
			},
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-B-mask.png",
				priority = "high",
				tint = inputs.tint,
				scale = 0.5,
				line_length = 8,
				width = 156,
				height = 234,
				frame_count = 64,
				shift = util.by_pixel(23, 6.5),
			},
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-B-highlights.png",
				priority = "high",
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
				line_length = 8,
				width = 156,
				height = 234,
				frame_count = 64,
				shift = util.by_pixel(23, 6.5),
			},
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-B-shadow.png",
				draw_as_shadow = true,
				priority = "high",
				scale = 0.5,
				line_length = 8,
				width = 251,
				height = 149,
				frame_count = 64,
				shift = util.by_pixel(63.25, 15.25),
			},
			-- Centrifuge A
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-A.png",
				priority = "high",
				scale = 0.5,
				line_length = 8,
				width = 139,
				height = 246,
				frame_count = 64,
				shift = util.by_pixel(-26.25, 3.5),
			},
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-A-mask.png",
				priority = "high",
				tint = inputs.tint,
				scale = 0.5,
				line_length = 8,
				width = 139,
				height = 246,
				frame_count = 64,
				shift = util.by_pixel(-26.25, 3.5),
			},
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-A-highlights.png",
				priority = "high",
				blend_mode = reskins.lib.settings.blend_mode, -- "additive",
				scale = 0.5,
				line_length = 8,
				width = 139,
				height = 246,
				frame_count = 64,
				shift = util.by_pixel(-26.25, 3.5),
			},
			{
				filename = "__base__/graphics/entity/centrifuge/centrifuge-A-shadow.png",
				priority = "high",
				draw_as_shadow = true,
				scale = 0.5,
				line_length = 8,
				width = 230,
				height = 124,
				frame_count = 64,
				shift = util.by_pixel(8.5, 23.5),
			},
		},
	}

	entity.graphics_set.working_visualisations = {
		-- Area Light
		{
			effect = "uranium-glow",
			apply_recipe_tint = "primary",
			fadeout = true,
			light = { intensity = 0.1, size = 9.9, shift = { 0.0, 0.0 }, color = { r = 0.0, g = 1.0, b = 0.0 } },
		},

		-- Working Light
		{
			effect = "uranium-glow",
			fadeout = true,
			apply_recipe_tint = "primary",
			animation = {
				layers = {
					-- Centrifuge C
					{
						filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-C-light.png",
						priority = "high",
						scale = 0.5,
						blend_mode = "additive",
						line_length = 8,
						width = 190,
						height = 207,
						frame_count = 64,
						shift = util.by_pixel(0, -27.25),
						draw_as_glow = true,
					},
					-- Centrifuge B
					{
						filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-B-light.png",
						priority = "high",
						scale = 0.5,
						blend_mode = "additive",
						line_length = 8,
						width = 131,
						height = 206,
						frame_count = 64,
						shift = util.by_pixel(16.75, 0.5),
						draw_as_glow = true,
					},
					-- Centrifuge A
					{
						filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-A-light.png",
						priority = "high",
						scale = 0.5,
						blend_mode = "additive",
						line_length = 8,
						width = 108,
						height = 197,
						frame_count = 64,
						shift = util.by_pixel(-23.5, -1.75),
						draw_as_glow = true,
					},
				},
			},
		},
	}

	::continue::
end

-- entity.graphics_set.working_visualisations = {
--     -- WORKING LIGHTS
--     -- Centrifuge A (Front Left)
--     {
--         effect = "uranium-glow",
--         fadeout = true,
--         apply_recipe_tint = "primary",
--         animation = {
--             filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-A-light.png",
--             priority = "high",
--             scale = 0.5,
--             blend_mode = "additive",
--             line_length = 8,
--             width = 108,
--             height = 197,
--             frame_count = 64,
--             shift = util.by_pixel(-23.5, -1.75),
--             draw_as_glow = true,
--         },
--     },

--     -- Centrifuge B (Front Right)
--     {
--         effect = "uranium-glow",
--         fadeout = true,
--         apply_recipe_tint = "secondary",
--         animation = {
--             filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-B-light.png",
--             priority = "high",
--             scale = 0.5,
--             blend_mode = "additive",
--             line_length = 8,
--             width = 131,
--             height = 206,
--             frame_count = 64,
--             shift = util.by_pixel(16.75, 0.5),
--             draw_as_glow = true,
--         },
--     },

--     -- Centrifuge C (Rear)
--     {
--         effect = "uranium-glow",
--         fadeout = true,
--         apply_recipe_tint = "tertiary",
--         animation = {
--             filename = "__reskins-bobs__/graphics/entity/assembly/centrifuge/centrifuge-C-light.png",
--             priority = "high",
--             scale = 0.5,
--             blend_mode = "additive",
--             line_length = 8,
--             width = 190,
--             height = 207,
--             frame_count = 64,
--             shift = util.by_pixel(0, -27.25),
--             draw_as_glow = true,
--         }
--     },

--     -- AREA LIGHT
--     -- Centrifuge A (Front Left)
--     {
--         effect = "uranium-glow",
--         apply_recipe_tint = "primary",
--         fadeout = true,
--         light = {intensity = 0.066, size = 8.9, shift = {-1, 0.5}}
--     },

--     -- Centrifuge B (Front Right)
--     {
--         effect = "uranium-glow",
--         apply_recipe_tint = "secondary",
--         fadeout = true,
--         light = {intensity = 0.066, size = 8.9, shift = {1, 0.5}}
--     },

--     -- Centrifuge C (Rear)
--     {
--         effect = "uranium-glow",
--         apply_recipe_tint = "tertiary",
--         fadeout = true,
--         light = {intensity = 0.066, size = 8.9, shift = {0, -1.2}}
--     },
-- }
