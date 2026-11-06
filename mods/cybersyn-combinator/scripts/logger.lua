local log = log or print
local sformat = string.format
local tconcat = table.concat

local constants = require "scripts.constants"
local MOD_TITLE = constants.MOD_TITLE

local NOOP = function() end

--- @class Logger
--- @field context string
--- @field [string] Logger
--- @operator call():Logger
local Logger = {
  context = constants.MOD_NAME
}

--- @type { [string]: boolean }
local super_methods = {}

--- @type table
local Logger_mt = {
  --- @param t Logger
  --- @param k any
  __index = function(t, k)
    local logger = t:new(t.context, k)
    rawset(t, k, logger)
    return logger
  end,

  --- @param t Logger
  --- @param k any
  --- @param v any
  __newindex = function(t, k, v)
    rawset(t, k, v)
    super_methods[k] = true
  end,

  --- @param t Logger
  --- @param ... LocalisedString
  __call = function(t, ...) return t:info(...) end
}

setmetatable(Logger, Logger_mt)

--- @enum LogLevel
local LogLevel = {
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  DISABLED = 99
}

Logger.LogLevel = LogLevel

local settings_loglevel = settings.startup[constants.SETTINGS.LOG_LEVEL].value
local settings_chatlevel = settings.startup[constants.SETTINGS.CHAT_LOG_LEVEL].value
local THRESHOLD = LogLevel[settings_loglevel]
local CHAT_THRESHOLD = LogLevel[settings_chatlevel]

--- @type { [LogLevel]: string }
local LEVEL_PREFIXES = {
  [LogLevel.DEBUG] = "DEBUG",
  [LogLevel.INFO] = "INFO",
  [LogLevel.WARN] = "WARN",
  [LogLevel.ERROR] = "ERROR"
}

local LEVEL_PREFIX_COLORS = {
  [LogLevel.DEBUG] = "green",
  [LogLevel.INFO] = "blue",
  [LogLevel.WARN] = "yellow",
  [LogLevel.ERROR] = "red"
}

local PREFIX_FORMAT = "%s - %5s: "
local RICH_PREFIX_FORMAT = "%s[color=gray][%s][/color] [color=%s]%s[/color]: "

--- @param level LogLevel
--- @param context string
--- @return string
local function build_prefix(level, context)
  return sformat(PREFIX_FORMAT, context, LEVEL_PREFIXES[level])
end

--- @param level LogLevel
--- @param context string
--- @return LocalisedString
local function build_rich_prefix(level, context)
  local color = LEVEL_PREFIX_COLORS[level]
  local text = sformat(RICH_PREFIX_FORMAT, MOD_TITLE, context, color, LEVEL_PREFIXES[level])
  return text
end

--- @param ... any?
--- @return Logger
function Logger:new(...)
  return setmetatable({
    context = tconcat({ ... }, ".")
  }, {
    --- @param t Logger
    --- @param k any
    --- @return any
    __index = function(t, k)
      if super_methods[k] then return rawget(self, k) end
      local logger = self:new(rawget(t, "context"), k)
      rawset(t, k, logger)
      return logger
    end,

    --- @param t Logger
    --- @param ... LocalisedString
    __call = function(t, ...)
      return t:info(...)
    end
  })
end

if THRESHOLD < LogLevel.DISABLED then
  --- @param level LogLevel
  --- @param ... LocalisedString
  function Logger:log(level, ...)
    if level < THRESHOLD then return self end
    local prefix = build_prefix(level, self.context)
    local msg = { "", prefix, ... }
    log(msg)
    if level < CHAT_THRESHOLD or not game then return end
    local rich_prefix = build_rich_prefix(level, self.context)
    local gmsg = { "", rich_prefix, ... }
    game.print(gmsg)
  end
else
  Logger.log = NOOP
end

if THRESHOLD <= LogLevel.DEBUG then
  --- @param ... LocalisedString
  function Logger:debug(...) self:log(LogLevel.DEBUG, ...) end
else
  Logger.debug = NOOP
end

if THRESHOLD <= LogLevel.INFO then
  --- @param ... LocalisedString
  function Logger:info(...) self:log(LogLevel.INFO, ...) end
else
  Logger.info = NOOP
end

if THRESHOLD <= LogLevel.WARN then
  --- @param ... LocalisedString
  function Logger:warn(...) self:log(LogLevel.WARN, ...) end
else
  Logger.warn = NOOP
end

if THRESHOLD <= LogLevel.ERROR then
  --- @param ... LocalisedString
  function Logger:error(...) self:log(LogLevel.ERROR, ...) end
else
  Logger.error = NOOP
end

return Logger
