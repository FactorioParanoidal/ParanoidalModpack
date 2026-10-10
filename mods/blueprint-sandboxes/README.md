# Blueprint Sandboxes

Temporary Editor-lite permissions in Lab-like environments for designing and experimenting.

Inspired by previous mods such as [Edit-Blueprints](https://mods.factorio.com/mod/Edit-Blueprints) and [Blueprint Designer Lab](https://mods.factorio.com/mod/BlueprintLab_design), [this mod](https://mods.factorio.com/mod/blueprint-sandboxes) aims to handle the situations where you want to design or tweak some Blueprints in a God-mode-like way, but without saving your active game, loading a different sandbox game, then leaving that to go back to the original once done.

To that end, it supports personal and team Sandbox Surfaces which enable: God-mode, extra Recipes (and Technologies if you wish), and automated construction. Getting in and out of Sandboxes is immediate and toggle-able via shortcuts (defaults to Shift+B).

To teach you the basics and provide many more details, the in-game Tips-and-Tricks are used; the first is visible after a few seconds, and the rest after you start using the Sandbox. The rest of this is considered a non-exhaustive summary - if you want to know more, see those Tips/Tricks!

* Multiple Sandboxes: your own and one for your force/team.
* Blueprint Input/Output: Copy/Paste, Blueprint Library, and in-Cursor.
* Item Input/Output: Infinity chests and loaders are available.
* God-mode: Fly around and construct/deconstruct much faster.
* Persistent Inventory: Your Inventory is saved and restored when exiting/entering.
* Automated Construction: Ghosts are automatically built for you.
* Surface Properties: Adjust gravity, pressure, etc. to mimic other Planets.
* All Recipes: If desired, use all Technology (instead of what you already know).
* Entity Generation: Place interesting entities like resources, trees, enemies, etc.
* Tile Placement: Place any kind of tiles wherever you want, or revert back to lab tiles.
* Default Equipment: You can decide what an empty Sandbox starts with.

# Isolation Levels

The Isolation Level setting controls how integrated the Sandboxes are with your game. There are important benefits and drawbacks to each.

- **Full** is the historical default, and aims to segregate the Sandboxes from the rest of the game as much as possible. This requires scripting to add back some helpful things that have been lost by this approach. The approach of using Forces and Controllers fundamentally affects what is and isn't possible with this setting.
- **None** is a newer setting made possible by the Remote View in 2.0, and it only aims to prevent blatant cheating in the Sandbox that could affect the rest of the game.

This is a summary of the important differences between the two:

| Scenario | Isolation: Full | Isolation: None |
| -------- | ---- | ---- |
| Safety | Various dangers | Entirely safe |
| Simplicity | Complex | Simple |
| Accessibility | Limitations | Always |
| Visibility | Personal / Force | Force |
| Remote Viewing | Not possible | Fully integrated |
| Technologies | Somewhat synced via Lua | Synchronized |
| Research | Disabled | Disabled |
| All-tech setting | Can be used | Cannot be used |
| Alerts | Separate | Synchronized |
| Chat | Forwarded via Lua | Synchronized |
| Character | Swapped to God-mode | Remains yours |
| Achievements | Can trigger | Will trigger |
| Milestones | Separate | Synchronized |
| Statistics | Separate | Included in Global |
| Logistics / Train Groups | Separate | Synchronized |
| Infinite Containers / Loaders | Only visible in Sandbox | Visible to all force members |
| Undo / Redo | Resets when entering/exiting | Works as expected |

## Details

- Research
  - **Isolation: Full**:
  Since the Sandbox uses a separate Force, it has an independent research tree. The overall tree and queue is synchronized via Lua, and you are prevented from making changes to the Sandbox's queue. Incremental progress is not synchronized. You may use the setting that unlocks all research while in the Sandbox. You cannot place research labs in Sandboxes.
  - **Isolation: None**:
  The tree and queue will always be exactly the same in and out of the Sandbox. You cannot place research labs in Sandboxes.

- Remote Viewing
  - **Isolation: Full**:
  Sandboxes cannot be viewed from outside of themselves, and nothing can be viewed while inside of a Sandbox.
  - **Isolation: None**:
  Viewing Sandboxes from outside of themselves is the primary method of "using" them, so they are fully integrated with the Remote View. This also means your teammates can see, view, and use each other's Sandboxes.

- Alerts
  - **Isolation: Full**:
  Alerts outside of the Sandbox cannot be seen while inside of the Sandbox, and vice-versa.
  - **Isolation: None**:
  Alerts are not affected: alerts in and out of the Sandbox are always visible.

- Chat
  - **Isolation: Full**:
  Lua is used to "forward" messages from outside and inside of the Sandbox to the relevant players.
  - **Isolation: None**:
  Chats are not affected: chats in and out of the Sandbox are always visible.

- Character -> God
  - **Isolation: Full**:
  Sandboxes can only be interacted with through this separate "controller" that gives you a larger inventory and more direct access to machines. It's not always possible to "safely" swap to this controller, so it's not always possible to enter the Sandbox. Your character is in danger of dying or being lost while in a Sandbox.
  - **Isolation: None**:
  The God controller is replaced with the Remote View, so it's always possible to see/use a Sandbox. You're never detached from your character, so it's extremely safe. You don't have an inventory, so you will always be using ghosts to imply interactions.

- Achievements / Milestones / Statistics
  - **Isolation: Full**:
  Achievements are per player or game, so it's possible to trigger achievements from the Sandbox. Milestones and Statistics are separated.
  - **Isolation: None**:
  Achievements and Milestones are linked. Statistics are always included when viewing them "globally."

- Infinite Containers / Loaders / Extensions
  - **Isolation: Full**:
  Only visible/usable while in the Sandbox.
  - **Isolation: None**:
  Visible to all players on the same force if any one of them is in the Sandbox, but they are not actually craftable.

- Logistics / Train Groups
  - **Isolation: Full**:
  These groups are separate and not synchronized.
  - **Isolation: None**:
  These groups are always the same inside and outside of Sandboxes.

- Undo / Redo
  - **Isolation: Full**:
  Entering and existing Sandboxes "resets" the queues, so you may not be able to undo things you've done before entering.
  - **Isolation: None**:
  You can undo / redo as you would expect.

# Known Issues / Frequently Asked Questions

### The Sandbox is not a Planet

Many Factorio 2.0 features, capabilities, definitions, mechanics, etc. are directly coupled to the concept of a Planet: a real, physical location that may be travelled to. Heating on Aquilo, lightning on Fulgora, and music are commonly known examples. Planets also carry other features that are not desirable for Sandboxes: appearing in all Planetary-selection menus, allowing travel with Platforms, and limiting recipes based on planetary conditions, to name a few. Lastly, Planets _must_ be known ahead of time, statically, while the game is loading its prototypes.

Sandboxes are meant to be quite different than that: ephemeral, dynamic, and personal. Each player has a Sandbox for themselves, and each Force/team does as well.

Sandboxes and Planets are not compatible. The only reasonable approach I can imagine right now is to have an additional, singular Planetary Sandbox that aims to generally set as many parameters as possible to be widely useful, and everyone would have access to it. This is totally fine for single-player, but it has very different implications for multi-player games.

### Music disappears while in Sandbox

This is an issue with Factorio's 2.0 music system (which only works for Planets and Platforms). See **The Sandbox is not a Planet**. There is a workaround that may solve this for you: there is a hidden setting in "the rest" (accessed by holding `ctrl` + `alt` while clicking "Settings" in the menu) called `ambient-music-based-on-physical-location`. If you cannot tell based on the name, this means that while you are in a Remote View (the default way of accessing the Sandbox), the music is still based on where your Character is. This naturally applies to the rest of the game as well, so it may not be to your taste.

### Cannot freeze due to cold, or place lightning collectors

This is again an issue with Factorio's 2.0 surface-specific settings (which only works for Planets and Platforms). See **The Sandbox is not a Planet**.

### Cannot Undo in (Real World/Sandbox) after coming from (Sandbox/Real World)

This is an issue with Factorio, and there's nothing this mod can do about it (while still being this mod).

### `on_pre_surface_cleared` in error message

When Resetting the Sandbox and the game crashes with any other mod listed in the error - it's _that_ mod's fault for not handling `on_pre_surface_cleared`.

### Crafting in Sandbox works towards Lazy Bastard

Crafting Counts cannot be segregated in the way that you want - this does not work for Lazy Bastard.

### Blueprint Library sourced Blueprints will not transfer via Cursor

Similar to above, another Factorio bug describes Blueprints in your cursor that are sourced from the Blueprint Library will be described as __not__ `valid_for_read`, thus accessing their contents is not possible, so this mod cannot transfer them into your Sandbox cursor because of that.

I have found at least three existing discussions on this topic, for reference:

* [How to access temporary BP in player's hand?](https://test.forums.factorio.com/viewtopic.php?t=93956)
* [Updated blueprint has no entities during on_player_setup_blueprint](https://forums.factorio.com/viewtopic.php?f=48&t=88100)
* [get blueprint-book from library link](https://test.forums.factorio.com/viewtopic.php?t=95272)

### Editor Extensions Lab Setting is incompatible

When Editor Extensions is enabled, its Lab Setting is disabled because it is incompatible with this mod.

## Credits
* undermark5: Factorissimo Performance Improvements
* KirillNaumkin and dodther: Russian translations