# Subterranean — Paranoidal Beta 8 port

Maintained Factorio 2.0 port of the **Paranoidal Beta 8 variant of Subterranean 0.5.3**, originally by Gangsir, Bilka and RealVictorPRM. This is not an unmodified upstream release or a general-purpose vanilla port.

## Preserved behavior

- Three underground belts and one underground pipe with a prototype range of 250.
- Beta 8 recipe quantities, two endpoints per craft, crafting time, research prices and final Angel/Bob prerequisites.
- Original item/technology icons and RU/EN localization; native 2.0 entity graphics with the original tints.
- Normal manual/robot construction and mining. **No distance-dependent charge or refund handlers.** Paranoidal already commented out all of `control.lua` and `settings.lua` in Beta 8 (robot-building change: `c324cca5525ae06284f91d4e0080cad26cd813e1`). Those inactive files are not resurrected.
- Bob copper-tungsten underground pipes regain the active 250-range compatibility effect; plastic underground pipes regain their Beta 8 range of 100.

## Compatibility boundaries

- Recipe IDs retain their names; steel/titanium gears and steel pipes use Bob 2.0's `bob-` IDs.
- The pipe item uses the current `bob-pipe-to-ground` subgroup.
- The old green/purple underground belt patches did not match any entities in the final Beta 8 dump, so ordinary Bob belts are not extended.
- The removed Bob nitinol pipe is not reintroduced or replaced by another material.
- While Subterranean is enabled, Paranoidal's late pipe-distance integration preserves its 100-range plastic pipe. Without Subterranean the existing 21-range rule is unchanged.
- New games are the acceptance scope. No migration of Factorio 1.1 saves is promised.

`zzzparanoidal` has an optional dependency on this fork so its late integration and restacking see the new prototypes. Enabling the mod in a user's profile is separate from copying this source tree; the port does not edit `mod-list.json`.

## Provenance and maintenance

`provenance.json` records hashes of every supplied Beta 8 source file. This is a maintained Paranoidal fork, not a temporary patch to an installed portal archive. Original attribution and the upstream forum link are retained. No separate license file was supplied in Beta 8; external redistribution/publication requires checking the upstream licensing first. No upstream report or publication has been made.
