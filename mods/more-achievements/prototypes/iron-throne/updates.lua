local meld = require("__core__/lualib/meld")
local base = "__base__"
local numbers = { "20k", "200k", "400k", "1M", "2.5M", "5M", "10M", "25M", "50M" }

for i = 1, 3 do
    meld(data.raw["produce-per-hour-achievement"]["iron-throne-" .. i], {
        icon = meld.delete(),
        icon_size = meld.delete(),
        icons = meld.overwrite({
            {
                icon = base .. "/graphics/achievement/iron-throne-" .. i .. ".png",
                icon_size = 128
            },
            {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { 0, 26 }
            }
        }),
        item_product = meld.overwrite({ name = "iron-plate", quality = "normal" }),
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.iron-throne" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.iron-plate" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-e[iron-throne-" .. i .. "]-a[quality]"
    })
end

for i = 4, 9 do
    meld(data.raw["produce-per-hour-achievement"]["iron-throne-" .. i], {
        icons = meld.append({ {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        } }),
        item_product = meld.overwrite({ name = "iron-plate", quality = "normal" }),
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.iron-throne" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.iron-plate" },
            { "more-achievements.per-hour" }
        }),
        order = "d[production]-e[iron-throne-" .. i .. "]-a[quality]"
    })
end
