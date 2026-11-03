-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Factorio 2.1 removed the 2.0 oil refinery art (the base game draws a new model per direction) that the masks
-- below are drawn for. Paranoidal decision G18 "A" (2026-11-03): the refinery family keeps the 2.0 look with the
-- tier colours, so the 2.0 files are kept as copies (Factorio 2.0.77, unchanged) in graphics/entity/base/oil-refinery/base-2.0/.

---Provides vanilla-style sprite definition for oil refinery `animation` field. See [Prototype/AssemblingMachine](https://wiki.factorio.com/Prototype/AssemblingMachine).
---@param tint data.Color
---@return table animation # [Types/Animation4Way](https://wiki.factorio.com/Types/Animation4Way)
local function entity_animation(tint)
	return reskins.lib.sprites.make_4way_animation_from_spritesheet({
		layers = {
			-- Base
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/oil-refinery.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/oil-refinery-mask.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/oil-refinery-highlights.png",
				width = 386,
				height = 430,
				shift = util.by_pixel(0, -7.5),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/oil-refinery-shadow.png",
				width = 674,
				height = 426,
				shift = util.by_pixel(82.5, 26.5),
				draw_as_shadow = true,
				scale = 0.5,
			},
		},
	})
end

---Provides vanilla-style sprite definition for oil refinery corpse `animation` field. See [Prototype/Corpse](https://wiki.factorio.com/Prototype/Corpse).
---@param tint data.Color
---@return data.RotatedAnimationVariations
local function corpse_animation(tint)
	---@type data.RotatedAnimation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/remnants/refinery-remnants.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25), --moved from -8.5 to -4.5
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/remnants/refinery-remnants-mask.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/remnants/refinery-remnants-highlights.png",
				width = 467,
				height = 415,
				direction_count = 1,
				shift = util.by_pixel(-0.25, -0.25),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
		},
	}

	return make_rotated_animation_variations_from_sheet(1, animation)
end

-- Factorio 2.1: the working visualisations, the water reflection and the circuit connector of the base-game refinery
-- belong to its new model; under the 2.0 art they are set back to the Factorio 2.0.77 definitions (flame and light,
-- reflection, connector placement and the default position of the module icons).

---@param direction_x integer # column of the light sheet (north 0, east 1, south 2, west 3)
local function light_2_0(direction_x)
	return {
		filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/oil-refinery-light.png",
		width = 321,
		x = 321 * direction_x,
		height = 205,
		blend_mode = "additive",
		draw_as_glow = true,
		shift = util.by_pixel(-1, -50),
		scale = 0.5,
	}
end

---@return data.WorkingVisualisation[]
local function working_visualisations_2_0()
	return {
		{
			fadeout = true,
			constant_speed = true,
			north_position = util.by_pixel(34, -65),
			east_position = util.by_pixel(-52, -61),
			south_position = util.by_pixel(-59, -82),
			west_position = util.by_pixel(57, -58),
			animation = {
				filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/oil-refinery-fire.png",
				line_length = 10,
				width = 40,
				height = 81,
				frame_count = 60,
				animation_speed = 0.75,
				scale = 0.5,
				draw_as_glow = true,
				shift = util.by_pixel(0, -14.25),
			},
		},
		{
			fadeout = true,
			north_animation = light_2_0(0),
			east_animation = light_2_0(1),
			south_animation = light_2_0(2),
			west_animation = light_2_0(3),
		},
	}
end

---@return data.WaterReflectionDefinition
local function water_reflection_2_0()
	return {
		pictures = {
			filename = "__reskins-library__/graphics/entity/base/oil-refinery/base-2.0/oil-refinery-reflection.png",
			priority = "extra-high",
			width = 40,
			height = 48,
			shift = util.by_pixel(5, 95),
			variation_count = 4,
			scale = 5,
		},
		rotate = false,
		orientation_to_variation = true,
	}
end

---@return data.CircuitConnectorDefinition[]
local function circuit_connector_2_0()
	return circuit_connector_definitions.create_vector(universal_connector_template, {
		{ variation = 17, main_offset = util.by_pixel(-45, -29.5), shadow_offset = util.by_pixel(48.5, 11), show_shadow = true },
		{ variation = 19, main_offset = util.by_pixel(29.5, -24), shadow_offset = util.by_pixel(81, 53), show_shadow = true },
		{ variation = 19, main_offset = util.by_pixel(29.5, -24), shadow_offset = util.by_pixel(82.5, 65.5), show_shadow = true },
		{ variation = 17, main_offset = util.by_pixel(-8, -35.5), shadow_offset = util.by_pixel(86.5, 77.5), show_shadow = true },
	})
end

---Reskins the named assembling machine with vanilla-style oil refinery sprites and color masking, and sets up appropriate corpse, explosion, and particle prototypes
---@param name string # [Prototype name](https://wiki.factorio.com/PrototypeBase#name)
---@param tier integer # 1-6 are supported, 0 to disable
---@param tint? data.Color
---@param make_tier_labels? boolean
function reskins.lib.apply_skin.oil_refinery(name, tier, tint, make_tier_labels)
	---@type SetupStandardEntityInputs
	local inputs = {
		type = "assembling-machine",
		icon_name = "oil-refinery",
		base_entity_name = "oil-refinery",
		mod = "lib",
		group = "base",
		particles = { ["big-tint"] = 5, ["medium"] = 2 },
		tier_labels = make_tier_labels,
		tint = tint and tint or reskins.lib.tiers.get_tint(tier),
	}

	---@type data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		return
	end

	inputs.defer_to_data_updates = true -- angelspetrochem > 0.9.19 modifies icon in data-updates

	reskins.lib.setup_standard_entity(name, tier, inputs)

	-- Fetch corpse
	local corpse = data.raw["corpse"][name .. "-remnants"]

	-- Reskin corpse
	corpse.animation = corpse_animation(inputs.tint)

	-- Reskin entity
	entity.graphics_set.animation = entity_animation(inputs.tint)
	entity.graphics_set.working_visualisations = working_visualisations_2_0()
	entity.water_reflection = water_reflection_2_0()
	entity.circuit_connector = circuit_connector_2_0()
	entity.icons_positioning = nil
end
