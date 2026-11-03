if mods["angelsexploration"] then
    -- angels exploration takes care of this
else
    local map_settings = data.raw["map-settings"]["map-settings"]
    map_settings.pollution.enabled = true
    map_settings.enemy_evolution.enabled = true
    map_settings.enemy_expansion.enabled = true
    -- Дефолты Паранои 1.1: base/prototypes/map-settings.lua, поверх изменений Bob's Enemies 2.0.
    map_settings.enemy_evolution.time_factor = 4e-06
    map_settings.enemy_evolution.destroy_factor = 0.002
    map_settings.enemy_evolution.pollution_factor = 9e-07
    map_settings.enemy_expansion.min_expansion_cooldown = 60 * 60 * 4
    map_settings.enemy_expansion.max_expansion_cooldown = 60 * 60 * 60
    map_settings.enemy_expansion.settler_group_min_size = 5
    -- Factorio 2.1 (решение G21): ванильный максимум группы переселенцев 2.1 — 10 (в 2.0 было 20). В 2.1 размер группы =
    -- random(min, max) * evolution_group_size_factor ^ эволюция (ваниль: 8); сейвы 2.0 движок при загрузке сам ставит 10.
    map_settings.enemy_expansion.settler_group_max_size = 10
    map_settings.difficulty_settings.research_queue_setting = "always"
end

