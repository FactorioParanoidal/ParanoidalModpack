-- Справка по радиации (мод Stuckez12_Radiation). Текст страниц — в locale
-- tips-radiation-pollution.cfg (en/ru). Только при наличии мода: триггер ссылается
-- на его технологию radiation-protection.
if not mods["Stuckez12_Radiation"] then return end

local CATEGORY = "radiation-help"

-- Подстраница с плоским описанием из locale.
local function sub(name, order, tag)
    return {
        type = "tips-and-tricks-item",
        name = name,
        category = CATEGORY,
        tag = tag,
        localised_name = {"tips-and-tricks-name." .. name},
        localised_description = {"tips-and-tricks-description." .. name},
        order = order,
        indent = 1,
        starting_status = "locked",
        dependencies = {"radiation-help"},
        trigger = {type = "dependencies-met"},
    }
end

-- Страница настроек: имя берём ЖИВЫМ ключом {mod-setting-name.*} — оно всегда
-- совпадает с подписью в меню настроек (у радиации настройки только на en),
-- + наше пояснение {zzz-rad-set.*}.
local SETTINGS = {
    {"Stuckez12-Radiation-Enable-Chunk-Range-Radiation", "zzz-rad-set.chunk-range"},
    {"Stuckez12-Radiation-Chunk-Effect-Radius",          "zzz-rad-set.chunk-radius"},
    {"Stuckez12-Radiation-Radiation-Radius",             "zzz-rad-set.rad-radius"},
    {"Stuckez12-Radiation-Protection-Radius",            "zzz-rad-set.protect-radius"},
    {"Stuckez12-Radiation-Base-Radiation",               "zzz-rad-set.base"},
    {"Stuckez12-Radiation-Damage-Multiplier",            "zzz-rad-set.mult"},
    {"Stuckez12-Radiation-Enable-Biter-Radiation",       "zzz-rad-set.biters"},
    {"Stuckez12-Radiation-Chunks-Per-Call",              "zzz-rad-set.perf"},
    {"Stuckez12-Radiation-Enable-GUI-Effect",            "zzz-rad-set.gui"},
    {"Stuckez12-Radiation-Menu-Simulations",             "zzz-rad-set.menu"},
}

local settings_desc = {"", {"tips-and-tricks-description.radiation-settings"}}
for _, s in ipairs(SETTINGS) do
    settings_desc[#settings_desc + 1] =
        {"", "\n• [font=default-bold]", {"mod-setting-name." .. s[1]}, "[/font] — ", {s[2]}}
end

data:extend({
    {type = "tips-and-tricks-item-category", name = CATEGORY, order = "b"},
    {
        type = "tips-and-tricks-item",
        name = "radiation-help",
        category = CATEGORY,
        is_title = true,
        tag = "[img=item/uranium-235]",
        localised_name = {"tips-and-tricks-name.radiation-help"},
        localised_description = {"tips-and-tricks-description.radiation-help"},
        order = "a",
        indent = 0,
        starting_status = "locked",
        trigger = {type = "research", technology = "radiation-protection"},
    },
    sub("radiation-protect", "b", "[img=item/radiation-absorption-equipment]"),
    {
        type = "tips-and-tricks-item",
        name = "radiation-settings",
        category = CATEGORY,
        tag = "[img=item/iron-gear-wheel]",
        localised_name = {"tips-and-tricks-name.radiation-settings"},
        localised_description = settings_desc,
        order = "c",
        indent = 1,
        starting_status = "locked",
        dependencies = {"radiation-help"},
        trigger = {type = "dependencies-met"},
    },
    sub("radiation-sos", "d", "[img=item/uranium-235]"),
})
