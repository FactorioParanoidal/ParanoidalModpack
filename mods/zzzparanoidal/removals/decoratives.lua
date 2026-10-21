-- Без декораций: удаляет тот же набор декоративов, что SingleColorTerrain в Beta 8.
-- Камни в 2.0 переименованы; обломков кораблей с травой и puberty-decal в 2.0 нет.
-- В 2.0 на декоративы ссылаются планеты, пресеты карты и spawn_decoration гнёзд/червей,
-- поэтому ссылки вычищаются вместе с прототипами (после гнёзд других модов и пресетов карты).
if not settings.startup["no-decor"].value then return end

local names =
{
  "brown-asterisk", "brown-asterisk-mini", "brown-carpet-grass", "brown-fluff", "brown-fluff-dry",
  "brown-hairy-grass", "dark-mud-decal", "garballo-mini-dry", "green-asterisk", "green-asterisk-mini",
  "green-bush-mini", "green-carpet-grass", "green-croton", "green-desert-bush", "green-hairy-grass",
  "green-pita", "green-pita-mini", "green-small-grass", "light-mud-decal", "red-asterisk",
  "red-croton", "red-desert-bush", "red-desert-decal", "red-pita", "sand-decal",
  "sand-dune-decal", "white-desert-bush",
  -- 1.1: rock-medium, rock-small, rock-tiny, sand-rock-medium, sand-rock-small
  "medium-rock", "small-rock", "tiny-rock", "medium-sand-rock", "small-sand-rock",
  -- 1.1: big-ship-wreck-grass, small-ship-wreck-grass, puberty-decal (в 2.0 отсутствуют)
  "big-ship-wreck-grass", "small-ship-wreck-grass", "puberty-decal"
}

local decoratives = data.raw["optimized-decorative"] or {}
local removed = {}
for _, name in pairs(names) do
  if decoratives[name] then
    decoratives[name] = nil
    removed[name] = true
  end
end

local function clean_autoplace(autoplace_settings)
  local settings_table = autoplace_settings and autoplace_settings.decorative and autoplace_settings.decorative.settings
  if not settings_table then return end
  for name in pairs(removed) do
    settings_table[name] = nil
  end
end

for _, planet in pairs(data.raw.planet or {}) do
  clean_autoplace(planet.map_gen_settings and planet.map_gen_settings.autoplace_settings)
end

for _, presets in pairs(data.raw["map-gen-presets"] or {}) do
  for _, preset in pairs(presets) do
    if type(preset) == "table" and preset.basic_settings then
      clean_autoplace(preset.basic_settings.autoplace_settings)
    end
  end
end

for _, prototypes in pairs(data.raw) do
  for _, prototype in pairs(prototypes) do
    local list = type(prototype) == "table" and prototype.spawn_decoration
    if type(list) == "table" then
      if list.decorative then list = {list} end
      local kept = {}
      for _, entry in pairs(list) do
        if not removed[entry.decorative] then
          kept[#kept + 1] = entry
        end
      end
      prototype.spawn_decoration = kept[1] and kept or nil
    end
  end
end
