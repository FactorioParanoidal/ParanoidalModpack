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

---@param event_id defines.events
---@return EvenPickierDolliesRemoteInterface
return function (event_id)
    return {

        ---@return defines.events event_id The event id to use when registering for dollies events.
        dolly_moved_entity_id = function ()
            return event_id
        end,

        ---@param entity_name string
        ---@param distance number?
        ---@return boolean
        add_oblong_name = function (entity_name, distance)
            storage.oblong_names = storage.oblong_names or {}
            local proto = prototypes.entity[entity_name]
            if not proto then return false end

            storage.oblong_names[entity_name] = distance or 0.5
            return true
        end,

        ---@param entity_name string
        ---@return boolean
        remove_oblong_name = function (entity_name)
            storage.oblong_names = storage.oblong_names or {}
            if not storage.oblong_names[entity_name] then return false end

            storage.oblong_names[entity_name] = nil
            return true
        end,

        ---@return table<string, number>
        get_oblong_names = function ()
            storage.oblong_names = storage.oblong_names or {}
            return storage.oblong_names
        end,

        ---@param entity_name string
        ---@return boolean
        add_blacklist_name = function (entity_name)
            storage.blacklist_names = storage.blacklist_names or {}
            local proto = prototypes.entity[entity_name]
            if not proto then return false end

            storage.blacklist_names[entity_name] = true
            return true
        end,

        ---@param entity_name string
        ---@return boolean
        remove_blacklist_name = function (entity_name)
            storage.blacklist_names = storage.blacklist_names or {}
            if not storage.blacklist_names[entity_name] then return false end

            storage.blacklist_names[entity_name] = nil
            return true
        end,

        ---@return table<string, true>
        get_blacklist_names = function ()
            storage.blacklist_names = storage.blacklist_names or {}
            return storage.blacklist_names
        end
    }
end
