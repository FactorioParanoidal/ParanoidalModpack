mod_prefix = "ghost-counter-"
NAME = require("shared/constants")

require("scripts/core")
require("scripts/events")
require("scripts/gui")

---Creates all necessary global tables.
function on_init()
    ---@type table<uint, Playerdata> Table of all `playerdata` tables, indexed by `player_index`
    global.playerdata = {}

    ---@type uint Last game tick where an event updated mod data
    global.last_event = 0

    ---@type {min_update_interval: uint} Map settings table
    global.settings = {min_update_interval=settings.global[NAME.setting.min_update_interval].value --[[@as uint]]}

    ---@type table<string, boolean> Contains registration status of different event handler groups
    global.events = {inventory=false, logistics=false, nth_tick=false}
end
script.on_init(on_init)

---Re-setups conditional event handlers.
function on_load()
    -- Inventory/entity event handlers
    if global.events.inventory then
        script.on_event(defines.events.on_player_main_inventory_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_player_cursor_stack_changed,
            on_player_main_inventory_changed)
        script.on_event(defines.events.on_entity_destroyed, on_ghost_destroyed)
    end

    -- Logistics event handler
    if global.events.logistics then
        script.on_event(defines.events.on_entity_logistic_slot_changed,
            on_entity_logistic_slot_changed)
    end

    -- nth_tick event handler
    if global.events.nth_tick then
        script.on_nth_tick(global.settings.min_update_interval, on_nth_tick)
    end
end
script.on_load(on_load)

---Validates mod data.
function on_configuration_changed()
    -- Validate `playerdata.job` table and contents
    for _, playerdata in pairs(global.playerdata) do
        playerdata.job = playerdata.job or {}
        playerdata.job.area = playerdata.job.area or {}
        playerdata.job.ghosts = playerdata.job.ghosts or {}
        playerdata.job.requests = playerdata.job.requests or {}
        playerdata.job.requests_sorted = playerdata.job.requests_sorted or {}
    end
end
script.on_configuration_changed(on_configuration_changed)

---Re-registers event handlers if appropriate for joining player.
---@param event EventData.on_player_joined_game Event table
function on_player_joined_game(event)
    local playerdata = get_make_playerdata(event.player_index)

    if playerdata.is_active then register_inventory_monitoring(true) end
    if playerdata.is_active or table_size(playerdata.logistic_requests) > 0 then
        register_logistics_monitoring(true)
    end
end
script.on_event(defines.events.on_player_joined_game, on_player_joined_game)

---Re-evaluates whether event handlers should continue to be bound.
---@param event EventData.on_player_left_game Event able
function on_player_left_game(event)
    if not is_inventory_monitoring_needed() then register_inventory_monitoring(false) end
    if not is_logistics_monitoring_needed() then register_logistics_monitoring(false) end
end
script.on_event(defines.events.on_player_left_game, on_player_left_game)

---Deletes playerdata table associated with removed player.
---@param event EventData.on_player_removed Event table
function on_player_removed(event)
    global.playerdata[event.player_index] = nil

    if not is_inventory_monitoring_needed() then register_inventory_monitoring(false) end
    if not is_logistics_monitoring_needed() then register_logistics_monitoring(false) end
end
script.on_event(defines.events.on_player_removed, on_player_removed)

---Listens to runtime settings changes.
---@param event EventData.on_runtime_mod_setting_changed Event table
function on_runtime_mod_setting_changed(event)
    if event.setting == NAME.setting.min_update_interval then
        local new_value = settings.global[NAME.setting.min_update_interval].value --[[@as uint]]

        -- Reregister on_nth_tick event handler using the new minimum interval
        if global.events.nth_tick then
            ---@diagnostic disable-next-line
            script.on_nth_tick(nil)
            script.on_nth_tick(new_value, on_nth_tick)
        end

        global.settings.min_update_interval = new_value
    end
end
script.on_event(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
