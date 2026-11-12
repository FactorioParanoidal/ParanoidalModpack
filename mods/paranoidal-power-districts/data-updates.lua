-- Quality does not affect transformers and load banks (user decision 2026-11-12): ic-more-qualities keeps
-- the results of these recipes always normal (registry documented in its README, section "Рецепты «результат всегда обычный»").
local S = require("shared")
local registry = data.raw["mod-data"] and data.raw["mod-data"]["ic-normal-result"]
if registry and registry.data and registry.data.recipes then
  for _, t in ipairs(S.TIERS) do registry.data.recipes[t.name] = true end
  registry.data.recipes[S.LOAD_BANK] = true
  registry.data.recipes[S.METER] = true
end
for _, t in ipairs(S.TIERS) do
  local r = data.raw.recipe[t.name]
  if r then r.allow_quality = false end
end
for _, name in ipairs({ S.LOAD_BANK, S.METER }) do
  if data.raw.recipe[name] then data.raw.recipe[name].allow_quality = false end
end
