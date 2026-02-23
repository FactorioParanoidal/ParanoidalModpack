require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Math) then return KuxCoreLib.__modules.Math end

---@class KuxCoreLib.Math
local Math = {
	__class  = "Math",
	__guid   = "69c90373-797d-406a-8e75-1150f74d2792",
	__origin = "Kux-CoreLib/lib/ModInfo.lua"
}
KuxCoreLib.__modules.Math = Math
setmetatable(Math,{__this=math})

function Math.sgn(x)
    if x > 0 then return 1
    elseif x < 0 then return -1
	else return 0 end
end

do -- "derive" from math
--- @see math.abs
KuxCoreLib.Math.abs = math.abs

--- @see math.acos
KuxCoreLib.Math.acos = math.acos

--- @see math.asin
KuxCoreLib.Math.asin = math.asin

--- @see math.atan
KuxCoreLib.Math.atan = math.atan

--- @see math.atan2
KuxCoreLib.Math.atan2 = math.atan2

--- @see math.ceil
KuxCoreLib.Math.ceil = math.ceil

--- @see math.cos
KuxCoreLib.Math.cos = math.cos

--- @see math.exp
KuxCoreLib.Math.exp = math.exp

--- @see math.floor
KuxCoreLib.Math.floor = math.floor

--- @see math.log
KuxCoreLib.Math.log = math.log

--- @see math.max
KuxCoreLib.Math.max = math.max

--- @see math.min
KuxCoreLib.Math.min = math.min

--- @see math.pow
KuxCoreLib.Math.pow = math.pow

--- @see math.rad
KuxCoreLib.Math.rad = math.rad

--- @see math.random
KuxCoreLib.Math.random = math.random

--- @see math.sin
KuxCoreLib.Math.sin = math.sin

--- @see math.sqrt
KuxCoreLib.Math.sqrt = math.sqrt

--- @see math.tan
KuxCoreLib.Math.tan = math.tan
end

---------------------------------------------------------------------------------------------------

---Provides Math in the global namespace
---@return KuxCoreLib.Math
function Math.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Math) end

return Math