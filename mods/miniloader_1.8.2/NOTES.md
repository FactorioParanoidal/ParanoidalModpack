### Code to paste to setup testing

```lua
/c
local bar = game.player.get_inventory(defines.inventory.player_quickbar)
bar.clear()
for _, stack in ipairs{
    "electric-energy-interface",
    "medium-electric-pole",
    "steel-chest",
    "iron-plate",
    "miniloader",
    "transport-belt",
    "fast-miniloader",
    "fast-transport-belt",
    "express-miniloader",
    "express-transport-belt",
} do
    bar.insert(stack)
end
bar.insert("iron-plate")
game.player.insert{name="iron-plate", count=500}
game.player.insert{name="copper-plate", count=500}
```