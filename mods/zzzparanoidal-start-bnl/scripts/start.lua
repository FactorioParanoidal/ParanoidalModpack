-- New map: empty freeplay item lists, the AAI scene and, after freeplay has created the crash
-- site for the first player, the ship and debris contents with the start level and quality.
local config = require("shipwreck-config")
local quality = require("scripts.quality")
local aai = require("scripts.aai-crash")
local M = {}

local FILL_ATTEMPTS = 60

-- Set by control.lua: called once after the ship and debris are filled, with the ship and every
-- start wreck entity (the BnL start content builds on them).
M.on_ready = nil

-- Start wrecks get the scripted loot of scripts/mining.lua; the key works also for simple-entity.
function M.mark(state, entity)
    state.start[script.register_on_object_destroyed(entity)] = true
end

local function freeplay_ready()
    local freeplay = remote.interfaces.freeplay
    return freeplay and freeplay.set_created_items and freeplay.set_ship_items and freeplay.set_debris_items
end

function M.init(state)
    if game.tick >= 2 then return end -- added to a running map: nothing is given out
    if freeplay_ready() then
        -- After aai-industry and angelsrefining (optional dependencies): their additions are part
        -- of shipwreck-config.lua; the player starts empty, respawn items stay.
        remote.call("freeplay", "set_created_items", {})
        remote.call("freeplay", "set_ship_items", {})
        remote.call("freeplay", "set_debris_items", {})
        state.pending = true
    end
    state.aai = {}
    state.aai_all = {}
    for _, entity in ipairs(aai.create(state)) do
        M.mark(state, entity)
        state.aai_all[#state.aai_all + 1] = entity
        if entity.type == "container" then state.aai[#state.aai + 1] = entity end
    end
    log("zzzparanoidal-start-bnl: start level " .. quality.level_name() .. ", AAI wrecks " .. #state.aai
        .. (state.pending and ", waiting for the freeplay crash site" or ", no freeplay crash site"))
end

function M.on_player_created(state, event)
    if state.pending and not state.fill_tick then
        state.fill_tick = event.tick + 1
        state.fill_player = event.player_index
    end
end

local function spill(ship, stack)
    ship.surface.spill_item_stack({position = ship.position, stack = stack, enable_looted = true, allow_belts = false})
end

local function into_ship(ship, inventory, stack)
    local inserted = inventory.insert(stack)
    if inserted < stack.count then
        spill(ship, {name = stack.name, count = stack.count - inserted, quality = stack.quality})
    end
end

local REPAIR_PACK = "repair-pack"

local function stacks(state, entry)
    local name = entry[1]
    local count = quality.roll(entry)
    if count <= 0 or not quality.available(name) then return {} end
    if name == REPAIR_PACK then
        -- the mechanic profession doubles the start repair packs (scripts/professions.lua)
        count = count * (state.repair_multiplier or 1)
        state.repair_total = (state.repair_total or 0) + count
    end
    local size = prototypes.item[name].stack_size
    local rolled = quality.of(state, name)
    local normal = rolled == "normal" and count or quality.normal_count(name, count)
    local list = {}
    local function add(total, quality_name)
        while total > 0 do
            local amount = math.min(total, size)
            list[#list + 1] = {name = name, count = amount, quality = quality_name}
            total = total - amount
        end
    end
    add(normal, "normal")
    add(count - normal, rolled)
    return list
end

local function fill(state, ship)
    local surface = ship.surface
    M.mark(state, ship)
    local inventory = ship.get_inventory(defines.inventory.chest)

    local containers = {}
    local wrecks = {}
    local wreck_names = {}
    for name in pairs(config.wrecks) do
        if name:sub(1, #config.ship) == config.ship and prototypes.entity[name] then wreck_names[#wreck_names + 1] = name end
    end
    for _, entity in pairs(surface.find_entities_filtered({position = ship.position, radius = config.crash_radius, name = wreck_names})) do
        M.mark(state, entity)
        wrecks[#wrecks + 1] = entity
        if entity.type == "container" then containers[#containers + 1] = entity end
    end
    for _, entity in ipairs(state.aai or {}) do
        if entity.valid and entity.surface == surface then containers[#containers + 1] = entity end
    end
    for _, entity in ipairs(state.aai_all or {}) do
        if entity.valid and entity.surface == surface then wrecks[#wrecks + 1] = entity end
    end

    for _, entry in ipairs(config.ship_items) do
        for _, stack in ipairs(stacks(state, entry)) do into_ship(ship, inventory, stack) end
    end

    for _, entry in ipairs(config.debris_items) do
        for _, stack in ipairs(stacks(state, entry)) do
            local free = {}
            for _, container in ipairs(containers) do
                local target = container.valid and container.get_inventory(defines.inventory.chest)
                if target and target.count_empty_stacks() > 0 then free[#free + 1] = target end
            end
            local left = stack.count
            if #free > 0 then left = left - free[math.random(#free)].insert(stack) end
            if left > 0 then into_ship(ship, inventory, {name = stack.name, count = left, quality = stack.quality}) end
        end
    end
    state.aai, state.aai_all = nil, nil
    state.ship = ship
    state.filled = true
    if M.on_ready then M.on_ready(state, ship, wrecks) end
end

-- Extra start repair packs after the fill (the mechanic chose later): same quality split.
function M.add_repair_packs(state, count)
    local ship = state.ship
    if count <= 0 or not (ship and ship.valid) or not quality.available(REPAIR_PACK) then return end
    local rolled = quality.of(state, REPAIR_PACK)
    local normal = rolled == "normal" and count or quality.normal_count(REPAIR_PACK, count)
    local inventory = ship.get_inventory(defines.inventory.chest)
    if normal > 0 then into_ship(ship, inventory, {name = REPAIR_PACK, count = normal, quality = "normal"}) end
    if count > normal then into_ship(ship, inventory, {name = REPAIR_PACK, count = count - normal, quality = rolled}) end
    state.repair_total = (state.repair_total or 0) + count
end

local function find_ship(state)
    local player = state.fill_player and game.get_player(state.fill_player)
    local surface = player and player.valid and player.surface or game.surfaces.nauvis
    return surface and surface.find_entities_filtered({
        name = config.ship, position = config.ship_position, radius = 3, limit = 1,
    })[1]
end

function M.on_tick(state, tick)
    if not state.fill_tick or tick < state.fill_tick then return end
    local ship = find_ship(state)
    if ship then
        fill(state, ship)
    else
        state.fill_attempts = (state.fill_attempts or 0) + 1
        if state.fill_attempts < FILL_ATTEMPTS then
            state.fill_tick = tick + 1
            return
        end
        log("zzzparanoidal-start-bnl: no freeplay crash site found, start supplies are not given")
    end
    state.pending, state.fill_tick, state.fill_player, state.fill_attempts, state.aai = nil, nil, nil, nil, nil
end

return M
