
local migrator = { }

---Valve types that we support based on the old way that I
---defined them.
---@alias MyValveType "overflow" | "top_up" | "one_way"

---The get threshold function should return a number between 0 and 1, or nil if it doesn't exist.
---@alias GetThresholdFunction fun(entity: LuaEntity, name: string, valve_type: MyValveType): number?

---@class MigrationData
---@field valve_type MyValveType
---@field get_threshold GetThresholdFunction
---@field invert_direction boolean?

---Get the threshold for an old valve entity, or it's ghost.
---@type GetThresholdFunction
local determine_threshold_for_type = {
    ["legacy-valves"] = function (entity, valve_type)
        local control_behaviour = entity.get_or_create_control_behavior()
        ---@cast control_behaviour LuaPumpControlBehavior
        local circuit_condition = control_behaviour.circuit_condition --[[@as CircuitCondition]]
        local threshold = circuit_condition.constant
        if not threshold then return end
        threshold = threshold / 100 -- Convert to a fraction which the new system uses
        return math.min(1, math.max(0, threshold)) -- Clamp to 0-1
    end,
}

---@type table<string, MigrationData>
migrator.old_valve_to_migration_data = {
    ["valves-overflow-legacy"]  = {valve_type="overflow",   get_threshold=determine_threshold_for_type["legacy-valves"]},
    ["valves-top_up-legacy"]    = {valve_type="top_up",     get_threshold=determine_threshold_for_type["legacy-valves"]},
    ["valves-one_way-legacy"]   = {valve_type="one_way",    get_threshold=determine_threshold_for_type["legacy-valves"]},
}

---@param entity LuaEntity
---@return MigrationData?
function migrator.should_migrate(entity)
    local name = entity.name
    local migration_data = migrator.old_valve_to_migration_data[name]
    if migration_data then return migration_data end
    if name ~= "entity-ghost" then return end
    return migrator.old_valve_to_migration_data[entity.ghost_name]
end

---@param old_valve LuaEntity
---@param valve_type MyValveType
---@return LuaEntity? new_valve
function migrator.replace_valve_entity(old_valve, valve_type)
    local surface = old_valve.surface
    local position = old_valve.position
    local direction = old_valve.direction
    local force = old_valve.force
    local health = old_valve.health
    local quality = old_valve.quality
    local to_be_deconstructed = old_valve.to_be_deconstructed()
    local is_ghost = old_valve.name == "entity-ghost"

    -- We need to destroy the old one first so that the fluid connections
    -- so are recreated correctly I think.
    old_valve.destroy{raise_destroy = true} -- Tell other mods, we don't listen anyway

    local new_valve = surface.create_entity{
        name = is_ghost and "entity-ghost" or "valves-" .. valve_type,
        inner_name = is_ghost and "valves-" .. valve_type or nil,
        position = position,
        force = force,
        direction = direction,
        quality = quality,
        raise_built = true, -- We listen to this, but doesn't really matter
    }
    if not new_valve then return end -- Something went wrong. Meh
    if is_ghost then return new_valve end -- Nothing left to do.

    new_valve.health = health
    if to_be_deconstructed then new_valve.order_deconstruction(force) end -- Will lose player and undo queue. Meh
    return new_valve
end

---@param old_valve LuaEntity
---@param migration_data MigrationData
function migrator.migrate(old_valve, migration_data)
    local valve_type = migration_data.valve_type
    local threshold = migration_data.get_threshold(old_valve, old_valve.name, valve_type)
    local new_valve = migrator.replace_valve_entity(old_valve, valve_type)
    if new_valve and valve_type ~= "one_way" then
        new_valve.valve_threshold_override = threshold
    end
end

return migrator