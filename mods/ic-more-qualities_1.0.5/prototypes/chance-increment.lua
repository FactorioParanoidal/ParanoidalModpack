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