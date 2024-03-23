if stringUtilsG then
    return stringUtilsG
end
local stringUtils = {}

local sSub = string.sub

function stringUtils.isRampantSetting(str)
    return sSub(str, 1, #"rampantFixed--") == "rampantFixed--"
end

stringUtilsG = stringUtils
return stringUtils
