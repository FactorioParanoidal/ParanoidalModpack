local modName = "__more-achievements__"
local base = "__base__"
local prototypes = {}
local tiers = 9
local amounts = { 10000, 1000000, 20000000, 50000000, 100000000, 250000000, 500000000, 1000000000, 20000000000 }
local numbers = { "10k", "1M", "20M", "50M", "100M", "250M", "500M", "1G", "20G" }

for i = 4, tiers do
    table.insert(prototypes, {
        type = "produce-achievement",
        name = "mass-production-" .. i,
        icons = {
            {
                icon = base .. "/graphics/achievement/mass-production-" .. (((i - 1) % 3) + 1) .. ".png",
                icon_size = 128
            },
            {
                icon = modName .. "/graphics/tier-" .. (i < 7 and 2 or 3) .. ".png",
                icon_size = 128
            },
        },
        localised_name = {
            "",
            {"more-achievements.mass-production"},
            " " .. i
        },
        localised_description = {
            "",
            {"more-achievements.produce"},
            numbers[i],
            " ",
            {"item-name.electronic-circuit"},
            "."
        },
        order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i),
        item_product = "electronic-circuit",
        amount = amounts[i],
        limited_to_one_game = false
    })
end

data:extend(prototypes)
