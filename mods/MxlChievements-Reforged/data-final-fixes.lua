-- Final fixes: every product, quality and base achievement is known here.
-- A catalog that fails to load is skipped with a log line; the game keeps loading.

local THEMES = {"resources", "industry", "quality", "energy", "logistics", "combat", "nature", "space",
  "challenges", "character"}

local function load(module)
  local ok, result = pcall(require, module)
  if ok and type(result) == "table" then return result end
  log("MxlChievements-Reforged: " .. module .. " not loaded: " .. tostring(result))
  return {}
end

local themes, by_key = {}, {}
for _, key in ipairs(THEMES) do
  local entries = key == "character" and {} or load("prototypes.content." .. key)
  local theme = {key = key, entries = entries}
  table.insert(themes, theme)
  by_key[key] = theme
end
for _, entry in ipairs(load("prototypes.scripted")) do
  table.insert((by_key[entry.theme] or by_key.character).entries, entry)
end

local builder = load("prototypes.builder")
if builder.build then
  local ok, err = pcall(builder.build, load("prototypes.base-series"), load("prototypes.catalog"), themes)
  if not ok then log("MxlChievements-Reforged: achievements not built: " .. tostring(err)) end
end
