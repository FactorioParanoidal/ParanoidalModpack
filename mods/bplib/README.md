# Blueprint Manipulation Library

bplib is a set of tools for use by other Factorio mods that need to manipulate blueprints.

Its primary purpose is to address the following pain points for developers working with custom entities that need advanced interaction with blueprints:

- Abstracting over blueprints within or without books, in the library, in the inventory, etc. and treating them in a unified fashion.

- Correctly identifying and updating pre-existing entities in the world when an overlapping blueprint is stamped down.

- Correctly extracting blueprint tags from world entities into blueprints, including when blueprints are updated via "select new contents."

- Doing all of the above while supporting absolute and relative snapping, offsets, books, libraries, the kitchen sink, etc.

## Basic Usage

**NOTE TO DEVELOPERS:** As of Factorio 2.1, the previously-deprecated `blueprint.lua` API is removed altogether. You must port your mods to the new 2.0 API.

### Extraction Events

bplib can raise an event whenever your custom entity is extracted into a user blueprint, giving you a writable blueprint object to which you can store custom tags. First register your entity for extraction events:
```lua
-- data.lua
-- Add one entry like this for every entity you want to track
data.raw["mod-data"]["bplib"].data.extract_entity_names["your-entity"] = true
```

Then bind-to and handle these events in `control`:
```lua
-- control.lua
script.on_event("bplib-extract", function(event)
  for blueprint_index, entity in pairs(event.entities)
    -- The event is raised for all mods, so you must filter for your mod's entities
    if entity.name == "your_entity" then
      event.blueprint.set_blueprint_entity_tags(blueprint_index, { your = "tags here" })
    end
  end
end)
```

The event object has the following type:
```lua
---@class bplib.ExtractEvent
---@field name "bplib-extract"
---@field tick MapTick
---@field player_index uint32 Player who is extracting entities into a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that entities are being extracted into.
---@field entities {[uint32]: LuaEntity} Map from blueprint entity indices to world entities that were extracted into the blueprint.
```

### Positions Events

bplib can raise an event whenever a player pre-builds a blueprint involving your custom entities. This event will tell you where in the world your custom entities will be built when the subsequent `on_build` events fire.

Register:
```lua
-- data.lua
-- Add one entry like this for every entity you want to track
data.raw["mod-data"]["bplib"].data.position_entity_names["your-entity"] = true
```

Handle:
```lua
-- control.lua
script.on_event("bplib-positions", function(event)
  for blueprint_index, pos in pairs(event.positions)
    -- The event is raised for all mods, so you must filter for your mod's entities
    if entity.name == "your_entity" then
      -- `pos` is where your entity will be built in the world.
    end
  end
end)
```

Event type:
```lua
---@class bplib.PositionsEvent
---@field name "bplib-positions"
---@field tick MapTick
---@field player_index uint32 Player who is applying a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that is being applied.
---@field bbox BoundingBox The bounding box of the area where the blueprint is being applied.
---@field positions {[uint32]: MapPosition} Map from blueprint entity indices to world positions where those entities will be placed.
---@field orientation_info {position: MapPosition, direction: defines.direction, flip_horizontal?: boolean, flip_vertical?: boolean} Information about how the blueprint was oriented when placed
---@field surface_index The surface where the blueprint was placed.
---@field cause any The Factorio event that caused this bplib event.
```

### Overlap Events

bplib can raise an event whenever a player pre-builds a blueprint where an entity in that blueprint would overlap with an entity with the same name (or ghost thereof) that already exists in the world. This can be used to correctly transfer custom entity settings onto the pre-existing entity.

Register:
```lua
-- data.lua
-- Add one entry like this for every entity you want to track
data.raw["mod-data"]["bplib"].data.overlap_entity_names["your-entity"] = true
```

Handle:
```lua
-- control.lua
script.on_event("bplib-overlaps", function(event)
  for blueprint_index, overlapped_entity in pairs(event.overlaps)
    -- The event is raised for all mods, so you must filter for your mod's entities
    if overlapped_entity.name == "your_entity" then
      local settings = event.blueprint.get_blueprint_entity_tags(blueprint_index)
      -- Apply your mod's logic here...
    end
  end
end)
```

Event type:
```lua
---@class bplib.OverlapsEvent
---@field name "bplib-overlaps"
---@field tick MapTick
---@field player_index uint32 Player who is applying a blueprint.
---@field blueprint LuaItemStack|LuaRecord The blueprint that is being applied.
---@field bbox BoundingBox The bounding box of the area where the blueprint is being applied.
---@field positions {[uint32]: MapPosition} Map from blueprint entity indices to world positions where those entities will be placed. This contains all positions that were calculated by bplib, regardless of overlap.
---@field overlaps {[uint32]: LuaEntity} Map from blueprint entity indices to world entities that overlap with those blueprint entities. This contains only overlaps.
---@field orientation_info {position: MapPosition, direction: defines.direction, flip_horizontal?: boolean, flip_vertical?: boolean} Information about how the blueprint was oriented when placed
---@field surface_index The surface where the blueprint was placed.
---@field cause any The Factorio event that caused this bplib event.
```

## Dynamic Registration

bplib's remote interface can be used to dynamically register entity names for events during the control phase. **Unless you have a clear-cut dynamic use case, you should use mod_data. If used, these must be treated like dynamic event bindings (you must properly restore them in `on_load`, etc.) or you will cause desyncs.**

```lua
-- Register an entity for extraction
remote.call("bplib", "register_extract_entity", "my-entity-name")
-- Register an entity for position events
remote.call("bplib", "register_position_entity", "my-entity-name")
-- Register an entity for overlap events
remote.call("bplib", "register_overlap_entity", "my-entity-name")
```

## Universal mode

Using the remote interface, it is possible to ask bplib to *always* calculate blueprint geometry, ignoring individual entity registration. This will cause the `bplib-positions` event to fire whenever any blueprint is built, and all entities to be listed in the `positions` field of the event.

**WARNING: Using this mode will cause high CPU usage and lag when deploying large blueprints, drag-building blueprints, and in multiplayer. You have been warned!**

```lua
-- Force bplib to always compute entity positions.
remote.call("bplib", "always_compute_positions")
```

## Contributing

Please use the [GitHub repository](https://github.com/project-cybersyn/bplib) for questions, bug reports, or pull requests.
