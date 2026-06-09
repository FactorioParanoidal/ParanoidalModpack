-- Load event and remote-call function libraries
require("lua/events")
require("lua/remotes")

--[[ How to: Subscribe to mod events
  Basics: Get the event id from a remote interface. Subscribe to the event in on_init and on_load.

  Example:
  local init = function ()
    if script.active_mods["AbandonedRuins_updated_fork"] then
      script.on_event(remote.call("AbandonedRuins", "get_on_entity_force_changed_event"),
      ---@param event on_entity_force_changed_event_data
      function(event)
        -- An entity changed force, let's handle that
        ---@type LuaEntity
        local entity = event.entity
        ---@type LuaForce
        local old_force = event.force
        ---@type LuaForce
        local new_force = entity.force

        -- handle the force change
        utils.output_message("old: " .. old_force.name .. " new: " .. new_force.name)
      end)
    end
  end

  script.on_load(init)
  script.on_init(init)
--]]
