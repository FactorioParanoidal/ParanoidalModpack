-- Flamethrower Wagon Reforged: two hidden flamethrower turrets ride on every wagon.
--
-- Load model:
--   * no wagons in the save: only name-filtered build/clone events and on_train_created are registered;
--   * a wagon whose train waits (station, signal, no path) costs nothing per tick, its train
--     state change wakes it up;
--   * a moving wagon: wagon.valid, speed, draw_data and two teleports per tick;
--   * a stopped wagon of a manual train: wagon.valid and speed per tick (it may start without events);
--   * fuel and sanity service: every wagon once per SERVICE_PERIOD ticks, spread evenly over the ticks.

local WAGON = "flamethrower-wagon"
local TURRET = "flamethrower-wagon-turret"
local MOD_DATA = "flamethrower-wagon-reforged"

local H_OFFSET = 2        -- turret distance from the wagon centre along the wagon
local V_OFFSET = -0.325   -- screen-space lift that puts the turrets on the wagon roof
local SERVICE_PERIOD = 60 -- ticks between two fuel/sanity services of one wagon
local PARK_CHECK = 2      -- ticks at zero speed before the train state is read
local MIN_TRANSFER = 1    -- smaller top-ups are skipped

local ev = defines.events
local ts = defines.train_state
local ENTITY = defines.target_type.entity
local sin, cos, min, ceil = math.sin, math.cos, math.min, math.ceil
local TAU = 2 * math.pi

-- States a train can only leave through on_train_changed_state.
local PARKED = {
    [ts.wait_station] = true,
    [ts.wait_signal] = true,
    [ts.no_path] = true,
    [ts.no_schedule] = true,
    [ts.destination_full] = true,
}

local DIRECTIONS = {
    [0] = defines.direction.north,
    [1] = defines.direction.east,
    [2] = defines.direction.south,
    [3] = defines.direction.west,
}

--- Turret base direction quadrant: 0 north, 1 east, 2 south, 3 west.
---@param o number RealOrientation
local function quadrant(o)
    if o <= 0.125 or o > 0.875 then return 0 end
    if o <= 0.375 then return 1 end
    if o <= 0.625 then return 2 end
    return 3
end

-- Scratch positions: teleport/create_entity copy them, so they are reused without allocations.
local PA, PB = { 0, 0 }, { 0, 0 }

--- Writes the turret positions of a wagon into PA (front) and PB (back).
--- The speed term predicts the wagon position after this tick's train update.
---@return number orientation
local function place(wagon, speed)
    local dd = wagon.draw_data
    local o = dd.orientation
    local p = dd.position
    local r = o * TAU
    local s, c = sin(r), cos(r)
    local f1, f2 = speed + H_OFFSET, speed - H_OFFSET
    local x, y = p.x, p.y + V_OFFSET
    PA[1], PA[2] = x + f1 * s, y - f1 * c
    PB[1], PB[2] = x + f2 * s, y - f2 * c
    return o
end

-- Prototype data, identical on every peer; read lazily because on_load must not depend on it.
local fuels, capacity

local function load_prototypes()
    local md = prototypes.mod_data[MOD_DATA]
    fuels = md and md.data.fuels or {}
    capacity = prototypes.entity[TURRET].fluidbox_prototypes[1].get_volume() -- Factorio 2.1: volume became get_volume()
end

local function init_storage()
    storage.list = storage.list or {}     -- dense array of records, rec.li = index
    storage.units = storage.units or {}   -- unit_number of wagon and both turrets -> record
    storage.moving = storage.moving or {} -- dense array of records that are polled every tick, rec.mi = index
    storage.cursor = storage.cursor or 1  -- service position in storage.list
end

---------------------------------------------------------------------------------------------------
-- Dynamic handlers: registered only while at least one wagon exists (same rule in on_load).

local on_tick, on_destroyed, on_state, on_turret_died, on_rotated
local live = false
local TURRET_FILTER = { { filter = "name", name = TURRET } }

local function sync_handlers()
    local want = storage.list[1] ~= nil
    if want == live then return end
    live = want
    script.on_event(ev.on_tick, want and on_tick or nil)
    script.on_event(ev.on_object_destroyed, want and on_destroyed or nil)
    script.on_event(ev.on_train_changed_state, want and on_state or nil)
    script.on_event(ev.on_player_rotated_entity, want and on_rotated or nil)
    if want then
        script.on_event(ev.on_entity_died, on_turret_died, TURRET_FILTER)
    else
        script.on_event(ev.on_entity_died, nil)
    end
end

---------------------------------------------------------------------------------------------------
-- Records

local function activate(rec)
    if rec.pending then return end
    rec.idle = 0
    if rec.mi then return end
    local moving = storage.moving
    local n = #moving + 1
    moving[n] = rec
    rec.mi = n
end

local function deactivate(rec)
    local moving = storage.moving
    local i, n = rec.mi, #moving
    local last = moving[n]
    moving[i] = last
    last.mi = i
    moving[n] = nil
    rec.mi = nil
end

--- Removes a record from all tables; entities are not touched.
local function forget(rec)
    local units = storage.units
    units[rec.id] = nil
    if rec.t1 then units[rec.t1] = nil end
    if rec.t2 then units[rec.t2] = nil end
    if rec.mi then deactivate(rec) end
    local list = storage.list
    local i, n = rec.li, #list
    local last = list[n]
    list[i] = last
    last.li = i
    list[n] = nil
    rec.li = nil
end

local function destroy(entity)
    if entity and entity.valid then entity.destroy() end
end

--- Removes the record and destroys what is left of the wagon and its turrets.
local function teardown(rec)
    if not rec.li then return end
    forget(rec)
    destroy(rec.a)
    destroy(rec.b)
    destroy(rec.wagon)
    sync_handlers()
end

local function make_turret(wagon, position, quarter)
    return wagon.surface.create_entity({
        name = TURRET,
        position = position,
        direction = DIRECTIONS[quarter],
        force = wagon.force,
        player = wagon.last_user,
        quality = wagon.quality,
        create_build_effect_smoke = false,
        raise_built = false,
    })
end

--- Creates the turrets of a wagon once; returns the record.
local function restore_clone(rec)
    local saved = rec.clone_snapshot
    if not saved then return end
    for i, turret in ipairs({rec.a, rec.b}) do
        local data = saved[i]
        if data.fluid then turret.set_fluid(1, data.fluid) else turret.clear_fluid(1) end
        turret.health = data.health
    end
    rec.clone_snapshot = nil
end

local function create_turrets(rec)
    local wagon = rec.wagon
    local q = quadrant(place(wagon, 0))
    local a = make_turret(wagon, PA, q)
    local b = a and a.valid and make_turret(wagon, PB, (q + 2) % 4)
    if not (b and b.valid) then
        destroy(a)
        rec.pending = true
        rec.retry_tick = game.tick + SERVICE_PERIOD
        if not rec.creation_warned then
            log("Flamethrower Wagon: helper creation failed for wagon " .. rec.id .. "; retry scheduled")
            rec.creation_warned = true
        end
        return false
    end
    rec.a, rec.b, rec.q = a, b, q
    rec.t1, rec.t2 = a.unit_number, b.unit_number
    rec.pending, rec.retry_tick, rec.creation_warned = nil, nil, nil
    storage.units[rec.t1], storage.units[rec.t2] = rec, rec
    script.register_on_object_destroyed(a)
    script.register_on_object_destroyed(b)
    restore_clone(rec)
    activate(rec)
    return true
end

local function register(wagon)
    local id = wagon.unit_number
    local rec = storage.units[id]
    if rec then return rec end
    local list = storage.list
    local li = #list + 1
    rec = {wagon = wagon, id = id, li = li, idle = 0, pending = true}
    list[li], storage.units[id] = rec, rec
    script.register_on_object_destroyed(wagon)
    create_turrets(rec)
    sync_handlers()
    return rec
end

---------------------------------------------------------------------------------------------------
-- Movement

local function move(rec, wagon, speed)
    local a, b = rec.a, rec.b
    if not (a.valid and b.valid) then
        teardown(rec)
        return
    end
    local q = quadrant(place(wagon, speed))
    local dq = (q - rec.q) % 4
    if dq ~= 0 then
        if dq == 2 then
            -- The wagon was flipped at once (rotation): turret b is at the front now.
            a, b = b, a
            rec.a, rec.b = a, b
        else
            -- A curve crossed a quarter: the roof picture of the gun depends on the base direction.
            a.direction = DIRECTIONS[q]
            b.direction = DIRECTIONS[(q + 2) % 4]
        end
        rec.q = q
    end
    a.teleport(PA)
    b.teleport(PB)
end

---------------------------------------------------------------------------------------------------
-- Fuel

local function mix(f, name, amount, temperature)
    if not f then
        return { name = name, amount = amount, temperature = temperature }
    end
    local total = f.amount + amount
    return {
        name = name,
        amount = total,
        temperature = (f.amount * f.temperature + amount * temperature) / total,
    }
end

--- Need of one turret for the wagon fluid. A turret with another fuel fires it first and is
--- switched when nearly empty; a fluid that is no fuel (any more) is replaced at once.
local function need_of(f, name)
    if not f then return capacity, nil end
    if f.name == name then return capacity - f.amount, f end
    if f.amount < MIN_TRANSFER or not fuels[f.name] then return capacity, nil end
    return 0, nil
end

--- Services one record; returns false when the record was removed.
local function service(rec)
    local wagon, a, b = rec.wagon, rec.a, rec.b
    if not wagon.valid then teardown(rec); return false end
    if rec.pending then
        if game.tick < rec.retry_tick or not create_turrets(rec) then return true end
        a, b = rec.a, rec.b
    end
    if not (a and a.valid and b and b.valid) then
        teardown(rec)
        return false
    end
    if not rec.mi and wagon.speed ~= 0 then activate(rec) end -- moved without a state change

    if not capacity then load_prototypes() end
    -- Factorio 2.1: LuaEntity::fluidbox was removed; storage 1 of a turret is its fluid box (2 is the internal buffer)
    local fa, fb = a.get_fluid(1), b.get_fluid(1)
    if fa and fb and capacity - fa.amount < MIN_TRANSFER and capacity - fb.amount < MIN_TRANSFER then
        return true
    end

    local src = wagon.get_fluid(1)
    if not src then return true end
    local name = src.name
    if not fuels[name] then return true end

    local need_a, keep_a = need_of(fa, name)
    local need_b, keep_b = need_of(fb, name)
    if need_a < MIN_TRANSFER then need_a = 0 end
    if need_b < MIN_TRANSFER then need_b = 0 end
    local want = need_a + need_b
    if want == 0 then return true end

    local got = wagon.extract_fluid({ name = name, amount = min(want, src.amount) }) -- Factorio 2.1: remove_fluid{} renamed
    if got <= 0 then return true end
    local give_a = got * need_a / want
    local give_b = got - give_a
    local temperature = src.temperature
    if give_a > 0 then a.set_fluid(1, mix(keep_a, name, give_a, temperature)) end
    if give_b > 0 then b.set_fluid(1, mix(keep_b, name, give_b, temperature)) end
    return true
end

---------------------------------------------------------------------------------------------------
-- Dynamic handlers

on_tick = function()
    local moving = storage.moving
    for i = #moving, 1, -1 do
        local rec = moving[i]
        if rec then -- a teardown during this loop may shrink the array
            local wagon = rec.wagon
            if not wagon.valid then
                teardown(rec)
            else
                local speed = wagon.speed
                if speed ~= 0 then
                    rec.idle = 0
                    move(rec, wagon, speed)
                else
                    local idle = rec.idle + 1
                    rec.idle = idle
                    if idle == 1 then
                        move(rec, wagon, 0) -- settle exactly where the wagon stopped
                    elseif idle == PARK_CHECK and PARKED[wagon.train.state] then
                        deactivate(rec)
                    end
                end
            end
        end
    end

    local list = storage.list
    local n = #list
    if n == 0 then return end
    local cursor = storage.cursor
    for _ = 1, ceil(n / SERVICE_PERIOD) do
        if cursor > n then cursor = 1 end
        if service(list[cursor]) then cursor = cursor + 1 end
        n = #list
        if n == 0 then break end
    end
    storage.cursor = cursor
end

on_destroyed = function(event)
    if event.type ~= ENTITY then return end
    local rec = storage.units[event.useful_id]
    if rec then teardown(rec) end
end

on_state = function(event)
    local train = event.train
    if not train.valid then return end
    local wagons = train.fluid_wagons
    local units = storage.units
    for i = 1, #wagons do
        local rec = units[wagons[i].unit_number]
        if rec then activate(rec) end
    end
end

--- A killed turret kills its wagon (remnants, death events, ghost for rebuilding).
on_turret_died = function(event)
    local turret = event.entity
    local rec = storage.units[turret.unit_number]
    if not rec then return end
    forget(rec)
    destroy(rec.a == turret and rec.b or rec.a)
    local wagon = rec.wagon
    if wagon.valid then
        local cause = event.cause
        if cause and not cause.valid then cause = nil end
        if not wagon.die(event.force, cause) then destroy(wagon) end
    end
    sync_handlers()
end

on_rotated = function(event)
    local entity = event.entity
    if entity.valid and entity.name == WAGON then
        local rec = storage.units[entity.unit_number]
        if rec then activate(rec) end
    end
end

---------------------------------------------------------------------------------------------------
-- Static handlers

local function on_built(event)
    local wagon = event.entity
    if wagon and wagon.valid and wagon.name == WAGON then register(wagon) end
end

--- Safety net for wagons created by scripts without raise_built: every rolling stock joins a train.
local function on_train_created(event)
    local train = event.train
    if not (train and train.valid) then return end
    local wagons = train.fluid_wagons
    local units = storage.units
    for i = 1, #wagons do
        local wagon = wagons[i]
        if wagon.name == WAGON and not units[wagon.unit_number] then register(wagon) end
    end
end

-- Plain data survives a deferred clone even if its source wagon is removed meanwhile.
local function clone_snapshot(rec)
    if rec.pending then return rec.clone_snapshot end
    if rec.a and rec.a.valid and rec.b and rec.b.valid then
        return {{fluid = rec.a.get_fluid(1), health = rec.a.health},
            {fluid = rec.b.get_fluid(1), health = rec.b.health}}
    end
end

local function on_cloned(event)
    local dst = event.destination
    if not (dst and dst.valid) then return end
    if dst.name == TURRET then
        -- A cloned wagon gets its own turrets; area clones must not leave copies behind.
        if not storage.units[dst.unit_number] then dst.destroy() end
        return
    end
    local rec = register(dst)
    if not rec then return end
    local src = event.source
    local old = src and src.valid and storage.units[src.unit_number]
    if old and old ~= rec then
        rec.clone_snapshot = clone_snapshot(old)
        if not rec.pending then restore_clone(rec) end
    end
end

--- Drops broken records, adopts unknown wagons and removes orphan turrets.
local function reconcile()
    local list = storage.list
    for i = #list, 1, -1 do
        local rec = list[i]
        if rec and (not rec.wagon.valid or (not rec.pending and not
            (rec.a and rec.a.valid and rec.b and rec.b.valid))) then teardown(rec) end
    end
    local units = storage.units
    for _, surface in pairs(game.surfaces) do
        for _, wagon in pairs(surface.find_entities_filtered({ name = WAGON })) do
            if not units[wagon.unit_number] then register(wagon) end
        end
        for _, turret in pairs(surface.find_entities_filtered({ name = TURRET })) do
            if not units[turret.unit_number] then turret.destroy() end
        end
    end
end

script.on_init(function()
    init_storage()
    sync_handlers()
end)

script.on_configuration_changed(function()
    init_storage()
    load_prototypes()
    reconcile()
    sync_handlers()
end)

script.on_load(function()
    if storage.list then sync_handlers() end
end)

-- Diagnostics: counts and the unit numbers of the wagons polled every tick.
remote.add_interface(MOD_DATA, {
    stats = function()
        local polled = {}
        for _, rec in pairs(storage.moving or {}) do polled[rec.id] = true end
        return {
            wagons = storage.list and #storage.list or 0,
            moving = storage.moving and #storage.moving or 0,
            live = live,
            polled = polled,
        }
    end,
})

local WAGON_FILTER = { { filter = "name", name = WAGON } }
script.on_event(ev.on_built_entity, on_built, WAGON_FILTER)
script.on_event(ev.on_robot_built_entity, on_built, WAGON_FILTER)
script.on_event(ev.script_raised_built, on_built, WAGON_FILTER)
script.on_event(ev.script_raised_revive, on_built, WAGON_FILTER)
script.on_event(ev.on_entity_cloned, on_cloned, { { filter = "name", name = WAGON }, { filter = "name", name = TURRET } })
script.on_event(ev.on_train_created, on_train_created)
