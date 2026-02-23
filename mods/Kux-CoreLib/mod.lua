--[[
	Use this only as local mod = require("mod")
--]]

require("init")

KuxCoreLibPath = KuxCoreLibPath or "__Kux-CoreLib__/"
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/InitGlobals")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio20Migrations")
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/Factorio11BackwardCompatibility")

--- mod-base class
---@class KuxCoreLib.Mod
---@field name string The name of the mod
---@field path string The file path of the mod
---@field prefix string The prefix used by the mod
local mod = {}

mod.name = "Kux-CoreLib"
mod.path = "__"..mod.name.."__/"
mod.prefix = mod.name.."-"


return mod