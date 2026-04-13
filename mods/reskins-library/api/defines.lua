-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api.defines" then
	return require("__reskins-library__.api.defines")
end

--- Provides enumerations for use in Artisanal Reskins.
---
---### Examples
---```lua
---local _icons = require("__reskins-library__.api.icons")
---```
---@class Reskins.Lib.Defines
local _defines = {}

---Represents stages of the Factorio mod loading process.
---@enum Reskins.Lib.Defines.Stage
_defines.stage = {
	---The settings stage.
	settings = 0,
	---The settings updates stage.
	settings_updates = 1,
	---The settings final fixes stage.
	settings_final_fixes = 2,
	---The data stage.
	data = 3,
	---The data updates stage.
	data_updates = 4,
	---The data final fixes stage.
	data_final_fixes = 5,
	---The control stage.
	runtime = 6,
}

---Represents the different types of animated transport belt sprite sheets.
---@enum Reskins.Lib.Defines.BeltSprites
_defines.belt_sprites = {
	---The sprites for a typical belt. Used for slower belt speeds.
	standard = 0,
	---The sprites for an express belt. Has twice as many frames as standard and larger spacing between arrows. Used for faster belt speeds.
	express = 1,
}

return _defines
