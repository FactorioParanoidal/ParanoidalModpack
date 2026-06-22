--- First we changed something about player data so just destroy it completely.
--- Including the render objects. It will be recreated when the player selects a valve again.
for _, player_data in pairs(storage.players or { }) do
    if player_data.render_threshold then
        player_data.render_threshold.destroy()
    end
end
storage.players = { }

--- Now migrate all old legacy valves to the new engine-supported ones.
local migrator = require("__valves-lib__/scripts/migrator")
---@type string[]
local legacy_name_to_type = {"valves-overflow-legacy", "valves-top_up-legacy", "valves-one_way-legacy"}

for _, surface in pairs(game.surfaces) do
    for _, old_legacy_name in pairs(legacy_name_to_type) do
        local migration_data = migrator.old_valve_to_migration_data[old_legacy_name]
        assert(migration_data, "Migration data not found for " .. old_legacy_name)
        for _, old_valve in pairs(surface.find_entities_filtered{name = old_legacy_name}) do
            migrator.migrate(old_valve, migration_data)
        end
        for _, old_valve_ghost in pairs(surface.find_entities_filtered{name = "entity-ghost", ghost_name = old_legacy_name}) do
            migrator.migrate(old_valve_ghost, migration_data)
        end
    end
end