local S = require("shared")

-- Qualities (including the pack's attack range scaling) are set in data-updates.
local multipliers = {}
for name, quality in pairs(data.raw.quality or {}) do
  local multiplier = quality.range_multiplier or math.min(1 + 0.1 * (quality.level or 0), 3)
  if multiplier ~= 1 then multipliers[name] = multiplier end
end

for tier in ipairs(S.tiers) do
  data.raw["logistic-container"][S.tower(tier)].radius_visualisation_specification.distance_quality_multiplier = multipliers
end
