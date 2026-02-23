# Contributing

## Bug reports

Please include the [log file](https://wiki.factorio.com/Log_file) in your bug reports. Enable debug logging (not for `on_tick`!) before uploading the log file e.g. on a public pastebin (no one-click hosters, please!).

## Contributing ruins

Since the 1.2.0 release, all ruin-sets from this mod have been moved out into an external mod called `AbandonedRuins-base`. *This* mod is now only a "framework" for ruin-sets and does NOT add any content to your game (no ruins will spawn).

If you wish to add ruins with "generic" (base game only) entities, adding them to `AbandonedRuins-base` is the best choice. Please head over to its [documentation](https://github.com/Quix0r/AbandonedRuins-base/blob/master/docs/CONTRIBUTING.md) instead.

You are invited to make your own ruins mod basing on `AbandonedRuins-base` mod or "stand-alone". Your mod can extend it with more ruins or modify its entities. If your mod requires other mods (because of their content), then add it as a mandatory dependency in your `info.json` file.

### Extending/modifying "base" ruin-set

Extending or modifying "base" ruin-set is described in the mod's [documentation](https://github.com/Quix0r/AbandonedRuins-base/blob/master/docs/CONTRIBUTING.md). You must add `AbandonedRuins-base` as a mandatory dependency in your `info.json` then.

### Creating stand-alone ruin-sets

Like the mod [realistic-ruins-updated](https://github.com/Quix0r/realistic-ruins-updated). Also read the above mentioned documentation. It is explained there more detailed.

You can use the dedicated [ruin maker mod](https://github.com/Bilka2/ruin-maker) to easily create ruins in-game. You can also manually create or edit ruins, their format is documented here: [Ruin data format](https://github.com/Quix0r/AbandonedRuins-base/blob/master/format.md).
