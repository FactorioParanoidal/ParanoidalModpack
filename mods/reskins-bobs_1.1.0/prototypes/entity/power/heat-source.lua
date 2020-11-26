-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not mods["bobpower"] then return end
if reskins.lib.setting("bobmods-power-heatsources") == false then return end
if reskins.lib.setting("reskins-bobs-do-bobpower") == false then return end

-- burner-reactor
-- burner-reactor-2
-- burner-reactor-3
-- fluid-reactor
-- fluid-reactor-2
-- fluid-reactor-3