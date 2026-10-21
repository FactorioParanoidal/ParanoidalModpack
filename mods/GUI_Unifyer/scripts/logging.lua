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

local player_levels = {}

local function should_log(level, player)
    if not player or not player.valid then return false end
    local minimum = player_levels[player.index]
    if minimum == nil then
        local player_settings = settings.get_player_settings(player)
        local enabled = player_settings["gu_enable_logging"]
        local selected = player_settings["gu_log_level"]
        minimum = enabled and enabled.value and
            (LOG_LEVELS[selected and selected.value or "INFO"] or LOG_LEVELS.INFO) or false
        player_levels[player.index] = minimum
    end
    return minimum and level >= minimum
end

local function format_message(level, category, message)
    return string.format("[GUI Unifier %s][%s] %s", get_log_level_name(level), category, message)
end

local M = {}

-- Local cache only; reload rebuilds it lazily without writing persistent state.
function M.invalidate(player_index)
    if player_index then
        player_levels[player_index] = nil
    else
        player_levels = {}
    end
end

function M.debug_enabled(player)
    return should_log(LOG_LEVELS.DEBUG, player)
end

-- Main logging function
function M.log(level, category, message, player)
    if not should_log(level, player) then return end
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