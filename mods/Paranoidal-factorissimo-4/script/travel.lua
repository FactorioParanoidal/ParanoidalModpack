-- This file contains frankly way too much code to basically make doors work.
-- Warning to future mainainers: do not attempt to rewrite this with landmines. Trust me.

local find_surrounding_factory = remote_api.find_surrounding_factory
local find_factory_by_area = remote_api.find_factory_by_area
local Passages = require("script.passages")
local d = defines.direction
local travel_cooldown = 35

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.last_player_teleport = storage.last_player_teleport or {}
    Passages.rebuild()
end)
factorissimo.on_event(defines.events.on_forces_merged, Passages.rebuild)
factorissimo.on_event(defines.events.on_player_removed, function(event)
    local returns = storage.factory_travel_returns
    if returns then returns[event.player_index] = nil end
end)

--- This function exists in order to teleport the personal robopots of a player along with the player when moving between factories.
local function purgatory_surface()
    if remote.interfaces["RSO"] then -- RSO compatibility
        pcall(remote.call, "RSO", "ignoreSurface", "factory-travel-surface")
    end

    local planet = game.planets["factory-travel-surface"]
    if planet.surface then return planet.surface end

    local surface = planet.create_surface()
    surface.set_chunk_generated_status({0, 0}, defines.chunk_generated_status.entities)
    surface.set_chunk_generated_status({-1, 0}, defines.chunk_generated_status.entities)
    surface.set_chunk_generated_status({0, -1}, defines.chunk_generated_status.entities)
    surface.set_chunk_generated_status({-1, -1}, defines.chunk_generated_status.entities)

    return surface
end

-- Retry only a failed return from the transit surface, even if the player stops walking.
local function recover_travel(player, tick)
    local returns = storage.factory_travel_returns
    local pending = returns and returns[player.index]
    if not pending then return end
    if player.physical_surface ~= pending.transit then
        returns[player.index] = nil
    elseif tick - (storage.last_player_teleport[player.index] or 0) >= travel_cooldown then
        storage.last_player_teleport[player.index] = tick
        if pending.surface.valid and player.controller_type ~= defines.controllers.remote
            and player.teleport(pending.position, pending.surface) then
            returns[player.index] = nil
            factorissimo.update_factory_preview(player)
        end
    end
    return true
end

local function teleport_safely(player, surface, position, prechecked)
    if not player.valid then return false end
    -- Throttle failed attempts as well as successes, so holding a key cannot spam teleports.
    storage.last_player_teleport[player.index] = game.tick
    if not player.character then -- God controller: no personal robots to transfer.
        if not player.teleport(position, surface) then return false end
    else
        if not prechecked then
            position = surface.find_non_colliding_position(player.character.name, position, 5, 0.5, false) or position
        end
        local origin, origin_surface = player.physical_position, player.physical_surface
        local transit = purgatory_surface()
        if not player.teleport({0, 0}, transit) then return false end
        if not (surface.valid and player.teleport(position, surface)) then
            if player.valid and player.physical_surface == transit then
                if not (origin_surface.valid and player.teleport(origin, origin_surface)) then
                    storage.factory_travel_returns = storage.factory_travel_returns or {}
                    storage.factory_travel_returns[player.index] = {surface = origin_surface, position = origin, transit = transit}
                    log("Factorissimo: scheduled travel recovery for player " .. player.index)
                end
            end
            return false
        end
    end
    factorissimo.update_factory_preview(player)
    return true
end

-- https://mods.factorio.com/mod/jetpack
local function get_jetpacks()
    local jetpack = script.active_mods.jetpack
    if jetpack then
        return remote.call("jetpack", "get_jetpacks", {})
    end
    return nil
end

-- Check for the mech suit or the jetpack mod
-- I could not find a good way to check if the mech suit jetpack is "active" so just it returns true
-- This is fine as the mech suit is effectively always active
local function is_airborne(jetpacks, player)
    if not player.character then return false end

    local armor_inventory = player.get_inventory(defines.inventory.character_armor)
    if armor_inventory then
        for i = 1, #armor_inventory do
            local armor = armor_inventory[i]
            if armor.valid_for_read and armor.prototype.provides_flight then
                return true
            end
        end
    end

    if not jetpacks then return false end
    local data = jetpacks[player.character.unit_number]
    if data == nil then return false end
    return data.status == "flying"
end

-- The remote view has no well-defined position; it is handled by shift clicking the factory/power monitor.
-- God, editor and spectator controllers walk in and out like characters (e.g. Blueprint Sandboxes).
local function check_position_and_leave_factory(player, factory, position, is_airborne)
    if not factory then return end

    local y = position.y + (is_airborne and 0.5 or -1)
    if y <= factory.inside_door_y then return end

    if math.abs(position.x - factory.inside_door_x) >= 4 then return end
    if not (factory.outside_surface and factory.outside_surface.valid) then return end

    if teleport_safely(player, factory.outside_surface, {factory.outside_door_x, factory.outside_door_y}) then
        factorissimo.update_overlay(factory)
    end
    return true -- The ordinary doorway owns this attempt, even if travel failed.
end

local function check_position_and_enter_factory(player, surface, position, direction, is_airborne)
    local is_moving_upwards = is_airborne or direction == d.north or direction == d.northeast or direction == d.northwest

    if not is_moving_upwards then return end

    local factory = find_factory_by_area {
        surface = surface,
        area = (not is_airborne) and {
            {position.x - 0.2, position.y - 0.3},
            {position.x + 0.2, position.y}
        } or nil,
        position = is_airborne and position or nil
    }

    if not factory or factory.inactive or not (factory.inside_surface and factory.inside_surface.valid) then return end

    local door_width = is_airborne and 4 or 0.9
    local is_standing_in_doorway = position.y > factory.outside_y + 1 and math.abs(position.x - factory.outside_x) < door_width
    if not is_standing_in_doorway then return end

    teleport_safely(player, factory.inside_surface, {factory.inside_door_x, factory.inside_door_y})
    return true -- Do not try a passage after a matched ordinary doorway.
end

local function try_passage(player, factory, position, direction)
    local surface, port, dx, dy = Passages.destination(factory, position, direction)
    if not surface then return end

    -- Cross-surface teleport does not check collisions; accept only the exact tile center.
    local character = player.character.name
    local function clear_tile(candidate)
        local clear = surface.find_non_colliding_position(character, candidate, 0.01, 0.01, true)
        if clear and clear.x == candidate.x and clear.y == candidate.y then return clear end
    end

    -- Find a free cell along the wall before attempting any teleport.
    local arrival = clear_tile(port) or clear_tile({x = port.x - dy, y = port.y + dx})
        or clear_tile({x = port.x + dy, y = port.y - dx})
    if arrival then return teleport_safely(player, surface, arrival, true) end
end

-- Reuse the ordinary door checks; nothing polls passage pairs or their endpoints.
factorissimo.on_nth_tick(6, function(event)
    -- Existing 9.20.0 saves may load the new Lua without a configuration-changed event.
    if not storage.factory_passages or storage.factory_passage_revision ~= Passages.revision then
        Passages.rebuild()
    elseif storage.factory_passage_marker_revision ~= Passages.marker_revision then
        Passages.refresh_saved_markers()
    end
    local tick = event.tick
    local last_teleport = storage.last_player_teleport
    if not last_teleport then return end
    local jetpacks -- fetched once, only when somebody is walking
    for _, player in pairs(game.connected_players) do
        local controller = player.controller_type
        if not recover_travel(player, tick) and controller ~= defines.controllers.remote and not player.driving
            and tick - (last_teleport[player.index] or 0) >= travel_cooldown then
            local walking_state = player.walking_state
            if walking_state.walking then
                if jetpacks == nil then jetpacks = get_jetpacks() or false end
                local airborne = is_airborne(jetpacks or nil, player)
                local surface, position, direction = player.physical_surface, player.physical_position, walking_state.direction
                if not check_position_and_enter_factory(player, surface, position, direction, airborne) then
                    local southwards = direction == d.south or direction == d.southeast or direction == d.southwest
                    local can_use_passage = controller == defines.controllers.character and player.character
                    if southwards or can_use_passage then
                        local factory = find_surrounding_factory(surface, position)
                        if not (southwards and check_position_and_leave_factory(player, factory, position, airborne))
                            and can_use_passage then
                            try_passage(player, factory, position, direction)
                        end
                    end
                end
            end
        end
    end
end)
