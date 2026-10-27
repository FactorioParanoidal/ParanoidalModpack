-- BnL insurance: the first radar catches a BnL broadcast, then supply pods (iron chests with one
-- kind of items, sometimes advertising) fall near the radar at growing intervals, sometimes far off.
-- After the last pod, or once the end technology is researched, the insurance is cancelled by letter
-- and nothing is scheduled any more. The biologist gets a big bio farm the same way.
-- The pod contents are a draft (config.pods.contents) for agreement with the user.
local config = require("bnl-config")
local util = require("scripts.util")
local scheduler = require("scripts.scheduler")
local journal = require("scripts.journal")
local falling = require("scripts.falling")
local events = require("scripts.events")
local tags = require("scripts.tags")
local M = {}
local cfg = config.pods

local WARNING = 8 * 60
local CHEST = "iron-chest"

local function state()
    return storage.bnl and storage.bnl.pods
end

function M.init()
    storage.bnl.pods = storage.bnl.pods or {index = 0, slots = {}}
end

local function generated(surface, p)
    return surface.is_chunk_generated({x = math.floor(p.x / 32), y = math.floor(p.y / 32)})
end

local function land_ok(surface, p)
    if not generated(surface, p) then return false end
    local tile = surface.get_tile(p.x, p.y)
    return tile.valid and not tile.collides_with("water_tile")
end

local function target_near(surface, center, range)
    for _ = 1, 25 do
        local p = util.add(center, util.vector(math.random(), util.float(range)))
        if land_ok(surface, p) then return p end
    end
    return nil
end

-- Announces a pod and launches it after the warning; items = {name, min, max}, {list = {entries}}
-- or {stacks = {{name, count, quality}}} (a reward rolled in advance, scripts/loot.lua).
function M.drop(surface, center, items, range, message)
    local target = target_near(surface, center, range or cfg.distance) or target_near(surface, center, {8, 30})
    if not target then return end
    falling.warn(surface, target, "pod", WARNING + 150)
    falling.shadow(surface, target, "pod", game.tick + WARNING + config.falling.flight)
    util.say({message or "bnl.pod-incoming", util.gps(target, surface)})
    scheduler.after(WARNING, "pod-launch", {surface = surface.index, target = target, items = items})
    falling.sound_before(surface, target, game.tick + WARNING)
end

scheduler.handler("pod-launch", function(job)
    local surface = game.get_surface(job.surface)
    if surface then falling.launch(surface, job.target, "pod", {items = job.items}) end
end)

falling.landers.pod = function(surface, position, data)
    local spot = surface.find_non_colliding_position(CHEST, position, 6, 0.5)
    if not spot then return end
    util.clear(surface, util.area(spot, 1))
    local chest = surface.create_entity({name = CHEST, position = spot, force = "player", create_build_effect_smoke = false})
    if not chest then return end
    local items = data and data.items
    if items and items.stacks then
        for _, stack in ipairs(items.stacks) do
            if util.item_exists(stack.name) then
                local q = prototypes.quality[stack.quality or "normal"] and stack.quality or "normal"
                local n = chest.insert({name = stack.name, count = stack.count, quality = q})
                if n < stack.count then
                    surface.spill_item_stack({position = spot, stack = {name = stack.name, count = stack.count - n, quality = q},
                        enable_looted = true, allow_belts = false})
                end
            end
        end
        items = nil
    end
    for _, entry in ipairs(items and (items.list or {items}) or {}) do
        if util.item_exists(entry[1]) then chest.insert({name = entry[1], count = util.int({entry[2], entry[3]})}) end
    end
    if items and items[1] == "bnl-advertising-flyer" then
        util.say({"bnl.flyer-pod", {"bnl.flyer-" .. math.random(4)}, util.gps(spot, surface)})
    end
    local s = state()
    if s then
        local slot = tags.set(nil, chest.force, surface, spot, "pod", {type = "item", name = CHEST})
        s.slots[script.register_on_object_destroyed(chest)] = slot
    end
end

local function pick_contents()
    if math.random() < cfg.joke_chance and util.item_exists(cfg.joke[1]) then return cfg.joke end
    local list = {}
    for _, entry in ipairs(cfg.contents) do
        if util.item_exists(entry[1]) then list[#list + 1] = entry end
    end
    return list[1] and list[math.random(#list)] or nil
end

local function finish(key)
    local s = state()
    if s.ended then return end
    s.ended = true
    scheduler.cancel("pod")
    if s.started then journal.add(key) end
end

scheduler.handler("pod", function()
    local s = state()
    if not s or s.ended then return end
    local surface = game.get_surface(s.surface)
    if not surface then return end
    s.index = s.index + 1
    local contents = pick_contents()
    if contents then
        local far = math.random() < cfg.far_chance
        M.drop(surface, s.radar, contents, far and cfg.far_distance or cfg.distance, far and "bnl.pod-incoming-far" or nil)
    end
    -- the SOS of the distress beacon may add pods (s.bonus), they come at the last interval
    if s.index > #cfg.intervals + (s.bonus or 0) then
        finish("insurance-end")
    else
        scheduler.after(cfg.intervals[s.index] or cfg.intervals[#cfg.intervals], "pod")
    end
end)

-- The insurance starts: pods fall around `position` (the first radar or the distress beacon).
local function start(surface, position, key)
    local s = state()
    s.started = true
    s.radar = util.pos(position)
    s.surface = surface.index
    journal.add(key, {util.gps(position, surface)})
    scheduler.after(util.int(cfg.first_delay), "pod")
end

local RADARS = {}
for _, name in ipairs(config.radars) do RADARS[name] = true end

local function on_built(event)
    local entity = event.entity
    local s = state()
    -- by name: the build events share one filter with the distress beacon (a radar that only
    -- transmits, scripts/distress.lua), which must not count as the first radar
    if not (s and entity and entity.valid and RADARS[entity.name]) then return end
    if s.started or s.ended or entity.force.name ~= "player" or not util.enabled("bnl-start-supply-pods") then return end
    start(entity.surface, entity.position, "insurance-start")
end

-- The SOS reached BnL (scripts/distress.lua): the crash becomes an insurance case without a radar,
-- or an insurance already running owes `bonus` more pods. Nothing once the insurance has ended.
function M.sos(surface, position, bonus)
    local s = state()
    if not s or s.ended or not util.enabled("bnl-start-supply-pods") then return end
    if not s.started then
        start(surface, position, "insurance-sos")
        return
    end
    s.bonus = (s.bonus or 0) + bonus
    util.say({"bnl.insurance-bonus", bonus})
end

local radar_filter = {}
for _, name in ipairs(config.radars) do radar_filter[#radar_filter + 1] = {filter = "name", name = name} end
for _, id in ipairs({"on_built_entity", "on_robot_built_entity", "script_raised_built", "script_raised_revive"}) do
    events.on(defines.events[id], on_built, radar_filter)
end

events.on(defines.events.on_research_finished, function(event)
    local s = state()
    if s and event.research.name == cfg.end_technology and not s.ended then finish("insurance-cancelled") end
end)

-- The biologist's big bio farm, delivered near the player at config.pods.biofarm_tick.
function M.schedule_biofarm(player_index)
    if not util.item_exists(cfg.biofarm[1]) then return end
    scheduler.at(math.max(game.tick + 3600, util.landing_tick() + cfg.biofarm_tick), "pod-biofarm", {player = player_index})
end

scheduler.handler("pod-biofarm", function(job)
    local player = game.get_player(job.player)
    if not (player and player.valid) then return end
    local center = player.character and player.character.position or player.position
    M.drop(player.surface, util.pos(center), cfg.biofarm, {15, 35}, "bnl.pod-biofarm")
end)

function M.on_destroyed(registration)
    local s = state()
    local slot = s and s.slots[registration]
    if slot then
        s.slots[registration] = nil
        tags.remove(slot)
    end
end

return M
