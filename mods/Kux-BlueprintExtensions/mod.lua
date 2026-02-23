require("__Kux-CoreLib__/lib/init")

---@class mod : KuxCoreLib.ModInfo
local mod = KuxCoreLib.ModInfo.new()

log("Mod: " .. mod.name .. " v" .. mod.version)
log("Entry Mod: " .. mod.entryMod)
log("Calling Mod: " .. mod.callingMod)
log("Current Stage: " .. mod.current_stage)

if(mod.current_stage:match("^settings") or mod.current_stage:match("^data")) then
	--require("__Kux-CoreLib__/lib/data/@")
end

if(mod.current_stage=="control") then
	if script.active_mods["gvv"] then require("__gvv__.gvv")() end
	require("__Kux-CoreLib__/lib/@")
end

_G.mod = mod
return mod