require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Radar: KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Radar
Radar = {
	__class  = "Radar",
	__guid   = "bdcf1cb7-8228-45ba-92d4-e5e3528a64a2",
	__origin = "Kux-CoreLib/lib/entities/Radar.lua",
}
if not KuxCoreLib.__classUtils.ctor(Radar) then return self end
---------------------------------------------------------------------------------------------------
local Math = KuxCoreLib.Math

local this = {}
setmetatable(this,{__index=Radar})

---------------------------------------------------------------------------------------------------
return Radar