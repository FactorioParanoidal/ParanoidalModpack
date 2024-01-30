[![Crowdin Translate](https://img.shields.io/badge/Crowdin-Translate-brightgreen)](https://crowdin.com/project/factorio-mods-localization) [![Factorio Mod Portal page](https://img.shields.io/badge/dynamic/json?color=orange&label=Factorio&query=downloads_count&suffix=%20downloads&url=https%3A%2F%2Fmods.factorio.com%2Fapi%2Fmods%2FMilestones)](https://mods.factorio.com/mod/Milestones)

# FactorioMilestones
Factorio Mod for tracking your milestones

Published here: https://mods.factorio.com/mod/Milestones

## Contributing

Pull requests welcome!

If you want to add a preset, take a look under the `preset` folder.

If you want to add a preset for a big overhaul mod that will work with no or very few other overhaul mods (e.g. Space Exploration), please add your preset in  [`presets.lua`](presets/presets.lua). Only one of those presets will be chosen by Milestones at the beginning of a game.

If you want to add a preset for a small mod that could be added on top of any other mod (e.g. Power Armor Mk3), please add your preset in [`preset_addons.lua`](presets/preset_addons.lua). All valid addons will be added at the end of the chosen main preset.

Thanks a lot!
