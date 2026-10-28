-- Multiplayer: every player after the first, created in the first minutes, lands in an own escape
-- pod 100-200 tiles from the ship, each with a different kit (drills, generator, weapons, tools).
-- First find each other. The kit is put into the pod only after the player has stayed connected for
-- config.probation.online.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
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
    -- the kit comes after the probation (config.probation): a quick extra login gets an empty pod
    scheduler.after(math.max(60, util.probation_left(player)), "capsule-kit",
        {pod = pod, player = player.index, kit = (n - 1) % #cfg.kits + 1})
    surface.create_entity({name = "medium-scorchmark-tintable", position = spot})
    local stand = surface.find_non_colliding_position("character", util.add(spot, {x = 0, y = 2.5}), 10, 0.5)
    if stand then player.teleport(stand, surface) end
    util.say({"bnl.capsule-landed", player.name, math.floor(util.distance(spot, util.ship_position()))})
    if util.probation_left(player) > 0 then
        player.print({"bnl.probation-capsule", math.ceil(util.probation_left(player) / 3600)}, {color = util.CHAT_COLOR})
    end
end

scheduler.handler("capsule-kit", function(job)
    local pod = job.pod
    local player = game.get_player(job.player)
    if not (pod and pod.valid and player and player.valid) or util.since_landing() > config.probation.give_up then return end
    local wait = player.connected and util.probation_left(player) or config.probation.check
    if wait > 0 then
        scheduler.after(math.max(wait, config.probation.check), "capsule-kit", job)
        return
    end
    for _, entry in ipairs(cfg.kits[job.kit] or {}) do
        if util.item_exists(entry[1]) then pod.insert({name = entry[1], count = entry[2]}) end
    end
    player.print({"bnl.probation-capsule-open", util.gps(pod.position, pod.surface)}, {color = util.CHAT_COLOR})
end)

return M
