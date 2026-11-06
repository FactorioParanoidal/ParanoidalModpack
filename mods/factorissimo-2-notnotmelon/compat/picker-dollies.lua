local function moved(event)
    factorissimo.connection_entity_moved(event.moved_entity, event.start_pos)
end

local function register_move_event()
    if storage.picker_dollies_event then script.on_event(storage.picker_dollies_event, moved) end
end

-- The interface may load after Factorissimo. Discover the event on init/configuration change;
-- on_load only restores the subscription, without writing storage or calling other mods.
factorissimo.on_event(factorissimo.events.on_load(), register_move_event)

factorissimo.on_event(factorissimo.events.on_init(), function()
    if storage.picker_dollies_event then script.on_event(storage.picker_dollies_event, nil) end
    local interface = remote.interfaces["PickerDollies"]
    storage.picker_dollies_event = interface and interface.dolly_moved_entity_id
        and remote.call("PickerDollies", "dolly_moved_entity_id") or nil
    register_move_event()
    if not interface then return end

    remote.call("PickerDollies", "add_blacklist_name", "factory-1", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-2", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-3", true)
    remote.call("PickerDollies", "add_blacklist_name", "factory-4", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-1", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-2", true)
    remote.call("PickerDollies", "add_blacklist_name", "space-factory-3", true)
end)
