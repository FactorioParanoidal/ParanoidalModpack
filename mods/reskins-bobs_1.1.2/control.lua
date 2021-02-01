-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

local function on_configuration_changed(data)
    -- Notify of changes when updated in a save we were already present in
    if data.mod_changes and data.mod_changes["reskins-bobs"] and data.mod_changes["reskins-bobs"].old_version then
        -- 1.0.7 update
        if data.mod_changes["reskins-bobs"].old_version <= "1.0.6" then
            game.print({"", "[", {"mod-name.reskins-bobs"}, "] ", {"reskins-updates.reskins-bobs-1-0-7-update", {"mod-setting-name.reskins-bobs-do-bobelectronics-circuit-style"}}})
        end
    end
end

script.on_configuration_changed(on_configuration_changed)