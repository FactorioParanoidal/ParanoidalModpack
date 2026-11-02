ic = {
    chance = {
        value = settings.startup["ic-more-qualities-chance-to-upgrade"].value,
        dynamic_bonus = settings.startup["ic-more-qualities-chance-dynamic-bonus"].value,
        next = 0
    }
}

function ic.get_chance()
    local chance = math.min(ic.chance.value + ic.chance.next, 1)
    ic.chance.next = ic.chance.next + ic.chance.dynamic_bonus
    return chance
end

-- Factorio 2.1 (Paranoidal, user decision: keep the 2.0 chances). The curve and the settings stay in 2.0 terms:
-- `chance` is the 2.0 next_probability of the tier. 2.0 rolled the first step with quality effect x
-- next_probability of the ingredient quality and every further step with next_probability of the tier reached.
-- 2.1 divides quality effect values by 10 and splits the tier value: next_probability (first step, x effect) and
-- chain_probability (further steps after reaching the tier). So next_probability = 10 x chance and
-- chain_probability = chance give the same rolls as 2.0 (engine check: test-runs/port21-q20bench2-20261102 on
-- 2.0.77 vs port21-q21a/q21b-20261102 on 2.1.24, 270000 crafts each, get_roll_chances).
function ic.set_chance(quality, chance)
    quality.next_probability = chance * 10
    quality.chain_probability = chance
    return quality
end