local salvage = require("shipwreck-salvage-definitions")
local M = {}
local target_names = {}
for name in pairs(salvage.names) do
    local target_name = salvage.target_prefix .. name
    if prototypes.entity[target_name] then target_names[name] = target_name end
end

function M.init()
    if not script.active_mods.LootingSpaceshipWrecks then return end
    local bonus = settings.global["lootingspaceshipwrecks-bonus-start-items"]
    if not (bonus and bonus.value) then return end

    local freeplay = remote.interfaces.freeplay
    if not (freeplay and freeplay.get_created_items and freeplay.set_created_items
        and freeplay.get_ship_items and freeplay.set_ship_items
        and freeplay.get_debris_items and freeplay.set_debris_items) then return end

    local items = remote.call("freeplay", "get_ship_items")
    items["nuclear-fuel"] = nil
    for name, count in pairs({
        ["repair-pack"] = math.random(100, 200),
        ["bob-basic-circuit-board"] = math.random(20, 40),
    }) do
        if prototypes.item[name] then
            items[name] = (items[name] or 0) + count
        else
            log("Paranoidal shipwreck salvage: optional starting loot unavailable: " .. name)
        end
    end
    remote.call("freeplay", "set_ship_items", items)
end

local function on(event, callback)
    local previous = script.get_event_handler(event)
    script.on_event(event, function(e)
        if previous then previous(e) end
        callback(e)
    end)
end

local function mining(player, target)
    return player.character and player.selected == target and player.mining_state.mining
end

on(defines.events.on_tick, function()
    local targets = storage.paranoidal_shipwreck_mining
    for id, entry in pairs(targets or {}) do
        local active = false
        if entry.wreck.valid and entry.target.valid then
            for _, player in pairs(game.players) do
                if mining(player, entry.target) then active = true; break end
            end
        end
        if not active then
            targets[id] = nil
            if entry.target.valid then
                for _, player in pairs(game.players) do
                    if player.selected == entry.target then
                        player.selected = entry.wreck.valid and entry.wreck or nil
                    end
                end
                entry.target.destroy()
            end
        end
    end

    for _, player in pairs(game.players) do
        local wreck = player.selected
        local target_name = wreck and wreck.valid and target_names[wreck.name]
        if target_name and mining(player, wreck) and wreck.minable and player.can_reach_entity(wreck) then
            targets = targets or {}
            storage.paranoidal_shipwreck_mining = targets
            local entry = targets[wreck.unit_number]
            if not entry then
                local target = wreck.surface.create_entity{
                    name = target_name, position = wreck.position, force = wreck.force,
                }
                if target then
                    target.destructible = false
                    target.health = target.max_health * wreck.get_health_ratio()
                    entry = {wreck = wreck, target = target}
                    targets[wreck.unit_number] = entry
                end
            end
            if entry then player.selected = entry.target end
        end
    end
end)

local function repair_loot(event)
    local entity = event.entity
    if not (entity and entity.valid) or entity.name:sub(1, 20) ~= "crash-site-spaceship" then return end
    -- Crash damage must not make recovered items unstackable with ordinary items.
    local buffer = event.buffer
    if not (buffer and buffer.valid) then return end
    for i = 1, #buffer do
        local stack = buffer[i]
        if stack.valid_for_read and stack.health < 1 then stack.health = 1 end
    end
end

on(defines.events.on_player_mined_entity, function(event)
    repair_loot(event)
    local targets = storage.paranoidal_shipwreck_mining
    for id, entry in pairs(targets or {}) do
        if entry.target == event.entity then
            targets[id] = nil
            local player = game.get_player(event.player_index)
            if entry.wreck.valid and player then
                -- Finish through normal player mining so inventory contents, loot and
                -- other mods' mining handlers are processed by the engine exactly once.
                player.mine_entity(entry.wreck, true)
            end
            return
        end
    end
end)

on(defines.events.on_robot_mined_entity, repair_loot)

return M
