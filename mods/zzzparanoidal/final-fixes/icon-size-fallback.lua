-- Fallback для multi-icon `icons[]`-записей без per-entry icon-полей.
--
-- Контекст: раньше эту работу делал osm-lib-postprocess в собственном
-- data-final-fixes (data-core.lua: index_icons). Он проходил по всем
-- prototype'ам с `icons[]` и дописывал недостающие поля каждой записи
-- из outer-значений самого prototype'а. Без этого Factorio 2.0 при
-- загрузке таких icons[] использует дефолтный icon_size = 64; если
-- фактический PNG другого размера — мод не загружается с ошибкой
-- "given sprite rectangle outside actual sprite size".
--
-- После удаления osm-lib-postprocess (см. PR #221) эта защита пропала.
-- Восстанавливаем её локально, чтобы битые multi-icon-записи в
-- Bob/Angels/Clowns/extended-remelting-fixed не валили сборку.
--
-- Логика: для каждой записи `icons[i]` без своего значения для поля X
-- проставляем outer `prototype.X`. Если outer тоже не задан — запись
-- пропускаем. Покрываем тот же набор полей, что osm-pp:
-- icon_size, icon_mipmaps, scale, tint, shift.

local FIELDS = { "icon_size", "icon_mipmaps", "scale", "tint", "shift" }

local function patch_one(proto)
    if not proto.icons then return end
    for _, icon_entry in pairs(proto.icons) do
        for _, field in ipairs(FIELDS) do
            if icon_entry[field] == nil and proto[field] ~= nil then
                icon_entry[field] = proto[field]
            end
        end
    end
end

-- Перебираем все типы прототипов в data.raw — поведение osm-pp
-- (он бежал по всем prototype'ам без фильтра).
for _, list in pairs(data.raw) do
    if type(list) == "table" then
        for _, proto in pairs(list) do
            if type(proto) == "table" then
                patch_one(proto)
            end
        end
    end
end
