# Todo List

This list may be out of date. To avoid duplication of effort, please post in [Discord](https://discord.gg/nFVqaPEk97) if you are working on one of these tasks.

## Significant

- Settings for the rotation of planets. By default, they should probably face their parent body, but should be able to be rotated to face another arbitrary body. Placement of the labels may also be related.
- User settings for the science packs required by promethium science: (all science packs) / (vanilla science packs only) / (don't touch it at all). We should also add hidden booleans so that mod authors can force it to be one of these values.
- Layer orbit sprites behind the sprites of the parent body. This should be directed by the orbit tree. For the feature to work, PlanetsLib will probably need to control all the images on the starmap. Currently, planets without sprite_only have their starmap icons drawn by the game engine so are not layered by the orbit structure.
- Player-facing setting to recenter the starmap each time you open it?
- Support elliptical orbits (presumably via another option on the Python script).
- Helpers to construct asteroid routes.

## Minor

- Add screenshot of moon orbits to the mod portal.
- Rewrite generate-visit-planet-achievement script in python