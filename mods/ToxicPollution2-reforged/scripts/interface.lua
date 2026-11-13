-- Command /toxic (answers only the caller) and remote interface "toxic_pollution".
local M = require("scripts.model")
local Player = require("scripts.player")
local Alerts = require("scripts.alerts")

local I = {}

local function status(player)
	local character = player.character
	if not (character and character.valid) then
		player.print({ "tpr-command.no-character" })
		return
	end
	local data = storage.players[player.index] or { x = 0 }
	local state = Player.evaluate(player, data, false)
	state.damage = M.damage(data.x, character.max_health, state.inhaled, state.tolerance)
	player.print({ "", { "tpr-command.status" }, "\n", Alerts.describe(state, data.x) })
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

local function read_remote(name, method, id)
	local api = remote.interfaces[name]
	if not (api and api[method]) then return nil end
	local ok, result = pcall(remote.call, name, method, id)
	local valid = ok and type(result) == "table" and result.schema_version == 1
		and type(result.availability) == "string"
	if valid and result.availability == "ok" then
		if method == "get_surface_status" then
			valid = type(result.pollution_component) == "number" and type(result.curve) == "table"
				and type(result.curve.min) == "number" and type(result.curve.max) == "number"
				and type(result.curve.exponent) == "number" and type(result.reduction) == "number"
				and type(result.occlusion_enabled) == "boolean"
		else
			valid = type(result.pollution) == "number" and type(result.start_above) == "number"
				and type(result.stop_at_or_below) == "number" and type(result.script_gate_enabled) == "boolean"
		end
	end
	if valid then return result end
	log("ToxicPollution2-reforged: unavailable status from " .. name .. "." .. method)
end

local function age(tick)
	return tick and { "tpr-air.age", tostring(math.max(0, math.floor((game.tick - tick) / 60))) }
		or { "tpr-air.unknown" }
end

local function air(player)
	-- Environmental context is the viewing position, not necessarily the character's body.
	local surface = player.surface
	local pollutant = surface.pollutant_type
	player.print({ "tpr-air.environment", surface.name, pollutant and pollutant.name or { "tpr-air.none" },
		tostring(math.floor(surface.get_pollution(player.position))) })
	local solar = read_remote("visible-pollutants", "get_surface_status", surface.index)
	if solar and solar.availability == "ok" then
		player.print({ "tpr-air.solar", tostring(math.floor(solar.pollution_component * 100 + 0.5)),
			age(solar.applied_tick), age(solar.last_complete_cycle_tick),
			solar.occlusion_enabled and { "tpr-air.enabled" } or { "tpr-air.disabled" } })
		player.print({ "tpr-air.curve", tostring(solar.curve.min), tostring(solar.curve.max),
			tostring(solar.curve.exponent), tostring(solar.reduction) })
	else
		player.print({ "tpr-air.solar-unavailable" })
	end
	local selected = player.selected
	if selected and selected.valid and selected.name:match("^CW%-air%-filter%-machine%-[1-6]$") then
		local machine = read_remote("carbon-capture2", "get_machine_status", selected.unit_number)
		if machine and machine.availability == "ok" then
			local native = { "tpr-air.unknown" }
			for name, id in pairs(defines.entity_status) do
				if id == machine.entity_status then
					native = { "?", { "entity-status." .. name:gsub("_", "-") }, { "tpr-air.unknown" } }
					break
				end
			end
			player.print({ "tpr-air.machine", selected.localised_name,
				machine.script_gate_enabled and { "tpr-air.gate-on" } or { "tpr-air.gate-off" },
				tostring(machine.pollution), age(machine.sample_tick), native })
			player.print({ "tpr-air.thresholds", tostring(machine.start_above), tostring(machine.stop_at_or_below) })
		else
			player.print({ "tpr-air.machine-unavailable" })
		end
	end
end

function I.command(event)
	local player = event.player_index and game.get_player(event.player_index)
	if not player then return end
	if event.parameter == "kills" then
		kills(player)
	elseif event.parameter == "air" then
		air(player)
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
		get_player_status = Player.get_status,
		-- Read-only snapshot: pollution, tolerance, inhaled (0 while the worn item protects), protected,
		-- filtration of cabin and module (0..1), rate (%/s), intoxication.
		get_state = function(player_index)
			local player = game.get_player(player_index)
			if not (player and player.character and player.character.valid) then return nil end
			local data = storage.players[player_index] or { x = 0 }
			local state = Player.evaluate(player, data, false)
			return { pollution = state.pollution, tolerance = state.tolerance, inhaled = state.inhaled,
				protected = state.protected, filtration = state.filtration, rate = state.rate, intoxication = data.x }
		end,
	})
end

return I
