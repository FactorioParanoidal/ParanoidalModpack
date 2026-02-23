-- Logging levels
local LOG_LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARNING = 3,
    ERROR = 4
}

local function get_log_level_name(level)
    for name, value in pairs(LOG_LEVELS) do
        if value == level then
            return name
        end
    end
    return "UNKNOWN"
end

local function should_log(player)
    if not player or not player.valid then return false end
    local settings = settings.get_player_settings(player)
    return settings["gu_enable_logging"] and settings["gu_enable_logging"].value
end

local function format_message(level, category, message)
    return string.format("[GUI Unifier %s][%s] %s", get_log_level_name(level), category, message)
end

local M = {}

-- Main logging function
function M.log(level, category, message, player)
    if not should_log(player) then return end
    if type(message) ~= "string" then
        message = serpent.line(message)
    end
    log(format_message(level, category, message))
end

-- Convenience functions for different log levels
function M.debug(category, message, player)
    M.log(LOG_LEVELS.DEBUG, category, message, player)
end

function M.info(category, message, player)
    M.log(LOG_LEVELS.INFO, category, message, player)
end

function M.warning(category, message, player)
    M.log(LOG_LEVELS.WARNING, category, message, player)
end

function M.error(category, message, player)
    M.log(LOG_LEVELS.ERROR, category, message, player)
end

return M 