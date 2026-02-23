local meld = require("__core__/lualib/meld")
local base = "__base__"
local tiers = 9
local numbers = { "1.0k", "10k", "25k", "50k", "100k", "250k", "500k", "1M", "5M" }

for i = 1, 3 do
    meld(data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i], {
        icon = meld.delete(),
        icon_size = meld.delete(),
        icons = meld.overwrite({
            {
                icon = base .. "/graphics/achievement/circuit-veteran-" .. i .. ".png",
                icon_size = 128
            },
            {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { 0, 26 }
            }
        }),
        item_product = { name = "advanced-circuit", quality = "normal" },
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.circuit-veteran" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.advanced-circuit" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-c[advanced-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
    })
end

for i = 4, tiers do
    meld(data.raw["produce-per-hour-achievement"]["circuit-veteran-" .. i], {
        icons = meld.append({{
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        }}),
        item_product = { name = "advanced-circuit", quality = "normal" },
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.circuit-veteran" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            "[img=quality/normal]",
            " ",
            numbers[i],
            " ",
            { "item-name.advanced-circuit" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-c[advanced-circuit-production]-" .. string.char(96 + i) .. "a-[quality]"
    })
end
