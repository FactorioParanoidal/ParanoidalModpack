local Rooms = require("script.external-rooms.registry")
local function moved(event)
    Rooms.host_changed(event.moved_entity)
    factorissimo.connection_entity_moved(event.moved_entity, event.start_pos)
end

local function register_move_event()
    local interface = remote.interfaces["PickerDollies"]
    if not (interface and interface.dolly_moved_entity_id) then return end

    local event_id = remote.call("PickerDollies", "dolly_moved_entity_id")
    if event_id then script.on_event(event_id, moved) end
end

-- The getter only reads the current event ID. An ID from the save may be invalid
-- before on_configuration_changed runs, so restore the subscription without using storage.
factorissimo.on_event(factorissimo.events.on_load(), register_move_event)

factorissimo.on_event(factorissimo.events.on_init(), function()
    register_move_event()
    local interface = remote.interfaces["PickerDollies"]
    if not (interface and interface.add_blacklist_name) then return end

    remote.call("PickerDollies", "add_blacklist_name", "factory-1", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-2", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-3", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-4", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-1", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-2", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-3", true)
end)
