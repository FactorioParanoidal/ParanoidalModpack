---Sorry to disappoint if you were expecting a real debugging tool, that's way above me
---This is basically a glorified error(serpent.block( )); it is my crutch

---@class Debug
local Debug = {}

--- Prints a structured error message with detailed object information.
--- @param object any # The object to include in the error message.
function Debug.error(object)
    local msg = "\n\nIf an end user sees this error message, something went terribly wrong."
    msg = msg .. "\nPlease report this error to the mod author, including any relevant mods."
    msg = msg .. "\nInformation used for debugging below:\n\n"
    error(msg .. serpent.block(object),4)
end

return Debug