local migration = require("__flib__.migration")

---comment
---@param version string | nil
local function parse_version(version)
    if version then
        local _, _, major, minor, patch = string.find(version, '([0-9]+)[.]([0-9]+)[.]([0-9]+)')
        return tonumber(major), tonumber(minor), tonumber(patch)
    end
    return nil, nil, nil
end

local function on_configuration_changed(event)
    if event.mod_changes[MergingChests.mod_name] then
        local old_major, old_minor, old_patch = parse_version(event.mod_changes[MergingChests.mod_name].old_version)
        local new_major, new_minor, new_patch = parse_version(event.mod_changes[MergingChests.mod_name].new_version)
        if old_major == 4 and new_major == 5 then
            for _, surface in pairs(game.surfaces) do
                for _, entity in ipairs(surface.find_entities()) do
                    surface.create_entity({
                        name = '',
                        position = entity.position
                    })
                    entity.destroy({ raise_destroy = true })
                end
            end
        end
    end
end

local function migrate_5_0_0(event)
    local name_map = {
        ['old'] = 'new'
    }
    --MergingChests.get_mod_settings('wooden-chest').max_width

    for _, surface in pairs(game.surfaces) do
        for _, entity in ipairs(surface.find_entities()) do
            local new_name = name_map[entity.name]
            if new_name then
                local new_entity = surface.create_entity({
                    name = new_name,
                    position = entity.position,
                    force = entity.force,
                    player = entity.player
                })

                MergingChests.move_inventories({ entity }, { new_entity })
                MergingChests.reconnect_circuits({ entity }, { new_entity })

                entity.destroy({ raise_destroy = true })
            end
        end
    end

    game.print('Migrated merged chests longer than 42 by lua script')
end

-- https://github.com/factoriolib/flib/blob/master/migration.lua
--migration.handle_on_configuration_changed({
--    ['5.0.0'] = migrate_5_0_0
--})
