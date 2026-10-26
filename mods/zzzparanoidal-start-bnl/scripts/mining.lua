-- Mining of wrecks and the ship: pickaxe targets for containers / simple-entity-with-owner,
-- scripted loot with the start level and quality for start wrecks, repaired stack health.
local config = require("shipwreck-config")
local quality = require("scripts.quality")
local fire = require("scripts.fire")
local M = {}

local loot = {[config.ship] = config.ship_loot} -- wreck name -> loot entries
for name, spec in pairs(config.wrecks) do loot[name] = spec.loot end

local targets = {} -- wreck name -> target name
local wreck_of = {} -- target name -> wreck name
for name in pairs(loot) do
    local target = config.target_prefix .. name
    if prototypes.entity[name] and prototypes.entity[target] then
        targets[name] = target
        wreck_of[target] = name
    end
end

function M.filters()
    local filters = {}
    for name in pairs(loot) do
        if prototypes.entity[name] then filters[#filters + 1] = {filter = "name", name = name} end
    end
    for target in pairs(wreck_of) do filters[#filters + 1] = {filter = "name", name = target} end
    return filters
end

local function mining(player, target)
    return player.character and player.selected == target and player.mining_state.mining
end

function M.on_tick(state)
    local entries = state.targets
    for id, entry in pairs(entries) do
        local active = false
        if entry.wreck.valid and entry.target.valid then
            for _, player in pairs(game.connected_players) do
                if mining(player, entry.target) then active = true; break end
            end
        end
        if not active then
            entries[id] = nil
            if entry.target.valid then
                for _, player in pairs(game.connected_players) do
                    if player.selected == entry.target then
                        player.selected = entry.wreck.valid and entry.wreck or nil
                    end
                end
                entry.target.destroy()
            end
        end
    end

    local watch = state.watch or {}
    for index in pairs(watch) do
        local player = game.get_player(index)
        local wreck = player and player.connected and player.selected
        local target_name = wreck and wreck.valid and targets[wreck.name]
        if not (target_name or (wreck and wreck.valid and wreck_of[wreck.name])) then
            watch[index] = nil -- points elsewhere now
        end
        if target_name and mining(player, wreck) and wreck.minable and player.can_reach_entity(wreck) then
            local entry = entries[wreck.unit_number]
            if not entry then
                local target = wreck.surface.create_entity({name = target_name, position = wreck.position, force = wreck.force})
                if target then
                    target.destructible = false
                    target.health = target.max_health * wreck.get_health_ratio()
                    entry = {wreck = wreck, target = target}
                    entries[wreck.unit_number] = entry
                end
            end
            if entry then player.selected = entry.target end
        end
    end
end

-- Selection changed: a player pointing at a wreck (or its pickaxe target) is watched by on_tick.
-- Returns true when the watch list may have changed.
function M.on_selected(state, event)
    local player = game.get_player(event.player_index)
    local selected = player and player.selected
    if selected and selected.valid and (targets[selected.name] or wreck_of[selected.name]) then
        state.watch = state.watch or {}
        if not state.watch[event.player_index] then
            state.watch[event.player_index] = true
            return true
        end
    end
    return false
end

local function is_start(state, entity)
    return state.start[script.register_on_object_destroyed(entity)] == true
end

-- Contents go to the player before the mining result, so the result buffer holds only loot.
function M.on_pre_player_mined(state, event)
    local entity = event.entity
    if not (entity and entity.valid and entity.type == "container" and loot[entity.name]) then return end
    if not is_start(state, entity) then return end
    local player = game.get_player(event.player_index)
    local inventory = entity.get_inventory(defines.inventory.chest)
    if not (player and inventory) or inventory.is_empty() then return end
    for i = 1, #inventory do
        local stack = inventory[i]
        if stack.valid_for_read then
            local inserted = player.insert(stack)
            if inserted < stack.count then
                local rest = {name = stack.name, count = stack.count - inserted, quality = stack.quality.name}
                entity.surface.spill_item_stack({position = player.position, stack = rest, enable_looted = true, allow_belts = false})
            end
            stack.clear()
        end
    end
end

-- `steps`: quality steps the wreck lost in a fire (scripts/fire.lua).
local function scripted_loot(state, buffer, entries, steps)
    buffer.clear()
    for _, entry in ipairs(entries) do
        local count = quality.roll(entry)
        if count > 0 and prototypes.item[entry[1]] then
            local stack = fire.degrade_loot({name = entry[1], count = count, quality = quality.of(state, entry[1])}, steps)
            if stack then buffer.insert(stack) end
        end
    end
end

local function repair(buffer)
    -- Crash damage must not make recovered items unstackable with ordinary items.
    for i = 1, #buffer do
        local stack = buffer[i]
        if stack.valid_for_read and stack.health < 1 then stack.health = 1 end
    end
end

function M.on_mined(state, event)
    local entity = event.entity
    if not (entity and entity.valid) then return end
    local wreck_name = wreck_of[entity.name]
    if wreck_name then
        for id, entry in pairs(state.targets) do
            if entry.target == entity then
                state.targets[id] = nil
                local player = event.player_index and game.get_player(event.player_index)
                if entry.wreck.valid and player then
                    -- Finish through normal player mining so contents, loot and other mods'
                    -- mining handlers are processed by the engine exactly once.
                    player.mine_entity(entry.wreck, true)
                end
                return
            end
        end
        return
    end
    local buffer = event.buffer
    if not (loot[entity.name] and buffer and buffer.valid) then return end
    if is_start(state, entity) then
        scripted_loot(state, buffer, loot[entity.name], fire.steps_of(entity))
        -- hazardous cargo of a wreck without an inventory that did not go off in a fire
        local leftover = fire.leftover(entity)
        if leftover then buffer.insert(leftover) end
    else
        repair(buffer)
    end
end

function M.on_destroyed(state, event)
    state.start[event.registration_number] = nil
end

return M
