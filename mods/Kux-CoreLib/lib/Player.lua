require((KuxCoreLibPath or "__Kux-CoreLib__/").."lib/init")

---@class KuxCoreLib.Player : KuxCoreLib.Class
---@---@field asGlobal fun(): KuxCoreLib.PlayerClass
---@overload fun(player: LuaPlayer): KuxCoreLib.Player
local Player = {
	__class  = "KuxCoreLib.Player",
	__guid   = "b241c272-0cfd-44c2-82a9-83d6918b8ccb",
	__origin = "Kux-CoreLib/lib/Player.lua",
}
if not KuxCoreLib.__classUtils.ctor(Player) then return self end
---------------------------------------------------------------------------------------------------
---@alias KuxCoreLib.LuaPlayerIdentifier  uint|string|LuaPlayer|KuxCoreLib.Player

---
---@param value KuxCoreLib.LuaPlayerIdentifier
---@return LuaPlayer?
local function toLuaPlayer(value)
	local t = type(value)
	if t == "userdata" and value.object_name =="LuaPlayer" then return value end
	if t == "table" and value.__class == "KuxCoreLib.Player" then return value["luaObject"] end
	if t == "table" and value["player_index"] then return game.get_player(value["player_index"]) end
	if t == "number" then return game.get_player(value) end
	if t == "string" then return game.get_player(value) end
	error("Invalid argument. "..tostring(arg))
end

Player.toLuaPlayer = toLuaPlayer

--- @see Player.toLuaPlayer
Player.getPlayer = Player.toLuaPlayer

function Player.character_personal_logistic_requests_enabled(player)
	player = toLuaPlayer(player); if not player then return false end
	---@diagnostic disable-next-line: undefined-field
	if isV1 then return player.character_personal_logistic_requests_enabled end

	local c = player.character; if not c then return false end
	local rp = player.character.get_requester_point(); if not rp then return false end
	return rp.enabled
end

function Player.isZoomReadable(player)
	return remote.interfaces["Kux-Zooming"] ~= nil
end

---@param player KuxCoreLib.LuaPlayerIdentifier
---@return double
function Player.getZoomFactor(player)
	local player = toLuaPlayer(player) or error("Invalid player.")
	if remote.interfaces["Kux-Zooming"] then
		return remote.call("Kux-Zooming", "getZoomFactor", player.index)
	else
		--return player.zoom ---crash
		return 1 -- workarround to avoid crash
	end
end

---@paam player LuaPlayer
---@param zoomFactor double
function Player.setZoomFactor(player, zoomFactor)
	local player = toLuaPlayer(player) or error("Invalid player.")
	if remote.interfaces["Kux-Zooming"] then
		remote.call("Kux-Zooming", "setZoomFactor", player.index, zoomFactor, player.controller_type, player.position)
	else
		player.zoom = zoomFactor
	end
end

---@class KuxCoreLib.LuaPlayer.set_controller_param : LuaPlayer.set_controller_param
---@field zoom double?

---@param player LuaPlayer
---@param parameter KuxCoreLib.LuaPlayer.set_controller_param
function Player.set_controller(player, parameter)
	local player = toLuaPlayer(player) or error("Invalid player.")
	player.set_controller(parameter)
	if parameter.zoom then
		Player.setZoomFactor(player, parameter.zoom)
	end
end

function Player.isCursorGhost(player)
	return player.cursor_ghost ~= nil
end

--- TODO move to Kux-CoreLib
---@param player LuaPlayer
---@return string?
function Player.getCursorItemName(player)
	local trace = _G.print; --trace = function() end
	if player.is_cursor_empty() then
		trace("Cursor is empty.")
		return nil
	end
	if player.is_cursor_blueprint() then
		trace("Cursor is blueprint.")
	end
	if player.cursor_ghost then --ItemIDAndQualityIDPair
		--print("New ghost in the cursor: " .. serpent.line(player.cursor_ghost))
		local nameOrId = player.cursor_ghost.name
		-- string		        The prototype name.
		-- LuaItemPrototype		Item prototype.			name, object_name
		-- LuaItemStack		    Non empty item stack.   name, object_name
		-- LuaItem		        The item.				name, object_name
		if(type(nameOrId) == "string") then
			trace("New ghost in the cursor: " .. nameOrId)
			return nameOrId
		else
			trace("New ghost in the cursor: " .. nameOrId.name.." ("..nameOrId.object_name..")" )
			return nameOrId.name
		end
	elseif player.cursor_stack then -- LuaItemStack
		if player.cursor_stack.valid_for_read then
			trace("New item in the cursor: " .. player.cursor_stack.name)
			return player.cursor_stack.name
		else
			trace("Unkown item in the cursor.")
			return nil
		end
	end
end

---@class KuxCoreLib.LuaPlayer : LuaPlayer
---@field __class string "KuxCoreLib.LuaPlayer"
---@field zoom double Gets or sets the zoom factor of the player. If the Kux-Zooming mod is installed, it will use that mod's zoom factor instead.

local mt_LuaPlayer = {
	__index = function (self,key)
		if key == "__class" then return "KuxCoreLib.Player" end
		if key == "zoom" then return Player.getZoomFactor(self.luaObject) end
		return self.luaObject[key]
	end,
	__newindex = function(self,key,value)
		if key == "__class" then error("__class is read-only.") end
		if key == "zoom" then return Player.setZoomFactor(self.luaObject,value) end
		self.luaObject[key]=value
	end,
}

local function __call(_, player)
	local obj = setmetatable({luaObject=toLuaPlayer(player)}, mt_LuaPlayer)
	return obj
end

local mt_Player = {
	__newindex = function(t,k,v) error("Attempt to write to undeclared field "..k) end,
	__call = __call
}
setmetatable(Player--[[@as table]], mt_Player)
---------------------------------------------------------------------------------------------------

return Player