-- Top panel button and the rules window.

local mod_gui = require("mod-gui")
local compat = require("__paranoidal-autofill__/scripts/compat")
local state = require("__paranoidal-autofill__/scripts/state")

local M = {}

M.BUTTON = "paranoidal_autofill_button"
M.FRAME = "paranoidal_autofill_frame" -- GUI Unifier highlights the button while it is open

local L = "paranoidal-autofill."

local function button_style(player)
	-- Match GUI Unifier when it is present; it restyles the button itself as well.
	local ps = settings.get_player_settings(player)
	local s = ps["gu_button_style_setting"]
	if s and type(s.value) == "string" and s.value ~= "" then return s.value end
	return mod_gui.button_style
end

function M.ensure_button(player)
	if not (player and player.valid) then return end
	local flow = mod_gui.get_button_flow(player)
	local button = flow[M.BUTTON]
	if button and button.valid then return end
	local ok = pcall(flow.add, {
		type = "sprite-button", name = M.BUTTON, sprite = "paranoidal-autofill-button",
		style = button_style(player), tooltip = { L .. "button-tooltip" },
	})
	if not ok then
		flow.add({
			type = "sprite-button", name = M.BUTTON, sprite = "paranoidal-autofill-button",
			style = mod_gui.button_style, tooltip = { L .. "button-tooltip" },
		})
	end
end

function M.recreate_button(player)
	local flow = mod_gui.get_button_flow(player)
	if flow[M.BUTTON] then flow[M.BUTTON].destroy() end
	M.ensure_button(player)
end

local function frame_of(player)
	local frame = player.gui.screen[M.FRAME]
	if frame and frame.valid then return frame end
end

function M.close(player)
	local frame = frame_of(player)
	if frame then frame.destroy() end
end

local function quality_of(value)
	local q = value and value.quality
	if type(q) == "table" then q = q.name end
	return q or "normal"
end

local function add_item_slot(parent, rule, ri, si, it, item_filter)
	local col = parent.add({ type = "flow", direction = "vertical" })
	col.style.vertical_spacing = 2
	col.style.horizontal_align = "center"
	col.add({
		type = "choose-elem-button", elem_type = "item-with-quality",
		["item-with-quality"] = it and { name = it.name, quality = it.quality } or nil,
		elem_filters = item_filter, style = "slot_button",
		tooltip = it and { L .. "item-tooltip" } or { L .. "add-item-tooltip" },
		tags = { paf = "item", ri = ri, si = si },
	})
	if it then
		local field = col.add({
			type = "textfield", text = tostring(it.count), numeric = true,
			allow_decimal = false, allow_negative = false, lose_focus_on_confirm = true,
			tooltip = { L .. "count-tooltip" }, style = "short_number_textfield",
			tags = { paf = "count", ri = ri, si = si },
		})
		field.style.width = 40
		field.style.horizontal_align = "center"
	end
end

-- Names list plus `extra` values already chosen (kept visible in any mode).
local function name_filter(names, extra)
	local list, seen = {}, {}
	for _, n in ipairs(names) do
		if not seen[n] then seen[n] = true; list[#list + 1] = n end
	end
	for _, n in ipairs(extra or {}) do
		if not seen[n] then seen[n] = true; list[#list + 1] = n end
	end
	if #list == 0 then return nil end
	return { { filter = "name", name = list } }
end

local function fill_rules(list, player)
	list.clear()
	local data = state.player(player.index)
	local c = compat.get()
	local force = player.force
	local learned = data.show ~= "all"
	local entity_names = c.entity_names
	if learned then
		entity_names = {}
		for _, name in ipairs(c.entity_names) do
			if compat.entity_learned(force, name) then entity_names[#entity_names + 1] = name end
		end
	end
	local item_ok = {}
	local function item_shown(name)
		if not learned then return true end
		local v = item_ok[name]
		if v == nil then
			v = compat.item_learned(force, name)
			item_ok[name] = v
		end
		return v
	end
	for ri, rule in ipairs(data.rules) do
		local info = compat.entity(rule.entity)
		local row = list.add({ type = "flow", direction = "horizontal" })
		row.style.vertical_align = "top"
		row.style.horizontal_spacing = 8
		local check = row.add({
			type = "checkbox", state = rule.enabled, tooltip = { L .. "rule-tooltip" },
			tags = { paf = "toggle", ri = ri },
		})
		check.style.top_margin = 10
		row.add({
			type = "choose-elem-button", elem_type = "entity", entity = rule.entity,
			elem_filters = name_filter(entity_names, { rule.entity }), style = "slot_button",
			tooltip = { L .. "building-tooltip" }, tags = { paf = "entity", ri = ri },
		})
		local arrow = row.add({ type = "label", caption = "→" })
		arrow.style.font = "default-large-bold"
		arrow.style.top_margin = 8
		local items = row.add({ type = "flow", direction = "horizontal" })
		items.style.horizontal_spacing = 4
		local shown, chosen = {}, {}
		for _, name in ipairs(info and info.items or {}) do
			if item_shown(name) then shown[#shown + 1] = name end
		end
		for _, it in ipairs(rule.items) do chosen[#chosen + 1] = it.name end
		local item_filter = name_filter(shown, chosen)
		for si, it in ipairs(rule.items) do
			add_item_slot(items, rule, ri, si, it, item_filter)
		end
		if #rule.items < state.MAX_ITEMS and #shown > 0 then
			add_item_slot(items, rule, ri, #rule.items + 1, nil, name_filter(shown))
		elseif #rule.items == 0 then
			local none = items.add({ type = "label", caption = { L .. "no-items" } })
			none.style.top_margin = 8
			none.style.font_color = { 0.75, 0.75, 0.75 }
		end
		local push = row.add({ type = "empty-widget" })
		push.style.horizontally_stretchable = true
		local del = row.add({
			type = "sprite-button", sprite = "utility/trash", style = "tool_button_red",
			tooltip = { L .. "delete" }, tags = { paf = "delete", ri = ri },
		})
		del.style.top_margin = 6
		list.add({ type = "line" })
	end
	local add = list.add({ type = "flow", direction = "horizontal" })
	add.style.vertical_align = "center"
	add.style.horizontal_spacing = 8
	local new_filter = name_filter(entity_names)
	if new_filter then
		add.add({
			type = "choose-elem-button", elem_type = "entity", elem_filters = new_filter,
			style = "slot_button", tooltip = { L .. "new-building-tooltip" }, tags = { paf = "new-entity" },
		})
		add.add({ type = "label", caption = { L .. "new-building" } })
	else
		local none = add.add({ type = "label", caption = { L .. "no-buildings" } })
		none.style.font_color = { 0.75, 0.75, 0.75 }
	end
end

function M.refresh(player)
	local frame = frame_of(player)
	if not frame then return end
	local list = frame.content and frame.content.scroll and frame.content.scroll.list
	if list then fill_rules(list, player) end
end

function M.open(player)
	M.close(player)
	local data = state.player(player.index)
	local frame = player.gui.screen.add({ type = "frame", name = M.FRAME, direction = "vertical" })
	frame.style.minimal_width = 420

	local bar = frame.add({ type = "flow", direction = "horizontal" })
	bar.drag_target = frame
	bar.style.horizontal_spacing = 8
	bar.add({ type = "label", caption = { L .. "title" }, style = "frame_title", ignored_by_interaction = true })
	local drag = bar.add({ type = "empty-widget", style = "draggable_space_header", ignored_by_interaction = true })
	drag.style.height = 24
	drag.style.horizontally_stretchable = true
	drag.style.right_margin = 4
	bar.add({
		type = "sprite-button", sprite = "utility/close", style = "frame_action_button",
		tooltip = { "gui.close-instruction" }, tags = { paf = "close" },
	})

	local content = frame.add({ type = "frame", name = "content", direction = "vertical", style = "inside_shallow_frame_with_padding" })
	local top = content.add({ type = "flow", direction = "horizontal" })
	top.style.vertical_align = "center"
	top.style.horizontal_spacing = 12
	top.add({ type = "label", caption = { L .. "on-build" }, tooltip = { L .. "on-build-tooltip" }, style = "caption_label" })
	top.add({
		type = "switch", switch_state = data.on_build and "right" or "left",
		left_label_caption = { L .. "off" }, right_label_caption = { L .. "on" },
		tooltip = { L .. "on-build-tooltip" }, tags = { paf = "on-build" },
	})
	local show = content.add({ type = "flow", direction = "horizontal" })
	show.style.vertical_align = "center"
	show.style.horizontal_spacing = 12
	show.add({ type = "label", caption = { L .. "show" }, style = "caption_label" })
	show.add({
		type = "switch", switch_state = data.show == "all" and "right" or "left",
		left_label_caption = { L .. "show-learned" }, left_label_tooltip = { L .. "show-learned-tooltip" },
		right_label_caption = { L .. "show-all" }, right_label_tooltip = { L .. "show-all-tooltip" },
		tags = { paf = "show" },
	})
	content.add({ type = "line" })

	local scroll = content.add({ type = "scroll-pane", name = "scroll", direction = "vertical" })
	scroll.horizontal_scroll_policy = "never"
	scroll.style.maximal_height = 520
	local list = scroll.add({ type = "flow", name = "list", direction = "vertical" })
	list.style.vertical_spacing = 6
	fill_rules(list, player)

	content.add({ type = "line" })
	local hint = content.add({ type = "label", caption = { L .. "hint" } })
	hint.style.font_color = { 0.75, 0.75, 0.75 }

	frame.force_auto_center()
	player.opened = frame
end

function M.toggle(player)
	if frame_of(player) then M.close(player) else M.open(player) end
end

local function notice(player, text)
	player.create_local_flying_text({ text = text, create_at_cursor = true })
	player.play_sound({ path = "utility/cannot_build" })
end

local function own(element)
	if not (element and element.valid) then return end
	if element.get_mod() ~= script.mod_name then return end
	local tags = element.tags
	if tags and tags.paf then return tags end
end

function M.on_click(event)
	local element = event.element
	if not (element and element.valid) then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	if element.name == M.BUTTON and element.get_mod() == script.mod_name then
		M.toggle(player)
		return
	end
	local tags = own(element)
	if not tags then return end
	if tags.paf == "close" then
		M.close(player)
	elseif tags.paf == "delete" then
		local data = state.player(player.index)
		if data.rules[tags.ri] then table.remove(data.rules, tags.ri) end
		M.refresh(player)
	end
end

function M.on_elem_changed(event)
	local tags = own(event.element)
	if not tags then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	local data = state.player(player.index)
	local element = event.element
	local value = element.elem_value

	if tags.paf == "new-entity" then
		if type(value) ~= "string" then return end
		if state.find_rule(data, value) then
			notice(player, { L .. "already-added" })
		elseif compat.canonical(value) == value then
			table.insert(data.rules, { entity = value, enabled = true, items = {} })
		end
		M.refresh(player)
	elseif tags.paf == "entity" then
		local rule = data.rules[tags.ri]
		if not rule then return M.refresh(player) end
		if type(value) ~= "string" then
			table.remove(data.rules, tags.ri) -- right click clears the building: remove the row
		elseif value ~= rule.entity then
			if state.find_rule(data, value) then
				notice(player, { L .. "already-added" })
			elseif compat.canonical(value) == value then
				rule.entity = value
				local kept = {}
				for _, it in ipairs(rule.items) do
					if state.item_allowed(value, it.name, it.quality) then kept[#kept + 1] = it end
				end
				rule.items = kept
			end
		end
		M.refresh(player)
	elseif tags.paf == "item" then
		local rule = data.rules[tags.ri]
		if not rule then return M.refresh(player) end
		local si = tags.si
		if type(value) ~= "table" or not value.name then
			if rule.items[si] then table.remove(rule.items, si) end
		else
			local quality = quality_of(value)
			if state.item_allowed(rule.entity, value.name, quality) then
				local it = rule.items[si]
				if it then
					it.name, it.quality = value.name, quality
				elseif #rule.items < state.MAX_ITEMS then
					rule.items[#rule.items + 1] = { name = value.name, quality = quality, count = state.default_count(value.name) }
				end
			end
		end
		M.refresh(player)
	end
end

function M.on_text_changed(event)
	local tags = own(event.element)
	if not (tags and tags.paf == "count") then return end
	local data = state.player(event.player_index)
	local rule = data.rules[tags.ri]
	local it = rule and rule.items[tags.si]
	local n = tonumber(event.element.text)
	if it and n and n >= 1 then it.count = state.clamp_count(n) end
end

function M.on_confirmed(event)
	local tags = own(event.element)
	if not (tags and tags.paf == "count") then return end
	local data = state.player(event.player_index)
	local rule = data.rules[tags.ri]
	local it = rule and rule.items[tags.si]
	if it then event.element.text = tostring(it.count) end
end

function M.on_checked(event)
	local tags = own(event.element)
	if not (tags and tags.paf == "toggle") then return end
	local data = state.player(event.player_index)
	local rule = data.rules[tags.ri]
	if rule then rule.enabled = event.element.state end
end

function M.on_switch(event)
	local tags = own(event.element)
	if not tags then return end
	local data = state.player(event.player_index)
	if tags.paf == "on-build" then
		data.on_build = event.element.switch_state == "right"
	elseif tags.paf == "show" then
		data.show = event.element.switch_state == "right" and "all" or "learned"
		local player = game.get_player(event.player_index)
		if player then M.refresh(player) end
	end
end

function M.on_closed(event)
	local element = event.element
	if element and element.valid and element.name == M.FRAME and element.get_mod() == script.mod_name then
		element.destroy()
	end
end

return M
