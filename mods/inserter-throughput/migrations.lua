local mod_gui = require('mod-gui')
local get_mod_button_flow = mod_gui.get_button_flow

local function version(version_string)
    local major, minor, patch = string.match(version_string, '^(%d+)%.(%d+)%.(%d+)$')
    return (major * 65536 + minor) * 65536 + patch
end

local function entry(version_string, migration)
    return {
        version = version(version_string),
        migration = migration,
    }
end

local migrations = {
    entry('0.1.3', function(env)
        for _, player in pairs(game.players) do
            local old_button = player.gui.top['inserter-throughput-toggle']
            if old_button then
                old_button.destroy()
            end
            --env.init_toggle_button(player) -- part of a later migration now
        end
    end),
    entry('0.1.6', function(env)
        for _, player in pairs(game.players) do
            local old_button = get_mod_button_flow(player)['inserter-throughput-toggle']
            if old_button then
                old_button.destroy()
            end
            env.init_toggle_button(player)
        end
        for _, data in pairs(storage.player_data) do
            local text_id = data.text_id
            if text_id then
                data.text_object = rendering.get_object_by_id(text_id)
                data.text_id = nil
            end
        end
    end),
}

local function migrate(env, from)
    from = version(from)
    for i = 1, #migrations do
        local entry = migrations[i]
        if entry.version > from then
            entry.migration(env)
        end
    end
end

return migrate
