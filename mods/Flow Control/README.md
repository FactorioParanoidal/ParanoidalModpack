# Flow Control

This mod has two main features: specific rotatable pipe sections and valves.

## Specific Rotatable Pipe Sections

Using these three new pipe sections you can build almost any pipe layout without worrying about unwanted connections. Each pipe is crafted from one normal pipe, and when mined drops a normal pipe.

- **Elbow**
- **T-Junction**
- **Straight**

![Imgur](https://i.imgur.com/B50vSJ1.png)

## Cursor shape cycle (Paranoidal, Factorio 2.1)

Hold an ordinary pipe and press **Rotate** (normally **R**): ordinary pipe → four elbow orientations → four T-junction orientations → two straight orientations → ordinary pipe. **Reverse rotate** walks the same cycle backwards. Rotation of unrelated items is unchanged.

No separate crafting is required. The held stack is converted 1:1, retaining its material and quality. Supported pipes have the usual four surface connections, including Bob's and Bio Industries pipes. Underground pipes and special-connection pipes are not included. The existing public iron-pipe fittings and their recipes remain compatible with old saves and blueprints.

Clearing the cursor returns its remaining fittings to the original pipe before the game's clear action. Cursor fittings transferred into the player's or an opened entity's inventories, or dropped on the ground, are likewise returned to the original pipe. There are no disposable cursor tools or hidden reserves of real items. Construction robots build fitting ghosts using the original pipe. When a held stack runs out, the next stack of the same source pipe and quality is selected if available.

The implementation reacts to input, cursor, inventory and build events; it does not scan the map or run an on-tick loop. The engine supplies the actual placement rotation and preview. This interaction still requires in-game acceptance on the target engine; static tests do not verify the native input ordering or visuals.

## Valves

Valves have been moved to the optional [Valves](https://mods.factorio.com/mod/valves) mod.

## Settings

- **New subgroup for pipe items** (enabled by default): Moves pipes, pumps and valves to a new line in the crafting menu
- **Picked up pipes become base pipes** (enabled by default): When picking up T-Junction, elbow or straight pipes, it reverts back to normal pipes.

## Recommended mods
- [Flow Control for Bob's Logistics](https://mods.factorio.com/mod/flow-control-expanded-bob) | Compatibility mod to add flow control to Bob's pipes and merge valves.
- [Fluid Must Flow](https://mods.factorio.com/mod/FluidMustFlow) | Adds larger pipes and valves.

## Credits
- GotLag
- snouz (new graphics and details)
- stringweasel
