local modName = "__more-achievements__"
local base = "__base__"
local quality = "__quality__"
local prototypes = {}
local tiers = 3
local modules = { "speed", "efficiency", "productivity" }
local amounts = { 1, 50, 100 }
local qualities = { "uncommon", "rare", "epic", "legendary" }

for i = 1, tiers do
    local amount = amounts[i]
    local number = tostring(amount)

    for j = 1, #modules do
        local module = modules[j]

        for k = 1, #qualities do
            local prototype = {
                type = "produce-achievement",
                name = "crafting-with-" .. module .. "-" .. i .. "-" .. qualities[k],
                icons = {
                    {
                        icon = base .. "/graphics/achievement/crafting-with-" .. module .. ".png",
                        icon_size = 128
                    },
                    {
                        icon = quality .. "/graphics/icons/quality-" .. qualities[k] .. ".png",
                        icon_size = 64,
                        scale = 0.1875,
                        shift = { -10, 10 }
                    }
                },
                localised_name = {
                    "",
                    "[img=quality/" .. qualities[k] .. "]",
                    " ",
                    { "more-achievements.crafting-with", module },
                    " " .. i
                },
                localised_description = {
                    "",
                    { "more-achievements.craft" },
                    number,
                    " ",
                    "[img=quality/" .. qualities[k] .. "]",
                    " ",
                    { "item-name." .. module .. "-module-3" },
                    "."
                },
                order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + j) .. "[" .. module .. "]-" .. string.char(96 + i) .. "-" .. string.char(96 + k) .. "[quality]",
                item_product = { name = module .. "-module-3", quality = qualities[j] },
                amount = amount,
                limited_to_one_game = false
            }

            if i == 1 then
                prototype.localised_name = {
                    "",
                    "[img=quality/" .. qualities[k] .. "]",
                    " ",
                    { "more-achievements.crafting-with", module }
                }
                prototype.localised_description = {
                    "",
                    { "more-achievements.craft-a" },
                    "[img=quality/" .. qualities[k] .. "]",
                    " ",
                    { "item-name." .. module .. "-module-3" },
                    "."
                }
            else
                table.insert(prototype.icons, 2, {
                    icon = modName .. "/graphics/tier-" .. i .. ".png",
                    icon_size = 128,
                    shift = { 16, -2 }
                })
            end

            table.insert(prototypes, prototype)
        end
    end
end

data:extend(prototypes)
