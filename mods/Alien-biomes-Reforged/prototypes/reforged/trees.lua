-- Tree shadows and normal maps of this mod are stored at half resolution (tools/trees.py).
-- Their sprite definitions are rewritten to match: width/height = ceil(original / 2),
-- scale doubled, shift unchanged. Runs right after the trees are created (before economy.lua
-- and before any other mod can copy them). Only one-row animations starting at x = y = 0 are
-- produced by the generator; anything else is an error so that a layout change upstream is
-- noticed at load time instead of drawing the wrong part of the sheet.
local PATTERNS = {
  "^__Alien%-biomes%-Reforged__/graphics/entity/tree/[^/]+/[^/]+%-shadow%.png$",
  "^__Alien%-biomes%-Reforged__/graphics/entity/tree/[^/]+/[^/]+%-normal%.png$",
}

local function halved_file(filename)
  if type(filename) ~= "string" then return false end
  for _, p in pairs(PATTERNS) do
    if filename:find(p) then return true end
  end
  return false
end

local seen = {}
local function halve(sprite, where)
  if type(sprite) ~= "table" or seen[sprite] then return end
  seen[sprite] = true
  if sprite.layers then
    for _, layer in pairs(sprite.layers) do halve(layer, where) end
    return
  end
  if not halved_file(sprite.filename) then return end
  if (sprite.x or 0) ~= 0 or (sprite.y or 0) ~= 0 or (sprite.line_length or 0) ~= 0 then
    error("Alien-biomes-Reforged: unexpected layout of " .. sprite.filename .. " in " .. where ..
          "; regenerate it with tools/trees.py and extend this rule")
  end
  sprite.width = math.ceil(sprite.width / 2)
  sprite.height = math.ceil(sprite.height / 2)
  sprite.scale = (sprite.scale or 1) * 2
end

for name, tree in pairs(data.raw.tree) do
  for _, v in pairs(tree.variations or {}) do
    halve(v.shadow, name)
    halve(v.normal, name)
  end
end
