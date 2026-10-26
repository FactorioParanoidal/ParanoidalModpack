-- Multiplayer: every player after the first, created in the first minutes, lands in an own escape
-- pod 100-200 tiles from the ship, each with a different kit (drills, generator, weapons, tools).
-- First find each other.
local config = require("bnl-config")
local util = require("scripts.util")
local M = {}
local cfg = config.capsules

local NAME = "bnl-escape-pod"
local GOLDEN = 0.381966 -- turns between pods

function M.on_player_created(player)
    local s = storage.bnl
    if not (s and s.capsules ~= false) then return end
    if player.index == 1 or not game.is_multiplayer() or util.since_landing() > cfg.window then return end
    if not (util.enabled("bnl-start-mp-capsules") and util.entity_exists(NAME)) then return end
    local surface = player.surface
    s.capsule_count = (s.capsule_count or 0) + 1
    local n = s.capsule_count
    local angle = util.trail_angle() + 0.5 + n * GOLDEN
    local p = util.add(util.ship_position(), util.vector(angle, util.float(cfg.distance)))
    if not surface.is_chunk_generated({x = math.floor(p.x / 32), y = math.floor(p.y / 32)}) then
        p = util.add(util.ship_position(), util.vector(angle, 90))
    end
    local spot = surface.find_non_colliding_position(NAME, p, 30, 1)
    if not spot then return end
    util.clear(surface, util.area(spot, 3))
    local pod = surface.create_entity({name = NAME, position = spot, force = player.force, create_build_effect_smoke = false})
    if not pod then return end
    local kit = cfg.kits[(n - 1) % #cfg.kits + 1]
    for _, entry in ipairs(kit) do
        if util.item_exists(entry[1]) then pod.insert({name = entry[1], count = entry[2]}) end
    end
    surface.create_entity({name = "medium-scorchmark-tintable", position = spot})
    local stand = surface.find_non_colliding_position("character", util.add(spot, {x = 0, y = 2.5}), 10, 0.5)
    if stand then player.teleport(stand, surface) end
    util.say({"bnl.capsule-landed", player.name, math.floor(util.distance(spot, util.ship_position()))})
end

return M
