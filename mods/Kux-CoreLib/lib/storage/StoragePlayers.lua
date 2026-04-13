-- TODO revise usage of KuxCoreLib.StoragePlayers, Who uses this?
do return {} end
require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.StoragePlayers : KuxCoreLib.Class
---@deprecated use KuxCoreLib.PlayerStorage
---@see use KuxCoreLib.PlayerStorage
local StoragePlayers = {
	__class  = "StoragePlayers",
	__guid   = "eeb5d79b-3522-4296-919a-40d8c430eb5d",
	__origin = "Kux-CoreLib/lib/storage/StoragePlayers.lua",
}
if not KuxCoreLib.__classUtils.ctor(StoragePlayers) then return self end
---------------------------------------------------------------------------------------------------
local Storage = KuxCoreLib.Storage
local StoragePlayer = KuxCoreLib.StoragePlayer
local Player = KuxCoreLib.Player

local mt = {}

local globalPlayers

--- Funktion, um den Indexzugriff zu behandeln
---@param self KuxCoreLib.StoragePlayers
---@param key any
---@return KuxCoreLib.StoragePlayer?
local function indexHandler(self, key)
    globalPlayers = globalPlayers or Storage.players

	local player = Player.toLuaPlayer(key)
	if(not player) then return nil end

	-- local pi = storage.players[player.index]
	-- if(pi==nil) then
	-- 	pi = {}
	-- 	storage.players[player.index]=pi
	-- end
	-- return

	storage.players = storage.players or {}  -- Sicherstellen, dass players eine Tabelle ist
	storage.players[key] = data

	local gp = storage.players[player.index]
	if not gp then
		error("player not initialized") -- TODO revise
		gp = {}  -- Hier sollte die Initialisierung der Spieler-Daten erfolgen
		storage.players[player.index] = gp
	end

	rawset(self, player.index, gp)	--self[player.index] = gp
	return gp --[[@as KuxCoreLib.StoragePlayer]]
end

---@return KuxCoreLib.StoragePlayer
mt.__index = indexHandler

function mt.__newindex(self,key,value)
	-- storage.players = storage.players or {}
	-- local player = Player.toLuaPlayer(key)
	-- storage.players[player.index] = value
	--if(type(key)=="number") then self[key]=value; return end
	error("StoragePlayers is protected.")
end

function StoragePlayers.asGlobal() return KuxCoreLib.__classUtils.asGlobal(StoragePlayers) end

setmetatable(StoragePlayers,mt)
return StoragePlayers

