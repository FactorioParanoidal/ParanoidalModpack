-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

if ... ~= "__reskins-library__.api" then
	return require("__reskins-library__.api")
end

---Provides access to the Artisanal Reskin's library of API functions.
---
---### Examples
---```lua
---local reskins_api = require("__reskins-library__.api")
---```
---@class Reskins.Library
local _library = {
	---@type Reskins.Lib.Defines
	defines = require("__reskins-library__.api.defines"),

	---@type Reskins.Lib.Icons
	icons = require("__reskins-library__.api.icons"),

	---@type Reskins.Lib.Prototypes
	prototypes = require("__reskins-library__.api.prototypes"),

	---@type Reskins.Lib.Settings
	settings = require("__reskins-library__.api.settings"),

	---@type Reskins.Lib.Sprites
	sprites = require("__reskins-library__.api.sprites"),

	---@type Reskins.Lib.Tiers
	tiers = require("__reskins-library__.api.tiers"),

	---@type Reskins.Lib.Version
	version = require("__reskins-library__.api.version"),
}

return _library
