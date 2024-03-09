-- Copyright (C) 2022  veden

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.


if buildRecordG then
    return buildRecordG
end

-- imports

local constants = require("Constants")

-- constants

local ENTITES_WITHOUT_DOWNTIME = constants.ENTITES_WITHOUT_DOWNTIME

-- imported fuctions

local mRandom = math.random
local roundToNearest = constants.roundToNearest

-- module codes

local buildRecord = {}

function buildRecord.generate(tick, entity, world)
    local entityType = entity.type
    local cooldowns = world.buildCooldown[entityType]
    local cooldown = (mRandom() * cooldowns.range) + cooldowns.low
    local failureCount = 0
    if not ENTITES_WITHOUT_DOWNTIME[entityType] and not entity.active then
        failureCount = 1
    end
    local tileModifier = 0
    local totalTileModifier = 0
    local tileCount = 0
    if world.useTileModifier then
        local surface = entity.surface
        local boundingBox = entity.bounding_box
        if boundingBox then
            local tiles = surface.find_tiles_filtered({
                    area = boundingBox
            })
            if #tiles > 0 then
                for i = 1,#tiles do
                    tileCount = tileCount + 1
                    totalTileModifier = totalTileModifier + (world.terrainModifierLookup[tiles[i].name] or 0)
                end
                tileModifier = totalTileModifier / tileCount
            end
        end
    end
    return {
        ["c"] = (entity.get_health_ratio() * cooldown) + tick, -- cooldown
        ["fC"] = failureCount, -- failed count
        ["u"] = 0, -- uptime
        ["lE"] = tick, -- last event
        ["d"] = 0, -- downtime
        ["e"] = entity, -- entity,
        ["a"] = true, -- active
        ["eU"] = entity.unit_number,
        ["t"] = tileModifier,
        ["tM"] = (world.buildTileModifier[entityType] or 0),
        ["tT"] = totalTileModifier,
        ["tC"] = tileCount,
        ["p"] = (world.buildPollutionModifier[entityType] or 0)
    }
end

buildRecordG = buildRecord
return buildRecord
