-- Burning wrecks of the start crash. Most loot wrecks carry one kind of hazardous cargo
-- (config.fire.hazards): ammo (frequent cook-offs), fuel barrels (rare bursts, a pool of burning fuel),
-- gas cylinders (a burst cylinder flies off and falls burning), high-tech fuel (burns as the fire's
-- fuel, the fire gets hotter), explosives (one big blast), oxygen (jets of flame, the fire burns twice
-- as fast) or batteries (sparks, a poison cloud).
-- One scheme of fire: what comes down in flames burns for real from the first second (the starliner
-- and the vanilla crash site parts the engine set alight, M.start; falling pieces that land burning,
-- scripts/falling.lua); anything else catches fire only from a real fire of the engine next to it
-- (ground fire, burning trees, cook-offs, fuel thrown into a fire; fire-watch, the first config.fire.watch_until
-- after the landing and while something burns). The fire of a wreck itself is drawn only (it never
-- lights anything); its cook-offs and embers make the real fires that spread. A burning wreck cannot
-- be destroyed by anything else;
-- it loses health steadily until it reaches a random floor of 2-10% of its max health, then the fire
-- goes out and a share of the hazardous cargo left goes off in a last blast; the rest of it is loot.
-- The cargo whose quality can change loses one quality step every 40-70 s of fire (config.fire.
-- step_interval, counted from config.fire.cargo_grace after the landing at the earliest; down to
-- defect -5 at most, materials not below normal), each step may burn a whole stack away;
-- mining loot follows the same steps. Fires from bursts reach player buildings nearby.
-- First put it out, then mine it: while a wreck burns its cargo is held by the fire (a script
-- inventory, the chest is empty and locked: no GUI, no fast transfer, no inserters, no mining).
-- A water barrel poured from the hand (scripts/douse.lua) puts it out and gives the cargo back; the
-- wreck and the spot around it stay wet for config.fire.water.calm: no new fire there, only steam.
local config = require("bnl-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local shipwreck = require("shipwreck-config")
local scheduler = require("scripts.scheduler")
local events = require("scripts.events")
local M = {}
local cfg = config.fire

-- item name -> {kind, spec (the kind's config), damage share, explosion, fire}
local hazard = {}
for kind, spec in pairs(cfg.hazards) do
    if spec.by_size then
        for _, list in pairs(spec.by_size) do
            for _, entry in ipairs(list) do
                hazard[entry[1]] = {kind = kind, spec = spec, damage = entry[5], explosion = entry[6], fire = entry.fire}
            end
        end
    else
        for _, entry in ipairs(spec.items) do
            hazard[entry[1]] = {kind = kind, spec = spec, damage = spec.damage, explosion = spec.explosion}
        end
    end
end
-- Story items of the start never burn: the flight recorder (its research decodes the safe code and
-- names the beacons), the antenna parts of the distress beacon, the note of the previous expedition.
local STORY = {["bnl-flight-recorder"] = true, ["bnl-antenna-part"] = true, ["bnl-engineer-note"] = true}

-- Hazards and story items are not cargo: no quality steps, never burnt away or thrown out.
local function special(name)
    return hazard[name] ~= nil or STORY[name] == true
end

-- Only wrecks and the ship are ever tracked: other entities are rejected by name before any
-- registration (clicks, opened GUIs and the burning cursor ask about everything).
local WRECK = {[shipwreck.ship] = true}
for name in pairs(shipwreck.wrecks) do WRECK[name] = true end

local function state()
    return storage.bnl.fire
end

local clear_visuals, temper_of, light_up -- defined with the visuals below

function M.init()
    storage.bnl.fire = storage.bnl.fire or {wrecks = {}}
end

local function size_of(name)
    if name == shipwreck.ship then return "big" end
    if name:find("big", 1, true) then return "big" end
    if name:find("medium", 1, true) then return "medium" end
    return "small"
end

local function reg_of(entity)
    return (script.register_on_object_destroyed(entity))
end

local function chest(entity)
    return entity.type == "container" and entity.get_inventory(defines.inventory.chest) or nil
end

-- The cargo of a wreck: held by the fire while it burns, else its chest.
local function cargo(rec, entity)
    local held = rec.held
    if held and held.valid then return held end
    return chest(entity)
end

-- Whatever is in the chest of a burning wreck (the cargo when it caught fire, later cargo of the
-- start fill, inserters) goes into the inventory held by the fire.
local function absorb(rec, entity)
    local inventory = chest(entity)
    if not inventory or inventory.is_empty() then return end
    local held = rec.held
    if not (held and held.valid) then
        held = game.create_inventory(#inventory)
        rec.held = held
    end
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read then
            local slot = held.find_empty_stack()
            if not slot then
                held.resize(#held + 1)
                slot = held[#held]
            end
            slot.transfer_stack(stack)
        end
    end
end

-- The fire is out: the cargo goes back into the chest (what does not fit spills next to it) and
-- the wreck can be opened and mined again.
local function release(rec)
    local entity, held = rec.entity, rec.held
    rec.held = nil
    if entity and entity.valid then
        local locked = rec.locked
        if locked then
            if entity.type == "container" then entity.operable = locked.operable end
            entity.minable_flag = locked.minable
        end
        if held and held.valid then
            local inventory = chest(entity)
            for i = 1, #held do
                local stack = held[i]
                if stack.valid_for_read then
                    local slot = inventory and inventory.find_empty_stack()
                    if not (slot and slot.transfer_stack(stack)) and stack.valid_for_read then
                        entity.surface.spill_item_stack({position = entity.position, stack = stack,
                            enable_looted = true, allow_belts = false})
                        stack.clear()
                    end
                end
            end
        end
    end
    rec.locked = nil
    if held and held.valid then held.destroy() end
end

-- A wreck set burning: locked (no GUI, fast transfer or mining), its GUI closed for everyone, a
-- pickaxe target of a player mining it removed (scripts/mining.lua), the cargo taken by the fire.
local function lock(rec, entity)
    if not rec.locked then
        rec.locked = {operable = entity.operable, minable = entity.minable_flag}
    end
    if entity.type == "container" then entity.operable = false end
    entity.minable_flag = false
    -- a robot sent to take it apart would find it locked: the order goes, mark it again when it is out
    if entity.to_be_deconstructed() then entity.cancel_deconstruction(util.player_force()) end
    for _, player in pairs(game.players) do
        if player.opened == entity then player.opened = nil end
    end
    local s = storage.shipwreck
    if s and s.targets then
        for id, entry in pairs(s.targets) do
            if entry.wreck == entity then
                s.targets[id] = nil
                if entry.target.valid then entry.target.destroy() end
            end
        end
    end
    absorb(rec, entity)
end

-- Item entries of a hazard kind for a wreck size and the count factor of the size.
local function choices(kind, size)
    local spec = cfg.hazards[kind]
    local list, factor = {}, 1
    local source = spec.items
    if spec.by_size then
        source = spec.by_size[size] or spec.by_size.small
    else
        factor = cfg.size_factor[size] or 1
    end
    for _, entry in ipairs(source) do
        if util.item_exists(entry[1]) then list[#list + 1] = entry end
    end
    return list, factor
end

function M.load_hazard(rec)
    local kinds = {}
    for kind, weight in pairs(cfg.hazard_weights) do
        if kind == "none" or (cfg.hazards[kind] and choices(kind, rec.size)[1]) then kinds[#kinds + 1] = {kind, weight} end
    end
    if not kinds[1] then return end
    table.sort(kinds, function(a, b) return a[1] < b[1] end)
    local kind = util.weighted(kinds, 2)[1]
    if kind == "none" then return end
    local list, factor = choices(kind, rec.size)
    local pick = util.weighted(list, 4)
    local count = math.max(1, math.floor(util.int({pick[2], pick[3]}) * factor + 0.5))
    rec.kind = kind
    local inventory = chest(rec.entity)
    local inserted = inventory and inventory.insert({name = pick[1], count = count}) or 0
    if inserted < count then rec.virtual = {name = pick[1], count = count - inserted} end
end

local function start_watch()
    local s = state()
    if s.watching then return end
    s.watching = true
    scheduler.after(cfg.watch_interval, "fire-watch")
end

local function start_ticking()
    local s = state()
    if s.ticking then return end
    s.ticking = true
    scheduler.after(cfg.tick_interval, "fire-tick")
end

-- Registers a wreck for fires; with_hazard: roll the hazardous cargo it carries.
function M.track(entity, with_hazard)
    if not (entity and entity.valid and util.enabled("bnl-start-wreck-fires")) then return nil end
    local s = state()
    local reg = reg_of(entity)
    local rec = s.wrecks[reg]
    if rec then return rec end
    rec = {entity = entity, size = size_of(entity.name), steps = 0}
    s.wrecks[reg] = rec
    -- area of all tracked wrecks per surface: fire-watch asks once whether any fire is near them
    local p, r = entity.position, entity.get_radius() + 2
    s.boxes = s.boxes or {}
    local box = s.boxes[entity.surface.index]
    if box then
        box[1], box[2] = math.min(box[1], p.x - r), math.min(box[2], p.y - r)
        box[3], box[4] = math.max(box[3], p.x + r), math.max(box[4], p.y + r)
    else
        s.boxes[entity.surface.index] = {p.x - r, p.y - r, p.x + r, p.y + r}
    end
    if with_hazard then M.load_hazard(rec) end
    start_watch()
    return rec
end

-- The vanilla crash site fire: flames and the hidden generators (crash-site-fire-smoke, a cyclic
-- smoke that keeps making new flames for 15-30 s) on the starliner and its parts.
local VANILLA_FIRE = {}
for _, name in ipairs({"crash-site-fire-flame", "crash-site-fire-smoke"}) do
    if prototypes.entity[name] then VANILLA_FIRE[#VANILLA_FIRE + 1] = name end
end

-- The crash site is filled (control.lua): every start wreck is tracked with its hazardous cargo;
-- the starliner and every wreck the engine set alight (a vanilla flame or flame generator in its
-- box) burn for real from now on, the others only catch fire from a fire next to them. The vanilla
-- fire goes: the fire of a burning wreck is the mod's, drawn only.
function M.start(ship, wrecks)
    if not (ship and ship.valid and util.enabled("bnl-start-wreck-fires")) then return end
    local surface = ship.surface
    local list = {ship}
    for _, wreck in ipairs(wrecks) do
        if wreck.valid and wreck ~= ship then list[#list + 1] = wreck end
    end
    local alight = {}
    if VANILLA_FIRE[1] then
        for _, entity in ipairs(list) do
            alight[entity] = entity == ship
                or surface.count_entities_filtered({name = VANILLA_FIRE, area = entity.bounding_box, limit = 1}) > 0
        end
        for _, flame in pairs(surface.find_entities_filtered({name = VANILLA_FIRE, position = ship.position,
            radius = shipwreck.crash_radius})) do
            if flame.valid then flame.destroy() end
        end
    else
        alight[ship] = true
    end
    for _, entity in ipairs(list) do
        local rec = M.track(entity, true)
        if rec and alight[entity] then M.ignite(rec) end
    end
end

-- "Too hot" over a burning wreck a player tries to open or mine (once a second at most).
function M.too_hot(player, entity)
    local s = storage.bnl and storage.bnl.fire
    if not s then return end
    s.hot = s.hot or {}
    if (s.hot[player.index] or 0) > game.tick then return end
    s.hot[player.index] = game.tick + 60
    player.create_local_flying_text({text = {"bnl.wreck-too-hot"}, position = entity.position,
        color = {r = 1, g = 0.45, b = 0.15}})
end

-- A burning wreck is not operable, so the engine does not open it; this catches the rest (a GUI
-- opened by another mod or by script).
function M.on_gui_opened(event)
    local entity = event.entity
    if not (entity and entity.valid and M.is_burning(entity)) then return end
    local player = game.get_player(event.player_index)
    if not player then return end
    player.opened = nil
    M.too_hot(player, entity)
end

-- Wet spots ---------------------------------------------------------------------------------------

-- `count` white steam puffs within `radius` of `position` (prototypes/bnl-water.lua).
function M.steam(surface, position, radius, count, name)
    for _ = 1, count do
        local a, r = math.random() * 2 * math.pi, radius * math.sqrt(math.random())
        surface.create_trivial_smoke({name = name or "bnl-steam",
            position = {x = position.x + r * math.cos(a), y = position.y + r * math.sin(a)}})
    end
end

-- A wet thing set alight: a little white steam instead of fire.
function M.hiss(surface, position, radius)
    M.steam(surface, position, radius or 0.6, 4, "bnl-steam-small")
end

function M.is_wet(surface, position)
    local s = storage.bnl and storage.bnl.fire
    local list = s and s.wet
    if not list then return false end
    local tick, index = game.tick, surface.index
    for _, spot in ipairs(list) do
        if spot.surface == index and spot.until_tick > tick then
            local dx, dy = position.x - spot.x, position.y - spot.y
            if dx * dx + dy * dy <= spot.r * spot.r then return true end
        end
    end
    return false
end

-- Puts out the fires (entities of type fire) within radius; returns their number.
local function put_out(surface, position, radius, steam)
    local n = 0
    for _, flame in pairs(surface.find_entities_filtered({type = "fire", position = position, radius = radius})) do
        if flame.valid then
            local p = flame.position
            flame.destroy()
            n = n + 1
            if steam then M.steam(surface, p, 0.4, 2, "bnl-steam-small") end
        end
    end
    return n
end

-- Water poured here: the fires within radius go out and the spot stays wet for water.calm.
function M.wet(surface, position, radius)
    put_out(surface, position, radius)
    local s = storage.bnl and storage.bnl.fire
    if not s then return end
    s.wet = s.wet or {}
    local list = s.wet
    list[#list + 1] = {surface = surface.index, x = position.x, y = position.y, r = radius,
        until_tick = game.tick + cfg.water.calm}
    while #list > cfg.water.max_spots do table.remove(list, 1) end
    if not s.drying then
        s.drying = true
        scheduler.after(cfg.water.wet_check, "fire-wet")
    end
end

-- Fires that reach a wet spot (spread by the engine, lit by bursts) die in steam until it dries.
scheduler.handler("fire-wet", function(_, tick)
    local s = state()
    local kept = {}
    for _, spot in ipairs(s.wet or {}) do
        local surface = spot.until_tick > tick and game.get_surface(spot.surface)
        if surface then
            kept[#kept + 1] = spot
            put_out(surface, {x = spot.x, y = spot.y}, spot.r, true)
        end
    end
    s.wet = kept
    if kept[1] then
        scheduler.after(cfg.water.wet_check, "fire-wet")
    else
        s.drying = false
    end
end)

-- Every scripted real fire (bursts, embers, jets, fuel thrown into a fire): steam on a wet spot.
-- `name`: the fire entity (default fire-flame). Returns the fire entity, false on a wet spot.
function M.make_fire(surface, position, flames, name)
    if M.is_wet(surface, position) then
        M.hiss(surface, position)
        return false
    end
    return surface.create_entity({name = name or "fire-flame", position = position, initial_ground_flame_count = flames})
        or false
end

-- Returns true when the wreck caught fire; a wet wreck (on a spot where water was poured less than
-- water.calm ago; a quenched wreck is one) steams instead and returns false, "wet". A burnt-out
-- wreck never burns again.
function M.ignite(entity_or_rec, duration)
    local rec = entity_or_rec
    if rec and rec.object_name == "LuaEntity" then rec = state().wrecks[reg_of(rec)] end
    if not rec or rec.burning or rec.burnt then return false end
    local entity = rec.entity
    if not (entity and entity.valid) then return false end
    local tick = game.tick
    if M.is_wet(entity.surface, entity.position) then
        if (rec.next_hiss or 0) <= tick then
            rec.next_hiss = tick + cfg.water.hiss_interval
            M.hiss(entity.surface, entity.position, entity.get_radius())
        end
        return false, "wet"
    end
    rec.burning = true
    lock(rec, entity)
    -- Only the fire itself (scripted health) burns a wreck down; ground fires, impacts and
    -- explosions around can no longer destroy it with its cargo. Stays so after the fire.
    entity.destructible = false
    rec.floor = cfg.burn_floor[1] + math.random() * (cfg.burn_floor[2] - cfg.burn_floor[1])
    local seconds = duration or util.int(cfg.burn_seconds[rec.size] or cfg.burn_seconds.small)
    rec.rate = (1 - rec.floor) / math.max(1, seconds) -- share of max health per second
    rec.next_pop = tick + util.int(cfg.idle_interval)
    -- the cargo is spared while the players land (the vanilla cutscene runs on game time)
    rec.next_step = math.max(tick, util.landing_tick() + cfg.cargo_grace) + util.int(cfg.step_interval)
    rec.budget = nil -- counted at the first fire tick (after the start cargo is in)
    local tempers = {}
    for name, spec in pairs(cfg.temperaments) do tempers[#tempers + 1] = {name, spec.weight} end
    table.sort(tempers, function(a, b) return a[1] < b[1] end)
    rec.temper = util.weighted(tempers, 2)[1]
    rec.next_flare = tick + util.int((cfg.temperaments[rec.temper].flare or {interval = {0, 0}}).interval)
    light_up(rec, entity)
    start_ticking()
    return true
end

local function extinguish(rec)
    rec.burning = false
    clear_visuals(rec)
    release(rec)
end

-- One stack, n quality steps down. Items with data (armor with equipment, blueprints) are kept.
local function degrade_stack(stack, n)
    if stack.item then return end
    local name, current = stack.name, stack.quality.name
    local target, count = current, stack.count
    for _ = 1, n do
        local below = quality.previous(target)
        if not below or (quality.is_defect(below) and not quality.can_defect(name)) then break end
        target = below
    end
    if target ~= current then
        local spec = {name = name, count = count, quality = target, health = stack.health}
        if stack.is_ammo then spec.ammo = stack.ammo end
        if stack.is_tool or stack.is_repair_tool then spec.durability = stack.durability end
        stack.set_stack(spec)
    end
end

-- One whole random cargo stack burns away; returns its rich text and count.
local function lose_stack(inventory)
    local list = {}
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read and not special(stack.name) then list[#list + 1] = stack end
    end
    if not list[1] then return nil end
    local stack = list[math.random(#list)]
    local text = "[item=" .. stack.name .. ",quality=" .. stack.quality.name .. "]"
    local count = stack.count
    stack.clear()
    return text, count
end

-- Counters of the start for the AUTO remarks and the closing act (scripts/goals.lua).
local function tally(key, n)
    local s = storage.bnl and storage.bnl.fire
    if not s then return end
    s.stats = s.stats or {}
    s.stats[key] = (s.stats[key] or 0) + (n or 1)
end

function M.stats()
    local s = storage.bnl and storage.bnl.fire
    return s and s.stats or {}
end

local function float_text(entity, text, offset, color, scale, ttl)
    rendering.draw_text({
        text = text,
        surface = entity.surface,
        target = {entity = entity, offset = {0, offset}},
        color = color,
        scale = scale,
        alignment = "center",
        use_rich_text = true,
        time_to_live = ttl,
    })
end

local function degrade(rec, entity, n)
    local inventory = cargo(rec, entity)
    local lost = {}
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read and not special(stack.name) then degrade_stack(stack, n) end
        end
        for _ = 1, n do -- every step burnt is one roll
            if math.random() < cfg.lose_chance then
                local text, n = lose_stack(inventory)
                if text then
                    lost[#lost + 1] = {text, n}
                    tally("stacks_lost")
                end
            end
        end
    end
    for i, entry in ipairs(lost) do
        float_text(entity, {"bnl.cargo-lost", entry[1], entry[2]}, -0.9 + 0.6 * (i - 1), {r = 1, g = 0.3, b = 0.2}, 1.1, 300)
    end
    float_text(entity, {"bnl.cargo-burnt", rec.steps}, -1.6, {r = 1, g = 0.45, b = 0.15}, 1.4, 240)
    local s = state()
    if not s.warned then
        s.warned = true
        util.say({"bnl.cargo-burnt-hint", util.gps(entity.position, entity.surface)})
    end
end

-- One step every config.fire.step_interval while it burns.
local function apply_steps(rec, entity, tick)
    if not rec.next_step then rec.next_step = tick + util.int(cfg.step_interval) end
    if tick < rec.next_step then return end
    rec.next_step = tick + util.int(cfg.step_interval)
    rec.steps = (rec.steps or 0) + 1
    degrade(rec, entity, 1)
end

-- One pass over a burning wreck: the first hazardous cargo (virtual first), the burn speed factor
-- of fuel and oxygen inside.
local function survey(rec, entity)
    local r = {boost = 1}
    local boosted = {}
    local function note(name)
        local h = hazard[name]
        if h and h.spec.boost and not boosted[h.kind] then
            boosted[h.kind] = true
            r.boost = r.boost * h.spec.boost
        end
    end
    r.count = 0
    if rec.virtual and rec.virtual.count > 0 and hazard[rec.virtual.name] then
        r.hazard = rec.virtual.name
        r.count = rec.virtual.count
        note(r.hazard)
    end
    local inventory = cargo(rec, entity)
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read then
                local name = stack.name
                if hazard[name] then
                    note(name)
                    if not r.hazard then r.hazard, r.stack = name, stack end
                    if name == r.hazard then r.count = r.count + stack.count end
                end
            end
        end
    end
    return r
end

-- Units of hazardous cargo in a wreck.
local function hazard_count(rec, entity)
    local n = rec.virtual and hazard[rec.virtual.name] and rec.virtual.count or 0
    local inventory = cargo(rec, entity)
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read and hazard[stack.name] then n = n + stack.count end
        end
    end
    return n
end

local function around(entity, radius)
    local p = entity.position
    local offset = util.vector(math.random(), radius * math.random())
    return {x = p.x + offset.x, y = p.y + offset.y}
end

local function ground_fire(surface, position, flames)
    M.make_fire(surface, position, flames)
end

-- Visuals of a burning wreck ------------------------------------------------------------------

local function destroy_all(list)
    for _, object in ipairs(list or {}) do
        if object.valid then object.destroy() end
    end
end

local function clear_torches(rec)
    destroy_all(rec.torches)
    rec.torches, rec.torch_item, rec.torch_base = nil, nil, nil
end

-- Torches of the fuel inside, shrinking as it runs out (r: survey of this tick).
local function update_torches(rec, entity, r)
    local h = r.hazard and hazard[r.hazard]
    local spec = h and cfg.torches[h.kind]
    if not spec or r.count <= 0 then
        clear_torches(rec)
        return
    end
    local t = cfg.torches
    if rec.torch_item ~= r.hazard then
        clear_torches(rec)
        rec.torch_item, rec.torch_base, rec.torches = r.hazard, r.count, {}
        local size = entity.get_radius() / 1.5
        local item = (spec.item_scale and spec.item_scale[r.hazard]) or 1
        rec.torch_points = {}
        for i, point in ipairs(spec.points) do
            local scale = point[3] * item * math.max(0.6, size)
            local stretch = point[3] * item >= t.long_from and t.long_stretch or 1
            rec.torch_points[i] = {point[1] * size, point[2] * size, scale, stretch}
            rec.torches[i] = rendering.draw_animation({animation = spec.animation, surface = entity.surface,
                target = {entity = entity, offset = {point[1] * size, point[2] * size - (t.lift[spec.animation] or 0.5) * scale * stretch}},
                x_scale = scale, y_scale = scale * stretch, render_layer = "higher-object-under",
                animation_offset = math.random(0, 59), animation_speed = 0.8 + 0.4 * math.random()})
        end
        rec.torch_animation = spec.animation
    end
    local k = math.max(t.min_scale, math.min(1, r.count / math.max(1, rec.torch_base)))
    local lift = t.lift[rec.torch_animation] or 0.5
    for i, object in ipairs(rec.torches) do
        local point = rec.torch_points[i]
        if object.valid and point then
            local scale, stretch = point[3] * k, point[4] or 1
            object.x_scale, object.y_scale = scale, scale * stretch
            object.target = {entity = entity, offset = {point[1], point[2] - lift * scale * stretch}}
        end
    end
end

temper_of = function(rec)
    return cfg.temperaments[rec.temper or "steady"] or cfg.temperaments.steady
end

clear_visuals = function(rec)
    clear_torches(rec)
    destroy_all(rec.flames)
    destroy_all({rec.light, rec.flare})
    rec.light, rec.flare, rec.flames, rec.smoke_points = nil, nil, nil, nil
end

-- The flames of a burning wreck (rendering only: they light nothing and do not spread), by size
-- and character (config.fire.flames, temperament flame_factor); the starliner's keep off its logo.
local function draw_flames(rec, entity)
    local count = entity.name == shipwreck.ship and cfg.flames.ship or cfg.flames[rec.size] or 1
    count = math.max(1, math.floor(count / (temper_of(rec).flame_factor or 1) + 0.5))
    local box, p0 = entity.bounding_box, entity.position
    local decal = entity.name == shipwreck.ship and util.add(p0, util.pos(config.ship_decal.offset))
    local lift = cfg.torches.lift["bnl-torch-blaze"]
    local scale0 = cfg.flames.scale[rec.size] or 1
    rec.flames, rec.smoke_points = {}, {}
    for i = 1, count do
        local p
        for _ = 1, 6 do
            p = {x = box.left_top.x + (box.right_bottom.x - box.left_top.x) * (0.2 + 0.6 * math.random()),
                y = box.left_top.y + (box.right_bottom.y - box.left_top.y) * (0.2 + 0.6 * math.random())}
            if not decal or util.distance(p, decal) > config.ship_decal.flame_radius then break end
        end
        local dx, dy = p.x - p0.x, p.y - p0.y
        local scale = scale0 * (0.8 + 0.4 * math.random())
        rec.flames[i] = rendering.draw_animation({animation = "bnl-torch-blaze", surface = entity.surface,
            target = {entity = entity, offset = {dx, dy - lift * scale}}, x_scale = scale, y_scale = scale,
            render_layer = "higher-object-under", animation_offset = math.random(0, 89),
            animation_speed = 0.8 + 0.4 * math.random()})
        rec.smoke_points[i] = {dx, dy - 2 * lift * scale}
    end
end

-- Smoke over the flames, every fire tick.
local function smoke(rec, entity)
    local p = entity.position
    for _, o in ipairs(rec.smoke_points or {}) do
        entity.surface.create_trivial_smoke({name = "fire-smoke-without-glow", position = {x = p.x + o[1], y = p.y + o[2]}})
    end
end

-- Light of the fire on the ground (and at night), coloured by its character, and the flames.
light_up = function(rec, entity)
    local c = temper_of(rec).light or {1, 0.55, 0.2}
    rec.light = rendering.draw_light({sprite = "utility/light_medium", surface = entity.surface, target = entity,
        scale = 1.5 + entity.get_radius(), intensity = 0.55, color = {r = c[1], g = c[2], b = c[3]}})
    draw_flames(rec, entity)
end

-- A smouldering wreck keeps smoking after it is out (temperament afterglow): puffs every 2 s.
scheduler.handler("fire-afterglow", function(job, tick)
    local entity = job.entity
    if not (entity and entity.valid) or tick >= job.until_tick then return end
    for _ = 1, 2 do
        entity.surface.create_trivial_smoke({name = "fire-smoke-without-glow",
            position = around(entity, entity.get_radius() * 0.6)})
    end
    scheduler.after(120, "fire-afterglow", job)
end)

-- Character effects every fire tick; returns extra health share lost.
local function temper_tick(rec, entity, tick)
    local temper = temper_of(rec)
    local surface = entity.surface
    if temper.smoke then
        for _ = 1, temper.smoke do
            surface.create_trivial_smoke({name = "fire-smoke-without-glow", position = around(entity, entity.get_radius())})
        end
    end
    if temper.embers and math.random() < temper.embers.chance then
        ground_fire(surface, around(entity, entity.get_radius() + util.float(temper.embers.radius)), 1)
    end
    local flare = temper.flare
    if flare and tick >= (rec.next_flare or 0) then
        rec.next_flare = tick + util.int(flare.interval)
        if rec.flare and rec.flare.valid then rec.flare.destroy() end
        rec.flare = rendering.draw_animation({animation = "bnl-torch-blaze", surface = surface,
            target = {entity = entity, offset = {0, -cfg.torches.lift["bnl-torch-blaze"] * flare.scale}},
            x_scale = flare.scale, y_scale = flare.scale, render_layer = "higher-object-under",
            time_to_live = flare.seconds * 60})
        ground_fire(surface, around(entity, entity.get_radius() + 2), 2)
        return flare.damage
    end
    return 0
end

-- Takes `units` (a number or "all") of the surveyed hazard, at most the wreck's budget of what may
-- go off in this fire; returns its spec and the number taken.
local function take(rec, r, units)
    local h = r.hazard and hazard[r.hazard]
    if not h or (rec.budget or 0) <= 0 then return nil, 0 end
    if units == "all" or units > rec.budget then units = rec.budget end
    local stack = r.stack
    if stack and stack.valid_for_read then
        local n = math.min(units, stack.count)
        if n >= stack.count then stack.clear() else stack.count = stack.count - n end
        rec.budget = rec.budget - n
        return h, n
    end
    local v = rec.virtual
    if v and v.count > 0 then
        local n = math.min(units, v.count)
        v.count = v.count - n
        if v.count <= 0 then rec.virtual = nil end
        rec.budget = rec.budget - n
        return h, n
    end
    return nil, 0
end

local function hurt(entity, radius, damage)
    for _, character in pairs(entity.surface.find_entities_filtered({type = "character", position = entity.position,
        radius = radius + entity.get_radius()})) do
        if character.valid and character.destructible then character.damage(damage, "neutral", "explosion") end
    end
end

-- Big blasts also hit what the players built close to the wreck.
local function hit_buildings(entity, radius, damage)
    for _, target in pairs(entity.surface.find_entities_filtered({force = "player", position = entity.position,
        radius = math.min(radius, cfg.building_radius) + entity.get_radius()})) do
        if target.valid and target.type ~= "character" and target.is_entity_with_health and target.destructible then
            target.damage(damage, "neutral", "explosion")
        end
    end
end

local function scatter(rec, entity, distance)
    local inventory = cargo(rec, entity)
    if not inventory then return end
    local candidates = {}
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read and not special(stack.name) and not stack.item then candidates[#candidates + 1] = stack end
    end
    if not candidates[1] then return end
    local stack = candidates[math.random(#candidates)]
    local count = math.max(1, math.floor(stack.count * (0.2 + 0.3 * math.random())))
    entity.surface.spill_item_stack({
        position = around(entity, entity.get_radius() + (distance or 3)),
        stack = {name = stack.name, count = count, quality = stack.quality.name},
        enable_looted = true,
        allow_belts = false,
    })
    if count >= stack.count then stack.clear() else stack.count = stack.count - count end
end

-- What a hazard does when it goes off in a burning wreck.
local effects = {}

effects.ammo = function(entity, h, rec)
    local surface = entity.surface
    surface.create_entity({name = h.explosion, position = around(entity, entity.get_radius())})
    hurt(entity, cfg.splash_radius, cfg.splash_damage)
    if h.fire or math.random() < cfg.spark_chance then ground_fire(surface, around(entity, entity.get_radius() + 3), 3) end
    if math.random() < cfg.scatter_chance then scatter(rec, entity) end
end

effects.barrel = function(entity, h, rec)
    local spec, surface = h.spec, entity.surface
    surface.create_entity({name = spec.explosion, position = around(entity, entity.get_radius())})
    local reach = entity.get_radius() + util.float(spec.pool_radius)
    for _ = 1, util.int(spec.pool_flames) do ground_fire(surface, around(entity, reach), 4) end
    hurt(entity, spec.hurt[1], spec.hurt[2])
    hit_buildings(entity, spec.hurt[1], spec.hurt[2])
    if math.random() < cfg.scatter_chance then scatter(rec, entity) end
end

effects.gas = function(entity, h)
    local spec, surface = h.spec, entity.surface
    surface.create_entity({name = spec.explosion, position = entity.position})
    hurt(entity, spec.hurt[1], spec.hurt[2])
    if util.entity_exists("bnl-flying-cylinder") then
        local distance = util.float(spec.fly)
        local target = util.add(entity.position, util.vector(math.random(), distance))
        surface.create_entity({name = "bnl-flying-cylinder", position = entity.position, target = target,
            force = "neutral", speed = distance / 75})
    end
end

effects.fuel = function(entity)
    local surface = entity.surface
    M.make_fire(surface, around(entity, entity.get_radius() * 0.7), 1, "crash-site-fire-flame")
    if math.random() < cfg.spark_chance then ground_fire(surface, around(entity, entity.get_radius() + 2), 2) end
end

effects.explosive = function(entity, h, rec)
    local spec, surface = h.spec, entity.surface
    surface.create_entity({name = spec.explosion, position = entity.position})
    for _ = 1, spec.blasts do
        surface.create_entity({name = "big-explosion", position = around(entity, entity.get_radius() + 3)})
    end
    hurt(entity, spec.hurt[1], spec.hurt[2])
    hit_buildings(entity, spec.hurt[1], spec.hurt[2])
    for _ = 1, spec.scatter do scatter(rec, entity, 8) end
    ground_fire(surface, around(entity, entity.get_radius() + 2), 4)
end

effects.oxygen = function(entity)
    local surface = entity.surface
    for _ = 1, 2 do
        M.make_fire(surface, around(entity, entity.get_radius()), 1, "crash-site-fire-flame")
    end
    ground_fire(surface, around(entity, entity.get_radius() + 2), 2)
end

local function poison(entity)
    if util.entity_exists("poison-cloud") then
        entity.surface.create_entity({name = "poison-cloud", position = around(entity, entity.get_radius()), force = "neutral"})
    end
end

effects.battery = function(entity, h)
    for _ = 1, 2 do
        entity.surface.create_entity({name = h.spec.explosion, position = around(entity, entity.get_radius())})
    end
    if math.random() < h.spec.poison_chance then poison(entity) end
end

-- The fire goes out: a share of every hazardous cargo left goes off, the rest stays as loot.
local function burn_out(rec, entity)
    local blasts, toxic = 0, false
    local function going(name, count)
        local n = math.min(count, math.floor(count * cfg.burnout_share + math.random()))
        local kind = hazard[name].kind
        if kind == "battery" then
            toxic = toxic or n > 0
        elseif kind ~= "fuel" and kind ~= "oxygen" then
            blasts = blasts + n
        end
        return n
    end
    local v = rec.virtual
    if v and v.count > 0 and hazard[v.name] then
        v.count = v.count - going(v.name, v.count)
        if v.count <= 0 then rec.virtual = nil end
    end
    local inventory = cargo(rec, entity)
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read and hazard[stack.name] then
                local n = going(stack.name, stack.count)
                if n >= stack.count then stack.clear() elseif n > 0 then stack.count = stack.count - n end
            end
        end
    end
    entity.surface.create_entity({name = blasts > 0 and "massive-explosion" or "big-explosion", position = entity.position})
    if blasts > 0 then
        hurt(entity, cfg.burnout_radius, cfg.burnout_damage)
        hit_buildings(entity, cfg.burnout_radius, cfg.burnout_damage)
    end
    if toxic then poison(entity) end
    local afterglow = temper_of(rec).afterglow
    if afterglow then
        scheduler.after(1, "fire-afterglow", {entity = entity, until_tick = game.tick + afterglow})
    end
    rec.burnt = true
    tally("burnt_out")
    extinguish(rec)
end

-- The fire goes out by water: a big steam cloud over the wreck, no last blast; the cargo comes
-- back, the wreck and the spot around it stay wet (its own flames around go out too).
local function quench(rec, entity)
    tally("quenched")
    extinguish(rec)
    M.wet(entity.surface, entity.position, entity.get_radius() + cfg.water.wet_margin)
    local radius = entity.get_radius() * 1.41 -- twice the area of the first version
    M.steam(entity.surface, entity.position, radius, math.max(20, math.floor(radius * 12)), "bnl-steam")
    float_text(entity, {"bnl.fire-quenched"}, -1.6, {r = 0.5, g = 0.8, b = 1}, 1.3, 240)
end

function M.is_tracked(entity)
    local s = storage.bnl and storage.bnl.fire
    return s ~= nil and WRECK[entity.name] == true and s.wrecks[reg_of(entity)] ~= nil
end

function M.is_burning(entity)
    local s = storage.bnl and storage.bnl.fire
    local rec = s and WRECK[entity.name] and s.wrecks[reg_of(entity)]
    return rec ~= nil and rec.burning == true
end

-- Burning wrecks now (the objectives window, scripts/goals.lua).
function M.burning_count()
    local s = storage.bnl and storage.bnl.fire
    if not s then return 0 end
    local n = 0
    for _, rec in pairs(s.wrecks) do
        if rec.burning and rec.entity.valid then n = n + 1 end
    end
    return n
end

-- Wrecks can still catch fire by themselves (the watch runs) or something burns.
function M.active()
    local s = storage.bnl and storage.bnl.fire
    return s ~= nil and (s.watching == true or s.ticking == true)
end

-- Items of `name` in an entity's chest, also while its fire holds the cargo.
function M.item_count(entity, name)
    local n = 0
    local inventory = chest(entity)
    if inventory then n = inventory.get_item_count(name) end
    local s = storage.bnl and storage.bnl.fire
    local rec = s and WRECK[entity.name] and s.wrecks[reg_of(entity)]
    local held = rec and rec.held
    if held and held.valid then n = n + held.get_item_count(name) end
    return n
end

-- A water barrel poured anywhere (scripts/douse.lua): every burning wreck reaching into `radius`
-- around the spot (its box, not only its centre) goes out, and so do the ordinary fires there; the
-- spot stays wet. Returns the number of wrecks put out.
function M.quench_area(surface, position, radius)
    local s = storage.bnl and storage.bnl.fire
    local n = 0
    for _, rec in pairs(s and s.wrecks or {}) do
        local entity = rec.entity
        if rec.burning and entity and entity.valid and entity.surface == surface then
            local box = entity.bounding_box
            local dx = math.max(box.left_top.x - position.x, 0, position.x - box.right_bottom.x)
            local dy = math.max(box.left_top.y - position.y, 0, position.y - box.right_bottom.y)
            if dx * dx + dy * dy <= radius * radius then
                quench(rec, entity)
                n = n + 1
            end
        end
    end
    M.wet(surface, position, radius)
    return n
end

local function burn(rec, entity, tick)
    local max = entity.max_health
    if not rec.rate then -- set burning by 2.0.0
        rec.floor = cfg.burn_floor[1] + math.random() * (cfg.burn_floor[2] - cfg.burn_floor[1])
        rec.rate = (1 - rec.floor) / util.int(cfg.burn_seconds[rec.size] or cfg.burn_seconds.small)
    end
    -- cargo that came into the chest since (start fill, inserters); only for a locked wreck: an
    -- unlocked one (set burning before the lock existed) can still be mined with its chest
    if rec.locked then absorb(rec, entity) end
    if not rec.budget then -- what may go off in this fire, counted once when it caught fire
        rec.budget = math.floor(hazard_count(rec, entity) * cfg.fire_share + math.random())
    end
    local r = survey(rec, entity)
    local factor = r.boost * (temper_of(rec).speed or 1)
    update_torches(rec, entity, r)
    local health = entity.health - max * rec.rate * factor * cfg.tick_interval / 60
    health = health - max * temper_tick(rec, entity, tick)
    if tick >= (rec.next_pop or 0) then
        local h = r.hazard and hazard[r.hazard]
        local units = h and h.spec.pop_units or 1
        if units ~= "all" then units = util.int(units) end
        local spec, taken = take(rec, r, units)
        if spec then
            health = health - max * spec.damage * (spec.spec.pop_units == "all" and 1 or taken)
            effects[spec.kind](entity, spec, rec)
            rec.next_pop = tick + util.int(spec.spec.pop_interval)
        else
            rec.next_pop = tick + util.int(cfg.idle_interval)
        end
    end
    local floor = max * rec.floor
    if health <= floor then
        entity.health = math.max(1, floor)
        burn_out(rec, entity)
        return
    end
    entity.health = health
    apply_steps(rec, entity, tick)
    if not rec.flames then draw_flames(rec, entity) end -- set burning before the drawn flames
    smoke(rec, entity)
end

scheduler.handler("fire-tick", function(_, tick)
    local s = state()
    local any = false
    for reg, rec in pairs(s.wrecks) do
        if rec.burning then
            local entity = rec.entity
            if entity.valid then
                burn(rec, entity, tick)
                any = any or rec.burning
            else
                extinguish(rec)
                s.wrecks[reg] = nil
            end
        end
    end
    if any then
        scheduler.after(cfg.tick_interval, "fire-tick")
    else
        s.ticking = false
        events.refresh() -- the start fires may be over: the water clicks stop listening
    end
end)

scheduler.handler("fire-watch", function(_, tick)
    local s = state()
    local burning = false
    -- one query per surface: without any fire near the wrecks no wreck needs its own query
    local fire_near = {}
    for index, box in pairs(s.boxes or {}) do
        local surface = game.get_surface(index)
        fire_near[index] = surface ~= nil and surface.count_entities_filtered({type = "fire",
            area = {{box[1], box[2]}, {box[3], box[4]}}, limit = 1}) > 0
    end
    for reg, rec in pairs(s.wrecks) do
        local entity = rec.entity
        if not entity.valid then
            extinguish(rec)
            s.wrecks[reg] = nil
        elseif rec.burning then
            burning = true
        elseif not rec.burnt and fire_near[entity.surface.index] ~= false
            and entity.surface.count_entities_filtered({type = "fire", position = entity.position,
            radius = entity.get_radius() + 1.5, limit = 1}) > 0 then
            burning = M.ignite(rec) or burning
        end
    end
    if util.since_landing() < cfg.watch_until or burning then
        scheduler.after(cfg.watch_interval, "fire-watch")
    else
        s.watching = false
        events.refresh()
        -- The start is over: wrecks keep their steps for the mining loot, nothing ticks any more.
    end
end)

-- Quality steps lost by a wreck (mining loot).
function M.steps_of(entity)
    local s = storage.bnl and storage.bnl.fire
    if not s then return 0 end
    local rec = s.wrecks[reg_of(entity)]
    return rec and rec.steps or 0
end

-- Hazardous cargo of a wreck without an inventory that did not go off: mining loot, given once.
function M.leftover(entity)
    local s = storage.bnl and storage.bnl.fire
    local rec = s and s.wrecks[reg_of(entity)]
    local v = rec and rec.virtual
    if not (v and v.count > 0 and util.item_exists(v.name)) then return nil end
    rec.virtual = nil
    return {name = v.name, count = v.count}
end

-- Lowers a loot stack definition {name, count, quality} by the wreck's steps (mining loot).
function M.degrade_loot(stack, steps)
    if steps <= 0 then return stack end
    local target = stack.quality or "normal"
    for _ = 1, steps do
        local below = quality.previous(target)
        if not below or (quality.is_defect(below) and not quality.can_defect(stack.name)) then break end
        target = below
    end
    return {name = stack.name, count = stack.count, quality = target}
end

function M.on_destroyed(registration)
    local s = storage.bnl and storage.bnl.fire
    local rec = s and s.wrecks[registration]
    if rec then
        extinguish(rec)
        s.wrecks[registration] = nil
    end
end

return M
