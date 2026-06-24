-- Справка по токсичному загрязнению (мод toxicPollution2). Текст — в locale
-- tips-radiation-pollution.cfg (en/ru). Только при наличии мода: триггер ссылается
-- на его технологию armor-absorb-1.
if not mods["toxicPollution2"] then return end

local CATEGORY = "pollution-help"

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
        dependencies = {"pollution-help"},
        trigger = {type = "dependencies-met"},
    }
end

-- Имя настройки — живым ключом {mod-setting-name.*} (совпадает с меню), + пояснение.
local SETTINGS = {
    {"armor-absorb-multiplier",       "zzz-pol-set.absorb-mult"},
    {"min-pollution-to-damage",       "zzz-pol-set.threshold"},
    {"auto-equip-armor",              "zzz-pol-set.auto-equip"},
    {"equip-respirator-when-respawn", "zzz-pol-set.respawn"},
}

local settings_desc = {"", {"tips-and-tricks-description.pollution-settings"}}
for _, s in ipairs(SETTINGS) do
    settings_desc[#settings_desc + 1] =
        {"", "\n• [font=default-bold]", {"mod-setting-name." .. s[1]}, "[/font] — ", {s[2]}}
end

data:extend({
    {type = "tips-and-tricks-item-category", name = CATEGORY, order = "c"},
    {
        type = "tips-and-tricks-item",
        name = "pollution-help",
        category = CATEGORY,
        is_title = true,
        tag = "[img=item/respirator]",
        localised_name = {"tips-and-tricks-name.pollution-help"},
        localised_description = {"tips-and-tricks-description.pollution-help"},
        order = "a",
        indent = 0,
        starting_status = "locked",
        trigger = {type = "research", technology = "armor-absorb-1"},
    },
    sub("pollution-protect", "b", "[img=virtual-signal/signal-yellow-gas-mask]"),
    {
        type = "tips-and-tricks-item",
        name = "pollution-settings",
        category = CATEGORY,
        tag = "[img=item/iron-gear-wheel]",
        localised_name = {"tips-and-tricks-name.pollution-settings"},
        localised_description = settings_desc,
        order = "c",
        indent = 1,
        starting_status = "locked",
        dependencies = {"pollution-help"},
        trigger = {type = "dependencies-met"},
    },
    sub("pollution-sos", "d", "[img=virtual-signal/signal-red-armor]"),
})
