if not mods['BotPrioritizer'] then
    data:extend{
        {
            type = 'bool-setting',
            name = 'picker-bp-prioritizer',
            setting_type = 'startup',
            default_value = true,
            order = 'picker[startup]-bp-prioritizer'
        }
    }
end
