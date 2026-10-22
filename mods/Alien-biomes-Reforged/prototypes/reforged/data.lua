-- Alien-biomes-Reforged additions to the data stage. Required at the end of data.lua
-- (hook in tools/patches.py), i.e. right after tiles, decoratives and trees are created,
-- so that mods copying these prototypes later receive the final graphics.
require("prototypes/reforged/trees")
require("prototypes/reforged/economy")
require("prototypes/reforged/geology")
