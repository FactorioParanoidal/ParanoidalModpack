do return {} end
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---Provides managed access to the Factorio `storage` table (formerly `global`).
---@class KuxCoreLib.StoragePlayer : KuxCoreLib.Class
---@field frames {string:LuaGuiElement}
---@deprecated use KuxCoreLib.PlayerStorage
local StoragePlayer = {
	__class  = "StoragePlayer",
	__guid   = "2eab6777-b887-4cf0-922c-41458b63dd2b",
	__origin = "Kux-CoreLib/lib/storage/StoragePlayer.lua",
}
if not KuxCoreLib.__classUtils.ctor(StoragePlayer) then return self end
---------------------------------------------------------------------------------------------------

--storage.players[].frames

local mt = {}

local getter = {
	frames = function (self,key) return safegetOrCreate(storage,"players["..self.index.."].frames") end,
}

local function defaultGetter(self, key) return storage.players[self.index][key]end

function mt.__index(self,key)
	return (getter[key] or defaultGetter)(self,key)
end

function mt.__newindex(self, key, value)
	if(getter[key]) then error("Property is write protected.") end
	storage.players[self.index][key]=value
end

---Creates a new StoragePlayer.
--Usually this function does not need to be called manually. The access is made via Storage.Players[index]
---@param player LuaPlayer|integer
---@param defaultData? table
---@return KuxCoreLib.StoragePlayer
function StoragePlayer:new(player, defaultData)
	if(type(player)=="number") then player=game.players[player] end
	if(not player) then error("Player does not exist.") end --TODO: return nil??
	data = safeget("storage.players["..player.index.."]")
	if(not data) then data = defaultData or {}; safeset("storage.players["..player.index.."]", defaultData) end
	local globalPlayer={index=player.index,_data=data}
	setmetatable(globalPlayer,mt)
	return globalPlayer
end

---------------------------------------------------------------------------------------------------

function StoragePlayer.asGlobal() return KuxCoreLib.__classUtils.asGlobal(StoragePlayer) end

return StoragePlayer