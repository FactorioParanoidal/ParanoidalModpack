-- PARANOIDAL: Start with BnL. The start crash supplies (scripts/start.lua, mining.lua, quality.lua,
-- generator.lua) and the BnL start content built on them. All event handlers go through
-- scripts/events.lua (one handler per event), timed work through scripts/scheduler.lua (one
-- on_nth_tick only while something is queued). Content starts only on a new map.
local config = require("bnl-config")
local events = require("scripts.events")
local scheduler = require("scripts.scheduler")
local start = require("scripts.start")
local mining = require("scripts.mining")
local generator = require("scripts.generator")
local journal = require("scripts.journal")
local tags = require("scripts.tags")
local fire = require("scripts.fire")
local falling = require("scripts.falling")
local trail = require("scripts.trail")
local pods = require("scripts.pods")
local professions = require("scripts.professions")
local anomalies = require("scripts.anomalies")
local scrap = require("scripts.scrap")
local safe = require("scripts.safe")
local turret = require("scripts.turret")
local capsules = require("scripts.capsules")
local distress = require("scripts.distress")
local intro = require("scripts.intro")
local util = require("scripts.util")
require("scripts.recorder")
require("scripts.reactor")

local function state()
    local s = storage.shipwreck
    if not s then
        s = {qualities = {}, start = {}, targets = {}}
        storage.shipwreck = s
    end
    return s
end

-- BnL start content of a new map.
local function bnl_init()
    storage.bnl = {queue = {}}
    storage.bnl.trail_angle = config.entry_angle + (math.random() * 2 - 1) * config.trail.angle_deviation
    journal.init()
    tags.init()
    fire.init()
    falling.init()
    trail.init()
    pods.init()
    professions.init()
    anomalies.init()
    distress.init()
    intro.init()
    local surface = game.surfaces.nauvis
    if surface then trail.plan(surface) end
end

-- The ship and debris are filled: wrecks get ammo and can burn, the rest of the crash site appears.
start.on_ready = function(shipwreck, ship, wrecks)
    util.ship_decal(ship)
    if not storage.bnl then return end
    storage.bnl.landing_tick = game.tick
    local surface = ship.surface
    fire.ship_kit(ship)
    for _, wreck in ipairs(wrecks) do
        if wreck.valid and wreck ~= ship then
            local rec = fire.track(wreck, true)
            if rec and math.random() < config.fire.start_burning then
                fire.ignite_later(rec, math.random(config.fire.start_delay[1], config.fire.start_delay[2]))
            end
        end
    end
    local placed = scrap.place(surface)
    log("zzzparanoidal-start-bnl: scrap tiles " .. placed .. ", anomaly " .. tostring(storage.bnl.anomaly and storage.bnl.anomaly.name))
    safe.place(surface)
    turret.place(surface, shipwreck)
    falling.plan(surface)
    anomalies.start(surface)
    local list = {}
    for _, wreck in ipairs(wrecks) do
        if wreck.valid and wreck ~= ship then list[#list + 1] = wreck end
    end
    storage.bnl.start_wrecks = list -- the start wrecks without later debris (the guard's ammo)
    professions.on_start_ready()
    events.refresh()
end

script.on_init(function()
    start.init(state())
    generator.refresh()
    if game.tick < 2 then bnl_init() end
    scheduler.on_init()
    events.refresh()
end)

script.on_configuration_changed(function()
    local s = state()
    util.ship_decal(s.ship) -- maps started before the logo (2.0.0) get it on the starliner too
    generator.refresh()
    events.refresh()
end)

script.on_load(function()
    scheduler.on_load()
    falling.on_load()
    events.refresh()
end)

events.on(defines.events.on_player_created, function(event)
    start.on_player_created(state(), event)
    local player = game.get_player(event.player_index)
    if not (player and storage.bnl) then return end
    capsules.on_player_created(player)
    intro.on_player_created(player)
end)

-- Every 5 ticks: the start fill tolerates the delay and the wreck selection lag (83 ms) is invisible.
script.on_nth_tick(5, function(event)
    local s = storage.shipwreck
    if not s then return end
    start.on_tick(s, event.tick)
    mining.on_tick(s)
end)

local mined_filters = mining.filters()
if not mined_filters[1] then mined_filters = nil end
local function on_mined(event) mining.on_mined(state(), event) end
events.on(defines.events.on_player_mined_entity, on_mined, mined_filters)
events.on(defines.events.on_robot_mined_entity, on_mined, mined_filters)
events.on(defines.events.on_pre_player_mined_item, function(event)
    mining.on_pre_player_mined(state(), event)
end, mined_filters)

events.on(defines.events.on_object_destroyed, function(event)
    local s = storage.shipwreck
    if s then mining.on_destroyed(s, event) end
    if storage.bnl then
        local registration = event.registration_number
        fire.on_destroyed(registration)
        pods.on_destroyed(registration)
        turret.on_destroyed(registration)
    end
end)

local built_filters = generator.filters()
if built_filters then
    for _, name in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
        events.on(defines.events[name], generator.on_built, built_filters)
    end
    events.on(defines.events.on_entity_cloned, generator.on_built, built_filters)
end

events.install()
