-- Once per second per connected player with a character: protection → intoxication → damage → alert.
-- Players are spread over 6 slots of 10 ticks.
local C = require("shared.config")
local M = require("scripts.model")
local Protection = require("scripts.protection")
local Zones = require("scripts.zones")
local Research = require("scripts.research")
local Alerts = require("scripts.alerts")

local U = {}

U.INTERVAL = 10
U.SLOTS = 6 -- INTERVAL × SLOTS = 60 ticks: every player once per second
local SECONDS = U.INTERVAL * U.SLOTS / 60

local base_tolerance = settings.startup["tpr-tolerance"].value

function U.inventory_changed(index)
	local data = storage.players[index]
	if data then data.refill_retry = nil end
end

-- Read current protection without advancing intoxication, wearing armor or spending module energy.
function U.get_status(index)
	local player = game.get_player(index)
	local character = player and player.character
	if not (character and character.valid) then
		return { schema_version = 1, availability = "no_character", player_index = index }
	end
	local data = storage.players[index] or { x = 0 }
	local state = U.evaluate(player, data, false)
	state.damage = M.damage(data.x, character.max_health, state.inhaled, state.tolerance)
	local pollutant = character.surface.pollutant_type
	state.schema_version, state.availability = 1, "ok"
	state.sample_tick, state.interval_ticks = game.tick, U.INTERVAL * U.SLOTS
	state.player_index, state.character_unit_number = index, character.unit_number
	state.surface_index, state.pollutant = character.surface.index, pollutant and pollutant.name
	state.chunk_x, state.chunk_y = math.floor(character.position.x / 32), math.floor(character.position.y / 32)
	state.force_index = player.force.index
	state.vehicle_unit_number = character.vehicle and character.vehicle.unit_number
	state.intoxication = data.x
	state.description = Alerts.describe(state, data.x)
	return state
end

function U.data(index)
	local data = storage.players[index]
	if not data then
		data = { x = 0 }
		storage.players[index] = data
	end
	return data
end

local function killed(player, data)
	storage.kills[player.index] = (storage.kills[player.index] or 0) + 1
	data.x = 0
	Alerts.reset(player, data)
	player.force.print({ "tpr-message.killed", player.name })
end

-- Full evaluation; `apply` = false only reads (status command, remote).
function U.evaluate(player, data, apply)
	local character = player.character
	local pollution = character.surface.get_pollution(character.position)
	local level = Research.level(player.force)
	local tolerance = M.tolerance(base_tolerance, level)
	local state = Protection.evaluate(player, character, data, pollution, tolerance, level, SECONDS, apply)
	state.zone = false
	if state.inhaled <= tolerance and data.x > 0 then
		state.zone = Zones.near_clean_air(character.surface, character.position)
	end
	state.rate = M.rate(state.inhaled, tolerance, state.zone)
	state.damage = 0
	return state, character
end

function U.update(player)
	local data = U.data(player.index)
	local character = player.character
	if not (character and character.valid) then return end
	local state
	state, character = U.evaluate(player, data, true)
	if not character.valid then return end
	data.x = M.step(data.x, state.rate, SECONDS)
	state.damage = M.damage(data.x, character.max_health, state.inhaled, state.tolerance)
	if state.damage > 0 then
		character.damage(state.damage * SECONDS, "neutral", C.DAMAGE_TYPE)
		if not character.valid then
			killed(player, data)
			return
		end
	end
	Alerts.update(player, character, data, state, data.x)
end

function U.tick(tick)
	local slot = math.floor(tick / U.INTERVAL) % U.SLOTS
	for _, player in pairs(game.connected_players) do
		if player.index % U.SLOTS == slot then
			U.update(player)
		end
	end
end

function U.on_died(player)
	local data = U.data(player.index)
	data.x = 0
	Alerts.reset(player, data)
end

function U.on_respawned(player)
	if not player.mod_settings["tpr-respawn-respirator"].value then return end
	local character = player.character
	if not (character and character.valid) then return end
	local stack, slot = Protection.armor_slot(character)
	if not stack and slot and slot.insert({ name = C.RESPIRATOR, count = 1 }) > 0 then return end
	local main = character.get_main_inventory()
	if main then main.insert({ name = C.RESPIRATOR, count = 1 }) end
end

-- Poison clouds: a mask resists 90 % and pays for it with its filter resource.
function U.on_poison(event)
	local character = event.entity
	if not (character and character.valid) then return end
	local player = character.player
	if not player then return end
	local stack, slot = Protection.armor_slot(character)
	if not (stack and C.POISON_FILTERS[stack.name]) then return end
	local absorbed = event.original_damage_amount * C.POISON_SHARE
	if absorbed > 0 then
		Protection.spend(player, character, stack, absorbed, U.data(player.index), slot)
	end
end

return U
