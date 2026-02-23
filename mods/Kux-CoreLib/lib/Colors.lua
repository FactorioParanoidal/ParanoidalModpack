require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")
if(KuxCoreLib.__modules.Colors) then return KuxCoreLib.__modules.Colors end

---Color constants
---@class KuxCoreLib.Colors Provides color constants
local Colors = {
	__class  = "Colors",
	__guid   = "{E6240471-4450-4C9C-A3D8-43E4284D95E8}",
	__origin = "Kux-CoreLib/lib/Colors.lua",

	white = {r = 1, g = 1, b = 1},
	lightgrey = {r = 0.75, g = 0.75, b = 0.75},
	grey = {r = 0.5, g = 0.5, b = 0.5},
	darkgrey = {r = 0.25, g = 0.25, b = 0.25},
	lightgray = {r = 0.75, g = 0.75, b = 0.75},
	gray = {r = 0.5, g = 0.5, b = 0.5},
	darkgray = {r = 0.25, g = 0.25, b = 0.25},
	black = {r = 0, g = 0, b = 0},
	red = {r = 1, g = 0, b = 0},
	green = {r = 0, g = 1, b = 0},
	blue = {r = 0, g = 0, b = 1},
	yellow = {r = 1, g = 1, b = 0},
	lightyellow = {r = 1, g = 1, b = 0.5},
	orange = {r = 1, g = 0.55, b = 0.1},
	lightorange = {r = 1, g = 0.75, b = 0.4},
	pink = {r = 1, g = 0, b = 1},
	lightpink = {r = 1, g = 0.5, b = 1},
	lightred = {r = 1, g = 0.5, b = 0.5},
	lightgreen = {r = 0.5, g = 1, b = 0.5},
	lightblue = {r = 0.5, g = 0.5, b = 1},
	darkred = {r = 0.5, g = 0, b = 0},
	darkgreen = {r = 0, g = 0.5, b = 0},
	darkblue = {r = 0, g = 0, b = 0.5},
	brown = {r = 0.6, g = 0.4, b = 0.1},
	purple = {r = 0.6, g = 0.1, b = 0.6},
	cyan = {r = 0, g = 1, b = 1},
	lightcyan= {r = 0.5, g = 1, b = 1},
}

KuxCoreLib.__modules.Colors = Colors

---------------------------------------------------------------------------------------------------

---Provides Colors in the global namespace
---@return KuxCoreLib.Colors
function Colors.asGlobal() return KuxCoreLib.__classUtils.asGlobal(Colors) end

return Colors