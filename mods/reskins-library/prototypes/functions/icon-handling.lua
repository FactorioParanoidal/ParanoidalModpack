-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

----------------------------------------------------------------------------------------------------
-- TECHNOLOGY ICON FUNCTIONS
----------------------------------------------------------------------------------------------------

---@class ConstructTechnologyIconInputsOld
---@field mod "angels"|"bobs"|"lib"|"compatibility"
---@field group string # Folder under the `graphics/technology` folder.
---@field subgroup? string # Folder under the `group` folder, e.g. `group/subgroup`. Default `nil`.
---@field untinted_icon_mask? boolean # Overrides default tinting behavior; when `true`, will not apply `tint` to the mask layer.
---@field tint? data.Color # Expected if `untinted_icon_mask` is not `true`. If not provided, defaults to white ({1, 1, 1, 1}).
---@field technology_icon_filename? data.FileName # Required if `icon_name` is not defined.
---@field technology_icon_size? data.SpriteSizeType # Default `128`.
---@field icon_name? string # Required if `technology_icon_filename` is not defined. Specifies the folder/filenames to prepare the layered icon.
---@field icon_base? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the base layer
---@field icon_mask? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the mask layer
---@field icon_highlights? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the highlights layer
---@field technology_icon_extras? data.IconData[] # An array of `IconData` objects to append to the main icon.
---@field technology_icon_layers? 1|2|3 # Default 3 if used with `technology_icon_name`, 1 if used with `technology_icon_filename`, corresponds to the number of standard-form files to prepare
---@field defer_to_data_updates? boolean # When `true`, stores the icon for assignment at the end of data-updates. Expected if `defer_to_data_final_fixes` is not set.
---@field defer_to_data_final_fixes? boolean # When `true`, stores the icon for assignment at the end of data-final-fixes. Supercedes `defer_to_data_updates`. Expected if `defer_to_data_updates` is not set.

---comment
---@param name string # The name of the technology prototype.
---@param inputs ConstructTechnologyIconInputsOld
function reskins.lib.construct_technology_icon(name, inputs)
	---@type ConstructTechnologyIconInputsOld
	local inputs_copy = util.copy(inputs)

	--Set defaults
	inputs_copy.technology_icon_size = inputs_copy.technology_icon_size or 128

	-- Handle compatibility defaults
	local folder_path = inputs_copy.group
	if inputs_copy.subgroup then
		folder_path = inputs_copy.group .. "/" .. inputs_copy.subgroup
	end

	-- Handle mask tinting defaults
	local icon_tint = inputs_copy.tint
	if inputs_copy.untinted_icon_mask then
		icon_tint = nil
	end

	-- Handle icon_layers defaults
	local icon_layers
	if inputs_copy.technology_icon_filename then
		icon_layers = inputs_copy.technology_icon_layers or 1
	else
		icon_layers = inputs_copy.technology_icon_layers or 3
	end

	-- Some entities have variable bases and masks
	local icon_base = inputs_copy.icon_base or inputs_copy.icon_name
	local icon_mask = inputs_copy.icon_mask or inputs_copy.icon_name
	local icon_highlights = inputs_copy.icon_highlights or inputs_copy.icon_name

	-- Setup icon layers
	---@type data.IconData
	local icon_base_layer = {
		icon = inputs_copy.technology_icon_filename or reskins[inputs_copy.mod].directory .. "/graphics/technology/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_base .. "-technology-base.png",
		icon_size = inputs_copy.technology_icon_size,
	}

	---@type data.IconData, data.IconData
	local icon_mask_layer, icon_highlights_layer
	if icon_layers > 1 then
		icon_mask_layer = {
			icon = reskins[inputs_copy.mod].directory .. "/graphics/technology/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_mask .. "-technology-mask.png",
			icon_size = inputs_copy.technology_icon_size,
			tint = icon_tint,
		}

		icon_highlights_layer = {
			icon = reskins[inputs_copy.mod].directory .. "/graphics/technology/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_highlights .. "-technology-highlights.png",
			icon_size = inputs_copy.technology_icon_size,
			tint = { 1, 1, 1, 0 },
		}
	end

	---@type data.IconData[]
	local icon_data = { icon_base_layer }

	if icon_layers > 1 then
		table.insert(icon_data, icon_mask_layer)
	end

	if icon_layers > 2 then
		table.insert(icon_data, icon_highlights_layer)
	end

	-- Append icon extras as needed
	if inputs_copy.technology_icon_extras then
		-- Append icon_extras
		for n = 1, #inputs_copy.technology_icon_extras do
			table.insert(icon_data, inputs_copy.technology_icon_extras[n])
		end
	end

	---@type DeferrableIconData
	local deferrable_icon = {
		name = name,
		type_name = "technology",
		icon_data = icon_data,
	}

	-- It may be necessary to put icons back in final fixes, allow for that
	local stage
	if inputs_copy.defer_to_data_final_fixes then
		stage = reskins.lib.defines.stage.data_final_fixes
	elseif inputs_copy.defer_to_data_updates then
		stage = reskins.lib.defines.stage.data_updates
	end

	if stage then
		reskins.internal.store_icon_for_deferred_assigment_in_stage(stage, deferrable_icon)
	else
		reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
	end
end

---@class TechnologyEquipmentOverlayParameters
---@field is_vehicle? boolean # When `true`, indicates that the overlay is for a vehicle equipment icon.
---@field scale double # The scale of the overlay. Default `0.5`.

---comment
---@param parameters TechnologyEquipmentOverlayParameters
---@return table
function reskins.lib.technology_equipment_overlay(parameters)
	local equipment = (parameters and parameters.is_vehicle) and "vehicle" or "personal"
	local scale = parameters and parameters.scale or 0.5

	---@type data.IconData
	local overlay = {
		icon = "__reskins-library__/graphics/technology/" .. equipment .. "-equipment-overlay.png",
		icon_size = 128,
		shift = { 64 * scale, 100 * scale },
		scale = scale,
	}

	return overlay
end

---@alias TechnologyConstant
---| "battery"
---| "braking-force"
---| "capacity"
---| "count"
---| "damage"
---| "follower-count"
---| "ghost"
---| "health"
---| "logistic-slot"
---| "map-zoom"
---| "mining"
---| "mining-productivity"
---| "movement-speed"
---| "range"
---| "speed"

local technology_constants = {
	["battery"] = { icon = "__core__/graphics/icons/technology/constants/constant-battery.png" },
	["braking-force"] = { icon = "__core__/graphics/icons/technology/constants/constant-braking-force.png" },
	["capacity"] = { icon = "__core__/graphics/icons/technology/constants/constant-capacity.png" },
	["count"] = { icon = "__core__/graphics/icons/technology/constants/constant-count.png" },
	["damage"] = { icon = "__core__/graphics/icons/technology/constants/constant-damage.png" },
	["follower-count"] = { icon = "__core__/graphics/icons/technology/constants/constant-follower-count.png" },
	["ghost"] = { icon = "__core__/graphics/icons/technology/constants/constant-time-to-live-ghosts.png" },
	["health"] = { icon = "__core__/graphics/icons/technology/constants/constant-health.png" },
	["logistic-slot"] = { icon = "__core__/graphics/icons/technology/constants/constant-logistic-slot.png" },
	["map-zoom"] = { icon = "__core__/graphics/icons/technology/constants/constant-map-zoom.png" },
	["mining"] = { icon = "__core__/graphics/icons/technology/constants/constant-mining.png" },
	["mining-productivity"] = { icon = "__core__/graphics/icons/technology/constants/constant-mining-productivity.png" },
	["movement-speed"] = { icon = "__core__/graphics/icons/technology/constants/constant-movement-speed.png" },
	["range"] = { icon = "__core__/graphics/icons/technology/constants/constant-range.png" },
	["speed"] = { icon = "__core__/graphics/icons/technology/constants/constant-speed.png" },
}

---comment
---@param constant TechnologyConstant
---@param scale double?
---@return data.IconData
function reskins.lib.return_technology_effect_icon(constant, scale)
	---@type data.IconData
	local icon_data = {
		icon = technology_constants[constant].icon,
		icon_size = 128,
		shift = util.mul_shift({ 100, 100 }, scale or 1),
		scale = scale,
	}

	return icon_data
end

----------------------------------------------------------------------------------------------------
-- STANDARD ICON FUNCTIONS
----------------------------------------------------------------------------------------------------

---The common base class for all creatable icons.
---@class CreateableIconBase
---The path to the folder containing the icon files, relative to the mod's `graphics` folder.
---@field subfolder string
---The size of the square icon, in pixels, e.g. `32` for a 32px by 32px icon.
---
---Mandatory if `icon_size` is not specified outside of `icons`.
---
---[View Documentation](https://lua-api.factorio.com/latest/types/IconData.html#icon_size)
---@field icon_size data.SpriteSizeType
---
---Defaults to `32/icon_size` for items and recipes, and `256/icon_size` for technologies.
---
---Specifies the scale of the icon on the GUI scale. A scale of `2` means that the icon will be two
---times bigger on screen (and thus more pixelated).
---
---[View Documentation](https://lua-api.factorio.com/latest/types/IconData.html#scale)
---@field scale? double
---
---Used to offset the icon "layer" from the overall icon. The shift is applied from the center (so
---negative shifts are left and up, respectively). Shift values are based on final size (`icon_size
---* scale`) of the first icon.
---
---[View Documentation](https://lua-api.factorio.com/latest/types/IconData.html#shift)
---@field shift? data.Vector
---
---The tint to apply to the icon.
---
---[View Documentation](https://lua-api.factorio.com/latest/types/IconData.html#tint)
---@field tint? data.Color

---A creatable multi-layer icon that uses the standard form of a base layer, mask layer, and a
---highlights layer.
---
---The number of layers used to create the icon is determined by the `num_layers` field.
---@class TintedCreateableIcon : CreateableIconBase
---
---The prefix of the base icon file named `{icon_base}-icon-base.png`. Used in place of `mask_name`
---and `highlights_name` if neither is provided.
---@field icon_base string
---
---The prefix of the mask icon file named `{icon_mask}-icon-mask.png` Optional; uses `icon_base` if
---not provided.
---@field icon_mask? string
---
---The prefix of the highlights icon file named `{icon_highlights}-icon-highlights.png` Optional;
---uses `icon_base` if not provided.
---@field icon_highlights? string
---
---The tint to apply to the mask layer.
---@field tint data.Color
---
---The number of layers in the icon. Default `3`.
---@field num_layers? 1|2|3

---A createable single-layer icon.
---@class FlatCreateableIcon : CreateableIconBase
---The name of the icon file named `{icon}.png`.
---@field icon string
---
---An optional tint to apply to the icon.
---@field tint? data.Color

---@class ConstructIconInputsOld
---@field type string # The type name of the prototype.
---@field mod "angels"|"bobs"|"lib"|"compatibility"
---@field group string # Folder under the `graphics/icons` folder.
---@field subgroup? string # Folder under the `group` folder, e.g. `group/subgroup`. Default `nil`.
---@field untinted_icon_mask? boolean # Overrides default tinting behavior; when `true`, will not apply `tint` to the mask layer.
---@field tint? data.Color # Expected if `untinted_icon_mask` is not `true`. If not provided, defaults to white ({1, 1, 1, 1}).
---@field tier_labels? boolean # Default `true`, displays tier labels on icons.
---@field icon_filename? data.FileName # Required if `icon_name` is not defined.
---@field icon_size? data.SpriteSizeType # Default `64`.
---@field icon_name? string # Required if `icon_filename` is not defined. Specifies the folder/filenames to prepare the layered icon.
---@field icon_base? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the base layer
---@field icon_mask? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the mask layer
---@field icon_highlights? string # Override of `icon_name` for filename variants within the folder specified by `icon_name`, for the highlights layer
---@field icon_extras? data.IconData[] # An array of `IconData` objects to append to the main icon.
---@field icon_picture_extras? data.SpriteVariations[] # An array of `SpriteVariations` objects to append to the main sprite for the item-on-ground.
---@field icon_layers? 1|2|3 # Default 3 if used with `icon_name`, 1 if used with `icon_filename`, corresponds to the number of standard-form files to prepare
---@field equipment_category? EquipmentCategory # When specified, the icon will have a background corresponding to the equipment category. Does not work with technology icons.
---@field defer_to_data_updates? boolean # When `true`, stores the icon for assignment at the end of data-updates. Expected if `defer_to_data_final_fixes` is not set.
---@field defer_to_data_final_fixes? boolean # When `true`, stores the icon for assignment at the end of data-final-fixes. Supercedes `defer_to_data_updates`. Expected if `defer_to_data_updates` is not set.

---Constructs and assigns an icon to the prototype with the given `name` from the given `inputs`,
---and appends tier labels of the given `tier`.
---
---@param name string # The name of the prototype.
---@param tier integer # The tier of the added labels. An integer value from 0 to 6.
---@param inputs ConstructIconInputsOld
function reskins.lib.construct_icon(name, tier, inputs)
	---@type ConstructIconInputsOld
	local inputs_copy = util.copy(inputs)

	--Set defaults
	inputs_copy.icon_size = inputs.icon_size or 64
	inputs_copy.tier_labels = (inputs.tier_labels ~= false)

	-- Handle compatibility defaults
	local folder_path = inputs_copy.group
	if inputs_copy.subgroup then
		folder_path = inputs_copy.group .. "/" .. inputs_copy.subgroup
	end

	-- Handle mask tinting defaults
	---@type data.Color|nil
	local icon_tint = inputs_copy.tint
	if inputs_copy.untinted_icon_mask then
		icon_tint = nil
	elseif not inputs_copy.tint then
		inputs_copy.untinted_icon_mask = true
	end

	-- Handle icon_layers defaults
	---@type integer
	local icon_layers
	if inputs_copy.icon_filename then
		icon_layers = inputs_copy.icon_layers or 1
	else
		icon_layers = inputs_copy.icon_layers or 3
	end

	-- Some entities have variable bases and masks
	local icon_base = inputs_copy.icon_base or inputs_copy.icon_name
	local icon_mask = inputs_copy.icon_mask or inputs_copy.icon_name
	local icon_highlights = inputs_copy.icon_highlights or inputs_copy.icon_name

	-- Setup icon layers
	---@type data.IconData
	local icon_base_layer = {
		icon = inputs_copy.icon_filename or reskins[inputs_copy.mod].directory .. "/graphics/icons/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_base .. "-icon-base.png",
		icon_size = inputs_copy.icon_size,
	}

	---@type data.IconData, data.IconData
	local icon_mask_layer, icon_highlights_layer
	if icon_layers > 1 then
		icon_mask_layer = {
			icon = reskins[inputs_copy.mod].directory .. "/graphics/icons/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_mask .. "-icon-mask.png",
			icon_size = inputs_copy.icon_size,
			tint = icon_tint,
		}

		icon_highlights_layer = {
			icon = reskins[inputs_copy.mod].directory .. "/graphics/icons/" .. folder_path .. "/" .. inputs_copy.icon_name .. "/" .. icon_highlights .. "-icon-highlights.png",
			icon_size = inputs_copy.icon_size,
			tint = { 1, 1, 1, 0 },
		}
	end

	---@type data.IconData[]
	local icon_data = { icon_base_layer }

	if icon_layers > 1 then
		table.insert(icon_data, icon_mask_layer)
	end

	if icon_layers > 2 then
		table.insert(icon_data, icon_highlights_layer)
	end

	---@type data.SpriteVariations
	local pictures = reskins.lib.sprites.create_sprite_from_icons(icon_data, 1.0)

	-- Append icon extras as needed
	if inputs_copy.icon_extras then
		-- Append icon_extras
		for n = 1, #inputs_copy.icon_extras do
			table.insert(icon_data, inputs_copy.icon_extras[n])
		end
	end

	if inputs_copy.icon_picture_extras then
		-- If we have one layer, we need to convert to an layered sprite.
		if not pictures.layers then
			pictures = {
				layers = { pictures },
			}
		end

		for n = 1, #inputs_copy.icon_picture_extras do
			table.insert(pictures.layers, inputs_copy.icon_picture_extras[n])
		end
	end

	-- Insert icon background if necessary
	if inputs_copy.equipment_category then
		-- Insert the equipment background
		table.insert(icon_data, 1, reskins.lib.icons.get_equipment_icon_background(inputs_copy.equipment_category))
	end

	---@type DeferrableIconData
	local deferrable_icon = {
		name = name,
		type_name = inputs_copy.type or "item",
		icon_data = inputs_copy.tier_labels and reskins.lib.tiers.add_tier_labels_to_icons(tier, icon_data) or icon_data,
		pictures = pictures,
	}

	-- It may be necessary to put icons back in final fixes, allow for that
	local stage
	if inputs_copy.defer_to_data_final_fixes then
		stage = reskins.lib.defines.stage.data_final_fixes
	elseif inputs_copy.defer_to_data_updates then
		stage = reskins.lib.defines.stage.data_updates
	end

	if stage then
		reskins.internal.store_icon_for_deferred_assigment_in_stage(stage, deferrable_icon)
	else
		reskins.lib.icons.assign_deferrable_icon(deferrable_icon)
	end
end
