local modName = "__more-achievements__"
local base = "__base__"
local quality = "__quality__"
local prototypes = {}
local tiers = 9
local amounts = { 20000, 200000, 400000, 1000000, 2500000, 5000000, 10000000, 25000000, 50000000 }
local numbers = { "20k", "200k", "400k", "1M", "2.5M", "5M", "10M", "25M", "50M" }
local qualities = { "uncommon", "rare", "epic", "legendary" }

for i = 1, tiers do
    local iconIndex = (((i - 1) % 3) + 1)
    local amount = amounts[i]
    local number = numbers[i]

    for j = 1, #qualities do
        local prototype = {
            type = "produce-per-hour-achievement",
            name = "iron-throne-" .. i .. "-" .. qualities[j],
            icons = {
                {
                    icon = base .. "/graphics/achievement/iron-throne-" .. iconIndex .. ".png",
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
                { "more-achievements.iron-throne" },
                " " .. i
            },
            localised_description = {
                "",
                { "more-achievements.produce" },
                number,
                " ",
                "[img=quality/" .. qualities[j] .. "]",
                " ",
                { "item-name.iron-plate" },
                { "more-achievements.per-hour" }
            },
            order = "d[production]-e[iron-throne-" .. i .. "]-" .. string.char(97 + j) .. "[quality]",
            item_product = { name = "iron-plate", quality = qualities[j] },
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
