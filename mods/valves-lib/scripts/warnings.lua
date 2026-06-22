local config = require("__valves-lib__.config")

-- This functionionality is to warn the player that there is unintended behaviour
-- when a valve's output is connected to a pump's input. In this scenario the pump
-- will pull fluid regardless of the fluid levels or the pump's threshold.
-- According to raiguard thiss is not intended behaviour by the game engine
-- but a limitation due to how fluidboxes are created for different entities.
-- I created a poll on the Py Discord to ask if I should show a warning or just destroy
-- the valve, and out of 134 votes 87% of players only wanted a non-destructive warning.
-- So we will only show a warning.


local warnings = { }

---@param fluidbox LuaFluidBox
---@param flow_direction "input"|"output"
---@param target_specifier {type:string?, names:table<string,boolean>?, entity:LuaEntity?}
---@return LuaFluidBox? connected_fluidbox to the fluidbox
local function fluidbox_is_connected_to(fluidbox, flow_direction, target_specifier)
    -- Both valves and pumps only have one fluidbox.
    for _, pipe_connection in pairs(fluidbox.get_pipe_connections(1)) do
        if pipe_connection.flow_direction == flow_direction then
            local target = pipe_connection.target
            if not target then goto continue end
            local owner = target.owner

            if target_specifier.type then
                if owner.type == target_specifier.type then
                    return target
                end

            elseif target_specifier.names then
                if target_specifier.names[owner.name] then
                    return target
                end

            elseif target_specifier.entity then
                if owner == target_specifier.entity then
                    return target
                end

            else
                -- Should never happen
                error("Invalid target_specifier: " .. serpent.block(target_specifier))
            end

            ::continue::
        end
    end
end

---@param valve LuaEntity
---@return boolean? true if the valve's output is connected to a pump's input
local function valve_has_bad_connection(valve)
    local pump_fluidbox = fluidbox_is_connected_to(valve.fluidbox, "output", {type = "pump"})
    if not pump_fluidbox then return end -- Not connected to a pump
    -- Now ensure we're connected to the pump's _input_
    return fluidbox_is_connected_to(pump_fluidbox, "input", {entity = valve}) ~= nil
end

---@param pump LuaEntity
---@return boolean? true if the pump's input is connected to a valves's output
local function pump_has_bad_connection(pump)
    local valve_fluidbox = fluidbox_is_connected_to(pump.fluidbox, "input", {names = config.valves})
    if not valve_fluidbox then return end -- Not connected to a valve
    -- Now ensure we're connected to the valve's _input_
    return fluidbox_is_connected_to(valve_fluidbox, "output", {entity = pump}) ~= nil
end

-- Generate nice handlers for all our valves and all pumps when might need to deal with.
local handler_for_name = { }
for valve_name, _ in pairs(config.valves) do
    handler_for_name[valve_name] = valve_has_bad_connection
end
for pump_name, prototype in pairs(prototypes.get_entity_filtered({{filter = "type", type = "pump"}})) do
    if not prototype.hidden then
        handler_for_name[pump_name] = pump_has_bad_connection
    end
end

---@param player LuaPlayer?
---@param entity LuaEntity the valve or pump
---@param has_bad_connection_handler function
local function handle_possible_bad_connection(player, entity, has_bad_connection_handler)
    local has_bad_connection = has_bad_connection_handler(entity)
    if not has_bad_connection then return end

    -- We've got a bad connection! Let's warn the player.

    if player then
        player.play_sound{ path = "utility/cannot_build" }
        player.create_local_flying_text{
            text = {"valves.flying-warning-bad-connection"},
            position = entity.position,
            surface = entity.surface,
            color = {r = 1, g = 0, b = 0},
            speed = 0.7,
            time_to_live = 120,
        }
    else
        entity.force.play_sound{ path = "utility/cannot_build" }
        entity.force.print({"valves.warn-all-found-extended", 1})
        entity.force.print({"valves.warn-found-at","[entity="..entity.name.."]", entity.gps_tag})
    end
end

---@param event EventData.on_robot_built_entity|EventData.on_built_entity|EventData.script_raised_built|EventData.script_raised_revive
local function on_entity_created(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end

    local player = event.player_index and game.get_player(event.player_index) or nil
    if handler_for_name[entity.name] then
        handle_possible_bad_connection(player, entity, handler_for_name[entity.name])
    elseif entity.name == "entity-ghost" and handler_for_name[entity.ghost_name] then
        handle_possible_bad_connection(player, entity, handler_for_name[entity.ghost_name])
    end
end

---@param event EventData.on_player_rotated_entity
local function on_player_rotated_entit(event)
    local entity = event.entity
    if not (entity and entity.valid) then return end

    local player = game.get_player(event.player_index) ---@cast player -?
    if handler_for_name[entity.name] then
        handle_possible_bad_connection(player, entity, handler_for_name[entity.name])
    elseif entity.name == "entity-ghost" and handler_for_name[entity.ghost_name] then
        handle_possible_bad_connection(player, entity, handler_for_name[entity.ghost_name])
    end
end

---@param force ForceID
---@return LuaEntity[]
local function find_all_bad_connections(force)
    ---@type string[]
    local valve_name_to_type_list = {}
    for name, _ in pairs(config.valves) do
        table.insert(valve_name_to_type_list, name)
    end

    ---@type LuaEntity[]
    local bad_valves = {}
    for _, surface in pairs(game.surfaces) do
        for _, valve in pairs(surface.find_entities_filtered({name = valve_name_to_type_list, force = force})) do
            if valve_has_bad_connection(valve) then
                table.insert(bad_valves, valve)
            end
        end
    end

    return bad_valves
end

function warnings.add_commands()
    commands.add_command("valves-find-bad-connections", {"valves.warn-command-help"}, function(command)
        local player = game.get_player(command.player_index) ---@cast player -?
        local bad_valves = find_all_bad_connections(player.force)
        if #bad_valves == 0 then
            player.print({"valves.warn-all-found-none"})
        else
            player.print({"valves.warn-all-found", #bad_valves})
            for _, valve in pairs(bad_valves) do
                player.print({"valves.warn-found-at","[entity="..valve.name.."]", valve.gps_tag})
            end
        end
    end)
end

function warnings.on_configuration_changed()
    for _, force in pairs(game.forces) do
        local bad_valves = find_all_bad_connections(force)
        if #bad_valves > 0 then
            force.print({"valves.warn-all-found-extended", #bad_valves})
            for _, valve in pairs(bad_valves) do
                force.print({"valves.warn-found-at","[entity="..valve.name.."]", valve.gps_tag})
            end
            force.print({"valves.warn-show-again"})
        end
    end
end

warnings.events = {
    [defines.events.on_robot_built_entity] = on_entity_created,
    [defines.events.on_built_entity] = on_entity_created,
    [defines.events.script_raised_built] = on_entity_created,
    [defines.events.script_raised_revive] = on_entity_created,
    [defines.events.on_space_platform_built_entity] = on_entity_created,
    [defines.events.on_player_rotated_entity] = on_player_rotated_entit,
}

return warnings