
# Sim Helper

Sim Helper consists of 2 parts to assist with creating simulations.

## Mod Loader

`modloader` is a wrapper to allow running a mostly-unmodified `control.lua` from a mod as an `event_handler` library inside `level`. This is useful because simulations do not load mods, however there is a good chance you need your mod to be loaded for the simulation to work, so it runs in `level` instead.

For a more detailed explanation see [here](modloader.md).

## Function Capture

`funccapture` allows you to capture a regular Lua function and use it for the `init` and `update` functions for simulations. This is useful because `init` and `update` expect strings which are code to be executed in a console command context, disallowing the use of `require` making it hard to reuse code. However with `funccapture`, you can just call functions outside of the captured function and they will be part of the string assigned to `init` and `update`.

For a more detailed explanation see [here](funccapture.md).
