# Wind Turbines (Reforged)

Локальный форк Paranoidal на основе [Wind Turbines (relaunched)](https://mods.factorio.com/mod/Wind-Turbines-relaunched) 2.2.5 (MIT, см. `LICENSE`). Формула ветра взята из `Texugo_windgenerator` 9.17.0 (Texugo Maldito & Yur_Ra) сборки Beta 8.

- Три тира: `texugo-wind-turbine`, `texugo-wind-turbine2`, `texugo-wind-turbine3`. Имена прототипов прежние, поэтому сейвы с relaunched и миграция `EasyWindTurbine*` из zzzparanoidal продолжают работать.
- Ветер: каждые 61 тик `x += random/2`, `y = 1.5 + Σ sin(x/k)` для k = 2, 3, 5, 7, 11, 13, 17, 19, 23, 29; шум `t = 0.99t + random − 0.5`, `z = 0.9z + 0.1t`. «Температура» `T = 14(y + 0.8z + 3)`, доля мощности `clamp((T − 15)/85, 0, 1)`. Скорость ветра на экране: `max(0, 3 + (T − 15)·9/85)` м/с.
- Полная мощность 67,5 кВт / 675 кВт / 6,75 МВт × `quality.default_multiplier`.
- Скрытые столбы `twt-electric-pole*` (провод 6/11/18) и неразрушаемое основание `twt-collision-rect*` создаются скриптом. При загрузке и при изменении модов реестр турбин пересобирается по карте.
- Гигантская турбина T4, режимы ветра, настройки и интеграции Krastorio 2 и Space Age удалены. Сущности T4 из старых сейвов движок удалит при загрузке.
