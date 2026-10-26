-- Look of a falling piece in the air (scripts/falling.lua launches it). The engine projectile only
-- carries the impact and its ground shadow (its own picture is empty); the piece is drawn here along
-- a straight descent from config.falling.fx.start_height at the source down to the impact point,
-- with a long flame tail pointing back the way it came (west-south-west) and black smoke left
-- along the path it has flown. Everything follows the projectile entity, so it moves smoothly;
-- one on_tick handler exists only while something is in the air (2 s per piece).
local config = require("bnl-config")
local events = require("scripts.events")
local M = {}
local cfg = config.falling
local fx = cfg.fx

local function flights()
    local f = storage.bnl and storage.bnl.falling
    return f and f.flights
end

local function destroy(rec)
    for _, key in ipairs({"sprite", "flame", "core", "light"}) do
        local object = rec[key]
        if object and object.valid then object.destroy() end
    end
end

-- Factorio orientation (0 = north, 0.25 = east) of a screen vector.
local function orientation_of(x, y)
    return (math.atan2(x, -y) / (2 * math.pi)) % 1
end

-- Starts the look of `projectile` flying from `from` to `to` in `ticks` ticks.
function M.start(projectile, from, to, kind, ticks)
    local spec = fx.kinds[kind]
    if not (spec and projectile and projectile.valid) then return end
    local f = storage.bnl.falling
    f.flights = f.flights or {}
    local surface = projectile.surface
    local dx, dy = to.x - from.x, to.y - from.y
    local length = math.sqrt(dx * dx + dy * dy)
    if length <= 0 then return end
    local h0 = fx.start_height * length / cfg.source_distance
    -- screen vector back along the flight: towards the source on the ground and up by the height
    local bx, by = -dx / length, -dy / length - h0 / length
    local b = math.sqrt(bx * bx + by * by)
    bx, by = bx / b, by / b
    local rec = {entity = projectile, kind = kind, start = game.tick, ticks = ticks, h0 = h0, bx = bx, by = by,
        spin = (math.random() * 2 - 1) * fx.spin, turn = math.random()}
    local orient = orientation_of(bx, by)
    rec.flame = rendering.draw_animation({animation = "bnl-torch-blaze", surface = surface, target = projectile,
        orientation = orient, x_scale = spec.width, y_scale = spec.tail / fx.blaze_tiles, render_layer = "air-object",
        animation_speed = 1.6, animation_offset = math.random(0, 89)})
    rec.core = rendering.draw_animation({animation = "bnl-torch-refinery", surface = surface, target = projectile,
        orientation = orient, x_scale = spec.width * 1.3, y_scale = spec.tail * 0.6 / fx.refinery_tiles,
        render_layer = "air-object", animation_speed = 1.4, animation_offset = math.random(0, 59)})
    rec.sprite = rendering.draw_sprite({sprite = "bnl-falling-piece-" .. kind, surface = surface, target = projectile,
        orientation = rec.turn, render_layer = "air-object"})
    rec.light = rendering.draw_light({sprite = "utility/light_medium", surface = surface, target = projectile,
        scale = spec.light, intensity = 0.9, color = {r = 1, g = 0.5, b = 0.15}})
    f.flights[#f.flights + 1] = rec
    M.update(rec, game.tick)
    events.refresh()
end

-- Height and objects of one piece at `tick`; false when it is gone.
function M.update(rec, tick)
    local entity = rec.entity
    if not entity.valid then
        destroy(rec)
        return false
    end
    local t = math.min(1, (tick - rec.start) / rec.ticks)
    local h = rec.h0 * (1 - t)
    local spec = fx.kinds[rec.kind]
    local up = {0, -h}
    -- the flame base sits on the piece, the tail reaches back half its length from the centre
    local half = spec.tail / 2
    if rec.sprite.valid then
        rec.sprite.target = {entity = entity, offset = up}
        rec.sprite.orientation = (rec.turn + rec.spin * t) % 1
    end
    if rec.flame.valid then
        rec.flame.target = {entity = entity, offset = {rec.bx * half, -h + rec.by * half}}
    end
    if rec.core.valid then
        local q = half * 0.6
        rec.core.target = {entity = entity, offset = {rec.bx * q, -h + rec.by * q}}
    end
    if rec.light.valid then rec.light.target = {entity = entity, offset = up} end
    -- black smoke where the piece has just been: it stays behind and drifts with the wind
    local p = entity.position
    local surface = entity.surface
    for _ = 1, spec.smoke do
        local back = spec.tail * (0.6 + 0.5 * math.random())
        local j = fx.smoke_jitter
        surface.create_trivial_smoke({name = "bnl-trail-smoke", position = {
            x = p.x + rec.bx * back + (math.random() * 2 - 1) * j,
            y = p.y - h + rec.by * back + (math.random() * 2 - 1) * j}})
    end
    return true
end

local function on_tick(event)
    local list = flights()
    if list then
        for i = #list, 1, -1 do
            if not M.update(list[i], event.tick) then table.remove(list, i) end
        end
    end
    if not (list and list[1]) then events.refresh() end
end

events.dynamic(defines.events.on_tick, on_tick, function()
    local list = flights()
    return list ~= nil and list[1] ~= nil
end)

return M
