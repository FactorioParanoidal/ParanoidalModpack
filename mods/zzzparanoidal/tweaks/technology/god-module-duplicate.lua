-- The Beta 8 chain replaces Bob 2.0's unnumbered God technology.
-- Its modules/recipes are already hidden by prototypes.modules-beta8.
local technologies = data.raw.technology
local restored = technologies["god-module-1"]
local obsolete = technologies["bob-god-module"]
if not restored or not obsolete then return end

-- Only retire the duplicate when the replacement provides its shared unlock.
local has_unlock = false
for _, effect in ipairs(restored.effects or {}) do
    if effect.type == "unlock-recipe" and effect.recipe == "intelligent-io" then
        has_unlock = true
        break
    end
end
assert(has_unlock, "Beta 8 God modules must unlock intelligent-io before retiring bob-god-module")
obsolete.hidden = true
obsolete.enabled = false
obsolete.hidden_in_factoriopedia = true
