`modloader` is a wrapper to allow running a mostly-unmodified `control.lua` from a mod as an `event_handler` library inside `level`. Examples taken from [Nixie Tubes](https://mods.factorio.com/mod/nixie-tubes).

Add the following to the top of the mod's main `control.lua` to prevent double-loading the mod while building saves for simulations:

```lua
do
  -- don't load if sim scenario has already loaded this (in another lua state)
  local modloader = remote.interfaces["modloader"]
  if modloader and modloader[script.mod_name] then
    return
  end
end
```
Also note that if the mod registers any events with filters, the filters will be ignored when loaded by `modloader`.

Create a scenario with the following in `control.lua`:

```lua
local handler = require("event_handler")
local modloader = require("__simhelper__/modloader.lua")
handler.add_lib(modloader.load("nixie-tubes"))
```

Create a world from this scenario, open `/editor` (to remove your character), and save it. Optionally delete all entities and fill with lab tiles. Copy this save into your mod for use in simulations. You can also manually build demo setups if desired.

Define simulation prototypes using this save with commands as needed to set up your desired demo setup. Note that some (all?) of the simulation-specific apis, like `create_entities_from_blueprint_string` do not raise events, so you may need to manually make your mod code aware of created entities. For example, I trigger Nixie Tubes to rescan the world after spawning simulation entities:

```lua
{
    type = "tips-and-tricks-item",
    name = "nixie-tubes",
    tag = "[entity=nixie-tube]",
    category = "nixie-tubes",
    is_title = true,
    order = "zz-00",
    dependencies = {"circuit-network"},
    simulation = {
      save = "__nixie-tubes__/simulations/nixiesim.zip",
      init = [[
        local bp="0eNq1lVtugzAQRfcy36aKzZu/dBtVhIA47UhgkDFRoogFdCHdWFdSG9QEKYRH1fwgbMbncsejmQukecMriUJBdAHMSlFD9HaBGt9Fkps9da44RICKF0BAJIVZCTwht1STcmgJoNjzE0S03RHgQqFC3lO6xTkWTZFyqQPGzhOoylofKYVR0xjLeXEJnPULa1tyB2HLIO4kxF4GYZMQZxnEnoS4yyCbG4SAviUlyzxO+UdyxFKaoAxl1qCK9bf99eQBZa3iu7s8olSN3rlK9xHWFnp4rRJTDxajju8EtucEZruoEpkoowbfn1/Q9rGCZ0atNnhqHpLvh3ePekXtdteOmfeWmaeTGfRHIFZdJHk+VVs6oWOwYA3MnoGFa2BsBkY3a2h0jkbX0DZD2vPq7/VZ9cce1B+9NZNfWUsLpSg6obtEsPk8HDBXXD5oojPGG+OaMttxPT8Ih311hVf6yKv9R6/0f71u77z+zajb+dQTp5tM0WCQETjqv+qcsECXUMh8FgaB5+v28QOiY0wL"
        game.tick_paused = false
        game.camera_alt_info = true
        local result = {game.surfaces[1].create_entities_from_blueprint_string
        {
          string = bp,
          position = {0, 0},
        }}
        remote.call("nixie-tubes", "RebuildNixies")
      ]],
      update = [[

      ]],
    }
  },
```

Note that the `init` and `update` functions can be defined as regular Lua functions captured using `funccapture`, see [its documentation](funccapture.md).
