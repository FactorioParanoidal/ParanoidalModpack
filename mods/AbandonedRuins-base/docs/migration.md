# Migrating your mod from 1.2.0 to latest

## 1.3.2

1.3.0 was the first merged version and it wasn't really stable. But it has introduced a lot of changes to the configuration keys and the way you can expand any existing ruin-set (e.g. "base")

1.3.2 has added a new remote-call function called "register_ruin_set" which can be found in this mod's control.lua file.

Previous code: (perhaps in `settings.lua`?)
```
table.insert(data.raw["string-setting"]["AbandonedRuins-set"].allowed_values, "YourRuinsMod")
data.raw["string-setting"]["AbandonedRuins-set"].default_value = "YourRuinsMod"
```
New code: (in `control.lua`)
```
local function make_ruin_set()
    remote.call("AbandonedRuins", "register_ruin_set", "FortressRuins", true)
    -- DO MORE STUFF HERE
end

script.on_init(make_ruin_set)
script.on_configuration_changed(make_ruin_set)
```
No need to worry about changes settings keys.

If your mod is based on e.g. `base` ruin-set (a playable example mod) then you need to do this now: (`control.lua`)
```
-- This goes into the header of control.lua
local ruin_set = require("ruins/ruin_set")

local function make_ruin_set()
  -- If your ruin set mod expands an other ruin set:
  local new_ruins = remote.call("AbandonedRuins", "get_ruin_set", "base")

  -- Add custom base ruins to existing ruins.
  for size, ruins in pairs(ruin_set) do
    for _, ruin in pairs(ruins) do
      table.insert(new_ruins[size], ruin)
    end
  end

  -- Provide an expanded and modified set of ruins as a “base” set. Or choose your ruin-set name here, e.g. "krastorio2"
  remote.call("AbandonedRuins", "add_ruin_sets", "base", new_ruins)
end
```
Please refer (you will find it commented out) to the mod `AbandonedRuins-base` for details (`control.lua` mostly). There is also an example on how to change entities into others.
