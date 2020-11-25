# Changelog

## 0.11.7 (2020-11-25)

### Bugfix

- Change status types to match the updated ones in core factorio by troelsbjerre

---

## 0.11.6 (2020-11-24)

### Bump

- Version number, to allow factorio 1.1.x experimental by troelsbjerre

---

## 0.11.5 (2020-10-28)

### Rollback

- Reintroduce signals to electric mining drill by troelsbjerre

---

## 0.11.4 (2020-06-30)

### Bugfixes

- Fix Japanese localization by shelaf
- Fix English localization by stefprez
- Remove signal from new electric mining drill by lstor

---

## 0.11.3 (2020-02-12)

### Features

- New default icons by [mybuddymichael](https://github.com/mybuddymichael)
- Danish localization
- Japanese localization by shelaf

### Performance

- Performance improvement: Use a truthy dictionary instead of iteration by [Nexela](https://github.com/Nexela)

---

## 0.11.2 (2020-01-26)

### Bugfixes

- Fix missing STYLE array on incomplete init by [Roang-zero1](https://github.com/Roang-zero1)

---

## 0.11.1 (2020-01-24)

### Bugfixes

- Fix crash on initial machine build by [Roang-zero1](https://github.com/Roang-zero1)

---

## 0.11.0 (2020-01-24)

### Features

- Use 0.17 API to request entity status by [Roang-zero1](https://github.com/Roang-zero1)
- Show rocket silo status by [Roang-zero1](https://github.com/Roang-zero1)
- New Icon options by [Roang-zero1](https://github.com/Roang-zero1)
- More customization options by [Roang-zero1](https://github.com/Roang-zero1)

### Bugfixes

- Fix status lamps for laboratories by [Roang-zero1](https://github.com/Roang-zero1)

---

## 0.10.5 (2020-01-24)

- Version bump to 0.18

---

## 0.10.0 (2019-02-26)

- Version bump to 0.17 (not using any of the new faster API... sorry)

---

## 0.9.3 (2018-10-19)

- Korean localization} by MasterBabol

---

## 0.9.2 (2018-10-17)

- Japanese localization by shelaf

---

## 0.9.1 (2017-12-22)

### Bugfixes

- Fixed bug introduced by 0.16 causing fluids not to be checked correctly by ochristi)

### Other

- German localization by ST-DDT

---

## 0.9.0 (2017-12-15)

### Bugfixes

- 0.16 compatibility fix by ochristi

### Other

- Changed logic for state tracking, to avoid light flickering (some machines would show as yellow for a tick per cycle, even when working 100%)

---

## 0.8.5 (2017-06-05)

### Bugfixes

- Fixed lights on uranium miners without mining fluid

---

## 0.8.4 (2017-06-01)

- Initialize STYLE from settings

---

## 0.8.3 (2017-05-30)

### Bugfixes

- Fixed hotkey and interface issue

---

## 0.8.2 (2017-05-29)

### Bugfixes

- Quick fix to remove spam messages

---

## 0.8.1 (2017-05-29)

- Reintroduced the hotkey: SHIFT+ALT_L

---

## 0.8.0 (2017-05-28)

- Fully configurable lights

---

## 0.7.3 (2017-05-27)

- Bugfixes

---

## 0.7.2 (2017-05-22)

- Bugfixes

---

## 0.7.1 (2017-05-10)

- Cached options values (turns out fetching them all the time is quite slow)
- Updated sprite indices for 0.15.10

---

## 0.7.0 (2017-05-05)

- Added options menu (Menu->Options->Mods->Map)

---

## 0.6.3 (2017-04-28)

- Updated for Factorio 0.15

---

## 0.6.2 (2017-01-13)

### Bugfixes

- Collision mask added, so you can again walk through the indicator lights
- Switching to high contrast mode was broken by 0.6.1, which is now working again

---

## 0.6.1 (2017-01-12)

### Bugfixes

- Using car as base type had unintended consequences, so now using storage-tank instead.

---

## 0.6.0 (2017-01-11)

### Optimizations

- change
- by

---

## 0.5.2 (2017-01-03)

### Bugfixes

- Rolled back a rebuild optimization, which used too much ram.

---

## 0.5.1 (2017-01-02)

- Code Restructure for 0 error/warns in linter. by Nexela (Nicholas Dunn)
- Several speedups. by Nexela (Nicholas Dunn)
- Ton of bug fixes and robustness improvements (incl. fixing desync issues). by Nexela (Nicholas Dunn)
- Add Remote interface. by Nexela (Nicholas Dunn)
- Custom events for hotkeys.. by Nexela (Nicholas Dunn)

---

## 0.5.0 (2016-12-17)

- Changed data structure from list to table, to allow for the following:
- Removed entities now have their associated lights disappear instantly, instead at next update.
- Mod now scales to larger factories, since removing elements (either from mining or destruction) is now expected constant time instead of linear in the number of lights.

---

## 0.4.5 (2016-12-04)

- Fixed unhelpful options menu text

---

## 0.4.4 (2016-12-04)

- High contrast mode replaces the yellow signal with a blue signal. SHIFT-B to toggle

---

## 0.4.3 (2016-10-03)

### Bugfixes

- 0.4.0 introduced caching of whether a mining drill was depleted, which was mistakenly also set if the drill was out of power.

---

## 0.4.2 (2016-10-02)

### Bugfixes

- re-introduced minor version numbers on global data. The use of function pointers inside global cause the function to be saved as well. This needs to be updated when loading a newer version of the mod, which includes minor versions.

---

## 0.4.1 (2016-10-02)

### Optimizations

- Only checking for fluid output as a last resort (speeds update up quite a bit)
- Clean transition from 'removing lights a few at a time' to 'all lights are off, so no need to check'.

---

## 0.4.0 (2016-10-01)

### Bugfixes

- Assemblers with fluid output now handled more consistently with the rest.
- Depletion of mines fixed (now explicitly searching for ore patches, since old method sometimes failed)

### Other

- Toggling the indicators now requires admin privileges, and toggling lights will now happen at the same rate as updates, instead of all in one tick

---

## 0.3.3 (2016-09-26)

### Bugfixes

- Compatibility issue with unDecorator resolved

---

## 0.3.2 (2016-08-30)

### Bugfixes

- Added sanity checks, in case signal entities have been destroyed by other mods

---

## 0.3.1 (2016-08-30)

### Bugfixes

- New fantories would get a red light (but not update) if lights were turned off

---

## 0.3.0 (2016-08-29)

### Bugfixes

- Version number was not updated, which caused the position cache to not be filled, causing a crash

### Optimizations

- No longer repeatedly checking status when lights are toggled off by bsdfhsbzxcbz

---

## 0.2.5 (2016-08-28)

### Optimizations

- Caching of light position (slightly lower CPU load)

### Other

- Confirmed working for 0.14, so updated info.json

---

## 0.2.4 (2016-08-23)

### Bugfixes

- Fixed crash which could occur when removing the last assembler

---

## 0.2.3 (2016-08-22)

### Bugfixes

- Fixed issue with entity being updated multiple times per tick, incorrectly giving drills the yellow status

---

## 0.2.2 (2016-08-22)

### Bugfixes

- Places the signals at the bottom center of oddly sized entities by apriori

### Other

- Hotkey 'B' for hiding signals by apriori

---

## 0.2.1 (2016-08-14)

### Bugfixes

- Correctly handling machines idling while trying to output a bonus item by randomflyingtaco

---

## 0.2.0 (2016-08-13)

### Features

- Mining drills and pump jacks now also have indicator lights
- Only updates 40 entities per tick, as suggested by github user zamp
- Much more consistent use of red/yellow/green across different entity types
- Major refactoring to handle save and load properly

---

## 0.1.0 (2016-07-16)

- Major refactoring to handle save and load properly

---

## 0.0.3 (2016-06-14)

### Features

- Furnaces now also have indicator lights

---

## 0.0.2 (2016-06-14)

### Features

- Slightly improved graphics (inspired by sporefreak)
- Red light stays on for 5 seconds, to improve visibility (as suggested by Miravlix)

### Bugfixes

- Machines places by robots now also get an indicator
- Old indicator lights are filtered out at load (this is a hack; the mapping should be stored in global)
- New entities are now only created when state changes.

---

## 0.0.1 (2016-06-11)

- Proof of concept.
