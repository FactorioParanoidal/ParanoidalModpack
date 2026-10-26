-- Distress signal: three antenna parts (medbay/armory compartments, the cold reactor) make the
-- distress beacon. Powered for a minute it sends an SOS; BnL answers that a rescue is not cost
-- effective and you are fired. From then on BnL writes at milestones (research, the first rocket).
-- The power check runs every 10 s only while a beacon is transmitting.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local events = require("scripts.events")
local M = {}
local cfg = config.distress

local NAME = "bnl-distress-beacon"

local function state()
    return storage.bnl and storage.bnl.distress
end

function M.init()
    storage.bnl.distress = storage.bnl.distress or {letters = {}}
end

local function on_built(event)
    local entity = event.entity
    local s = state()
    if not (s and entity and entity.valid and entity.name == NAME) then return end
    if s.sent then
        util.say({"bnl.distress-again"}, nil, entity.force)
        return
    end
    s.beacon = entity
    s.powered = 0
    util.say({"bnl.distress-built"}, false, entity.force)
    if not scheduler.has("distress-check") then scheduler.after(cfg.check_interval, "distress-check") end
end

local filter = {{filter = "name", name = NAME}}
for _, id in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
    events.on(defines.events[id], on_built, filter)
end

scheduler.handler("distress-check", function()
    local s = state()
    local beacon = s and s.beacon
    if not (beacon and beacon.valid) or s.sent then return end
    if beacon.status == defines.entity_status.working then
        s.powered = s.powered + cfg.check_interval / 60
    end
    if s.powered >= cfg.transmit_s then
        s.sent = true
        journal.add("distress-sent", {util.gps(beacon.position, beacon.surface)})
        scheduler.after(cfg.reply_delay, "distress-reply")
    else
        scheduler.after(cfg.check_interval, "distress-check")
    end
end)

scheduler.handler("distress-reply", function()
    local s = state()
    s.replied = true
    journal.add("distress-reply", nil, {open = true})
end)

events.on(defines.events.on_research_finished, function(event)
    local s = state()
    if not (s and s.replied) then return end
    local name = event.research.name
    for _, letter in ipairs(cfg.letters) do
        if letter == name and not s.letters[name] then
            s.letters[name] = true
            journal.add("letter-" .. name)
        end
    end
end)

events.on(defines.events.on_rocket_launched, function()
    local s = state()
    if not (s and s.replied) or s.letters.rocket then return end
    s.letters.rocket = true
    journal.add("letter-rocket", nil, {open = true})
end)

return M
