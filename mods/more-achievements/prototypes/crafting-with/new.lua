local modName = "__more-achievements__"
local base = "__base__"
local prototypes = {}
local tiers = 3
local modules = { "speed", "efficiency", "productivity" }
local amounts = { 1, 50, 100 }

for i = 2, tiers do
    local amount = amounts[i]
    local number = tostring(amount)

    for j = 1, #modules do
        local module = modules[j]

        table.insert(prototypes, {
            type = "produce-achievement",
            name = "crafting-with-" .. module .. "-" .. i,
            icons = {
                {
                    icon = base .. "/graphics/achievement/crafting-with-" .. module .. ".png",
                    icon_size = 128
                },
                {
                    icon = modName .. "/graphics/tier-" .. i .. ".png",
                    icon_size = 128,
                    shift = { 16, -2 }
                }
            },
            localised_name = {
                "",
                { "more-achievements.crafting-with", module },
                " " .. i
            },
            localised_description = {
                "",
                { "more-achievements.craft" },
                number,
                " ",
                { "item-name." .. module .. "-module-3" },
                "."
            },
            order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + j) .. "[" .. module .. "]-" .. string.char(96 + i),
            item_product = module .. "-module-3",
            amount = amount,
            limited_to_one_game = false
        })
    end
end

data:extend(prototypes)
