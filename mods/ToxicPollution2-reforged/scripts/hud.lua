-- Intoxication panel (player.gui.left). Built once, then only changed texts are written.
-- Per-player setting tpr-hud: auto (while intoxicated or in harmful air) / always / never.
local C = require("shared.config")
local M = require("scripts.model")

local H = {}

local ROOT = "tpr_hud"
local COLORS = {
	[0] = { 0.55, 0.9, 0.55 },
	[1] = { 1, 0.85, 0.3 },
	[2] = { 1, 0.55, 0.15 },
	[3] = { 1, 0.3, 0.3 },
}

local function int(value)
	return tostring(math.floor(value + 0.5))
end

local function one(value)
	return string.format("%.1f", value)
end

local function percent(share)
	return int(share * 100)
end

local function build(player, data)
	local left = player.gui.left
	if left[ROOT] then left[ROOT].destroy() end
	local root = left.add({ type = "frame", name = ROOT, direction = "vertical" })
	root.style.padding = 8
	root.style.minimal_width = 300
	local head = root.add({ type = "flow", direction = "horizontal" })
	head.style.vertical_align = "center"
	head.style.horizontal_spacing = 8
	local icon = head.add({ type = "sprite", sprite = "virtual-signal/" .. C.ALERT.smog })
	icon.style.width = 32
	icon.style.height = 32
	icon.style.stretch_image_to_widget_size = true
	local column = head.add({ type = "flow", direction = "vertical" })
	column.style.vertical_spacing = 2
	local title = column.add({ type = "label" })
	title.style.font = "default-bold"
	local bar = column.add({ type = "progressbar", value = 0 })
	bar.style.width = 240
	local air = root.add({ type = "label" })
	local guard = root.add({ type = "label" })
	local trend = root.add({ type = "label" })
	for _, label in ipairs({ air, guard, trend }) do
		label.style.single_line = false
		label.style.maximal_width = 320
	end
	data.hud = { root = root, icon = icon, title = title, bar = bar, air = air, guard = guard, trend = trend, keys = {} }
	return data.hud
end

function H.destroy(player, data)
	local frame = player.gui.left[ROOT]
	if frame then frame.destroy() end
	data.hud = nil
end

function H.hide(player, data)
	local hud = data.hud
	if hud and hud.root.valid then
		hud.root.visible = false
	end
end

-- Writes `value` into element[field] only when `key` changed since the last write under `id`.
local function set(hud, id, element, field, key, value)
	local keys = hud.keys
	if keys[id] ~= key then
		keys[id] = key
		element[field] = value
	end
end

local function protection_text(state)
	local parts = { "" }
	if state.vehicle then
		parts[#parts + 1] = { "tpr-hud.part-vehicle", state.vehicle.name, percent(state.vehicle.share) }
	end
	if state.module then
		local status = state.module.status
		parts[#parts + 1] = { "tpr-hud.part-module", state.module.name, percent(state.module.share),
			(status == "low" or status == "empty") and { "tpr-hud.module-" .. status } or "" }
	end
	local armor = state.armor
	if armor then
		if armor.exhausted then
			parts[#parts + 1] = { "tpr-hud.part-armor-exhausted", armor.name }
		else
			parts[#parts + 1] = { "tpr-hud.part-armor", armor.name, percent(armor.share),
				armor.max > 0 and int(armor.resource / armor.max * 100) or "0" }
		end
		if state.filters then
			parts[#parts + 1] = { "tpr-hud.part-filters", C.REFILL_ITEM, tostring(state.filters) }
		end
	elseif state.unprotected_armor then
		parts[#parts + 1] = { "tpr-hud.part-no-filter", state.unprotected_armor }
	end
	if #parts == 1 then
		return { "tpr-hud.no-protection" }
	end
	return { "tpr-hud.protection", percent(state.filtration), parts }
end

local function trend_text(state, intoxication)
	if state.damage > 0 then
		return { "tpr-hud.damage", one(state.damage) }
	end
	local eta = M.eta(intoxication, state.rate)
	if state.rate > 0 then
		return eta and { "tpr-hud.rising", one(state.rate), int(eta) } or { "tpr-hud.rising-full", one(state.rate) }
	end
	if intoxication > 0 then
		return { "tpr-hud.falling", one(-state.rate), int(eta or 0), state.zone and { "tpr-hud.zone" } or "" }
	end
	return { "tpr-hud.clean" }
end

function H.update(player, data, state, intoxication)
	local mode = player.mod_settings["tpr-hud"].value
	local show = mode == "always"
		or (mode == "auto" and (intoxication >= 1 or state.pollution > state.tolerance or data.alert ~= nil))
	if not show then
		if mode == "never" and data.hud then
			H.destroy(player, data)
		else
			H.hide(player, data)
		end
		return
	end
	local hud = data.hud
	if not (hud and hud.root.valid) then
		hud = build(player, data)
	end
	hud.root.visible = true

	local tier = M.tier(intoxication)
	local x = int(intoxication)
	set(hud, "title", hud.title, "caption", x .. "/" .. tier, { "tpr-hud.title", x, { "tpr-tier.t" .. tier } })
	set(hud, "title-color", hud.title.style, "font_color", tier, COLORS[tier])
	set(hud, "bar", hud.bar, "value", x, intoxication / 100)
	set(hud, "bar-color", hud.bar.style, "color", tier, COLORS[tier])
	set(hud, "icon", hud.icon, "sprite", tier, "virtual-signal/" .. (tier >= 2 and C.ALERT.danger or C.ALERT.smog))

	local safe = M.safe_level(state.tolerance, state.filtration)
	local safe_text = safe == math.huge and { "tpr-hud.infinite" } or int(safe)
	set(hud, "air", hud.air, "caption", int(state.inhaled) .. "/" .. int(state.tolerance) .. "/" .. int(math.min(safe, 1e9)),
		{ "tpr-hud.air", int(state.inhaled), int(state.tolerance), safe_text })

	local armor = state.armor
	local guard_key = percent(state.filtration) .. "/" .. (state.vehicle and state.vehicle.name or "")
		.. "/" .. (state.module and (state.module.name .. state.module.status .. percent(state.module.share)) or "")
		.. "/" .. (armor and (armor.name .. percent(armor.share) .. tostring(armor.exhausted)
			.. int(armor.max > 0 and armor.resource / armor.max * 100 or 0)) or (state.unprotected_armor or ""))
		.. "/" .. tostring(state.filters)
	set(hud, "guard", hud.guard, "caption", guard_key, protection_text(state))

	local trend_key = one(state.rate) .. "/" .. one(state.damage) .. "/" .. tostring(state.zone) .. "/" .. x
	set(hud, "trend", hud.trend, "caption", trend_key, trend_text(state, intoxication))

	local level = state.level
	local tip_key = int(state.pollution) .. "/" .. level .. "/" .. guard_key
	local tooltip = { "tpr-hud.tooltip", int(state.pollution), int(state.tolerance), tostring(level),
		int(level * C.MODEL.tolerance_per_level * 100), int(level * C.MODEL.resource_per_level * 100),
		percent(state.filtration), tostring(C.MODEL.damage_from) }
	for index, element in ipairs({ hud.title, hud.bar, hud.air, hud.guard, hud.trend, hud.icon }) do
		set(hud, "tip" .. index, element, "tooltip", tip_key, tooltip)
	end
end

function H.reset_all()
	for _, player in pairs(game.players) do
		local frame = player.gui.left[ROOT]
		if frame then frame.destroy() end
	end
	for _, data in pairs(storage.players) do
		data.hud = nil
	end
end

return H
