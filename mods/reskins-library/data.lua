-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Setup the reskins global.
reskins = {}

---@type Reskins.Library
reskins.lib = require("__reskins-library__.api")

require("internal")

-- Setup function hosts and import triggers
if mods["reskins-angels"] then
	reskins.angels = {
		triggers = require("__reskins-angels__.prototypes.functions.triggers"),
	}
end

if mods["reskins-bobs"] then
	reskins.bobs = {
		triggers = require("__reskins-bobs__.prototypes.functions.triggers"),
	}
end

if mods["reskins-compatibility"] then
	reskins.compatibility = {
		triggers = require("__reskins-compatibility__.prototypes.functions.triggers"),
	}
end

require("prototypes.functions.functions")
require("prototypes.functions.tints")
require("prototypes.functions.icon-handling")
require("prototypes.functions.label-items")
require("prototypes.functions.entity-functions")

----------------------------------------------------------------------------------------------------
-- ENTITIES
----------------------------------------------------------------------------------------------------
-- Common
require("prototypes.entity.common.pipe")

-- Base
require("prototypes.entity.base.oil-refinery")
require("prototypes.entity.base.belt-entities")

----------------------------------------------------------------------------------------------------
-- TECHNOLOGIES
----------------------------------------------------------------------------------------------------
-- Base
require("prototypes.technology.base.logistics")
