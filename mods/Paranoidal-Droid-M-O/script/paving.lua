-- Paved floors: every tile that can be mined back up (data-final-fixes.lua puts the others on shared.unpaved).
local shared = require("shared")

local paving = {}

local paved_tiles
paving.is_paved = function(tile_name)
  if not paved_tiles then
    paved_tiles = {}
    for name, tile in pairs(prototypes.tile) do
      paved_tiles[name] = not tile.collision_mask.layers[shared.unpaved]
    end
  end
  return paved_tiles[tile_name]
end

return paving
