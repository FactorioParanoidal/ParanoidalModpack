-- Copyright (c) 2024 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

---Provides control functions for Artisanal Reskins.
---@class Reskins.Control
local _control = {}

---
---Checks for each of the Artisanal Reskin mods, and sets the notification status to `true` if
---they are detected; otherwise, sets to `false`.
---
---### Remarks
---Called by `migration/reskins-library_1.1.3.lua`
function _control.on_init()
	storage.notify = {
		bobs = {
			status = script.active_mods["reskins-bobs"] and true or false,
		},
		angels = {
			status = script.active_mods["reskins-angels"] and true or false,
		},
		compatibility = {
			status = script.active_mods["reskins-compatibility"] and true or false,
		},
	}
end

return _control
