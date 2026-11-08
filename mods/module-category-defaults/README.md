[![foundrygg.com](https://img.shields.io/badge/foundrygg-4a1402?style=for-the-badge&logo=vercel&logoColor=white)](https://foundrygg.com) [![Discord](https://img.shields.io/badge/Discord-%235865F2.svg?style=for-the-badge&logo=discord&logoColor=white)](https://discord.gg/VuVhYUBbWE) [![Downloads](https://img.shields.io/factorio-mod-portal/dt/module-category-defaults?style=for-the-badge&logo=data%3Aimage%2Fx-icon%3Bbase64%2CAAABAAEAEBAAAAEACABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAALzAtABIVFwBBOSwAISYpAB0iJACTfFQAICQnAEk%2FLAAcICIAsZZlADs4MABsXUIAd2hMAINzVgChi2QAPTozAIt6WwAWGhsAs5prABwgIwC1nG4AKSglAEpGOwBhVDwAGx4hAGJUPABoXkkAMiwiAGleSQCwmW8AtJpsALigdABnXEcAi3ZPAFhNOACDb0sAIicqAEtCLwAxMzEAEhQWAE1EMgAgJSgAISUoAJV%2FWACrkmQAHyMmAIFwUgAbHyEAsJVkAG5gRgAXGxwAHSEkAKCKYwCzmWoAsJhtACIhHAAbHyIAeWtRADo3MACxmnAAtZttACMoKgAaHSAAPzcoABYZGwASFRYAX1ZEAINwTABKRTsAIygrAJqDWABoXUkAHyQmAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADExMTExEyAgEzExMTExADExMRMVCi8EBC8KFTYxMTExMT0OGx5DJSVDHkgRHzExMTEyB0YnRiUlPidGBw0xMTExGi5GJS4JOS4lRkkpMTExHzcrRi4SHEBBLkYrNxUKMTpFRiUURDExRAklRhchLTE%2FKyU%2BCzExMTE7JSUqGSwxAj8qRgEVCgoVEEYqPwIGMSQMSUYlHTw8HSVGSQwiMTExDwclJSVGRiUlPgc1MTExMQMwNBQuJSUuFAU5IzExMTEiOEImFklJFiYCKCQxMTExMUckMRgzMxgxJCIxMTExMTExMTEiCAgiMTExMTExADExMTExMTExMTExMTExAIABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAIABAAA%3D&color=orange&labelColor=rgb(111,148,173))](https://mods.factorio.com/mod/module-category-defaults) [![GitLab Bugs](https://img.shields.io/gitlab/issues/open/jfletcher94%2Fmodule-category-defaults?labels=bug&style=for-the-badge&logo=gitlab&label=Bugs)](https://gitlab.com/jfletcher94/module-category-defaults/-/work_items) [![GitLab Critical](https://img.shields.io/gitlab/issues/open/jfletcher94%2Fmodule-category-defaults?labels=critical&style=for-the-badge&logo=gitlab&label=Critical)](https://gitlab.com/jfletcher94/module-category-defaults/-/work_items) [![Gitlab Pipeline Status](https://img.shields.io/gitlab/pipeline-status/jfletcher94%2Fmodule-category-defaults?branch=main&style=for-the-badge&logo=gitlab)](https://gitlab.com/jfletcher94/module-category-defaults/-/pipelines)

## Module Category Defaults

This library mod sets the vanilla module categories as `allowed_module_categories` for all applicable entity prototypes that do not have that field already set by another mod. This allows blacklisting special modules when a mod needs to define its own rules for including them.

In effect, this mod inverts the engine's behavior for modded module categories: instead of being allowed for all entities by default, all modded module categories will be _disallowed for all entities by default_. Modded module categories can be added to this mod's list of default categories, which will cause them to be treated as if they were vanilla categories (i.e. enabled by default). The same can also be done for recipes; this is not done automatically, but only if another mod requires it.

## Mod Support

In the `data` stage, the global table `ModuleCategoryDefaults` is made available. Most importantly, it contains a table `default_categories` that will be used to apply the defaults. Add or remove values to change the outcome of this mod. You probably want to add your custom category that you want to be available to all regular machines. `ModuleCategoryDefaults` also has a few additional tables and functions, which are explained in the examples.

This mod makes all its changes in `data-final-fixes`. Default categories should be added in your mod's `data` or `data-updates`. Any logic that depends on `allowed_module_categories` being set should be in your mod's `data-final-fixes`, and may require an additional step for compatibility safety (explained in the examples).

### Example: My mod adds a module category for all buildings to use.

1. Add `module-category-defaults` as a dependency to your mod.
2. Add your module category to the defaults table: `table.insert(ModuleCategoryDefaults.default_categories, 'my-module-category')`.

Done. The module(s) will be available the same as without this mod. This must be done in either `data` or `data-updates`.

### Example: My mod adds a special module for a special building.

1. Add `module-category-defaults` as a dependency to your mod.
2. Add your special module category to the `allowed_module_categories` table for each of the special buildings, as you would normally do.

Done. No other buildings will be able to use the module. You do not need to touch `ModuleCategoryDefaults` or the `allowed_module_categories` table of any other entity prototypes. This must be done in either `data` or `data-updates`.

### Example: My mod adds a special module that should be used in _no_ buildings.

1. Add `module-category-defaults` as a dependency to your mod.
2. Add your module category to the restricted categories table: `table.insert(ModuleCategoryDefaults.restricted_categories, 'my-module-category')`.

Done. No buildings will be able to use the module. This must be done in either `data` or `data-updates`.

### Example: My mod has prototype-stage code that needs this library's code to have run.

1. Add `module-category-defaults` as a dependency to your mod.
2. At the top of your mod's `data-final-fixes.lua`, call `ModuleCategoryDefaults.process_entity_prototypes()`.

Done. All entity prototypes will already have been processed in this mod's `data-final-fixes`; this is only necessary in case a third mod adds any new entity prototypes then and your mod's `data-final-fixes`. Each entity prototype is only ever processed once; all previously-procssed prototypes are skipped during any subsequent call to `ModuleCategoryDefaults.process_entity_prototypes()`.

It is possible to call this function in `data-updates` or even `data`, but this is prone to error and incompatibilities (especially `data`). Only do this if absolutely necessary.

### Example: My mod needs default `allowed_module_categories` values set for recipes too.

1. Add `module-category-defaults` as a dependency to your mod.
2. At the top of your mod's `data-final-fixes.lua`, call `ModuleCategoryDefaults.process_recipe_prototypes()`.

Done. This uses the exact same logic and defaults as for entities. The same caveats as `process_entity_prototypes` apply to this function.

## Additional Compatibility

If you enable the startup setting "Autodetect default categories", the mod will attempt to automatically detect additional module categories to treat like vanilla categories and enable by default. This feature is a "best effort" attempt to improve compatibility with mods that add module categories but do not use this library; it is not guaranteed to fix compatibility issues. Some mods that use this library may require this setting to be enabled; if the setting is not visible, this is likely why.

## Contributors

* [Cackling fiend](https://mods.factorio.com/user/cackling.fiend): Original author.
* [Thremtopod](https://mods.factorio.com/user/thremtopod): Current maintainer.