local modName = "__more-achievements__"
local base = "__base__"
local prototypes = {}
local tiers = 9
local amounts = { 20000, 200000, 400000, 1000000, 2500000, 5000000, 10000000, 25000000, 50000000 }
local numbers = { "20k", "200k", "400k", "1M", "2.5M", "5M", "10M", "25M", "50M" }

for i = 4, tiers do
    table.insert(prototypes, {
        type = "produce-per-hour-achievement",
        name = "iron-throne-" .. i,
        icons = {
            {
                icon = base .. "/graphics/achievement/iron-throne-" .. (((i - 1) % 3) + 1) .. ".png",
                icon_size = 128
            },
            {
                icon = modName .. "/graphics/tier-" .. (i < 7 and 2 or 3) .. ".png",
                icon_size = 128
            },
        },
        localised_name = {
            "",
            {"more-achievements.iron-throne"},
            " " .. i
        },
        localised_description = {
            "",
            {"more-achievements.produce"},
            numbers[i],
            " ",
            {"item-name.iron-plate"},
            {"more-achievements.per-hour"}
        },
        order = "d[production]-e[iron-throne-" .. i .. "]",
        item_product = "iron-plate",
        amount = amounts[i],
        limited_to_one_game = false
    })
end

data:extend(prototypes)
