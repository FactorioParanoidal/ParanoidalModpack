local events = require('scripts/events')
local debug_chat = require('paranoidal-debug-chat')

local M = {}
local WINDOW = 30 * 60
local ACTIONS = {
    empty = true, deconstruct = true, explode_cliff = true, upgrade = true,
    build = true, clear_ground = true, upgrade_tile = true, build_tile = true,
    repair = true, removal_request = true, insert_request = true,
    destroy_tree = true, destroy_rock = true, fill_water = true,
}

local function label(kind)
    return {'nano-notice-action.' .. kind}
end

local function schedule(state, index, kind, record, tick)
    record.due = tick + WINDOW
    local bucket = state.due[record.due]
    if not bucket then
        bucket = {}
        state.due[record.due] = bucket
    end
    bucket[#bucket + 1] = {index = index, kind = kind}
end

function M.failed(player, kind, target)
    if not (player and player.valid and player.connected) then return end
    kind = ACTIONS[kind] and kind or 'other'
    local state = storage.nano_action_notices
    if not state then
        state = {players = {}, due = {}}
        storage.nano_action_notices = state
    end
    local records = state.players[player.index]
    if not records then
        records = {}
        state.players[player.index] = records
    end
    local record = records[kind]
    if record then
        record.repeats = record.repeats + 1
        return
    end
    record = {repeats = 0}
    records[kind] = record
    schedule(state, player.index, kind, record, game.tick)
    local where = {'nano-notice.no-location'}
    if target and target.valid then
        local p = target.position
        where = string.format('[gps=%.1f,%.1f,%s]', p.x, p.y, target.surface.name)
    end
    player.print({'nano-notice.first', label(kind), where})
end

-- Only the due bucket is inspected; manual mode shares the same existing event registry.
local function on_tick(event)
    local state = storage.nano_action_notices
    if not state then return end
    local bucket = state.due[event.tick]
    if not bucket then return end
    state.due[event.tick] = nil
    for _, item in ipairs(bucket) do
        local records = state.players[item.index]
        local record = records and records[item.kind]
        if record and record.due == event.tick then
            local player = game.get_player(item.index)
            if player and player.valid and player.connected and not debug_chat.enabled() and record.repeats > 0 then
                player.print({'nano-notice.summary', record.repeats, label(item.kind)})
                record.repeats = 0
                schedule(state, item.index, item.kind, record, event.tick)
            else
                records[item.kind] = nil
                if next(records) == nil then state.players[item.index] = nil end
            end
        end
    end
end

events.on(defines.events.on_tick, on_tick)
events.on(defines.events.on_player_removed, function(event)
    local state = storage.nano_action_notices
    if state then state.players[event.player_index] = nil end
end)

return M
