![Demo](https://github.com/tburrows13/SpidertronPatrols/raw/master/resources/animated-docks-demo.mp4)

# Features

### Patrol Schedule

- Use the patrol remote to create a series of waypoints
- Open the inventory of a spidertron with waypoints to see the schedule editor

### Spidertron Docks

- Docks connect to a spidertron standing above them and share its inventory, so that inserters can interact with the spidertron
- Circuits wires can be connected to docks to allow its contents to be read

### Spiderling

- Spiderling is a slower, smaller and weaker spidertron unlocked by chemical (blue) science
- Added so that patrols and docks can be used before the spidertron is unlocked at the end of the game

-----
## Recommendations

- [Spidertron Enhancements](https://mods.factorio.com/mod/SpidertronEnhancements) is a required dependency which, amongst other features, allows you to open a spidertron's inventory (and patrol schedule) from anywhere whilst holding a connected remote by pressing `Shift + E`

-----
## Known Bugs / Limitations

- Each patrol waypoint can only have one wait condition set. If you need more, you can usually just set multiple waypoints in the same position, each with a different wait condition
- For performance reasons, when items with associated data (such as modular armor) in a spidertron inventory are taken out of a connected dock's inventory, they lose all their data. This loses all the equipment in that armor's equipment grid 
- Performance is good, but not insignificant:
    - Docks are limited so that only 20 are updated each tick. Adding lots of docks will simply increase the update delay for each dock instead of reducing UPS
    - Spidertrons waiting at waypoints also add to the mod update time
    - If you are running into performance problems, send me the save and I can probably make some improvements to the mod to help you
- Use `/reset-sp-render-objects` if render objects (numbers and lines on the ground) are behaving unexpectedly

-----
## Future Updates?

- Progress bars for wait conditions inside schedule user interface

-----
## Translation

You can help by translating this mod into your language using [CrowdIn](https://crowdin.com/project/factorio-mods-localization). Any translations made will be included in the next release.

-----

Replaces [Spidertron Waypoints](https://mods.factorio.com/mod/SpidertronWaypoints).
Allows creating patrols for [Lex's Aircraft](https://mods.factorio.com/mod/lex-aircraft), since those aircraft are spidertrons internally.
Fully compatible with Krastorio2, Space Exploration, and Nullius.

Thank you to:

- [danatron1](https://www.reddit.com/r/factorio/comments/iitlvi/i_made_a_mod_that_allows_you_to_set_waypoints/g3dzt1h) for creating the patrol remote icon
- [notnotmelon](https://mods.factorio.com/mod/spidertron-logistics) for some of the dock prototype code
- [raiguard](https://mods.factorio.com/mod/flib) for the GUI library and style tips
- kumpuu for adding the ability to show patrol paths in map view
