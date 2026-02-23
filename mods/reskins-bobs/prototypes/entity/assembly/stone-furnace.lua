-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and (reskins.bobs.triggers.assembly.entities or reskins.bobs.triggers.plates.entities)) then
	return
end

local stone_furnace_map = {
	["stone-furnace"] = {
		type = "furnace",
		tint = reskins.bobs.furnace_tint_index.standard,
	},
	["bob-stone-mixing-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.mixing,
	},
	["bob-stone-chemical-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.chemical,
		is_chemical = true,
	},
}

---Defines the supported filenames for stone furnaces.
---@alias StoneFurnaceImageName
---| "stone-chemical-furnace"
---| "stone-furnace"

---Defines the supported filenames for mirrored stone furnaces.
---@alias MirroredStoneFurnaceImageName StoneFurnaceImageName
---| "stone-chemical-furnace-mirror"

---@alias StoneFurnaceLightOrientation
---| "bottom"
---| "left-front"
---| "left-rear"
---| "right-front"
---| "right-rear"

---Gets an animation built for the given `image_name`, tinted with `tint`.
---@param image_name MirroredStoneFurnaceImageName The name of the image to use.
---@param tint data.Color The tint to apply to the animation.
---@return data.Animation  --The animation for the given `image_name` type, tinted with `tint`.
local function get_stone_furnace_animation(image_name, tint)
	---@type data.Animation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/" .. image_name .. "-base.png",
				priority = "high",
				width = 152,
				height = 152,
				shift = util.by_pixel(0, 1),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/" .. image_name .. "-mask.png",
				priority = "high",
				width = 152,
				height = 152,
				tint = tint,
				shift = util.by_pixel(0, 1),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/" .. image_name .. "-highlights.png",
				priority = "high",
				width = 152,
				height = 152,
				blend_mode = reskins.lib.settings.blend_mode,
				shift = util.by_pixel(0, 1),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/shadows/" .. image_name .. "-shadow.png",
				priority = "high",
				width = 176,
				height = 140,
				draw_as_shadow = true,
				shift = util.by_pixel(12, 3),
				scale = 0.5,
			},
		},
	}

	return animation
end

--- Gets a remnants animation built for the given `image_name`, tinted with `tint`.
---@param image_name StoneFurnaceImageName The name of the image to use.
---@param tint data.Color The tint to apply to the animation.
---@return data.RotatedAnimation
local function get_stone_furnace_remnant_animation(image_name, tint)
	local count = image_name == "stone-furnace" and 1 or 4

	---@type data.RotatedAnimation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/remnants/" .. image_name .. "-remnants-base.png",
				width = 202,
				height = 180,
				line_length = count,
				direction_count = count,
				shift = util.by_pixel(2, 17),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/remnants/" .. image_name .. "-remnants-mask.png",
				width = 202,
				height = 180,
				line_length = count,
				direction_count = count,
				shift = util.by_pixel(2, 17),
				tint = tint,
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/remnants/" .. image_name .. "-remnants-highlights.png",
				width = 202,
				height = 180,
				line_length = count,
				direction_count = count,
				shift = util.by_pixel(2, 17),
				blend_mode = reskins.lib.settings.blend_mode,
				scale = 0.5,
			},
		},
	}
end

---Gets the working light animation for the stone furnace.
---
---When `orientation` is provided, the sprite is for the given orientation, otherwise the full sprite is returned.
---@param orientation? StoneFurnaceLightOrientation
---@return data.Animation
local function get_stone_furnace_working_light(orientation)
	local file_name = "stone-furnace-light"
	if orientation then
		file_name = file_name .. "-" .. orientation .. "-obscure"
	end

	---@type data.Animation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/assembly/stone-furnace/lights/" .. file_name .. ".png",
		blend_mode = "additive",
		draw_as_glow = true,
		width = 152,
		height = 172,
		repeat_count = 48,
		shift = util.by_pixel(0, 1),
		scale = 0.5,
	}

	return animation
end

---Gets the glow animation for the stone furnace.
---@return data.Animation
local function get_stone_furnace_ground_light()
	---@type data.Animation
	local animation = {
		filename = "__base__/graphics/entity/stone-furnace/stone-furnace-ground-light.png",
		blend_mode = "additive",
		draw_as_light = true,
		width = 116,
		height = 110,
		repeat_count = 48,
		shift = util.by_pixel(-1, 44),
		scale = 0.5,
	}

	return animation
end

---Gets the fire animation for the stone furnace.
---@return data.Animation
local function get_stone_furnace_fire_animation()
	---@type data.Animation
	local animation = {
		filename = "__base__/graphics/entity/stone-furnace/stone-furnace-fire.png",
		priority = "extra-high",
		width = 41,
		height = 100,
		line_length = 8,
		frame_count = 48,
		draw_as_glow = true,
		shift = util.by_pixel(-0.75, 5.5),
		scale = 0.5,
	}

	return animation
end

---Gets the water reflection of a generic stone furnace.
---@return data.WaterReflectionDefinition
local function get_stone_furnace_water_reflection()
	---@type data.WaterReflectionDefinition
	local water_reflection = {
		pictures = {
			filename = "__base__/graphics/entity/stone-furnace/stone-furnace-reflection.png",
			priority = "extra-high",
			width = 16,
			height = 16,
			shift = util.by_pixel(0, 35),
			variation_count = 1,
			scale = 5,
		},
		rotate = false,
		orientation_to_variation = false,
	}

	return water_reflection
end

---This method applies fixes to the fluid box of the given `entity`, by removing all pipe pictures
---from any defined fluid boxes and by setting `fluid_boxes_off_when_no_fluid_recipe` to `false`.
---@param entity data.FurnacePrototype|data.AssemblingMachinePrototype The entity to apply fixes to.
local function apply_fluid_box_fixes(entity)
	if entity.fluid_boxes then
		entity.fluid_boxes_off_when_no_fluid_recipe = false

		for _, fluid_box in pairs(entity.fluid_boxes) do
			fluid_box.pipe_picture = nil
		end
	end
end

for name, map in pairs(stone_furnace_map) do
	local inputs = {
		type = map.type,
		base_entity_name = "stone-furnace",
		directory = reskins.bobs.directory,
		mod = "bobs",
		group = "assembly",
		tint = map.tint,
		particles = { ["medium-stone"] = 2 },
		tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-furnace-tier-labeling") == true,
	}

	---@type data.FurnacePrototype|data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	inputs.icon_name = map.is_chemical and "stone-chemical-furnace" or "stone-furnace"

	reskins.lib.setup_standard_entity(name, 1, inputs)

	local remnant = data.raw["corpse"][name .. "-remnants"]
	remnant.animation = get_stone_furnace_remnant_animation(inputs.icon_name, inputs.tint)

	if map.is_chemical then
		apply_fluid_box_fixes(entity)

		local animation = get_stone_furnace_animation(inputs.icon_name, inputs.tint)
		entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet(animation)
		entity.graphics_set.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_fire_animation(),
				south_animation = get_stone_furnace_fire_animation(),
				west_animation = get_stone_furnace_fire_animation(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_working_light("right-rear"),
				east_animation = get_stone_furnace_working_light("bottom"),
				south_animation = get_stone_furnace_working_light("left-front"),
				west_animation = get_stone_furnace_working_light(),
			},

			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_ground_light(),
				south_animation = get_stone_furnace_ground_light(),
				west_animation = get_stone_furnace_ground_light(),
			},
		}

		local mirrored_animation = get_stone_furnace_animation(inputs.icon_name .. "-mirror", inputs.tint)
		entity.graphics_set_flipped = {}
		entity.graphics_set_flipped.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet(mirrored_animation)
		entity.graphics_set_flipped.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_fire_animation(),
				east_animation = get_stone_furnace_fire_animation(),
				south_animation = get_stone_furnace_fire_animation(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_working_light("left-rear"),
				east_animation = get_stone_furnace_working_light(),
				south_animation = get_stone_furnace_working_light("right-front"),
				west_animation = get_stone_furnace_working_light("bottom"),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_stone_furnace_ground_light(),
				east_animation = get_stone_furnace_ground_light(),
				south_animation = get_stone_furnace_ground_light(),
			},
		}
	else
		entity.graphics_set.animation = get_stone_furnace_animation(inputs.icon_name, inputs.tint)

		-- Handle working_visualisations
		entity.graphics_set.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				animation = get_stone_furnace_fire_animation(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				animation = get_stone_furnace_working_light(),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				animation = get_stone_furnace_ground_light(),
			},
		}
	end

	-- Handle ambient-light
	entity.energy_source.light_flicker = {
		color = { 0, 0, 0 },
		minimum_light_size = 0,
		light_intensity_to_size_coefficient = 0,
	}

	if name ~= "stone-furnace" then
		entity.graphics_set.water_reflection = get_stone_furnace_water_reflection()
	end

	::continue::
end
