## Blueprint Sandboxes

Temporary Editor-lite permissions in Lab-like environments for designing and experimenting.

Inspired by previous mods such as [Edit-Blueprints](https://mods.factorio.com/mod/Edit-Blueprints) and [Blueprint Designer Lab](https://mods.factorio.com/mod/BlueprintLab_design), [this mod](https://mods.factorio.com/mod/blueprint-sandboxes) aims to handle the situations where you want to design or tweak some Blueprints in a God-mode-like way, but without saving your active game, loading a different sandbox game, then leaving that to go back to the original once done.

To that end, it supports personal and team Sandbox Surfaces which enable: God-mode, extra Recipes (and Technologies if you wish), and automated construction. Getting in and out of Sandboxes is immediate and toggle-able via shortcuts (defaults to Shift+B).

To teach you the basics and provide many more details, the in-game Tips-and-Tricks are used; the first is visible after a few seconds, and the rest after you start using the Sandbox. The rest of this is considered a non-exhaustive summary - if you want to know more, see those Tips/Tricks!

* Multiple Sandboxes: your own and one for your force/team. If you're using Space Exploration, there's also Planetary and Orbital Sandboxes.
* Blueprint Intput/Output: Copy/Paste, Blueprint Library, and in-Cursor.
* Item Input/Output: Infinity chests and loaders are available.
* God-mode: Fly around and construct/deconstruct much faster.
* Persistent Inventory: Your Inventory is saved and restored when exiting/entering.
* Automated Construction: Ghosts are automatically built for you.
* All Recipes: If desired, use all Technology (instead of what you already know).
* Resource Generation: Draw then use any kind of Resource Patch.
* Water placement: Place water, so you can then landfill it (or not).
* Default Equipment: You can decide what an empty Sandbox starts with.

# FAQ

* Pollution counts towards Evolution.
* Production Statistics cannot be segregated.
* Crafting Counts cannot be segregated - this does not work for Lazy Bastard.
* You can die in the real world while in a Sandbox.
* When Resetting the Sandbox and the game crashes with any other mod listed in the error - it's _that_ mod's fault for not handling `on_pre_surface_cleared`.

# Known Issues

### Cannot Undo in (Real World/Sandbox) after coming from (Sandbox/Real World)

This is an issue with Factorio, and there's nothing this mod can do about it (while still being this mod).

### Space Exploration Sandboxes report incorrect Daylight on their first use

This also seems to be an issue with Factorio. Although the Daylight property is forcefully set and told to not change, the next read of the value will be zero (or perhaps what the value originally was). It's purely a cosmetic bug.

### Space Exploration sometimes blocks placements due to Zone/Force issues

In its original form, this mod had great compatibility with Space Exploration - from this mod's POV. From SE's POV, however, at least two things were bad. First, it's technically possible to cheat (well, it _always_ is, since you're in control of the games you play), even though this mod discourages it and aims to prevent it. Second, SE's handling of Forces had some assumptions that were not true when using this mod. As such, there were a few bugs, like having twice as many CMEs as normal.

Recently, SE became "aware" of this mod and have made changes to _prevent_ placement of some important SE Entities. Around the same time, this mod introduced "Illusions" to safely swap out scripted Entities with basic placeholders.

At this time, _most_ of those Entities cannot _normally_ be placed within the Sandboxes - you will get an error from SE instead. They _can_ be Ghost-built (holding shift, or using a Blueprint), in _most_ cases. This is because SE does not check the types of the Ghosts, and this mod can safely replace them with Illusions. For the real Entities, SE blocks the placement _before_ this mod can do anything about it.

I've reached out to their team to improve the compatibility, but nothing came of it.

### Selecting new contents for some Blueprints will include Illusions instead of Real Entities

There is a significant flaw in Factorio's handling of Blueprints that have already been created when you want to "select new contents" for them; to quote a Factorio dev, it's "kind of a giant hack in my opinion and I don't see it getting re-worked any time soon." This is the only real acknowledgement of this issue, whereas all other responses seem to deflect or feign ignorance. As far as I have found, this is the only (and for our purposes, quite a large) shortcoming of the otherwise excellent Modding API.

In short, this mod has _no_ access or capability to adjust a Blueprint when you are "selecting new contents." This capability is necessary to swap our Fake Illusions (script-less Entities that replace other, more complicated ones for various reasons) with their Real Counterparts. This cannot be overcome without Factorio itself being fixed by the development team. That said, there is _potentially_ a hackish and unnecessary workaround when you do this to a Blueprint in your Inventory.

I have found at least three existing discussions on this topic, for reference:

* [New contents for blueprint broken vs. new blueprint](https://forums.factorio.com/viewtopic.php?f=29&t=88793)
* [Blueprints missing entity list when reused](https://forums.factorio.com/viewtopic.php?f=7&t=99323)
* [Updated blueprint has no entities during on_player_setup_blueprint](https://forums.factorio.com/viewtopic.php?f=48&t=88100)

### Blueprint Library sourced Blueprints will not transfer via Cursor

Similar to above, another Factorio bug describes Blueprints in your cursor that are sourced from the Blueprint Library will be described as __not__ `valid_for_read`, thus accessing their contents is not possible, so this mod cannot transfer them into your Sandbox cursor because of that.

I have found at least three existing discussions on this topic, for reference:

* [How to access temporary BP in player's hand?](https://test.forums.factorio.com/viewtopic.php?t=93956)
* [Updated blueprint has no entities during on_player_setup_blueprint](https://forums.factorio.com/viewtopic.php?f=48&t=88100)
* [get blueprint-book from library link](https://test.forums.factorio.com/viewtopic.php?t=95272)

## Credits
* undermark5: Factorissimo Performance Improvements
