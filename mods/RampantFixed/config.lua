local config = {}

-- imported

local mathUtils = require("libs/MathUtils")

-- imported functions

local gaussianRandomRange = mathUtils.gaussianRandomRange
local mCeil = math.ceil


-- configurations

function config.getAttackWaveMaxSize(universe)
	if universe.allowExternalControl and universe.externalControlValues.attackWaveMaxSize then
		return universe.externalControlValues.attackWaveMaxSize
	else
		return universe.attackWaveMaxSize
	end
end

function config.getAttackWaveSize(map)
	local universe = map.universe
	if universe.allowExternalControl and universe.externalControlValues.attackWaveSize then
		return universe.externalControlValues.attackWaveSize
	else
		return map.attackWaveSize
	end
end

--[[
    attackWaveScaling is used to calculate the attack wave size from the evolutionFactor
    default is universe.attackWaveMaxSize * (evolutionFactor ^ 1.666667)
    DOES NOT affect vanilla biters waves
--]]
config.attackWaveScaling = function (map)
	local universe = map.universe
    return mCeil(gaussianRandomRange(config.getAttackWaveSize(map),
                                     map.attackWaveDeviation,
                                     1,
                                     map.attackWaveUpperBound))
end

config.settlerWaveScaling = function (map)
	local universe = map.universe
    return mCeil(gaussianRandomRange(map.settlerWaveSize,
                                     map.settlerWaveDeviation,
                                     universe.expansionMinSize,
                                     universe.expansionMaxSize))
end

return config


