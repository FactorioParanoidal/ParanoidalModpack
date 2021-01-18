MOD_LOG_RELEASE = 0
MOD_LOG_DEBUG   = 1
  
local log_level = MOD_LOG_RELEASE

global.messages = {}

local function mod_print(message)
  if not game or #game.players <= 0 then
    global.messages = global.messages or {}
    table.insert(global.messages, message)
  else
    game.print(MOD_STRING .. ": " .. message)
  end
end

local logger = function(message) end
if log_level > MOD_LOG_RELEASE then
  logger = function(message) 
    mod_print(" -- Debug: " .. message)
  end
end

return function() return mod_print, logger end