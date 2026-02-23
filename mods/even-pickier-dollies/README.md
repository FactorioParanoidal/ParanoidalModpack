# Even Pickier Dollies

This is a rewrite of the [Picker Dollies](https://github.com/Nexela/PickerDollies) mod by @nexela which has been modified to work with Factorio 2.0. Nexela did awesome work with this for Factorio 1.1. I will claim responsibility for all the bugs that this mod shows with Factorio 2.0.

Hover over entities and use the keybindings to move entities around. Entities will keep their wire connections and settings. This allows you to build your set up spaced out and when you are finished push it all together for a nice tight build. Some entities can't be shoved around. Also respects max wire distance.

*Note:* Moving some entities from mods can cause issues or strange visual artifacts. If you move a *modded* entity around and things behave weird (e.g. a piece of the entity is "left behind" or some effect remains at the original position), it is almost always because the mod uses some "hidden" additional entities. EPD knows nothing about those entities *and there is nothing that can be done in EPD!* EPD exposes an [API](https://github.com/hgschmie/factorio-even-pickier-dollies/blob/main/API.md) with can be used to receive events whenever an entity is moved and a mod author could use those to move these additional entities as well. Please raise an issue with the author of the mod, not with EPD.

EPD retains the `PickerDollies` API name to be compatible with all the other things out there that interface with it.

If you encounter other problems with this mod, please check out the [README](https://github.com/hgschmie/factorio-even-pickier-dollies/blob/main/README.md) and report them on the [Mod Discussion group](https://mods.factorio.com/mod/even-pickier-dollies/discussion) or on [github](https://github.com/hgschmie/factorio-even-pickier-dollies/issues).

[![Even Pickier Dollies in Action](https://raw.githubusercontent.com/hgschmie/factorio-even-pickier-dollies/refs/heads/main/.portal/even-pickier-dollies.gif)]

## Script support

Whenever an entity is moved successfully, the `script_raised_teleported` event is raised. This does *NOT* happen in 'transporter' mode as the entity is not teleported, but destroyed and recreated.

## API Support

Note: Moving some modded entities that rely on position can cause issues. There is an API available that mod authors can use to be notified of these events.

The [EPD API is documented here](https://github.com/hgschmie/factorio-even-pickier-dollies/blob/main/API.md).

## Noteworthy changes

### Release 2.4.0 and higher

Entities are no longer teleported into "safe positions" first. This makes a lot of the problems with 2.0 go away (and will make EPD much more usable in very tight spots or crowded situations such as space platforms).

### Release 2.5.0 and higher

EPD now offers a "transporter mode" that can be enabled in the startup settings. It allows certain entities (currently only belts and 1x1 loaders) to be moved even though these entities can not be teleported. This is done by creating a clone of the entity at the new position and destroying the original entity. This may cause problems in some scenarios or with some mods, so when in doubt, leave the startup setting off.

### Release 2.6.0 and higher

EPD can now move ghost entities around (they are still limited as regular entities as they can not overlap) if enabled through a new startup setting. Default is allowing to move ghosts around.

Ghosts do not collide with items on the ground (useful for Space platforms).

EPD can destroy items on the ground if the inventory (or space platform hub) are full and an entity is moved on top of items on the ground. This is controlled by a startup setting.

### Release 2.7.0 and higher

EPD restricts moving of entities to direct player interactions. Entities can no longer be moved in the remote view. There is a startup setting to restore that behavior and cheat mode will bypass this restriction.

## Legal

Copyright (C) 2024-2025 Henning Schmiedehausen (@hgschmie), licensed under the MIT License.

The original Picker Dollies is (C) @Nexela, licensed under the MIT License.
