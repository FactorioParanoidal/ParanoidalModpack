# Описания модов

Канонический каталог описаний находится в [`mods-metadata/!descriptions.json`](../mods-metadata/!descriptions.json).

Файл является JSON-объектом: ключ - точное внутреннее имя мода из поля `name` его `mods/<папка>/info.json`, значение - непустое русское описание. Значения допускают Markdown и переводы строк `\n`.

```json
{
  "aai-industry": "Краткое описание мода.",
  "zzzparanoidal": "Описание основного мода сборки."
}
```

Не добавляйте записи для отсутствующих модов и не используйте отображаемое название из `title` вместо `name`. Проверка `build.cmd CheckModProvenance` валидирует JSON, непустые описания и соответствие каждого ключа моду в `mods/`: учитываются все папки и ZIP-архивы с `info.json`, в том числе моды, выключенные в `mod-list.json`.

В игре описание в меню «Моды» берётся из секции `[mod-description]` файла `mods/ParanoidalLocale/locale/ru/zzzz-user-overrides.cfg`; тексты каталога и этой секции совпадают. Если у мода есть собственная `locale/ru` с `[mod-name]` или `[mod-description]`, там тот же текст, что в ParanoidalLocale.
