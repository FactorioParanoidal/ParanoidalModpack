local shared = require("shared")

-- Last, so other mods' tiles are covered too: paved floors are the tiles that can be mined back up.
for _, tile in pairs(data.raw.tile) do
  if not tile.minable then
    tile.collision_mask.layers = tile.collision_mask.layers or {}
    tile.collision_mask.layers[shared.unpaved] = true
  end
end

-- What flies off a decorative as the bot scrubs it up: its own trigger effect (grass bits, splinters), as an explosion
-- the script makes on the tile. The game's destroy-decoratives effect would set these off itself, but it can't keep to
-- one tile.
local scrubbed = {}
for name, decorative in pairs(data.raw["optimized-decorative"]) do
  if decorative.trigger_effect then
    scrubbed[#scrubbed + 1] =
    {
      type = "explosion",
      name = shared.scrubbed .. name,
      flags = {"not-on-map"},
      hidden = true,
      animations = {{filename = "__core__/graphics/empty.png", size = 1, frame_count = 1}},
      created_effect =
      {
        type = "direct",
        action_delivery = {type = "instant", target_effects = table.deepcopy(decorative.trigger_effect)}
      }
    }
  end
end
if #scrubbed > 0 then
  data:extend(scrubbed)
end
