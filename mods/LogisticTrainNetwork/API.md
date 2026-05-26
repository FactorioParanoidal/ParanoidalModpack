# LTN API

LTN offers a large API for other mods to interact.

All methods can be accessed through the LTN remote interface:

```lua
-- Test for LTN API availability
local ltn_present = remote.interfaces["logistic-train-network"] and true or false
```

The documentation refers to LTN data types, which are defined [in the types.lua](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/types.lua) metadata file.

----

## API Changelog

### Quality Support (v 2.1.0+)

Factorio 2.0 supports quality for items, so any item can exist in different qualities.

To support quality for requesters and providers with LTN, the API requires some minor changes.

If you do not use quality in your game (or only use items of 'normal' quality), nothing changes within the API.

#### Changes to cargo identifiers

LTN internally uses "typed" strings such as `item,advanced-circuit` or `fluid,crude-oil` as cargo identifiers to manage station inventory and requests. All uses of those strings are marked with `ltn.ItemIdentifier` [in the types.lua](https://github.com/hgschmie/factorio-LogisticTrainNetwork/blob/master/types.lua) metadata file.

Starting with 2.1.0, whenever LTN sees a provider or requester item signal that has quality included, it will use a *third* field: `item,advanced-circuit,epic`. For normal quality, this field is omitted.

The recommended way to parse these attributes was using the following lua regular expression: `'([^,]+),([^,]+)'` with `string.match`. This will still work but lose the third (quality) field. Instead, it is recommended to parse these identifiers as follows:

```lua
local identifier = 'item,advanced-circuit,epic'

local type, name, quality = identifier:match('^([^,]+),([^,]+),?([^,]*)')
quality = (quality and #quality > 0) and quality or 'normal'
```

#### Event changes

The `ltn.EventData.no_train_found_shipment` payload which is raised when LTN has a scheduled shipment but no matching train could be found contains the `shipment` attribute which is a list of `ltn.LoadingElement` objects. Each of these objects now has an additional, optional attribute `quality` attribute.

### Fuel Stations (v 2.3.0+)

Fuel station support adds a few new attributes to the `ltn.TrainStop` data type. Any external mod that reads this information needs to check the following attributes to determine the station type:

- if `is_depot` is true, then the station is a Depot
- if `is_fuel_station` is true, then the station is a Fuel Station
- otherwise the station participates in deliveries and can be a requester or a provider.

Reference code:

```lua
---@enum ltn.StationType
station_type = {
    station = 1,
    depot = 2,
    fuel_stop = 3,
}

---@param station ltn.TrainStop|ltn.SignalState
---@return ltn.StationType station_type The station type
function GetStationType(station)
    if station.is_depot then return station_type.depot end
    if station.is_fuel_station then return station_type.fuel_stop end
    return station_type.station
end
```

----

## API documentation

### Events

All LTN events are available through the remote API:

The `remote.class("logistic-train-network", <event-name>)` call returns an event id that can be used with the `script.on_event` function to receive a callback:

```lua
-- receive a callback when stops are updated
script.on_event(remote.call("logistic-train-network", "on_stops_updated"), <code to be called>)
```

#### on_dispatcher_updated

Raised whenever the dispatcher has finished scheduling, after all deliveries have been generated. Sends out a `ltn.EventData.on_dispatcher_updated` payload.

#### on_stops_updated

Raised whenever the dispatcher has finished scheduling, after all deliveries have been generated. Sends out a `ltn.EventData.on_stops_updated` payload.

#### on_dispatcher_no_train_found

Raised whenever the dispatcher can not schedule a train for a delivery. Sends out a `ltn.EventData.no_train_found` payload, which is a union of two different payloads:

If no train capacity at all is available to create a shipment (because all the depots are empty), the dispatcher sends this event with a `ltn.EventData.no_train_found_item` payload.

If capacity is available but not train could be found that matches the criterias to create a delivery, this event is raised with a `ltn.EventData.no_train_found_shipment` payload.

The two payloads can be differentiated by the presence of the `item` field.

#### on_delivery_pickup_complete

Raised whenever a pickup is complete and a train leaves the provider stop. Sends out a `ltn.EventData.delivery_pickup_complete` payload.

#### on_delivery_completed

Raised when a dropoff is complete and a train leaves the requester stop. Sends out a `ltn.EventData.delivery_complete` payload.

#### on_delivery_failed

Raised when a delivery has failed (e.g. train gets removed, the delivery timed out, train enters depot stop with active delivery). Sends out a `ltn.EventData.on_delivery_failed` payload.

### on_delivery_reassigned (since 2.5.0)

Raised when a delivery is reassigned from one train to another. Sends out a `ltn.EventData.on_delivery_reassigned` payload.

### Alerts

Each of the alert events is sent in addition to the normal delivery events.

#### on_provider_missing_cargo

Raised when a train leaves a pickup station with missing cargo. Sends out a `ltn.EventData.provider_missing_cargo` payload.

#### on_provider_unscheduled_cargo

Raised when a train leaves a pickup station with additional cargo. Sends out a `ltn.EventData.unscheduled_cargo` payload.

#### on_requester_unscheduled_cargo

Raised when a train arrives at a dropoff with additionalt cargo. Sends out a `ltn.EventData.unscheduled_cargo` payload.

#### on_requester_remaining_cargo

Raised when a train leaves a dropoff with remaining cargo. Sends out a `ltn.EventData.requester_remaining_cargo` payload.

### Cross-Surface operations

__If you design a mod that uses the cross-surface operations mod, please read the following implementation notes:__

When calling `connect_surfaces`, LTN will retain a reference to the entities passed in. That means, if your mod invalidates these entities without calling `disconnect_surfaces` or `clear_all_surface_connections`, LTN will have references to invalid LuaEntities. Those Entities may be passed back in some events, especially `on_dispatcher_updated`.

_As Factorio will not raise events with invalid entities in the payload_, LTN must filter out these invalid entities. It does so by tracking destruction of these entities but this is expensive and (in large games) may lead to FPS problems. There is a [modding interface request](https://forums.factorio.com/viewtopic.php?t=133664) that would allow some mitigation.

LTN works better if these entities do not get invalidated while LTN knows about them:

- before destroying connection objects, call `disconnect_surfaces` or even `clear_all_surface_connections` to inform LTN that it should no longer hold references to these entities.
- Only destroy or invalidate these entities when it is really necessary. The [LTN - Space Exploration Integration](https://mods.factorio.com/mod/ltn-space-exploration) mod shows how this can be done while still allowing connecting/disconnecting between surfaces.

If you change or update your mod, make it depend on LTN version 2.7.1 or later to ensure that LTN and your mod will coexist well.

#### reassign_delivery API

Re-assigns a delivery to a different train. Should be called after creating a train based on another train, for example after moving a train to a different surface.

Calls with an old_train_id without delivery have no effect. Don't call this function when coupling trains via script, LTN already handles that through Factorio events. This function does not add missing temp stops. See `get_or_create_next_temp_stop` for that.

```lua
remote.call('logistic-train-network', 'reassign_delivery', old_train, new_train)
```

#### get_or_create_next_temp_stop

Finds or, if necessary, creates a new temporary stop before the next logistic stop.

Ensures the next logistic stop in the schedule has a temporary stop if it is on the same surface as the train. If no schedule_index is given, the search for the next logistic stop starts from `train.schedule.current`. In case the train is currently stopping at that index, the search starts at the next higher index.

The result is the schedule index of the temp stop of the next logistic stop or `nil` if there is no further logistic stop.

```lua
local schedule_index = remote.call('logistic-train-network', 'get_or_create_next_temp_stop', train)
```

#### get_next_logistic_stop

Finds the next logistic stop in the schedule of the given train. If no schedule_index is given, the search starts from `train.schedule.current`. In case the train is currently stopping at that index, the search starts at the next higher index.

The result will be three values:

- stop_schedule_index        - number?
- stop_id                    - number?
- 'provider'|'requester'|nil - string?

If there is no further logistic stop in the schedule, the result will be all `nil`.

#### connect_surfaces

Adds a surface connection between the given entities; the network_id will be used in delivery processing to discard providers that don't match the surface connection's network_id.

```lua
remote.call('logistic-train-network', 'connect_surfaces', entity1, entity2, network_id)
```

#### disconnect_surfaces

Removes a surface connection formed by the two given entities. Active deliveries will not be affected. It is not necessary to call this function when deleting one or both entities.

```lua
remote.call('logistic-train-network', 'disconnect_surfaces', entity1, entity2)
```

#### clear_all_surface_connections

Clears all surface connections. Active deliveries will not be affected.

(This function exists for debugging purposes, no event is raised to notify connection owners.)

```lua
remote.call('logistic-train-network', 'clear_all_surface_connections')
```
