require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides utils
---@class KuxCoreLib.Utils : KuxCoreLib.Class
---@field asGlobal fun():KuxCoreLib.Utils Provides Utils in the global namespace
local Utils = {
	__class  = "Utils",
	__guid   = "5c1d7b38-4452-4339-902e-b82d93286121",
	__origin = "Kux-CoreLib/lib/Utils.lua",
}
if not KuxCoreLib.__classUtils.ctor(Utils) then return self end
---------------------------------------------------------------------------------------------------

function Utils.skipIntro()
	if remote.interfaces["freeplay"] then -- In "sandbox" mode, freeplay is not available
		remote.call( "freeplay", "set_disable_crashsite", true ) -- removes crashsite and cutscene start
		remote.call( "freeplay", "set_skip_intro", true )        -- Skips popup message to press tab to start playing
	end
end
-- script.on_init( function()
-- 	Utils.skipIntro()
-- end )
---------------------------------------------------------------------------------------------------
KuxCoreLib.__classUtils.finalize(Version)
return Utils