# How to create ruin-sets
Other mods can add their own ruin sets to *Abandoned Ruins - Updated* (aka. "core").

## Simple start
First step is to fork my `AbandonedRuins-base` repository. As GIT is fairly distrubuted you can also do this from e.g. gitlab or your own GIT server.

While forking/cloing it, best option is to rename it NOW to avoid confusion and people (including yourself) might want to play it "from source" and not a distributed ZIP file.

So go to your `mods` folder and start the cloning:
```shell
# Example:
cd /opt/GOG/Factorio/game/mods/

# Now clone your fork
git clone git@github.com:You/MyRuinsSet.git

# Change into that new directory
cd MyRuinsSet
```
Now start editing the files, first change `info.json` as it still points on `AbandonedRuins-base` and not yours. So change all relevant fields, like `name`, `version` (e.g. 0.0.1), `author`, `description`, et cetera.
Leave the dependency to the core mod `AbandonedRuins_updated_fork` but make sure you use the latest stable version (you can find it at the mod's page.

Make any needed changes to dependencies and other flags, e.g. if your ruin-set is for Space Age, add the proper flag to `info.json`, too!

Next clear the `changelog.txt` but keep a first entry in it for your first release (please document your changes so others can quickly see what you have done).

Now `git rm ruins/<size>/<ruin-file>.lua` all ruins files (NOT directories!), **except** `__init__.lua` and place your own ruin files in. In `__init__.lua` you fill find a list of the old names, clear that list and fill it with your ruin names ommitting the `.lua` file extension.

There is only one step more for a very basic ruin-set (nothing fancy like described below): Edit `control.lua` and change the value for `RUINSET_NAME` to your liking, NOT the mod's name here!

E.g. use `"my-set"` not `"MyRuinsSet"` here as the later one is the mod's name, not your ruin-set's name! This name will later show up in the "currently selected ruin-set" selection box.

Now you can try to launch Factorio and see what happens. If it starts normally, you are nearly done. Go to mod-settings and check if your ruin-set name you have set in `RUINSET_NAME` appears in the selection box. Yes? Then congratulation!

### Deprecated way
The above way is the most easiest way as all, including optional but recommended `ruin.name` support is included. There was an old way documented here. Please port your ruin-set to the new way. Adding ruins is just as easy as adding another value to an array.

## Excluded surfaces versus spawning on specific surfaces or exclusively
There are different ways in *Abandoned Ruins - Updated* how ruins should spawn or not spawn. So let me clarify them here:

- `spawn_on_surfaces` is a table of surfaces where exclusively ruins should spawn or everywhere except those listed here. It is ruin-depending, optional to use. Its purpose to either allow ruins spawn only on specified surfaces or on all surfaces except the ones listed.
- `spawn_exclusively_on()` is a remote-call function to let the "core" mod be notified that the ruin-sets should exclusively spawn on that surface.
- `no_spawning` is a table of surfaces where the ruin having this property isn't allowed to spawn on (e.g. ruins with water on Fulgora)
- `no_spawning_on()` is a remote-call function to let the "core" mod not spawn ruins from given ruin-set on given surface
- `spawning.excluded_surfaces` is a table of (mostly) "internal" (inaccesible) surfaces that should always be excluded. Its purpose is that "planet/moon" mods can exclude themselves from *Abandoned Ruins - Updated* __alltogether__. There is a simple code for to be added to `control.lua`.

So if you maintain a ruin-set, `spawning.excluded_surfaces` is by 99.9% chance __NOT__ your option to choose as then your ruin-set is fully excluded from the mod's spawning process.

So if you maintain a "planet/moon", which are surfaces BTW, and you want some own ruins with your planet's entities randomly spawn only on your planet, I recommend that you write for the ruins a separate mod.

In contrast if you maintain a mod like Factorisimo or NiceFill, adding your internal, hidden surace to `spawning.excluded_surfaces` is what you want so it doesn't cause any side-effects.

Example #1:
- Your mod planet "Foolands" is about a deserted planet where a civilizaton once lived on. It comes with custom buildings (machines) that fit the whole planet's theme.
- Now you certainly want to show that there was once a civilization living on it with some ruins. Since Factorio doesn't allow designing planets (chunk generation), you are left with randomly spawning ruins to make it look once populated.
- Other ruins may not spawn on your planet. But since banning other mods (like this one) in your `info.json` is a bit harsh and gamers maybe not wish to still have ruins spawned on other planets like Nauvis is, the mod's remote-call function `spawn_exclusively_on()` comes handy.

Example #2:
- Your mod is like Factorisimo (factories shrinked into a building) and you don't want ruins being spawned there
- Then your best option is to add this to your `control.lua`:
```lua
if script.active_mods["AbandonedRuins_updated_fork"] then
	remote.call("AbandonedRuins", "exclude_surface", "YourFactorisimoMod")
end
```

## Adding more sizes?
The current ruin-sets can be split into 3 different "sizes" with each having different spawn chances. As per default settings, while `small` as the highest chance and `large` has the lowest. Still for some folks these 3 sizes might not be enough.

E,g, `tiny` or `huge` might be some desired names. For this, there is some experimental (untested!) support in core mod and you have to add a global runtime setting to your `settings.lua` file:

First add the folder `ruins/tiny` and copy `__init__.lua` from e.g. `ruins/small/` to it, remove all ruin names from the list.

Add some ruin files to folder `ruins/tiny/` and add their names to the previously cleared list.

Then add the size `tiny` to your `settings.lua` file:
```lua
data:extend({
  {
    type = "double-setting",
    name = "ruins-tiny-ruin-chance",
    setting_type = "runtime-global",
    default_value = 0.02,
    minimum_value = 0.0,
    maximum_value = 1.0,
    order = "c0"
  }
})
```

Last in your `control.lua` you have to register the new ruin size:
```
```
