-- Copyright (c) 2020 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

local function on_configuration_changed(data)
    -- Notify of changes when updated in a save we were already present in
    if data.mod_changes and data.mod_changes["reskins-library"] and data.mod_changes["reskins-library"].old_version then
        -- 1.0.4 update
        if data.mod_changes["reskins-library"].old_version <= "1.0.3" then
            game.print({"", "[", {"mod-name.reskins-library"}, "] ", {"reskins-updates.reskins-1-0-4-update", {"mod-setting-name.reskins-lib-blend-mode"}}})
        end
    end
end

script.on_configuration_changed(on_configuration_changed)