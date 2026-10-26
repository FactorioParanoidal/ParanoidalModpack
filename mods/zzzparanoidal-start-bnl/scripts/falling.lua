-- The ship keeps falling apart: for the first minutes stragglers come down around the crash site
-- from the west-south-west. The growing shadow warns a few seconds before, the roar of a low pass comes with the flight; the impact
-- (prototypes/bnl-falling.lua) damages the area and raises a script trigger, then a new wreck with
-- start loot and ammo lies there, often burning. Sometimes a piece aims at a player building.
-- The big piece closest to config.falling.recorder_tick carries the flight recorder.
-- BnL supply pods use the same flight (scripts/pods.lua registers a lander).
local config = require("bnl-config")
local shipwreck = require("shipwreck-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local scheduler = require("scripts.scheduler")
local start = require("scripts.start")
local fire = require("scripts.fire")
local events = require("scripts.events")
local tags = require("scripts.tags")
local M = {}
local cfg = config.falling

M.landers = {} -- kind -> function(surface, position, data)

local RADIUS = {small = 2.5, medium = 3.5, big = 5, pod = 2}

function M.init()
    storage.bnl.falling = storage.bnl.falling or {incoming = {}}
end

local function not_wreck(name)
    if name == shipwreck.ship then return false end
    return shipwreck.wrecks[name] == nil
end

local function land_tile(surface, p)
    local tile = surface.get_tile(p.x, p.y)
    return tile.valid and not tile.collides_with("water_tile")
end

local function pick_target(surface)
    local center = util.ship_position()
    if math.random() < cfg.target_building_chance then
        local found = surface.find_entities_filtered({position = center, radius = cfg.building_radius, force = "player",
            type = {"mining-drill", "furnace", "assembling-machine", "inserter", "lab", "boiler", "generator",
                "electric-pole", "transport-belt", "radar", "electric-energy-interface", "container"}, limit = 60})
        local list = {}
        for _, entity in pairs(found) do
            if not_wreck(entity.name) and entity.name ~= "bnl-captain-safe" then list[#list + 1] = entity end
        end
        if list[1] then return util.pos(list[math.random(#list)].position) end
    end
    for _ = 1, 20 do
        local p = util.add(center, util.vector(math.random(), util.float(cfg.distance)))
        if land_tile(surface, p) and util.distance(p, center) > 11 then return p end
    end
    return nil
end

-- Red mark at the impact point for `ticks` (supply pods only; falling debris has none).
function M.warn(surface, target, kind, ticks)
    local radius = RADIUS[kind] or 3
    rendering.draw_circle({color = {r = 1, g = 0.15, b = 0.05, a = 0.85}, radius = radius, width = 4, filled = false,
        target = target, surface = surface, time_to_live = ticks, draw_on_ground = true})
    rendering.draw_circle({color = {r = 0.5, g = 0.05, b = 0.02, a = 0.35}, radius = radius, filled = true,
        target = target, surface = surface, time_to_live = ticks, draw_on_ground = true, blink_interval = 20})
    rendering.draw_sprite({sprite = "utility/warning_icon", target = target, surface = surface, time_to_live = ticks,
        x_scale = 0.8, y_scale = 0.8, blink_interval = 30})
end

-- Shadow of the coming piece over `target`: huge and faint at first, the real shadow at
-- `impact_tick`. One on_nth_tick handler animates all shadows and exists only while there are any.
local update_shadows

local function shadow_list()
    local f = storage.bnl and storage.bnl.falling
    return f and f.shadows
end

function M.shadow(surface, target, kind, impact_tick)
    local sprite = "bnl-falling-shadow-" .. kind
    local from = game.tick
    if impact_tick <= from or not helpers.is_valid_sprite_path(sprite) then return end
    local s0 = util.float(cfg.shadow_scale)
    local spin = kind == "pod" and 0 or (math.random() * 2 - 1) * cfg.shadow_spin
    local object = rendering.draw_sprite({sprite = sprite, target = target, surface = surface, x_scale = s0, y_scale = s0,
        orientation = spin % 1, tint = {0, 0, 0, cfg.shadow_alpha}, render_layer = "object",
        time_to_live = impact_tick - from + cfg.shadow_interval * 2})
    local f = storage.bnl.falling
    f.shadows = f.shadows or {}
    f.shadows[#f.shadows + 1] = {object = object, from = from, to = impact_tick, s0 = s0, spin = spin}
    script.on_nth_tick(cfg.shadow_interval, update_shadows)
end

update_shadows = function(event)
    local list = shadow_list()
    local tick = event.tick
    local a0 = cfg.shadow_alpha
    for i = #list, 1, -1 do
        local sh = list[i]
        local object = sh.object
        if not object.valid then
            table.remove(list, i)
        else
            local t = math.min(1, (tick - sh.from) / (sh.to - sh.from))
            local s = 1 + (sh.s0 - 1) * (1 - t)
            local k = (1 / s - 1 / sh.s0) / (1 - 1 / sh.s0)
            object.x_scale, object.y_scale = s, s
            object.color = {0, 0, 0, a0 + (1 - a0) * k}
            object.orientation = (sh.spin * (1 - t)) % 1
            if t >= 1 then table.remove(list, i) end -- the last frame stays until its time to live
        end
    end
    if not (list and list[1]) then script.on_nth_tick(cfg.shadow_interval, nil) end
end

function M.on_load()
    local list = shadow_list()
    if list and list[1] then script.on_nth_tick(cfg.shadow_interval, update_shadows) end
end

-- Sound of a coming piece at `target`, decided per player config.falling.sound_lead before
-- `launch_tick`: far players hear the roar of the low pass from then on, players within
-- near_distance hear the incoming shell whistle that ends at the impact (launch + flight).
function M.sound_before(surface, target, launch_tick)
    scheduler.at(math.max(game.tick + 1, launch_tick - cfg.sound_lead), "falling-sound",
        {surface = surface.index, target = target, impact = launch_tick + cfg.flight})
end

scheduler.handler("falling-sound", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    local near = {}
    local limit = cfg.near_distance * cfg.near_distance
    for _, player in pairs(game.connected_players) do
        if player.surface == surface then
            local p = player.position
            local dx, dy = p.x - job.target.x, p.y - job.target.y
            if dx * dx + dy * dy <= limit then
                near[#near + 1] = player.index
            else
                player.play_sound({path = "bnl-falling-whistle", position = job.target})
            end
        end
    end
    if near[1] then
        scheduler.at(math.max(game.tick + 1, (job.impact or game.tick) - cfg.incoming_lead), "falling-incoming",
            {target = job.target, players = near})
    end
end)

scheduler.handler("falling-incoming", function(job)
    for _, index in ipairs(job.players) do
        local player = game.get_player(index)
        if player and player.connected then
            player.play_sound({path = "bnl-falling-incoming", position = job.target})
        end
    end
end)

-- Projectile from the west-south-west onto `target`; `data` comes back to the lander.
function M.launch(surface, target, kind, data)
    local distance = cfg.source_distance
    local from = util.add(target, util.vector(util.trail_angle(), distance))
    if not surface.is_chunk_generated({x = math.floor(from.x / 32), y = math.floor(from.y / 32)}) then
        distance = 24
        from = util.add(target, util.vector(util.trail_angle(), distance))
    end
    local name = kind == "pod" and "bnl-supply-pod" or "bnl-falling-debris-" .. kind
    local projectile = surface.create_entity({name = name, position = from, target = target, force = "neutral",
        speed = distance / cfg.flight})
    if not projectile then return false end
    local incoming = storage.bnl.falling.incoming
    incoming[#incoming + 1] = {target = target, surface = surface.index, kind = kind, data = data, tick = game.tick}
    return true
end

function M.plan(surface)
    if not util.enabled("bnl-start-falling-debris") then return end
    local n = util.int(cfg.count)
    local times = {}
    local landing = util.landing_tick()
    for i = 1, n do times[i] = landing + math.random(cfg.first_tick, cfg.last_tick) end
    table.sort(times)
    local weights = {{"small", cfg.sizes.small}, {"medium", cfg.sizes.medium}, {"big", cfg.sizes.big}}
    local sizes, recorder, best = {}, 1, math.huge
    for i, t in ipairs(times) do
        sizes[i] = util.weighted(weights, 2)[1]
        local d = math.abs(t - landing - cfg.recorder_tick)
        if d < best then best, recorder = d, i end
    end
    sizes[recorder] = "big"
    for i, t in ipairs(times) do
        scheduler.at(math.max(game.tick + 1, t - cfg.warning), "falling-warn",
            {kind = sizes[i], surface = surface.index, recorder = i == recorder or nil})
    end
end

scheduler.handler("falling-warn", function(job, tick)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    local target = pick_target(surface)
    if not target then return end
    job.target = target
    M.shadow(surface, target, job.kind, tick + cfg.warning) -- launch at +warning-flight, flight ticks
    -- small pieces fall silently, medium ones are announced, big ones with the impact point
    if job.kind == "big" then
        util.say({"bnl.falling-warning", {"bnl.falling-size-" .. job.kind}, util.gps(target, surface)})
    elseif job.kind == "medium" then
        util.say({"bnl.falling-warning-medium", {"bnl.falling-size-" .. job.kind}})
    end
    scheduler.at(tick + cfg.warning - cfg.flight, "falling-launch", job)
    M.sound_before(surface, target, tick + cfg.warning - cfg.flight)
end)

scheduler.handler("falling-launch", function(job)
    local surface = game.get_surface(job.surface)
    if surface then M.launch(surface, job.target, job.kind, {recorder = job.recorder}) end
end)

local function cargo(state, wreck, kind)
    local picks = cfg.picks[kind]
    local inventory = wreck.get_inventory(defines.inventory.chest)
    if not (picks and inventory) then return end
    for _ = 1, util.int(picks) do
        local entry = cfg.cargo[math.random(#cfg.cargo)]
        if util.item_exists(entry[1]) then
            local count = util.int({entry[2], entry[3]})
            inventory.insert({name = entry[1], count = count, quality = quality.of(state, entry[1])})
        end
    end
end

-- A straggler lands: a new start wreck with loot and ammo, often on fire.
local function land_debris(surface, position, kind, data)
    local names = {}
    for _, name in ipairs(cfg.names[kind] or {}) do
        if util.entity_exists(name) then names[#names + 1] = name end
    end
    if not names[1] then return end
    if data and data.recorder then
        -- the recorder needs a container
        local containers = {}
        for _, name in ipairs(names) do
            if prototypes.entity[name].type == "container" then containers[#containers + 1] = name end
        end
        if containers[1] then names = containers end
    end
    local name = names[math.random(#names)]
    local spot = surface.find_non_colliding_position(name, position, 8, 0.5) or position
    util.clear(surface, util.area(spot, 2))
    local wreck = surface.create_entity({name = name, position = spot, force = "neutral", create_build_effect_smoke = false})
    if not wreck then return end
    local state = storage.shipwreck
    if state then
        start.mark(state, wreck)
        if wreck.type == "container" then cargo(state, wreck, kind) end
    end
    if data and data.recorder and wreck.type == "container" then
        wreck.insert({name = "bnl-flight-recorder", count = 1})
        tags.set("recorder", util.player_force(), surface, wreck.position, "recorder", {type = "item", name = "bnl-flight-recorder"})
        util.say({"bnl.recorder-signal", util.gps(wreck.position, surface)})
    end
    local rec = fire.track(wreck, true)
    if rec and math.random() < cfg.ignite_chance then fire.ignite(rec) end
end

for _, kind in ipairs({"small", "medium", "big"}) do
    M.landers[kind] = function(surface, position, data) land_debris(surface, position, kind, data) end
end

local function on_trigger(event)
    local id = event.effect_id
    if id:sub(1, 11) ~= "bnl-impact-" then return end
    local kind = id:sub(12)
    local surface = game.get_surface(event.surface_index)
    local position = event.target_position or event.source_position
    if not (surface and position) then return end
    local incoming = storage.bnl and storage.bnl.falling and storage.bnl.falling.incoming
    local data
    if incoming then
        for i, rec in ipairs(incoming) do
            if rec.surface == event.surface_index and rec.kind == kind
                and math.abs(rec.target.x - position.x) < 2 and math.abs(rec.target.y - position.y) < 2 then
                data = rec.data
                table.remove(incoming, i)
                break
            end
        end
        -- forget lost flights (a projectile destroyed in the air)
        for i = #incoming, 1, -1 do
            if incoming[i].tick + 3600 < event.tick then table.remove(incoming, i) end
        end
    end
    if kind ~= "pod" then
        -- no position: every player hears it at full volume, however far the piece fell
        game.play_sound({path = kind == "small" and "bnl-impact-boom-small" or "bnl-impact-boom-big", volume_modifier = 1})
    end
    local lander = M.landers[kind]
    if lander then lander(surface, position, data) end
end

events.on(defines.events.on_script_trigger_effect, on_trigger)

return M
