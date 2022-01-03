-- Copyright (c) 2022 Kirazy
-- Part of Artisanal Reskins: Bob's Mods
--
-- See LICENSE in the project directory for license information.

-- Requires
local migration = require("__reskins-library__.prototypes.functions.migration")

local function on_configuration_changed(data)
    for _, player in pairs(game.connected_players) do
        if player.admin then
            if player.mod_settings["reskins-lib-display-notifications"].value == true then
                -- Notify of changes when updated in a save we were already present in
                if data.mod_changes and data.mod_changes["reskins-bobs"] and data.mod_changes["reskins-bobs"].old_version then
                    -- 1.0.7 update
                    if migration.is_version_or_older(data.mod_changes["reskins-bobs"].old_version, "1.0.7") then
                        player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-updates.reskins-bobs-1-0-7-update", {"mod-setting-name.reskins-bobs-do-bobelectronics-circuit-style"}}})
                    end
                end
            end
        end
    end
end

script.on_configuration_changed(on_configuration_changed)