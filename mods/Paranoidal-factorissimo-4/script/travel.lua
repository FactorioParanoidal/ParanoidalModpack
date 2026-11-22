-- This file contains frankly way too much code to basically make doors work.
-- Warning to future mainainers: do not attempt to rewrite this with landmines. Trust me.

local find_surrounding_factory = remote_api.find_surrounding_factory
local find_factory_by_area = remote_api.find_factory_by_area
local Passages = require("script.passages")

factorissimo.on_event(factorissimo.events.on_init(), function()
    storage.last_player_teleport = storage.last_player_teleport or {}
    Passages.rebuild()
end)
factorissimo.on_event(defines.events.on_forces_merged, Passages.rebuild)

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

local function teleport_safely(e, surface, position, player, prechecked)
    if not e.valid then return end
    if not player.valid then return end

    position = {x = position.x or position[1], y = position.y or position[2]}

    if e.is_player() and not e.character then -- god controller
        e.teleport(position, surface)
        storage.last_player_teleport[player.index] = game.tick
    else
        if prechecked then
            local origin, origin_surface = player.physical_position, player.physical_surface
            if not e.teleport({0, 0}, purgatory_surface()) then return false end
            if not e.teleport(position, surface) then
                e.teleport(origin, origin_surface)
                return false
            end
        else
            position = surface.find_non_colliding_position(e.character.name, position, 5, 0.5, false) or position
            e.teleport({0, 0}, purgatory_surface())
            e.teleport(position, surface)
        end
        storage.last_player_teleport[player.index] = game.tick
    end

    if player then factorissimo.update_factory_preview(player) end
    return true
end

local function enter_factory(e, factory, player)
    teleport_safely(e, factory.inside_surface, {factory.inside_door_x, factory.inside_door_y}, player)
end

local function leave_factory(e, factory, player)
    teleport_safely(e, factory.outside_surface, {factory.outside_door_x, factory.outside_door_y}, player)
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
local function check_position_and_leave_factory(player, walking_state, is_airborne)
    if player.controller_type == defines.controllers.remote then return end

    local position = player.physical_position

    local walking_direction = walking_state.direction
    local is_moving_downwards =
        walking_direction == defines.direction.south or
        walking_direction == defines.direction.southeast or
        walking_direction == defines.direction.southwest

    if not is_moving_downwards then return end

    local factory = find_surrounding_factory(player.physical_surface, position)
    if not factory then return end

    local y = position.y + (is_airborne and 0.5 or -1)
    if y <= factory.inside_door_y then return end

    if math.abs(position.x - factory.inside_door_x) >= 4 then return end
    if not (factory.outside_surface and factory.outside_surface.valid) then return end

    leave_factory(player, factory, player)
    factorissimo.update_factory_preview(player)
    factorissimo.update_overlay(factory)
    return true
end

local function check_position_and_enter_factory(player, walking_state, is_airborne)
    if player.controller_type == defines.controllers.remote then return end

    local physical_position = player.physical_position

    local walking_direction = walking_state.direction
    local is_moving_upwards = is_airborne
        or walking_direction == defines.direction.north
        or walking_direction == defines.direction.northeast
        or walking_direction == defines.direction.northwest

    if not is_moving_upwards then return end

    local factory = find_factory_by_area {
        surface = player.physical_surface,
        area = (not is_airborne) and {
            {physical_position.x - 0.2, physical_position.y - 0.3},
            {physical_position.x + 0.2, physical_position.y}
        } or nil,
        position = is_airborne and player.physical_position or nil
    }

    if not factory or factory.inactive or not (factory.inside_surface and factory.inside_surface.valid) then return end

    local door_width = is_airborne and 4 or 0.9
    local is_standing_in_doorway = physical_position.y > factory.outside_y + 1 and math.abs(physical_position.x - factory.outside_x) < door_width
    if not is_standing_in_doorway then return end

    enter_factory(player, factory, player)
    return true
end

local function try_passage(player, direction)
    if player.controller_type ~= defines.controllers.character or not player.character then return end
    local surface, port, dx, dy = Passages.destination(player.physical_surface, player.physical_position, direction)
    if not surface then return end

    -- Cross-surface teleport does not check collisions; accept only the exact tile center.
    local character = player.character.name
    local function arrive(position)
        local clear = surface.find_non_colliding_position(character, position, 0.01, 0.01, true)
        if not clear or clear.x ~= position.x or clear.y ~= position.y then return false end
        teleport_safely(player, surface, position, player, true)
        return true
    end

    -- Keep the same depth at the wall. Try the port first, then either neighboring tile along the wall.
    if arrive(port) or arrive({x = port.x - dy, y = port.y + dx}) then return end
    arrive({x = port.x + dy, y = port.y - dx})
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
        if not player.driving and tick - (last_teleport[player.index] or 0) >= 35 then
            local walking_state = player.walking_state
            if walking_state.walking then
                if jetpacks == nil then jetpacks = get_jetpacks() or false end
                local airborne = is_airborne(jetpacks or nil, player)
                if not check_position_and_enter_factory(player, walking_state, airborne)
                    and not check_position_and_leave_factory(player, walking_state, airborne) then
                    try_passage(player, walking_state.direction)
                end
            end
        end
    end
end)
