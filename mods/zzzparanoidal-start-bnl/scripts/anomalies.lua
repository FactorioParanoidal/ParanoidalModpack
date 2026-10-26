-- Landing anomaly: one per map (map setting: random, none or a fixed one), told in the landing
-- scanner report. Every anomaly ends by itself and leaves nothing scheduled:
-- * long night: the first nights are twice as long (daytime frozen at midnight for half a day);
-- * magnetic storm: radars are jammed for a minute every few minutes until a technology;
-- * rich vein: the ship struck a deposit of the rarest ore near the crash site;
-- * quiet planet: peaceful for two hours, then the whole planet wakes up at once;
-- * dust storms: a warning, then a one-time pollution cloud in a chunk near the base.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local events = require("scripts.events")
local M = {}
local cfg = config.anomalies

local function state()
    return storage.bnl and storage.bnl.anomaly
end

function M.init()
    if storage.bnl.anomaly then return end
    local setting = settings.global["bnl-start-anomaly"]
    local value = setting and setting.value or "random"
    if value == "random" then value = cfg.list[math.random(#cfg.list)] end
    storage.bnl.anomaly = {name = value ~= "none" and value or nil}
end

-- long night ---------------------------------------------------------------------------------
local function next_midnight(surface)
    local day = surface.ticks_per_day
    local d = surface.daytime
    local until_midnight = ((0.5 - d) % 1) * day
    if until_midnight < 60 then until_midnight = until_midnight + day end
    return game.tick + math.floor(until_midnight)
end

scheduler.handler("night-freeze", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    surface.daytime = 0.5
    surface.freeze_daytime = true
    scheduler.after(math.floor(surface.ticks_per_day / 2), "night-thaw", job)
end)

scheduler.handler("night-thaw", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    surface.freeze_daytime = false
    job.left = job.left - 1
    if job.left > 0 then
        scheduler.at(next_midnight(surface), "night-freeze", job)
    else
        util.say({"bnl.anomaly-long-night-end"})
    end
end)

-- magnetic storm -----------------------------------------------------------------------------
local function storm_over(force)
    local tech = force.technologies[cfg.magnetic_storm.until_technology]
    return not tech or tech.researched
end

local function radars(surface, force)
    local names = {}
    for _, name in ipairs(config.radars) do
        if prototypes.entity[name] then names[#names + 1] = name end
    end
    return surface.find_entities_filtered({name = names, force = force})
end

scheduler.handler("storm-start", function(job)
    local surface = game.get_surface(job.surface)
    local force = util.player_force()
    if not surface or storm_over(force) then
        util.say({"bnl.anomaly-magnetic-storm-end"})
        return
    end
    local jammed = {}
    for _, radar in pairs(radars(surface, force)) do
        if not radar.disabled_by_script then
            radar.disabled_by_script = true
            jammed[#jammed + 1] = radar
        end
    end
    if jammed[1] then util.say({"bnl.anomaly-magnetic-storm-now"}, nil, force) end
    scheduler.after(util.int(cfg.magnetic_storm.length), "storm-stop", {surface = job.surface, jammed = jammed})
end)

scheduler.handler("storm-stop", function(job)
    for _, radar in ipairs(job.jammed) do
        if radar.valid then radar.disabled_by_script = false end
    end
    scheduler.after(util.int(cfg.magnetic_storm.every), "storm-start", {surface = job.surface})
end)

-- rich vein ----------------------------------------------------------------------------------
local function rarest_ore(surface, center)
    local best, best_count
    for _, name in ipairs(cfg.rich_vein.ores) do
        local prototype = prototypes.entity[name]
        if prototype and prototype.type == "resource" then
            local count = surface.count_entities_filtered({name = name, position = center, radius = 160, limit = 2000})
            if not best_count or count < best_count then best, best_count = name, count end
        end
    end
    return best
end

local function place_vein(surface)
    local spec = cfg.rich_vein
    local ship = util.ship_position()
    local ore = rarest_ore(surface, ship)
    if not ore then return nil end
    local away = util.trail_angle() + 0.3 + math.random() * 0.4
    local center = util.add(ship, util.vector(away, util.int(spec.distance)))
    local r = util.int(spec.radius)
    local placed = 0
    for x = math.floor(center.x - r), math.floor(center.x + r) do
        for y = math.floor(center.y - r * 0.7), math.floor(center.y + r * 0.7) do
            local dx, dy = (x + 0.5 - center.x) / r, (y + 0.5 - center.y) / (r * 0.7)
            local d = dx * dx + dy * dy
            if d <= 1 - 0.25 * math.random() then
                local p = {x = x + 0.5, y = y + 0.5}
                local tile = surface.get_tile(x, y)
                if tile.valid and not tile.collides_with("water_tile")
                    and surface.count_entities_filtered({type = "resource", position = p, radius = 0.4, limit = 1}) == 0 then
                    local amount = math.floor(util.float(spec.amount) * (1.2 - 0.6 * d))
                    if surface.create_entity({name = ore, position = p, amount = amount, snap_to_tile_center = true}) then
                        placed = placed + 1
                    end
                end
            end
        end
    end
    return placed > 0 and ore or nil, center
end

-- quiet planet -------------------------------------------------------------------------------
scheduler.handler("quiet-end", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    surface.peaceful_mode = false
    util.say({"bnl.anomaly-quiet-planet-end"}, "utility/alert_destroyed")
    local rampant = remote.interfaces.rampantFixed
    if rampant and rampant.strikePosition_ExtCtrl then
        pcall(remote.call, "rampantFixed", "strikePosition_ExtCtrl",
            {surfaceIndex = surface.index, position = util.ship_position(), units = 60})
    end
end)

-- dust storms --------------------------------------------------------------------------------
local function storm_center(surface)
    local players = {}
    for _, player in pairs(game.connected_players) do
        if player.surface == surface and player.character then players[#players + 1] = player end
    end
    local base = players[1] and util.pos(players[math.random(#players)].character.position) or util.ship_position()
    local p = util.add(base, util.vector(math.random(), util.float(cfg.dust_storms.distance)))
    return {x = math.floor(p.x / 32) * 32 + 16, y = math.floor(p.y / 32) * 32 + 16}
end

scheduler.handler("dust-warn", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    local center = storm_center(surface)
    job.center = center
    util.say({"bnl.anomaly-dust-storm-warning", util.gps(center, surface)})
    scheduler.after(cfg.dust_storms.warning, "dust-hit", job)
end)

scheduler.handler("dust-hit", function(job)
    local surface = game.get_surface(job.surface)
    if not surface then return end
    surface.pollute(job.center, cfg.dust_storms.pollution)
    job.left = job.left - 1
    if job.left > 0 then
        scheduler.after(util.int(cfg.dust_storms.every) - cfg.dust_storms.warning, "dust-warn", job)
    else
        util.say({"bnl.anomaly-dust-storms-end"})
    end
end)

-- start --------------------------------------------------------------------------------------
-- Called when the crash site is ready; the report goes to the journal.
function M.start(surface)
    local s = state()
    if not (s and s.name) or s.started then return end
    s.started = true
    local name = s.name
    local params = {}
    if name == "long-night" then
        scheduler.at(next_midnight(surface), "night-freeze", {surface = surface.index, left = cfg.long_night.nights})
    elseif name == "magnetic-storm" then
        scheduler.after(util.int(cfg.magnetic_storm.every), "storm-start", {surface = surface.index})
        params = {{"technology-name." .. cfg.magnetic_storm.until_technology}}
    elseif name == "rich-vein" then
        local ore, center = place_vein(surface)
        if not ore then
            s.name = nil
            return
        end
        params = {{"entity-name." .. ore}, util.gps(center, surface)}
        s.vein = {ore = ore, center = center, surface = surface.index} -- scripts/geology.lua
    elseif name == "quiet-planet" then
        if surface.peaceful_mode then
            s.name = nil
            return
        end
        surface.peaceful_mode = true
        scheduler.after(cfg.quiet_planet.duration, "quiet-end", {surface = surface.index})
    elseif name == "dust-storms" then
        scheduler.at(game.tick + cfg.dust_storms.first, "dust-warn", {surface = surface.index, left = cfg.dust_storms.count})
    end
    journal.add("anomaly-" .. name, params)
end

return M
