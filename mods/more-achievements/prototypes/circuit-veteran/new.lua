local modName = "__more-achievements__"
local base = "__base__"
local prototypes = {}
local tiers = 9
local amounts = { 1000, 10000, 25000, 50000, 100000, 250000, 500000, 1000000, 5000000 }
local numbers = { "1.0k", "10k", "25k", "50k", "100k", "250k", "500k", "1M", "5M" }

for i = 3, tiers do
    table.insert(prototypes, {
        type = "produce-per-hour-achievement",
        name = "circuit-veteran-" .. i,
        icons = {
            {
                icon = base .. "/graphics/achievement/circuit-veteran-" .. (((i - 1) % 3) + 1) .. ".png",
                icon_size = 128
            },
            {
                icon = modName .. "/graphics/tier-" .. (i < 7 and 2 or 3) .. ".png",
                icon_size = 128
            },
        },
        localised_name = {
            "",
            {"more-achievements.circuit-veteran"},
            " " .. i
        },
        localised_description = {
            "",
            {"more-achievements.produce"},
            numbers[i],
            " ",
            {"item-name.advanced-circuit"},
            {"more-achievements.per-hour"}
        },
        order = "d[production]-c[advanced-circuit-production]-" .. string.char(96 + i),
        item_product = "advanced-circuit",
        amount = amounts[i],
        limited_to_one_game = false
    })
end

data:extend(prototypes)
