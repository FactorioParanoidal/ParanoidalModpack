# Bulk Rail Loaders

This mod adds dedicated train loaders and unloaders for granular bulk cargo,
as often used in reality at mines, power stations, etc.  A large hopper placed
directly over the track drops granular solids into the top of a hopper car,
and at the destination the bottom of the car is opened and the cargo pours out
through metal grates and onto conveyors.

Loaders benefit from inserter stack size bonus.  When fully researched they will
fill or empty a cargo wagon in about 5 seconds.

![Bulk Rail Loaders in action](https://github.com/mspielberg/factorio-railloader/raw/master/resources/snapshot.jpg)

The Bulk Rail Loader and Unloader items will show a preview of the loader and
an image of a cargo wagon, to help position the loader correctly. The
concrete pad of the Bulk Rail Unloader serves a similar purpose.

Note that rails are placed every other tile, but cargo wagons in stations
stop every 7 tiles. Depending on the exact loader placement, it may appear
with two or three rail segments underneath. You cannot place a BRL if it
could not align with other rails.

BRLs are circuit-connectable chest entities that output their content. You
can connect them to Logistic Train Network stops to manage automatic creation
of transport orders. Sending a BRL the special "Disable rail loader" signal
will stop the BRL from loading/unloading a cargo wagon. Due to their speed,
you are likely to load or unload a few more items than expected.

## Boosting Throughput with Interface Chests

Rail loaders and unloaders can fit 4 inserters or loaders on each side, for
an inherent 8 belts of throughput. If this is insufficient, you can add up to
4 chests to the corners of the loaders, and they will automatically push or
pull items into these chests. I recommend limiting these chests to just a few
stacks to prevent them from getting too out of balance.

With vanilla 1x1 chests, this system allows up to 12 belts of throughput, 6
per side. However, chests can be of any size. Interface chests can also be
logistics chests, if you wish to directly connect your bulk rail loaders to
your logistics network.

![Interface Chest Demo](https://github.com/mspielberg/factorio-railloader/raw/master/resources/interfacechests.jpg)

## What items are supported?

Anything that would tolerate a long drop onto the hard metal floor of a cargo
wagon, then would fit through a metal grate, and would survive a trip up a
[screw conveyor](https://en.wikipedia.org/wiki/Screw_conveyor).

By default, this does not include plates, but a setting is available to enable
them if you wish to abandon realism. You can even enable Bulk Rail Loaders to
handle any item at all.

From base:

* Coal, stone, copper ore, iron ore, uranium ore
* Landfill
* Plastic (realistically these are likely pellets, not shaped bars)
* Sulfur

From mods:

* Items named "ore", "powder", "sand", "gravel", etc.

The following mods and mod sets have specific additional support:

* Angel's Mods
* Bob's Mods
* Krastorio
* MadClown's Extended AngelBob Minerals
* Py's Mods (pycoalprocessing, pyrawores)
* Xander-Mod

Mod authors can add their own items or classes of items to be handled
by Bulk Rail Loaders using the remote interface:

```lua
-- call either of these during your mod's on_init and on_load event handlers
-- takes the exact name of an item
remote.call("railloader", "add_bulk_item", item_name)
-- takes a Lua pattern (https://www.lua.org/manual/5.2/manual.html#6.4.1)
remote.call("railloader", "add_bulk_item_pattern", lua_pattern)
```

If you feel something that meets the above generic description is not
included, let me know.  You can also edit `bulk.lua` if you would like
to change the set of supported items for your own use, or change the
mod setting to allow any item.

## Acknowledgements

* Arch666Angel for the loader graphics.
