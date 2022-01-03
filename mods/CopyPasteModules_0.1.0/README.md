# Copy Paste Modules

Copy and paste modules mod for Factorio. [Factorio mod portal](https://mods.factorio.com/mod/CopyPasteModules).


## Version

Current version in compatible with Factorio 1.1.
See the [changelog](https://github.com/kajacx/CopyPasteModules/blob/master/changelog.md) for more information.


## How to use

First, place some modules into a machine, and then copy that machine's settings (by shift + right click)
into another machine (shift + left click) and voila, the modules are copied (inserted from the player's inventory) as well!

The inserted modules will be sorted in the same order. You can also copy from a machine with no modules to remove all modules.

If the player doesn't have enough modules, a logistic request can be automatically created (turned on by default)
to fill those modules from the logistic network. However, the additional modules will not be sorted (this may be changed in a future version).

From 0.1.0 it also works when placing blueprint with modules (or a blueprint with no modules to remove modules!)
over an entity, these modules will also not be sorted, since Factorio keeps only counts of modules in the blueprint data.


## Settings

 - #### Enable when copying settings
Copy modules (insert from player's inventory) together with entity settings (when shift-clicking).

 - #### Create logistic request
Create logistic request when the player does not have enough modules on them.

 - #### Copy modules from blueprint
Copy modules (create a logistic request) when building over an existing entity with a blueprint.


## Contributing

If you want to contribute, then you can do so by creating a pull request.
 - If your PR is a new feature or a change in behaviour to an existing feature,
 then please fork it from the [develop](https://github.com/kajacx/CopyPasteModules/tree/develop) branch.
 - If your PR fixes a bug in the released version of the mod,
 then please fork it from the [master](https://github.com/kajacx/CopyPasteModules/tree/master) branch.

## License

This mod is licensed under the [MIT Licence](https://github.com/kajacx/CopyPasteModules/blob/master/LICENSE).
