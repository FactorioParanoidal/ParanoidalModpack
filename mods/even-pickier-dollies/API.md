# API Documentation

Even Pickier Dollies (EPD) implements the same API as the original PickerDollies mod. Any mod that works with PickerDollies in Factorio 1.1 should work the same way with EPD in Factorio 2.0.

## API calls

The API is available to other mods through the `remote.interfaces` attribute. Use

```lua
local function is_picker_dollies_available()
    return (remote and remote.interfaces['PickerDollies']) or false
end
```

to test whether the API is available (the EPD mod has been loaded in the game).

### Event callback

EPD provides a custom event that mods can register and get called when an entity is moved. This event is called for all entities, not just for entities that a mod has registered. It is called for both move and rotate actions.

```lua

---@class epd.Event: EventData
---@field player_index uint                 Player index
---@field moved_entity LuaEntity            The entity that was moved. See 'transporter mode' note below
---@field start_pos MapPosition             The start position from which the entity was moved
---@field start_direction defines.direction The start direction of the entity (since 2.5.0)
---@field start_unit_number integer?        The original unit number of the entity (since 2.5.0)

---@param event epd.Event
local function on_epd_event(event)
end

local function init_epd_event()
    local epd_api = remote.interfaces['PickerDollies']
    assert(epd_api)

    local epd_event_id = remote.call("PickerDollies", "dolly_moved_entity_id")

    script.on_event(epd_event_id, on_epd_event)
end

script.on_init(init_epd_event)
script.on_load(init_epd_event)
```

The `EventData` fields `tick` and `name` (which contains the event id returned by `dolly_moved_entity_id`) are filled after EPD version 2.5.0. If a mod depends on these fields being present, add a dependency to your mod info.json file to require at least this version.

#### `dolly_moved_entity_id(): defines.events`

Returns the event id which EPD will use to send an event to another mod. The return value is actually whatever `LuaBootstrap#generated_event_name` returns but the weirdness of the Lua API makes this a `defines.events` type.

Use this value to register a callback with `script.on_event`. The callback receives an event with the following attributes:

* `player_index`      - `number`. Index of the player that moved or rotated the entity
* `moved_entity`      - `LuaEntity`. The entity that was placed in the target position (see note below!)
* `start_pos`         - `MapPosition`. The starting position of the entity that was moved or rotated.
* `start_direction`   - `defines.direction`. The starting direction of the entity that was moved or rotated.
* `start_unit_number` - `number`. The original unit number of the entity that was moved or rotated.
* `tick`              - `number`. The game tick of this event (since 2.5.0).
* `name`              - `defines.event`. The event id of the event (since 2.5.0).

__[NOTE on 'transporter mode']__

Starting with EPD 2.5.0, 'transporter mode' can move entities that can not be teleported. This is done by creating a identical copy of the entity moved *and destroying* the original entity. So the entity reported by the event may not be the entity expected but a different one (with a different unit number). If a mod relies on the unit_number not changing (or keeping a reference), it needs to check against the `start_unit_number` field to see whether the original entity was replaced.

### Blacklist management

Some mods want to exclude their entities (or hidden entities) from being moved by EPD. They can register with the mod using the blacklist API.

#### `add_blacklist_name(entity_name: string)`

Adds an entity to the blacklist. The entity must be defined in `prototypes.entity`.

```lua
local epd_api = remote.interfaces['PickerDollies']
assert(epd_api)

remote.call('PickerDollies', 'add_blacklist_name', 'my_immovable_entity')
```

registers an entity called `my_immovable_entity`. This entity will not be moved by EPD.

#### `remove_blacklist_name(entity_name: string)`

Removes an entry from the blacklist. Calling this method with an entity name that has not been blacklisted has no effect.

#### `get_blacklist_names(): table<string, true>`

Returns a table where the keys are the blacklisted entities. The value is always `true`.

### Oblong management

EPD supports rotating oblong (rectangular) entities. By default, it only supports the standard game combinators and pump. Mods can register additional entities with EPD which then can also be rotated.

Unlike the original PickerDollies, which only supported 1x2 tiles entities (e.g. a combinator), EPD can rotate any oblong entity if the distance parameter is set correctly. Distance is how far the midpoint of the entity is moving when rotating. This sounds complicated but is pretty straightforward:

For a 1x2 entity, the midpoint is at `{ 1, 0.5 }` and moves to `{ 0.5, 1 }` when rotated. The midpoint moves by 0.5 tiles in x and y direction. This is the distance (it is also the default if no distance is given, which is compatible to PickerDollies).

For a 2x4 entity, the midpoint is at `{ 2, 1 }` and moves to `{ 1, 2 }` when rotated. The midpoint moves by 1 tile in x and y direction. So the distance is 1.

#### `add_oblong_name(entity_name: string, distance: number?)`

Adds an entity for oblong rotation. If the `distance` parameter is omitted, it is assumed to be 0.5 (which is compatible to PickerDollies). The entity must be defined in `prototypes.entity`.

#### `remove_oblong_name(entity_name: string)`

Removes an entity from the oblong rotation list. Calling this method with an entity name that has not been registered has no effect.

#### `get_oblong_names(): table<string, number>`

Returns a table where the keys are the entity names registered for oblong rotation. The value is the distance value (This is different from PickerDollies, where the value is always the `true` constant).

## Using mod-data to register blacklisting (since 2.7.0)

Factorio 2.0.58 introduced a way to create mod specific custom data objects. EPD supports registering blacklisted entities directly (in the prototype phase) without any API calls. It is recommended to register entities either in `data-updates.lua` or `data-final-fixes.lua` as the order in which mods are loaded is undefined and EPD registers its custom object in the initial `data.lua` phase.

```lua
local epd_mod_data = assert(data.raw['mod-data']['even-pickier-dollies']).data
if epd_mod_data then
     epd_mod_data.blacklist_names['blacklisted-entity'] = true
end
```
