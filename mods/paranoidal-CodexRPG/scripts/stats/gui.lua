-- The base journal: the RPG window as a book over most of the screen. Bookmarks on the left, a
-- two-page spread on the right (one page on narrow screens). All sizes come from the player's screen
-- and stay the same on every bookmark, so nothing moves when switching, and every text that can be
-- long wraps instead of being cut. The window is redrawn only on clicks, on opening, when a snapshot
-- is ready and, on the character pages, when the experience changes.
local mod_gui = require("mod-gui")
local data = require("scripts.stats.data")
local fmt = data.fmt

local G = {}

local FRAME = "char-panel"
local OLD_PASSPORT = "rpg-stats-passport" -- separate window of the first version
local SHELL = 3                           -- layout version kept in the window tags

local ORANGE = {1, 0.77, 0.2}
local MUTED = {0.68, 0.68, 0.68}
local DIM = {0.45, 0.45, 0.45}
local TEXT = {0.88, 0.88, 0.88}
local GREEN = {0.36, 0.78, 0.24}
local BLUE = {0.3, 0.6, 0.95}
local RED = {0.88, 0.3, 0.22}

local TABS = {
	{id = "char", icon = "[entity=character]"},
	{id = "passport", icon = "[img=utility/list_view]"},
	{id = "base", icon = "[item=assembling-machine-1]"},
	{id = "world", icon = "[item=radar]"},
	{id = "war", icon = "[item=gun-turret]"},
	{id = "quality", icon = "[virtual-signal=signal-star]"},
	{id = "milestones", icon = "[virtual-signal=signal-check]"},
	{id = "codex", icon = "[virtual-signal=signal-info]"},
}
local NEEDS_SNAPSHOT = {passport = true, base = true, world = true, war = true, quality = true}
local ARTICLES = {"defects", "quality", "ruins", "rpg", "stats"}

---------------------------------------------------------------------------------------------
-- layout

local LY -- sizes of the window being drawn

-- Window, page and card sizes in GUI pixels for this player's screen.
local function measure(player)
	local scale = player.display_scale
	if not scale or scale <= 0 then scale = 1 end
	local res = player.display_resolution
	local W, H = math.floor(res.width / scale), math.floor(res.height / scale)
	local l = {}
	l.win_w = math.max(700, math.min(W - 48, 1760))
	l.win_h = math.max(460, math.min(H - 72, 1060))
	l.nav_w = 196
	l.gap = 8
	l.book_w = l.win_w - 16 - l.nav_w - l.gap -- frame padding 8 + 8
	l.single = math.floor((l.book_w - l.gap) / 2) < 430
	l.page_w = l.single and l.book_w or math.floor((l.book_w - l.gap) / 2)
	-- scroll padding 10 + 4, reserved scrollbar 12, slack for borders
	l.card_w = l.page_w - 36
	l.inner_w = l.card_w - 24 -- card padding 12 + 12
	l.key_w = math.floor(l.inner_w * 0.58)
	l.val_w = l.inner_w - l.key_w - 8
	return l
end

---------------------------------------------------------------------------------------------
-- small helpers

local function L(key, ...) return {"rpg-stats." .. key, ...} end

local function entity_name(name)
	local p = prototypes.entity[name]
	if not p then return name end
	return {"", "[entity=" .. name .. "] ", p.localised_name}
end

local function item_name(name)
	local p = prototypes.item[name]
	if not p then return name end
	return {"", "[item=" .. name .. "] ", p.localised_name}
end

local function tech_name(name)
	local p = prototypes.technology[name]
	if not p then return name end
	return {"", "[technology=" .. name .. "] ", p.localised_name}
end

local function quality_name(name)
	local q = prototypes.quality[name]
	return q and q.localised_name or name
end

local function since_tooltip(key)
	local s = storage.rpg_stats
	local tick = s and s[key or "since"] or 0
	if tick == 0 then return L("since-start") end
	return L("since", fmt.hm(tick))
end

local function since(caption)
	return {"", caption, " [img=utility/clock]"}
end

local function label(parent, caption, o)
	local l = parent.add{type = "label", caption = caption, name = o and o.name, tooltip = o and o.tooltip,
		tags = o and o.tags}
	if o then
		if o.font then l.style.font = o.font end
		if o.color then l.style.font_color = o.color end
		if o.wrap then l.style.single_line = false l.style.maximal_width = o.wrap end
		if o.width then l.style.width = o.width end
		if o.align then l.style.horizontal_align = o.align end
	end
	return l
end

local function muted(parent, caption, wrap, name)
	return label(parent, caption, {color = MUTED, font = "default-small", wrap = wrap or LY.inner_w, name = name})
end

local function bar(parent, value, color, name)
	local pb = parent.add{type = "progressbar", name = name, value = math.max(0, math.min(1, value or 0))}
	pb.style.width = LY.inner_w
	if color then pb.style.color = color end
	return pb
end

local function card(page, icon, title, tooltip)
	local f = page.add{type = "frame", style = "deep_frame_in_shallow_frame", direction = "vertical"}
	f.style.width = LY.card_w
	f.style.padding = {8, 12, 10, 12}
	if title then
		local head = label(f, {"", icon or "", "  ", title}, {font = "default-bold", color = ORANGE, wrap = LY.inner_w,
			tooltip = tooltip})
		head.style.bottom_margin = 4
	end
	return f
end

local function rows(parent)
	local t = parent.add{type = "table", column_count = 2}
	t.style.horizontal_spacing = 8
	t.style.vertical_spacing = 3
	return t
end

local function row(t, key, value, tooltip)
	local k = t.add{type = "label", caption = key, tooltip = tooltip}
	k.style.width = LY.key_w
	k.style.single_line = false
	k.style.font_color = TEXT
	local v = t.add{type = "label", caption = value, style = "bold_label", tooltip = tooltip}
	v.style.width = LY.val_w
	v.style.single_line = false
	v.style.horizontal_align = "right"
	return v
end

-- A strip of big numbers with small captions, the card width shared equally.
local function bigs(parent, items)
	local n = #items
	local t = parent.add{type = "table", column_count = n}
	t.style.horizontal_spacing = 8
	t.style.bottom_margin = 4
	local w = math.floor((LY.inner_w - 8 * (n - 1)) / n)
	for _, it in ipairs(items) do
		local f = t.add{type = "flow", direction = "vertical"}
		f.style.width = w
		f.style.vertical_spacing = 0
		label(f, it[1], {color = MUTED, font = "default-small", wrap = w, tooltip = it[4]})
		label(f, it[2], {font = "default-large-bold", color = it[3], wrap = w, tooltip = it[4]})
	end
end

-- Name, bar and value in three fixed columns.
local function bar_rows(parent, list, color, name_of, value_of)
	local t = parent.add{type = "table", column_count = 3}
	t.style.horizontal_spacing = 8
	t.style.vertical_spacing = 2
	local name_w = math.floor(LY.inner_w * 0.42)
	local val_w = math.floor(LY.inner_w * 0.26)
	local bar_w = LY.inner_w - name_w - val_w - 16
	local best = 0
	for _, e in ipairs(list) do if e.bar > best then best = e.bar end end
	for _, e in ipairs(list) do
		label(t, name_of(e), {width = name_w, wrap = name_w, color = e.color, font = e.font})
		local pb = t.add{type = "progressbar", value = best > 0 and e.bar / best or 0}
		pb.style.width = bar_w
		pb.style.color = e.color or color
		label(t, value_of(e), {width = val_w, align = "right", font = "default-bold"})
	end
end

local function find(element, name)
	if element.name == name then return element end
	for _, child in pairs(element.children) do
		local found = find(child, name)
		if found then return found end
	end
end

local function snapshot(player)
	local f = storage.rpg_stats and storage.rpg_stats.forces[player.force.index]
	return f and f.snapshot
end

local function tech_pct(sn)
	return sn.tech_total > 0 and 100 * sn.tech_done / sn.tech_total or 0
end

local function hours(ticks) return math.max(ticks, 3600) / 216000 end

local function clock(daytime)
	-- daytime 0 is noon and 0.5 midnight (dusk, evening, morning and dawn lie in between)
	local minutes = math.floor(((daytime * 24 + 12) % 24) * 60)
	return string.format("%d:%02d", math.floor(minutes / 60), minutes % 60)
end

-- Text for the precision of an estimated milestone time.
local function resolution(ticks)
	if ticks <= 3600 then return L("res-minute") end
	if ticks < 216000 then return L("res-min", fmt.int(ticks / 3600)) end
	return L("res-h", fmt.dec(ticks / 216000))
end

-- Time of a milestone: exact, estimated from the statistics history, or "no later than".
local function ms_time(rec)
	if rec.tick then return fmt.hm(rec.tick), nil end
	if rec.est then return L("approx", fmt.hm(rec.est)), L("approx-tooltip", resolution(rec.res or 0)) end
	return L("upto", fmt.hm(rec.upto or 0)), L("upto-tooltip")
end
G.ms_time = ms_time

local function milestone_text(id, rec)
	local pack = id:match("^pack:(.+)$")
	if pack then
		local p = prototypes.item[pack]
		return L("ms-pack", "[item=" .. pack .. "]", p and p.localised_name or pack)
	end
	local q = id:match("^q:(.+)$")
	if q then return L("ms-quality", quality_name(q)) end
	local icon = data.milestone_icon(id)
	if icon then return {"", L("ms-" .. id), "  ", icon} end
	if rec and rec.entity and prototypes.entity[rec.entity] then
		return {"", L("ms-" .. id), "  [entity=" .. rec.entity .. "]"}
	end
	return L("ms-" .. id)
end
G.milestone_text = milestone_text

local function reached_list(f)
	local list = {}
	for id, rec in pairs(f.milestones) do list[#list + 1] = {id = id, rec = rec} end
	table.sort(list, function(a, b)
		local ta, tb = data.record_tick(a.rec), data.record_tick(b.rec)
		if ta ~= tb then return ta < tb end
		return a.id < b.id
	end)
	return list
end

local function pack_text(name)
	local p = prototypes.item[name]
	if not p then return nil end
	return {"", "[item=" .. name .. "] ", p.localised_name}
end

-- What the next base status needs.
local function goal_text(status)
	local step = data.STATUS[status + 1]
	if not step then return L("status-top") end
	if step.rocket then return L("goal-rocket", L("status-" .. (status + 1))) end
	local names = {}
	for _, pack in ipairs(step.packs or {}) do
		local t = pack_text(pack)
		if t then names[#names + 1] = t end
	end
	if #names == 0 then return L("status-top") end
	if #names == 1 then return L("goal-pack", L("status-" .. (status + 1)), names[1]) end
	return L("goal-pack-or", L("status-" .. (status + 1)), names[1], names[2])
end

---------------------------------------------------------------------------------------------
-- window shell

local function window(player) return player.gui.screen[FRAME] end

function G.tab(player)
	return data.player(player.index).tab
end

local function build_shell(player)
	local frame = player.gui.screen.add{type = "frame", name = FRAME, direction = "vertical",
		tags = {shell = SHELL, w = LY.win_w, h = LY.win_h}}
	frame.style.width = LY.win_w
	frame.style.height = LY.win_h
	frame.auto_center = true

	local title = frame.add{type = "flow", name = "title_table", direction = "horizontal"}
	title.drag_target = frame
	title.style.horizontal_spacing = 8
	title.add{type = "label", style = "frame_title", caption = L("book-title"), ignored_by_interaction = true}
	local dragger = title.add{type = "empty-widget", style = "draggable_space_header"}
	dragger.style.height = 24
	dragger.style.horizontally_stretchable = true
	dragger.style.minimal_width = 24
	dragger.drag_target = frame
	local tagfield = title.add{type = "textfield", name = "ctag_field", text = player.tag}
	tagfield.style.width = 200
	tagfield.visible = false
	title.add{type = "sprite-button", name = "rpg_bt_edittag", sprite = "utility/rename_icon",
		style = "frame_action_button", tooltip = {"player_tag"}}
	title.add{type = "sprite-button", name = "rpg_bt_close", sprite = "utility/close",
		style = "frame_action_button", tooltip = L("close")}

	local body = frame.add{type = "flow", name = "rpgst_body", direction = "horizontal"}
	body.style.horizontal_spacing = LY.gap
	body.style.vertically_stretchable = true

	-- bookmarks
	local nav = body.add{type = "frame", name = "nav", style = "inside_deep_frame", direction = "vertical"}
	nav.style.width = LY.nav_w
	nav.style.vertically_stretchable = true
	nav.style.padding = 6
	local buttons = nav.add{type = "flow", name = "buttons", direction = "vertical"}
	buttons.style.vertical_spacing = 4
	for _, t in ipairs(TABS) do
		local b = buttons.add{type = "button", name = "rpgst_tab_" .. t.id, tags = {tab = t.id},
			caption = {"", t.icon, "  ", L("tab-" .. t.id)}, tooltip = L("tab-" .. t.id .. "-tooltip")}
		b.style.width = LY.nav_w - 12
		b.style.horizontal_align = "left"
		b.style.height = 34
	end
	local filler = nav.add{type = "empty-widget"}
	filler.style.vertically_stretchable = true
	local summary = nav.add{type = "frame", name = "summary", style = "inside_shallow_frame_with_padding",
		direction = "vertical"}
	summary.style.width = LY.nav_w - 12
	summary.style.padding = 8

	-- the book: a header line and the pages
	local book = body.add{type = "flow", name = "book", direction = "vertical"}
	book.style.width = LY.book_w
	book.style.vertically_stretchable = true
	book.style.vertical_spacing = 6
	local head = book.add{type = "flow", name = "head", direction = "horizontal"}
	head.style.vertical_align = "center"
	head.style.horizontal_spacing = 10
	head.style.width = LY.book_w
	head.style.height = 32
	local pages = book.add{type = "flow", name = "pages", direction = "horizontal"}
	pages.style.horizontal_spacing = LY.gap
	pages.style.vertically_stretchable = true
	for _, side in ipairs(LY.single and {"left"} or {"left", "right"}) do
		local page = pages.add{type = "frame", name = side, style = "inside_shallow_frame", direction = "vertical"}
		page.style.width = LY.page_w
		page.style.vertically_stretchable = true
		local scroll = page.add{type = "scroll-pane", name = "scroll", horizontal_scroll_policy = "never",
			vertical_scroll_policy = "auto-and-reserve-space"}
		scroll.style.vertically_stretchable = true
		scroll.style.horizontally_stretchable = true
		scroll.style.padding = {10, 4, 10, 10}
	end
	return frame
end

local function render_summary(player, box)
	box.clear()
	local w = LY.nav_w - 12 - 16
	label(box, L("summary-title"), {font = "default-semibold", color = ORANGE})
	local sn = snapshot(player)
	if not sn then
		muted(box, L("summary-empty"), w)
		return
	end
	local function line(icon, caption)
		label(box, {"", icon, " ", caption}, {font = "default-small", wrap = w})
	end
	line("[item=assembling-machine-1]", {"", "«", L("status-" .. sn.status), "»"})
	line("[item=radar]", L("summary-chunks", fmt.int(sn.charted)))
	line("[item=lab]", L("summary-tech", fmt.int(tech_pct(sn))))
	if (sn.spm or 0) > 0 then line("[item=automation-science-pack]", L("summary-spm", fmt.dec(sn.spm))) end
	if sn.quality.best then line("[virtual-signal=signal-star]", quality_name(sn.quality.best[1])) end
	if sn.evolution then
		line("[virtual-signal=signal-skull]", L("summary-evolution", fmt.pct(sn.evolution.total, 1)))
	end
end

local function updated_text(sn, busy)
	if busy then return L("counting") end
	if not sn then return "" end
	local minutes = math.floor((game.tick - sn.tick) / 3600)
	if minutes < 1 then return L("updated-now") end
	if minutes < 60 then return L("updated-min", minutes) end
	return L("updated-h", math.floor(minutes / 60))
end

local function render_head(player, head, tab, sn)
	head.clear()
	label(head, L("tab-" .. tab), {font = "default-large-bold", color = ORANGE})
	-- the subtitle gives way first when the line is short
	label(head, L("tab-" .. tab .. "-tooltip"), {color = MUTED}).style.horizontally_squashable = true
	local filler = head.add{type = "empty-widget"}
	filler.style.horizontally_stretchable = true
	if NEEDS_SNAPSHOT[tab] and data.player_force(player.force) then
		local busy = data.busy(player.force.index)
		label(head, updated_text(sn, busy), {color = MUTED, tooltip = L("refresh-tooltip")})
		local refresh = head.add{type = "sprite-button", name = "rpgst_refresh", sprite = "utility/refresh",
			style = "tool_button", tooltip = L("refresh-tooltip")}
		refresh.enabled = not busy
	end
end

---------------------------------------------------------------------------------------------
-- pages: R[tab](player, left, right, snapshot); on one-page screens left == right

local R = {}

-- Character -------------------------------------------------------------------------------

local function xp_state(player)
	local name = player.name
	local px = storage.personalxp
	local level = px.Level[name] or 1
	local xp = px.XP[name] or 0
	local nxt = storage.xp_table[level]
	local maxed = (not nxt) or xp >= storage.max_xp
	return level, xp, nxt, maxed
end

local function xp_texts(player)
	local level, xp, nxt, maxed = xp_state(player)
	if maxed then return L("xp-max", fmt.int(xp)), "", 1 end
	return L("xp-of", fmt.int(xp), fmt.int(nxt)), L("xp-left", level + 1, fmt.int(nxt - xp)),
		CalculateXP_PB(player.name) or 0
end

local DAMAGE_ATTRIBS = {LV_Armor_Bonus = true, LV_Damage_Bonus = true, LV_Damage_Critical = true}

local function skills(player, parent, points)
	local name = player.name
	local px = storage.personalxp
	local max_level = storage.setting_max_level_ability
	local t = parent.add{type = "table", column_count = 3}
	t.style.horizontal_spacing = 10
	t.style.vertical_spacing = 6
	local level_w = 70
	local text_w = LY.inner_w - 64 - level_w - 20
	for _, attrib in ipairs(storage.Player_Attributes) do
		local shown = storage.RPG_Bonus[attrib] ~= 0
		if DAMAGE_ATTRIBS[attrib] and not storage.setting_allow_damage_attribs then shown = false end
		if shown then
			local vchar = "global.personalxp." .. attrib
			local lvl = px[attrib][name] or 0
			local bonus = storage.RPG_Bonus[attrib]
			local hint = {"xp_hint_" .. vchar, fmt.int(bonus), fmt.int(lvl * bonus)}
			local can = points >= 1 and lvl < max_level
			local b = t.add{type = "sprite-button", name = "btLVU_" .. vchar, sprite = attrib .. "_sprite",
				style = "rounded_button", tooltip = {"", hint, "\n", L(can and "skill-click" or (lvl >= max_level and "skill-max" or "skill-no-points"))}}
			b.style.width = 64
			b.style.height = 64
			b.style.padding = 0
			b.enabled = can
			local f = t.add{type = "flow", direction = "vertical"}
			f.style.vertical_spacing = 0
			f.style.width = text_w
			label(f, {vchar}, {font = "default-bold", wrap = text_w})
			label(f, hint, {color = MUTED, font = "default-small", wrap = text_w})
			label(t, {"", fmt.int(lvl), " / ", fmt.int(max_level)}, {font = "default-large-bold", width = level_w, align = "right"})
		end
	end
end

function R.char(player, lc, rc)
	XP_Time_upd() -- average play time of the force, used by the experience multiplier
	local name = player.name
	local px = storage.personalxp
	local level = xp_state(player)
	local points = math.max(0, level - 1 - SumPointSpent(name))
	local character = player.character
	local p = data.player(player.index)

	local c = card(lc, "[entity=character]", name)
	local top = c.add{type = "flow", direction = "horizontal"}
	top.style.horizontal_spacing = 12
	top.style.vertical_align = "center"
	top.style.bottom_margin = 6
	local portrait = top.add{type = "frame", style = "deep_frame_in_shallow_frame"}
	portrait.style.width = 116
	portrait.style.height = 116
	if character and character.valid then
		local preview = portrait.add{type = "entity-preview"}
		preview.style.width = 112
		preview.style.height = 112
		preview.entity = character
	else
		portrait.add{type = "sprite", sprite = "charxpmod_space_suit"}
	end
	local info = top.add{type = "flow", direction = "vertical"}
	info.style.vertical_spacing = 2
	label(info, L("level", level), {font = "charxpmod_font_30", name = "rpgst_level", tags = {level = level}})
	label(info, L("played", fmt.time(player.online_time)), {color = MUTED, name = "rpgst_time"})
	label(info, L("points-free", points), {font = "default-bold", color = points > 0 and ORANGE or TEXT})
	local xp_text, xp_left, xp_bar = xp_texts(player)
	label(c, xp_text, {name = "rpgst_xp_text", wrap = LY.inner_w})
	bar(c, xp_bar, GREEN, "rpgst_xp_bar")
	muted(c, xp_left, LY.inner_w, "rpgst_xp_left")
	local t = rows(c)
	t.style.top_margin = 6
	row(t, L("xp-ratio"), {"rpg-stats.percent", math.floor(RatioXP(player) * 100)}, L("xp-ratio-tooltip"))
	row(t, L("deaths"), fmt.int(px.Death[name] or 0))
	if character and character.valid then
		row(t, L("health"), {"", fmt.int(math.ceil(character.health)), " / ", fmt.int(character.max_health)})
	end

	c = card(lc, "[entity=small-biter]", L("card-own-kills"), L("card-own-kills-tooltip"))
	t = rows(c)
	local units = storage.personal_kill_units[name] or 0
	local spawners = storage.personal_kill_spawner[name] or 0
	local worms = storage.personal_kill_turrets[name] or 0
	row(t, L("kills-units"), fmt.int(units))
	row(t, L("kills-spawners"), fmt.int(spawners))
	row(t, L("kills-worms"), fmt.int(worms))
	row(t, L("kills-total"), fmt.int(units + spawners + worms))

	c = card(lc, "[virtual-signal=signal-info]", L("card-commands"))
	label(c, L("commands"), {wrap = LY.inner_w})

	c = card(rc, "[virtual-signal=signal-heart]", L("card-skills"), L("card-skills-tooltip"))
	label(c, L("skills-points", points), {color = points > 0 and ORANGE or MUTED, wrap = LY.inner_w}).style.bottom_margin = 4
	skills(player, c, points)
	local cb = c.add{type = "checkbox", name = "cb_pick_extender", caption = {"xp_opt_Pick_Extender"},
		state = px.opt_Pick_Extender[name] or false}
	cb.style.top_margin = 8

	c = card(rc, "[virtual-signal=signal-map-marker]", since(L("card-journeys")), since_tooltip("since_move"))
	t = rows(c)
	row(t, L("walked"), fmt.km(p.walk))
	row(t, L("driven"), fmt.km(p.drive), L("driven-tooltip"))
	row(t, L("by-rail"), fmt.km(p.rail))
	row(t, L("farthest-self"), fmt.km(p.far), L("farthest-self-tooltip"))

	c = card(rc, "[virtual-signal=signal-skull]", since(L("card-deaths")), since_tooltip())
	t = rows(c)
	local any = false
	for _, k in ipairs(data.DEATH_CAUSES) do
		local n = p.deaths_by[k] or 0
		if n > 0 then any = true row(t, L("death-" .. k), fmt.int(n)) end
	end
	if not any then muted(c, L("deaths-none")) end

	c = card(rc, "[item=iron-gear-wheel]", since(L("card-hands")), since_tooltip())
	t = rows(c)
	row(t, L("crafted"), fmt.int(p.crafted))
	local best, bn = nil, 0
	for item, n in pairs(p.crafted_items) do
		if n > bn or (n == bn and best and item < best) then best, bn = item, n end
	end
	if best then row(t, L("crafted-top"), {"", item_name(best), "  ", fmt.int(bn)}) end
	row(t, L("trees"), fmt.int(p.trees))
	row(t, L("rocks"), fmt.int(p.rocks))
end

-- Passport ----------------------------------------------------------------------------------

local function passport_tiles(sn)
	local q, k, ru = sn.quality, sn.kills, sn.ruins
	return {
		{"item/assembling-machine-1", fmt.int(sn.built), L("pass-built")},
		{"item/radar", fmt.int(sn.charted), L("pass-chunks", fmt.dec(sn.charted * 1024 / 1e6))},
		{"item/lab", {"rpg-stats.percent", fmt.int(tech_pct(sn))}, L("pass-tech")},
		{"item/automation-science-pack", fmt.dec(sn.spm or 0), L("pass-spm")},
		{"item/steam-engine", fmt.power(sn.power.now), L("pass-power")},
		{"item/iron-gear-wheel", fmt.short(sn.items_made), L("pass-items")},
		{"virtual-signal/signal-star", q.best and quality_name(q.best[1]) or L("dash"), L("pass-quality")},
		{"item/repair-pack", q.control and fmt.pct(q.defects, q.defectable) or L("dash"),
			q.control and L("pass-defects", q.control) or L("defects-off-short")},
		{"virtual-signal/signal-map-marker", ru and {"", fmt.int(ru.found_types or 0), " / ", fmt.int(ru.total_types or 0)} or L("dash"), L("pass-ruins")},
		{"entity/small-biter", fmt.short(k.units + k.spawners + k.worms), L("pass-kills")},
		{"virtual-signal/signal-skull", sn.evolution and fmt.pct(sn.evolution.total, 1) or L("dash"), L("pass-evolution")},
		{"item/pipe", sn.machines > 0 and fmt.dec((sn.belts_m + sn.pipes_m) / sn.machines) or L("dash"), L("pass-macaroni")},
	}
end

local function build_info()
	local mods = 0
	for _ in pairs(script.active_mods) do mods = mods + 1 end
	local function on(name) return script.active_mods[name] and "✓" or "✗" end
	local planet = game.surfaces["nauvis"]
	return L("build-info", script.active_mods["zzzparanoidal"] or "?", script.active_mods["base"] or "?",
		on("quality"), on("elevated-rails"), on("space-age"), fmt.int(mods),
		planet and tostring(planet.map_gen_settings.seed) or "?")
end

local function days_of(sn) return sn.day and sn.day.days or 0 end

local function passport_text(player, sn)
	local lines = {
		L("text-title", player.force.name, #player.force.players),
		L("text-status", L("status-" .. sn.status), fmt.hm(game.tick)),
	}
	for _, t in ipairs(passport_tiles(sn)) do
		lines[#lines + 1] = {"", t[3], ": ", t[2]}
	end
	local ms = reached_list(data.force(player.force.index))
	for i = math.max(1, #ms - 5), #ms do
		local e = ms[i]
		if e then lines[#lines + 1] = {"", (ms_time(e.rec)), "  ", milestone_text(e.id, e.rec)} end
	end
	lines[#lines + 1] = build_info()
	-- a localised string takes at most 20 parameters: nest the lines in groups
	local groups, cur = {""}, {""}
	for _, line in ipairs(lines) do
		if #cur >= 19 then groups[#groups + 1] = cur cur = {""} end
		cur[#cur + 1] = line
		cur[#cur + 1] = "\n"
	end
	groups[#groups + 1] = cur
	return groups
end

local function status_card(page, sn, big_font)
	local c = card(page)
	label(c, {"", "«", L("status-" .. sn.status), "»"}, {font = big_font or "charxpmod_font_30", color = ORANGE,
		wrap = LY.inner_w, tooltip = L("status-tooltip")})
	return c
end

local function goal(c, sn)
	label(c, goal_text(sn.status), {wrap = LY.inner_w}).style.top_margin = 4
	if (sn.tier_total or 0) > 0 then
		bar(c, sn.tier_done / sn.tier_total, ORANGE)
		muted(c, L("tier-progress", fmt.int(sn.tier_done), fmt.int(sn.tier_total)))
	end
end

local function minimap_card(player, page, height)
	local planet = game.surfaces["nauvis"]
	if not planet then return end
	local c = card(page, "[item=radar]", L("card-minimap"), L("card-minimap-tooltip"))
	local st = data.player(player.index)
	local size = math.min(LY.inner_w, height or 400)
	local mm = c.add{type = "minimap", surface_index = planet.index, position = player.force.get_spawn_position(planet),
		zoom = st.zoom, force = player.force.name, chart_player_index = player.index}
	mm.style.width = size
	mm.style.height = size
	local zf = c.add{type = "flow", direction = "horizontal"}
	zf.style.top_margin = 4
	zf.style.vertical_align = "center"
	zf.add{type = "button", name = "rpgst_zoom_out", caption = "−", style = "tool_button", tooltip = L("zoom-out"), tags = {dir = -1}}
	zf.add{type = "button", name = "rpgst_zoom_in", caption = "+", style = "tool_button", tooltip = L("zoom-in"), tags = {dir = 1}}
	muted(zf, L("minimap-hint"), LY.inner_w - 80)
end

function R.passport(player, lc, rc, sn)
	local f = data.force(player.force.index)
	local c = status_card(lc, sn)
	muted(c, L("pass-head", player.force.name, #player.force.players))
	muted(c, L("pass-sub", fmt.hm(game.tick), fmt.int(days_of(sn)), fmt.int(storage.personalxp.Level[player.name] or 1)))
	goal(c, sn)

	local tiles = lc.add{type = "table", column_count = 2}
	tiles.style.horizontal_spacing = 8
	tiles.style.vertical_spacing = 8
	local tile_w = math.floor((LY.card_w - 8) / 2)
	local text_w = tile_w - 16 - 32 - 8
	for _, t in ipairs(passport_tiles(sn)) do
		local tile = tiles.add{type = "frame", style = "deep_frame_in_shallow_frame", direction = "horizontal"}
		tile.style.width = tile_w
		tile.style.padding = {6, 8, 6, 8}
		tile.style.vertical_align = "center"
		local s = tile.add{type = "sprite", sprite = t[1], resize_to_sprite = false}
		s.style.width = 32
		s.style.height = 32
		s.style.stretch_image_to_widget_size = true
		s.style.right_margin = 8
		local v = tile.add{type = "flow", direction = "vertical"}
		v.style.vertical_spacing = 0
		label(v, t[2], {font = "default-large-bold", wrap = text_w})
		label(v, t[3], {color = MUTED, font = "default-small", wrap = text_w})
	end
	muted(lc, build_info(), LY.card_w)

	minimap_card(player, rc, 300)
	local ms = reached_list(f)
	c = card(rc, "[virtual-signal=signal-check]", L("last-milestones"))
	if #ms == 0 then muted(c, L("nothing-yet")) end
	local t = c.add{type = "table", column_count = 2}
	t.style.horizontal_spacing = 10
	for i = math.max(1, #ms - 7), #ms do
		local e = ms[i]
		local time, tip = ms_time(e.rec)
		label(t, time, {font = "default-bold", color = ORANGE, width = 90, tooltip = tip})
		label(t, milestone_text(e.id, e.rec), {wrap = LY.inner_w - 100})
	end
	c = card(rc, "[img=utility/copy]", L("card-text"))
	label(c, L("card-text-hint"), {color = MUTED, wrap = LY.inner_w})
	c.add{type = "button", name = "rpgst_pass_text", caption = L("as-text"), tooltip = L("as-text-tooltip")}.style.top_margin = 4
	local box = c.add{type = "text-box", name = "rpgst_pass_box"}
	box.visible = false
	box.read_only = true
	box.word_wrap = true
	box.style.width = LY.inner_w
	box.style.height = 200
	box.style.top_margin = 6
end

-- Base ----------------------------------------------------------------------------------------

function R.base(player, lc, rc, sn)
	local c = status_card(lc, sn)
	local ladder = c.add{type = "table", column_count = 3}
	ladder.style.horizontal_spacing = 12
	local w = math.floor((LY.inner_w - 24) / 3)
	for i = 1, #data.STATUS do
		local color = i < sn.status and TEXT or (i == sn.status and ORANGE or DIM)
		label(ladder, L("status-" .. i), {font = i == sn.status and "default-small-bold" or "default-small",
			color = color, wrap = w})
	end
	goal(c, sn)

	c = card(lc, "[item=iron-gear-wheel]", L("card-production"), L("card-production-tooltip"))
	local t = rows(c)
	row(t, L("items-made"), fmt.short(sn.items_made))
	row(t, L("items-used"), fmt.short(sn.items_used))
	row(t, L("items-pace"), fmt.short(sn.items_made / (hours(sn.tick) * 60)), L("items-pace-tooltip"))
	row(t, L("fluids-made"), fmt.short(sn.fluids_made))
	row(t, L("fluids-used"), fmt.short(sn.fluids_used))
	row(t, L("built"), fmt.int(sn.built))
	row(t, L("mined"), fmt.int(sn.mined))
	row(t, L("build-pace"), fmt.int(sn.built / hours(sn.tick)), L("build-pace-tooltip"))
	row(t, L("rockets"), fmt.int(sn.rockets))

	c = card(lc, "[item=lab]", L("card-research"))
	t = rows(c)
	row(t, L("tech-done"), {"", fmt.int(sn.tech_done), " / ", fmt.int(sn.tech_total), "  (", fmt.pct(sn.tech_done, sn.tech_total), ")"})
	bar(c, sn.tech_total > 0 and sn.tech_done / sn.tech_total or 0, BLUE)
	t = rows(c)
	row(t, L("recipes"), fmt.int(sn.recipes))
	row(t, L("science-total"), fmt.short(sn.science_total), L("science-tooltip"))
	row(t, L("spm"), fmt.dec(sn.spm or 0), L("spm-tooltip"))
	if #sn.science > 0 then
		local pt = c.add{type = "table", column_count = 3}
		pt.style.horizontal_spacing = 8
		pt.style.top_margin = 4
		local num_w = 80
		local name_w = LY.inner_w - 2 * num_w - 16
		label(pt, L("pack"), {font = "default-small-bold", color = MUTED, width = name_w})
		label(pt, L("pack-made"), {font = "default-small-bold", color = MUTED, width = num_w, align = "right"})
		label(pt, L("pack-spm"), {font = "default-small-bold", color = MUTED, width = num_w, align = "right"})
		for _, s in ipairs(sn.science) do
			label(pt, item_name(s[1]), {wrap = name_w, width = name_w})
			label(pt, fmt.short(s[2]), {width = num_w, align = "right"})
			label(pt, fmt.dec(s[3] or 0), {width = num_w, align = "right"})
		end
	end
	t = rows(c)
	t.style.top_margin = 4
	if sn.tech_top then row(t, L("tech-top"), tech_name(sn.tech_top), L("tech-top-tooltip")) end
	if sn.research then
		row(t, L("research-now"), {"", tech_name(sn.research), "  ", fmt.pct(sn.research_progress or 0, 1)})
	end

	c = card(rc, "[item=steam-engine]", L("card-power"), L("card-power-tooltip"))
	local p = sn.power
	if p.networks == 0 and p.now == 0 then
		muted(c, L("power-none"))
	else
		bigs(c, {
			{L("power-now"), fmt.power(p.now), ORANGE},
			{L("power-hour"), fmt.power(p.hour)},
			{L("power-peak"), fmt.power(p.peak or p.now), nil, L("power-peak-tooltip")},
		})
		t = rows(c)
		row(t, L("power-networks"), fmt.int(p.networks))
		if #p.sources > 0 then
			muted(c, L("power-sources")).style.top_margin = 4
			t = rows(c)
			for _, src in ipairs(p.sources) do
				row(t, entity_name(src[1]), {"", fmt.power(src[2]), "  (", fmt.pct(src[2], p.now), ")"})
			end
		end
		if #(p.consumers or {}) > 0 then
			muted(c, L("power-consumers")).style.top_margin = 4
			t = rows(c)
			for _, e in ipairs(p.consumers) do row(t, entity_name(e[1]), fmt.power(e[2])) end
		end
	end

	c = card(rc, "[item=transport-belt]", L("card-logistics"), L("card-logistics-tooltip"))
	t = rows(c)
	row(t, L("belts"), fmt.km(sn.belts_m), L("belts-tooltip"))
	row(t, L("pipes"), fmt.km(sn.pipes_m), L("pipes-tooltip"))
	local r = sn.robots
	row(t, L("robots-logistic"), L("of-free", fmt.int(r.logistic), fmt.int(r.logistic_free)))
	row(t, L("robots-construction"), L("of-free", fmt.int(r.construction), fmt.int(r.construction_free)))
	row(t, L("logistic-networks"), fmt.int(r.networks))
	local tr = sn.trains
	row(t, L("trains"), fmt.int(tr.trains))
	row(t, L("locomotives-wagons"), {"", fmt.int(tr.locomotives), " / ", fmt.int(tr.wagons)})
	row(t, L("train-stops"), fmt.int(tr.stops))
	row(t, L("rails"), fmt.int(sn.rails))
	row(t, L("poles"), fmt.int(sn.poles))

	c = card(rc, "[item=wooden-chest]", L("card-top-buildings"), L("standing-tooltip"))
	if #sn.top_buildings == 0 then muted(c, L("nothing-yet")) end
	t = rows(c)
	for _, e in ipairs(sn.top_buildings) do row(t, entity_name(e[1]), fmt.int(e[2])) end

	c = card(rc, "[item=iron-plate]", L("card-top-items"), L("card-top-items-tooltip"))
	if #(sn.top_items or {}) == 0 then muted(c, L("nothing-yet")) end
	t = rows(c)
	for _, e in ipairs(sn.top_items or {}) do row(t, item_name(e[1]), fmt.short(e[2])) end

	c = card(rc, "[item=pipe]", L("card-indices"), L("card-indices-tooltip"))
	local m = sn.machines
	local function index(value)
		if m <= 0 then return L("dash") end
		return fmt.dec(value / m)
	end
	bigs(c, {
		{L("index-macaroni"), index(sn.belts_m + sn.pipes_m), ORANGE, L("index-macaroni-tooltip")},
		{L("index-paranoia"), index(sn.walls + sn.turrets), ORANGE, L("index-paranoia-tooltip")},
		{L("index-chests"), index(sn.chests), ORANGE, L("index-chests-tooltip")},
	})
	t = rows(c)
	row(t, L("machines"), fmt.int(m), L("machines-tooltip"))
	row(t, L("walls-turrets"), {"", fmt.int(sn.walls), " / ", fmt.int(sn.turrets)})
	row(t, L("chests"), fmt.int(sn.chests))
end

-- World -------------------------------------------------------------------------------------

function R.world(player, lc, rc, sn)
	local c = card(lc, "[item=radar]", L("card-map"), L("card-map-tooltip"))
	bigs(c, {
		{L("chunks-charted"), fmt.int(sn.charted), ORANGE},
		{L("area"), {"rpg-stats.km2", fmt.dec(sn.charted * 1024 / 1e6)}},
	})
	muted(c, L("football", fmt.int(sn.charted * 1024 / 7140)))
	local t = rows(c)
	t.style.top_margin = 4
	row(t, L("chunks-generated"), fmt.int(sn.generated), L("chunks-generated-tooltip"))
	row(t, L("chunks-share"), fmt.pct(sn.charted, sn.generated))
	bar(c, sn.generated > 0 and sn.charted / sn.generated or 0, GREEN)
	t = rows(c)
	row(t, L("farthest"), fmt.km(sn.far_m), L("farthest-tooltip"))
	row(t, L("footprint"), fmt.int(sn.footprint or 0), L("footprint-tooltip"))
	row(t, L("radars"), fmt.int(sn.radars))
	if sn.day then
		row(t, L("daytime"), sn.day.frozen and L("daytime-frozen", clock(sn.day.time)) or clock(sn.day.time))
		row(t, L("days"), fmt.int(sn.day.days), L(sn.day.calendar and "days-calendar-tooltip" or "days-tooltip"))
		if sn.day.year then
			row(t, L("year"), L("year-value", fmt.int(sn.day.year), fmt.int(sn.day.day_of_year), fmt.int(sn.day.period)),
				L("year-tooltip"))
		end
		if sn.day.season then
			local ok, name = pcall(remote.call, "NightBrightness", "get_season_name", sn.day.season, player.index)
			row(t, L("season"), L("season-value", ok and name or sn.day.season, fmt.int(sn.day.season_day or 1),
				fmt.int(sn.day.season_length or 1)))
		end
	end

	minimap_card(player, lc, 420)

	c = card(rc, "[virtual-signal=signal-skull]", L("card-ruins"), L("card-ruins-tooltip"))
	local ru = sn.ruins
	if not ru then
		muted(c, L("ruins-none"))
	else
		t = rows(c)
		row(t, L("ruins-types"), {"", fmt.int(ru.found_types or 0), " / ", fmt.int(ru.total_types or 0)})
		bar(c, (ru.total_types or 0) > 0 and (ru.found_types or 0) / ru.total_types or 0, GREEN)
		t = rows(c)
		for _, size in ipairs({"small", "medium", "large"}) do
			local s = ru.sizes and ru.sizes[size]
			if s then row(t, L("ruins-" .. size), {"", fmt.int(s.found), " / ", fmt.int(s.total)}) end
		end
		row(t, L("ruins-visits"), fmt.int(ru.found_total or 0), L("ruins-visits-tooltip"))
		if (ru.legendary_found or 0) > 0 then
			row(t, L("ruins-legendary"), L("legendary-value", fmt.int(ru.legendary_found), fmt.int(ru.legendary_total or 0),
				fmt.int(ru.legendary_solved or 0)))
		else
			row(t, L("ruins-legendary"), L("legendary-none"))
		end
	end

	c = card(rc, "[item=iron-ore]", L("card-resources"), L("card-resources-tooltip"))
	t = rows(c)
	row(t, L("ore-total"), fmt.short(sn.ore_total))
	for _, e in ipairs(sn.top_ores) do
		row(t, item_name(e[1]), {"", fmt.short(e[2]), "  (", fmt.pct(e[2], sn.ore_total), ")"})
	end
	row(t, L("fluid-resources"), fmt.short(sn.fluid_resources))
	if sn.wood then row(t, L("wood"), fmt.short(sn.wood), L("wood-tooltip")) end
	if sn.fish then row(t, L("fish"), fmt.short(sn.fish)) end
	row(t, since(L("depleted")), fmt.int(sn.depleted), since_tooltip())
end

-- War ---------------------------------------------------------------------------------------

local function share_card(page, counts, keys, prefix)
	local total = 0
	for _, k in ipairs(keys) do total = total + (counts[k] or 0) end
	if total == 0 then
		muted(page, L("nothing-since"))
		return
	end
	local list = {}
	for _, k in ipairs(keys) do
		if (counts[k] or 0) > 0 then list[#list + 1] = {key = k, n = counts[k], bar = counts[k]} end
	end
	table.sort(list, function(a, b) return a.n > b.n end)
	bar_rows(page, list, RED, function(e) return L(prefix .. e.key) end,
		function(e) return {"", fmt.int(e.n), "  (", fmt.pct(e.n, total), ")"} end)
end

local function leaderboard(player, page)
	local c = card(page, "[virtual-signal=signal-star]", L("card-board"), L("card-board-tooltip"))
	local players = {}
	for _, p in pairs(player.force.players) do players[#players + 1] = p end
	local px = storage.personalxp
	local function lvl(p) return px.Level[p.name] or 1 end
	table.sort(players, function(a, b)
		if lvl(a) ~= lvl(b) then return lvl(a) > lvl(b) end
		return (px.XP[a.name] or 0) > (px.XP[b.name] or 0)
	end)
	local cols = {"board-player", "board-level", "board-time", "board-deaths", "board-kills", "board-walked"}
	local tb = c.add{type = "table", column_count = #cols, draw_horizontal_line_after_headers = true}
	tb.style.horizontal_spacing = 8
	local name_w = math.floor(LY.inner_w * 0.3)
	local col_w = math.floor((LY.inner_w - name_w - 8 * (#cols - 1)) / (#cols - 1))
	for i, h in ipairs(cols) do
		local w = i == 1 and name_w or col_w
		label(tb, L(h), {font = "default-small-bold", color = ORANGE, width = w, wrap = w, align = i == 1 and "left" or "right"})
	end
	local s = storage.rpg_stats
	for i, p in ipairs(players) do
		local name = p.name
		local kills = (storage.personal_kill_units[name] or 0) + (storage.personal_kill_spawner[name] or 0)
			+ (storage.personal_kill_turrets[name] or 0)
		local mark = i <= 3 and ({"[virtual-signal=signal-1] ", "[virtual-signal=signal-2] ", "[virtual-signal=signal-3] "})[i] or ""
		label(tb, mark .. name, {width = name_w, wrap = name_w, font = p.connected and "default-bold" or nil})
		local st = s.players[p.index]
		for _, v in ipairs({fmt.int(lvl(p)), fmt.hm(p.online_time), fmt.int(px.Death[name] or 0), fmt.short(kills),
			fmt.km(st and st.walk or 0)}) do
			label(tb, v, {width = col_w, align = "right"})
		end
	end
end

function R.war(player, lc, rc, sn)
	local k = sn.kills
	local total = k.units + k.spawners + k.worms
	local c = card(lc, "[entity=small-biter]", L("card-kills"), L("card-kills-tooltip"))
	bigs(c, {
		{L("kills-total"), fmt.int(total), ORANGE},
		{L("kills-pace"), fmt.int(total / hours(sn.tick)), nil, L("kills-pace-tooltip")},
	})
	local t = rows(c)
	row(t, L("kills-units"), fmt.int(k.units))
	row(t, L("kills-spawners"), fmt.int(k.spawners))
	row(t, L("kills-worms"), fmt.int(k.worms))
	row(t, L("ammo-used"), fmt.short(sn.ammo_used or 0), L("ammo-used-tooltip"))
	if #sn.top_killed > 0 then
		muted(c, L("kills-top")).style.top_margin = 4
		t = rows(c)
		for _, e in ipairs(sn.top_killed) do row(t, entity_name(e[1]), fmt.int(e[2])) end
	end

	c = card(lc, "[item=gun-turret]", since(L("card-weapons")), since_tooltip())
	share_card(c, data.force(player.force.index).kills_by, data.KILL_CAUSES, "cause-")

	c = card(rc, "[item=stone-wall]", L("card-losses"), L("card-losses-tooltip"))
	t = rows(c)
	row(t, L("lost-total"), fmt.int(sn.lost))
	for _, e in ipairs(sn.top_lost) do row(t, entity_name(e[1]), fmt.int(e[2])) end

	if sn.evolution then
		local e = sn.evolution
		c = card(rc, "[virtual-signal=signal-skull]", L("card-evolution"), L("card-evolution-tooltip"))
		t = rows(c)
		row(t, L("evolution"), fmt.pct(e.total, 1))
		bar(c, e.total, RED)
		local parts = {{"evo-time", e.time}, {"evo-pollution", e.pollution}, {"evo-spawners", e.spawners}}
		local any = false
		for _, part in ipairs(parts) do if part[2] > 0 then any = true end end
		if any then
			t = rows(c)
			for _, part in ipairs(parts) do row(t, L(part[1]), fmt.pct(part[2], 1)) end
		end
		if e.by_research then muted(c, L("evo-research")).style.top_margin = 4 end
	end
	if sn.pollution then
		c = card(rc, "[item=stone-furnace]", L("card-pollution"), L("card-pollution-tooltip"))
		t = rows(c)
		row(t, L("pollution-now"), fmt.short(sn.pollution.now or 0), L("pollution-now-tooltip"))
		row(t, L("pollution-emitted"), fmt.short(sn.pollution.emitted))
		row(t, L("pollution-absorbed"), fmt.short(sn.pollution.absorbed))
		if #sn.pollution.top > 0 then
			muted(c, L("polluters")).style.top_margin = 4
			t = rows(c)
			for _, e in ipairs(sn.pollution.top) do row(t, entity_name(e[1]), fmt.short(e[2])) end
		end
	end
	leaderboard(player, rc)
end

-- Quality -------------------------------------------------------------------------------------

function R.quality(player, lc, rc, sn)
	local q = sn.quality
	local c = card(lc)
	muted(c, L("best-quality"))
	if q.best then
		local proto = prototypes.quality[q.best[1]]
		label(c, quality_name(q.best[1]), {font = "charxpmod_font_30", color = proto and proto.color, wrap = LY.inner_w})
		muted(c, L("best-quality-count", fmt.int(q.best[2])))
	else
		label(c, L("best-quality-none"), {font = "default-large-bold", wrap = LY.inner_w})
	end

	c = card(lc, "[virtual-signal=signal-star]", L("card-quality-split"), L("card-quality-split-tooltip"))
	if #q.list == 0 then muted(c, L("nothing-yet")) end
	local list = {}
	for _, e in ipairs(q.list) do
		local proto = prototypes.quality[e[1]]
		list[#list + 1] = {name = e[1], n = e[2], bar = math.log(e[2] + 1), color = proto and proto.color, font = "default-small"}
	end
	bar_rows(c, list, nil, function(e) return quality_name(e.name) end, function(e) return fmt.short(e.n) end)

	c = card(rc, "[item=repair-pack]", L("card-defects"), L("card-defects-tooltip"))
	if not q.control then
		muted(c, L("defects-off"))
	else
		bigs(c, {
			{L("defects-made"), fmt.short(q.defects), RED},
			{L("defects-share"), fmt.pct(q.defects, q.defectable)},
		})
		local t = rows(c)
		row(t, L("defectable-made"), fmt.short(q.defectable), L("defectable-tooltip"))
		row(t, L("control-level"), {"", fmt.int(q.control), " / 10"})
		bar(c, q.control / 10, BLUE)
		local w = q.workshop
		if w then
			t = rows(c)
			row(t, L("workshop-attempts"), fmt.int(w["refine.attempts"] or 0))
			row(t, L("workshop-success"), {"", fmt.int(w["refine.success"] or 0), "  (",
				fmt.pct(w["refine.success"] or 0, w["refine.attempts"] or 0), ")"})
			row(t, L("workshop-resets"), fmt.int(w["refine.resets"] or 0))
		end
	end
	c = card(rc, "[item=electronic-circuit]", L("card-positive"))
	local t = rows(c)
	row(t, L("positive-made"), fmt.short(q.positive))
	row(t, L("positive-share"), fmt.pct(q.positive, sn.items_made))
end

-- Milestones -------------------------------------------------------------------------------

function R.milestones(player, lc, rc)
	local f = data.force(player.force.index)
	local list = reached_list(f)
	local c = card(lc, "[virtual-signal=signal-check]", L("card-milestones", #list), L("card-milestones-tooltip"))
	if #list == 0 then muted(c, L("nothing-yet")) end
	local t = c.add{type = "table", column_count = 2}
	t.style.horizontal_spacing = 10
	t.style.vertical_spacing = 4
	local time_w = 90
	for _, e in ipairs(list) do
		local time, tip = ms_time(e.rec)
		label(t, time, {font = "default-bold", color = ORANGE, width = time_w, tooltip = tip})
		local text = milestone_text(e.id, e.rec)
		if e.rec.player then text = {"", text, "  [color=0.6,0.6,0.6]", e.rec.player, "[/color]"} end
		label(t, text, {wrap = LY.inner_w - time_w - 10})
	end

	local pending = {}
	for _, id in ipairs(data.MILESTONE_ORDER) do
		if not f.milestones[id] and data.milestone_available(id) then pending[#pending + 1] = milestone_text(id) end
	end
	for _, pack in ipairs(data.KEY_PACKS) do
		if not f.milestones["pack:" .. pack] and prototypes.item[pack] then pending[#pending + 1] = milestone_text("pack:" .. pack) end
	end
	c = card(rc, "[img=utility/clock]", L("card-pending", #pending))
	if #pending == 0 then muted(c, L("pending-none")) end
	for _, text in ipairs(pending) do label(c, text, {color = MUTED, wrap = LY.inner_w}) end

	c = card(rc, "[item=lab]", L("card-pace"))
	t = rows(c)
	row(t, L("map-time"), fmt.hm(game.tick))
	local exact = {}
	for _, e in ipairs(list) do if e.rec.tick then exact[#exact + 1] = e end end
	local last = list[#list]
	if last then
		local time = ms_time(last.rec)
		row(t, L("last-milestone"), {"", milestone_text(last.id, last.rec), ", ", time})
	end
	row(t, L("milestones-exact"), fmt.int(#exact), L("milestones-exact-tooltip"))
	if #list >= 2 then
		local span = data.record_tick(list[#list].rec) - data.record_tick(list[1].rec)
		row(t, L("milestones-gap"), fmt.hm(span / (#list - 1)), L("milestones-gap-tooltip"))
	end
end

-- Codex -------------------------------------------------------------------------------------

function R.codex(player, lc, rc)
	local st = data.player(player.index)
	local c = card(lc, "[virtual-signal=signal-info]", L("card-contents"))
	for i, id in ipairs(ARTICLES) do
		local b = c.add{type = "button", name = "rpgst_art_" .. id, tags = {art = i}, caption = L("codex-" .. id .. "-title")}
		b.style.width = LY.inner_w
		b.style.horizontal_align = "left"
		b.toggled = (i == st.art)
	end
	muted(c, L("codex-intro")).style.top_margin = 6
	local id = ARTICLES[st.art] or ARTICLES[1]
	c = card(rc)
	label(c, L("codex-" .. id .. "-title"), {font = "default-large-bold", color = ORANGE, wrap = LY.inner_w})
	label(c, L("codex-" .. id .. "-text"), {wrap = LY.inner_w}).style.top_margin = 6
end

---------------------------------------------------------------------------------------------
-- rendering

local function new_content(page)
	local scroll = page.scroll
	scroll.clear()
	local content = scroll.add{type = "flow", name = "content", direction = "vertical"}
	content.style.vertical_spacing = 8
	return content
end

function G.render(player)
	local frame = window(player)
	if not (frame and frame.rpgst_body) then return end
	LY = measure(player)
	local st = data.player(player.index)
	local body = frame.rpgst_body
	for _, b in pairs(body.nav.buttons.children) do
		b.toggled = (b.tags.tab == st.tab)
	end
	render_summary(player, body.nav.summary)
	local pages = body.book.pages
	local lc = new_content(pages.left)
	local rc = LY.single and lc or new_content(pages.right)
	local sn
	if NEEDS_SNAPSHOT[st.tab] then
		if not data.player_force(player.force) then
			render_head(player, body.book.head, st.tab)
			muted(lc, L("sandbox"), LY.card_w)
			return
		end
		data.request(player.force)
		sn = snapshot(player)
	end
	render_head(player, body.book.head, st.tab, sn)
	if NEEDS_SNAPSHOT[st.tab] and not sn then
		muted(lc, L("first-count"), LY.card_w)
		return
	end
	R[st.tab](player, lc, rc, sn)
end

function G.open(player, tab)
	local st = data.player(player.index)
	if tab then st.tab = tab end
	if st.tab ~= "char" then st.stats_tab = st.tab end
	local old = player.gui.screen[OLD_PASSPORT]
	if old then old.destroy() end
	LY = measure(player)
	local frame = window(player)
	if frame then
		local tags = frame.tags or {}
		if tags.shell ~= SHELL or tags.w ~= LY.win_w or tags.h ~= LY.win_h then
			frame.destroy()
			frame = nil
		end
	end
	frame = frame or build_shell(player)
	G.render(player)
	if player.opened ~= frame then player.opened = frame end
end

function G.close(player)
	local frame = window(player)
	if frame then frame.destroy() end
end

-- Experience changed: on the character pages update the numbers in place (the scroll position
-- stays); a new level changes points and buttons, so then the pages are redrawn.
function G.refresh_char(player)
	local frame = window(player)
	if not (frame and frame.rpgst_body) then return end
	if data.player(player.index).tab ~= "char" then return end
	local page = frame.rpgst_body.book.pages.left
	local level_label = find(page, "rpgst_level")
	local level = xp_state(player)
	if not level_label or (level_label.tags or {}).level ~= level then
		G.render(player)
		return
	end
	LY = measure(player)
	local xp_text, xp_left, xp_bar = xp_texts(player)
	local e = find(page, "rpgst_xp_text")
	if e then e.caption = xp_text end
	e = find(page, "rpgst_xp_left")
	if e then e.caption = xp_left end
	e = find(page, "rpgst_xp_bar")
	if e then e.value = math.max(0, math.min(1, xp_bar)) end
	e = find(page, "rpgst_time")
	if e then e.caption = L("played", fmt.time(player.online_time)) end
end

local function show_text(player)
	local frame = window(player)
	local box = frame and find(frame, "rpgst_pass_box")
	if not box then return end
	if box.visible then box.visible = false return end
	local sn = snapshot(player)
	if not sn then return end
	box.visible = true
	box.text = ""
	data.player(player.index).translation = player.request_translation(passport_text(player, sn))
end

function G.on_translated(event)
	local s = storage.rpg_stats
	local st = s and s.players[event.player_index]
	if not (st and st.translation and st.translation == event.id) then return end
	st.translation = nil
	local player = game.get_player(event.player_index)
	local frame = player and window(player)
	local box = frame and find(frame, "rpgst_pass_box")
	if box and event.translated then
		box.text = event.result
		box.focus()
		box.select_all()
	end
end

---------------------------------------------------------------------------------------------
-- events

-- Snapshot finished: refresh what players of that force are looking at.
function G.on_snapshot(force_index)
	local force = game.forces[force_index]
	if not force then return end
	for _, player in pairs(force.connected_players) do
		local frame = window(player)
		local st = storage.rpg_stats.players[player.index]
		if frame and frame.rpgst_body and st then
			if st.tab ~= "char" then
				G.render(player)
			else
				LY = measure(player)
				render_summary(player, frame.rpgst_body.nav.summary)
			end
		end
		if script.active_mods["GUI_Unifyer"] then
			local button = mod_gui.get_button_flow(player).btcharxp
			local sn = snapshot(player)
			if button and sn then
				button.tooltip = {"", {"panel-title", player.name}, "\n", L("button-summary", L("status-" .. sn.status),
					fmt.int(sn.charted), fmt.int(tech_pct(sn)))}
			end
		end
	end
end

-- The chat adds "[Item: name]" after every [item=...]-like tag; [img=type/name] shows the icon only.
local CHAT_ICON_TYPES = {item = true, entity = true, technology = true, recipe = true, fluid = true,
	["virtual-signal"] = true}

local function chat_icons(value)
	if type(value) == "string" then
		return (value:gsub("%[([%a%-]+)=([^%],]+)%]", function(kind, name)
			if CHAT_ICON_TYPES[kind] then return "[img=" .. kind .. "/" .. name .. "]" end
		end))
	elseif type(value) == "table" then
		local copy = {}
		for k, v in pairs(value) do copy[k] = chat_icons(v) end
		return copy
	end
	return value
end

-- A milestone was reached: tell the force (each player can switch it off in the settings).
function G.announce(force, id, rec)
	for _, player in pairs(force.connected_players) do
		local setting = settings.get_player_settings(player)["charxpmod_milestone_messages"]
		if not setting or setting.value then
			local text, time = milestone_text(id, rec), (ms_time(rec))
			local msg = rec.player and L("announce-by", text, time, rec.player) or L("announce", text, time)
			player.print(chat_icons({"", "[virtual-signal=signal-check] ", msg}), {color = ORANGE})
		end
	end
end

-- Screen size or interface scale changed: rebuild an open window for the new size.
function G.on_display_changed(player)
	if window(player) then G.open(player) end
end

-- Returns true when the click belonged to the journal.
function G.on_click(event, player)
	local element = event.element
	local name = element.name
	if name:sub(1, 6) ~= "rpgst_" then return false end
	if name:sub(1, 10) == "rpgst_tab_" then
		G.open(player, element.tags.tab)
	elseif name == "rpgst_refresh" then
		data.request(player.force, true)
		G.render(player)
	elseif name == "rpgst_pass_text" then
		show_text(player)
	elseif name == "rpgst_pass_close" then
		local old = player.gui.screen[OLD_PASSPORT]
		if old then old.destroy() end
	elseif name:sub(1, 10) == "rpgst_art_" then
		data.player(player.index).art = element.tags.art
		G.render(player)
	elseif name == "rpgst_zoom_in" or name == "rpgst_zoom_out" then
		local st = data.player(player.index)
		local z = st.zoom * (element.tags.dir > 0 and 2 or 0.5)
		st.zoom = math.max(1 / 64, math.min(4, z))
		G.render(player)
	end
	return true
end

function G.on_closed(event, player)
	local element = event.element
	if element and element.valid and element.name == FRAME then
		element.destroy()
	end
end

G.FRAME = FRAME
return G
