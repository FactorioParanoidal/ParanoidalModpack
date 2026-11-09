-- Paranoidal fork (Space Age branch, user 2026-11-09): Muluna is the first stop after the rocket and opens the way to
-- every other planet, so its exploration science comes from Muluna and home only. Upstream gated the nanofoamed polymers
-- (diffused and microcellular plastic -> lightweight platform foundation -> interstellar science pack) behind two
-- researched planetary science packs, recomputed here after every other mod (Muluna.exploration_science.refresh()) and
-- researched by scripts/interstellar-science-pack.lua. Here the technology is an ordinary trigger: foam plastic with
-- flue gas, which Muluna's vacuum boiler makes. The conditions stay in the mod-data with zero packs required, so the
-- control script does nothing, and no technology carries the "contributes to discovery" label.
local conditions = data.raw["mod-data"]["muluna-interstellar-science-pack-conditions"].data
conditions.science_packs = {}
conditions.packs = {}
conditions.required_science_packs = 0
conditions.gated_technology = conditions.gated_technology or "muluna-nanofoamed-polymers"
Muluna.exploration_science.apply_labels(conditions)

local technology = data.raw["technology"][conditions.gated_technology]
if technology then
    technology.enabled = true
    technology.visible_when_disabled = nil
    technology.unit = nil
    technology.prerequisites = {"muluna-advanced-boiler"}
    technology.research_trigger = {type = "craft-fluid", fluid = "carbon-dioxide", amount = 1000}
    technology.localised_description = {"technology-description.paranoidal-muluna-nanofoamed-polymers"}
end
