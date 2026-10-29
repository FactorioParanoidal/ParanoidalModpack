-- One custom alert per player at a time: danger > filters > smog. Tracked in storage, so the old one
-- is removed when the kind changes; re-added if the game dropped it.
local C = require("shared.config")

local A = {}

local REFRESH = 600 -- ticks between presence checks of an unchanged alert
local SIGNALS = {}
for key, name in pairs(C.ALERT) do
	SIGNALS[key] = { type = "virtual", name = name }
end

local function present(player, character, key)
	local name = C.ALERT[key]
	for _, by_type in pairs(player.get_alerts({ entity = character, type = defines.alert_type.custom })) do
		for _, list in pairs(by_type) do
			for _, alert in pairs(list) do
				if alert.icon and alert.icon.name == name then
					return true
				end
			end
		end
	end
	return false
end

local function add(player, character, key)
	player.add_custom_alert(character, SIGNALS[key], { "tpr-alert." .. key }, false)
end

function A.clear(player, data)
	if data.alert then
		local character = player.character
		if character and character.valid then
			player.remove_alert({ entity = character, type = defines.alert_type.custom, icon = SIGNALS[data.alert] })
		end
		data.alert = nil
	end
end

function A.choose(state, intoxication)
	if state.damage > 0 then return "danger" end
	local armor = state.armor
	if armor and state.pollution * (1 - (state.vehicle and state.vehicle.share or 0)) > state.tolerance
		and (armor.exhausted or (armor.max > 0 and armor.resource / armor.max < 0.1)) then
		return "filters"
	end
	if state.rate > 0 or intoxication >= C.TIERS[1] then return "smog" end
	return nil
end

function A.update(player, character, data, state, intoxication)
	local want = A.choose(state, intoxication)
	if want ~= data.alert then
		A.clear(player, data)
		if want then
			add(player, character, want)
			data.alert_tick = game.tick
		end
		data.alert = want
	elseif want and game.tick - (data.alert_tick or 0) >= REFRESH then
		if not present(player, character, want) then
			add(player, character, want)
		end
		data.alert_tick = game.tick
	end
end

return A
