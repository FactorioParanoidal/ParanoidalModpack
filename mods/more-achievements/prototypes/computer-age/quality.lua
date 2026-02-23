local modName = "__more-achievements__"
local base = "__base__"
local quality = "__quality__"
local prototypes = {}
local tiers = 9
local amounts = { 500, 1000, 5000, 10000, 25000, 50000, 100000, 250000, 500000 }
local numbers = { "500", "1.0k", "5k", "10k", "25k", "50k", "100k", "250k", "500k" }
local qualities = { "uncommon", "rare", "epic", "legendary" }

for i = 1, tiers do
    local iconIndex = ((i - 1) % 3) + 1
    local amount = amounts[i]
    local number = numbers[i]

    for j = 1, #qualities do
        local prototype = {
            type = "produce-per-hour-achievement",
            name = "computer-age-" .. i .. "-" .. qualities[j],
            icons = {
                {
                    icon = base .. "/graphics/achievement/computer-age-" .. iconIndex .. ".png",
                    icon_size = 128
                },
                {
                    icon = quality .. "/graphics/icons/quality-" .. qualities[j] .. ".png",
                    icon_size = 64,
                    scale = 0.1875,
                    shift = { 0, 26 }
                }
            },
            localised_name = {
                "",
                "[img=quality/" .. qualities[j] .. "]",
                " ",
                { "more-achievements.computer-age" },
                " " .. i
            },
            localised_description = {
                "",
                { "more-achievements.produce" },
                number,
                " ",
                "[img=quality/" .. qualities[j] .. "]",
                " ",
                { "item-name.processing-unit" },
                { "more-achievements.per-hour" }
            },
            order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i) .. "-" .. string.char(97 + j) .. "[quality]",
            item_product = { name = "advanced-circuit", quality = qualities[j] },
            amount = amount,
            limited_to_one_game = false
        }

        if i > 3 then
            table.insert(prototype.icons, 2, {
                icon = modName .. "/graphics/tier-" .. (i < 7 and 2 or 3) .. ".png",
                icon_size = 128
            })
        end

        table.insert(prototypes, prototype)
    end
end

data:extend(prototypes)
