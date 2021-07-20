-- wrapper for global.permissions
Permissions = {}

-- global.permissions[-2] : settings.global["ion-cannon-auto-targeting"].value
--                          checkbox.name == "ion-cannon-auto-target-enabled"
-- global.permissions[-1] : checkbox.name == "show"
-- global.permissions[0] : "toggle all"
-- global.permissions[>0] : player.index

Permissions.initialize = function()
	if global.permissions then return end

	--TODO revise initialization
	global.permissions = {}
	global.permissions[-2] = settings.global["ion-cannon-auto-targeting"].value
	global.permissions[-1] = false
	global.permissions[0] = false
end

Permissions.hasPermission = function(playerIndex)
	if not global.permissions then Permissions.initialize() end --TODO revise initialization
	local player = game.players[playerIndex]
	return global.permissions[playerIndex] or player.admin
end

Permissions.setAll = function(value)
	for i = 1, #game.players do
		global.permissions[i] = value -- global.permissions[0]
	end
end

Permissions.setPermission = function(playerIndex, value)
	global.permissions[playerIndex] = value
end
Permissions.getPermission = function(playerIndex)
	return global.permissions[playerIndex] or false
end
