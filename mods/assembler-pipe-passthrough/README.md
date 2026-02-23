# Assembler Pipe Passthrough

This repository houses the [Assembler Pipe Passthrough](https://mods.factorio.com/mod/assembler-pipe-passthrough) mod for the game [Factorio](https://factorio.com)

## Mod Description

Adds more pipe connections to allow assemblers (chem plants, refineries, pumpjacks and modded miners (all toggled by settings)) to pass through fluids.

## Help Wanted
Translators needed: if you can translate the locale strings into your native language, please let me know, or submit a pull request on github.

## Major Changes

Version: 2022.02.05
Date: 2022.02.05
Changes:
- Overhauled fluidbox processing methods; should now be compatible with all mods natively.
- Removed compatibility requirements for existing integrations
- THIS WILL BREAK EXISTING SAVES

Because of the mod-breaking update in 0.17.63, the mod no longer allows for the multi-pipe setting.
Instead - all INPUT fluidboxes are on the North/South plane and all OUTPUT fluidboxes are on the East/West plane.
Oil Refineries and Chemical plants are now affected by this mod.

## Known issues

Pipe direction indicators don't point in both directions. Fluid will still flow from one assembler to the other, even though it might not look like it will.

There is some funky graphical glitch when there are lots of Bob's assemblers on screen, occasionally the pipe-cover graphics do not display properly.

There are some graphical glitches with oil refineries and chemical plants, as fluid boxes on the corners of these machines overlap their alt-mode display. If you are having trouble telling which fluid is coming out where, place a pipe next to the output.

Don't add this mod mid-game unless you are prepared to fix all broken fluid setups.
