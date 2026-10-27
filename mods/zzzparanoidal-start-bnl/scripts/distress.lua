-- Distress signal: three of the four antenna parts (medbay, armory, engineering bay, the reactor
-- compartment) make the distress beacon. Powered for a minute it sends an SOS (the progress over the
-- beacon; a lost power is reported); BnL answers that a rescue is not cost effective and you are
-- fired. Then the beacon only listens (an ordinary radar, bnl-distress-receiver), a severance pod
-- comes next to it and the SOS goes to the insurance (scripts/pods.lua). From then on BnL writes at
-- milestones (research, the first rocket). The power check runs only while a beacon is transmitting.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local events = require("scripts.events")
local pods = require("scripts.pods")
local goals = require("scripts.goals")
local loot = require("scripts.loot")
local M = {}
local cfg = config.distress

local NAME = "bnl-distress-beacon"
local RECEIVER = "bnl-distress-receiver"

local function state()
    return storage.bnl and storage.bnl.distress
end

function M.init()
    storage.bnl.distress = storage.bnl.distress or {letters = {}}
end

local function clear_label(s)
    if s.label and s.label.valid then s.label.destroy() end
    s.label = nil
end

local function show_progress(s, beacon)
    local text = {"bnl.sos-label", math.floor(s.powered), cfg.transmit_s}
    if s.label and s.label.valid then
        s.label.text = text
        return
    end
    s.label = rendering.draw_text({text = text, surface = beacon.surface, target = {entity = beacon, offset = cfg.label_offset},
        color = {r = 1, g = 0.6, b = 0.2}, scale = 1.3, alignment = "center"})
end

-- The beacon has said everything it had to say: an ordinary radar from now on, same place,
-- quality and health share. Returns the new entity (or the old one when it cannot be replaced).
local function to_receiver(entity)
    if not (entity and entity.valid and util.entity_exists(RECEIVER)) then return entity end
    local surface, position, force = entity.surface, entity.position, entity.force
    local quality, health = entity.quality.name, entity.health / entity.max_health
    entity.destroy({raise_destroy = true})
    local receiver = surface.create_entity({name = RECEIVER, position = position, force = force, quality = quality,
        create_build_effect_smoke = false, raise_built = true})
    if receiver then receiver.health = receiver.max_health * health end
    return receiver
end

local function on_built(event)
    local entity = event.entity
    local s = state()
    if not (s and entity and entity.valid and entity.name == NAME) then return end
    if s.sent then
        util.say({"bnl.distress-again"}, nil, entity.force)
        if s.replied then to_receiver(entity) end
        return
    end
    if s.beacon and s.beacon.valid and s.beacon ~= entity then clear_label(s) end
    s.beacon = entity
    s.powered = 0
    s.on_air = false
    util.say({"bnl.distress-built"}, false, entity.force)
    show_progress(s, entity)
    if not scheduler.has("distress-check") then scheduler.after(cfg.check_interval, "distress-check") end
    goals.refresh()
end

local filter = {{filter = "name", name = NAME}}
for _, id in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
    events.on(defines.events[id], on_built, filter)
end

scheduler.handler("distress-check", function()
    local s = state()
    local beacon = s and s.beacon
    if not (beacon and beacon.valid) or s.sent then
        if s then clear_label(s) end
        return
    end
    if beacon.status == defines.entity_status.working then
        s.powered = math.min(cfg.transmit_s, s.powered + cfg.check_interval / 60)
        s.on_air = true
    elseif s.on_air then
        s.on_air = false
        util.say(util.joke("distress-interrupted", util.gps(beacon.position, beacon.surface)), nil, beacon.force)
    end
    if s.powered >= cfg.transmit_s then
        s.sent = true
        s.sent_tick = game.tick
        s.position = util.pos(beacon.position)
        s.surface = beacon.surface.index
        clear_label(s)
        journal.add("distress-sent", {util.gps(beacon.position, beacon.surface)})
        scheduler.after(cfg.reply_delay, "distress-reply")
    else
        show_progress(s, beacon)
        scheduler.after(cfg.check_interval, "distress-check")
    end
    goals.refresh()
end)

scheduler.handler("distress-reply", function()
    local s = state()
    s.replied = true
    journal.add("distress-reply", nil, {open = true})
    local beacon = s.beacon
    if beacon and beacon.valid then
        s.beacon = to_receiver(beacon)
        util.say({"bnl.distress-receiver"}, false)
    end
    local surface = game.get_surface(s.surface or 1)
    if surface and s.position then
        pods.sos(surface, s.position, cfg.insurance_bonus)
        scheduler.after(cfg.severance_delay, "distress-severance")
    end
    goals.act_later()
    goals.refresh()
end)

-- Severance pay: one pod with several kinds of items next to the beacon.
scheduler.handler("distress-severance", function()
    local s = state()
    local surface = s and game.get_surface(s.surface or 1)
    if not (surface and s.position) then return end
    local beacon = s.beacon
    local center = beacon and beacon.valid and util.pos(beacon.position) or s.position
    local reward = loot.get("severance")
    pods.drop(surface, center, {stacks = reward.items}, cfg.severance_distance, "bnl.pod-severance-" .. reward.key)
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
