---@type table<string, number|false> valve name -> prototype default threshold; false for one-way
local valves = {}
for _, valve in ipairs(require("config")) do
    local prototype = prototypes.entity[valve.name]
    valves[valve.name] = prototype.valve_mode ~= "one-way" and prototype.valve_threshold or false
end

---@param entity LuaEntity
---@return string name of the entity, or of the entity in the ghost
local function real_name(entity)
    local name = entity.name
    return name == "entity-ghost" and entity.ghost_name or name
end

--------------------------------------------------------------------------------
-- Bad connections: a pump whose input is connected to a valve output bypasses
-- the valve (engine limitation, confirmed by raiguard). Only warn: 87% of
-- 134 votes on the Py Discord wanted a warning instead of destroying the valve.

---@param fluidbox LuaFluidBox
---@param flow_direction "input"|"output"
---@param matches fun(owner: LuaEntity): boolean
---@return LuaFluidBox? target fluidbox reached through a connection of this direction
local function connected(fluidbox, flow_direction, matches)
    -- Both valves and pumps have exactly one fluidbox.
    for _, connection in pairs(fluidbox.get_pipe_connections(1)) do
        local target = connection.target
        if target and connection.flow_direction == flow_direction and matches(target.owner) then return target end
    end
end

---@param a LuaEntity
---@param out_dir "input"|"output" direction of `a` towards `b`
---@param is_b fun(owner: LuaEntity): boolean
---@param in_dir "input"|"output" direction of `b` back towards `a`
local function linked(a, out_dir, is_b, in_dir)
    local target = connected(a.fluidbox, out_dir, is_b)
    return target ~= nil and connected(target, in_dir, function(owner) return owner == a end) ~= nil
end

local function is_pump(owner) return owner.type == "pump" end
local function is_valve(owner) return valves[owner.name] ~= nil end
local function valve_is_bad(valve) return linked(valve, "output", is_pump, "input") end
local function pump_is_bad(pump) return linked(pump, "input", is_valve, "output") end

---@type table<string, fun(entity: LuaEntity): boolean>
local bad_connection_check = {}
for name in pairs(valves) do bad_connection_check[name] = valve_is_bad end
for name, prototype in pairs(prototypes.get_entity_filtered{ { filter = "type", type = "pump" } }) do
    if not prototype.hidden then bad_connection_check[name] = pump_is_bad end
end

---@param receiver LuaForce|LuaPlayer
---@param bad LuaEntity[]
local function print_bad(receiver, bad)
    for _, valve in pairs(bad) do
        receiver.print{ "valves.warn-found-at", "[entity=" .. valve.name .. "]", valve.gps_tag }
    end
end

---@param entity LuaEntity
---@param player LuaPlayer?
local function check_connection(entity, player)
    local check = bad_connection_check[real_name(entity)]
    if not (check and check(entity)) then return end
    if player then
        player.play_sound{ path = "utility/cannot_build" }
        player.create_local_flying_text{
            text = { "valves.flying-warning-bad-connection" },
            position = entity.position,
            surface = entity.surface,
            color = { r = 1, g = 0, b = 0 },
            speed = 0.7,
            time_to_live = 120,
        }
    else
        entity.force.play_sound{ path = "utility/cannot_build" }
        entity.force.print{ "valves.warn-all-found-extended", 1 }
        print_bad(entity.force, { entity })
    end
end

local valve_names = {}
for name in pairs(valves) do valve_names[#valve_names + 1] = name end

---@param force ForceID
---@return LuaEntity[]
local function find_bad_valves(force)
    local bad = {}
    for _, surface in pairs(game.surfaces) do
        for _, valve in pairs(surface.find_entities_filtered{ name = valve_names, force = force }) do
            if valve_is_bad(valve) then bad[#bad + 1] = valve end
        end
    end
    return bad
end

commands.add_command("valves-find-bad-connections", { "valves.warn-command-help" }, function(command)
    local player = game.get_player(command.player_index) ---@cast player -?
    local bad = find_bad_valves(player.force)
    if #bad == 0 then
        player.print{ "valves.warn-all-found-none" }
    else
        player.print{ "valves.warn-all-found", #bad }
        print_bad(player, bad)
    end
end)

--------------------------------------------------------------------------------
-- Building and rotating

local function on_built_or_rotated(event)
    local entity = event.entity
    if entity and entity.valid then
        check_connection(entity, event.player_index and game.get_player(event.player_index))
    end
end

for _, event in pairs{ "on_built_entity", "on_robot_built_entity", "on_space_platform_built_entity",
    "script_raised_built", "script_raised_revive", "on_player_rotated_entity" } do
    script.on_event(defines.events[event], on_built_or_rotated)
end

--------------------------------------------------------------------------------
-- Threshold label on the selected valve and hotkeys

---@class ThresholdLabel
---@field object LuaRenderObject
---@field valve LuaEntity
---@field default number

---@param threshold number
local function format_threshold(threshold)
    return string.format("%d%%", math.floor(threshold * 100 + 0.5))
end

---@param player_index uint
local function remove_label(player_index)
    local label = storage.labels[player_index]
    if not label then return end
    label.object.destroy() -- safe on invalid objects
    storage.labels[player_index] = nil
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
    remove_label(event.player_index)
    local player = game.get_player(event.player_index) ---@cast player -?
    local entity = player.selected
    if not (entity and entity.valid) then return end
    local default = valves[real_name(entity)]
    if not default then return end

    local threshold = entity.valve_threshold_override or default
    storage.labels[event.player_index] = {
        valve = entity,
        default = default,
        object = rendering.draw_text{
            text = format_threshold(threshold),
            surface = entity.surface,
            target = entity,
            color = { 1, 1, 1, 0.8 },
            scale = 1.5,
            alignment = "center",
            vertical_alignment = "middle",
            players = { player },
        },
    }
end)

-- Keeps labels in sync with hotkeys, copy-paste and other players' changes; trivial cost.
script.on_event(defines.events.on_tick, function()
    for player_index, label in pairs(storage.labels) do
        if label.object.valid and label.valve.valid then
            label.object.text = format_threshold(label.valve.valve_threshold_override or label.default)
        else
            remove_label(player_index)
        end
    end
end)

---@param event EventData.CustomInputEvent
---@param step number
local function change_threshold(event, step)
    local player = game.get_player(event.player_index)
    local entity = player and player.selected
    if not entity then return end
    local default = valves[real_name(entity)]
    if default == nil then return end
    if not default then
        player.create_local_flying_text{ text = { "valves.configuration-doesnt-support-thresholds" }, create_at_cursor = true }
        return
    end
    local threshold = (entity.valve_threshold_override or default) + step
    threshold = math.min(1, math.max(0, threshold))
    entity.valve_threshold_override = math.floor(threshold * 10 + 0.5) / 10
    entity.create_build_effect_smoke()
end

script.on_event("valves-threshold-plus", function(event) change_threshold(event, 0.1) end)
script.on_event("valves-threshold-minus", function(event) change_threshold(event, -0.1) end)

--------------------------------------------------------------------------------
-- Lifecycle

script.on_init(function()
    storage.labels = {}
end)

script.on_configuration_changed(function(data)
    -- Fresh label state. Labels of the merged valves-lib: it is not documented that the engine
    -- removes render objects of a removed mod, so clear them explicitly.
    rendering.clear(script.mod_name)
    if data.mod_changes["valves-lib"] then rendering.clear("valves-lib") end
    storage.labels = {}

    for _, force in pairs(game.forces) do
        local bad = find_bad_valves(force)
        if #bad > 0 then
            force.print{ "valves.warn-all-found-extended", #bad }
            print_bad(force, bad)
            force.print{ "valves.warn-show-again" }
        end
    end
end)
