# Factory Search

Have you ever asked yourself any of these questions?

"Where are the repair packs being made?"

"How many green circuit machines do I have?"

"Which planet did I build my iron smelters on?"

If so, then Factory Search might be the mod for you!

Similar to [BeastFinder](https://mods.factorio.com/mod/BeastFinder) and [Where is it Made?](https://mods.factorio.com/mod/WhereIsItMade). This mod was made to provide an easy-to-use and clean-looking interface that can perform cross-surface searches and immediate viewing of search results in the map view (and across planets with Space Exploration).

-----
## Doesn't 2.0 have built-in search?

Factorio 2.0 has some brilliant built-in search functionality ([Product, Tag, and Train stop search](https://factorio.com/blog/post/fff-400), [Resource search](https://factorio.com/blog/post/fff-426)). However, you might still want to use Factory Search for the other search modes that vanilla can't do, such as searching for items in storage, modules in machines, requests for an item, or signals. Factory Search is also useful for searching across all planets at once, whereas built-in search only searches your current planet.

-----
## Features

- Press `Shift + F` to open search interface (can be changed in Settings > Controls)
- Pick any combination of the following search modes
    - Ingredient: Search for machines that consume this item (either as  ingredient or fuel)
    - Product: Search for machines that produce this item or fluid
    - Storage: Search for containers that contain this item or fluid
    - Logistics: Search for logistics entities that are transporting this item
    - Module: Search for machines that are using this module
    - Entity: Search for built entities of this item, including resource patches
    - Ground: Search for this item on the ground
    - Request: Search for logistic containers that are requesting this item
    - Signal: Search for entities that are sending this signal
    - Tag: Search for tags on the map that have this icon
- Factory Search will present a list of machines matching the selected search modes, grouped by name and proximity
- Displays results from all planets/surfaces, so works well with Space Age and Space Exploration
- Click on a result group to open it in remote view
- `Alt + Shift + Click` on any game object (e.g. built entity, inventory item, recipe) to open the search interface with that item selected
- Supports multiplayer and compatible with any mod. No UPS impact when not in use, but searching may freeze the game for a couple of seconds on larger maps
    - Background search can be enabled to search in the background instead of freezing the game (enabled by default in multiplayer)

Check out Xterminator's mod spotlight [here](https://youtu.be/_60XPAT3uas) (though this version is from 1.1 and quite old).

-----
## Future Updates?

- More streamlined item selection workflow
- Integration with [Recipe Book](https://mods.factorio.com/mod/RecipeBook) and [Quick Item Search](https://mods.factorio.com/mod/QuickItemSearch)
- Better support for PvP so that corpses and ground items aren't shown in hidden chunks
- 'Expanded' view, with inline cameras like the train overview GUI (not for many months…)

-----
## Translation

You can help by translating this mod into your language using [CrowdIn](https://crowdin.com/project/factorio-mods-localization). Any translations made will automatically be included in the next release.

-----
Thank you to:

- [raiguard](https://mods.factorio.com/user/raiguard) for [flib](https://mods.factorio.com/mod/flib) (GUI library), [Quick Item Search](https://mods.factorio.com/mod/QuickItemSearch) (provided initial framework), and [Better Alert Arrows](https://mods.factorio.com/mod/BetterAlertArrows) (arrow sprite)
- [Atria](https://mods.factorio.com/user/Atria) for [various contributions](https://github.com/tburrows13/FactorySearch/issues?q=is%3Apr%20author%3AAtria1234)
- [justarandomgeek](https://mods.factorio.com/user/justarandomgeek) for the excellent [mod debugger](https://github.com/justarandomgeek/vscode-factoriomod-debug)
- [Earendel](https://mods.factorio.com/user/Earendel) for the character corpse icon
