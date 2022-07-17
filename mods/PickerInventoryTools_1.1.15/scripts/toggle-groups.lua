local Event = require('__stdlib__/stdlib/event/event')

local function set_group_options(index, ...)
    local player = game.players[index]
    local set = player.mod_settings
    for _, val in pairs({...}) do
        local func_name = val:find('subgroups') and 'recipe_subgroups' or 'recipe_groups'
        if set[val].value then
            player['enable_'..func_name]()
        else
            player['disable_'..func_name]()
        end
    end
end

local function on_init()
    for index in pairs(game.players) do
        set_group_options(index, 'picker-use-groups', 'picker-use-subgroups')
    end
end
Event.register(Event.core_events.init, on_init)

local function on_player_created(event)
    set_group_options(event.player_index, 'picker-use-groups', 'picker-use-subgroups')
end
Event.register(defines.events.on_player_created, on_player_created)

local function on_runtime_mod_setting_changed(event)
    local setting = event.setting
    if setting == 'picker-use-groups' or setting == 'picker-use-subgroups' then
        set_group_options(event.player_index, setting)
    end
end
Event.register(defines.events.on_runtime_mod_setting_changed, on_runtime_mod_setting_changed)
