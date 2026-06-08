--- Provides enumerations for use in Prismatic Belts.
---
---### Examples
---```lua
---local api = require("__prismatic-belts__.prototypes.api")
---local defines = api.defines
---```
---@class PrismaticBelts.Api.Defines
local defines_api = {}

---Represents stages of the Factorio mod loading process.
---@enum PrismaticBelts.Api.Defines.Stage
defines_api.stage = {
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
---@enum PrismaticBelts.Api.Defines.BeltSprites
defines_api.belt_sprites = {
	---Indicates standard belt sprites.
	---
	---Used for slower belt speeds, typically less than 30 items/s.
	standard = 1,
	---Indicates fast belt sprites.
	---
	---Used for faster belt speeds, typically between 30 items/s and 60 items/s.
	---Has twice as many frames as `defines.belt_sprites.standard` and larger spacing between arrows.
	fast = 2,
	---Indicates turbo belt sprites.
	---
	---Used for faster belt speeds, typically more than 60 items/s.
	---Has twice as many frames as `defines.belt_sprites.fast` and larger spacing between arrows. Used for fastest belt speeds.
	turbo = 3,
}

---Represents the different types of transport belt sprite sheets that have been included as
---pre-colored sprite sheets.
---
---Pre-colored sprite sheets are more performative than multi-layered dynamic sprite sheets and so
---these have been included to support reskinning the standard base-Factorio transport belts.
---@enum PrismaticBelts.Api.Defines.BeltPresets
defines_api.belt_presets = {
	---Indicates the (yellow) transport belt animation set should be used.
	---
	---Should be used with slower belt speeds, less than 30 items/s.
	standard = 1,
	---Indicates the fast (red) transport belt animation set should be used.
	---
	---Should be used with faster belt speeds, between 30 items/s and 60 items/s.
	fast = 2,
	---Indicates the express (blue) transport belt animation set should be used. 
	---
	---Should be used with faster belt speeds, between 30 items/s and 60 items/s.
	express = 3,
	---Indicates the turbo (green) transport belt animation set should be used.
	---
	---Should be used with fastest belt speeds, more than 60 items/s.
	turbo = 4,
}

return defines_api
