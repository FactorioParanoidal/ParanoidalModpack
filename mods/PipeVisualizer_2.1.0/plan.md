# Goal

Visualize pipe connections with lines and arrows, and visualize "complex"
(non-pipe) entities with colored boxes.

# Constraints

- Minimal UPS impact
  - Spread visualization over multiple ticks
  - Scale rate of visualization by number of active visualizations
  - Minimize creation and destruction of LuaRendering objects
- Update in real-time as entities are modified
  - Fluid system IDs will need to be migrated
  - This might need to be done over multiple ticks as well - consider simply removing and re-iterating the affected systems
- Two visualization modes
  - System: Given a starting entity, walk the fluid system and visualize each entity's connections to this system.
  - Overlay: Visualize all systems on all visible entities.

# Definitions

- **Simple entity:** Entity of type `pipe`, `pipe-to-ground`, or `infinity-pipe`.
- **Complex entity:** All other entity types.

# Visualzation

## Simple entities

Simple entities are visualized with a sprite representing the entity's
connections. This sprite is determined by binary encoding the directions of
that entity's connection. The color is simply the fluid system's assigned
color.

## Complex entities

Complex entities are visualized with a translucent box matched to their
bounding box.

Box color depends on the current color setting:
- By fluid: Fluid prototype order (lower is better)
- By system: Generated color index (lower is better)

We are unable to style the entity boxes well because LuaRendering cannot scale
sprites like GUI styles can. Potential solution would be to add this draw mode
to LuaRendering.

## Connection arrows

Connection arrows represent the `flow_direction` for a given connection. They
are drawn for every connection on complex entities, and non-I/O connections for
simple entities. The arrow is positioned halfway between the `position` and
`target_position` for the connection.

## Underground connections

Underground connections are visualized by drawing a dashed line between the two
entities. Because the PipeConnection does not contain the target owner's
connection position, the engine will need to assemble the entity data for the
target owner before the visualization can occur.

There are several potential options for doing this:
- Create N sprites for N tiles between the entities (current method, slow!)
- Determine max possible underground connection length in data-final-fixes and create sprites for each length (best non-c++ solution, could be slow with certain modpacks)
- Create separate sprites for connection lengths up to an arbitrary constant (say, 100) and ignore ones longer than that (easiest, fastest, but could be bad in certain mods)
- Add sprite tiling support to LuaRendering (hardest, best solution)

# Iteration

Entities are iterated over time to eliminate long hangs. The rate of
visualization will be scaled based on the number of players currently
visualizing.

## Specific fluid system

Pressing `H` on a fluid-connectable entity will visualize all of the entities
in that fluid system.

```
if mode is overlay then return
for neighbour in entity
  push entity to queue for iteration
```

## Overlay

Pressing `Shift + H` will visualize all of the entities visible to the player
at max zoom level. As the player moves, entities are searched and added to the
queue to be visualized.

# Rendering architecture

`Renderer` module contains methods for drawing all of the requisite components:
- Simple entity connection lines
- Complex entity box
- Connection arrows
- Underground connection dashes
- Update color of primary entity object and/or a fluid system's connection objects

LuaRendering performance is at its worst when creating and destroying objects.
To migitate this, create a shared cache of render objects and re-use as many as
possible. Cache can be implemented as a queue for O(1) appending and removing.

All required render objects are sprites, so it should be unnecessary to store
the object's type.
