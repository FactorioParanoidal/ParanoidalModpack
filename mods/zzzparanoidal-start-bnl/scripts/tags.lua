-- Chart tags of the BnL start. A tag needs a charted chunk: until then it waits and the
-- on_chunk_charted handler (registered only while something waits) creates it. Every tag has a
-- slot: setting a slot again replaces its tag, waiting or made.
local util = require("scripts.util")
local events = require("scripts.events")
local M = {}

local function state()
    return storage.bnl.tags
end

function M.init()
    storage.bnl.tags = storage.bnl.tags or {pending = {}, made = {}, next_slot = 0}
end

local function make(spec)
    local force = game.forces[spec.force]
    local surface = game.get_surface(spec.surface)
    if not (force and surface) then return true end
    local tag = force.add_chart_tag(surface, {position = spec.position, icon = spec.icon,
        text = util.tag_text(force, spec.key, spec.suffix)})
    if not tag then return false end
    state().made[spec.slot] = tag
    return true
end

function M.set(slot, force, surface, position, key, icon, suffix)
    local s = state()
    if not slot then
        s.next_slot = s.next_slot + 1
        slot = "auto-" .. s.next_slot
    end
    M.remove(slot)
    local spec = {slot = slot, force = force.index, surface = surface.index, position = util.pos(position), key = key,
        icon = icon or {type = "virtual", name = "signal-info"}, suffix = suffix}
    if not make(spec) then
        s.pending[slot] = spec
        events.refresh()
    end
    return slot
end

function M.remove(slot)
    local s = state()
    s.pending[slot] = nil
    local tag = s.made[slot]
    if tag and tag.valid then tag.destroy() end
    s.made[slot] = nil
end

local function on_chunk_charted(event)
    local s = storage.bnl.tags
    local area = event.area
    local changed = false
    for slot, spec in pairs(s.pending) do
        local p = spec.position
        if spec.surface == event.surface_index and spec.force == event.force.index
            and p.x >= area.left_top.x and p.x < area.right_bottom.x and p.y >= area.left_top.y and p.y < area.right_bottom.y then
            if make(spec) then
                s.pending[slot] = nil
                changed = true
            end
        end
    end
    if changed and not next(s.pending) then events.refresh() end
end

events.dynamic(defines.events.on_chunk_charted, on_chunk_charted, function()
    local s = storage.bnl and storage.bnl.tags
    return s ~= nil and next(s.pending) ~= nil
end)

return M
