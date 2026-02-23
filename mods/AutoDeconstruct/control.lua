require "script.autodeconstruct"

function msg_all(message)
  if message[1] == "autodeconstruct-debug" then
    table.insert(message, 2, debug.getinfo(2).name)
  end
  for _,p in pairs(game.players) do
    p.print(message)
  end
  log(message)
end


function debug_message_with_position(entity, msg)
  if not storage.debug then return end
  msg_all({"autodeconstruct-debug", util.positiontostr(entity.position) .. " " .. entity.name  .. " " .. msg})
end

-- Use a prime number interval so we don't regularly collide with any even-numbered events
local UPDATE_INTERVAL = 17

local function on_nth_tick()
  autodeconstruct.process_queue()
  if not next(storage.drill_queue) then
    script.on_nth_tick(UPDATE_INTERVAL, nil)
  end
end

local function update_tick_event()
  if storage.drill_queue and next(storage.drill_queue) then
    -- Make sure event is enabled when queue has entries
    script.on_nth_tick(UPDATE_INTERVAL, on_nth_tick)
  else
    -- Make sure event is disabled when queue is empty
    script.on_nth_tick(UPDATE_INTERVAL, nil)
  end
end


-- Debug command
function cmd_debug(params)
  local cmd = params.parameter
  if cmd == "on" then
    storage.debug = true
    game.print("Autodeconstruct debug prints enabled")
  elseif cmd == "off" then
    storage.debug = false
    game.print("Autodeconstruct debug prints disabled")
  elseif cmd == "init" then
    game.print("Autodeconstruct stored state reset")
    autodeconstruct.init_globals()
    update_tick_event()
  elseif cmd == "print" then
    game.print("Autodeconstruct storage.max_radius = "..tostring(storage.max_radius))
  elseif cmd == "dump" then
    game.print(serpent.block(storage))
  elseif cmd == "dumplog" then
    log(serpent.block(storage))
    game.print("Autodeconstruct storage logged")
  else
    storage.debug = not storage.debug
    if storage.debug then
      game.print("Autodeconstruct debug prints enabled")
    else
      game.print("Autodeconstruct debug prints disabled")
    end
  end
end
commands.add_command("ad-debug", "Usage: ad-debug [on | off | init]", cmd_debug)



script.on_init(function()
  autodeconstruct.init_globals()
  update_tick_event()
end)

script.on_load(function()
  update_tick_event()
end)

script.on_configuration_changed(function()
  -- Check the pipe settings for valid entity prototypes
  autodeconstruct.init_globals()
  update_tick_event()
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if( event.setting == "autodeconstruct-pipe-name" or 
      event.setting == "autodeconstruct-remove-fluid-drills" or 
      event.setting == "autodeconstruct-remove-wired" or
      event.setting == "autodeconstruct-blacklist" or
      event.setting == "autodeconstruct-ore-blacklist" ) then
    autodeconstruct.init_globals()
  end
  update_tick_event()
end)

script.on_event(defines.events.on_cancelled_deconstruction,
  function(event)
    autodeconstruct.on_cancelled_deconstruction(event)
    update_tick_event()
  end,
  {{filter="type", type="mining-drill"}}
)

script.on_event(defines.events.on_resource_depleted, function(event)
  autodeconstruct.on_resource_depleted(event)
  update_tick_event()
end)

------------------------------------------------------------------------------------
--                    FIND LOCAL VARIABLES THAT ARE USED GLOBALLY                 --
--                              (Thanks to eradicator!)                           --
------------------------------------------------------------------------------------
setmetatable(_ENV,{
  __newindex=function (self,key,value) --locked_global_write
    error('\n\n[ER Global Lock] Forbidden global *write*:\n'
      .. serpent.line{key=key or '<nil>',value=value or '<nil>'}..'\n')
    end,
  __index   =function (self,key) --locked_global_read
    error('\n\n[ER Global Lock] Forbidden global *read*:\n'
      .. serpent.line{key=key or '<nil>'}..'\n')
    end ,
  })

if script.active_mods["gvv"] then require("__gvv__.gvv")() end
