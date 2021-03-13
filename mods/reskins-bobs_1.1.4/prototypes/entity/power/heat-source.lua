-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Check to see if reskinning needs to be done.
if not (reskins.bobs and reskins.bobs.triggers.power.entities) then return end
if reskins.lib.setting("bobmods-power-heatsources") == false then return end

-- burner-reactor
-- burner-reactor-2
-- burner-reactor-3
-- fluid-reactor
-- fluid-reactor-2
-- fluid-reactor-3