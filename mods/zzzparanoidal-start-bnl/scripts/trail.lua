-- Debris trail: the ship broke up while coming in from the west-south-west. Small debris lies along
-- the line, the detached compartments further out, the previous expedition aside. Every object is
-- placed when the 3x3 chunks around it are generated (requested at once); the chunk handler is
-- registered only while something waits. Compartments send an emergency beacon (chart tag); the
-- flight recorder tells what each of them is.
local config = require("bnl-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local events = require("scripts.events")
local reactor = require("scripts.reactor")
local tags = require("scripts.tags")
local M = {}
local cfg = config.trail

local function state()
    return storage.bnl.trail
end

function M.init()
    storage.bnl.trail = storage.bnl.trail or {objects = {}, waiting = {}, next_id = 0, placed = {}}
end

local function chunk_of(p)
    return math.floor(p.x / 32), math.floor(p.y / 32)
end

local function ready(surface, p)
    local cx, cy = chunk_of(p)
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not surface.is_chunk_generated({x = cx + dx, y = cy + dy}) then return false end
        end
    end
    return true
end

local place -- forward

local function queue(surface, obj)
    local t = state()
    t.next_id = t.next_id + 1
    obj.id = t.next_id
    obj.surface = surface.index
    if ready(surface, obj.position) then
        place(obj)
        return
    end
    t.objects[obj.id] = obj
    local cx, cy = chunk_of(obj.position)
    for dx = -1, 1 do
        for dy = -1, 1 do
            if not surface.is_chunk_generated({x = cx + dx, y = cy + dy}) then
                local key = (cx + dx) .. ":" .. (cy + dy)
                local list = t.waiting[key]
                if not list then
                    list = {}
                    t.waiting[key] = list
                end
                list[#list + 1] = obj.id
            end
        end
    end
    surface.request_to_generate_chunks(obj.position, 1)
end
M.queue = queue

local function point(origin, angle, distance, side)
    local along = util.vector(angle, distance)
    local across = util.vector(angle + 0.25, side)
    return {x = origin.x + along.x + across.x, y = origin.y + along.y + across.y}
end

function M.plan(surface)
    local origin = util.ship_position()
    local angle = util.trail_angle()
    if util.enabled("bnl-start-debris-trail") then
        local length = util.int(cfg.debris_to)
        local d = cfg.debris_from
        while d < length do
            local side = util.float(cfg.debris_side) * (math.random() < 0.5 and -1 or 1)
            local name = util.weighted(cfg.debris, 2)[1]
            if util.entity_exists(name) then
                queue(surface, {kind = "debris", name = name, position = point(origin, angle, d, side)})
            end
            d = d + util.int(cfg.debris_step)
        end
        for _, spec in ipairs(cfg.compartments) do
            queue(surface, {kind = "compartment", key = spec.key,
                position = point(origin, angle, util.int(spec.distance), util.float(spec.side))})
        end
    end
    local e = config.expedition
    local away = angle + e.min_angle + math.random() * (1 - 2 * e.min_angle)
    queue(surface, {kind = "expedition", angle = away, position = util.add(origin, util.vector(away, util.int(e.distance)))})
    events.refresh()
end

local function fill(entity, items)
    local inventory = entity.get_inventory(defines.inventory.chest)
    local state_ = storage.shipwreck
    for _, entry in ipairs(items or {}) do
        local name = entry[1]
        if util.item_exists(name) then
            local q = entry.quality
            if q and not prototypes.quality[q] then q = "normal" end
            if not q then q = state_ and quality.of(state_, name) or "normal" end
            if name:sub(1, 4) == "bnl-" then q = "normal" end
            inventory.insert({name = name, count = util.int({entry[2], entry[3]}), quality = q})
        end
    end
end

local function spec_of(key)
    for _, spec in ipairs(cfg.compartments) do
        if spec.key == key then return spec end
    end
end

local function shore(surface, p)
    local tiles = surface.find_tiles_filtered({position = p, radius = cfg.water_search, collision_mask = "water_tile", limit = 600})
    local best, best_d
    for _, tile in pairs(tiles) do
        local tp = tile.position
        local land = false
        for _, o in ipairs({{3, 0}, {-3, 0}, {0, 3}, {0, -3}}) do
            local near = surface.get_tile(tp.x + o[1], tp.y + o[2])
            if near.valid and not near.collides_with("water_tile") then
                land = true
                break
            end
        end
        if land then
            local d = (tp.x - p.x) ^ 2 + (tp.y - p.y) ^ 2
            if not best_d or d < best_d then best, best_d = tp, d end
        end
    end
    return best and {x = best.x + 0.5, y = best.y + 0.5} or nil
end

-- No lake within reach: the bay dug a crater and ground water filled it. The bay lies at the edge
-- (deep water behind it, shallow water around it), so it can be reached from the dry side.
local function crater_pond(surface, p)
    if not (prototypes.tile.water and prototypes.tile["water-shallow"]) then return nil end
    local center = util.add(p, util.vector(math.random(), 4))
    local r = 6 + 2 * math.random()
    local phase = math.random() * 2 * math.pi
    local tiles = {}
    for x = math.floor(center.x - r - 1), math.ceil(center.x + r + 1) do
        for y = math.floor(center.y - r - 1), math.ceil(center.y + r + 1) do
            local dx, dy = x + 0.5 - center.x, y + 0.5 - center.y
            local edge = r * (0.85 + 0.15 * math.sin(math.atan2(dy, dx) * 3 + phase))
            local d = math.sqrt(dx * dx + dy * dy) / edge
            if d <= 1 then tiles[#tiles + 1] = {name = d < 0.55 and "water" or "water-shallow", position = {x, y}} end
        end
    end
    for _, entity in pairs(surface.find_entities_filtered({position = center, radius = r + 1.5, type = {"resource", "tree", "simple-entity"}})) do
        entity.destroy()
    end
    surface.set_tiles(tiles, true, true, true, false)
    return p
end

local function guard(surface, center)
    local g = cfg.guard
    for _, part in ipairs({g.spawner, g.worms}) do
        local name = part[1]
        if util.entity_exists(name) then
            for _ = 1, part[2] do
                local p = util.add(center, util.vector(math.random(), util.float({part[3], part[4]})))
                local spot = surface.find_non_colliding_position(name, p, 10, 1)
                if spot then surface.create_entity({name = name, position = spot, force = "enemy"}) end
            end
        end
    end
end

local function tag_compartment(key, entity)
    local force = util.player_force()
    util.chart(force, entity.surface, entity.position, 24)
    tags.set("compartment-" .. key, force, entity.surface, entity.position, state().revealed and key or "beacon",
        {type = "item", name = "bnl-antenna-part"})
end

local COMPARTMENT_TRIES = 20
local COMPARTMENT_STEP = 48 -- tiles further out along the trail per try

local function place_compartment(surface, obj)
    local spec = spec_of(obj.key)
    local name = spec and spec.name
    if not (name and util.entity_exists(name)) then return end
    local p = obj.position
    local water = spec.water and shore(surface, p)
    if water then p = water end
    util.clear(surface, util.area(p, 8))
    if spec.water and not water then water = crater_pond(surface, p) end
    local spot = water or surface.find_non_colliding_position(name, p, 30, 1)
    if not spot then
        -- water all around (a lake or sea): further out along the trail, on land; the old drop in
        -- place only when there is no land after every try (the antenna parts must stay in the game)
        obj.tries = (obj.tries or 0) + 1
        if obj.tries <= COMPARTMENT_TRIES then
            queue(surface, {kind = "compartment", key = obj.key, tries = obj.tries,
                position = util.add(p, util.vector(util.trail_angle(), COMPARTMENT_STEP))})
            events.refresh()
            return
        end
        log("zzzparanoidal-start-bnl: no land for the " .. obj.key .. " compartment, placed in the water")
        spot = p
    end
    local entity = surface.create_entity({name = name, position = spot,
        force = obj.key == "reactor" and "player" or "neutral", create_build_effect_smoke = false})
    if not entity then return end
    if spec.items then fill(entity, spec.items) end
    if spec.guard then guard(surface, entity.position) end
    if obj.key == "reactor" then reactor.setup(entity) end
    state().placed[obj.key] = entity
    tag_compartment(obj.key, entity)
end

local function place_expedition(surface, obj)
    local name = "bnl-old-expedition"
    if not util.entity_exists(name) then return end
    util.clear(surface, util.area(obj.position, 12))
    local spot = surface.find_non_colliding_position(name, obj.position, 40, 1)
    if not spot then
        -- water (a lake or sea): try further out along the same direction, on land
        obj.tries = (obj.tries or 0) + 1
        if obj.angle and obj.tries <= 20 then
            queue(surface, {kind = "expedition", angle = obj.angle, tries = obj.tries,
                position = util.add(obj.position, util.vector(obj.angle, 64))})
            events.refresh()
        end
        return
    end
    local ship = surface.create_entity({name = name, position = spot, force = "neutral", create_build_effect_smoke = false})
    if not ship then return end
    fill(ship, config.expedition.items)
    local car = config.expedition.car
    if car and util.entity_exists(car.name) then
        local cp = surface.find_non_colliding_position(car.name, util.add(spot, {x = 0, y = 7}), 15, 1)
        local vehicle = cp and surface.create_entity({name = car.name, position = cp, force = "player"})
        if vehicle then vehicle.health = vehicle.max_health * car.health end
    end
    local t = state()
    t.placed.expedition = ship
    -- the corpse tag appears once the place is charted (or when the recorder is decoded)
    tags.set("expedition", util.player_force(), surface, util.add(spot, {x = 3, y = 5}), "expedition",
        {type = "virtual", name = "signal-info"})
    if t.revealed then util.chart(util.player_force(), surface, spot, 24) end
end

local function place_debris(surface, obj)
    local spot = surface.find_non_colliding_position(obj.name, obj.position, 6, 0.5)
    if not spot then return end
    util.clear(surface, util.area(spot, 2))
    local wreck = surface.create_entity({name = obj.name, position = spot, force = "neutral", create_build_effect_smoke = false})
    if wreck and wreck.type == "container" and math.random() < 0.5 then
        local entry = config.falling.cargo[math.random(#config.falling.cargo)]
        if util.item_exists(entry[1]) then wreck.insert({name = entry[1], count = util.int({entry[2], entry[3]})}) end
    end
    if math.random() < 0.4 and util.entity_exists("small-scorchmark-tintable") then
        surface.create_entity({name = "small-scorchmark-tintable", position = spot})
    end
end

place = function(obj)
    local surface = game.get_surface(obj.surface)
    local t = state()
    t.objects[obj.id] = nil
    if not surface then return end
    if obj.kind == "debris" then
        place_debris(surface, obj)
    elseif obj.kind == "compartment" then
        place_compartment(surface, obj)
    elseif obj.kind == "expedition" then
        place_expedition(surface, obj)
    end
end

local function on_chunk_generated(event)
    local t = storage.bnl.trail
    local p = event.position
    local key = p.x .. ":" .. p.y
    local list = t.waiting[key]
    if not list then return end
    t.waiting[key] = nil
    local surface = event.surface
    for _, id in ipairs(list) do
        local obj = t.objects[id]
        if obj and obj.surface == surface.index and ready(surface, obj.position) then place(obj) end
    end
    if not next(t.waiting) then events.refresh() end
end

events.dynamic(defines.events.on_chunk_generated, on_chunk_generated, function()
    local t = storage.bnl and storage.bnl.trail
    return t ~= nil and next(t.waiting) ~= nil
end)

-- The flight recorder names the beacons and points at the previous expedition.
function M.reveal()
    local t = state()
    t.revealed = true
    for key, entity in pairs(t.placed) do
        if entity.valid then
            if key == "expedition" then
                util.chart(util.player_force(), entity.surface, entity.position, 24)
            else
                tag_compartment(key, entity)
            end
        end
    end
end

function M.compartment(key)
    local t = storage.bnl and storage.bnl.trail
    local entity = t and t.placed[key]
    return entity and entity.valid and entity or nil
end

return M
