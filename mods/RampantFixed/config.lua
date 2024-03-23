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

function config.getAttackWaveSize(universe)
	if universe.allowExternalControl and universe.externalControlValues.attackWaveSize then
		return universe.externalControlValues.attackWaveSize
	else
		return universe.attackWaveSize
	end
end

--[[
    attackWaveScaling is used to calculate the attack wave size from the evolutionFactor
    default is universe.attackWaveMaxSize * (evolutionFactor ^ 1.666667)
    DOES NOT affect vanilla biters waves
--]]
config.attackWaveScaling = function (universe)
    return mCeil(gaussianRandomRange(config.getAttackWaveSize(universe),
                                     universe.attackWaveDeviation,
                                     1,
                                     universe.attackWaveUpperBound))
end

config.settlerWaveScaling = function (universe)
    return mCeil(gaussianRandomRange(universe.settlerWaveSize,
                                     universe.settlerWaveDeviation,
                                     universe.expansionMinSize,
                                     universe.expansionMaxSize))
end

return config


