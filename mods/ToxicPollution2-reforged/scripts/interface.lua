-- Command /toxic (answers only the caller) and remote interface "toxic_pollution".
local M = require("scripts.model")
local Player = require("scripts.player")

local I = {}

local function int(value)
	return tostring(math.floor(value + 0.5))
end

local function status(player)
	local character = player.character
	if not (character and character.valid) then
		player.print({ "tpr-command.no-character" })
		return
	end
	local data = Player.data(player.index)
	local state = Player.evaluate(player, data, false)
	local safe = M.safe_level(state.tolerance, state.filtration)
	player.print({ "tpr-command.status", int(data.x), int(state.pollution), int(state.inhaled), int(state.tolerance),
		int(state.filtration * 100), safe == math.huge and { "tpr-hud.infinite" } or int(safe) })
end

local function kills(player)
	local lines = {}
	for index, count in pairs(storage.kills) do
		local victim = game.get_player(index)
		lines[#lines + 1] = { name = victim and victim.name or ("#" .. index), count = count }
	end
	table.sort(lines, function(a, b) return a.count > b.count end)
	if #lines == 0 then
		player.print({ "tpr-command.no-kills" })
		return
	end
	player.print({ "tpr-command.kills-title" })
	for _, line in ipairs(lines) do
		player.print(line.name .. " — " .. line.count)
	end
end

function I.command(event)
	local player = event.player_index and game.get_player(event.player_index)
	if not player then return end
	if event.parameter == "kills" then
		kills(player)
	else
		status(player)
	end
end

function I.register()
	commands.add_command("toxic", { "tpr-command.help" }, I.command)
	remote.add_interface("toxic_pollution", {
		-- Intoxication of a player, 0..100 (%).
		get_intoxication = function(player_index)
			local data = storage.players[player_index]
			return data and data.x or 0
		end,
		set_intoxication = function(player_index, value)
			Player.data(player_index).x = M.clamp(tonumber(value) or 0, 0, 100)
		end,
		-- Read-only snapshot: pollution, tolerance, inhaled, filtration (0..1), rate (%/s), intoxication.
		get_state = function(player_index)
			local player = game.get_player(player_index)
			if not (player and player.character and player.character.valid) then return nil end
			local data = Player.data(player_index)
			local state = Player.evaluate(player, data, false)
			return { pollution = state.pollution, tolerance = state.tolerance, inhaled = state.inhaled,
				filtration = state.filtration, rate = state.rate, intoxication = data.x }
		end,
	})
end

return I
