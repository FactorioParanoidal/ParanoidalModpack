-- Localised search: background translation of technology names and of what they unlock, matching and the
-- reason of a match. State lives in the per-player window state `s` (storage.native_players).
local G = require("graph")
local Goal = require("goal")
local M = {}

-- Unlock text format: one name per line, so a match can name the recipe or item it came from.
-- Older saves hold format 1 (names joined by spaces) and are translated again.
local UNLOCK_FORMAT = 2
local BUDGET = 32 -- requests per player per call (every 15 ticks)
local SCAN = 256  -- technologies looked at per call, requests or not

-- Search text of what a technology unlocks: names of the unlocked recipes, their products and given items.
-- One translation request per technology. Every name is wrapped in {"?", name, ""}: a name without a locale
-- entry becomes empty instead of failing the whole string. A LocalisedString has at most 20 parameters, so
-- the names are grouped by 20 (two levels: up to 400 names). nil when the technology unlocks nothing.
local function add_name(list, seen, key, localised_name)
  if seen[key] then return end
  seen[key] = true
  list[#list + 1] = {"", {"?", localised_name, ""}, "\n"}
end
function M.unlock_string(t)
  local list, seen = {}, {}
  for _, effect in ipairs(t.prototype.effects or {}) do
    if effect.type == "unlock-recipe" then
      local recipe = prototypes.recipe[effect.recipe]
      if recipe then
        add_name(list, seen, "recipe/" .. recipe.name, recipe.localised_name)
        for _, product in ipairs(recipe.products or {}) do
          local proto
          if product.type == "fluid" then proto = prototypes.fluid[product.name] else proto = prototypes.item[product.name] end
          if proto then add_name(list, seen, product.type .. "/" .. product.name, proto.localised_name) end
        end
      end
    elseif effect.type == "give-item" then
      local item = prototypes.item[effect.item]
      if item then add_name(list, seen, "item/" .. effect.item, item.localised_name) end
    end
  end
  if #list == 0 then return nil end
  local groups = {""}
  for i = 1, #list, 20 do
    if #groups > 20 then break end
    local group = {""}
    for j = i, math.min(#list, i + 19) do group[#group + 1] = list[j] end
    groups[#groups + 1] = group
  end
  return groups
end

local function fields(s)
  s.translations = s.translations or {}; s.pending = s.pending or {}; s.request_index = s.request_index or 1
  s.unlock_index = s.unlock_index or 1; s.unlock_pending = s.unlock_pending or {}
  s.unlock_texts = s.unlock_texts or {}; s.unlock_raw = s.unlock_raw or {}
  if s.unlock_format ~= UNLOCK_FORMAT then
    s.unlock_format = UNLOCK_FORMAT
    s.unlock_index = 1; s.unlock_pending = {}; s.unlock_texts = {}; s.unlock_raw = {}
  end
end

-- Forget all translations (the player's language changed).
function M.reset(s)
  s.translations = {}; s.pending = {}; s.request_index = 1
  s.unlock_index = 1; s.unlock_pending = {}; s.unlock_texts = {}; s.unlock_raw = {}
end

-- Background translation: runs for every connected player from joining the game, window open or not.
-- Technology names first, then the unlock texts. When the graph is rebuilt both walks restart and skip
-- what is already known.
function M.step(p, s)
  fields(s)
  local g = Goal.graph(p.force)
  local names = g.names
  if s.names_serial ~= g.serial then
    s.names_serial = g.serial; s.request_index = 1; s.unlock_index = 1
  end
  local budget, scan = BUDGET, SCAN
  while budget > 0 and scan > 0 do
    local n = names[s.request_index]
    if not n then break end
    s.request_index = s.request_index + 1; scan = scan - 1
    if not s.translations[n] then
      budget = budget - 1
      local id = p.request_translation(p.force.technologies[n].localised_name)
      if id then s.pending[id] = n end
    end
  end
  if names[s.request_index] then return end
  while budget > 0 and scan > 0 do
    local n = names[s.unlock_index]
    if not n then break end
    s.unlock_index = s.unlock_index + 1; scan = scan - 1
    if not s.unlock_texts[n] then
      local ls = M.unlock_string(p.force.technologies[n])
      if ls then
        budget = budget - 1
        local id = p.request_translation(ls)
        if id then s.unlock_pending[id] = n end
      end
    end
  end
end

-- Share of the translation done, 0..100; 100 only when everything is requested and answered.
function M.percent(p, s)
  fields(s)
  local total = #Goal.graph(p.force).names
  if total == 0 then return 100 end
  local requested = math.min(s.request_index - 1, total) + math.min(s.unlock_index - 1, total)
  local waiting = table_size(s.pending) + table_size(s.unlock_pending)
  if requested >= 2 * total and waiting == 0 then return 100 end
  return math.min(99, math.floor(math.max(0, requested - waiting) * 100 / (2 * total)))
end

-- Does `n` match the lower-cased query? Returns false, true (by its name) or the unlocked name it matched.
function M.match(s, n, query)
  if string.find(G.lower(n), query, 1, true) then return true end
  local name = s.translations and s.translations[n]
  if name and string.find(G.lower(name), query, 1, true) then return true end
  local text = s.unlock_texts and s.unlock_texts[n]
  if not text then return false end
  local at = string.find(text, query, 1, true)
  if not at then return false end
  -- The line around the match; lower-casing keeps byte lengths, so the same range of the raw text has the case.
  local from = at
  while from > 1 and string.sub(text, from - 1, from - 1) ~= "\n" do from = from - 1 end
  local to = string.find(text, "\n", at, true)
  to = to and to - 1 or #text
  local raw = s.unlock_raw and s.unlock_raw[n]
  local line = raw and #raw == #text and string.sub(raw, from, to) or string.sub(text, from, to)
  return line ~= "" and line or true
end

-- on_string_translated. Returns the new search text when it matches the current query (the caller
-- schedules a refresh), nil otherwise.
function M.translated(s, e)
  local name = s.pending and s.pending[e.id]
  if name then
    s.pending[e.id] = nil
    if e.translated then
      s.translations[name] = e.result
      return G.lower(e.result)
    end
    return nil
  end
  name = s.unlock_pending and s.unlock_pending[e.id]
  if name then
    s.unlock_pending[e.id] = nil
    if e.translated then
      -- Stored lower-cased for matching and raw for showing the matched name with its case.
      local text = G.lower(e.result)
      s.unlock_texts[name] = text; s.unlock_raw[name] = e.result
      return text
    end
  end
  return nil
end

return M
