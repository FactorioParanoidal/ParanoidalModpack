local modName = "__more-achievements__"
local base = "__base__"
local prototypes = {}
local tiers = 9
local amounts = { 500, 1000, 5000, 10000, 25000, 50000, 100000, 250000, 500000 }
local numbers = { "500", "1.0k", "5k", "10k", "25k", "50k", "100k", "250k", "500k" }

for i = 3, tiers do
    table.insert(prototypes, {
        type = "produce-per-hour-achievement",
        name = "computer-age-" .. i,
        icons = {
            {
                icon = base .. "/graphics/achievement/computer-age-" .. (((i - 1) % 3) + 1) .. ".png",
                icon_size = 128
            },
            {
                icon = modName .. "/graphics/tier-" .. (i < 7 and 2 or 3) .. ".png",
                icon_size = 128
            },
        },
        localised_name = {
            "",
            {"more-achievements.computer-age"},
            " " .. i
        },
        localised_description = {
            "",
            {"more-achievements.produce"},
            numbers[i],
            " ",
            {"item-name.processing-unit"},
            {"more-achievements.per-hour"}
        },
        order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i),
        item_product = "processing-unit",
        amount = amounts[i],
        limited_to_one_game = false
    })
end

data:extend(prototypes)
