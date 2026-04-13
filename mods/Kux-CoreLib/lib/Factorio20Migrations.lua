--[[---------------------------------------------------------------------------
	 ensures that old 1.1 code also works in 2.0
--]]---------------------------------------------------------------------------

--- The global table => storage
--- @deprecated Use `storage` instead
_G.global = _G.global ---@diagnostic disable-line: deprecated

-- Removed LuaPlayer::open_map, zoom_to_world, and close_map. LuaPlayer::set_controller with type 'remote' replaces these.

mig = {}
mig.player = {}

---@param player LuaPlayer
mig.player.open_map = function(player, position, scale)
	if not player.controller_type == defines.controllers.character then return end
	player.set_controller{type=defines.controllers.remote, position=position}
end

---Zooms the player to the specified position and scale.
---@param player LuaPlayer
---@param position MapPosition?
---@param scale number [not implmented]
mig.player.zoom_to_world = function(player, position, scale)
	if not player.controller_type == defines.controllers.character then return end
	player.set_controller{type=defines.controllers.remote, position=position}
end

---Closes the map view for the player.
---@param player LuaPlayer
mig.player.close_map = function(player)
	if not player.controller_type == defines.controllers.remote then return end
	player.set_controller{type = defines.controllers.character, character = player.character}
end