require "modules/IonCannonStorage"

local function play_allowed(sound, player)
	if not settings.get_player_settings(player)["ion-cannon-play-voices"].value then return end
	local setting = settings.get_player_settings(player)["ion-cannon-play-voices-"..sound]
	if not setting then return true end
	return setting.value
	-- "ion-cannon-ready" "unable-to-comply" "ion-cannon-charging" "select-target"
end

---@param sound string
---@param player LuaPlayer
--TODO: add debounce to prevent overlapping sounds
function playSoundForPlayer(sound, player)
	if not play_allowed(sound, player) then return end
	local voice = settings.get_player_settings(player)["ion-cannon-voice-style"].value
	player.play_sound({path = sound .. "-" .. voice, volume_modifier = settings.get_player_settings(player)["ion-cannon-voice-volume"].value / 100})
end