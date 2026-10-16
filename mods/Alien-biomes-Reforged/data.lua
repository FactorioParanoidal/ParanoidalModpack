-- test map seed: 2682915831
local util = require("data-util")
local default_decal_layer = 183 -- should be replaced in data-final-fixes
if not logged_mods_once then logged_mods_once = true log("Log mods once: "..serpent.block(mods)) end

local biomes = require("prototypes/biome/biomes")

-- global
alien_biomes = {}
alien_biomes.all_tiles = biomes.all_tiles
alien_biomes.require_tag = biomes.require_tag
alien_biomes.require_tags = biomes.require_tags
alien_biomes.exclude_tags = biomes.exclude_tags
alien_biomes.list_tiles = biomes.list_tiles
alien_biomes.axes = biomes.axes
alien_biomes.spec = biomes.spec
alien_biomes.tile_alias = biomes.tile_alias


require("prototypes/styles")
require("prototypes/disables")
require("prototypes/noise-programs")
require("prototypes/item-groups")
require("prototypes/decorative/decoratives")
require("prototypes/decorative/puddle-decal")
require("prototypes/decorative/wetland-decal")
require("prototypes/decorative/rocks")
require("prototypes/decorative/lava")
require("prototypes/decorative/vegetation")
require("prototypes/decorative/vegetation-bush")
require("prototypes/decorative/vegetation-cane")
require("prototypes/decorative/crater")
require("prototypes/entity/trees")

-- They forgot to add those in vanilla
table.insert(data.raw.item.landfill.place_as_tile.tile_condition, "water-shallow")
table.insert(data.raw.item.landfill.place_as_tile.tile_condition, "water-mud")

-- TODO: Alien Biomes does not currently have a full set of Cliff graphics, we are missing the "-lower" additional variants added with 2.0
-- for _, cliff in pairs(data.raw.cliff) do
--   util.replace_filenames_recursive(cliff.orientations, "__base__", "__Alien-biomes-Reforged__")
-- end