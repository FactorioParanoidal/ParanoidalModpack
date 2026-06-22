local builder = require("__valves-lib__.scripts.builder")

---@class ThresholdRendering
---@field render_object LuaRenderObject
---@field default_threshold number
---@field valve LuaEntity?

---@class PlayerData
---@field render_threshold ThresholdRendering?

local interaction = {}

---@param threshold number
---@return string
local function format_threshold(threshold)
    return string.format("%d%%", math.floor((threshold * 100) + 0.5))
end

---@param player_data PlayerData
local function destroy_render_threshold(player_data)
    local render_threshold = player_data.render_threshold
    if render_threshold and render_threshold.render_object then
        render_threshold.render_object.destroy()
    end
end

---@param event EventData.on_selected_entity_changed
local function on_selected_entity_changed(event)
    local player = game.get_player(event.player_index) --[[@cast player -? ]]

    -- Don't want to set up all the plumbing to create this data.
    -- This is a slow event, so it might be okay for now.
    ---@type table<number, PlayerData>
    storage.players = storage.players or {}
    local player_data = storage.players[event.player_index]
    if not player_data then
        storage.players[event.player_index] = {}
        player_data = storage.players[event.player_index]
    end

    -- Always destroy all current render_objects, if any, to keep logic simple.
    -- Regardless of wity is now selected.
    destroy_render_threshold(player_data)
    player_data.render_threshold = nil

    local entity = player.selected
    if not (entity and entity.valid) then return end
    local valve_config = builder.get_useful_valve_config(entity)
    if not valve_config then return end
    if valve_config.valve_mode == "one-way" then return end -- Doesn't have a threshold
    local threshold = entity.valve_threshold_override or valve_config.default_threshold

    player_data.render_threshold = {
        valve = entity,
        default_threshold = threshold,
        render_object = rendering.draw_text{
            text = format_threshold(threshold),
            surface = entity.surface,
            target = entity,
            color = {1, 1, 1, 0.8},
            scale = 1.5 * (valve_config.threshold_visualization_scale or 1.0),
            vertical_alignment = "middle",
            players = { player },
            alignment = "center",
        }
    }
end

---@param input "minus" | "plus"
---@param event EventData.CustomInputEvent
local function quick_toggle(input, event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local valve = player.selected
    if not valve then return end
    local valve_config = builder.get_useful_valve_config(valve)
    if not valve_config then return end

    if valve_config.valve_mode == "one-way" then
        player.create_local_flying_text{text = {"valves.configuration-doesnt-support-thresholds"}, create_at_cursor=true}
        return
    end

    local threshold = valve.valve_threshold_override or valve_config.default_threshold
    threshold = threshold + (0.1 * (input == "plus" and 1 or -1 ))  -- Adjust
    threshold = math.min(1, math.max(0, threshold))                 -- Clamp
    threshold = math.floor(threshold * 10 + 0.5) / 10               -- Round
    valve.valve_threshold_override = threshold

    -- Visualize it to the player
    valve.create_build_effect_smoke()
end

local function on_tick()
    -- All we're doing is just updating any threshold rendering that any players
    -- might have while selecting a valve. This is to handle quick-toggles, copy-pasting,
    -- multiplayer things, and whetever else might occur. Probably overkill but this function
    -- will be so fast nobody will be able to measure it.

    for _, player_data in pairs(storage.players or { }) do
        local render_threshold = player_data.render_threshold
        if not render_threshold then goto continue end

        local render_object, valve = render_threshold.render_object, render_threshold.valve
        if not (render_object and render_object.valid and valve and valve.valid) then
            destroy_render_threshold(player_data)
            if render_object then render_object.destroy() end
            player_data.render_threshold = nil
            goto continue
        end

        render_object.text = format_threshold(valve.valve_threshold_override or render_threshold.default_threshold)

        ::continue::
    end
end

interaction.events = {
    [defines.events.on_selected_entity_changed] = on_selected_entity_changed,
    [defines.events.on_tick] = on_tick,
}
for input, custom_input in pairs({
    minus = "valves-threshold-minus",
    plus = "valves-threshold-plus",
}) do
    interaction.events[custom_input] = function(e) quick_toggle(input, e) end
end

return interaction
