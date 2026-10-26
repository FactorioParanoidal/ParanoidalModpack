-- Captain's safe near the ship: locked until the BnL code is put on its circuit input as the
-- signals B, N and L. The flight recorder gives B and N, the note of the previous expedition gives
-- L (the BnL master digit has not changed for seven centuries). The lock is checked when a player
-- points at the safe; the handler exists only while the safe is locked.
local config = require("bnl-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local journal = require("scripts.journal")
local events = require("scripts.events")
local M = {}
local cfg = config.safe

local NAME = "bnl-captain-safe"
local NOTE = "bnl-engineer-note"

local function state()
    return storage.bnl and storage.bnl.safe
end

function M.place(surface)
    if not util.entity_exists(NAME) then return end
    local code = {}
    for i = 1, #cfg.signals do code[i] = util.int(cfg.code) end
    storage.bnl.safe = {code = code}
    local p = util.add(util.ship_position(), util.vector(math.random(), util.float(cfg.distance)))
    local spot = surface.find_non_colliding_position(NAME, p, 12, 1)
    if not spot then return end
    util.clear(surface, util.area(spot, 2))
    local safe = surface.create_entity({name = NAME, position = spot, force = "player", create_build_effect_smoke = false})
    if not safe then return end
    safe.operable = false
    safe.minable_flag = false
    safe.destructible = false
    local inventory = safe.get_inventory(defines.inventory.chest)
    for _, entry in ipairs(cfg.items) do
        if util.item_exists(entry[1]) then
            local q = entry.quality_steps and quality.step_up(entry.quality_steps) or "normal"
            inventory.insert({name = entry[1], count = util.int({entry[2], entry[3]}), quality = q})
        end
    end
    storage.bnl.safe.entity = safe
    events.refresh()
end

local function matches(safe, code)
    local signals = safe.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
    if not signals then return nil end
    local values = {}
    for _, signal in pairs(signals) do
        local id = signal.signal
        if id.type == "virtual" then values[id.name] = (values[id.name] or 0) + signal.count end
    end
    for i, name in ipairs(cfg.signals) do
        if values[name] ~= code[i] then return false end
    end
    return true
end

-- true: the code is on the input, false: wrong code, nil: no signal (or no locked safe).
function M.code_matches()
    local s = state()
    if not (s and s.entity and s.entity.valid) then return nil end
    return matches(s.entity, s.code)
end

local function open(s, player)
    local safe = s.entity
    s.open = true
    safe.operable = true
    safe.minable_flag = true
    safe.destructible = true
    safe.surface.play_sound({path = "utility/achievement_unlocked", position = safe.position})
    journal.add("safe-open", {player.name}, {open = true})
    events.refresh()
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
    local result = matches(s.entity, s.code)
    if result then
        open(s, player)
    else
        player.create_local_flying_text({text = {result == nil and "bnl.safe-no-signal" or "bnl.safe-wrong-code"},
            position = s.entity.position, color = {r = 1, g = 0.6, b = 0.2}})
    end
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
end)

return M
