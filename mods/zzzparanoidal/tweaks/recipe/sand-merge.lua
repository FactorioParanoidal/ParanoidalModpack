-- Единый песок: aai-industry вводит предмет "sand", Angels — "angels-solid-sand".
-- Два «Песка» дублировались в поиске; aai-шный не производился (рецепт скрыт),
-- но оставался в bob-glass и триггере glass-processing. Переводим все ссылки
-- на angels-solid-sand и удаляем aai-шные предмет и рецепт. Сохранения — migrations/zzzparanoidal_8.1.28-sand.json.
local OLD, NEW = "sand", "angels-solid-sand"
if not (data.raw.item[OLD] and data.raw.item[NEW]) then return end

local function merge(list)
  if not list then return end
  local seen = {}
  local out = {}
  for _, entry in ipairs(list) do
    if entry.name == OLD and (entry.type or "item") == "item" then entry.name = NEW end
    local key = (entry.type or "item") .. "/" .. tostring(entry.name)
    local prev = (entry.type or "item") == "item" and seen[key]
    if prev and prev.amount and entry.amount and not prev.probability and not entry.probability
      and not prev.amount_min and not entry.amount_min then
      prev.amount = prev.amount + entry.amount
    else
      out[#out + 1] = entry
      seen[key] = entry
    end
  end
  for i = #list, 1, -1 do list[i] = nil end
  for i, entry in ipairs(out) do list[i] = entry end
end

for name, recipe in pairs(data.raw.recipe) do
  if name ~= OLD then
    merge(recipe.ingredients)
    merge(recipe.results)
    if recipe.main_product == OLD then recipe.main_product = NEW end
  end
end

for _, tech in pairs(data.raw.technology) do
  if tech.effects then
    for i = #tech.effects, 1, -1 do
      local e = tech.effects[i]
      if e.type == "unlock-recipe" and e.recipe == OLD then table.remove(tech.effects, i) end
    end
  end
  local trigger = tech.research_trigger
  if trigger and trigger.item == OLD then trigger.item = NEW end
  if trigger and type(trigger.item) == "table" and trigger.item.name == OLD then trigger.item.name = NEW end
end

data.raw.recipe[OLD] = nil
data.raw.item[OLD] = nil
