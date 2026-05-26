--[[ Copyright (c) 2017 Optera
 * Part of Logistics Train Network
 *
 * See LICENSE.md in the project directory for license information.
--]]

local SurfaceInterface = require('script.surface-interface')
local TrainInterface = require('script.train-interface')

---@type defines.events
on_stops_updated_event = script.generate_event_name()
---@type defines.events
on_dispatcher_updated_event = script.generate_event_name()
---@type defines.events
on_dispatcher_no_train_found_event = script.generate_event_name()
---@type defines.events
on_delivery_created_event = script.generate_event_name()
---@type defines.events
on_delivery_pickup_complete_event = script.generate_event_name()
---@type defines.events
on_delivery_completed_event = script.generate_event_name()
---@type defines.events
on_delivery_failed_event = script.generate_event_name()
---@type defines.events
on_delivery_reassigned_event = script.generate_event_name()

---@type defines.events
on_provider_missing_cargo_alert = script.generate_event_name()
---@type defines.events
on_provider_unscheduled_cargo_alert = script.generate_event_name()
---@type defines.events
on_requester_unscheduled_cargo_alert = script.generate_event_name()
---@type defines.events
on_requester_remaining_cargo_alert = script.generate_event_name()

-- ltn_interface allows mods to register for update events
remote.add_interface('logistic-train-network', {
    -- updates for ltn_stops
    on_stops_updated = function() return on_stops_updated_event end,

    -- updates for dispatcher
    on_dispatcher_updated = function() return on_dispatcher_updated_event end,
    on_dispatcher_no_train_found = function() return on_dispatcher_no_train_found_event end,
    on_delivery_created = function() return on_delivery_created_event end,

    -- update for updated deliveries after leaving provider
    on_delivery_pickup_complete = function() return on_delivery_pickup_complete_event end,

    -- update for completing deliveries
    on_delivery_completed = function() return on_delivery_completed_event end,
    on_delivery_failed = function() return on_delivery_failed_event end,
    on_delivery_reassigned = function() return on_delivery_reassigned_event end,

    -- alerts
    on_provider_missing_cargo = function() return on_provider_missing_cargo_alert end,
    on_provider_unscheduled_cargo = function() return on_provider_unscheduled_cargo_alert end,
    on_requester_unscheduled_cargo = function() return on_requester_unscheduled_cargo_alert end,
    on_requester_remaining_cargo = function() return on_requester_remaining_cargo_alert end,

    -- surface connections
    connect_surfaces = SurfaceInterface.ConnectSurfaces,     -- function(entity1 :: LuaEntity, entity2 :: LuaEntity, network_id :: int32)
    disconnect_surfaces = SurfaceInterface.DisconnectSurfaces, -- function(entity1 :: LuaEntity, entity2 :: LuaEntity)
    clear_all_surface_connections = SurfaceInterface.ClearAllSurfaceConnections,

    -- Re-assigns a delivery to a different train.
    reassign_delivery = TrainInterface.ReassignDelivery,                 -- function(old_train_id :: uint, new_train :: LuaTrain) :: bool
    get_or_create_next_temp_stop = TrainInterface.GetOrCreateNextTempStop, -- function(train :: LuaTrain, schedule_index :: uint?) :: uint
    get_next_logistic_stop = TrainInterface.GetNextLogisticStop,         -- function(train :: LuaTrain, schedule_index :: uint?) :: uint?, uint?, string?
})
