-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.sprites.pipes" then
	return require("__reskins-library__.api.sprites.pipes")
end

--- Provides methods for getting sprites for pipe-type entities.
---
---### Examples
---```lua
---local _sprites = require("__reskins-library__.api.sprites.pipes")
---```
---@class Reskins.Lib.Sprites.Pipes
local _pipes = {}

---
---Gets an `Animation` object configured to draw a vertical pipe shadow at the given `shift`,
---for a single tile.
---
---### Returns
---@return data.Animation # A vertical pipe shadow for a single tile.
---
---### Remarks
---Conventional use is by non-pipe entities that have pipe connections, and need to dynamically
---draw a shadow at the connection point for a given rotation state, rather than bake the shadow
---into the entity's sprite.
---
---For example, the Artisanal Reskins: Bob's Mods greenhouse has a static main sprite and a single
---pipe connection that rotates freely. Rather than have four shadows baked into the main sprite,
---the greenhouse uses this function to draw a shadow at the connection point.
---
---### Examples
---```lua
----- Add a vertical pipe shadow in the north and south directions to the working_visualisations
----- field of an assembly machine prototype. The shadow will offset up 1 tile for north, and
----- down 1 tile for south, along the centerline of a 3 x 3 entity.
---local greenhouse = data.raw["assembling-machine"]["bob-greenhouse"]
---table.insert(greenhouse.working_visualisations, {
---    always_draw = true,
---    north_animation = _pipes.get_vertical_pipe_shadow({0, -1}),
---    south_animation = _pipes.get_vertical_pipe_shadow({0, 1}),
---)}
---```
---
---### Parameters
---@param shift data.Vector The shift to apply to the shadow. Typically whole-tile or half-tile increments.
---@nodiscard
function _pipes.get_vertical_pipe_shadow(shift)
	---@type data.Animation
	local shadow_animation = {
		filename = "__reskins-library__/graphics/entity/common/pipe-patches/vertical-pipe-shadow-patch.png",
		priority = "high",
		width = 128,
		height = 128,
		draw_as_shadow = true,
		shift = shift,
		scale = 0.5,
	}

	return shadow_animation
end

---
---Gets an `Animation` object configured to draw a horizontal pipe shadow at the given `shift`,
---for a single tile.
---
---### Returns
---@return data.Animation # A horizontal pipe shadow for a single tile.
---
---### Remarks
---Conventional use is by non-pipe entities that have pipe connections, and need to dynamically
---draw a shadow at the connection point for a given rotation state, rather than bake the shadow
---into the entity's sprite.
---
---### Examples
---```lua
----- Add a horizontal pipe shadow in the north and south directions to the working_visualisations
----- field of an assembly machine prototype. The shadow will offset right 1 tile for east, and
----- left 1 tile for west, along the centerline of a 3 x 3 entity.
---local greenhouse = data.raw["assembling-machine"]["bob-greenhouse"]
---table.insert(greenhouse.working_visualisations, {
---    always_draw = true,
---    east_animation = _pipes.get_horizontal_pipe_shadow({1, 0}),
---    west_animation = _pipes.get_horizontal_pipe_shadow({-1, 0}),
---)}
---```
---
---### Parameters
---@param shift data.Vector The shift to apply to the shadow. Typically whole-tile or half-tile increments.
---@nodiscard
function _pipes.get_horizontal_pipe_shadow(shift)
	---@type data.Animation
	local shadow_animation = {
		filename = "__reskins-library__/graphics/entity/common/pipe-patches/horizontal-pipe-shadow-patch.png",
		priority = "high",
		width = 128,
		height = 128,
		draw_as_shadow = true,
		shift = shift,
		scale = 0.5,
	}

	return shadow_animation
end

---@alias PipeNamePrefix
---| '"brass"'
---| '"bronze"'
---| '"ceramic"'
---| '"copper"'
---| '"copper-tungsten"'
---| '"nitinol"'
---| '"plastic"'
---| '"steel"'
---| '"stone"'
---| '"titanium"'
---| '"tungsten"'

---@alias PipeMaterialType
---| '"angels-ceramic"'
---| '"angels-nitinol"'
---| '"angels-titanium"'
---| '"angels-tungsten"'
---| '"brass"'
---| '"bronze"'
---| '"ceramic"'
---| '"copper"'
---| '"copper-tungsten"'
---| '"iron"'
---| '"nitinol"'
---| '"plastic"'
---| '"steel"'
---| '"stone"'
---| '"titanium"'
---| '"tungsten"'

---
---Gets the path to the sprites for the given `folder_name` and `material_type`.
---
---### Returns
---@return string # The path to the sprites for the given `folder_name` and `material_type`. Includes the trailing slash.
---
---### Examples
---```lua
----- Get the path to the sprites for iron pipes.
---local path = _pipes.get_path_to_pipe_material_sprites("pipe", "iron")
---
----- Which has the following value:
---path = "__reskins-library__/graphics/entity/common/pipe/iron/"
---```
---
---### Parameters
---@param folder_name string # The folder name of the prototype to get the path for.
---@param material_type PipeMaterialType # The type of material to get the path for.
---@nodiscard
local function get_path_to_pipe_material_sprites(folder_name, material_type)
	local path
	if material_type == "iron" then
		path = "__reskins-library__/graphics/entity/common/" .. folder_name .. "/iron/"
	elseif material_type:find("angels") then
		path = "__reskins-angels__/graphics/entity/smelting/" .. folder_name .. "/" .. material_type:gsub("angels%-", "") .. "/"
	else
		path = "__reskins-bobs__/graphics/entity/logistics/" .. folder_name .. "/" .. material_type .. "/"
	end

	return path
end

---
---Gets a `PipePictures` object containing pipe sprites in the given `material_type`.
---
---### Returns
---@return data.PipePictures # The complete set of pipe sprites in the given `material_type`.
---
---### Examples
---```lua
----- Update the pipe sprites for the bronze pipes.
---local pipe_entity = data.raw["pipe"]["bronze-pipe"]
---
---pipe_entity.pictures = _pipes.get_pipe_pictures("bronze")
---```
---
---### Parameters
---@param material_type PipeMaterialType # The material type to get sprites for.
---@nodiscard
function _pipes.get_pipe(material_type)
	local path = get_path_to_pipe_material_sprites("pipe", material_type)

	---@type data.PipePictures
	local pipe_pictures = {
		straight_vertical_single = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-straight-vertical-single.png",
					priority = "extra-high",
					width = 160,
					height = 160,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-straight-vertical-single-shadow.png",
					priority = "extra-high",
					width = 160,
					height = 160,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		straight_vertical = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-straight-vertical.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		straight_vertical_window = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-straight-vertical-window.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-straight-vertical-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		straight_horizontal_window = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-straight-horizontal-window.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		straight_horizontal = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-straight-horizontal.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-straight-horizontal-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		corner_up_right = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-corner-up-right.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-corner-up-right-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		corner_up_left = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-corner-up-left.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-corner-up-left-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		corner_down_right = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-corner-down-right.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-corner-down-right-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		corner_down_left = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-corner-down-left.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-corner-down-left-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		t_up = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-t-up.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-t-up-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		t_down = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-t-down.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-t-down-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		t_right = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-t-right.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-t-right-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		t_left = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-t-left.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-t-left-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		cross = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-cross.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-cross-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		ending_up = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-ending-up.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-ending-up-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		ending_down = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-ending-down.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-ending-down-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		ending_right = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-ending-right.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-ending-right-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		ending_left = {
			layers = {
				-- Base
				{
					filename = path .. "pipe-ending-left.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe/shadows/pipe-ending-left-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		horizontal_window_background = {
			filename = path .. "pipe-horizontal-window-background.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
		},
		vertical_window_background = {
			filename = path .. "pipe-vertical-window-background.png",
			priority = "extra-high",
			width = 128,
			height = 128,
			scale = 0.5,
		},
		fluid_background = {
			filename = "__base__/graphics/entity/pipe/fluid-background.png",
			priority = "extra-high",
			width = 64,
			height = 40,
			scale = 0.5,
		},
		low_temperature_flow = {
			filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
			priority = "extra-high",
			width = 160,
			height = 18,
		},
		middle_temperature_flow = {
			filename = "__base__/graphics/entity/pipe/fluid-flow-medium-temperature.png",
			priority = "extra-high",
			width = 160,
			height = 18,
		},
		high_temperature_flow = {
			filename = "__base__/graphics/entity/pipe/fluid-flow-high-temperature.png",
			priority = "extra-high",
			width = 160,
			height = 18,
		},
		gas_flow = {
			filename = "__base__/graphics/entity/pipe/steam.png",
			priority = "extra-high",
			line_length = 10,
			width = 48,
			height = 30,
			frame_count = 60,
		},
	}

	return pipe_pictures
end

---
---Gets a `PipeToGroundPictures` object containing pipe-to-ground sprites in the given
---`material_type`.
---
---### Returns
---@return data.Sprite4Way # The complete set of pipe-to-ground sprites in the given `material_type`.
---
---### Examples
---```lua
----- Update the pipe-to-ground sprites for the bronze pipes.
---local pipe_to_ground_entity = data.raw["pipe-to-ground"]["bronze-pipe"]
---
---pipe_to_ground_entity.pictures = _pipes.get_pipe_to_ground_pictures("bronze")
---```
---
---### Parameters
---@param material_type PipeMaterialType # The material type to get sprites for.
---@nodiscard
function _pipes.get_pipe_to_ground(material_type)
	local path = get_path_to_pipe_material_sprites("pipe-to-ground", material_type)

	---@type data.Sprite4Way
	local pipe_to_ground_pictures = {
		north = {
			layers = {
				-- Pipe
				{
					filename = path .. "pipe-to-ground-up.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-up-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		east = {
			layers = {
				-- Pipe
				{
					filename = path .. "pipe-to-ground-right.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-right-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		south = {
			layers = {
				-- Pipe
				{
					filename = path .. "pipe-to-ground-down.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-down-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
		west = {
			layers = {
				-- Pipe
				{
					filename = path .. "pipe-to-ground-left.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				-- Shadows
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-to-ground/shadows/pipe-to-ground-left-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					draw_as_shadow = true,
					scale = 0.5,
				},
			},
		},
	}

	return pipe_to_ground_pictures
end

---
---Gets a `Sprite4Way` object containing pipe cover sprites in the given `material_type`.
---
---### Returns
---@return data.Sprite4Way # The complete set of pipe cover sprites in the given `material_type`.
---
---### Examples
---```lua
----- Update the pipe cover sprites on the bronze pipe fluid box.
---local pipe_entity = data.raw["pipe"]["bronze-pipe"]
---
---pipe_entity.fluid_box.pipe_covers = _pipes.get_pipe_covers("bronze")
---```
---
---### Parameters
---@param material_type PipeMaterialType # The material type to get sprites for.
---@nodiscard
function _pipes.get_pipe_covers(material_type)
	local path = get_path_to_pipe_material_sprites("pipe-covers", material_type)

	---@type data.Sprite4Way
	local pipe_cover_pictures = {
		north = {
			layers = {
				{
					filename = path .. "pipe-cover-north.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-covers/shadows/pipe-cover-north-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
					draw_as_shadow = true,
				},
			},
		},
		east = {
			layers = {
				{
					filename = path .. "pipe-cover-east.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-covers/shadows/pipe-cover-east-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
					draw_as_shadow = true,
				},
			},
		},
		south = {
			layers = {
				{
					filename = path .. "pipe-cover-south.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-covers/shadows/pipe-cover-south-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
					draw_as_shadow = true,
				},
			},
		},
		west = {
			layers = {
				{
					filename = path .. "pipe-cover-west.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
				},
				{
					filename = "__reskins-library__/graphics/entity/common/pipe-covers/shadows/pipe-cover-west-shadow.png",
					priority = "extra-high",
					width = 128,
					height = 128,
					scale = 0.5,
					draw_as_shadow = true,
				},
			},
		},
	}

	return pipe_cover_pictures
end

---
---Gets a `RotatedAnimationVariations` object containing pipe remnant sprites in the given
---`material_type`.
---
---### Returns
---@return data.Sprite4Way # The complete set of remnant sprites in the given `material_type`.
---
---### Examples
---```lua
----- Update the remnant sprites on the bronze pipe corpse.
---local pipe_remnants = data.raw["corpse"]["bronze-pipe-remnants"]
---
---pipe_remnants.animation = _pipes.get_pipe_remnants("bronze")
---```
---
---### Parameters
---@param material_type PipeMaterialType # The material type to get sprites for.
---@nodiscard
function _pipes.get_pipe_remnants(material_type)
	local path = get_path_to_pipe_material_sprites("pipe", material_type)

	---@type data.RotatedAnimationVariations
	local animation = make_rotated_animation_variations_from_sheet(2, {
		filename = path .. "remnants/pipe-remnants.png",
		width = 122,
		height = 120,
		direction_count = 2,
		shift = util.by_pixel(1.5, 2.5),
		scale = 0.5,
	})

	return animation
end

---
---Gets a `RotatedAnimationVariations` object containing pipe remnant sprites in the given
---`material_type`.
---
---### Returns
---@return data.Sprite4Way # The complete set of remnant sprites in the given `material_type`.
---
---### Examples
---```lua
----- Update the remnant sprites on the bronze pipe-to-ground corpse.
---local pipe_to_ground_remnants = data.raw["corpse"]["bronze-pipe-to-ground-remnants"]
---
---pipe_to_ground_remnants.animation = _pipes.get_pipe_to_ground_remnants("bronze")
---```
---
---### Parameters
---@param material_type PipeMaterialType # The material type to get sprites for.
---@nodiscard
function _pipes.get_pipe_to_ground_remnants(material_type)
	local path = get_path_to_pipe_material_sprites("pipe-to-ground", material_type)

	---@type data.RotatedAnimationVariations
	local animation = {
		filename = path .. "remnants/pipe-to-ground-remnants.png",
		width = 90,
		height = 80,
		shift = util.by_pixel(0.5, -3),
		scale = 0.5,
	}

	return animation
end

return _pipes
