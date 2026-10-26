-- Reactor compartment: the holed core of the ship. Repaired to full health it gives
-- P(t) = Pmax * (1 - t/T)^2 (t = time since the landing): 10 MW at the start, 1 MW at 10 minutes,
-- zero at T = 10 min / (1 - sqrt(1/10)) ~ 14.6 min. Until then it leaks radiation around (less when
-- repaired), cannot be mined or destroyed. Cold, it becomes a hull to take apart (with an antenna
-- part). The job runs every 5 s only while the core is hot.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local M = {}
local cfg = config.reactor

local T = 10 * 3600 / (1 - math.sqrt(cfg.at_ten_minutes_mw / cfg.power_mw))

local function power_mw(tick)
    if tick >= T then return 0 end
    local k = 1 - tick / T
    return cfg.power_mw * k * k
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
    if util.since_landing() >= T then
        M.cool(rec)
    else
        scheduler.after(1, "reactor")
    end
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
    local p = power_mw(util.since_landing())
    if p <= 0 then
        M.cool(rec)
        return
    end
    local repaired = entity.health >= entity.max_health - 0.5
    if repaired and not rec.repaired then
        rec.repaired = true
        util.say({"bnl.reactor-online", string.format("%.1f", p), util.gps(entity.position, entity.surface)})
    end
    entity.power_production = rec.repaired and p * 1000000 / 60 or 0
    if rec.label and rec.label.valid then
        rec.label.text = rec.repaired and {"bnl.reactor-label", string.format("%.2f", p)} or {"bnl.reactor-label-broken"}
    end
    radiate(entity, cfg.radiation_damage * p / cfg.power_mw * (rec.repaired and 0.5 or 1))
    scheduler.after(cfg.interval, "reactor")
end)

return M
