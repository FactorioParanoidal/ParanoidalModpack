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
    entry("0.1.3", function(env)
        for _, player in pairs(game.players) do
            local old_button = player.gui.top['inserter-throughput-toggle']
            if old_button then
                old_button.destroy()
            end
            env.init_toggle_button(player)
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
