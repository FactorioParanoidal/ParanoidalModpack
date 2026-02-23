-- Remote interfaces

local this = {}

-- Returns the version of this remote API
-- Usage example: remote.call("even-distribution", "version")
function this.version()
    return 1
end

-- Add an entity to be ignored by CTRL+Click Drag and SHIFT+C
-- Usage example: remote.call("even-distribution", "add_ignored_entity", "wooden-chest")
function this.add_ignored_entity(entity)
    storage.remoteIgnoredEntities = storage.remoteIgnoredEntities or {}
    storage.remoteIgnoredEntities[entity] = true
end

-- Remove an entity from the ignored list
-- Usage example: remote.call("even-distribution", "remove_ignored_entity", "wooden-chest")
function this.remove_ignored_entity(entity)
    storage.remoteIgnoredEntities = storage.remoteIgnoredEntities or {}
    storage.remoteIgnoredEntities[entity] = nil
end

-- Get the list of ignored entities
-- Usage example: remote.call("even-distribution", "get_ignored_entities")
--                  --> { ["wooden-chest"] = true, ["steel-chest"] = true }
function this.get_ignored_entities()
    return storage.remoteIgnoredEntities or {}
end

-- Get the configured fuel limit.
-- Usage example: remote.call("even-distribution", "get_fuel_limit", game.players[1])
--                  --> { limit = 0.5, type = "stacks" }
function this.get_fuel_limit(player)
    local settings = storage.settings[player.index]

    return {
        limit = settings.fuelLimit,
        type  = settings.fuelLimitType,
    }
end

-- Get the configured ammo limit.
-- Usage example: remote.call("even-distribution", "get_ammo_limit", game.players[1])
--                  --> { limit = 10, type = "items" }
function this.get_ammo_limit(player)
    local settings = storage.settings[player.index]

    return {
        limit = settings.ammoLimit,
        type  = settings.ammoLimitType,
    }
end

remote.add_interface("even-distribution", 
        {
            version               = this.version,
            add_ignored_entity    = this.add_ignored_entity,
            remove_ignored_entity = this.remove_ignored_entity,
            get_ignored_entities  = this.get_ignored_entities,
            get_fuel_limit        = this.get_fuel_limit,
            get_ammo_limit        = this.get_ammo_limit,
        }
)

return this
