local config = require("__valves-lib__.config")
local migrator = require("__valves-lib__.scripts.migrator")

local builder = { }

---@param valve LuaEntity
---@param valve_config ValveConfig
function builder.build(valve, valve_config)
    if valve_config.valve_mode ~= "overflow" and valve_config.valve_mode ~= "top-up" then return end

    -- We will set the valve's current threshold as the override
    -- threshold. That way if the player ever changes their default
    -- thresholds then it won't affect _all_ the already placed valves.
    -- This won't affect valves that already have overrides
    valve.valve_threshold_override = valve.valve_threshold_override
end

---@param entity LuaEntity
---@return ValveConfig?
function builder.get_useful_valve_config(entity)
    local valve_config = config.valves[entity.name]
    if valve_config then return valve_config end

    if entity.name ~= "entity-ghost" then return end
    valve_config = config.valves[entity.ghost_name]
    if valve_config then return valve_config end
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function on_entity_created(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end

    local valve_config = builder.get_useful_valve_config(entity)
    if valve_config then
        builder.build(entity, valve_config)
    end

    -- Also migrate legacy blueprints when placed.
    local migration_data = migrator.should_migrate(entity)
    if migration_data then migrator.migrate(entity, migration_data) end
end

builder.events = {
    [defines.events.on_robot_built_entity] = on_entity_created,
    [defines.events.on_built_entity] = on_entity_created,
    [defines.events.script_raised_built] = on_entity_created,
    [defines.events.script_raised_revive] = on_entity_created,
    [defines.events.on_space_platform_built_entity] = on_entity_created,
}

return builder