local meld = require("__core__/lualib/meld")
local base = "__base__"
local numbers = { "10k", "1M", "20M", "50M", "100M", "250M", "500M", "1G", "20G" }

for i = 1, 3 do
    meld(data.raw["produce-achievement"]["mass-production-" .. i], {
        icon = meld.delete(),
        icon_size = meld.delete(),
        icons = meld.overwrite({
            {
                icon = base .. "/graphics/achievement/mass-production-" .. i .. ".png",
                icon_size = 128
            },
            {
                icon = base .. "/graphics/icons/quality-normal.png",
                icon_size = 64,
                scale = 0.1875,
                shift = { 0, 26 }
            }
        }),
        item_product = meld.overwrite({ name = "electronic-circuit", quality = "normal" }),
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.mass-production" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.electronic-circuit" },
            "."
        }),
        order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
    })
end

for i = 4, 9 do
    meld(data.raw["produce-achievement"]["mass-production-" .. i], {
        icons = meld.append({ {
            icon = base .. "/graphics/icons/quality-normal.png",
            icon_size = 64,
            scale = 0.1875,
            shift = { 0, 26 }
        } }),
        item_product = meld.overwrite({ name = "electronic-circuit", quality = "normal" }),
        localised_name = meld.overwrite({
            "",
            "[img=quality/normal]",
            " ",
            { "more-achievements.mass-production" },
            " " .. i
        }),
        localised_description = meld.overwrite({
            "",
            { "more-achievements.produce" },
            numbers[i],
            " ",
            "[img=quality/normal]",
            " ",
            { "item-name.electronic-circuit" },
            "."
        }),
        order = "d[production]-b[electronic-circuit-production]-" .. string.char(96 + i) .. "-a[quality]"
    })
end
