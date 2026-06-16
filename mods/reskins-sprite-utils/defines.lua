--- Provides enumerations for use with Artisanal Reskins: Sprite Utils.
---
---### Examples
---```lua
---local _defines = require("__reskins-sprite-utils__.defines")
---```
---@class Reskins.SpriteUtils.Defines
local _defines = {}

---Represents stages of the Factorio mod loading process.
---@enum Reskins.SpriteUtils.Defines.Stage
_defines.stage = {
	---The settings stage. Initial mod configuration setup.
	settings = 0,
	---The settings updates stage. Modifications to existing settings.
	settings_updates = 1,
	---The settings final fixes stage. Final adjustments to settings.
	settings_final_fixes = 2,
	---The data stage. Initial prototype definitions.
	data = 3,
	---The data updates stage. Modifications to existing prototypes.
	data_updates = 4,
	---The data final fixes stage. Final prototype adjustments.
	data_final_fixes = 5,
	---The control/runtime stage. Active gameplay logic.
	runtime = 6,
}

return _defines
