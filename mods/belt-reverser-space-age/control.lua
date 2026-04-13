local function adjacentPosition(position, direction, distance)
    local distance = distance or 1
    if     direction == defines.direction.north then return { x = position.x,            y = position.y - distance }
    elseif direction == defines.direction.south then return { x = position.x,            y = position.y + distance }
    elseif direction == defines.direction.east  then return { x = position.x + distance, y = position.y            }
    elseif direction == defines.direction.west  then return { x = position.x - distance, y = position.y            }
    end
end

local oppositeDirection = {
    [defines.direction.north] = defines.direction.south,
    [defines.direction.south] = defines.direction.north,
    [defines.direction.east] = defines.direction.west,
    [defines.direction.west] = defines.direction.east,
}
local leftTurn = {
    [defines.direction.north] = defines.direction.west,
    [defines.direction.south] = defines.direction.east,
    [defines.direction.east] = defines.direction.north,
    [defines.direction.west] = defines.direction.south,
}
local rightTurn = {
    [defines.direction.north] = defines.direction.east,
    [defines.direction.south] = defines.direction.west,
    [defines.direction.east] = defines.direction.south,
    [defines.direction.west] = defines.direction.north,
}

local loaderTypes = {
    "loader",
    "loader-1x1"
}

local function getBeltLike(surface, position, type)
    return surface.find_entities_filtered{ position = position, type = type, }[1]
end

local function isLoaderType(type)
    for _, knownType in ipairs(loaderTypes) do
        if type == knownType then
            return true
        end
    end
    return false
end

local function isBeltTerminatingDownstream(belt, distance)
    local distance = distance or 1
    local downstreamBelt   = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "transport-belt")
    local downstreamUGBelt = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "underground-belt")
    local downstreamLoader = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), loaderTypes)
    if downstreamBelt   and downstreamBelt.direction ~= oppositeDirection[belt.direction] then return false end
    if downstreamUGBelt and downstreamUGBelt.direction == belt.direction and downstreamUGBelt.belt_to_ground_type == "input" then return false end
    if downstreamLoader and downstreamLoader.direction == belt.direction and downstreamLoader.loader_type == "input" then return false end
    return true
end

local function isBeltSideloadingDownstream(belt, distance)
    local distance = distance or 1
    local downstreamBelt   = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "transport-belt")
    local downstreamUGBelt = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "underground-belt")
    local downstreamLoader = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), loaderTypes)
    if downstreamLoader then return false end
    if downstreamUGBelt and (downstreamUGBelt.direction == belt.direction or downstreamUGBelt.direction == oppositeDirection[belt.direction]) then return false end
    if downstreamBelt   then
        if (downstreamBelt.direction   == belt.direction or downstreamBelt.direction   == oppositeDirection[belt.direction]) then return false else
        local upstreamBelt   = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, oppositeDirection[downstreamBelt.direction]), "transport-belt")
        local upstreamUGBelt = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, oppositeDirection[downstreamBelt.direction]), "underground-belt")
        local upstreamLoader = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, oppositeDirection[downstreamBelt.direction]), loaderTypes)
        local oppositeBelt   = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, belt.direction), "transport-belt")
        local oppositeUGBelt = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, belt.direction), "underground-belt")
        local oppositeLoader = getBeltLike(belt.surface, adjacentPosition(downstreamBelt.position, belt.direction), loaderTypes)

        local continuingBelt = true
        if not (upstreamBelt or upstreamUGBelt or upstreamLoader) then continuingBelt = false end
        if upstreamBelt   and upstreamBelt.direction   ~= downstreamBelt.direction then continuingBelt = false end
        if upstreamUGBelt and not (upstreamUGBelt.direction == downstreamBelt.direction and upstreamUGBelt.belt_to_ground_type == "output") then continuingBelt = false end
        if upstreamLoader and upstreamLoader.direction ~= downstreamBelt.direction then continuingBelt = false end

        local sandwichBelt = true
        if not (oppositeBelt or oppositeUGBelt or oppositeLoader) then sandwichBelt = false end
        if oppositeBelt   and oppositeBelt.direction   ~= oppositeDirection[belt.direction] then sandwichBelt = false end
        if oppositeUGBelt and not (oppositeUGBelt.direction == oppositeDirection[belt.direction] and oppositeUGBelt.belt_to_ground_type == "output") then sandwichBelt = false end
        if oppositeLoader and oppositeLoader.direction ~= oppositeDirection[belt.direction] then sandwichBelt = false end

        if not continuingBelt and not sandwichBelt then return false end
    end end
    return true
end

local function getNextBeltDownstream(belt)
    local distance = 1
    if belt.type == "underground-belt" and belt.belt_to_ground_type == "input" then
        if belt.neighbours then return belt.neighbours else return nil end
    end

    if isLoaderType(belt.type) then
        if belt.loader_type == "output" then
            if belt.tile_width > 1 or belt.tile_height > 1 then
                distance = 1.5
            end
        else
            return nil
        end
    end

    local downstreamBelt   = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "transport-belt")
    local downstreamUGBelt = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), "underground-belt")
    local downstreamLoader = getBeltLike(belt.surface, adjacentPosition(belt.position, belt.direction, distance), loaderTypes)


    if isBeltTerminatingDownstream(belt, distance) then return nil end
    if isBeltSideloadingDownstream(belt, distance) then return nil end
    local returnBelt = downstreamBelt or downstreamUGBelt or downstreamLoader
    return returnBelt
end

local function getUpstreamBeltInDirection(belt, direction, distance)
    local distance = distance or 1
    local upstreamBelt   = getBeltLike(belt.surface, adjacentPosition(belt.position, direction, distance), "transport-belt")
    local upstreamUGBelt = getBeltLike(belt.surface, adjacentPosition(belt.position, direction, distance), "underground-belt")
    local upstreamLoader = getBeltLike(belt.surface, adjacentPosition(belt.position, direction, distance), loaderTypes)
    if upstreamBelt and upstreamBelt.direction == oppositeDirection[direction] then return upstreamBelt end
    if upstreamLoader and upstreamLoader.direction == oppositeDirection[direction] and upstreamLoader.loader_type == "output" then return upstreamLoader end
    if upstreamUGBelt and upstreamUGBelt.direction == oppositeDirection[direction] and upstreamUGBelt.belt_to_ground_type == "output" then return upstreamUGBelt end
    return nil
end

local function getNextBeltUpstream(belt)
    if belt.type == "underground-belt" and belt.belt_to_ground_type == "output" then
        if belt.neighbours then return belt.neighbours else return nil end
    end

    if isLoaderType(belt.type) then
        if belt.loader_type == "input" then
            local linearBelt = getUpstreamBeltInDirection(belt, oppositeDirection[belt.direction], 1.5)
            if linearBelt then return linearBelt end
        end
        return nil
    end

    local linearBelt    = getUpstreamBeltInDirection(belt, oppositeDirection[belt.direction])
    local leftTurnBelt  = getUpstreamBeltInDirection(belt, leftTurn[belt.direction])
    local rightTurnBelt = getUpstreamBeltInDirection(belt, rightTurn[belt.direction])
    if linearBelt then return linearBelt end
    if leftTurnBelt and not rightTurnBelt then
        return leftTurnBelt end
    if rightTurnBelt and not leftTurnBelt then
        return rightTurnBelt end
    return nil
end

local function findStartOfBelt(currentBelt, initialBelt)
    local newBelt  = getNextBeltUpstream(currentBelt)
    if not newBelt then return currentBelt end
    if newBelt == initialBelt then
        if newBelt.type == "underground-belt" and newBelt.belt_to_ground_type == "input" then
            return newBelt
        else
            return currentBelt
        end
    end
    return findStartOfBelt(newBelt, initialBelt)
end

local function reverseBelt(belt, direction)
    if belt.type == "underground-belt" then
        -- only reverse inputs, unless the output is not connected - then reverse it too
        -- for now, assume that reversing ug belt just means reversing it
        if belt.belt_to_ground_type == "input" then
            belt.rotate()
        end
    elseif isLoaderType(belt.type) then
        belt.rotate()
    else
        local cw = (belt.direction + 4) % 16
        local ccw = (belt.direction - 4) % 16

        if direction == cw then
            belt.rotate()
        elseif direction == ccw then
            belt.rotate({reverse = true})
        else
            belt.rotate()
            belt.rotate()
        end
    end
end

local function reverseDownstreamBelts(currentBelt, startOfBelt)
    local newBelt = getNextBeltDownstream(currentBelt)
    if newBelt == nil then return -- we've nothing left to do as at end of belt
    elseif newBelt == startOfBelt then
        -- special case for when we detect a loop
        -- Normally the head of the belt is simply reversed. Here, the head of the belt is part of the loop so remember to set its direction correctly later
        directionToTurnStartBelt = oppositeDirection[currentBelt.direction]
        return
    else
        -- set newBelt direction to the opposite of current belt - this should reverse the entire line - but do it after reversing downstream
        reverseDownstreamBelts(newBelt, startOfBelt)
        reverseBelt(newBelt, oppositeDirection[currentBelt.direction])
    end
end

local function reverseEntireBelt(event)
    -- find belt under cursor
    player = game.players[event.player_index]
    if player.connected and player.selected and player.controller_type ~= defines.controllers.ghost then
        local initialBelt = player.selected
        if initialBelt and (initialBelt.type == "transport-belt" or initialBelt.type == "underground-belt" or isLoaderType(initialBelt.type)) then
            local startOfBelt = findStartOfBelt(initialBelt, initialBelt)
            directionToTurnStartBelt = oppositeDirection[startOfBelt.direction]
            reverseDownstreamBelts(startOfBelt, startOfBelt)
            reverseBelt(startOfBelt, directionToTurnStartBelt)
        end
    end
end

script.on_event('ReverseEntireBelt', reverseEntireBelt)
