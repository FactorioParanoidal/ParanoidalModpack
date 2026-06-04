# check_updates.py — проверка обновлений модов

Скрипт сравнивает версии модов сборки (`mods/`) с актуальными версиями на
[Factorio Mod Portal](https://mods.factorio.com/) и показывает, для каких модов
есть свежие релизы. Опционально подтягивает changelog от текущей версии до актуальной.

- **Зависимости:** только стандартная библиотека Python 3 (`urllib`, `concurrent.futures`). Ставить ничего не нужно.
- **API-ключ:** не требуется — читающие эндпоинты портала публичны.
- **Расположение:** `tools/check_updates.py`. Папку с модами скрипт находит сам (`<repo>/mods`), её можно переопределить флагом `--mods-dir`.

## Запуск

```bash
# из корня репозитория — проверить все моды сборки под Factorio 2.0
python3 tools/check_updates.py --target 2.0

# то же, но с changelog для каждого апдейта
python3 tools/check_updates.py --target 2.0 --changelog

# проверить реально установленные моды в игре (живая папка Factorio)
python3 tools/check_updates.py --target 2.0 \
    --mods-dir "~/Library/Application Support/factorio/mods"
```

## Флаги

| Флаг | Назначение |
|------|------------|
| (без флагов) | Проверяет все моды в `mods/`, цель — `factorio_version` каждого мода. |
| `--target 2.0` | Форсит целевую версию игры — апдейты ищутся только среди релизов под неё (1.1-версии не предлагаются для 2.0-сборки). |
| `--changelog` | Для каждого апдейта печатает блоки changelog в диапазоне «текущая версия (не включая) → актуальная (включая)». Использует эндпоинт `/full`. |
| `--all` | Дополнительно показывает up-to-date и not-found моды. |
| `--mods-dir PATH` | Папка с модами (по умолчанию `<repo>/mods`). Удобно для проверки живой установки игры. |
| `--from-list` | Источник — `mod-list.json` (если есть в папке модов), включая записанные, но не скачанные моды. В репе `mod-list.json` нет, поэтому флаг тут игнорируется. |
| `--enabled-only` | Только моды с `enabled: true` в `mod-list.json` (требует `mod-list.json`). |

Флаги комбинируются.

## Как это работает

1. Локальная версия берётся из `info.json` каждой папки мода (поле `version`).
2. Запрашивается портал: `https://mods.factorio.com/api/mods/<name>` (или `/full` при `--changelog`), 12 параллельных потоков.
3. Из релизов выбирается самый свежий с подходящей `factorio_version`; если таких нет — самый свежий вообще.
4. Версии сравниваются как кортежи чисел (`1.0.10` < `1.0.12`).
5. Wube-моды (`base`, `space-age`, `quality`, `elevated-rails`) пропускаются — их на портале нет.

Категории в выводе:
- `⬆️ Updates available` — есть свежее.
- `📥 In list but not installed` — мод записан в `mod-list.json`, но папки нет (только с `--from-list`).
- `❓ Not on portal / no matching release` — кастомные/локальные моды сборки (`zzz*`, `toxicPollution2` и т.п.) или без релиза под целевую версию.
- `⚠️ Errors` — сетевые ошибки.

## Пример вывода

Без changelog:

```
Mods dir: /Users/mitrofanov/Projects/ParanoidalModpack/mods
Checking 156 mods against the portal...

⬆️  Updates available (46):
  AutoDeconstruct                 1.0.10  →  1.0.12        (FA 2.0)
  Clowns-Processing               2.0.13  →  2.0.14        (FA 2.0)
  FactorySearch                   1.14.0  →  1.14.1        (FA 2.0)
  HeroTurretRedux                 1.0.32  →  1.0.38        (FA 2.0)
  boblogistics                     2.0.6  →  2.1.1         (FA 2.0)
  prismatic-belts                 2.0.10  →  3.0.3         (FA 2.0)
  ...

❓ Not on portal / no matching release (5):
  (use --all to list; e.g. local-only or renamed mods)
```

С `--changelog`:

```
⬆️  Updates available (46):
  AutoDeconstruct                 1.0.10  →  1.0.12        (FA 2.0)
        Version: 1.0.12
        Date: 2026-02-26
          Bugfixes:
            - Hotfix for crash introduced in previous update.
        Version: 1.0.11
        Date: 2026-02-22
          Changes:
            - Updated translations from Crowdin.
          Bugfixes:
            - Fixed that automatic pipe selection would not look at tile and pipe collision masks.

  Clowns-Processing               2.0.13  →  2.0.14        (FA 2.0)
        Version: 2.0.14
        Date: 2026-05-02
          Bugfixes:
            - Reverted sulfuric acid to vanilla
            - Updated tech icon size
```

## Ограничения

- Скрипт только **сообщает** об апдейтах — он ничего не скачивает и не меняет файлы модов.
- Для модов не с портала changelog недоступен (выводится `(no changelog entries for this range)`).
- Даты в changelog приходят в том формате, в каком их написал автор мода (единого формата у портала нет).
