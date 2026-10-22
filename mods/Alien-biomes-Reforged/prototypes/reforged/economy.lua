-- Economy atlas: startup setting alien-biomes-reforged-atlas = "economy".
-- Uses only graphics that are already in the mod: fewer variants and shared pictures, no
-- extra files. Everything a save depends on keeps its name and count (tree variation count,
-- tile and decorative names); decoratives and tile variants are chosen by position, so
-- switching the setting on an existing map only changes how things look.
local setting = settings.startup["alien-biomes-reforged-atlas"]
if not (setting and setting.value == "economy") then return end

local MOD = "__Alien-biomes-Reforged__/"
local tint_matrices = require("prototypes/tint-matrices")

local function is_ours(filename)
  return type(filename) == "string" and filename:sub(1, #MOD) == MOD
end

local function first_filename(t)
  if type(t) ~= "table" then return nil end
  if t.filename then return t.filename end
  if t.picture then return t.picture end
  for _, v in pairs(t) do
    local f = first_filename(v)
    if f then return f end
  end
end

-- 1. Tiles: one tint matrix per family; only the 1x1 variants and half of the 2x2 ones are
-- kept (the 4x4 variants were three quarters of every tile sheet in the atlas).
local SIZE2_COUNT = 8
for name, tile in pairs(data.raw.tile) do
  local main = tile.variants and tile.variants.main
  if main and main[1] and is_ours(main[1].picture) then
    local e = tint_matrices.tiles[name] and tint_matrices.tiles[name].economy
    local kept = {}
    for _, v in ipairs(main) do
      if v.size == 1 or v.size == 2 then
        if e then v.picture = e.picture end
        if v.size == 2 and (v.count or 1) > SIZE2_COUNT then
          v.count = SIZE2_COUNT
          if v.weights then
            local w = {}
            for i = 1, SIZE2_COUNT do w[i] = v.weights[i] end
            v.weights = w
          end
        end
        kept[#kept + 1] = v
      end
    end
    tile.variants.main = kept
    if e then tile.tint = e.tint end
  end
end

-- 2. Decoratives drawn from this mod with 6+ pictures (dunes, lava, sand/stone/wetland
-- decals, puddles, craters, vegetation): every third picture is kept.
for _, deco in pairs(data.raw["optimized-decorative"]) do
  local pics = deco.pictures
  if type(pics) == "table" and #pics >= 6 and is_ours(first_filename(pics[1])) then
    local kept = {}
    for i = 1, #pics, 3 do kept[#kept + 1] = pics[i] end
    deco.pictures = kept
  end
end

-- 3. Trees: similar species share graphics, each species keeps the first half of its
-- variations (the others reuse them), normal maps are dropped. The number of variations
-- of every tree prototype is unchanged, so trees on existing maps keep a valid variation.
local SPECIES_TARGET = {
  willow = "mangrove",       -- weeping crowns
  greypine = "conifer-01",   -- conifers
  specter = "oaktapus",      -- dense bushy crowns
  scarecrow = "oaktapus",
  pear = "ash",              -- sparse foliage on a visible trunk
}
local GRAPHICS_FIELDS = {"trunk", "leaves", "normal", "shadow", "overlay", "underwater",
                         "water_reflection", "disable_shadow_distortion_beginning_at_frame"}
local TRUNK_PATTERN = "^__Alien%-biomes%-Reforged__/graphics/entity/tree/([^/]+)/tree%-.+%-(%a)%-trunk%.png$"

local function species_of(variation)
  local f = variation.trunk and variation.trunk.filename
  if type(f) ~= "string" then return nil end
  return f:match(TRUNK_PATTERN)
end

local canonical, letters = {}, {}
local tree_names = {}
for name in pairs(data.raw.tree) do tree_names[#tree_names + 1] = name end
table.sort(tree_names)
for _, name in ipairs(tree_names) do
  for _, v in pairs(data.raw.tree[name].variations or {}) do
    local species, letter = species_of(v)
    if species then
      canonical[species] = canonical[species] or {}
      if not canonical[species][letter] then
        canonical[species][letter] = table.deepcopy(v)
        letters[species] = letters[species] or {}
        table.insert(letters[species], letter)
      end
    end
  end
end
for _, list in pairs(letters) do table.sort(list) end

local function index_of(list, value)
  for i, v in ipairs(list) do if v == value then return i end end
end

for _, name in ipairs(tree_names) do
  for _, v in pairs(data.raw.tree[name].variations or {}) do
    local species, letter = species_of(v)
    if species then
      local target = SPECIES_TARGET[species]
      if not (target and letters[target]) then target = species end
      local keep = math.ceil(#letters[target] / 2)
      local idx = index_of(letters[species], letter)
      local source_letter = letters[target][(idx - 1) % keep + 1]
      if target ~= species or source_letter ~= letter then
        local src = canonical[target][source_letter]
        for _, field in pairs(GRAPHICS_FIELDS) do
          v[field] = table.deepcopy(src[field])
        end
      end
      v.normal = nil
    end
  end
end

log("Alien-biomes-Reforged: economy atlas applied")
