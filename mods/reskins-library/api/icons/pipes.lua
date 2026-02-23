-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.icons.pipes" then
	return require("__reskins-library__.api.icons.pipes")
end

--- Provides methods for getting icons for pipe-type entities.
---
---### Examples
---```lua
---local _icons = require("__reskins-library__.api.icons.pipes")
---```
---@class Reskins.Lib.Icons.Pipes
local _pipes = {}

---
---Gets the path to the icon for the given `folder_name` and `material_type`.
---
---### Returns
---@return string # The path to the icons for the given `folder_name` and `material_type`.
---
---### Examples
---```lua
----- Get the path to the icon for iron pipes.
---local path = _pipes.get_path_to_pipe_material_icons("pipe", "iron")
---
----- Which has the following value:
---path = "__reskins-library__/graphics/icons/common/pipe/iron"
---```
---
---### Parameters
---@param folder_name string # The folder name of the prototype to get the path for.
---@param material_type PipeMaterialType # The type of material to get the path for.
---@nodiscard
local function get_path_to_pipe_material_icons(folder_name, material_type)
	local path
	if material_type == "iron" then
		path = "__reskins-library__/graphics/icons/common/" .. folder_name .. "/iron"
	elseif material_type:find("angels") then
		path = "__reskins-angels__/graphics/icons/smelting/" .. folder_name .. "/" .. material_type:gsub("angels%-", "")
	else
		path = "__reskins-bobs__/graphics/icons/logistics/" .. folder_name .. "/" .. material_type
	end

	return path
end

---
---Gets the pipe icon data for the given `type_name` and `material_type`.
---
---### Returns
---@return data.IconData # The icon data for the given `type_name` and `material_type`.
---
---### Examples
---```lua
----- Get the icon data for iron pipes.
---local icon_data = _pipes.get_icon_data("pipe", "iron")
---```
---
---### Parameters
---@param type_name "pipe"|"pipe-to-ground" # The type name of the prototype to get the icon data for.
---@param material_type PipeMaterialType # The type of material to get the path for.
---@nodiscard
local function get_icon_datum(type_name, material_type)
	local path = get_path_to_pipe_material_icons(type_name, material_type)

	---@type data.IconData
	local icon_datum = {
		icon = path .. "-" .. type_name .. "-icon.png",
		icon_size = 64,
		scale = 0.5,
	}

	return icon_datum
end

---Prototype type-names supported by generic methods in this module.
local supported_types = {
	["pipe"] = true,
	["pipe-to-ground"] = true,
}

---
---Gets the deferrable icon for the given `prototype`, and `material_type`. If pipe tier
---labeling is enabled, tier labels for the given `tier` are added to the icon.
---
---### Returns
---@return DeferrableIconData|DeferrableIconDatum # The deferrable icon for the given `prototype`, `material_type`, and `tier`.
---
---### Examples
---```lua
---local pipe = data.raw["pipe"]["iron-pipe"]
---
----- Get an icon labeled for tier 2, for an iron pipe prototype.
---local deferrable_icon = _pipes.get_icon(pipe, "iron", 2)
---```
---### Parameters
---@param prototype data.PipePrototype|data.PipeToGroundPrototype # The prototype to get an icon for.
---@param material_type PipeMaterialType # The material type to get the icon for.
---@param tier? integer # The tier of the added labels. An integer value from 0 to 6. Default 0 (none).
---
---### Exceptions
---*@throws* `string` — Thrown when `prototype` is `nil`.
---*@throws* `string` — Thrown when `prototype` is not of a supported type.
---@nodiscard
function _pipes.get_icon(prototype, material_type, tier)
	---@type data.IconData
	local icon_datum = get_icon_datum(prototype.type, material_type)

	assert(prototype, "Invalid parameter: 'prototype' must not be nil.")
	assert(supported_types[prototype.type], "Invalid parameter: 'prototype' must be of a supported type.")

	---@type DeferrableIconDatum|DeferrableIconData
	local deferrable_icon
	if reskins.lib.tiers.is_pipe_tier_labeling_enabled then
		---@type DeferrableIconData
		deferrable_icon = {
			name = prototype.name,
			type_name = prototype.type,
			icon_data = reskins.lib.tiers.add_tier_labels_to_icon(tier or 0, icon_datum),
			pictures = reskins.lib.sprites.create_sprite_from_icon(icon_datum, 1.0),
		}
	else
		---@type DeferrableIconDatum
		deferrable_icon = {
			name = prototype.name,
			type_name = prototype.type,
			icon_datum = icon_datum,
		}
	end

	return deferrable_icon
end

return _pipes
