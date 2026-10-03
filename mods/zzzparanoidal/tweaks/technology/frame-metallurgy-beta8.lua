-- Beta 8 normal: the bootstrap recipes and frames already unlock at metallurgy
-- II/III. Restore the tier-III prerequisites, without altering technology effects.
local metallurgy = data.raw.technology["angels-metallurgy-3"]
if metallurgy then
    metallurgy.prerequisites = {"angels-metallurgy-2", "chemical-science-pack", "angels-ore-leaching"}
end

-- Angels 2.0 adds a hidden Bob bronze duplicate to this unlock list. Beta 8
-- exposes bronze-alloy-x instead; leave the legacy prototype but not its unlock.
local bronze = data.raw.technology["angels-bronze-smelting-1"]
if bronze then
    for i = #(bronze.effects or {}), 1, -1 do
        local effect = bronze.effects[i]
        if effect.type == "unlock-recipe" and effect.recipe == "bob-bronze-alloy" then
            table.remove(bronze.effects, i)
        end
    end
end
