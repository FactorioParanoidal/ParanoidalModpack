-- Burning wrecks of the start crash. Most loot wrecks carry one kind of hazardous cargo
-- (config.fire.hazards): ammo (frequent cook-offs), fuel barrels (rare bursts, a pool of burning fuel),
-- gas cylinders (a burst cylinder flies off and falls burning), high-tech fuel (burns as the fire's
-- fuel, the fire gets hotter), explosives (one big blast), oxygen (jets of flame, the fire burns twice
-- as fast) or batteries (sparks, a poison cloud). A fire next to a wreck (or the crash itself, for a
-- share of the start wrecks) sets it burning. A burning wreck cannot be destroyed by anything else;
-- it loses health steadily until it reaches a random floor of 2-10% of its max health, then the fire
-- goes out and a share of the hazardous cargo left goes off in a last blast; the rest of it is loot.
-- The cargo whose quality can change loses one quality step at 75%, 50% and 25% health and one more
-- when the fire goes out (4 steps, down to defect -5 at most), each step may burn a whole stack away;
-- mining loot follows the same steps. Water barrels put into the wreck slow the fire and burst into
-- steam one by one; enough of them put it out. Fires from bursts reach player buildings nearby.
local config = require("bnl-config")
local util = require("scripts.util")
local quality = require("scripts.quality")
local scheduler = require("scripts.scheduler")
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
local water = {}
for _, name in ipairs(cfg.water.items) do water[name] = true end

-- Hazards and water are not cargo: no quality steps, never burnt away or thrown out.
local function special(name)
    return hazard[name] ~= nil or water[name] == true
end

local function state()
    return storage.bnl.fire
end

local clear_visuals, temper_of, light_up -- defined with the visuals below

function M.init()
    storage.bnl.fire = storage.bnl.fire or {wrecks = {}}
end

local function size_of(name)
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
    if with_hazard then M.load_hazard(rec) end
    start_watch()
    return rec
end

-- Water barrels of the ship's fire kit.
function M.ship_kit(ship)
    local kit = cfg.water.ship_kit
    if kit and ship and ship.valid and util.item_exists(kit[1]) then ship.insert({name = kit[1], count = kit[2]}) end
end

function M.ignite(entity_or_rec, duration)
    local rec = entity_or_rec
    if rec and rec.object_name == "LuaEntity" then rec = state().wrecks[reg_of(rec)] end
    if not rec or rec.burning or rec.burnt then return end
    local entity = rec.entity
    if not (entity and entity.valid) then return end
    local tick = game.tick
    rec.burning = true
    -- Only the fire itself (scripted health) burns a wreck down; ground fires, impacts and
    -- explosions around can no longer destroy it with its cargo. Stays so after the fire.
    entity.destructible = false
    rec.floor = cfg.burn_floor[1] + math.random() * (cfg.burn_floor[2] - cfg.burn_floor[1])
    local seconds = duration or util.int(cfg.burn_seconds[rec.size] or cfg.burn_seconds.small)
    rec.rate = (1 - rec.floor) / math.max(1, seconds) -- share of max health per second
    rec.next_pop = tick + util.int(cfg.idle_interval)
    rec.next_flame = tick
    rec.next_water = nil
    rec.quench = 0
    rec.budget = nil -- counted at the first fire tick (after the start cargo is in)
    local tempers = {}
    for name, spec in pairs(cfg.temperaments) do tempers[#tempers + 1] = {name, spec.weight} end
    table.sort(tempers, function(a, b) return a[1] < b[1] end)
    rec.temper = util.weighted(tempers, 2)[1]
    rec.next_flare = tick + util.int((cfg.temperaments[rec.temper].flare or {interval = {0, 0}}).interval)
    light_up(rec, entity)
    start_ticking()
end

-- Start wrecks set burning by the crash itself, staggered after the landing.
function M.ignite_later(rec, delay)
    if rec then scheduler.after(delay, "fire-ignite", {entity = rec.entity}) end
end

scheduler.handler("fire-ignite", function(job)
    if job.entity and job.entity.valid then M.ignite(job.entity) end
end)

-- Visible fire on a burning wreck: a crash-site flame (short lived, harmless) and its smoke.
local function flame(rec, entity, tick)
    if tick < (rec.next_flame or 0) then return end
    rec.next_flame = tick + math.floor(cfg.flame_interval * (temper_of(rec).flame_factor or 1))
    local surface = entity.surface
    local box = entity.bounding_box
    local p = {x = box.left_top.x + (box.right_bottom.x - box.left_top.x) * (0.2 + 0.6 * math.random()),
        y = box.left_top.y + (box.right_bottom.y - box.left_top.y) * (0.2 + 0.6 * math.random())}
    surface.create_entity({name = "crash-site-fire-flame", position = p})
    if not (rec.smoke and rec.smoke.valid) then
        rec.smoke = surface.create_entity({name = "crash-site-fire-smoke", position = p})
    end
    if rec.smoke and rec.smoke.valid then rec.smoke.time_to_live = cfg.flame_interval * 2 end
end

local function extinguish(rec)
    if rec.burning then
        -- its own last flames must not light it again at once
        rec.calm_until = game.tick + 90 * 60
    end
    rec.burning = false
    if rec.smoke and rec.smoke.valid then rec.smoke.destroy() end
    rec.smoke = nil
    clear_visuals(rec)
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
    local inventory = chest(entity)
    local lost = {}
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read and not special(stack.name) then degrade_stack(stack, n) end
        end
        for _ = 1, n do -- every step burnt is one roll
            if math.random() < cfg.lose_chance then
                local text, count = lose_stack(inventory)
                if text then lost[#lost + 1] = {text, count} end
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

-- Steps at 75%, 50% and 25% health; the 4th comes when the fire goes out (burn_out).
local function apply_steps(rec, entity)
    local lost = 1 - entity.health / entity.max_health
    local steps = math.min(3, math.floor(lost * 4 + 1e-6))
    if steps > rec.steps then
        local n = steps - rec.steps
        rec.steps = steps
        degrade(rec, entity, n)
    end
end

-- One pass over a burning wreck: the first hazardous cargo (virtual first), the burn speed factor
-- of fuel and oxygen inside, the first water stack.
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
    local inventory = chest(entity)
    if inventory then
        for i = 1, #inventory do
            local stack = inventory[i]
            if stack.valid_for_read then
                local name = stack.name
                if hazard[name] then
                    note(name)
                    if not r.hazard then r.hazard, r.stack = name, stack end
                    if name == r.hazard then r.count = r.count + stack.count end
                elseif water[name] and not r.water then
                    r.water = stack
                end
            end
        end
    end
    return r
end

-- Units of hazardous cargo in a wreck.
local function hazard_count(rec, entity)
    local n = rec.virtual and hazard[rec.virtual.name] and rec.virtual.count or 0
    local inventory = chest(entity)
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
    surface.create_entity({name = "fire-flame", position = position, initial_ground_flame_count = flames})
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
    destroy_all({rec.light, rec.flare})
    rec.light, rec.flare = nil, nil
end

-- Light of the fire on the ground (and at night), coloured by its character.
light_up = function(rec, entity)
    local c = temper_of(rec).light or {1, 0.55, 0.2}
    rec.light = rendering.draw_light({sprite = "utility/light_medium", surface = entity.surface, target = entity,
        scale = 1.5 + entity.get_radius(), intensity = 0.55, color = {r = c[1], g = c[2], b = c[3]}})
end

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

local function scatter(entity, distance)
    local inventory = chest(entity)
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

effects.ammo = function(entity, h)
    local surface = entity.surface
    surface.create_entity({name = h.explosion, position = around(entity, entity.get_radius())})
    hurt(entity, cfg.splash_radius, cfg.splash_damage)
    if h.fire or math.random() < cfg.spark_chance then ground_fire(surface, around(entity, entity.get_radius() + 3), 3) end
    if math.random() < cfg.scatter_chance then scatter(entity) end
end

effects.barrel = function(entity, h)
    local spec, surface = h.spec, entity.surface
    surface.create_entity({name = spec.explosion, position = around(entity, entity.get_radius())})
    local reach = entity.get_radius() + util.float(spec.pool_radius)
    for _ = 1, util.int(spec.pool_flames) do ground_fire(surface, around(entity, reach), 4) end
    hurt(entity, spec.hurt[1], spec.hurt[2])
    hit_buildings(entity, spec.hurt[1], spec.hurt[2])
    if math.random() < cfg.scatter_chance then scatter(entity) end
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
    surface.create_entity({name = "crash-site-fire-flame", position = around(entity, entity.get_radius() * 0.7)})
    if math.random() < cfg.spark_chance then ground_fire(surface, around(entity, entity.get_radius() + 2), 2) end
end

effects.explosive = function(entity, h)
    local spec, surface = h.spec, entity.surface
    surface.create_entity({name = spec.explosion, position = entity.position})
    for _ = 1, spec.blasts do
        surface.create_entity({name = "big-explosion", position = around(entity, entity.get_radius() + 3)})
    end
    hurt(entity, spec.hurt[1], spec.hurt[2])
    hit_buildings(entity, spec.hurt[1], spec.hurt[2])
    for _ = 1, spec.scatter do scatter(entity, 8) end
    ground_fire(surface, around(entity, entity.get_radius() + 2), 4)
end

effects.oxygen = function(entity)
    local surface = entity.surface
    for _ = 1, 2 do
        surface.create_entity({name = "crash-site-fire-flame", position = around(entity, entity.get_radius())})
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
    local inventory = chest(entity)
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
        local smoke = entity.surface.create_entity({name = "crash-site-fire-smoke", position = entity.position})
        if smoke then smoke.time_to_live = afterglow end
    end
    if rec.steps < 4 then
        local n = 4 - rec.steps
        rec.steps = 4
        degrade(rec, entity, n)
    end
    rec.burnt = true
    extinguish(rec)
end

-- Water: one barrel bursts into steam; enough of them put the fire out (no last blast, no 4th step).
local function douse(rec, entity, stack)
    if stack.count > 1 then stack.count = stack.count - 1 else stack.clear() end
    local smoke = entity.surface.create_entity({name = "crash-site-explosion-smoke", position = around(entity, entity.get_radius())})
    if smoke then smoke.time_to_live = 120 end
    rec.quench = (rec.quench or 0) + 1
    if rec.quench < (cfg.water.quench[rec.size] or cfg.water.quench.small) then return false end
    extinguish(rec)
    rec.calm_until = game.tick + cfg.water.calm
    rec.quench = 0
    float_text(entity, {"bnl.fire-quenched"}, -1.6, {r = 0.5, g = 0.8, b = 1}, 1.3, 240)
    return true
end

local function burn(rec, entity, tick)
    local max = entity.max_health
    if not rec.rate then -- set burning by 2.0.0
        rec.floor = cfg.burn_floor[1] + math.random() * (cfg.burn_floor[2] - cfg.burn_floor[1])
        rec.rate = (1 - rec.floor) / util.int(cfg.burn_seconds[rec.size] or cfg.burn_seconds.small)
    end
    if not rec.budget then -- what may go off in this fire, counted once when it caught fire
        rec.budget = math.floor(hazard_count(rec, entity) * cfg.fire_share + math.random())
    end
    local r = survey(rec, entity)
    local factor = r.boost
    if r.water then
        factor = factor * cfg.water.slow
        if not rec.next_water then
            rec.next_water = tick + util.int(cfg.water.interval)
        elseif tick >= rec.next_water then
            rec.next_water = tick + util.int(cfg.water.interval)
            if douse(rec, entity, r.water) then return end
        end
    end
    factor = factor * (temper_of(rec).speed or 1)
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
            effects[spec.kind](entity, spec)
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
    apply_steps(rec, entity)
    flame(rec, entity, tick)
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
    end
end)

scheduler.handler("fire-watch", function(_, tick)
    local s = state()
    local burning = false
    for reg, rec in pairs(s.wrecks) do
        local entity = rec.entity
        if not entity.valid then
            extinguish(rec)
            s.wrecks[reg] = nil
        elseif rec.burning then
            burning = true
        elseif not rec.burnt and (rec.calm_until or 0) <= tick
            and entity.surface.count_entities_filtered({type = "fire", position = entity.position,
            radius = entity.get_radius() + 1.5, limit = 1}) > 0 then
            M.ignite(rec)
            burning = true
        end
    end
    if util.since_landing() < cfg.watch_until or burning then
        scheduler.after(cfg.watch_interval, "fire-watch")
    else
        s.watching = false
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
