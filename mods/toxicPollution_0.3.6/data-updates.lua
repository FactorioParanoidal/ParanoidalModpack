local armorsToxin = {
    -- Base Mod
    {name = "light-armor",          decrease = 0, percent = 10, durability = 1000},
    {name = "heavy-armor",          decrease = 0, percent = 30, durability = 5000},
    {name = "modular-armor",        decrease = 0, percent = 40, durability = 10000},
    {name = "power-armor",          decrease = 0, percent = 60, durability = 15000},
    {name = "power-armor-mk2",      decrease = 0, percent = 70, durability = 20000},

    -- Power Armor MK3
    {name = "power-armor-mk3",      decrease = 0, percent = 90, durability = 30000},
    {name = "power-armor-mk4",      decrease = 0, percent = 90, durability = 40000},

    -- Bob Warface
    {name = "heavy-armor-2",        decrease = 0, percent = 35, durability = 6500},
    {name = "heavy-armor-3",        decrease = 0, percent = 43, durability = 8500},
    {name = "bob-power-armor-mk3",  decrease = 0, percent = 30, durability = 30000},
    {name = "bob-power-armor-mk4",  decrease = 0, percent = 40, durability = 40000},
    {name = "bob-power-armor-mk5",  decrease = 0, percent = 50, durability = 50000}
}

for _, resist in pairs(armorsToxin) do
    local items = data.raw.armor
    local armor = items[resist.name]
    if armor then
        table.insert(armor.resistances, {type = "toxin", decrease = resist.decrease, percent = resist.percent})
		armor.durability = resist.durability
		armor.infinite = false
		if (resist.name:find("modular") == nil and resist.name:find("power") == nil) then
			armor.stack_size = 10
		end
    end
end