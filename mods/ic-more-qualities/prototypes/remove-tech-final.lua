-- odebere nadbytecny vyzkumy, protoze nove kvality upravi cely system kvalit

-- Paranoidal: effects of type "nothing" (e.g. the research evolution note) do not keep a research
-- useful. Such researches are hidden instead of deleted: other mods may still reference them.
local function only_notes(effects)
  for _, effect in pairs(effects or {}) do
    if effect.type ~= "nothing" then return false end
  end
  return true
end
local function hide_if_useless(name)
  local technology = data.raw.technology[name]
  if technology and only_notes(technology.effects) then
    technology.hidden = true
    technology.enabled = false
  end
end

if data.raw.technology["legendary-quality"] then
  for i = #data.raw.technology["legendary-quality"].effects, 1, -1 do
    effect = data.raw.technology["legendary-quality"].effects[i]
    if effect.type == "unlock-quality" then
      table.remove(data.raw.technology["legendary-quality"].effects, i)
    end
  end

  if next(data.raw.technology["legendary-quality"].effects) == nil then
    data.raw.technology["legendary-quality"] = nil
  end
end

if data.raw.technology["epic-quality"] then
  for i = #data.raw.technology["epic-quality"].effects, 1, -1 do
    effect = data.raw.technology["epic-quality"].effects[i]
    if effect.type == "unlock-quality" and effect.quality == "epic" then
      table.remove(data.raw.technology["epic-quality"].effects, i)
    end
  end

  if next(data.raw.technology["epic-quality"].effects) == nil and not data.raw.technology["legendary"] then
    data.raw.technology["epic-quality"] = nil
  end
end

hide_if_useless("legendary-quality")
hide_if_useless("epic-quality")
