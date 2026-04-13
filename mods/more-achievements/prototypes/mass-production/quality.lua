local modName = "__more-achievements__"
local base = "__base__"
local quality = "__quality__"
local prototypes = {}
local tiers = 9
local amounts = { 10000, 1000000, 20000000, 50000000, 100000000, 250000000, 500000000, 1000000000, 20000000000 }
local numbers = { "10k", "1M", "20M", "50M", "100M", "250M", "500M", "1G", "20G" }
local qualities = { "uncommon", "rare", "epic", "legendary" }

for i = 1, tiers do
    local iconIndex = ((i - 1) % 3) + 1
    local amount = amounts[i]
    local number = numbers[i]

    for j = 1, #qualities do
        local prototype = {
            type = "produce-achievement",
            name = "mass-production-" .. i .. "-" .. qualities[j],
            icons = {
                {
                    icon = base .. "/graphics/achievement/mass-production-" .. iconIndex .. ".png",
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
                { "more-achievements.mass-production" },
                " " .. i
            },
            localised_description = {
                "",
                { "more-achievements.produce" },
                number,
                " ",
                "[img=quality/" .. qualities[j] .. "]",
                " ",
                { "item-name.electronic-circuit" },
                "."
            },
            order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i) .. "-" .. string.char(97 + j) .. "[quality]",
            item_product = { name = "electronic-circuit", quality = qualities[j] },
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
