require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Technology : KuxCoreLib.Class
---@field asGlobal fun(): KuxCoreLib.Technology
Technology = {
	__class  = "Technology",
	__guid   = "eb2242d4-9547-45d1-b0a2-0e2528a43c70",
	__origin = "Kux-CoreLib/lib/Technology.lua",
}
if not KuxCoreLib.__classUtils.ctor(Technology) then return self end
---------------------------------------------------------------------------------------------------

---comment
---@param maybeForceOrPlayerOrPlayerIndex LuaForce|LuaPlayer|integer
---@return LuaForce
local function getForce(maybeForceOrPlayerOrPlayerIndex)
	local force
	if(type(maybeForceOrPlayerOrPlayerIndex)=="number") then
		force = game.players[maybeForceOrPlayerOrPlayerIndex].force
	elseif(type(maybeForceOrPlayerOrPlayerIndex)=="table" and not maybeForceOrPlayerOrPlayerIndex.set_cease_fire) then
		force = maybeForceOrPlayerOrPlayerIndex.force -- assume LuaPlayer
	else
		force = maybeForceOrPlayerOrPlayerIndex -- assume force
	end
	return force --[[@as LuaForce]]
end

---
---@param force LuaForce|LuaPlayer|integer
---@param technologyName string
---@return boolean
function Technology.isUnlocked(force, technologyName)
	force = getForce(force)

	local tech = force.technologies[technologyName]
	if(not tech) then return false end
	return tech.researched
end

---------------------------------------------------------------------------------------------------

---Provides Technology in the global namespace
---@return KuxCoreLib.Technology
function Technology.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Technology) end

return Technology