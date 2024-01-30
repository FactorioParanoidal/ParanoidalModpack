--- Event table returned with the event
---
--- In your mods on_load and on_init, create a function to handle the event
--- ``` lua
--- local function your_function_to_update_the_entity(event)
---    -- Do stuff here
--- end
---
--- script.on_init(function()
---     if remote.interfaces["PickerDollies"] then
---         script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), your_function_to_update_the_entity)
---         remote.call("PickerDollies", "add_blacklist_name", "my_unteleportable_entity_name")
---         remote.call("PickerDollies", "add_oblong_name", "my_oblong_entity_name")
---     end
--- end)
---
--- script.on_load(function()
---     if remote.interfaces["PickerDollies"] then
---         script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), your_function_to_update_the_entity)
---     end
--- end)
--- ```
--- If you are using the remote interface for adding/removing entity names make sure to add PickerDollies as an optional dependency.
--- @class EventData.PickerDollies.dolly_moved_event: EventData
--- @field player_index uint
--- @field moved_entity LuaEntity
--- @field start_pos MapPosition

local interface = require("__stdlib__/stdlib/scripts/interface")
local Event = require("__stdlib__/stdlib/event/event")

interface["dolly_moved_entity_id"] = function()
    return Event.generate_event_name("dolly_moved")
end

--- @param entity_name string
--- @return boolean
interface["add_oblong_name"] = function(entity_name)
    global.oblong_names = global.oblong_names or {}
    local proto = game.entity_prototypes[entity_name]
    if proto then
        global.oblong_names[entity_name] = true
        return true
    end
    return false
end

--- @param entity_name string
--- @return boolean
interface["remove_oblong_name"] = function(entity_name)
    global.oblong_names = global.oblong_names or {}
    if global.oblong_names[entity_name] then
        global.oblong_names[entity_name] = nil
        return true
    end
    return false
end

--- @return {[string]: true}
interface["get_oblong_names"] = function()
    global.oblong_names = global.oblong_names or {}
    return global.oblong_names
end

--- @param entity_name string
--- @return boolean
interface["add_blacklist_name"] = function(entity_name)
    global.blacklist_names = global.blacklist_names or {}
    local proto = game.entity_prototypes[entity_name]
    if proto then
        global.blacklist_names[entity_name] = true
        return true
    end
    return false
end

--- @param entity_name string
--- @return boolean
interface["remove_blacklist_name"] = function(entity_name)
    global.blacklist_names = global.blacklist_names or {}
    if global.blacklist_names[entity_name] then
        global.blacklist_names[entity_name] = nil
        return true
    end
    return false
end

--- @return {[string]: true}
interface["get_blacklist_names"] = function()
    global.blacklist_names = global.blacklist_names or {}
    return global.blacklist_names
end

remote.add_interface(script.mod_name, interface)

return interface
