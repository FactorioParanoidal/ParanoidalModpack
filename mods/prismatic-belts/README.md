# Изменения Paranoidal в Prismatic Belts (upstream 3.0.4)

Временный локальный portal-патч поверх Prismatic Belts 3.0.4 (Kirazy, MIT). Версия мода не менялась.
Описание для проверки происхождения: `mods-metadata/prismatic-belts.json`. Ничего не опубликовано.

Синхронизация графики лент между прототипами, запечённые листы лент Bob и скорости лент
Factorissimo сделаны не здесь, а в `zzzparanoidal` (см. `zzzparanoidal/README.md`, раздел
«Prismatic Belts»).

## Изменения (2026-10-14)

| Файл | Было | Стало |
|---|---|---|
| `prototypes/api.lua`, `normalize_tint` | Цвет считался заданным в 0–255 только при компоненте `> 255`; при отсутствии альфы `tint.a / 255` падал с ошибкой `nil`. В обычном случае функция возвращала `a = nil` | Как в движке: 0–255, если любой компонент `> 1`; отсутствующая альфа не делится, по умолчанию 1 |
| `prototypes/api.lua`, `get_animation_set_identity` | Наборы анимации сравнивались по хэшу djb2 строки «файл + цвет + скорость» (теоретически возможны совпадения); слой без `filename` давал дыру в списке, и `table.concat` падал | Сравнивается сама строка; слои без файла пропускаются без дыр. Логика (включая скорость в ключе) не изменена |
| `prototypes/api.lua`, остатки ленты | Название созданного остатка — жёстко заданный английский суффикс `" (remnant)"` | Ключ локализации `prismatic-belts.remnants-name` (`locale/en`, `locale/ru`) |
| `prototypes/mods/bobs.lua` | Подмена графики лент Bob вызывалась без параметров иконки: иконки AAI-погрузчиков basic/turbo/ultimate оставались без цветного слоя ленты (у обычного/быстрого/экспресс он был) | Передаётся `mask_tint`; все шесть AAI-погрузчиков получают одинаковую вставку |
| `prototypes/mods/more-belts-final-fixes.lua` | `if not belt and splitter and lane_splitter then return end` — из-за приоритета операторов проверка не защищала от отсутствующих прототипов | `if not (belt and splitter and lane_splitter) then` |
| `locale/en`, `locale/ru` | — | Раздел `[prismatic-belts]`, ключ `remnants-name` |

В текущей сборке остатки Prismatic не создаёт (у всех лент есть свои `*-remnants`), а ветки
`normalize_tint` с `base_tint` и `more-belts` не выполняются: эти три правки — защита на будущее.
Проверено дампом прототипов 2.0.77: иконки `aai-basic/turbo/ultimate-loader` (сущность и предмет)
содержат слои `transport-belt-icon-base/mask/highlights`; ошибок загрузки нет.

## При обновлении мода

1. Сравнить новую версию с этим списком: если автор исправил пункт, взять его вариант.
2. Неисправленные пункты перенести заново, обновить `upstreamVersion` и `changeReason` в
   `mods-metadata/prismatic-belts.json`.
3. Если автор поменяет пути или размеры `graphics/entity/standard/transport-belt-*`, перезапечь листы
   (`zzzparanoidal/graphics/entity/prismatic-baked/bake.py`) и проверить журнал `[prismatic-sync]`.

## Отчёт автору (черновик, не отправлен)

> Prismatic Belts 3.0.4, a few small issues found while integrating it in a large modpack:
>
> 1. `normalize_tint` (api.lua) only rescales 0–255 colors when a component is `> 255`; Factorio's
>    rule is `> 1`. When it does rescale, `tint.a / 255` errors if `a` is absent.
> 2. `more-belts-final-fixes.lua`: `if not belt and splitter and lane_splitter` parses as
>    `(not belt) and ...`; probably meant `not (belt and splitter and lane_splitter)`.
> 3. `bobs.lua` calls `apply_belt_animation_set_and_update_related_connectables` without
>    `icon_inputs`, so AAI basic/turbo/ultimate loaders don't get the belt icon patch.
> 4. The created remnants use a hard-coded English `" (remnant)"` suffix instead of a locale key.
> 5. `get_animation_set_identity` hashes the key with djb2 (collision-prone and unnecessary: the
>    string can be compared directly); a layer without `filename` leaves a hole for `table.concat`.
> 6. Belts copied before `data-updates` (e.g. a mod deep-copying `underground-belt` in `data`, or
>    Factorissimo's linked belts) keep the vanilla sheets, because the identity includes the speed
>    and the source belt speed may change later (Bob's belt speed setting). The vanilla sheets then
>    stay in the atlas in addition to the Prismatic copies.
