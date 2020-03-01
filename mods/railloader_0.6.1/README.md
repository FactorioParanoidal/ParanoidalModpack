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

This mod should be considered __ALPHA__ quality.  Expect bugs, and please report
any you find to the mod thread.

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

From Bob's mods:

* All ores, including quartz
* Solid chemical intermediates (salt, lithium chloride, etc.)

From Angel's mods:

* All 6 primary ores from Angel's Refining, including refined variants up to
  purified crystals
* Geodes, crushed stone and slag waste products from Angel's Refining
* Processed ores from Angel's Smelting
* Solid chemical intermediates from Angel's Petrochem

From MadClown's Extended AngelBob Minerals:

* Additional ores and refined variants

From Omnimatter:

* Omnite ore

From Pyanodon's mods:

* A huge variety of organics, stone, and chemical intermediates from Pyanodons
  Coal Processing
* Raw and processed ores from Pyanodons Raw Ores

If you feel something that meets the above generic description is not included,
let me know.  You can also edit `bulk.lua` if you would like to change the set
of supported items for your own use.

## Acknowledgements

* Arch666Angel for the loader graphics.
