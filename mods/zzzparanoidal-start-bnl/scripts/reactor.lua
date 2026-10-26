-- Reactor compartment: the holed core of the ship. Broken, it gives nothing and leaks full
-- radiation. From the moment it is repaired to full health (t = minutes since then):
--   t <= 5:  P = 5 + 10 * (1 - t/5)^2          15 MW -> 5 MW, fast at first;
--   t > 5:   P = 5 * (1 - (t-5)/55)^1.5        slowly down to zero at 60 minutes
-- (numbers from config.reactor), radiation scaled with the power and halved. While hot it cannot be
-- mined or destroyed; cold, it becomes a hull to take apart (with an antenna part). Left broken,
-- the core melts down: config.reactor.meltdown after the landing it blows up like an atomic bomb
-- (the antenna part is thrown out); warning minutes before, a light radiation covers the whole
-- surface and a player thinks something is wrong. The job runs every 5 s only while the core is hot.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local M = {}
local cfg = config.reactor

-- Power in MW `ticks` after the full repair.
local function power_mw(ticks)
    local t = ticks / 3600
    if t >= cfg.life_minutes then return 0 end
    if t <= cfg.knee_minutes then
        local k = 1 - t / cfg.knee_minutes
        return cfg.knee_mw + (cfg.power_mw - cfg.knee_mw) * k * k
    end
    local k = 1 - (t - cfg.knee_minutes) / (cfg.life_minutes - cfg.knee_minutes)
    return cfg.knee_mw * k ^ 1.5
end
M.power_mw = power_mw

local function damage_type()
    return prototypes.damage["uranium-damage"] and "uranium-damage" or "poison"
end

-- Radiation goes through Radioactive-Damage-Reforged when it is loaded (its damage, hazmat suit and
-- Geiger counter); without it the core damages characters around itself every interval.
local RDR = "radioactive_damage"
local function rdr()
    local interface = remote.interfaces[RDR]
    return interface and interface.set_source
end

local MELTDOWN_KEY = "meltdown"

local function meltdown_glow(entity, dps)
    if rdr() then
        remote.call(RDR, "set_source", entity, dps, dps > 0 and cfg.meltdown_radius or 0, nil, MELTDOWN_KEY)
    elseif dps > 0 then
        local kind = damage_type()
        for _, character in pairs(entity.surface.find_entities_filtered({type = "character"})) do
            if character.valid and character.destructible then character.damage(dps * cfg.interval / 60, "neutral", kind) end
        end
    end
end

local function explode(rec)
    local entity = rec.entity
    local surface, position = entity.surface, entity.position
    rec.cold, rec.exploded = true, true
    if rec.light and rec.light.valid then rec.light.destroy() end
    if rec.label and rec.label.valid then rec.label.destroy() end
    if rdr() then
        remote.call(RDR, "set_source", entity, 0)
        remote.call(RDR, "set_source", entity, 0, nil, nil, MELTDOWN_KEY)
    end
    if util.item_exists("bnl-antenna-part") then
        surface.spill_item_stack({position = position, stack = {name = "bnl-antenna-part", count = 1},
            enable_looted = true, allow_belts = false})
    end
    entity.destructible = true
    entity.die()
    if prototypes.entity["atomic-rocket"] then
        surface.create_entity({name = "atomic-rocket", position = position, target = position, speed = 1, force = "neutral"})
    else
        surface.create_entity({name = "massive-explosion", position = position})
    end
    util.say({"bnl.reactor-exploded", util.gps(position, surface)}, false)
end

local function radiate(entity, dose)
    if rdr() then
        local dps = dose > 0.2 and dose * 60 / cfg.interval or 0
        remote.call(RDR, "set_source", entity, dps, cfg.radiation_radius, cfg.geiger_radius)
        return
    end
    if dose <= 0.2 then return end
    local kind = damage_type()
    for _, character in pairs(entity.surface.find_entities_filtered({type = "character", position = entity.position,
        radius = cfg.radiation_radius})) do
        if character.valid and character.destructible then character.damage(dose, "neutral", kind) end
    end
end

function M.setup(entity)
    local s = storage.bnl
    entity.health = entity.max_health * cfg.start_health
    entity.minable_flag = false
    entity.destructible = false
    entity.power_production = 0
    entity.electric_buffer_size = cfg.power_mw * 1000000 / 60 * 3
    local rec = {entity = entity, repaired = false}
    rec.light = rendering.draw_light({sprite = "utility/light_medium", scale = 2.5, intensity = 0.8,
        color = {r = 1, g = 0.35, b = 0.1}, target = {entity = entity, offset = {1.2, -0.8}}, surface = entity.surface})
    rec.label = rendering.draw_text({text = "", surface = entity.surface, target = {entity = entity, offset = {0, -3.6}},
        color = {r = 1, g = 0.6, b = 0.2}, scale = 1.2, alignment = "center", only_in_alt_mode = true})
    s.reactor = rec
    scheduler.after(1, "reactor")
end

function M.cool(rec)
    local entity = rec.entity
    rec.cold = true
    if rec.light and rec.light.valid then rec.light.destroy() end
    if rec.label and rec.label.valid then rec.label.destroy() end
    if not entity.valid then return end
    if rdr() then remote.call(RDR, "set_source", entity, 0) end
    entity.power_production = 0
    entity.minable_flag = true
    entity.destructible = true
    util.say({"bnl.reactor-cold", util.gps(entity.position, entity.surface)})
end

scheduler.handler("reactor", function(_, tick)
    local rec = storage.bnl.reactor
    if not rec or rec.cold then return end
    local entity = rec.entity
    if not entity.valid then
        rec.cold = true
        return
    end
    if not rec.repaired and entity.health >= entity.max_health - 0.5 then
        rec.repaired = true
        rec.repaired_tick = tick
        util.say({"bnl.reactor-online", string.format("%.1f", power_mw(0)), util.gps(entity.position, entity.surface)})
    end
    if rec.repaired and not rec.repaired_tick then rec.repaired_tick = tick end -- repaired on an older version
    if not rec.repaired then
        local left = cfg.meltdown - util.since_landing()
        if left <= 0 then
            explode(rec)
            return
        end
        if left <= cfg.meltdown_warning and not rec.melting then
            rec.melting = true
            game.print({"bnl.reactor-meltdown-hint"}, {color = {r = 1, g = 0.8, b = 0.45}})
        end
        if rec.melting then meltdown_glow(entity, cfg.meltdown_dps) end
    elseif rec.melting then
        rec.melting = nil -- repaired in the last minutes: the meltdown stops
        meltdown_glow(entity, 0)
    end
    local p = rec.repaired and power_mw(tick - rec.repaired_tick) or 0
    if rec.repaired and p <= 0 then
        M.cool(rec)
        return
    end
    entity.power_production = p * 1000000 / 60
    if rec.label and rec.label.valid then
        rec.label.text = rec.repaired and {"bnl.reactor-label", string.format("%.2f", p)} or {"bnl.reactor-label-broken"}
    end
    radiate(entity, rec.repaired and cfg.radiation_damage * p / cfg.power_mw * 0.5 or cfg.radiation_damage)
    scheduler.after(cfg.interval, "reactor")
end)

return M
