-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.settings" then
	return require("__reskins-library__.api.settings")
end

--- Provides methods for retrieving and validating startup settings.
---
---### Examples
---```lua
---local _settings = require("__reskins-library__.api.settings")
---```
---@class Reskins.Lib.Settings
local _settings = {}

---
---Gets the value of the startup setting with the given `name`.
---
---### Returns
---@return boolean|string|Color|double|int|nil # The value of the startup setting, if it exists; otherwise, `nil`.
---
---### Examples
---```lua
----- Check if the user has enabled custom furnace variants.
------@type boolean
---local value = setting_tools.get_value("reskins-bobs-do-custom-furnace-variants")
---
----- Get the color of the standard furnace variant.
------@type data.Color
---local color = setting_tools.get_value("reskins-bobs-standard-furnace-color")
---```
---
---### Parameters
---@param name string # The name of a startup setting.
function _settings.get_value(name)
	local value = nil
	if settings.startup[name] then
		value = settings.startup[name].value
	end

	return value
end

---
---Gets the blend mode to use for applying the highlights layer of Artisanal Reskins sprite sets.
---
---@type data.BlendMode
_settings.blend_mode = _settings.get_value("reskins-lib-blend-mode")

---@alias TargetMod
---| '"angelsaddons-cab"'
---| '"angelsaddons-mobility"'
---| '"angelsaddons-storage"'
---| '"angelsbioprocessing"'
---| '"angelsexploration"'
---| '"angelsindustries"'
---| '"angelspetrochem"'
---| '"angelsrefining"'
---| '"angelssmelting"'
---| '"bobassembly"'
---| '"bobelectronics"'
---| '"bobenemies"'
---| '"bobequipment"'
---| '"bobgreenhouse"'
---| '"boblogistics"'
---| '"bobmining"'
---| '"bobmodules"'
---| '"bobores"'
---| '"bobplates"'
---| '"bobpower"'
---| '"bobrevamp"'
---| '"bobtech"'
---| '"bobvehicleequipment"'
---| '"bobwarfare"'

---@alias SourceMod
---| '"reskins-angels"'
---| '"reskins-bobs"'
---| '"reskins-lib"'
---| '"reskins-compatibility"'

---@alias FeatureSet
---| '"entities"'
---| '"equipment"'
---| '"items-and-fluids"'
---| '"technologies"'

---
---Checks if reskinning the given `feature_set` is enabled for a given `source_mod`
---doing the reskinning, and a given `target_mod` being reskinned.
---
---### Returns
---@return boolean|nil # `true` if the feature set is enabled, `false` if it is disabled, and `nil` if the setting does not exist.
---
---### Examples
---```lua
----- Check if Artisanal Reskins: Bob's Mods is reskinning entities for Bob's Assembling Machines
---local is_enabled = setting_tools.is_feature_set_enabled("entities", "reskins-bobs", "bobassembly")
---```
---
---### Parameters
---@param feature_set FeatureSet # The feature set to check.
---@param source_mod SourceMod # The source mod with reskin authority.
---@param target_mod TargetMod # The target mod being reskinned.
function _settings.is_feature_set_enabled(feature_set, source_mod, target_mod)
	if _settings.get_value(source_mod .. "-do-" .. target_mod) == true then
		return _settings.get_value("reskins-lib-scope-" .. feature_set) == true
	elseif _settings.get_value(source_mod .. "-do-" .. target_mod) == false then
		return false
	else
		return nil
	end
end

return _settings
