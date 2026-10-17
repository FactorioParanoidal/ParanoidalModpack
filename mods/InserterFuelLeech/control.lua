--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

require("util") -- Part of the game.

require("mathTools")

require("settingsCache")
require("logging")
require("prototypeTools")
require("filterTools")
require("itemTools")
require("entityTools")
require("inserterTools")

require("inserterUpdateContext")
require("inserterCheatFuelForSelf")
require("inserterLeechFuel")
require("inserterUpdate")
require("inserterRepo")
require("inserterDiscovery")

require("consoleCommands")

-- -----------------------------------------------------------------------------
-- Event handler registration

script.on_init(function()
    initConsoleCommands()
    -- Nothing else to do. Everything is version aware and initialized on demand.
end)
script.on_load(function()
    inserterRepoOnLoad()
    inserterDiscoveryOnLoad()
    initConsoleCommands()
end)

--- @param event EventData.on_runtime_mod_setting_changed
--- @return nil
local function onRuntimeSettingsChanged(event)
    if event.setting_type == "runtime-per-user" and event.player_index then
        initSettingsCacheIfNeeded()
        updatePlayerSettingsCache(game.get_player(event.player_index))
        return
    end
    updateSettingsCache()
end

script.on_event(defines.events.on_runtime_mod_setting_changed, onRuntimeSettingsChanged)

--- @param event EventData.on_player_joined_game|EventData.on_player_left_game
--- @return nil
local function onPlayerConnectedStateChanged(event)
    initSettingsCacheIfNeeded()
    updatePlayerSettingsCache(game.get_player(event.player_index))
end

script.on_event(defines.events.on_player_joined_game, onPlayerConnectedStateChanged)
script.on_event(defines.events.on_player_left_game, onPlayerConnectedStateChanged)

script.on_event(defines.events.on_tick, function(event)
    initSettingsCacheIfNeeded()
    local tick = event.tick
    updateInserters(tick)
    discoverUnknownInserters(tick)
end)

--- @param event EventData.on_built_entity
---     |EventData.on_robot_built_entity
---     |EventData.on_space_platform_built_entity
---     |EventData.script_raised_built
---     |EventData.script_raised_revive
---     |EventData.script_raised_teleported
---     |EventData.on_entity_cloned
---     |EventData.on_player_rotated_entity
--- @return nil
local function onInserterBuilt(event)
    initSettingsCacheIfNeeded()
    registerInserter(event.tick, event.entity, event.player_index)
end

script.on_event(defines.events.on_built_entity, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.on_robot_built_entity, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.on_space_platform_built_entity, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.script_raised_built, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.script_raised_revive, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.script_raised_teleported, onInserterBuilt, {{filter = "type", type = "inserter"}})
script.on_event(defines.events.on_entity_cloned, onInserterBuilt, {{filter = "type", type = "inserter"}})

script.on_event(defines.events.on_player_rotated_entity, function(event)
    initSettingsCacheIfNeeded()
    registerInserter(event.tick, event.entity, nil)
end)
