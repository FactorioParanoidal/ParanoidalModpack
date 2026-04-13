-----------------------------------------------------------------------------------------------------------------------
--- Class Template
-----------------------------------------------------------------------------------------------------------------------

require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Template : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Template
-- replaces script (LuaBootstrap) for all event actions
local Template = {
	__class  = "Template",
	__guid   = "00000000-0000-0000-0000-000000000000",
	__origin = "Kux-CoreLib/lib/Template.lua",
	__writableMembers={"getDisplayName","registerName"}
}
if not KuxCoreLib.__classUtils.ctor(Template) then return self end
---------------------------------------------------------------------------------------------------

local EventDistributor = KuxCoreLib.require.EventDistributor

local function register_names()
	Events.getDisplayName = EventDistributor.getDisplayName or error("Invalid state.")
	Events.registerName   = EventDistributor.registerName or error("Invalid state.")
end
EventDistributor.__on_initialized(register_names)
---------------------------------------------------------------------------------------------------

--- define the class --

---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(Events)
return Events