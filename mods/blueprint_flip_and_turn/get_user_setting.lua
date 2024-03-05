local safecall = require "safecall"

-- global settings, global game
local function get_user_setting(event_player_index, settingname)
	-- 0.16 game.player[N]
	-- 0.17 game.get_player(N)

	local get_player = safecall(function() return game.get_player end) -- 0.17, but catch to avoid 0.16 error
	if not ok then -- 0.16
		get_player = function(n) return game.players[n] end
	end

	-- protect against error, deleted user ? (see https://mods.factorio.com/mod/blueprint_flip_and_turn/discussion/5e5d2b6d8c94fb000b3bd978)
	return safecall(function()
			return (settings.get_player_settings(get_player(event_player_index))[settingname] or {}).value
		end)
end
return get_user_setting
