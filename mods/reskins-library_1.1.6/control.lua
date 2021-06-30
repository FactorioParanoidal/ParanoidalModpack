-- Copyright (c) 2021 Kirazy
-- Part of Artisanal Reskins: Library
--
-- See LICENSE.md in the project directory for license information.

-- Requires
local migration = require("__flib__.migration")

-- General Functions
local message_color = "#9cdcfe" -- Light blue

function check_for_missing_reskin(player)
    local supported_mods = {
        angels = {
            "angelssmelting",
            "angelspetrochem",
            "angelsaddons-storage",
            -- "angelsbioprocessing",
            -- "angelsexploration",
            "angelsindustries",
            -- "angelsrefining",
            -- "angelsaddons-cab",
            -- "angelsaddons-mobility",
        },
        bobs = {
            "bobassembly",
            -- "bobclasses",
            "bobelectronics",
            "bobequipment",
            -- "bobenemies",
            "bobgreenhouse",
            -- "bobinserters",
            "boblogistics",
            "bobmining",
            "bobmodules",
            "bobores",
            "bobplates",
            "bobpower",
            "bobrevamp",
            "bobtech",
            "bobvehicleequipment",
            "bobwarfare",
        },
        compatibility = {
            "miniloader",
            "LoaderRedux",
            "deadlock-beltboxes-loaders",
            "vanilla-loaders-hd",
            "DeadlockCrating",
            "mini-machines",
            "CircuitProcessing",
            "angels-smelting-extended",
            "Clowns-Processing",
            "classic-beacon",
            "classic-mining-drill",
            "semi-classic-mining-drill",
        },
    }

    -- Make sure at least one reskin mod is present
    if game.active_mods["reskins-bobs"] or game.active_mods["reskins-angels"] or game.active_mods["reskins-compatibility"] then
        -- Iterate through each of the reskin mods
        for reskin, mod_list in pairs(supported_mods) do
            -- Check if notification for this reskin is needed
            if global.notify[reskin].status then goto continue end
            local count = -1
            local notify_mod_name

            -- Check for each of the mods supported by the reskin mod, store the first result found, count the number of matches
            for _, mod in pairs(mod_list) do
                -- A supported mod is present
                if game.active_mods[mod] then
                    -- Store the name of the first positive result
                    if count == -1 then notify_mod_name = mod end
                    count = count + 1
                end
            end

            -- Notify the player, set the flag not to do so again
            if notify_mod_name then
                global.notify[reskin].status = true
                if count == 0 then
                    player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-notifications.reskins-notify-missing-single",
                        {"", "[color="..message_color.."]", {"reskins-supported-mods."..notify_mod_name}, "[/color]"},
                        {"", "[color="..message_color.."]", {"reskins-library.reskins-"..reskin.."-mod-name"}, "[/color]"}}
                    })
                else
                    player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-notifications.reskins-notify-missing-multiple",
                        {"", "[color="..message_color.."]", {"reskins-supported-mods."..notify_mod_name}, "[/color]"},
                        count,
                        {"", "[color="..message_color.."]", {"reskins-library.reskins-"..reskin.."-mod-name"}, "[/color]"}}
                    })
                end
            end

            -- Label to continue to the next iteration
            ::continue::
        end
    end
end

----------------------------------------------------------------------------------------------------
-- ON INIT
----------------------------------------------------------------------------------------------------
function on_init() -- Called by migration/reskins-library_1.1.3.lua
    -- Check for each of the reskin mods, and set the notification status to true if they are detected otherwise, set to false
    global.notify = {
        bobs = {
            status = game.active_mods["reskins-bobs"] and true or false,
        },
        angels = {
            status = game.active_mods["reskins-angels"] and true or false,
        },
        compatibility = {
            status = game.active_mods["reskins-compatibility"] and true or false,
        },
    }
end

script.on_init(on_init)

----------------------------------------------------------------------------------------------------
-- ON CONFIGURATION CHANGED
----------------------------------------------------------------------------------------------------
local function notify(data)
    for _, player in pairs(game.connected_players) do
        if player.admin then
            if player.mod_settings["reskins-lib-display-notifications"].value == true then
                -- Check for supported mods for which a reskin mod is missing, and notify
                check_for_missing_reskin(player)

                -- Notify of changes when updated in a save we were already present in
                if data.mod_changes and data.mod_changes["reskins-library"] and data.mod_changes["reskins-library"].old_version then
                    -- 1.0.4 update
                    if not migration.is_newer_version("1.0.3", data.mod_changes["reskins-library"].old_version) then
                        player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-updates.reskins-lib-1-0-4-update", {"mod-setting-name.reskins-lib-blend-mode"}}})
                    end

                    -- 1.1.3 update
                    if not migration.is_newer_version("1.1.2", data.mod_changes["reskins-library"].old_version) then
                        if game.active_mods["reskins-bobs"] and not game.active_mods["reskins-compatibility"] then
                            player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-updates.reskins-lib-1-1-3-update-bobs", {"", "[color="..message_color.."]", {"reskins-library.reskins-compatibility-mod-name"}, "[/color]"}}})
                        end

                        if game.active_mods["reskins-angels"] and not game.active_mods["reskins-compatibility"] then
                            player.print({"", "[", {"reskins-library.reskins-suite-name"}, "] ", {"reskins-updates.reskins-lib-1-1-3-update-angels", {"", "[color="..message_color.."]", {"reskins-library.reskins-compatibility-mod-name"}, "[/color]"}}})
                        end
                    end
                end
            end
        end
    end
end

script.on_configuration_changed(notify)

----------------------------------------------------------------------------------------------------
-- RUNTIME
----------------------------------------------------------------------------------------------------
script.on_event(defines.events.on_player_joined_game, function(event)
    local player = game.get_player(event.player_index)
    if player.admin then
        if player.mod_settings["reskins-lib-display-notifications"].value == true then
            -- Check for supported mods for which a reskin mod is missing, and notify
            check_for_missing_reskin(player)
        end
    end
end)