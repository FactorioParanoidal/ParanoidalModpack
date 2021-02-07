# Ruin sets

Other mods can add their own ruin sets to *The Ruins Mod*.

Typically, a ruin set is added in two steps:
* Modify the "AbandonedRuins-set" string-setting in the settings stage to add the name of the ruin set.
* Add the own ruin set in control.lua via the remote interface.

An "real-life" example for adding a ruin set with another mod can be found at [The Ruins Mod - Krastorio2](https://github.com/Bilka2/AbandonedRuins-Krastorio2).

## Step 1: Ruin set setting

The settings should be modified in settings.lua. Make sure to set "AbandonedRuins >= 1.0.0" (this mod) as a dependency.

Add a ruin set name to the setting:
```lua
table.insert(data.raw["string-setting"]["AbandonedRuins-set"].allowed_values, "my-ruin-set")
```
Optional: Set the just added ruin set to be selected by default.
```lua
data.raw["string-setting"]["AbandonedRuins-set"].default_value = "my-ruin-set"
```

## Step 2: Ruin set remote interface

Adding a ruin set is a simple as providing the ruins to *The Ruins Mod* via the add_ruin_set remote call in on_init and on_load in control.lua. For the format of ruins, see [ruin data format](docs/format.md).

Some extra care needs to be taken with ruin sets, as they are not save/loaded. That means they should not be changed during the game.<br>
For that reason, it is recommended to only add ruin sets in on_init and on_load. Furthermore, it is recommended to not conditionally change ruin sets.

```lua
local small_ruins = require("ruins/small") -- an array of ruins
local medium_ruins = require("ruins/medium") -- an array of ruins
local large_ruins = require("ruins/large") -- an array of ruins

local function make_ruin_set()
  remote.call("AbandonedRuins", "add_ruin_set", "my-ruin-set", small_ruins, medium_ruins, large_ruins)
end

-- The ruin set is always created when the game is loaded, since the ruin sets are not save/loaded by AbandonedRuins.
-- Since this is using on_load, we must be sure that it always produces the same result for everyone.
script.on_init(make_ruin_set)
script.on_load(make_ruin_set)
```
