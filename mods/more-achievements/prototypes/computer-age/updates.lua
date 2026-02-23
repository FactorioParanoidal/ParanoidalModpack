local meld = require("__core__/lualib/meld")
local base = "__base__"
local numbers = { "500", "1.0k", "5k", "10k", "25k", "50k", "100k", "250k", "500k" }

for i = 1, 3 do
    meld(data.raw["produce-per-hour-achievement"]["computer-age-" .. i], {
        icon = meld.delete(),
        icon_size = meld.delete(),
        icons = meld.overwrite({
            {
                icon = base .. "/graphics/achievement/computer-age-" .. i .. ".png",
                icon_size = 128
            },
            {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { 0, 26 }
            }
        }),
        item_product = { name = "processing-unit", quality = "normal" },
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.computer-age" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.processing-unit" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i) .. "-a[quality]"
    })
end

for i = 4, 9 do
    meld(data.raw["produce-per-hour-achievement"]["computer-age-" .. i], {
        icons = meld.append({ {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        } }),
        item_product = { name = "processing-unit", quality = "normal" },
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.computer-age" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.processing-unit" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-d[processing-unit-production]-" .. string.char(96 + i) .. "-a[quality]"
    })
end
