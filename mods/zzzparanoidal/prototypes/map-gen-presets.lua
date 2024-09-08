if mods["angelsexploration"] then
    -- angels exploration takes care of this
else
    local map_settings = data.raw["map-settings"]["map-settings"]
    map_settings.pollution.enabled = true
    map_settings.enemy_evolution.enabled = false
    map_settings.enemy_expansion.enabled = true
    map_settings.difficulty_settings.research_queue_setting = "always"
end
