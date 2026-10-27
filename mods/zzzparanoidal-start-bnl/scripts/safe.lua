-- Captain's safe near the ship: locked until the BnL code is put on its circuit input as the
-- signals B, N and L. The flight recorder gives B and N, the note of the previous expedition gives
-- L (the BnL master digit has not changed for seven centuries). Without them the lock can be picked:
-- a letter whose right value stays on the input for config.safe.latch_polls polls in a row clicks
-- and stays solved; all three solved open the safe (the whole right code opens it at once).
-- The safe looks empty and takes nothing (the bar of its chest is at the first slot): what is
-- inside was rolled at the map start (scripts/loot.lua) and appears when it opens.
-- The lock is polled from the landing until it opens: every config.safe.poll_idle ticks, every
-- poll_wired while a wire is on it; pointing at it checks at once and tells what the lock thinks.
local config = require("bnl-config")
local util = require("scripts.util")
local journal = require("scripts.journal")
local events = require("scripts.events")
local scheduler = require("scripts.scheduler")
local goals = require("scripts.goals")
local loot = require("scripts.loot")
local M = {}
local cfg = config.safe

local NAME = "bnl-captain-safe"
local NOTE = "bnl-engineer-note"
local LETTERS = {"B", "N", "L"}

local function state()
    return storage.bnl and storage.bnl.safe
end

local function start_poll(s, delay)
    if s.polling or s.open then return end
    s.polling = true
    scheduler.after(delay or cfg.poll_idle, "safe-poll")
end

function M.place(surface)
    if not util.entity_exists(NAME) then return end
    local code = {}
    for i = 1, #cfg.signals do code[i] = util.int(cfg.code) end
    storage.bnl.safe = {code = code, latched = {}, hits = {}}
    local p = util.add(util.ship_position(), util.vector(math.random(), util.float(cfg.distance)))
    local spot = surface.find_non_colliding_position(NAME, p, 12, 1)
    if not spot then return end
    util.clear(surface, util.area(spot, 2))
    local safe = surface.create_entity({name = NAME, position = spot, force = "player", create_build_effect_smoke = false})
    if not safe then return end
    safe.operable = false
    safe.minable_flag = false
    safe.destructible = false
    -- empty and closed to inserters: nothing to take out, nothing to hide inside
    local inventory = safe.get_inventory(defines.inventory.chest)
    if inventory and inventory.supports_bar() then inventory.set_bar(1) end
    loot.get("safe") -- rolled at the map start already; a guard for a missing roll
    storage.bnl.safe.entity = safe
    start_poll(storage.bnl.safe)
    events.refresh()
end

-- Signal values on the safe (nil: no wire).
local function values_of(safe)
    local signals = safe.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
    if not signals then return nil end
    local values = {}
    for _, signal in pairs(signals) do
        local id = signal.signal
        if id.type == "virtual" then values[id.name] = (values[id.name] or 0) + signal.count end
    end
    return values
end

local function all_right(values, code)
    for i, name in ipairs(cfg.signals) do
        if values[name] ~= code[i] then return false end
    end
    return true
end

local function wired(safe)
    return safe.get_circuit_network(defines.wire_connector_id.circuit_red) ~= nil
        or safe.get_circuit_network(defines.wire_connector_id.circuit_green) ~= nil
end

-- Letters solved so far, for texts: "B, L" or nil.
local function latched_text(s)
    local list = {}
    for i, letter in ipairs(LETTERS) do
        if s.latched and s.latched[i] then list[#list + 1] = letter end
    end
    return list[1] and table.concat(list, ", ") or nil
end

-- Digit i known to the players: from the recorder (B, N), the note (L) or picked (any).
function M.known(i)
    local s = state()
    if not (s and s.code) then return nil end
    if s.latched and s.latched[i] then return s.code[i] end
    if i <= 2 and storage.bnl.recorder_done then return s.code[i] end
    if i == 3 and s.note_read then return s.code[i] end
    return nil
end

local function open(s, name)
    local safe = s.entity
    s.open = true
    safe.operable = true
    safe.minable_flag = true
    safe.destructible = true
    local inventory = safe.get_inventory(defines.inventory.chest)
    if inventory then
        if inventory.supports_bar() then inventory.set_bar() end
        loot.give("safe", inventory, safe)
    end
    safe.surface.play_sound({path = "utility/achievement_unlocked", position = safe.position})
    journal.add("safe-open-" .. loot.get("safe").key, {name}, {open = true})
    events.refresh()
    goals.refresh()
end

-- The code checks itself: the player closest to the safe gets the credit.
local function nearest_name(safe)
    local best, best_d
    for _, player in pairs(game.connected_players) do
        if player.surface == safe.surface then
            local d = util.distance(player.position, safe.position)
            if not best_d or d < best_d then best, best_d = player, d end
        end
    end
    return best and best.name or {"bnl.fallback-player-name"}
end

-- One look at the lock: the right letters count up, a letter seen right latch_polls times clicks.
local function check(s)
    local safe = s.entity
    local values = values_of(safe)
    if not values then
        s.hits = {}
        return
    end
    if all_right(values, s.code) then
        open(s, nearest_name(safe))
        return
    end
    s.latched, s.hits = s.latched or {}, s.hits or {}
    local clicked = false
    for i, name in ipairs(cfg.signals) do
        if not s.latched[i] then
            if values[name] == s.code[i] then
                s.hits[i] = (s.hits[i] or 0) + 1
                if s.hits[i] >= cfg.latch_polls then
                    s.latched[i] = true
                    clicked = true
                    util.say(util.joke("safe-latched", LETTERS[i], s.code[i]), nil, safe.force)
                    rendering.draw_text({text = {"bnl.safe-click", LETTERS[i]}, surface = safe.surface,
                        target = {entity = safe, offset = {0, -1.5}}, color = {r = 0.55, g = 0.9, b = 0.5},
                        scale = 1.4, alignment = "center", time_to_live = 180})
                end
            else
                s.hits[i] = 0
            end
        end
    end
    if clicked then
        if s.latched[1] and s.latched[2] and s.latched[3] then
            open(s, nearest_name(safe))
            return
        end
        goals.refresh()
    end
end

scheduler.handler("safe-poll", function()
    local s = state()
    if not s or s.open then
        if s then s.polling = false end
        return
    end
    if not (s.entity and s.entity.valid) then
        s.polling = false
        return
    end
    check(s)
    if s.open then return end
    scheduler.after(wired(s.entity) and cfg.poll_wired or cfg.poll_idle, "safe-poll")
end)

-- Kept for callers that expect it (scripts/recorder.lua): the poll runs from the landing anyway.
function M.wake()
    local s = state()
    if s and s.entity and s.entity.valid then start_poll(s) end
end

local function on_selected(event)
    local s = state()
    if not (s and s.entity) or s.open then return end
    if not s.entity.valid then
        s.open = true
        events.refresh()
        return
    end
    local player = game.get_player(event.player_index)
    if not (player and player.selected == s.entity) then return end
    local values = values_of(s.entity)
    if values and all_right(values, s.code) then
        open(s, player.name)
        return
    end
    local text = util.joke(values == nil and "safe-no-signal" or "safe-wrong-code")
    local solved = latched_text(s)
    if solved then text = {"", text, " ", {"bnl.safe-solved", solved}} end
    player.create_local_flying_text({text = text, position = s.entity.position, color = {r = 1, g = 0.6, b = 0.2}})
end

events.dynamic(defines.events.on_selected_entity_changed, on_selected, function()
    local s = state()
    return s ~= nil and s.entity ~= nil and not s.open
end)

-- The note of engineer #7 (a capsule): reading it gives the last digit of the code.
events.on(defines.events.on_player_used_capsule, function(event)
    if event.item.name ~= NOTE then return end
    local s = state()
    local player = game.get_player(event.player_index)
    local code = s and s.code
    journal.add("expedition-note", {player and player.name or "?", code and code[3] or "???"}, {open = true})
    if s then
        s.note_read = true
        goals.refresh()
    end
end)

return M
