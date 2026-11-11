-- Settings panel of a teleporter: anchored to the right of the vanilla chest window (the chest grid, slot filters and
-- the red bar stay vanilla). Built once on open, updated in place every 15 ticks while open.
local tiers = require("shared.tiers")
local registry = require("scripts.registry")
local transfer = require("scripts.transfer")

local M = {}

local PANEL = "ptl_panel"
local CHEST = defines.inventory.chest
local SPRITES = {
	[defines.entity_status_diode.green] = "utility/status_working",
	[defines.entity_status_diode.yellow] = "utility/status_yellow",
	[defines.entity_status_diode.red] = "utility/status_not_working",
}

local function state(player)
	local s = storage.players[player.index]
	if not s then
		s = {}
		storage.players[player.index] = s
	end
	return s
end

function M.close(player)
	local frame = player.gui.relative[PANEL]
	if frame then frame.destroy() end
	storage.players[player.index] = nil
end

-- Planets for the destination list: every planet with a surface except the teleporter's own, plus the current
-- target even before its surface exists. Hidden planets only when a receiver of the force is there (Maraxsis trench).
local function target_list(rec)
	local own = rec.entity.surface.index
	local force_index = rec.entity.force.index
	local has_receiver = {}
	for key in pairs(storage.receivers) do
		local f, s = key:match("^(%d+)|(%d+)|")
		if tonumber(f) == force_index then has_receiver[tonumber(s)] = true end
	end
	local names = {}
	for name, planet in pairs(game.planets) do
		local surface = planet.surface
		local visible = not planet.prototype.hidden or (surface and has_receiver[surface.index])
		if (surface and surface.index ~= own and visible) or name == rec.target then names[#names + 1] = name end
	end
	table.sort(names, function(a, b)
		local pa, pb = prototypes.space_location[a], prototypes.space_location[b]
		local oa, ob = pa and pa.order or a, pb and pb.order or b
		if oa ~= ob then return oa < ob end
		return a < b
	end)
	return names
end

local function target_items(names)
	local items = {{"ptl-gui.target-none"}}
	for _, name in ipairs(names) do
		local proto = prototypes.space_location[name]
		items[#items + 1] = {"", "[planet=" .. name .. "] ", proto and proto.localised_name or name}
	end
	return items
end

local function index_of(list, value)
	for i, v in ipairs(list) do
		if v == value then return i end
	end
end

local function row(table_el, caption, tooltip)
	return table_el.add{type = "label", caption = caption, tooltip = tooltip, style = "bold_label"}
end

function M.open(player, entity)
	M.close(player)
	local rec = registry.get(entity.unit_number) or registry.add(entity)
	local tier = tiers.by_name[entity.name]
	local s = state(player)
	s.unit = rec.unit

	local frame = player.gui.relative.add{type = "frame", name = PANEL, direction = "vertical",
		caption = {"ptl-gui.title"},
		anchor = {gui = defines.relative_gui_type.container_gui, position = defines.relative_gui_position.right,
			names = tiers.names}}
	local pane = frame.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
	pane.style.width = 340
	local inner = pane.add{type = "flow", direction = "vertical"}
	inner.style.vertical_spacing = 8

	local status = inner.add{type = "flow", direction = "horizontal"}
	status.style.vertical_align = "center"
	status.style.horizontal_spacing = 8
	s.status_sprite = status.add{type = "sprite", sprite = "utility/status_yellow"}
	s.status_label = status.add{type = "label", caption = ""}
	s.status_label.style.single_line = false
	s.status_label.style.maximal_width = 290
	s.charge = inner.add{type = "progressbar", value = 0, tooltip = {"ptl-gui.charge-tooltip"}}
	s.charge.style.horizontally_stretchable = true

	local t = inner.add{type = "table", column_count = 2}
	t.style.horizontal_spacing = 12
	t.style.vertical_spacing = 8
	t.style.column_alignments[1] = "left"
	t.style.column_alignments[2] = "right"

	row(t, {"ptl-gui.mode"}, {"ptl-gui.mode-tooltip"})
	s.mode = t.add{type = "drop-down", tags = {ptl = "mode"},
		items = {{"ptl-gui.mode-send"}, {"ptl-gui.mode-receive"}, {"ptl-gui.mode-off"}},
		selected_index = index_of(registry.MODES, rec.mode) or 2}

	row(t, {"ptl-gui.channel"}, {"ptl-gui.channel-tooltip"})
	s.channel = t.add{type = "choose-elem-button", elem_type = "signal", signal = rec.channel, tags = {ptl = "channel"},
		tooltip = {"ptl-gui.channel-tooltip"}}

	s.target_label = row(t, {"ptl-gui.target"}, {"ptl-gui.target-tooltip"})
	s.targets = target_list(rec)
	s.target = t.add{type = "drop-down", tags = {ptl = "target"}, items = target_items(s.targets),
		selected_index = (rec.target and index_of(s.targets, rec.target) or 0) + 1}
	s.target.style.minimal_width = 180

	s.rule_label = row(t, {"ptl-gui.rule"}, {"ptl-gui.rule-tooltip"})
	s.rule = t.add{type = "drop-down", tags = {ptl = "rule"},
		items = {{"ptl-gui.rule-ready"}, {"ptl-gui.rule-full"}, {"ptl-gui.rule-circuit"}},
		selected_index = index_of(registry.RULES, rec.rule) or 1}
	s.rule.style.minimal_width = 180

	s.cond_label = row(t, {"ptl-gui.condition"}, {"ptl-gui.condition-tooltip"})
	local cond = t.add{type = "flow", direction = "horizontal"}
	cond.style.vertical_align = "center"
	cond.style.horizontal_spacing = 8
	s.cond_flow = cond
	s.cond_signal = cond.add{type = "choose-elem-button", elem_type = "signal", signal = rec.cond and rec.cond.signal,
		tags = {ptl = "cond-signal"}}
	s.cond_comparator = cond.add{type = "drop-down", items = registry.COMPARATORS, tags = {ptl = "comparator"},
		selected_index = index_of(registry.COMPARATORS, rec.cond and rec.cond.comparator) or 1}
	s.cond_comparator.style.width = 56
	s.cond_constant = cond.add{type = "textfield", text = tostring(rec.cond and rec.cond.constant or 0),
		numeric = true, allow_negative = true, allow_decimal = false, tags = {ptl = "constant"}}
	s.cond_constant.style.width = 80
	s.constant_shown = rec.cond and rec.cond.constant or 0

	s.network = inner.add{type = "label", caption = ""}
	s.network.style.single_line = false
	s.network.style.maximal_width = 310
	s.stats = inner.add{type = "label", caption = ""}
	s.stats.style.single_line = false
	s.stats.style.maximal_width = 310
	local info = inner.add{type = "label", style = "label", caption = {"ptl-gui.info", tostring(tier.power_mw),
		tostring(tier.cycle_s), tostring(tier.power_mw * tier.cycle_s / 1000), #rec.entity.get_inventory(CHEST),
		tostring(tier.receive_mw)}}
	info.style.single_line = false
	info.style.maximal_width = 310
	info.style.font_color = {0.7, 0.7, 0.7}

	M.refresh(player)
end

local function same_signal(a, b) return registry.channel_key(a) == registry.channel_key(b) end

-- In place: status, charge, which rows show, values changed elsewhere (another player, copy-paste), network.
function M.refresh(player)
	local s = storage.players[player.index]
	local frame = player.gui.relative[PANEL]
	if not (s and frame and s.unit and s.mode and s.mode.valid) then return end
	local rec = registry.get(s.unit)
	if not rec then
		M.close(player)
		return
	end
	local entity = rec.entity
	local tier = tiers.by_name[entity.name]
	if rec.mode ~= "send" then transfer.passive_status(rec) end

	s.status_sprite.sprite = SPRITES[rec.status_diode or defines.entity_status_diode.yellow]
	s.status_label.caption = rec.status_label or ""
	local sending = rec.mode == "send"
	local charger = rec.charger
	s.charge.visible = sending
	if sending and charger and charger.valid then
		s.charge.value = math.min(1, charger.energy / tier.energy_j)
	end

	local mode_index = index_of(registry.MODES, rec.mode) or 2
	if s.mode.selected_index ~= mode_index then s.mode.selected_index = mode_index end
	if not same_signal(s.channel.elem_value, rec.channel) then s.channel.elem_value = rec.channel end
	local target_index = (rec.target and index_of(s.targets, rec.target) or 0) + 1
	if rec.target and not index_of(s.targets, rec.target) then
		s.targets = target_list(rec)
		s.target.items = target_items(s.targets)
		target_index = (index_of(s.targets, rec.target) or 0) + 1
	end
	if s.target.selected_index ~= target_index then s.target.selected_index = target_index end
	local rule_index = index_of(registry.RULES, rec.rule) or 1
	if s.rule.selected_index ~= rule_index then s.rule.selected_index = rule_index end
	local cond = rec.cond or {}
	if not same_signal(s.cond_signal.elem_value, cond.signal) then s.cond_signal.elem_value = cond.signal end
	local comparator_index = index_of(registry.COMPARATORS, cond.comparator) or 1
	if s.cond_comparator.selected_index ~= comparator_index then s.cond_comparator.selected_index = comparator_index end
	-- The number field is rewritten only when the value changed elsewhere, never while the player types in it.
	if (cond.constant or 0) ~= s.constant_shown then
		s.cond_constant.text = tostring(cond.constant or 0)
		s.constant_shown = cond.constant or 0
	end

	s.target_label.visible, s.target.visible = sending, sending
	s.rule_label.visible, s.rule.visible = sending, sending
	local circuit = sending and rec.rule == "circuit"
	s.cond_label.visible, s.cond_flow.visible = circuit, circuit

	if sending then
		local surface = transfer.target_surface(rec)
		local receivers = surface and transfer.receivers_for(rec, surface) or {}
		local free, powered = 0, 0
		for _, r in ipairs(receivers) do
			if registry.powered(r) then
				powered = powered + 1
				free = free + r.entity.get_inventory(CHEST).count_empty_stacks(false, false)
			end
		end
		s.network.caption = rec.target and {"ptl-gui.network-send", #receivers, free, powered} or
			{"ptl-gui.network-none"}
		s.stats.caption = {"ptl-gui.stats-send", rec.sent or 0, rec.last_moved or 0}
	elseif rec.mode == "receive" then
		local senders = 0
		for unit in pairs(storage.senders) do
			local other = storage.units[unit]
			if other and other.entity and other.entity.valid and other.target and other.entity.force == entity.force
				and transfer.target_surface(other) == entity.surface and same_signal(other.channel, rec.channel) then
				senders = senders + 1
			end
		end
		s.network.caption = {"ptl-gui.network-receive", senders}
		s.stats.caption = {"ptl-gui.stats-receive", rec.received or 0}
	else
		s.network.caption = ""
		s.stats.caption = ""
	end
end

-- Every player looking at this teleporter.
function M.refresh_unit(unit)
	for index, s in pairs(storage.players) do
		if s.unit == unit then
			local player = game.get_player(index)
			if player then M.refresh(player) end
		end
	end
end

function M.refresh_all()
	for index in pairs(storage.players) do
		local player = game.get_player(index)
		if player and player.valid then M.refresh(player) else storage.players[index] = nil end
	end
end

-- One change from the panel (or the remote interface with the same arguments).
function M.apply(player, field, value)
	local s = storage.players[player.index]
	local rec = s and s.unit and registry.get(s.unit)
	if not rec then return false end
	local settings = registry.settings_of(rec)
	if field == "mode" then
		settings.mode = registry.MODES[value] or settings.mode
	elseif field == "channel" then
		settings.channel = value
	elseif field == "target" then
		settings.target = s.targets[(value or 1) - 1]
	elseif field == "rule" then
		settings.rule = registry.RULES[value] or settings.rule
	elseif field == "cond-signal" then
		settings.cond.signal = value
	elseif field == "comparator" then
		settings.cond.comparator = registry.COMPARATORS[value] or settings.cond.comparator
	elseif field == "constant" then
		settings.cond.constant = tonumber(value) or 0
	else
		return false
	end
	registry.apply_settings(rec, settings)
	if field == "constant" then s.constant_shown = rec.cond.constant end
	if rec.mode == "send" then transfer.process(rec) else transfer.passive_status(rec) end
	M.refresh_unit(rec.unit)
	return true
end

function M.on_gui_event(event)
	local element = event.element
	if not (element and element.valid) then return end
	local field = element.tags and element.tags.ptl
	if not field then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	local value
	if element.type == "drop-down" then
		value = element.selected_index
	elseif element.type == "choose-elem-button" then
		value = element.elem_value
	elseif element.type == "textfield" then
		value = element.text
	end
	M.apply(player, field, value)
end

-- What the panel shows (remote interface for tests).
function M.describe(player)
	local s = storage.players[player.index]
	local frame = player.gui.relative[PANEL]
	if not (s and frame and s.mode and s.mode.valid) then return {open = false} end
	local function vis(el) return el and el.valid and el.visible end
	return {open = true, unit = s.unit, mode = s.mode.selected_index, target = s.target.selected_index,
		targets = s.targets, rule = s.rule.selected_index, target_visible = vis(s.target), rule_visible = vis(s.rule),
		cond_visible = vis(s.cond_flow), charge_visible = vis(s.charge), charge = s.charge.value,
		status = s.status_label.caption, network = s.network.caption, stats = s.stats.caption}
end

return M
