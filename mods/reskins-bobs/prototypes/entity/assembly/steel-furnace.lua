-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and (reskins.bobs.triggers.assembly.entities or reskins.bobs.triggers.plates.entities)) then
	return
end

---Defines the supported filenames for steel furnaces.
---@alias SteelFurnaceImageName
---| "fluid-steel-chemical-furnace"
---| "fluid-steel-furnace"
---| "steel-chemical-furnace"
---| "steel-furnace"

---Defines the supported filenames for mirrored steel furnaces.
---@alias MirroredSteelFurnaceImageName SteelFurnaceImageName
---| "fluid-steel-chemical-furnace-mirror"
---| "steel-chemical-furnace-mirror"

---Defines the supported filenames for working lights.
---@alias SteelFurnaceLightOrientation
---| "left"
---| "right"

local steel_furnace_map = {
	-- Standard furnaces
	["steel-furnace"] = {
		type = "furnace",
		tint = reskins.bobs.furnace_tint_index.standard,
	},
	["bob-fluid-furnace"] = {
		type = "furnace",
		tint = reskins.bobs.furnace_tint_index.standard,
		has_fluids = true,
		is_fluid_burning = true,
	},

	-- Mixing furnaces
	["bob-steel-mixing-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.mixing,
	},
	["bob-fluid-mixing-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.mixing,
		has_fluids = true,
		is_fluid_burning = true,
	},

	-- Chemical furnaces
	["bob-steel-chemical-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.chemical,
		has_fluids = true,
		is_chemical = true,
	},
	["bob-fluid-chemical-furnace"] = {
		type = "assembling-machine",
		tint = reskins.bobs.furnace_tint_index.chemical,
		has_fluids = true,
		is_fluid_burning = true,
		is_chemical = true,
	},
}

---Gets an animation built for the given `image_name`, tinted with `tint`.
---@param image_name MirroredSteelFurnaceImageName The name of the image to use.
---@param tint data.Color The tint to apply to the animation.
---@return data.Animation --The animation for the given `image_name` type, tinted with `tint`.
local function get_steel_furnace_animation(image_name, tint)
	---@type data.Animation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/" .. image_name .. "-base.png",
				priority = "high",
				width = 172,
				height = 174,
				shift = util.by_pixel(-1, 2),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/" .. image_name .. "-mask.png",
				priority = "high",
				width = 172,
				height = 174,
				tint = tint,
				shift = util.by_pixel(-1, 2),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/" .. image_name .. "-highlights.png",
				priority = "high",
				width = 172,
				height = 174,
				blend_mode = reskins.lib.settings.blend_mode,
				shift = util.by_pixel(-1, 2),
				scale = 0.5,
			},
			-- Shadow
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/shadows/" .. image_name .. "-shadow.png",
				priority = "high",
				width = 282,
				height = 142,
				draw_as_shadow = true,
				shift = util.by_pixel(38.5, 3.5),
				scale = 0.5,
			},
		},
	}

	return animation
end

--- Gets a remnants animation built for the given `image_name`, tinted with `tint`.
---@param image_name SteelFurnaceImageName The name of the image to use.
---@param tint data.Color The tint to apply to the animation.
---@return data.RotatedAnimation
local function get_steel_furnace_remnant_animation(image_name, tint)
	local count = image_name == "steel-furnace" and 1 or 4

	---@type data.RotatedAnimation
	local animation = {
		layers = {
			-- Base
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/remnants/" .. image_name .. "-remnants-base.png",
				width = 268,
				height = 238,
				line_length = count,
				direction_count = count,
				shift = util.by_pixel(4, 0.5),
				scale = 0.5,
			},
			-- Mask
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/remnants/" .. image_name .. "-remnants-mask.png",
				width = 268,
				height = 238,
				line_length = count,
				direction_count = count,
				tint = tint,
				shift = util.by_pixel(4, 0.5),
				scale = 0.5,
			},
			-- Highlights
			{
				filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/remnants/" .. image_name .. "-remnants-highlights.png",
				width = 268,
				height = 238,
				line_length = count,
				direction_count = count,
				blend_mode = reskins.lib.settings.blend_mode,
				shift = util.by_pixel(4, 0.5),
				scale = 0.5,
			},
		},
	}

	return animation
end

---Gets the working light animation for the steel furnace.
---
---When `orientation` is provided, the sprite is for the given orientation, otherwise the full sprite is returned.
---@param orientation? SteelFurnaceLightOrientation
---@return data.Animation
local function get_steel_furnace_working_light(orientation)
	local file_name = "steel-furnace-working"
	if orientation then
		file_name = "steel-furnace-working-" .. orientation
	end

	---@type data.Animation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/working/" .. file_name .. ".png",
		priority = "high",
		width = 172,
		height = 174,
		shift = util.by_pixel(-1, 2),
		blend_mode = "additive",
		draw_as_glow = true,
		scale = 0.5,
	}

	return animation
end

---Gets the glow animation for the steel furnace.
---@return data.Animation
local function get_steel_furnace_glow()
	---@type data.Animation
	local animation = {
		filename = "__base__/graphics/entity/steel-furnace/steel-furnace-glow.png",
		priority = "high",
		width = 60,
		height = 43,
		shift = { 0.03125, 0.640625 },
		blend_mode = "additive",
		draw_as_glow = true,
	}

	return animation
end

---Gets the fire animation for the steel furnace.
---@param orientation? SteelFurnaceLightOrientation
---@return data.Animation
local function get_steel_furnace_fire_animation(orientation)
	local file_name = "steel-furnace-fire"
	if orientation then
		file_name = "steel-furnace-fire-" .. orientation
	end

	---@type data.Animation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/working/" .. file_name .. ".png",
		priority = "high",
		line_length = 8,
		width = 57,
		height = 81,
		frame_count = 48,
		shift = util.by_pixel(-0.75, 5.75),
		draw_as_glow = true,
		scale = 0.5,
	}

	return animation
end

---Gets the ground light animation for the steel furnace.
---@param orientation? SteelFurnaceLightOrientation
---@return data.Animation
local function get_steel_furnace_ground_light(orientation)
	local file_name = "steel-furnace-ground-light"
	if orientation then
		file_name = "steel-furnace-ground-light-" .. orientation
	end

	---@type data.Animation
	local animation = {
		filename = "__reskins-bobs__/graphics/entity/assembly/steel-furnace/lights/" .. file_name .. ".png",
		priority = "high",
		draw_as_light = true,
		width = 152,
		height = 126,
		shift = util.by_pixel(1, 48),
		blend_mode = "additive",
		scale = 0.5,
	}

	return animation
end

---Gets the water reflection of a generic steel furnace.
---@return data.WaterReflectionDefinition
local function get_steel_furnace_water_reflection()
	---@type data.WaterReflectionDefinition
	local water_reflection = {
		pictures = {
			filename = "__base__/graphics/entity/steel-furnace/steel-furnace-reflection.png",
			priority = "extra-high",
			width = 20,
			height = 24,
			shift = util.by_pixel(0, 45),
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

	if entity.energy_source and entity.energy_source.fluid_box then
		entity.energy_source.fluid_box.pipe_picture = nil
	end
end

for name, map in pairs(steel_furnace_map) do
	local inputs = {
		type = map.type,
		base_entity_name = "steel-furnace",
		directory = reskins.bobs.directory,
		mod = "bobs",
		group = "assembly",
		tint = map.tint,
		particles = { ["medium"] = 2 },
		tier_labels = reskins.lib.settings.get_value("reskins-bobs-do-furnace-tier-labeling") == true,
	}

	---@type data.FurnacePrototype|data.AssemblingMachinePrototype
	local entity = data.raw[inputs.type][name]
	if not entity then
		goto continue
	end

	inputs.icon_name = map.is_chemical and "steel-chemical-furnace" or "steel-furnace"
	inputs.icon_base = map.is_fluid_burning and "fluid-" .. inputs.icon_name or inputs.icon_name

	reskins.lib.setup_standard_entity(name, 2, inputs)

	if map.is_chemical or map.is_fluid_burning then
		apply_fluid_box_fixes(entity)
	end

	local remnant = data.raw["corpse"][name .. "-remnants"]

	if map.has_fluids == true then
		remnant.animation = get_steel_furnace_remnant_animation(inputs.icon_base, inputs.tint)

		local animation = get_steel_furnace_animation(inputs.icon_base, inputs.tint)
		entity.graphics_set.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet(animation)
	else
		local animation = get_steel_furnace_remnant_animation(inputs.icon_base, inputs.tint)
		remnant.animation = make_rotated_animation_variations_from_sheet(1, animation)
		entity.graphics_set.animation = get_steel_furnace_animation(inputs.icon_base, inputs.tint)
	end

	if map.is_chemical then
		-- Only the chemical furnaces have mirrored sprites due to the asymmetry.
		local animation = get_steel_furnace_animation(inputs.icon_base .. "-mirror", inputs.tint)

		entity.graphics_set_flipped = {}
		entity.graphics_set_flipped.animation = reskins.lib.sprites.make_4way_animation_from_spritesheet(animation)
	end

	if map.is_chemical and map.is_fluid_burning then
		-- Skin the fluid-based steel chemical furnace working visualization
		entity.graphics_set.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				south_animation = get_steel_furnace_fire_animation("right"),
				west_animation = get_steel_furnace_fire_animation("left"),
			},
			-- Small glow around the furnace mouth
			{
				fadeout = true,
				effect = "flicker",
				south_animation = get_steel_furnace_glow(),
				west_animation = get_steel_furnace_glow(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				south_animation = get_steel_furnace_working_light("right"),
				west_animation = get_steel_furnace_working_light("left"),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				south_animation = get_steel_furnace_ground_light("right"),
				west_animation = get_steel_furnace_ground_light("left"),
			},
		}

		entity.graphics_set_flipped.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_fire_animation("right"),
				south_animation = get_steel_furnace_fire_animation("left"),
			},
			-- Small glow around the furnace mouth
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_glow(),
				south_animation = get_steel_furnace_glow(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_working_light("right"),
				south_animation = get_steel_furnace_working_light("left"),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_ground_light("right"),
				south_animation = get_steel_furnace_ground_light("left"),
			},
		}
	elseif map.is_chemical then
		-- Skin the steel chemical furnace working visualization
		entity.graphics_set.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_fire_animation(),
				south_animation = get_steel_furnace_fire_animation("right"),
				west_animation = get_steel_furnace_fire_animation(),
			},
			-- Small glow around the furnace mouth
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_glow(),
				south_animation = get_steel_furnace_glow(),
				west_animation = get_steel_furnace_glow(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_working_light(),
				south_animation = get_steel_furnace_working_light("right"),
				west_animation = get_steel_furnace_working_light(),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_ground_light(),
				south_animation = get_steel_furnace_ground_light("right"),
				west_animation = get_steel_furnace_ground_light(),
			},
		}

		entity.graphics_set_flipped.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_fire_animation(),
				east_animation = get_steel_furnace_fire_animation(),
				south_animation = get_steel_furnace_fire_animation("left"),
			},
			-- Small glow around the furnace mouth
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_glow(),
				east_animation = get_steel_furnace_glow(),
				south_animation = get_steel_furnace_glow(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_working_light(),
				east_animation = get_steel_furnace_working_light(),
				south_animation = get_steel_furnace_working_light("left"),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				north_animation = get_steel_furnace_ground_light(),
				east_animation = get_steel_furnace_ground_light(),
				south_animation = get_steel_furnace_ground_light("left"),
			},
		}
	elseif map.is_fluid_burning then
		-- Skin the fluid-based steel furnace working visualizations
		entity.graphics_set.working_visualisations = {
			-- Fire effect
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_fire_animation("right"),
				south_animation = get_steel_furnace_fire_animation(),
				west_animation = get_steel_furnace_fire_animation("left"),
			},
			-- Small glow around the furnace mouth
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_glow(),
				south_animation = get_steel_furnace_glow(),
				west_animation = get_steel_furnace_glow(),
			},
			-- Furnace flicker
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_working_light("right"),
				south_animation = get_steel_furnace_working_light(),
				west_animation = get_steel_furnace_working_light("left"),
			},
			-- Ground light
			{
				fadeout = true,
				effect = "flicker",
				east_animation = get_steel_furnace_ground_light("right"),
				south_animation = get_steel_furnace_ground_light(),
				west_animation = get_steel_furnace_ground_light("left"),
			},
		}
	end

	-- Overwrite any Bob-specific light behavior
	entity.energy_source.light_flicker = {
		color = { 0, 0, 0 },
		minimum_light_size = 0,
		light_intensity_to_size_coefficient = 0,
	}

	if name ~= "steel-furnace" then
		entity.graphics_set.water_reflection = get_steel_furnace_water_reflection()
	end

	::continue::
end
