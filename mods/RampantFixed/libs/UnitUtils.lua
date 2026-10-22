if (unitUtilsG) then
    return unitUtilsG
end
local unitUtils = {}

-- imports

local constants = require("Constants")

-- constants

local ENERGY_THIEF_DRAIN_CRYSTALS = constants.ENERGY_THIEF_DRAIN_CRYSTALS

-- imported functions

-- module code

function unitUtils.convertTypeToDrainCrystal(evolutionFactor, entity)
    if (entity == "pole") then
        return "crystal-drain-pole-rampant"
    else
        if (entity == "smallUnit") then
            if (evolutionFactor < 0.25) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[1]
            elseif (evolutionFactor < 0.50) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[2]
            elseif (evolutionFactor < 0.75) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[3]
            else
                return ENERGY_THIEF_DRAIN_CRYSTALS[4]
            end
        elseif (entity == "unit") then
            if (evolutionFactor < 0.25) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[4]
            elseif (evolutionFactor < 0.50) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[5]
            elseif (evolutionFactor < 0.75) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[6]
            else
                return ENERGY_THIEF_DRAIN_CRYSTALS[7]
            end
        else
            if (evolutionFactor < 0.25) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[7]
            elseif (evolutionFactor < 0.50) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[8]
            elseif (evolutionFactor < 0.75) then
                return ENERGY_THIEF_DRAIN_CRYSTALS[9]
            else
                return ENERGY_THIEF_DRAIN_CRYSTALS[10]
            end
        end
    end
end

-- Paranoidal: units of the tracked champions and hour bosses (libs/Champions.lua) by unit number, nil when there are
-- none. Scripts that destroy, replace, pack, buff or regroup units skip these: a champion lost that way vanishes
-- without its loot. Callers look up entity.unit_number only when the table is not nil.
function unitUtils.championUnits(universe)
    local data = universe and universe.champions
    local units = data and data.units
    if units and (next(units) ~= nil) then
        return units
    end
    return nil
end

unitUtilsG = unitUtils
return unitUtils
