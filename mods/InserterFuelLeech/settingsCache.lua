--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @class PlayerSettingsCache
--- @field player LuaPlayer
--- @field logSettings PrintSettings

--- @class SettingsCache
---
--- @field inserterTypes table<string?,boolean?>
--- @field discoverPerTick uint
--- @field discoverEmptyChunksPerTick uint
---
--- @field selfLeechFromDropEnabled boolean
--- @field selfRefuelCheatEnabled boolean
--- @field vectorGranularity double
--- @field targetItemCountMin uint
--- @field pickupPosMarginTicks uint
---
--- @field noUseForFuelTicksToWait uint
--- @field unpoweredNonBurnerTicksToWait uint
--- @field vanillaSelfRefuelTicksToWait uint
--- @field unpoweredBurnerTicksToWait uint
--- @field stuckWithItemTicksToWait uint
--- @field nothingLeechableFoundTicksToWait uint
--- @field ticksToWaitMinForVariation uint
--- @field ticksToWaitVariation uint
--- @field maxTicksToWait uint The maximum amount of ticks to wait in any case before updating an inserter again.
---
--- @field logCommandsPlayers table<integer?,PlayerSettingsCache?>
--- @field logLowTrafficPlayers table<integer?,PlayerSettingsCache?>
--- @field logDiscoveryCyclePlayers table<integer?,PlayerSettingsCache?>
--- @field watchLastInserterPlayers table<integer?,PlayerSettingsCache?>

--- @type SettingsCache
settingsCache = {
    inserterTypes = {},
    discoverPerTick = 1,
    discoverEmptyChunksPerTick = 1,

    selfLeechFromDropEnabled = false,
    selfRefuelCheatEnabled = false,
    vectorGranularity = 0.01,
    targetItemCountMin = 1,
    pickupPosMarginTicks = 1,

    noUseForFuelTicksToWait = 10 * 60,
    unpoweredNonBurnerTicksToWait = 10 * 60,
    vanillaSelfRefuelTicksToWait = 1 * 60,
    unpoweredBurnerTicksToWait = 10 * 60,
    stuckWithItemTicksToWait = 10 * 60,
    nothingLeechableFoundTicksToWait = 10 * 60,
    ticksToWaitMinForVariation = 10 * 60,
    ticksToWaitVariation = 60,
    maxTicksToWait = 11 * 60,

    logCommandsPlayers = {},
    logLowTrafficPlayers = {},
    logDiscoveryCyclePlayers = {},
    watchLastInserterPlayers = {},
}

local settingsCacheUninitialized = true

---@return nil
function initSettingsCacheIfNeeded()
    if settingsCacheUninitialized then
        updateSettingsCache()
    end
    settingsCacheUninitialized = false
end

---@return nil
function updateSettingsCache()
    local inserterTypeSet = settings.global["inserter-fuel-leech-inserters-enabled"].value
    if inserterTypeSet == "all" then
        settingsCache.inserterTypes = getInserterTypes()
    elseif inserterTypeSet == "itemfueled" then
        settingsCache.inserterTypes = getItemFueledInserterTypes()
    else
        settingsCache.inserterTypes = {}
    end
    settingsCache.discoverPerTick = settings.global["inserter-fuel-leech-discover-per-tick"].value
    settingsCache.discoverEmptyChunksPerTick = settings.global["inserter-fuel-leech-discover-empty-chunks-per-tick"].value

    settingsCache.selfLeechFromDropEnabled = settings.global["inserter-fuel-leech-self-leech-from-drop-enabled"].value
    settingsCache.selfRefuelCheatEnabled = settings.global["inserter-fuel-leech-self-refuel-cheat-enabled"].value
    settingsCache.targetItemCountMin = settings.global["inserter-fuel-leech-target-item-count-min"].value
    settingsCache.pickupPosMarginTicks = settings.global["inserter-fuel-leech-pickup-margin-ticks"].value

    local noUseForFuelTicksToWait = math.floor(60 * settings.global["inserter-fuel-leech-no-use-for-fuel-seconds-to-wait"].value)
    local missingPowerTicksToWait = math.floor(60 * settings.global["inserter-fuel-leech-missing-power-seconds-to-wait"].value)
    local vanillaSelfRefuelTicksToWait = math.floor(60 * settings.global["inserter-fuel-leech-vanilla-self-refuel-seconds-to-wait"].value)
    local missingResourceTicksToWait = math.floor(60 * settings.global["inserter-fuel-leech-missing-resource-seconds-to-wait"].value)
    local ticksBetweenUpdatesVariation = math.floor(60 * settings.global["inserter-fuel-leech-wait-variation-seconds"].value)
    local minTicksToWaitforVariation = math.min(noUseForFuelTicksToWait, missingPowerTicksToWait, missingResourceTicksToWait)
    local maxTicksToWait = math.max(noUseForFuelTicksToWait, missingPowerTicksToWait, missingResourceTicksToWait) + ticksBetweenUpdatesVariation
    settingsCache.noUseForFuelTicksToWait = noUseForFuelTicksToWait
    settingsCache.unpoweredNonBurnerTicksToWait = missingPowerTicksToWait
    settingsCache.vanillaSelfRefuelTicksToWait = vanillaSelfRefuelTicksToWait
    settingsCache.unpoweredBurnerTicksToWait = missingResourceTicksToWait
    settingsCache.stuckWithItemTicksToWait = missingResourceTicksToWait
    settingsCache.nothingLeechableFoundTicksToWait = missingResourceTicksToWait
    settingsCache.ticksToWaitMinForVariation = minTicksToWaitforVariation
    settingsCache.ticksToWaitVariation = ticksBetweenUpdatesVariation
    settingsCache.maxTicksToWait = maxTicksToWait

    settingsCache.logCommandsPlayers = {}
    settingsCache.logLowTrafficPlayers = {}
    settingsCache.logDiscoveryCyclePlayers = {}
    settingsCache.watchLastInserterPlayers = {}
    for _, player in pairs(game.connected_players) do
        updatePlayerSettingsCache(player)
    end
end

--- @param player (integer|LuaPlayer)?
--- @return nil
function updatePlayerSettingsCache(player)
    if not player then
        return
    end
    if type(player) == "number" then
        updatePlayerSettingsCache(game.players[player])
        return
    end
    if not player.valid then
        return
    end
    local playerIndex = player.index
    local playerIsConnected = player.connected
    local defaultMsgColor = player.mod_settings["inserter-fuel-leech-chat-log-color"].value

    settingsCache.logCommandsPlayers[playerIndex] = playerIsConnected and {
        player = player,
        logSettings = {
            color = defaultMsgColor,
            sound = defines.print_sound.never,
            game_state = false,
            skip = defines.print_skip.never,
        }
    } or nil

    local logLowTraffic = playerIsConnected and player.mod_settings["inserter-fuel-leech-log-low-traffic"].value
    settingsCache.logLowTrafficPlayers[playerIndex] = logLowTraffic and {
        player = player,
        logSettings = {
            color = defaultMsgColor,
            sound = defines.print_sound.never,
            game_state = false,
            skip = defines.print_skip.never,
        }
    } or nil

    local logDiscoveryCycle = playerIsConnected and player.mod_settings["inserter-fuel-leech-log-discovery-cycle"].value
    settingsCache.logDiscoveryCyclePlayers[playerIndex] = logDiscoveryCycle and {
        player = player,
        logSettings = {
            color = defaultMsgColor,
            sound = defines.print_sound.never,
            game_state = false,
            skip = defines.print_skip.never,
        }
    } or nil

    local watchLastInserter = playerIsConnected and player.mod_settings["inserter-fuel-leech-watch-last-inserter"].value
    settingsCache.watchLastInserterPlayers[playerIndex] = watchLastInserter and {
        player = player,
        logSettings = {
            color = player.mod_settings["inserter-fuel-leech-last-inserter-log-color"].value,
            sound = defines.print_sound.never,
            game_state = false,
            skip = defines.print_skip.never,
        }
    } or nil

end
