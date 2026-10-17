--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]

--- @alias Logger fun(msg: string, data: any): nil

--- @param data any
--- @param indent string
--- @return string
local function serializeForLog(data, indent)
    if type(data) == "table" then
        --- @type string[]
        local lines = {}
        for k, v in pairs(data) do
            lines[#lines+1] = "\n"
            lines[#lines+1] = indent
            if type(k) == "string" then
                lines[#lines+1] = k
            else
                lines[#lines+1] = serpent.line(k)
            end
            lines[#lines+1] = ": "
            lines[#lines+1] = serializeForLog(v, ".   " .. indent)
        end
        return table.concat(lines)
    else
        return serpent.line(data)
    end
end

--- @param ticks uint
--- @return string
function formatTickForLog(ticks)
    local accu = ticks
    ticks = accu % 60
    accu = math.floor(accu / 60)
    local seconds = accu % 60
    accu = math.floor(accu / 60)
    local minutes = accu % 60
    accu = math.floor(accu / 60)
    local hours = accu % 24
    local days = math.floor(accu / 24)
    local result = ""
    if days > 0 then
        result = tostring(days) .. "d"
    end
    if string.len(result) ~= 0 or hours > 0 then
        result = result .. string.format("%02d:", hours)
    end
    if string.len(result) ~= 0 or minutes > 0 then
        result = result .. string.format("%02d:", minutes)
    end
    if string.len(result) ~= 0 or seconds > 0 then
        result = result .. string.format("%02d.", seconds)
    end
    result = result .. string.format("%02dt", ticks)
    return result
end

--- @param playersSettings nil|PlayerSettingsCache[]|table<integer?,PlayerSettingsCache?>
--- @param logToconsole boolean
--- @param msg string
--- @param data any
--- @return nil
function logMsg(playersSettings, logToconsole, msg, data)
    msg = formatTickForLog(game.tick) .. " " .. script.mod_name .. ": " .. msg
    if data then
        if type(data) == "table" then
            msg = msg .. serializeForLog(data, "")
        else
            msg = msg .. " data: " .. serializeForLog(data, "")
        end
    end
    if logToconsole then
        print(msg)
    end
    if playersSettings then
        for _, playerSettings in pairs(playersSettings) do
            playerSettings.player.print(msg, playerSettings.logSettings)
        end
    else
        game.print(msg)
    end
end

--- @param playersSettings PlayerSettingsCache[]|table<integer?,PlayerSettingsCache?>
--- @param logToconsole boolean
--- @return Logger
function getLogger(playersSettings, logToconsole)
    return function(msg, data) logMsg(playersSettings, logToconsole, msg, data) end
end
