-- One custom alert per player, shown only when the course of events changes sharply:
-- entering harmful air, the smog getting at least twice as harmful, the protection resource falling
-- below 25 % / 10 %, the protection worn out / exhausted / replaced, health damage starting.
-- The alert message carries the whole status (former panel): intoxication bar, air, layers, resource
-- bar, spare filters and forecast. It stays SHOW ticks (refreshed every update meanwhile); the damage
-- alert stays while the damage lasts. No alert on leaving the smog.
local C = require("shared.config")
local M = require("scripts.model")

local A = {}

A.SHOW = 600 -- ticks an alert stays after its event
local SMOG_COOLDOWN = 1800 -- ticks between two smog alerts (walking along a cloud edge)
local WORSE_FACTOR = 2 -- harmful excess this many times the last alerted one = sharp change
local WORSE_MIN = 50 -- ... and at least this much higher
local RESEND = 300 -- ticks: re-add an unchanged alert in case the game dropped it
local BAR_CELLS = 20
local PRIORITY = { smog = 1, filters = 2, danger = 3 }
local SOUNDS = { smog = "utility/console_message", danger = "utility/alert_destroyed" } -- filters: protection plays it

local SIGNALS = {}
for key, name in pairs(C.ALERT) do
	SIGNALS[key] = { type = "virtual", name = name }
end

local TIER_COLORS = { [0] = "140,230,140", [1] = "255,210,80", [2] = "255,150,50", [3] = "255,80,80" }

local function int(value)
	return tostring(math.floor(value + 0.5))
end

local function one(value)
	return string.format("%.1f", value)
end

-- Text bar of `share` (0..1) out of "|" cells: the glyph exists in every game font.
function A.bar(share, color)
	local filled = math.floor(M.clamp(share, 0, 1) * BAR_CELLS + 0.5)
	return "[color=" .. color .. "]" .. string.rep("|", filled) .. "[/color][color=90,90,90]"
		.. string.rep("|", BAR_CELLS - filled) .. "[/color]"
end

function A.duration(seconds)
	if seconds < 120 then return { "tpr-time.s", int(seconds) } end
	local minutes = math.floor(seconds / 60 + 0.5)
	if minutes < 120 then return { "tpr-time.min", tostring(minutes) } end
	return { "tpr-time.h", tostring(math.floor(minutes / 60)), tostring(minutes % 60) }
end

local function resource_share(armor)
	return armor.max > 0 and armor.resource / armor.max or 1
end

local function resource_color(share)
	if share < 0.1 then return TIER_COLORS[3] end
	if share < 0.25 then return TIER_COLORS[2] end
	return TIER_COLORS[0]
end

-- Status lines (also printed by /toxic).
function A.describe(state, intoxication)
	local tier = M.tier(intoxication)
	local lines = { "" }
	lines[#lines + 1] = { "tpr-status.intoxication", A.bar(intoxication / 100, TIER_COLORS[tier]), int(intoxication),
		{ "tpr-tier.t" .. tier } }

	if state.reaching < state.pollution - 0.5 then
		lines[#lines + 1] = { "", "\n", { "tpr-status.air-filtered", int(state.pollution), int(state.tolerance),
			int(state.reaching) } }
	else
		lines[#lines + 1] = { "", "\n", { "tpr-status.air", int(state.pollution), int(state.tolerance) } }
	end

	local layers = { "" }
	if state.vehicle then
		layers[#layers + 1] = { "tpr-status.part-vehicle", state.vehicle.name, int(state.vehicle.share * 100) }
	end
	if state.module then
		local status = state.module.status
		layers[#layers + 1] = { "tpr-status.part-module", state.module.name, int(state.module.share * 100),
			(status == "low" or status == "empty") and { "tpr-status.module-" .. status } or "" }
	end
	if #layers > 1 then
		lines[#lines + 1] = { "", "\n", { "tpr-status.layers", layers } }
	end

	local armor = state.armor
	if armor and state.protected then
		local share = resource_share(armor)
		if armor.infinite then
			lines[#lines + 1] = { "", "\n", { "tpr-status.armor-infinite", armor.name } }
		else
			lines[#lines + 1] = { "", "\n", { "tpr-status.armor", armor.name, A.bar(share, resource_color(share)),
				int(share * 100), int(armor.resource), int(armor.max) } }
		end
		local lasts = M.lasts(armor.resource, armor.wear or 0)
		if lasts and not armor.infinite then
			lines[#lines + 1] = { "", "\n", { "tpr-status.lasts", A.duration(lasts) } }
		end
	elseif armor and armor.exhausted then
		lines[#lines + 1] = { "", "\n", { "tpr-status.armor-exhausted", armor.name } }
	else
		lines[#lines + 1] = { "", "\n", { "tpr-status.no-armor" } }
	end
	if state.filters then
		lines[#lines + 1] = { "", "\n", { "tpr-status.filters", C.REFILL_ITEM, tostring(state.filters) } }
	end

	if state.damage > 0 then
		lines[#lines + 1] = { "", "\n", { "tpr-status.damage", one(state.damage) } }
	elseif state.rate > 0 then
		local eta = M.eta(intoxication, state.rate)
		lines[#lines + 1] = { "", "\n", eta and { "tpr-status.rising", one(state.rate), A.duration(eta) }
			or { "tpr-status.rising-full", one(state.rate) } }
	elseif intoxication > 0 then
		lines[#lines + 1] = { "", "\n", { "tpr-status.falling", A.duration(M.eta(intoxication, state.rate) or 0),
			state.zone and { "tpr-status.zone" } or "" } }
	end
	return lines
end

-- Event of this update, or nil. Updates the memo in `data`.
function A.detect(state, data, tick)
	local harmful = state.reaching - state.tolerance
	local armor = state.armor
	local event

	if state.damage > 0 then
		event = { kind = "danger", title = { "tpr-alert.danger", one(state.damage) } }
	end

	if armor and armor.replaced then
		event = event or { kind = "filters", title = { "tpr-alert.replaced", data.armor_name or armor.name, armor.name } }
	elseif armor and armor.lost then
		event = event or { kind = "filters", title = { "tpr-alert.lost", data.armor_name or armor.name } }
	elseif armor and armor.exhausted and data.was_protected then
		event = event or { kind = "filters", title = { "tpr-alert.exhausted", armor.name } }
	end

	-- Resource marks: 1 below 25 %, 2 below 10 % (per item; reset by a refill or another item).
	if armor and state.protected and not armor.infinite then
		local share = resource_share(armor)
		local mark = share < 0.1 and 2 or (share < 0.25 and 1 or 0)
		if armor.name ~= data.armor_name then
			data.mark = mark
		elseif mark > (data.mark or 0) then
			data.mark = mark
			event = event or { kind = "filters", title = { "tpr-alert.low", armor.name, int(share * 100) } }
		else
			data.mark = mark
		end
	end

	if harmful > 0 then
		local ref = data.harm_ref
		local sharp = not ref or (harmful >= ref * WORSE_FACTOR and harmful - ref >= WORSE_MIN)
		if sharp and tick >= (data.smog_ready or 0) then
			local title
			if not ref then
				title = state.protected and { "tpr-alert.smog-protected", int(state.pollution), armor.name }
					or { "tpr-alert.smog", int(state.pollution) }
			else
				title = { "tpr-alert.smog-worse", int(state.pollution) }
			end
			event = event or { kind = "smog", title = title }
			data.smog_ready = tick + SMOG_COOLDOWN
			data.harm_ref = harmful
		elseif ref and harmful < ref then
			data.harm_ref = harmful -- the reference follows the air down, so a new rise is noticed
		end
	else
		data.harm_ref = nil
	end

	data.armor_name = armor and armor.name or nil
	data.was_protected = state.protected
	return event
end

local function play(player, kind)
	local path = SOUNDS[kind]
	if path and player.mod_settings["tpr-sounds"].value then
		player.play_sound({ path = path })
	end
end

local function remove(player, character, kind)
	if character and character.valid then
		player.remove_alert({ entity = character, type = defines.alert_type.custom, icon = SIGNALS[kind] })
	end
end

function A.clear(player, data)
	if data.alert then
		remove(player, player.character, data.alert)
	end
	data.alert, data.alert_until, data.alert_title, data.alert_key, data.alert_sent = nil, nil, nil, nil, nil
end

-- Forget the trend memo (death, surface change): the next harmful air is a new event.
function A.reset(player, data)
	A.clear(player, data)
	data.harm_ref, data.smog_ready, data.mark, data.armor_name, data.was_protected = nil, nil, nil, nil, nil
end

function A.update(player, character, data, state, intoxication)
	local tick = game.tick
	local event = A.detect(state, data, tick)
	local kind = data.alert
	if kind and data.alert_until and tick >= data.alert_until and not (kind == "danger" and state.damage > 0) then
		A.clear(player, data)
		kind = nil
	end
	if event and (not kind or PRIORITY[event.kind] >= PRIORITY[kind]) then
		if kind ~= event.kind or event.kind ~= "danger" then
			play(player, event.kind)
		end
		if kind and kind ~= event.kind then
			remove(player, character, kind)
		end
		kind = event.kind
		data.alert, data.alert_title, data.alert_until = kind, event.title, tick + A.SHOW
	elseif kind == "danger" and state.damage > 0 then
		data.alert_title = { "tpr-alert.danger", one(state.damage) }
		data.alert_until = tick + A.SHOW
	end
	if not kind then return end

	local message = { "", "[font=default-bold]", data.alert_title, "[/font]\n", A.describe(state, intoxication) }
	local key = serpent.line(message)
	if key ~= data.alert_key or tick - (data.alert_sent or 0) >= RESEND then
		remove(player, character, kind)
		player.add_custom_alert(character, SIGNALS[kind], message, false)
		data.alert_key, data.alert_sent = key, tick
	end
end

return A
