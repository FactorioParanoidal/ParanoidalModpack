------------------------------------------------------------------------
-- Framework logger
------------------------------------------------------------------------

local StdLibLogger = require('stdlib.misc.logger')

----------------------------------------------------------------------------------------------------

local dummy = function(...) end

local default_logger = { log = log }

--- Logging

---@class FrameworkLogger
---@field debug_mode boolean? If true, debug and debugf produce output lines
---@field core_logger table<string, any> The logging target
local FrameworkLogger = {
    debug_mode = nil,
    core_logger = default_logger,

    debug = dummy,
    debugf = dummy,
    flush = dummy,
}

---@param message string
function FrameworkLogger:log(message)
    self.core_logger.log(message)
end

---@param message string
---@param ... any
function FrameworkLogger:logf(message, ...)
    self.core_logger.log(message:format(table.unpack { ... }))
end

if FrameworkLogger.debug_mode then
    FrameworkLogger.debug = FrameworkLogger.log
    FrameworkLogger.debugf = FrameworkLogger.logf
end

function FrameworkLogger:updateDebugSettings()
    local new_debug_mode = Framework.settings:startup_setting('debug_mode') --[[@as boolean]]

    if new_debug_mode ~= self.debug_mode then
        self:log('==')
        self:logf('== Debug Mode %s.', new_debug_mode and 'enabled' or 'disabled')
        self:log('==')
    end

    -- reset debug logging, turn back on if debug_mode is still set
    self.debug = (new_debug_mode and self.log) or dummy
    self.debugf = (new_debug_mode and self.logf) or dummy

    self.debug_mode = new_debug_mode
end

----------------------------------------------------------------------------------------------------

if script then
    local Event = require('stdlib.event.event')

    local function register_events()
        Event.on_nth_tick(3600, function(ev)
            Framework.logger:flush()
        end)

        -- Runtime settings changed
        Event.register(defines.events.on_runtime_mod_setting_changed, function()
            Framework.logger:updateDebugSettings()
        end)
    end

    --- Brings up the actual file logging using the stdlib. This only works in runtime mode, otherwise logging
    --- just goes to the regular logfile/output.
    ---
    --- writes a <module-name>/framework.log logfile by default
    function FrameworkLogger:init()
        self.core_logger = StdLibLogger.new('framework', self.debug_mode, { force_append = true })

        self.flush = function() self.core_logger.write() end

        self:updateDebugSettings()

        Event.on_init(register_events)
        Event.on_load(register_events)
    end
end

return FrameworkLogger
