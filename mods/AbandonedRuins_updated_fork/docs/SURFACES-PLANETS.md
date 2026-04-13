# Planets, other surfaces and this mod

## General notices

Please note that in general terms, ruins are only spawning when a new map tile is being rendered by Factorio. So existing tiles won't have ruins spawned on them. This means that you have to move to the outer "border" of the visible (read: already rendered) map so new tiles can be rendered and perhaps a ruin is spawned.

## How do I exclude any ruins from spawning on my planet's surface?

This is a very common request and old code has recommended to use `exclude_surface` but since some drastic code-change include new remote-call functions (which I want to redirect to) are available things are a bit different but not impossible to fix.

First consider this step as this is drastic. Do you REALLY don't want any ruins spawned on your entire planet? If that's what you want, you need to now invoke two functions as more ruin-sets could be installed.

In your `control.lua` you might want to add some code like this:
```lua
if script.active_mods["AbandonedRuins_updated_fork"] then
  -- First fetch all ruin-sets
  local ruinsets = remote.call("AbandonedRuins", "get_ruin_sets")

  -- Then loop through all ruin-sets
  for ruinset_name, _ in pairs(ruinsets) do
      -- Now exclude it from spawning on your surface
      remote.call("AbandonedRuins", "no_spawning_on", surface_name, ruinset_name)
  end
end
```
The above code assumes that your surface's name is stored in a variable `surface_name`. If `script.active_mods` throws an error at you, then please use `mods` instead, Factorio seem to handle this different in different life-cycle phases.

## I have created a planet and want to have a ruin-set exclusively spawn on my planet only

This is easier to handle than the above code and is the opposite of it. Let's assume your surface's name is stored again in `surface_name` and the exclusive ruin-set's name in `exclusive_ruinset` then your code looks like this snippet:
```lua
if script.active_mods["AbandonedRuins_updated_fork"] then
  -- Exclusive ruin-set
  remote.call("AbandonedRuins", "spawn_exclusively_on", surface_name, exclusive_ruinset)
end
```
You may however should not mark ruin-sets such as `base` or `realistic-ruins` as an exclusive ruin-set to your planet only as these are very "generic" ruin-sets and normally spawn nearly everywhere.

So let's say, you have a planet called "Dune" and have written a ruin-set "Dune ruins" then this is the right code to use.

## I have created a planet and want a certain ruin-set being excluded as it disturbs my planet's look

This is also very easy to handle and is, as you might have guessed, the opposite of exclusive spawning. So to take above code, you only have to replace `spawn_exclusively_on` with `no_spawning_on` and you are done! Yes, it is that simple.

## I have written a mod that has some "hidden/internal" surface and ruin-sets should not spawn there

This can be done also very easily. Can you guess what you have to change in above (exclusive spawning) code? Yes, it is that simple:
```lua
if script.active_mods["AbandonedRuins_updated_fork"] then
  -- Prevent any spawning on hidden/internal surface
  remote.call("AbandonedRuins", "exclude_surface", surface_name)
end
```
As my code doesn't "magically" know your surface is an internal/hidden surface (like Factorisimo or NiceFill have), you have to add that code (and modify it to your needs) to your mod and spawning is entirely prevented.

## I have excluded my surface from ruin-spawning, now I want it back at some some other place

This is very easy to accomplish, too. Take above code and replace `exclude_surface` with `reinclude_surface` and ruins may spawn on your surface again.
