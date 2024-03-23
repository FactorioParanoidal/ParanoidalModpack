Remote Configuration allows you to click on any machine in map view and open its GUI. While the GUI is open, you can change configurations (e.g. combinator signals, chest limits, spidertron logistic requests) but you can't transfer any items. Since you need to be able to select the machines, radar coverage is required.

Also allows red/green wire and copper cable placement and entity settings copy-paste in map view.

Press _R_ over a machine to create a rotation request for it (or _Shift + R_ for reverse rotation). Assembling machines are rotated instantly because that's what vanilla does when you paste a blueprint with a rotated machine on top of an existing one. For other entity types, a construction bot must come and rotate them.

_Right-click_ on a machine to mark it for deconstruction. _Shift + Right-click_ to cancel deconstruction.

Attempting to build in map view replaces the item in cursor with a ghost so that you don't have to hold _Shift_. When building after exiting map view, the ghost cursor is replaced with a real item again. This can be disabled in mod settings. (This feature doesn't work if "Automatic ghost cursor" from [Cursor Enhancements](https://mods.factorio.com/mod/CursorEnhancements) is enabled).


All interactions can be disabled by removing their keybind in **Settings > Controls**. There is a setting in mod settings to additionally enable these interactions when not in map mode, but when trying to do something out of range.


## Compatibility

- Compatible with any mod, including [Far Reach](https://mods.factorio.com/mod/far-reach)
- Works with [Space Exploration](https://mods.factorio.com/mod/space-exploration), although functionality is mostly superseded by SE's Navigation Satellite, which also works cross-surface
- Recommended with [Wire Shortcut X](https://mods.factorio.com/mod/WireShortcutX) or [Wire Shortcuts](https://mods.factorio.com/mod/WireShortcuts) for long distance wire connections
- Utilises vanilla's permissions system, so may break if you aren't using the **Default** permissions group. Let me know if you'd like me to improve the interactions in this area
