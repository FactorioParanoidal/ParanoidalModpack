--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @param command CustomCommandData
--- @param denyNonAdmin boolean
--- @param extraLoggerPlayers table<integer?,PlayerSettingsCache?>
--- @param alwaysLogToConsole boolean
--- @param onAllowedFun fun(logger: Logger, commanderName: string): nil
--- @return nil
local function executeCommand(command, denyNonAdmin, extraLoggerPlayers, alwaysLogToConsole, onAllowedFun)
    local playerIndex = command.player_index
    local player = playerIndex and game.get_player(playerIndex)
    if playerIndex and not player then
        return
    end

    if denyNonAdmin and playerIndex and (not player or not player.admin) then
        logMsg({settingsCache.logCommandsPlayers[playerIndex]}, true, "Denied " .. command.name .. " because not an admin.", nil)
        return
    end

    local logPlayers = {}
    for index, playerSettings in pairs(extraLoggerPlayers) do
        logPlayers[index] = playerSettings
    end
    if playerIndex then
        logPlayers[playerIndex] = settingsCache.logCommandsPlayers[playerIndex]
    end
    local logToConsole = alwaysLogToConsole or not playerIndex
    local logger = getLogger(logPlayers, logToConsole)

    local commanderName = player and player.name or "server console"

    onAllowedFun(logger, commanderName)
end

--- @param command CustomCommandData
--- @return nil
local function commandResetModState(command)
    executeCommand(command, true, settingsCache.logLowTrafficPlayers, true, function(logger, commanderName)
        logger("State reset triggered by " .. commanderName .. "...", nil)
        initInserterRepo(command.tick, logger)
        initInserterDiscovery(command.tick, logger)
        logger("State reset done.", nil)
    end)
end

--- @param command CustomCommandData
--- @return nil
local function commandShowStats(command)
    executeCommand(command, false, {}, false, function(logger, commanderName)
        logger("Stats requested by " .. commanderName .. ".", nil)
        logger("", getInserterStats(command.tick))
        testCalcVectorMinTurnsAndExtension(logger)
    end)
end

--- @return nil
function initConsoleCommands()
    commands.add_command(
        "iflreset",
        "Reinitializes the Inserter Fuel Leech mod state including rediscovering all inserters. Admins only.",
        commandResetModState
    )
    commands.add_command(
        "iflstats",
        "Prints Inserter Fuel Leech mod stats. This is fast.",
        commandShowStats
    )
end
