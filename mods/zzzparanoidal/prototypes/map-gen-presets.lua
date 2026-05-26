-- Кастомные пресеты "Новая игра" для ParanoidalModpack.
--
-- Соответствуют рекомендациям docs/Recommendations.md:
--   * Богатый старт ресурсами (Bob/Angels-цепочки прожорливые).
--   * "Богатый ресурсами"-style: frequency = normal, size = big,
--     richness = very-good для всех руд. С учётом того, что RSO
--     читает все три слайдера и применяет их множителями к своему
--     конфигу (mods/rso-mod/control.lua:1180-1233), настройки реально
--     влияют на размер/частоту/богатство залежей.
--   * "Paranoidal: без врагов" — peaceful_mode + enemy-base.size=none,
--     гнёзда не генерируются (Big-Monsters guard в этом случае тоже
--     отрабатывает, см. mods/Big-Monsters/control.lua: bm_peaceful_skip).
--
-- Имена пресетов локализованы в locale/*/locale.cfg секциями
-- [map-gen-preset-name] и [map-gen-preset-description].

local rich = { frequency = "normal", size = "big", richness = "very-good" }

-- Собираем все resource-autoplace-control'ы динамически, чтобы покрыть
-- vanilla + Angels + Bob + любые будущие моды без хардкода.
local rich_controls = {}
for name, ctrl in pairs(data.raw["autoplace-control"] or {}) do
    if ctrl.category == "resource" then
        rich_controls[name] = rich
    end
end

local function shallow_copy(t)
    local copy = {}
    for k, v in pairs(t) do copy[k] = v end
    return copy
end

-- Для пресета "без врагов" дополнительно выключаем спавн гнёзд.
local no_enemies_controls = shallow_copy(rich_controls)
no_enemies_controls["enemy-base"] = { frequency = "normal", size = "none", richness = "normal" }

-- В Factorio разрешён только один prototype-объект типа "map-gen-presets"
-- (см. ошибку "Only one map-gen-presets instance can be defined"), поэтому
-- расширяем существующий vanilla-объект "default". Структура:
-- пресеты лежат прямо в полях самого prototype-объекта (НЕ в подключе
-- presets), рядом с type/name. См. base/prototypes/map-gen-presets.lua.
local default = data.raw["map-gen-presets"] and data.raw["map-gen-presets"].default
if default then
    default["paranoidal"] = {
        order = "a-paranoidal",
        basic_settings = {
            property_expression_names = {},
            autoplace_controls = rich_controls,
        },
    }
    default["paranoidal-no-enemies"] = {
        order = "a-paranoidal-z",
        basic_settings = {
            property_expression_names = {},
            peaceful_mode = true,
            autoplace_controls = no_enemies_controls,
        },
    }
end
