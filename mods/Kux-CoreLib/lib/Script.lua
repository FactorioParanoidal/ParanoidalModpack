--
-- DRAFT --
-- This module provides a Lua wrapper class for the global `script` object.

--- Lua-Wrapper for the global `script` object.
--- @class Script : LuaBootstrap
Script = {}

setmetatable(Script, {
    __index = function(_, key)
        return script[key]
    end,
    __newindex = function(_, key, value)
        script[key] = value
    end
})

--- Loggt eine benutzerdefinierte Nachricht in das Factorio-Log.
--- @param message string Die Nachricht, die geloggt werden soll.
function Script.custom_log(message)
    log("[Custom Log] " .. message)
end

-- Beispiel für die Verwendung der gemappten Funktion
Script.on_event(defines.events.on_tick, function(event)
    log("Script mapped on_event executed")
end)

Script.custom_log("This is a custom log message")