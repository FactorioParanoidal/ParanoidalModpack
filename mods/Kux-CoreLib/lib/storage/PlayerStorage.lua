require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Internal.PlayerData
---@field player_index integer
---@field player LuaPlayer
---@field timers KuxCoreLib.TimerData[]


---@class KuxCoreLib.PlayerData
---@field player_index uint                           The player_index of the player. will be filled automatically.
---@field player LuaPlayer                            The player object. will be filled automatically.
---@field __KuxCoreLib__ KuxCoreLib.Internal.PlayerData Data used internally by Kux-CoreLib. DON'T CHANGE


---@class KuxCoreLib.PlayerStorageBase : KuxCoreLib.Class
---@field getIds fun():string[]
---@field on_get fun(pdata:KuxCoreLib.PlayerData)
---@field on_new fun(pdata:KuxCoreLib.PlayerData):table?
---@field extend fun(self:KuxCoreLib.PlayerStorage, name:string, member:any)


--- Persistent store per player. <br>
--- The data will be stored in `storage.__KuxCoreLib__.players[player_index]`
---@class KuxCoreLib.PlayerStorage : KuxCoreLib.PlayerStorageBase, {[uint]: KuxCoreLib.PlayerData}, KuxCoreLib.Class
---@field raw KuxCoreLib.PlayerData[] direct access to the `storage.__KuxCoreLib__.players`

--[[ USAGE in calling mod
---@class PlayerStorage : {[uint]: PlayerData}, KuxCoreLib.PlayerStorageBase
---@field raw KuxCoreLib.PlayerData[] direct access to the `storage.__KuxCoreLib__.players`
]]
---------------------------------------------------------------------------------------------------

if _G["---ANNONTATION---"] then
	storage.__KuxCoreLib__.players = nil							---@see KuxCoreLib.PlayerStorage
	storage.__KuxCoreLib__.players[0] = nil							---@see KuxCoreLib.PlayerData
	storage.__KuxCoreLib__.players[0].__KuxCoreLib__.timers = nil	---@see KuxCoreLib.TimerData
end

---@type KuxCoreLib.PlayerStorage
local PlayerStorage = {
	__class  = "PlayerStorage",
	__guid   = "cb7e6ed5-e48c-4ef8-841c-b3782ab36b72",
	__origin = "Kux-CoreLib/lib/storage/PlayerStorage.lua"
}
if not KuxCoreLib.__classUtils.ctor(PlayerStorage) then return self end

---------------------------------------------------------------------------------------------------
if(not script) then
	KuxCoreLib.__classUtils.finalize(PlayerStorage)
	return PlayerStorage
end -- only initialized if in control stage]]

local Events = KuxCoreLib.Events
local Flags = KuxCoreLib.Flags
local Storage = KuxCoreLib.Storage

Storage.register("storage.__KuxCoreLib__.players", "KuxCoreLib.PlayerStorage")

local mt_PlayerData = {
	__index = function(self, key)
        if key == "player" and self.player_index then
            return game.get_player(self.player_index)
        end
        return nil
    end
}
script.register_metatable("02c290f1-6b6d-4d29-8e79-42f7ec31c909", mt_PlayerData)

local attributes = Flags.toDictionary{"on_new", "on_get", "raw", "__setGlobals"}

function PlayerStorage.getIds()
	local ids = {}
	for player_id, _ in pairs(storage.__KuxCoreLib__.players or {}) do table.insert(ids, player_id) end
	return ids
end

function PlayerStorage:extend(name, value) rawset(self, name, value) end

local mt_PlayerStorage = {
	__index = function(self, key)
		if attributes[key] then return nil end
		if type(key) == "string" then error("Member not exists. '"..key.."'") end

		local player_index = key
		if not storage.__KuxCoreLib__.players then storage.__KuxCoreLib__.players = {} end
		if not storage.__KuxCoreLib__.players[player_index] then
			local new_data = setmetatable({
				--player = game.get_player(player_index),
				player_index = player_index,
			}, mt_PlayerData)
			local on_new = rawget(self, "on_new"); if on_new then
				local d = on_new(new_data)
				if d then new_data = setmetatable(d,mt_PlayerData) end
			end
			--new_data.player = new_data.player or game.get_player(player_index)
			new_data.player_index = player_index
			new_data.__KuxCoreLib__ = new_data.__KuxCoreLib__ or {}
			new_data.__KuxCoreLib__.timers = new_data.__KuxCoreLib__.timers or {}

			storage.__KuxCoreLib__.players[player_index] = new_data
		end
		local pdata = storage.__KuxCoreLib__.players[player_index]
		--pdata.player = game.get_player(player_index)
		local f = rawget(self, "on_get"); if f then f(pdata) end
		return pdata
	end,
	__newindex = function(self, key, value)
		if attributes[key] then rawset(self, key, value) return end
		if type(key) == "string" then error("PlayerStorage is protected. '"..key.."' not exists") end
		if type(key) ~= "number" then error("Type not valid. 'number' expected. but got '"..type(key).."'") end
		local player_index = key
		local pdata = value or {}
		--[[migration!]] if not storage.__KuxCoreLib__.players then	storage.__KuxCoreLib__.players = {} end
		--pdata.player = game.get_player(player_index)
		pdata.player_index = player_index
		pdata.__KuxCoreLib__ = {}
		pdata.__KuxCoreLib__.timers =  {}
		setmetatable(pdata, mt_PlayerData)

		storage.__KuxCoreLib__.players[player_index] = pdata
	end,
	__pairs = function()
		-- Gibt einen Iterator für `storage.player_data` zurück. return raw data without metatables!
		if not storage.__KuxCoreLib__.players then	storage.__KuxCoreLib__.players = {} end
		--return next, storage.__KuxCoreLib__.players, nil
		local key, value
		return function()
			key, value = next(storage.__KuxCoreLib__.players, key)
			if key then
				return key, setmetatable(value, mt_PlayerData)
			end
		end
	end,
	__ipairs = function()
		error("ipairs is not supported on PlayerStorage. Use pairs instead.")
	end,
	__metatable = "protected"
}

local function register_events()
	Events.on_load(function()
		if storage.__KuxCoreLib__ then
			if storage.__KuxCoreLib__.players then
				PlayerStorage.raw = storage.__KuxCoreLib__.players
			end
		end
	end)

	local function init_storage(e)
		if not storage.__KuxCoreLib__ then storage.__KuxCoreLib__ = {} end
		if not storage.__KuxCoreLib__.players then storage.__KuxCoreLib__.players = {} end

		PlayerStorage.raw = storage.__KuxCoreLib__.players
	end

	Events.on_init(init_storage)
	Events.on_configuration_changed(init_storage)
	Events.on_loaded(init_storage)-- only for development
end

if KuxCoreLib.Events.__isInitialized then register_events()
else KuxCoreLib.Events.__on_initialized(register_events) end

---------------------------------------------------------------------------------------------------
setmetatable(PlayerStorage, mt_PlayerStorage)
KuxCoreLib.__classUtils.finalize(PlayerStorage)
return PlayerStorage