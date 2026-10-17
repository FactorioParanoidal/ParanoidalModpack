--[[
This file is part of the mod InserterFuelLeech that is licensed under the
GNU GPL-3.0. See the file COPYING for a copy of the GNU GPLv3.0.
]]
local _ = nil

--- @param value double
--- @param divisor double
--- @return double
function round(value, divisor)
    return math.floor(value / divisor + 0.5) * divisor
end

--- @type table<double,double?>
local squareRootsCache = {}

--- @param x double
--- @return double
function calcSquareRoot(x)
    local result = squareRootsCache[x]
    if result == nil then
        result = math.sqrt(x)
        squareRootsCache[x] = result
    end
    return result
end

--- Reduces the amount of significant digits of a vector's components
--- to make following calculations' results more cache friendly.
--- @param x double
--- @param y double
--- @param granularity double
--- @return double, double
function granularizeVector(x, y, granularity)
    return round(x, granularity), round(y, granularity)
end

--- Reduces the amount of significant digits of a vector's components
--- to make following calculations' results more cache friendly.
--- @param mapPos MapPosition.0
--- @param granularity double
--- @return double, double
function granularizeMapPos(mapPos, granularity)
    return granularizeVector(mapPos.x, mapPos.y, granularity)
end

--- Moves a vectors coordinate system from (0, 0) to given base.
--- @param x double
--- @param y double
--- @param baseX double
--- @param baseY double
--- @return double rebasedX, double rebasedY
function rebaseVector(x, y, baseX, baseY)
    return x - baseX, y - baseY
end

--- Reduces the amount of significant digits of a vector's components
--- to make following calculations' results more cache friendly.
--- @param mapPos MapPosition.0
--- @param granularity double
--- @param baseX double already granularized
--- @param baseY double already granularized
--- @return double rebasedX, double rebasedY
function granularizeAndRebaseMapPos(mapPos, granularity, baseX, baseY)
    local xGranularized, yGranularized = granularizeVector(mapPos.x, mapPos.y, granularity)
    return rebaseVector(xGranularized, yGranularized, baseX, baseY)
end

--- @param x double
--- @param y double
--- @return double
function calcVector2Length(x, y)
    return calcSquareRoot(x * x + y * y)
end

--- @param aX double
--- @param aY double
--- @param bX double
--- @param bY double
--- @return double
function calcVector2Distance(aX, aY, bX, bY)
    return calcVector2Length(aX - bX, aY - bY)
end

--- @type table<double,double?>
local calcAcosTurnsCache = {}

--- @param x double
--- @param granularity double
--- @return double
function calcAcosTurns(x, granularity)
    local turns = calcAcosTurnsCache[x]
    if turns == nil then
        local roationAngleRad = math.acos(x) -- 0..Pi
        turns = round(roationAngleRad / math.pi / 2, granularity) -- 0..0.5
        calcAcosTurnsCache[x] = turns
    end
    return turns
end

--- All coordinates are assumed to be granularized and rebased.
--- @param startPosX double
--- @param startPosY double
--- @param destPosX double
--- @param destPosY double
--- @param granularity double
--- @param logger Logger?
--- @return double, double turns and extension
function calcVectorMinTurnsAndExtension(startPosX, startPosY, destPosX, destPosY, granularity, logger)
    local handExtension = calcVector2Length(startPosX, startPosY)
    local destExtension = calcVector2Length(destPosX, destPosY)
    local extensionDiff = math.abs(handExtension - destExtension)

    local dotProduct = startPosX * destPosX + startPosY * destPosY
    local lengthProduct = handExtension * destExtension
    local roationAngleCos = lengthProduct ~= 0 and dotProduct / lengthProduct or 1 -- -1..1
    local turns = calcAcosTurns(roationAngleCos, granularity)
    --local turnsRaw = math.atan(startPosX * destPosY - startPosY * destPosX, dotProduct) -- -Pi..Pi
    --local turns = math.abs(turnsRaw) / math.pi
    --if dotProduct < 0 then
    --    turns = 0.5 - turns
    --end
    _ = logger and logger("calcVectorMinTurnsAndExtension debug", {
        dotProduct = dotProduct,
        lengthProduct = lengthProduct,
        roationAngleCos = roationAngleCos,
        turns = turns,
    })
    return turns, extensionDiff
end

--- @param logger Logger
--- @return nil
function testCalcVectorMinTurnsAndExtension(logger)
    local granularity = 0.001
    local tests = {
        {"Same spot 1", 0, 0, 0, 0, 0,0},
        {"Same spot 2", 1, 0, 1, 0, 0,0},
        {"Same spot 3",-1, 0,-1, 0, 0,0},
        {"Same spot 4", 0, 1, 0, 1, 0,0},
        {"Same spot 5", 1, 1, 1, 1, 0,0},
        {"Same spot 6",-1, 1,-1, 1, 0,0},
        {"Same spot 7", 0,-1, 0,-1, 0,0},
        {"Same spot 8", 1,-1, 1,-1, 0,0},
        {"Same spot 9",-1,-1,-1,-1, 0,0},
        {"Same spot 10", 3, 7, 3, 7, 0,0},
        {"Same spot 11", 3,-7, 3,-7, 0,0},
        {"Same spot 12",-3, 7,-3, 7, 0,0},
        {"Same spot 13",-3,-7,-3,-7, 0,0},
        {"Extend 1", 1,0,2,0, 0,1},
        {"Extend 2", 2,0,1,0, 0,1},
        {"Quarter turn 1",  1, 0, 0,-1, 0.25,0},
        {"Quarter turn 2",  0,-1,-1, 0, 0.25,0},
        {"Quarter turn 3", -1, 0, 0, 1, 0.25,0},
        {"Quarter turn 4",  0, 1, 1, 0, 0.25,0},
        {"Quarter turn 5",  1, 1, 1,-1, 0.25,0},
        {"Quarter turn 6",  1,-1,-1,-1, 0.25,0},
        {"Quarter turn 7", -1,-1,-1, 1, 0.25,0},
        {"Quarter turn 8", -1, 1, 1, 1, 0.25,0},
        {"Quarter turn 9", 7.5, 7.5, 7.5,-7.5, 0.25,0},
        {"Half turn 1",  1, 0,-1, 0, 0.5,0},
        {"Half turn 2",  0,-1, 0, 1, 0.5,0},
        {"Half turn 3", -1, 0, 1, 0, 0.5,0},
        {"Half turn 4",  0, 1, 0,-1, 0.5,0},
        {"Half turn 5",  1, 1,-1,-1, 0.5,0},
        {"Half turn 6",  1,-1,-1, 1, 0.5,0},
        {"Half turn 7", -1,-1, 1, 1, 0.5,0},
        {"Half turn 8", -1, 1, 1,-1, 0.5,0},
        {"Half turn 9", 7.5, 7.5, -7.5,-7.5, 0.5,0},
    }
    for _, test in pairs(tests) do
        local name = test[1]
        local startPosX = test[2]
        local startPosY = test[3]
        local destPosX = test[4]
        local destPosY = test[5]
        local expectedTurns = test[6]
        local expectedExtension = test[7]
        local turns, extension = calcVectorMinTurnsAndExtension(startPosX, startPosY, destPosX, destPosY, granularity)
        if expectedTurns ~= turns or expectedExtension ~= extension then
            logger("calcVectorMinTurnsAndExtension test \"" .. name .. "\" failed:", {
                startPosX = startPosX, startPosY = startPosY, destPosX = destPosX, destPosY = destPosY,
                turns = turns, extension = extension,
                expectedTurns = expectedTurns, expectedExtension = expectedExtension,
            })
            _ = calcVectorMinTurnsAndExtension(startPosX, startPosY, destPosX, destPosY, granularity, logger)
        end
    end
end
