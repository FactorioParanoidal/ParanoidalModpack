# Патчи в сторонних модах

Список локальных правок, наложенных на вендорные сторонние моды (всё, что лежит в `mods/` и не наше). Нужен, чтобы при апдейте мода знать: что именно мы патчили и можно ли уже снять патч (если апстрим починил).

## Формат записи

Каждый патч описывается блоком:

- **Мод** — имя папки в `mods/`.
- **Версия на момент патча** — из `info.json` мода.
- **Файл и строка** — где правили.
- **Симптом** — как баг проявляется в игре.
- **Суть патча** — одной строкой что меняем.
- **PR** — ссылка на PR в этом репозитории, в рамках которого патч был наложен.
- **Статус** — `активен` / `можно снять (апстрим починил в X.Y.Z)` / `постоянный (наша спец. логика)`.

При обновлении мода:
1. Сравнить новую версию мода со «версией на момент патча».
2. Проверить, ушёл ли затронутый код / починили ли симптом.
3. Если да — удалить патч из мода и запись из этого файла. Если нет — переналожить патч на новую версию и обновить «версию на момент патча».

---

## Патчи

### Big-Monsters: guard на peaceful-режим

- **Мод:** `Big-Monsters` (автор MFerrari).
- **Версия на момент патча:** 2.1.2.
- **Файл и строка:**
  - `mods/Big-Monsters/control.lua` — helper `bm_peaceful_skip` после `require`-блока; вызов в `CreateNewEvent` сразу после проверки force/surface; вызов в `Create_Position_Event` после проверки `surface.valid`; вызов в `Call_next_wave` внутри цикла по `attacks`; вызов в `On_Built` перед прямым `CallFrenzyAttack` (атака при постройке rocket-silo).
  - `mods/Big-Monsters/settings.lua` — определение `bm-events-when-peaceful` (runtime-global bool, default `false`).
  - `mods/Big-Monsters/locale/en/en.cfg` — `mod-setting-name` и `mod-setting-description` для настройки.
  - `mods/Big-Monsters/locale/ru/ru.cfg` — **новый файл** (в апстриме папки `ru/` нет), RU-локаль для настройки.
- **Симптом:** на peaceful-сёрфейсах Big-Monsters всё равно спавнит swarm / invasion / volcano / biterzilla / human soldiers и шлёт красные алерты в чат, независимо от `surface.peaceful_mode` карты.
- **Суть патча:** `bm_peaceful_skip(surface)` возвращает `true` если `surface.peaceful_mode` или `map_gen_settings.autoplace_controls["enemy-base"].size == 0`; на «true» event-функции делают ранний `break`/`return`. Перебивается runtime-настройкой `bm-events-when-peaceful` для редкого сценария «играем peaceful по ванилле, но скриптовые сюрпризы Big-Monsters хочу оставить».
- **PR:** [#220](https://github.com/FactorioParanoidal/ParanoidalModpack/pull/220).
- **Статус:** активен. Аналогичный патч был в 1.1-сборке; при порте мода MFerrari на 2.0 проверки потерялись, upstream-патч пока не отправлен.

Полный апстрим-ready diff: `git diff master..fix/big-monsters-peaceful-mode-guard -- mods/Big-Monsters/` или см. PR-changes.
