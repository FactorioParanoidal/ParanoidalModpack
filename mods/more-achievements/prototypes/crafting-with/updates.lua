local meld = require("__core__/lualib/meld")
local base = "__base__"
local tiers = 3
local modules = { "speed", "efficiency", "productivity" }
local numbers = { "1", "50", "100" }

for i = 1, #modules do
    local module = modules[i]

    meld(data.raw["produce-achievement"]["crafting-with-" .. module], {
        icon = meld.delete(),
        icon_size = meld.delete(),
        icons = meld.overwrite({
            {
                icon = base .. "/graphics/achievement/crafting-with-" .. module .. ".png",
                icon_size = 128
            },
            {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { -10, 10 }
            }
        }),
        item_product = { name = module .. "-module-3", quality = "normal" },
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.crafting-with", module }
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.craft-a" },
            "[img=quality/normal]",
            " ",
            { "item-name." .. module .. "-module-3" },
            "."
        }),
        order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + i) .. "[" .. module .. "]-a-a[quality]"
    })

    for j = 2, tiers do
        meld(data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. j], {
            icons = meld.append({ {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { -10, 10 }
            } }),
            item_product = { name = module .. "-module-3", quality = "normal" },
            localised_name = meld.overwrite({
                "",
                "[img=quality/normal]",
                " ",
                { "more-achievements.crafting-with", module },
                " " .. j
            }),
            localised_description = meld.overwrite({
                "",
                { "more-achievements.craft" },
                numbers[j],
                " ",
                "[img=quality/normal]",
                " ",
                { "item-name." .. module .. "-module-3" },
                "."
            }),
            order = "a[progress]-h[crafting-tier-3-module]-" .. string.char(96 + i) .. "[" .. module .. "]-" .. string.char(96 + j) .. "-a[quality]"
        })
    end
end
