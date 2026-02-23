require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Vector.static : KuxCoreLib.Class
---@field asGlobal KuxCoreLib.Vector.static Provides Vector in the global namespace
Vector = {
    __class  = "KuxCoreLib.Vector.static",
	__guid   = "c4d74ac2-ff84-4467-af6d-8ad8a0475d23",
	__origin = "Kux-CoreLib/lib/Vector.lua",
}
if not KuxCoreLib.__classUtils.ctor(Vector) then return self end
---------------------------------------------------------------------------------------------------

function Vector.setmetatable(t)
	setmetatable{t,{
		__mul=function(v, n) return Vector.setmetatable({x=v.x*n, y=v.y*n}) end,
		__add=function(v1, v2) return Vector.setmetatable({x=v1.x+v2.x, y=v1.y+v2.y}) end,
		__sub=function(v1, v2) return Vector.setmetatable({x=v1.x-v2.x, y=v1.y-v2.y}) end,
		__div=function(v, n) return Vector.setmetatable({x=v.x/n, y=v.y/n}) end,
		__tostring=function(v) return v.x.."x"..v.y end,
		__index=function(v, k) return k==1 and v.x or k==2 and v.y or rawget(v, k) end,
		__newindex=function(v, k, value) if k==1 then v.x=value elseif k==2 then v.y=value else rawset(v, k, value) end end
	}}
end

---------------------------------------------------------------------------------------------------
return Vector

---------------------------------------------------------------------------------------------------
---@class KuxCoreLib.Vector : Vector.0|{[1]:number, [2]:number}
--- -----------------------
---@field x number
---@field y number
---@field [1] number
---@field [2] number