# Picker Dollies

Hover over entities and use the Picker dolly keybinds to move entities around. Entities will keep their wire connections and settings. This allows you to build your set up spaced out and when you are finished push it all together for a nice tight build. Some entities can't be shoved around. Also respects max wire distance. Note Moving some modded entities that rely on position can cause issues. There is an API available that mod authors can use to be notified of these events.

![Dollies in Action](https://github.com/Nexela/PickerAtheneum/raw/master/.web/picker-combinator-dolly.gif)

[![Picker Dollies](http://img.youtube.com/vi/LbBK6wAtMHU/0.jpg)](http://www.youtube.com/watch?v=LbBK6wAtMHU "Picker Dollies Mod Spotlight")

## Dollies Remote API

Whenever a player moves an entity using picker dollies an event is raised. Listening for this event will allow you to update your entities if needed.

In your mods on_load and on_init events add:
```lua
if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), your_function_to_update_the_entity)
end
```

The dolly moved event returns a table with the following the information:
```lua
{
    player_index = player_index, -- The index of the player who moved the entity
    moved_entity = entity, -- The entity that was moved
    start_pos = position -- The position that the entity was moved from
}
```

In addition a remote api to disallow moving of an entity is available:
```lua
if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
    remote.call("PickerDollies", "add_blacklist_name", "name-of-your-entity")
end
```
