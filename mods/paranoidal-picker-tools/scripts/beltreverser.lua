-------------------------------------------------------------------------------
--[[Belt Reverser]] -- from Belt Reverser 2.0 (belt-reverser-space-age) by Cornbread, MIT
-------------------------------------------------------------------------------
-- ALT + R over a belt reverses the whole segment: belts, underground belts and loaders.
-- Paranoidal: one entity search per tile instead of three, no global variables, only belts of the
-- player's force, the walks are loops with a visited set (no deep recursion on long belts), and
-- the rotations raise on_player_rotated_entity.
local events = require('utils/events')

local north, south, east, west = defines.direction.north, defines.direction.south, defines.direction.east, defines.direction.west

local oppositeDirection = {[north] = south, [south] = north, [east] = west, [west] = east}
local leftTurn = {[north] = west, [south] = east, [east] = north, [west] = south}
local rightTurn = {[north] = east, [south] = west, [east] = south, [west] = north}

local SEARCH_TYPES = {'transport-belt', 'underground-belt', 'loader', 'loader-1x1'}
local LOADER = {['loader'] = true, ['loader-1x1'] = true}

local function adjacentPosition(position, direction, distance)
    distance = distance or 1
    if direction == north then
        return {x = position.x, y = position.y - distance}
    elseif direction == south then
        return {x = position.x, y = position.y + distance}
    elseif direction == east then
        return {x = position.x + distance, y = position.y}
    elseif direction == west then
        return {x = position.x - distance, y = position.y}
    end
end

--- The first belt, underground belt and loader of the force at a position
local function beltsAt(belt, position)
    local found = {}
    if not position then
        return found
    end
    for _, entity in pairs(belt.surface.find_entities_filtered {position = position, type = SEARCH_TYPES, force = belt.force}) do
        local kind = LOADER[entity.type] and 'loader' or entity.type
        if not found[kind] then
            found[kind] = entity
        end
    end
    return found
end

local function isBeltTerminatingDownstream(belt, found)
    local downstreamBelt, downstreamUGBelt, downstreamLoader = found['transport-belt'], found['underground-belt'], found.loader
    if downstreamBelt and downstreamBelt.direction ~= oppositeDirection[belt.direction] then return false end
    if downstreamUGBelt and downstreamUGBelt.direction == belt.direction and downstreamUGBelt.belt_to_ground_type == 'input' then return false end
    if downstreamLoader and downstreamLoader.direction == belt.direction and downstreamLoader.loader_type == 'input' then return false end
    return true
end

local function isBeltSideloadingDownstream(belt, found)
    local downstreamBelt, downstreamUGBelt, downstreamLoader = found['transport-belt'], found['underground-belt'], found.loader
    if downstreamLoader then return false end
    if downstreamUGBelt and (downstreamUGBelt.direction == belt.direction or downstreamUGBelt.direction == oppositeDirection[belt.direction]) then return false end
    if downstreamBelt then
        if downstreamBelt.direction == belt.direction or downstreamBelt.direction == oppositeDirection[belt.direction] then
            return false
        end
        local upstream = beltsAt(belt, adjacentPosition(downstreamBelt.position, oppositeDirection[downstreamBelt.direction]))
        local opposite = beltsAt(belt, adjacentPosition(downstreamBelt.position, belt.direction))
        local upstreamBelt, upstreamUGBelt, upstreamLoader = upstream['transport-belt'], upstream['underground-belt'], upstream.loader
        local oppositeBelt, oppositeUGBelt, oppositeLoader = opposite['transport-belt'], opposite['underground-belt'], opposite.loader

        local continuingBelt = true
        if not (upstreamBelt or upstreamUGBelt or upstreamLoader) then continuingBelt = false end
        if upstreamBelt and upstreamBelt.direction ~= downstreamBelt.direction then continuingBelt = false end
        if upstreamUGBelt and not (upstreamUGBelt.direction == downstreamBelt.direction and upstreamUGBelt.belt_to_ground_type == 'output') then continuingBelt = false end
        if upstreamLoader and upstreamLoader.direction ~= downstreamBelt.direction then continuingBelt = false end

        local sandwichBelt = true
        if not (oppositeBelt or oppositeUGBelt or oppositeLoader) then sandwichBelt = false end
        if oppositeBelt and oppositeBelt.direction ~= oppositeDirection[belt.direction] then sandwichBelt = false end
        if oppositeUGBelt and not (oppositeUGBelt.direction == oppositeDirection[belt.direction] and oppositeUGBelt.belt_to_ground_type == 'output') then sandwichBelt = false end
        if oppositeLoader and oppositeLoader.direction ~= oppositeDirection[belt.direction] then sandwichBelt = false end

        if not continuingBelt and not sandwichBelt then return false end
    end
    return true
end

local function getNextBeltDownstream(belt)
    local distance = 1
    if belt.type == 'underground-belt' and belt.belt_to_ground_type == 'input' then
        return belt.neighbours
    end

    if LOADER[belt.type] then
        if belt.loader_type ~= 'output' then
            return nil
        end
        if belt.tile_width > 1 or belt.tile_height > 1 then
            distance = 1.5
        end
    end

    local found = beltsAt(belt, adjacentPosition(belt.position, belt.direction, distance))
    if isBeltTerminatingDownstream(belt, found) then return nil end
    if isBeltSideloadingDownstream(belt, found) then return nil end
    return found['transport-belt'] or found['underground-belt'] or found.loader
end

local function getUpstreamBeltInDirection(belt, direction, distance)
    local found = beltsAt(belt, adjacentPosition(belt.position, direction, distance))
    local upstreamBelt, upstreamUGBelt, upstreamLoader = found['transport-belt'], found['underground-belt'], found.loader
    if upstreamBelt and upstreamBelt.direction == oppositeDirection[direction] then return upstreamBelt end
    if upstreamLoader and upstreamLoader.direction == oppositeDirection[direction] and upstreamLoader.loader_type == 'output' then return upstreamLoader end
    if upstreamUGBelt and upstreamUGBelt.direction == oppositeDirection[direction] and upstreamUGBelt.belt_to_ground_type == 'output' then return upstreamUGBelt end
    return nil
end

local function getNextBeltUpstream(belt)
    if belt.type == 'underground-belt' and belt.belt_to_ground_type == 'output' then
        return belt.neighbours
    end

    if LOADER[belt.type] then
        if belt.loader_type == 'input' then
            return getUpstreamBeltInDirection(belt, oppositeDirection[belt.direction], 1.5)
        end
        return nil
    end

    local linearBelt = getUpstreamBeltInDirection(belt, oppositeDirection[belt.direction])
    if linearBelt then return linearBelt end
    local leftTurnBelt = getUpstreamBeltInDirection(belt, leftTurn[belt.direction])
    local rightTurnBelt = getUpstreamBeltInDirection(belt, rightTurn[belt.direction])
    if leftTurnBelt and not rightTurnBelt then return leftTurnBelt end
    if rightTurnBelt and not leftTurnBelt then return rightTurnBelt end
    return nil
end

local function findStartOfBelt(initialBelt)
    local currentBelt = initialBelt
    local visited = {[initialBelt.unit_number] = true}
    while true do
        local newBelt = getNextBeltUpstream(currentBelt)
        if not newBelt then return currentBelt end
        if newBelt == initialBelt then
            if newBelt.type == 'underground-belt' and newBelt.belt_to_ground_type == 'input' then
                return newBelt
            end
            return currentBelt
        end
        if visited[newBelt.unit_number] then return currentBelt end
        visited[newBelt.unit_number] = true
        currentBelt = newBelt
    end
end

local function reverseBelt(belt, direction, player)
    if belt.type == 'underground-belt' then
        -- only the input is rotated; the engine turns its output with it
        if belt.belt_to_ground_type == 'input' then
            belt.rotate {by_player = player}
        end
    elseif LOADER[belt.type] then
        belt.rotate {by_player = player}
    else
        local cw = (belt.direction + 4) % 16
        local ccw = (belt.direction - 4) % 16
        if direction == cw then
            belt.rotate {by_player = player}
        elseif direction == ccw then
            belt.rotate {reverse = true, by_player = player}
        else
            belt.rotate {by_player = player}
            belt.rotate {by_player = player}
        end
    end
end

local function reverseEntireBelt(event)
    local player = game.get_player(event.player_index)
    if not (player and player.connected and player.controller_type ~= defines.controllers.ghost) then return end
    local initialBelt = player.selected
    if not (initialBelt and (initialBelt.type == 'transport-belt' or initialBelt.type == 'underground-belt' or LOADER[initialBelt.type])) then return end
    if initialBelt.force ~= player.force then return end

    local startOfBelt = findStartOfBelt(initialBelt)
    local directionToTurnStartBelt = oppositeDirection[startOfBelt.direction]

    -- Walk downstream first; nothing is rotated until the whole segment is known.
    local chain = {startOfBelt}
    local visited = {[startOfBelt.unit_number] = true}
    while true do
        local currentBelt = chain[#chain]
        local newBelt = getNextBeltDownstream(currentBelt)
        if newBelt == nil then break end
        if newBelt == startOfBelt then
            -- a loop: the head of the belt is part of it, so it turns against the last belt
            directionToTurnStartBelt = oppositeDirection[currentBelt.direction]
            break
        end
        if visited[newBelt.unit_number] then break end
        visited[newBelt.unit_number] = true
        chain[#chain + 1] = newBelt
    end

    -- From the tail back: each belt turns against its upstream belt, which is not rotated yet.
    for i = #chain, 2, -1 do
        reverseBelt(chain[i], oppositeDirection[chain[i - 1].direction], player)
    end
    reverseBelt(startOfBelt, directionToTurnStartBelt, player)
end

events.on('ReverseEntireBelt', reverseEntireBelt)
