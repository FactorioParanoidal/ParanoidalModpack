-- Premium BnL: the last bookmark of the base journal. Wishes of players and the features made for
-- them; every entry opens its feature on the right page. The first one is the calendar and alarm
-- clock asked for by Silkor (Серега).
--
-- Work outside events: one on_nth_tick(60) handler. It records the calendar day every 10 seconds
-- (one remote call, for the milestones on the calendar) and otherwise visits only the players in
-- storage.rpg_premium.watch: those with alarms, the rest reminder, the pinned window or the journal
-- open on this bookmark. Everything lives in storage, so multiplayer clients stay in sync.
local calendar = require("scripts.premium.calendar")
local SOUNDS = require("scripts.premium.sounds")
local stats = require("scripts.stats.data")

local P = {}

local VERSION = 1
local JOURNAL = "char-panel"     -- the base journal window (scripts/stats/gui.lua)
local PIN = "rpgpm_pin"
local RING = "rpgpm_ring"
local MINUTE = 3600
local NOTE_BYTES = 120           -- longer notes are cut at a character boundary
local RECENT = 4                 -- remembered notes
local MAX_ALARMS = 10
local REST_SOUND = "new-objective"
local REST_EVERY = {60, 90, 120, 180}
local PRESETS = {5, 15, 30, 60}

local ORANGE = {1, 0.77, 0.2}
local GOLD = {1, 0.84, 0.3}
local MUTED = {0.68, 0.68, 0.68}
local TEXT = {0.88, 0.88, 0.88}
local GREEN = {0.36, 0.78, 0.24}
local BLUE = {0.3, 0.6, 0.95}
local RED = {0.88, 0.3, 0.22}

local SOUND = {}
for i, s in ipairs(SOUNDS) do SOUND[s.id] = {index = i, every = s.every} end

-- Gold Card holders: the supporters of the modpack, by their display name (data, not translated). The
-- list is kept in alphabetical order and shown as is; card is the order of addition (the first holders
-- are numbered alphabetically, a new holder gets the next number). wishes: ids in WISHES.
local DONORS = {
	{card = 1, name = "3vaL"},
	{card = 2, name = "Alehandro"},
	{card = 3, name = "CoolzeT", wishes = {"coolzet"}},
	{card = 4, name = "DarkMays"},
	{card = 5, name = "Denni"},
	{card = 6, name = "FreeSiberian"},
	{card = 7, name = "GeForce RTX 4090 Aorus Elite"},
	{card = 8, name = "nomoreplay"},
	{card = 9, name = "Psyhe"},
	{card = 10, name = "Sheiny"},
	{card = 11, name = "Silkor (Серега)", wishes = {"silkor"}},
	{card = 12, name = "Svarshick_Ivan"},
	{card = 13, name = "TheWolfOW"},
	{card = 14, name = "yadergame"},
	{card = 15, name = "ИгрокСталинграда"},
	{card = 16, name = "ТРЯМ"},
}

-- Fulfilled wishes. Dates are real dates (year, month, day) of the request and of the release. feature: opened on
-- the right page by "Open" (FEATURES); without it the wish only expands to its quote and description.
-- Texts: rpg-premium.<id>-title/-quote/-text.
local WISHES = {
	coolzet = {asked = {2026, 10, 28}, done = {2026, 10, 29}, version = "9.1.0"}, -- the Codex is its own bookmark
	silkor = {asked = {2026, 11, 3}, done = {2026, 11, 6}, version = "9.2.0", feature = "calendar"},
}

local BY_CARD, DONOR_OF, WISH_IDS = {}, {}, {}
for _, d in ipairs(DONORS) do
	BY_CARD[d.card] = d
	d.wishes = d.wishes or {}
	for _, id in ipairs(d.wishes) do
		DONOR_OF[id] = d
		WISH_IDS[#WISH_IDS + 1] = id
	end
end

local LAYOUT = 2 -- 9.3.0: holders and profiles instead of a flat list; the bookmark starts closed once

local journal -- the window module, set by P.set_journal: render, open, ui helpers

-- Icon of the bookmark: the base game coin, a star if a mod removed it.
P.ICON = prototypes.item["coin"] and "[item=coin]" or "[virtual-signal=signal-star]"

local function L(key, ...) return {"rpg-premium." .. key, ...} end

---------------------------------------------------------------------------------------------
-- state

local function root()
	local s = storage.rpg_premium
	if not s then
		s = {version = VERSION, players = {}, days = {}, watch = {}, next_id = 1}
		storage.rpg_premium = s
	end
	return s
end

local function pstate(index)
	local s = root()
	local p = s.players[index]
	if not p then
		p = {view = "month", alarms = {}, notes = {}, sound = SOUNDS[1].id, volume = 80,
			hours = 0, minutes = 30, note = "", session = game.tick, rest = false, rest_every = 120,
			pin = false, pin_full = false}
		s.players[index] = p
	end
	-- The bookmark starts closed (no holder selected, no wish opened); afterwards it is remembered.
	if p.layout ~= LAYOUT then
		p.open, p.donor, p.expanded, p.sel = nil, nil, nil, nil
		p.layout = LAYOUT
	end
	return p
end

---------------------------------------------------------------------------------------------
-- time

local function planet() return game.surfaces["nauvis"] end

local function ticks_per_day()
	local surface = planet()
	return math.max(1, surface and surface.ticks_per_day or 25000)
end

-- Calendar state of NightBrightness, read once per tick at most.
local cache_tick, cache_state
local function nb_state()
	if cache_tick == game.tick then return cache_state end
	cache_tick, cache_state = game.tick, nil
	local api = remote.interfaces["NightBrightness"]
	if api and api.get_state then
		local ok, state = pcall(remote.call, "NightBrightness", "get_state")
		if ok and type(state) == "table" then cache_state = state end
	end
	return cache_state
end

-- Day index of today: midnights since the landing as counted by NightBrightness (the count the
-- journal, EvoUI and the achievements share); without it, map time in planet days.
local function today()
	local state = nb_state()
	if state and type(state.days_passed) == "number" then return state.days_passed, state end
	return math.floor(game.tick / ticks_per_day()), nil
end

-- Midnights between tick t and now at the current day length.
local function midnights_since(t)
	local surface = planet()
	local now = surface and surface.daytime or 0
	local before = now - (game.tick - t) / ticks_per_day()
	return math.floor(now - 0.5) - math.floor(before - 0.5)
end

local function poll_day()
	local s = root()
	local n = today()
	local last = s.days[#s.days]
	if not last or last.d ~= n then s.days[#s.days + 1] = {t = game.tick, d = n} end
end

-- Calendar day of a past tick and whether it is an estimate. Exact (to 10 seconds) after this
-- feature started recording days; earlier ticks are counted back from today.
local function day_of_tick(t)
	local days = root().days
	local first = days[1]
	if not first or t < first.t then
		return math.max(0, today() - midnights_since(t)), true
	end
	local lo, hi = 1, #days
	while lo < hi do
		local mid = math.floor((lo + hi + 1) / 2)
		if days[mid].t <= t then lo = mid else hi = mid - 1 end
	end
	return days[lo].d, false
end

local function clock(daytime)
	-- daytime 0 is noon and 0.5 midnight
	local minutes = math.floor(((daytime * 24 + 12) % 24) * 60)
	return string.format("%d:%02d", math.floor(minutes / 60), minutes % 60)
end

-- Ticks -> "m:ss" or "h:mm:ss".
local function countdown(ticks)
	local s = math.max(0, math.ceil(ticks / 60))
	if s >= 3600 then
		return string.format("%d:%02d:%02d", math.floor(s / 3600), math.floor(s / 60) % 60, s % 60)
	end
	return string.format("%d:%02d", math.floor(s / 60), s % 60)
end

-- Ticks -> "1 ч 05 мин" / "25 мин".
local function hours_minutes(ticks)
	local m = math.floor(ticks / MINUTE)
	if m < 60 then return L("m", m) end
	return L("hm", math.floor(m / 60), string.format("%02d", m % 60))
end

-- Ticks -> "1 мин 07 с" / "45 с" (a game day lasts a few minutes).
local function min_sec(ticks)
	local s = math.max(0, math.ceil(ticks / 60))
	if s >= 3600 then return hours_minutes(s * 60) end
	if s >= 60 then return L("dur-ms", math.floor(s / 60), string.format("%02d", s % 60)) end
	return L("dur-s", s)
end

-- Day or night on the planet: night?, daytime of the next change, ticks to it, share of the phase passed.
-- Night runs from dusk to morning, the day from morning to dusk. nil while the time is frozen.
local function phase()
	local surface = planet()
	if not surface or surface.freeze_daytime then return nil end
	local t = surface.daytime
	local dp = surface.daytime_parameters
	local night = t >= dp.dusk and t < dp.morning
	local from, to = dp.morning, dp.dusk
	if night then from, to = dp.dusk, dp.morning end
	local length = (to - from) % 1
	return night, to, ((to - t) % 1) * surface.ticks_per_day, length > 0 and ((t - from) % 1) / length or 0
end

local NIGHT_BLUE = {0.55, 0.7, 1}

local function daylight()
	local surface = planet()
	if not surface then return "" end
	local night, to, left = phase()
	if night == nil then return L("frozen") end
	return L(night and "phase-night" or "phase-day", clock(to), min_sec(left))
end

local function now_line()
	local surface = planet()
	return L("now-line", clock(surface and surface.daytime or 0))
end

local function date_text(n)
	local y, m, d = calendar.date(n)
	return L("date", d, L("month-gen-" .. m), y)
end

local function real_date(t)
	return string.format("%02d.%02d.%d", t[3], t[2], t[1])
end

-- Days between a wish and its release.
local function review_days(w)
	return calendar.index(w.done[1], w.done[2], w.done[3]) - calendar.index(w.asked[1], w.asked[2], w.asked[3])
end

local REVIEW_DAYS -- average over all wishes
do
	local sum = 0
	for _, id in ipairs(WISH_IDS) do sum = sum + review_days(WISHES[id]) end
	REVIEW_DAYS = math.floor(sum / math.max(1, #WISH_IDS) + 0.5)
end

local NORM_DAYS = 700 * 365 -- the BnL review standard

-- "Fulfilled in 1 day, 699 years and 364 days faster than the BnL standard".
local function done_tooltip(w)
	local days = review_days(w)
	local faster = NORM_DAYS - days
	return {"", L("entry-done", w.version, real_date(w.done)), "\n", L("done-joke", days, math.floor(faster / 365),
		faster % 365)}
end

local function holiday_name(id, y)
	if id == "landing" then
		if y <= 1 then return L("holiday-landing-first") end
		return L("holiday-landing", y)
	end
	return L("holiday-" .. id)
end

local function holiday_text(id)
	return L("holiday-" .. id .. "-text")
end

---------------------------------------------------------------------------------------------
-- alarms

-- Cuts text to at most max bytes without splitting a UTF-8 character.
local function cut(text, max)
	if #text <= max then return text end
	local i = max
	while i > 0 do
		local b = text:byte(i + 1)
		if not b or b < 0x80 or b >= 0xC0 then break end
		i = i - 1
	end
	return text:sub(1, i)
end

local function clean_note(text)
	text = (text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	return cut(text, NOTE_BYTES)
end

local function sort_alarms(p)
	table.sort(p.alarms, function(a, b)
		if a.at ~= b.at then return a.at < b.at end
		return a.id < b.id
	end)
end

local function remember_note(p, note)
	if note == "" then return end
	for i = #p.notes, 1, -1 do
		if p.notes[i] == note then table.remove(p.notes, i) end
	end
	table.insert(p.notes, 1, note)
	while #p.notes > RECENT do table.remove(p.notes) end
end

local function duration_minutes(p)
	return math.max(0, math.floor(p.hours or 0)) * 60 + math.max(0, math.floor(p.minutes or 0))
end

local function new_alarm(p, minutes, kind)
	local s = root()
	local id = s.next_id
	s.next_id = id + 1
	local a = {id = id, kind = kind or "alarm", set = game.tick, at = game.tick + minutes * MINUTE, minutes = minutes,
		note = kind == "rest" and "" or clean_note(p.note), sound = kind == "rest" and REST_SOUND or p.sound,
		volume = p.volume, snoozed = 0}
	p.alarms[#p.alarms + 1] = a
	sort_alarms(p)
	return a
end

local function ringing(p)
	local list = {}
	for _, a in ipairs(p.alarms) do
		if a.ringing then list[#list + 1] = a end
	end
	return list
end

local function next_alarm(p)
	for _, a in ipairs(p.alarms) do
		if not a.ringing then return a end
	end
end

local function rest_schedule(p)
	if not p.rest then p.rest_next = nil return end
	local every = p.rest_every * MINUTE
	local k = math.floor(math.max(0, game.tick - p.session) / every) + 1
	p.rest_next = p.session + k * every
end

local function journal_on_page(player)
	local frame = player.gui.screen[JOURNAL]
	if not (frame and frame.valid and frame.rpgst_body) then return false end
	return stats.player(player.index).tab == "premium"
end

local function update_watch(player, p)
	local need = #p.alarms > 0 or p.rest or p.pin or journal_on_page(player)
	root().watch[player.index] = need or nil
end

---------------------------------------------------------------------------------------------
-- small GUI helpers (windows outside the journal)

local function find(element, name)
	if element.name == name then return element end
	for _, child in pairs(element.children) do
		local found = find(child, name)
		if found then return found end
	end
end

local function add_label(parent, caption, o)
	local l = parent.add{type = "label", caption = caption, name = o and o.name, tooltip = o and o.tooltip}
	if o then
		if o.font then l.style.font = o.font end
		if o.color then l.style.font_color = o.color end
		if o.wrap then l.style.single_line = false l.style.maximal_width = o.wrap end
		if o.width then l.style.width = o.width end
	end
	return l
end

local function filler(parent)
	local f = parent.add{type = "empty-widget"}
	f.style.horizontally_stretchable = true
	return f
end

local function alarm_note(a)
	if a.kind == "rest" then return L("rest-note") end
	if a.note == "" then return L("no-note") end
	return a.note
end

-- "Rings in 1 min, at 0:04 planet time" for the time in the alarm fields.
local function preview(p)
	local minutes = duration_minutes(p)
	if minutes <= 0 then return L("preview-zero") end
	local surface = planet()
	if not surface or surface.freeze_daytime then return L("preview", hours_minutes(minutes * MINUTE)) end
	return L("preview-at", hours_minutes(minutes * MINUTE),
		clock(surface.daytime + minutes * MINUTE / math.max(1, surface.ticks_per_day)))
end

local function bar_color(left)
	if left <= MINUTE then return RED end
	if left <= 5 * MINUTE then return ORANGE end
	return BLUE
end

local function alarm_progress(a)
	local total = a.at - a.set
	if total <= 0 then return 1 end
	return math.max(0, math.min(1, (game.tick - a.set) / total))
end

---------------------------------------------------------------------------------------------
-- pinned window

local function pin_signature(p)
	local ids = {}
	if p.pin_full then
		for i, a in ipairs(p.alarms) do
			if i > 3 then break end
			ids[#ids + 1] = tostring(a.id)
		end
	end
	return (p.pin_full and "full:" or "mini:") .. table.concat(ids, ",")
end

local function build_pin(player, p)
	local old = player.gui.screen[PIN]
	if old then old.destroy() end
	local frame = player.gui.screen.add{type = "frame", name = PIN, direction = "vertical",
		tags = {sig = pin_signature(p)}}
	frame.style.padding = {4, 8, 6, 8}
	if p.pin_loc then frame.location = p.pin_loc else frame.location = {x = 300, y = 120} end
	local head = frame.add{type = "flow", name = "head", direction = "horizontal"}
	head.drag_target = frame
	head.style.vertical_align = "center"
	head.style.horizontal_spacing = 6
	add_label(head, "", {name = "date", font = "default-bold", color = ORANGE}).ignored_by_interaction = true
	add_label(head, "", {name = "mini"}).ignored_by_interaction = true
	local drag = head.add{type = "empty-widget", style = "draggable_space_header"}
	drag.style.height = 20
	drag.style.minimal_width = 16
	drag.style.horizontally_stretchable = true
	drag.drag_target = frame
	head.add{type = "sprite-button", name = "rpgpm_pin_mode", style = "frame_action_button",
		sprite = p.pin_full and "utility/collapse" or "utility/expand", tooltip = L(p.pin_full and "pin-less" or "pin-more")}
	head.add{type = "sprite-button", name = "rpgpm_pin_open", style = "frame_action_button",
		sprite = "utility/list_view", tooltip = L("pin-open")}
	head.add{type = "sprite-button", name = "rpgpm_pin_close", style = "frame_action_button",
		sprite = "utility/close", tooltip = L("pin-close")}
	if p.pin_full then
		local body = frame.add{type = "flow", name = "body", direction = "vertical"}
		body.style.vertical_spacing = 2
		body.style.width = 280
		add_label(body, "", {name = "now", color = TEXT, wrap = 280})
		add_label(body, "", {name = "session", color = MUTED})
		for i, a in ipairs(p.alarms) do
			if i > 3 then break end
			local row = body.add{type = "flow", direction = "horizontal"}
			row.style.vertical_align = "center"
			add_label(row, alarm_note(a), {width = 200})
			add_label(row, "", {name = "left_" .. a.id, font = "default-bold"})
			local pb = body.add{type = "progressbar", name = "bar_" .. a.id, value = alarm_progress(a)}
			pb.style.width = 280
		end
		if #p.alarms > 3 then add_label(body, L("pin-more-alarms", #p.alarms - 3), {color = MUTED}) end
	end
	return frame
end

local function update_pin(player, p)
	local frame = player.gui.screen[PIN]
	if not p.pin then
		if frame then frame.destroy() end
		return
	end
	if not frame or (frame.tags or {}).sig ~= pin_signature(p) then frame = build_pin(player, p) end
	local n = today()
	local head = frame.head
	head.date.caption = date_text(n)
	local a = next_alarm(p)
	if p.pin_full then
		head.mini.caption = ""
		local body = frame.body
		body.now.caption = {"", L("wd-" .. calendar.weekday(n)), " · ", n == 0 and L("landing-day") or L("since-landing", n + 1)}
		body.session.caption = L("session", hours_minutes(game.tick - p.session))
		for _, al in ipairs(p.alarms) do
			local left = body["left_" .. al.id]
			if left then left.caption = al.ringing and L("ringing") or countdown(al.at - game.tick) end
			local pb = body["bar_" .. al.id]
			if pb then
				pb.value = alarm_progress(al)
				pb.style.color = al.ringing and RED or bar_color(al.at - game.tick)
			end
		end
	elseif a then
		head.mini.caption = {"", "[img=utility/clock] ", countdown(a.at - game.tick)}
		head.mini.tooltip = alarm_note(a)
	else
		head.mini.caption = ""
	end
end

---------------------------------------------------------------------------------------------
-- ringing window

local function ring_signature(list)
	local ids = {}
	for _, a in ipairs(list) do ids[#ids + 1] = a.id .. ":" .. a.snoozed end
	return table.concat(ids, ",")
end

local function snooze_joke(n)
	if n <= 0 then return nil end
	return L("snoozed-" .. math.min(n, 4), n)
end

local function build_ring(player, p, list)
	local old = player.gui.screen[RING]
	if old then old.destroy() end
	local frame = player.gui.screen.add{type = "frame", name = RING, direction = "vertical",
		tags = {sig = ring_signature(list)}}
	frame.auto_center = true
	frame.style.padding = 12
	frame.style.minimal_width = 440
	frame.style.maximal_width = 640
	local head = frame.add{type = "flow", name = "head", direction = "horizontal"}
	head.drag_target = frame
	head.style.vertical_align = "center"
	add_label(head, L("ring-title"), {name = "title", font = "heading-1", color = ORANGE}).ignored_by_interaction = true
	local drag = head.add{type = "empty-widget", style = "draggable_space_header"}
	drag.style.height = 24
	drag.style.horizontally_stretchable = true
	drag.style.minimal_width = 24
	drag.drag_target = frame
	local body = frame.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
	body.style.horizontally_stretchable = true
	for i, a in ipairs(list) do
		if i > 1 then body.add{type = "line"}.style.margin = {4, 0} end
		if a.kind == "rest" then
			add_label(body, L("rest-title"), {font = "charxpmod_font_20", color = GOLD, wrap = 600})
			add_label(body, L("rest-text", hours_minutes(game.tick - p.session)), {wrap = 600})
		else
			add_label(body, alarm_note(a), {font = "charxpmod_font_30", color = TEXT, wrap = 600})
			add_label(body, L("ring-set", hours_minutes(a.at - a.set)), {color = MUTED, wrap = 600})
		end
		local joke = snooze_joke(a.snoozed)
		if joke then add_label(body, joke, {color = ORANGE, font = "default-small", wrap = 600}) end
	end
	local buttons = frame.add{type = "flow", direction = "horizontal"}
	buttons.style.top_margin = 8
	buttons.style.horizontal_spacing = 8
	buttons.add{type = "button", name = "rpgpm_up", style = "green_button", caption = L("up"), tooltip = L("up-tooltip")}
	filler(buttons)
	buttons.add{type = "button", name = "rpgpm_snooze_5", tags = {m = 5}, caption = L("snooze", 5)}
	buttons.add{type = "button", name = "rpgpm_snooze_10", tags = {m = 10}, caption = L("snooze", 10)}
	return frame
end

local function update_ring(player, p, tick)
	local list = ringing(p)
	local frame = player.gui.screen[RING]
	if #list == 0 then
		if frame then frame.destroy() end
		return
	end
	if not frame or (frame.tags or {}).sig ~= ring_signature(list) then
		frame = build_ring(player, p, list)
	end
	frame.head.title.style.font_color = (math.floor(tick / 60) % 2 == 0) and ORANGE or RED
	frame.bring_to_front()
	if tick >= (p.next_sound or 0) then
		local a = list[1]
		local id = SOUND[a.sound] and a.sound or SOUNDS[1].id
		player.play_sound{path = "rpgpm-" .. id, volume_modifier = math.max(0.1, math.min(1, (a.volume or 80) / 100))}
		p.next_sound = tick + SOUND[id].every * 60
	end
end

---------------------------------------------------------------------------------------------
-- journal page

local function refresh_journal(player, p)
	if not journal_on_page(player) then return end
	local pages = player.gui.screen[JOURNAL].rpgst_body.book.pages
	local cards = {}
	for _, side in ipairs({"left", "right"}) do
		local page = pages[side]
		local content = page and page.scroll and page.scroll.content
		if content then
			for _, name in ipairs({"rpgpm_now", "rpgpm_alarms", "rpgpm_session"}) do
				if content[name] then cards[name] = content[name] end
			end
		end
	end
	local now = cards.rpgpm_now
	local e
	if now then
		if (now.tags or {}).day ~= today() then
			journal.render(player)
			return
		end
		e = find(now, "rpgpm_clock")
		if e then e.caption = now_line() end
		local night, _, _, share = phase()
		e = find(now, "rpgpm_phase")
		if e then
			e.caption = daylight()
			e.style.font_color = night and NIGHT_BLUE or GOLD
		end
		e = find(now, "rpgpm_daybar")
		if e then
			e.visible = share ~= nil
			e.value = share or 0
			e.style.color = night and BLUE or GOLD
		end
	end
	local alarms = cards.rpgpm_alarms
	if alarms then
		e = find(alarms, "rpgpm_preview")
		if e then e.caption = preview(p) end
		for _, a in ipairs(p.alarms) do
			local left = find(alarms, "rpgpm_left_" .. a.id)
			if left then left.caption = a.ringing and L("ringing") or L("left", countdown(a.at - game.tick)) end
			local pb = find(alarms, "rpgpm_bar_" .. a.id)
			if pb then
				pb.value = alarm_progress(a)
				pb.style.color = a.ringing and RED or bar_color(a.at - game.tick)
			end
		end
	end
	local session = cards.rpgpm_session
	if session then
		e = find(session, "rpgpm_session_time")
		if e then e.caption = L("session", hours_minutes(game.tick - p.session)) end
		e = find(session, "rpgpm_rest_next")
		if e then
			e.caption = p.rest_next and L("rest-next", countdown(p.rest_next - game.tick)) or ""
		end
	end
end

local function rerender(player)
	if journal_on_page(player) then journal.render(player) end
end

-- Milestones of the player's team by calendar day, for the days from..to.
local function milestones_by_day(player, from, to)
	local out = {}
	local f = stats.force(player.force.index)
	for id, rec in pairs(f.milestones) do
		local t = stats.record_tick(rec)
		local n, approx = day_of_tick(t)
		approx = approx or not rec.tick
		if n >= from and n <= to then
			out[n] = out[n] or {}
			table.insert(out[n], {id = id, rec = rec, t = t, approx = approx})
		end
	end
	for _, list in pairs(out) do
		table.sort(list, function(a, b)
			if a.t ~= b.t then return a.t < b.t end
			return a.id < b.id
		end)
	end
	return out
end

local function day_tooltip(n, today_n, holiday_id, y, ms)
	local lines = {"", "[font=default-bold]", date_text(n), "[/font]\n", L("wd-" .. calendar.weekday(n)), " · ",
		n == 0 and L("landing-day") or L("since-landing", n + 1)}
	local approx = false
	if n == today_n then lines[#lines + 1] = {"", "\n", L("is-today")} end
	if holiday_id then
		lines[#lines + 1] = {"", "\n[color=1,0.84,0.3]★ ", holiday_name(holiday_id, y), "[/color]\n", holiday_text(holiday_id)}
	end
	if ms then
		local shown = 0
		for _, e in ipairs(ms) do
			if shown >= 6 then
				lines[#lines + 1] = {"", "\n", L("more-milestones", #ms - shown)}
				break
			end
			local time = journal.ms_time(e.rec)
			lines[#lines + 1] = {"", "\n[color=0.36,0.78,0.24]✓[/color] ", journal.milestone_text(e.id, e.rec), ", ", time}
			if e.approx then approx = true end
			shown = shown + 1
		end
	end
	if approx then lines[#lines + 1] = {"", "\n[color=0.68,0.68,0.68]", L("day-approx"), "[/color]"} end
	return lines
end

local function day_info(player, c, ui, LY, p, today_n)
	local n = p.sel
	if not n then
		ui.muted(c, L("pick-day")).style.top_margin = 6
		return
	end
	local y, m, d = calendar.date(n)
	local hol = calendar.holidays(y, m)[d]
	local ms = milestones_by_day(player, n, n)[n]
	local box = c.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
	box.style.top_margin = 6
	box.style.width = LY.inner_w
	ui.label(box, day_tooltip(n, today_n, hol, y, ms), {wrap = LY.inner_w - 24})
	if not hol and not ms then
		ui.muted(box, L(n > today_n and "day-future" or "day-empty"), LY.inner_w - 24)
	end
end

local function month_grid(player, p, c, ui, LY, vy, vm, today_n)
	local first = calendar.index(vy, vm, 1)
	local days = calendar.month_days(vy, vm)
	local hol = calendar.holidays(vy, vm)
	local ms = milestones_by_day(player, first, first + days - 1)
	local gap = 4
	local cell = math.max(36, math.min(110, math.floor((LY.inner_w - 6 * gap) / 7))) -- the cells fill the card
	local t = c.add{type = "table", column_count = 7}
	t.style.horizontal_spacing = gap
	t.style.vertical_spacing = gap
	t.style.top_margin = 4
	for wd = 1, 7 do
		local l = ui.label(t, L("wds-" .. wd), {font = "default-small-bold", color = wd >= 6 and {1, 0.56, 0.45} or MUTED,
			width = cell})
		l.style.horizontal_align = "center"
	end
	local lead = calendar.weekday(first) - 1
	for _ = 1, lead do
		local e = t.add{type = "empty-widget"}
		e.style.width = cell
	end
	for d = 1, days do
		local n = first + d - 1
		local wd = calendar.weekday(n)
		local style = "rpgpm_day"
		if n == today_n then style = "rpgpm_day_today"
		elseif n < today_n then style = wd >= 6 and "rpgpm_day_past_weekend" or "rpgpm_day_past"
		elseif wd >= 6 then style = "rpgpm_day_weekend" end
		-- holidays gold, days with milestones green (dimmer when past); the number stays centred
		local caption = tostring(d)
		local mark
		if hol[d] then mark = n < today_n and "0.75,0.62,0.3" or "1,0.84,0.3"
		elseif ms[n] then mark = n < today_n and "0.32,0.6,0.24" or "0.45,0.88,0.3" end
		if mark and n ~= today_n then caption = "[color=" .. mark .. "]" .. caption .. "[/color]" end
		local b = t.add{type = "button", name = "rpgpm_day_" .. d, style = style, caption = caption,
			tags = {n = n}, tooltip = day_tooltip(n, today_n, hol[d], vy, ms[n])}
		b.style.width = cell
		b.style.height = math.min(cell, 44)
		b.toggled = p.sel == n and n ~= today_n
	end
end

local function year_grid(player, c, ui, LY, vy, today_n)
	local cols = LY.inner_w >= 640 and 4 or 3
	local gap = 10
	local mw = math.floor((LY.inner_w - (cols - 1) * gap) / cols)
	local cw = math.floor(mw / 7)
	local first = calendar.index(vy, 1, 1)
	local ms = milestones_by_day(player, first, first + calendar.year_days(vy) - 1)
	local _, tm = calendar.date(today_n)
	local ty = calendar.date(today_n)
	local grid = c.add{type = "table", column_count = cols}
	grid.style.horizontal_spacing = gap
	grid.style.vertical_spacing = 10
	grid.style.top_margin = 4
	for m = 1, 12 do
		local box = grid.add{type = "flow", direction = "vertical"}
		box.style.width = mw
		box.style.vertical_spacing = 0
		local head = box.add{type = "button", name = "rpgpm_month_" .. m, style = "list_box_item", tags = {y = vy, m = m},
			caption = L("month-" .. m), tooltip = L("month-tooltip")}
		head.style.width = mw
		head.style.font = "default-bold"
		if vy == ty and m == tm then head.style.font_color = ORANGE end
		local t = box.add{type = "table", column_count = 7}
		t.style.horizontal_spacing = 0
		t.style.vertical_spacing = 0
		local mfirst = calendar.index(vy, m, 1)
		local hol = calendar.holidays(vy, m)
		for _ = 1, calendar.weekday(mfirst) - 1 do
			local e = t.add{type = "empty-widget"}
			e.style.width = cw
		end
		for d = 1, calendar.month_days(vy, m) do
			local n = mfirst + d - 1
			local wd = calendar.weekday(n)
			local color = wd >= 6 and {1, 0.56, 0.45} or TEXT
			if n < today_n then color = wd >= 6 and {0.58, 0.4, 0.35} or {0.5, 0.5, 0.5} end
			if ms[n] then color = GREEN end
			if hol[d] then color = GOLD end
			local font = "default-small"
			if n == today_n then color, font = ORANGE, "default-small-bold" end
			local caption = n == today_n and {"", "[", tostring(d), "]"} or tostring(d)
			local l = ui.label(t, caption, {font = font, color = color, width = cw})
			l.style.horizontal_align = "center"
			if hol[d] or ms[n] or n == today_n then l.tooltip = day_tooltip(n, today_n, hol[d], vy, ms[n]) end
		end
	end
end

local function render_now(player, p, page, ui, LY)
	local n, state = today()
	local y, m, d = calendar.date(n)
	local c = ui.card(page)
	c.name = "rpgpm_now"
	c.tags = {day = n}
	local top = c.add{type = "flow", direction = "horizontal"}
	top.style.vertical_align = "center"
	top.style.width = LY.inner_w
	ui.label(top, date_text(n), {font = "charxpmod_font_30", color = ORANGE})
	filler(top)
	local pin = top.add{type = "button", name = "rpgpm_pin_toggle", caption = L(p.pin and "unpin" or "pin"),
		tooltip = L(p.pin and "unpin-tooltip" or "pin-tooltip")}
	pin.toggled = p.pin
	ui.label(c, {"", L("wd-" .. calendar.weekday(n)), " · ", n == 0 and L("landing-day") or L("since-landing", n + 1)},
		{font = "default-bold", wrap = LY.inner_w})
	ui.label(c, now_line(), {name = "rpgpm_clock", wrap = LY.inner_w})
	local night, _, _, share = phase()
	local ph = ui.label(c, daylight(), {name = "rpgpm_phase", color = night and NIGHT_BLUE or GOLD, wrap = LY.inner_w})
	ph.style.top_margin = 4
	local daybar = c.add{type = "progressbar", name = "rpgpm_daybar", value = share or 0,
		tooltip = L("daybar-tooltip")}
	daybar.style.width = LY.inner_w
	daybar.style.color = night and BLUE or GOLD
	daybar.visible = share ~= nil
	if state and state.season and not state.disabled then
		local api = remote.interfaces["NightBrightness"] or {}
		local name, color = state.season, nil
		if api.get_season_name then
			local ok, result = pcall(remote.call, "NightBrightness", "get_season_name", state.season, player.index)
			if ok and result then name = result end
		end
		if api.get_season_color then
			local ok, result = pcall(remote.call, "NightBrightness", "get_season_color", state.season)
			if ok then color = result end
		end
		ui.label(c, L("season", name, state.season_day or "?", state.season_length or "?"),
			{color = type(color) == "table" and {color[1], color[2], color[3]} or TEXT, wrap = LY.inner_w})
	end
	local hol = calendar.holidays(y, m)[d]
	if hol then
		local h = ui.label(c, L("today-holiday", holiday_name(hol, y)), {font = "default-bold", color = GOLD, wrap = LY.inner_w})
		h.style.top_margin = 4
		ui.muted(c, holiday_text(hol))
	end
end

local function render_calendar_card(player, p, page, ui, LY)
	local today_n = today()
	local ty, tm = calendar.date(today_n)
	local vy, vm = p.vy or ty, p.vm or tm
	local c = ui.card(page, "[virtual-signal=signal-star]", L("card-calendar"))
	local nav = c.add{type = "flow", direction = "horizontal"}
	nav.style.vertical_align = "center"
	nav.style.horizontal_spacing = 6
	nav.style.width = LY.inner_w
	nav.add{type = "button", name = "rpgpm_prev", style = "tool_button", caption = "<", tooltip = L(p.view == "year" and "prev-year" or "prev-month")}
	local title = p.view == "year" and L("year-title", vy) or L("month-title", L("month-" .. vm), vy)
	local tl = ui.label(nav, title, {font = "default-large-bold"})
	tl.style.minimal_width = 150
	tl.style.horizontal_align = "center"
	nav.add{type = "button", name = "rpgpm_next", style = "tool_button", caption = ">", tooltip = L(p.view == "year" and "next-year" or "next-month")}
	filler(nav)
	local tb = nav.add{type = "button", name = "rpgpm_today", caption = L("today"), tooltip = L("today-tooltip")}
	tb.enabled = not (vy == ty and (p.view == "year" or vm == tm))
	local bm = nav.add{type = "button", name = "rpgpm_view_month", tags = {view = "month"}, caption = L("view-month")}
	bm.toggled = p.view ~= "year"
	local by = nav.add{type = "button", name = "rpgpm_view_year", tags = {view = "year"}, caption = L("view-year")}
	by.toggled = p.view == "year"
	if p.view == "year" then
		year_grid(player, c, ui, LY, vy, today_n)
		ui.muted(c, L("legend-year")).style.top_margin = 6
	else
		month_grid(player, p, c, ui, LY, vy, vm, today_n)
		ui.muted(c, L("legend-month")).style.top_margin = 6
		day_info(player, c, ui, LY, p, today_n)
	end
end

local LABEL_W = 96 -- the label column of the alarm form

-- One row of the alarm form: the caption in a fixed column, the controls in a flow after it.
local function form_row(t, caption)
	local l = t.add{type = "label", caption = caption or ""}
	l.style.width = LABEL_W
	l.style.height = 28
	l.style.vertical_align = "center"
	l.style.font_color = TEXT
	local f = t.add{type = "flow", direction = "horizontal"}
	f.style.vertical_align = "center"
	f.style.horizontal_spacing = 6
	f.style.minimal_height = 28
	return f
end

local function render_alarm_card(player, p, page, ui, LY)
	local c = ui.card(page, "[img=utility/clock]", {"", L("card-alarm"), "  [virtual-signal=signal-info]"},
		{"", L("card-alarm-tooltip"), "\n\n", L("game-time")})
	c.name = "rpgpm_alarms"
	local field_w = LY.inner_w - LABEL_W - 8
	local t = c.add{type = "table", column_count = 2}
	t.style.horizontal_spacing = 8
	t.style.vertical_spacing = 6

	local row = form_row(t, L("in"))
	local h = row.add{type = "textfield", name = "rpgpm_hours", text = tostring(p.hours), numeric = true,
		allow_decimal = false, allow_negative = false, lose_focus_on_confirm = true}
	h.style.width = 50
	ui.label(row, L("h"))
	local m = row.add{type = "textfield", name = "rpgpm_minutes", text = tostring(p.minutes), numeric = true,
		allow_decimal = false, allow_negative = false, lose_focus_on_confirm = true}
	m.style.width = 60
	ui.label(row, L("min"))

	row = form_row(t)
	row.style.horizontal_spacing = 4
	local preset_w = math.max(56, math.min(80, math.floor((field_w - 4 * #PRESETS) / (#PRESETS + 1))))
	for _, minutes in ipairs(PRESETS) do
		local caption = minutes < 60 and L("m", minutes) or L("h-only", minutes / 60)
		row.add{type = "button", name = "rpgpm_preset_" .. minutes, tags = {m = minutes}, caption = caption}.style.width = preset_w
	end
	row.add{type = "button", name = "rpgpm_plus5", caption = L("plus", 5), tooltip = L("plus-tooltip", 5)}.style.width = preset_w

	row = form_row(t, L("note"))
	local note = row.add{type = "textfield", name = "rpgpm_note", text = p.note or "", tooltip = L("note-tooltip"),
		lose_focus_on_confirm = true}
	note.style.width = math.max(160, field_w)
	if #p.notes > 0 then
		row = form_row(t, L("recent"))
		row.style.horizontal_spacing = 4
		local w = math.floor((field_w - 4 * (RECENT - 1)) / RECENT)
		for i, text in ipairs(p.notes) do
			local b = row.add{type = "button", name = "rpgpm_tpl_" .. i, tags = {i = i}, caption = text, tooltip = text}
			b.style.maximal_width = math.max(60, w)
			b.style.font = "default-small"
		end
	end

	row = form_row(t, L("sound"))
	local items = {}
	for i, s in ipairs(SOUNDS) do items[i] = {"programmable-speaker-note." .. s.id} end
	local dd = row.add{type = "drop-down", name = "rpgpm_sound", items = items,
		selected_index = SOUND[p.sound] and SOUND[p.sound].index or 1}
	dd.style.width = math.min(240, math.max(160, field_w - 40))
	row.add{type = "sprite-button", name = "rpgpm_play", sprite = "utility/play", style = "tool_button",
		tooltip = L("play-tooltip")}

	row = form_row(t, L("volume-label"))
	row.style.horizontal_spacing = 10
	local slider = row.add{type = "slider", name = "rpgpm_volume", minimum_value = 10, maximum_value = 100,
		value = p.volume, value_step = 10, discrete_values = true}
	slider.style.width = math.max(120, math.min(240, field_w - 60))
	ui.label(row, L("volume", p.volume), {name = "rpgpm_volume_text", font = "default-bold"})

	local act = c.add{type = "flow", direction = "horizontal"}
	act.style.vertical_align = "center"
	act.style.horizontal_spacing = 10
	act.style.top_margin = 10
	act.style.left_margin = LABEL_W + 8 -- under the fields
	local set = act.add{type = "button", name = "rpgpm_set", style = "green_button", caption = L("set"),
		tooltip = L("set-tooltip")}
	set.style.minimal_width = 160
	set.enabled = #p.alarms < MAX_ALARMS
	local pv = ui.label(act, preview(p), {name = "rpgpm_preview", color = MUTED, wrap = math.max(120, field_w - 180)})
	pv.style.horizontally_squashable = true
	if #p.alarms >= MAX_ALARMS then ui.muted(c, L("limit", MAX_ALARMS)).style.top_margin = 4 end

	local head = ui.label(c, L("active", #p.alarms), {font = "default-bold", color = ORANGE})
	head.style.top_margin = 12
	if #p.alarms == 0 then ui.muted(c, L("none")) end
	for _, a in ipairs(p.alarms) do
		local r = c.add{type = "flow", direction = "horizontal"}
		r.style.vertical_align = "center"
		r.style.horizontal_spacing = 6
		r.style.top_margin = 4
		local sound_name = {"programmable-speaker-note." .. (SOUND[a.sound] and a.sound or SOUNDS[1].id)}
		ui.label(r, alarm_note(a), {font = "default-semibold", width = math.max(120, LY.inner_w - 200), wrap = math.max(120, LY.inner_w - 200),
			tooltip = L("alarm-tooltip", hours_minutes(a.at - a.set), sound_name, a.volume or 80)})
		ui.label(r, a.ringing and L("ringing") or L("left", countdown(a.at - game.tick)),
			{name = "rpgpm_left_" .. a.id, font = "default-bold", width = 140})
		r.add{type = "sprite-button", name = "rpgpm_del_" .. a.id, tags = {id = a.id}, sprite = "utility/close",
			style = "tool_button_red", tooltip = L("del-tooltip")}
		local pb = c.add{type = "progressbar", name = "rpgpm_bar_" .. a.id, value = alarm_progress(a)}
		pb.style.width = LY.inner_w
		pb.style.color = a.ringing and RED or bar_color(a.at - game.tick)
	end
end

-- The session in one line; the reminder time only while the reminder is on.
local function render_session_card(player, p, page, ui, LY)
	local c = ui.card(page, "[entity=character]", L("card-session"), {"", L("card-session-tooltip"), "\n\n", L("rest-hint")})
	c.name = "rpgpm_session"
	local row = c.add{type = "flow", direction = "horizontal"}
	row.style.vertical_align = "center"
	row.style.horizontal_spacing = 12
	ui.label(row, L("session", hours_minutes(game.tick - p.session)), {name = "rpgpm_session_time",
		font = "default-bold", tooltip = L("card-session-tooltip")})
	row.add{type = "checkbox", name = "rpgpm_rest", state = p.rest, caption = L("rest"), tooltip = L("rest-tooltip")}
	local items, sel = {}, 1
	for i, minutes in ipairs(REST_EVERY) do
		items[i] = minutes % 60 == 0 and L("every-h", minutes / 60) or L("every-hm", math.floor(minutes / 60), minutes % 60)
		if minutes == p.rest_every then sel = i end
	end
	row.add{type = "drop-down", name = "rpgpm_rest_every", items = items, selected_index = sel}
	if p.rest and p.rest_next then
		ui.label(c, L("rest-next", countdown(p.rest_next - game.tick)), {name = "rpgpm_rest_next", color = MUTED,
			font = "default-small"}).style.top_margin = 4
	end
end

-- Features render on the right page (on one-page screens: after the list), under the back line.
local FEATURES = {
	calendar = function(player, p, page, ui, LY)
		render_now(player, p, page, ui, LY)
		render_calendar_card(player, p, page, ui, LY)
		render_alarm_card(player, p, page, ui, LY)
		render_session_card(player, p, page, ui, LY)
	end,
}

-- Left page: the club card and the holders, alphabetically.
local function render_list(player, p, page, ui, LY)
	local c = ui.card(page, P.ICON, L("card-title"), L("card-title-tooltip"))
	ui.bigs(c, {
		{L("donors-count"), tostring(#DONORS), GOLD},
		{L("done-count"), tostring(#WISH_IDS), GREEN},
		{L("review"), L("review-value", REVIEW_DAYS), ORANGE, L("review-tooltip")},
		{L("review-norm"), L("review-norm-value"), nil},
	})
	ui.muted(c, L("card-fine"))

	c = ui.card(page, "[virtual-signal=signal-star]", L("card-donors"), L("card-donors-tooltip"))
	for _, d in ipairs(DONORS) do
		local n = #d.wishes
		local caption = {"", "[color=1,0.84,0.3]★[/color]  ", d.name}
		if n > 0 then caption[#caption + 1] = "    [color=0.45,0.88,0.3]✓ " .. n .. "[/color]" end
		local b = c.add{type = "button", name = "rpgpm_donor_" .. d.card, tags = {card = d.card}, caption = caption,
			tooltip = L("donor-tooltip")}
		b.style.width = LY.inner_w
		b.style.horizontal_align = "left"
		b.toggled = p.donor == d.card
	end
end

-- One wish in a profile: a line with the version, expand and open; the quote and the text when expanded.
local function render_wish_row(p, c, id, ui, LY)
	local w = WISHES[id]
	local expanded = p.expanded and p.expanded[id]
	local quote = L("quote", L(id .. "-quote"))
	local row = c.add{type = "flow", direction = "horizontal"}
	row.style.vertical_align = "center"
	row.style.horizontal_spacing = 8
	row.style.width = LY.inner_w
	local line = ui.label(row, L(id .. "-title"), {font = "default-bold", wrap = math.max(120, LY.inner_w - 300),
		tooltip = {"", quote, "\n", L("entry-asked", real_date(w.asked))}})
	line.style.horizontally_squashable = true
	ui.label(row, L("entry-short", w.version), {font = "default-bold", color = GREEN, tooltip = done_tooltip(w)})
	filler(row)
	row.add{type = "sprite-button", name = "rpgpm_exp_" .. id, tags = {wish = id}, style = "frame_action_button",
		sprite = expanded and "utility/collapse" or "utility/expand", tooltip = L(expanded and "collapse" or "expand")}
	if w.feature then
		row.add{type = "button", name = "rpgpm_open_" .. id, tags = {wish = id}, caption = L("open"),
			tooltip = L("open-tooltip")}
	end
	if not expanded then return end
	local q = ui.label(c, quote, {name = "rpgpm_quote_" .. id, wrap = LY.inner_w, color = TEXT})
	q.style.top_margin = 6
	ui.muted(c, L("entry-asked", real_date(w.asked)))
	ui.label(c, L(id .. "-text"), {wrap = LY.inner_w}).style.top_margin = 6
	ui.label(c, L("entry-done", w.version, real_date(w.done)), {font = "default-bold", color = GREEN,
		tooltip = done_tooltip(w)}).style.top_margin = 4
end

-- Right page: the card of a holder and the wishes.
local function render_profile(p, d, page, ui, LY)
	local c = ui.card(page, P.ICON, L("profile-card"))
	c.name = "rpgpm_profile"
	local top = c.add{type = "flow", direction = "horizontal"}
	top.style.vertical_align = "center"
	top.style.width = LY.inner_w
	ui.label(top, d.name, {font = "charxpmod_font_30", color = GOLD, wrap = math.max(160, LY.inner_w - 110)})
	filler(top)
	ui.label(top, L("card-number", string.format("%04d", d.card)), {font = "default-large-bold", color = MUTED,
		tooltip = L("card-number-tooltip")})
	ui.label(c, L("valid-until"), {wrap = LY.inner_w})
	local n = #d.wishes
	-- every holder has the same status
	ui.label(c, L("status", L("status-name")), {font = "default-bold", color = ORANGE, wrap = LY.inner_w,
		tooltip = L("status-tooltip")}).style.top_margin = 4

	c = ui.card(page, "[virtual-signal=signal-check]", L("card-wishes"))
	if n == 0 then
		ui.muted(c, L("empty-" .. ((d.card - 1) % 5 + 1)))
		return
	end
	for i, id in ipairs(d.wishes) do
		if i > 1 then
			local sep = c.add{type = "line"}
			sep.style.top_margin = 6
			sep.style.bottom_margin = 6
		end
		render_wish_row(p, c, id, ui, LY)
	end
end

-- Right page: an opened wish under a line back to its holder.
local function render_wish(player, p, id, page, ui, LY)
	local w, d = WISHES[id], DONOR_OF[id]
	local bar = page.add{type = "flow", name = "rpgpm_backbar", direction = "horizontal"}
	bar.style.vertical_align = "center"
	bar.style.horizontal_spacing = 12
	bar.style.width = LY.card_w
	bar.add{type = "button", name = "rpgpm_back", style = "back_button", caption = d.name, tooltip = L("back-tooltip")}
	ui.label(bar, L(id .. "-title"), {font = "default-large-bold", color = ORANGE})
	FEATURES[w.feature](player, p, page, ui, LY)
end

-- The bookmark: the holders on the left; on the right a hint, a profile or an opened wish.
function P.render(player, lc, rc)
	local ui = journal.ui
	local LY = ui.layout()
	local p = pstate(player.index)
	root().watch[player.index] = true
	render_list(player, p, lc, ui, LY)
	local w = p.open and WISHES[p.open]
	if w and w.feature and FEATURES[w.feature] then
		p.donor = DONOR_OF[p.open].card
		render_wish(player, p, p.open, rc, ui, LY)
		return
	end
	p.open = nil
	local d = p.donor and BY_CARD[p.donor]
	if not d then
		p.donor = nil
		local c = ui.card(rc)
		c.name = "rpgpm_hint"
		ui.muted(c, L("pick-hint"))
		return
	end
	render_profile(p, d, rc, ui, LY)
end

---------------------------------------------------------------------------------------------
-- events

function P.set_journal(module) journal = module end

function P.on_init()
	root()
	poll_day()
end

function P.on_configuration_changed()
	local s = root()
	if (s.version or 1) < VERSION then s.version = VERSION end
	poll_day()
end

-- New session: a player joined, or the save was loaded (single player raises on_singleplayer_init
-- on load, used the same way by paranoidal-rain).
local function start_session(player)
	local p = pstate(player.index)
	p.session = game.tick
	rest_schedule(p)
	update_watch(player, p)
end

function P.on_player_joined(player)
	if player and player.valid then start_session(player) end
end

function P.on_game_loaded()
	for _, player in pairs(game.connected_players) do start_session(player) end
end

function P.on_player_removed(index)
	local s = storage.rpg_premium
	if s then
		s.players[index] = nil
		s.watch[index] = nil
	end
end

local function second(player, p, tick)
	local changed = false
	for _, a in ipairs(p.alarms) do
		if not a.ringing and a.at <= tick then
			a.ringing = true
			changed = true
			p.next_sound = tick
			local text = a.kind == "rest" and L("chat-rest", hours_minutes(tick - p.session)) or L("chat", alarm_note(a))
			player.print({"", "[img=utility/clock] ", text}, {color = ORANGE})
		end
	end
	if p.rest and p.rest_next and tick >= p.rest_next then
		local busy = false
		for _, a in ipairs(p.alarms) do
			if a.kind == "rest" then busy = true end
		end
		if not busy then
			local a = new_alarm(p, 0, "rest")
			a.ringing = true
			p.next_sound = tick
			changed = true
			player.print({"", "[img=utility/clock] ", L("chat-rest", hours_minutes(tick - p.session))}, {color = ORANGE})
		end
		rest_schedule(p)
	end
	update_ring(player, p, tick)
	update_pin(player, p)
	if changed then rerender(player) else refresh_journal(player, p) end
	update_watch(player, p)
end

function P.on_nth_tick(event)
	local s = storage.rpg_premium
	if not s then return end
	if event.tick % 600 == 0 then poll_day() end
	for index in pairs(s.watch) do
		local player = game.get_player(index)
		local p = s.players[index]
		if not (player and p) then
			s.watch[index] = nil
		elseif player.connected then
			second(player, p, event.tick)
		end
	end
end

local function remove_alarm(p, id)
	for i = #p.alarms, 1, -1 do
		if p.alarms[i].id == id then table.remove(p.alarms, i) end
	end
end

local function set_alarm(player, p)
	local minutes = duration_minutes(p)
	if minutes <= 0 then
		player.print(L("zero"))
		return
	end
	if #p.alarms >= MAX_ALARMS then return end
	local a = new_alarm(p, minutes)
	remember_note(p, a.note)
	p.note = ""
	update_watch(player, p)
	update_pin(player, p)
	rerender(player)
end

local function set_field(player, name, text)
	local frame = player.gui.screen[JOURNAL]
	local e = frame and find(frame, name)
	if e then e.text = text end
end

-- The alarm time changed: the hours and minutes fields and the "rings at" line.
local function set_duration(player, p)
	set_field(player, "rpgpm_hours", tostring(p.hours))
	set_field(player, "rpgpm_minutes", tostring(p.minutes))
	local frame = player.gui.screen[JOURNAL]
	local e = frame and find(frame, "rpgpm_preview")
	if e then e.caption = preview(p) end
end

-- Returns true when the click belonged to Premium BnL.
function P.on_click(event, player)
	local element = event.element
	local name = element.name
	if name:sub(1, 6) ~= "rpgpm_" then return false end
	local p = pstate(player.index)
	local tags = element.tags or {}
	if name:sub(1, 12) == "rpgpm_donor_" then
		-- the selected holder again closes the profile; from an opened wish it goes back to the profile
		if p.donor == tags.card and not p.open then p.donor = nil else p.donor = tags.card end
		p.open = nil
		rerender(player)
	elseif name:sub(1, 11) == "rpgpm_open_" then
		local w = WISHES[tags.wish]
		if w and w.feature then
			p.open = tags.wish
			rerender(player)
		end
	elseif name == "rpgpm_back" then
		p.open = nil
		rerender(player)
	elseif name:sub(1, 10) == "rpgpm_exp_" then
		p.expanded = p.expanded or {}
		p.expanded[tags.wish] = (not p.expanded[tags.wish]) or nil
		rerender(player)
	elseif name == "rpgpm_pin_toggle" then
		p.pin = not p.pin
		update_pin(player, p)
		update_watch(player, p)
		rerender(player)
	elseif name == "rpgpm_pin_mode" then
		p.pin_full = not p.pin_full
		update_pin(player, p)
	elseif name == "rpgpm_pin_open" then
		-- the wish with the calendar and the alarm
		for _, id in ipairs(WISH_IDS) do
			if WISHES[id].feature == "calendar" then p.open, p.donor = id, DONOR_OF[id].card break end
		end
		journal.open(player, "premium")
	elseif name == "rpgpm_pin_close" then
		p.pin = false
		update_pin(player, p)
		update_watch(player, p)
		rerender(player)
	elseif name == "rpgpm_prev" or name == "rpgpm_next" then
		local ty, tm = calendar.date(today())
		local vy, vm = p.vy or ty, p.vm or tm
		local delta = name == "rpgpm_next" and 1 or -1
		if p.view == "year" then
			vy = math.max(1, vy + delta)
		else
			vy, vm = calendar.shift_month(vy, vm, delta)
		end
		p.vy, p.vm = vy, vm
		rerender(player)
	elseif name == "rpgpm_today" then
		p.vy, p.vm, p.sel = nil, nil, nil
		rerender(player)
	elseif name == "rpgpm_view_month" or name == "rpgpm_view_year" then
		p.view = tags.view
		rerender(player)
	elseif name:sub(1, 12) == "rpgpm_month_" then
		p.view, p.vy, p.vm = "month", tags.y, tags.m
		rerender(player)
	elseif name:sub(1, 10) == "rpgpm_day_" then
		p.sel = (p.sel ~= tags.n) and tags.n or nil
		rerender(player)
	elseif name:sub(1, 13) == "rpgpm_preset_" then
		p.hours, p.minutes = math.floor(tags.m / 60), tags.m % 60
		set_duration(player, p)
	elseif name == "rpgpm_plus5" then
		local total = duration_minutes(p) + 5
		p.hours, p.minutes = math.floor(total / 60), total % 60
		set_duration(player, p)
	elseif name:sub(1, 10) == "rpgpm_tpl_" then
		local text = p.notes[tags.i]
		if text then
			p.note = text
			set_field(player, "rpgpm_note", text)
		end
	elseif name == "rpgpm_play" then
		local id = SOUND[p.sound] and p.sound or SOUNDS[1].id
		player.play_sound{path = "rpgpm-" .. id, volume_modifier = math.max(0.1, math.min(1, p.volume / 100))}
	elseif name == "rpgpm_set" then
		set_alarm(player, p)
	elseif name:sub(1, 10) == "rpgpm_del_" then
		remove_alarm(p, tags.id)
		update_ring(player, p, game.tick)
		update_pin(player, p)
		update_watch(player, p)
		rerender(player)
	elseif name == "rpgpm_up" then
		for _, a in ipairs(ringing(p)) do remove_alarm(p, a.id) end
		update_ring(player, p, game.tick)
		update_pin(player, p)
		update_watch(player, p)
		rerender(player)
	elseif name:sub(1, 13) == "rpgpm_snooze_" then
		for _, a in ipairs(ringing(p)) do
			a.ringing = false
			a.snoozed = a.snoozed + 1
			a.set = game.tick
			a.at = game.tick + tags.m * MINUTE
		end
		sort_alarms(p)
		update_ring(player, p, game.tick)
		update_pin(player, p)
		rerender(player)
	end
	return true
end

function P.on_text_changed(event)
	local element = event.element
	local name = element.name
	if name ~= "rpgpm_hours" and name ~= "rpgpm_minutes" and name ~= "rpgpm_note" then return end
	local p = pstate(event.player_index)
	if name == "rpgpm_note" then
		p.note = cut(element.text, NOTE_BYTES)
	else
		local v = math.max(0, math.min(name == "rpgpm_hours" and 99 or 999, math.floor(tonumber(element.text) or 0)))
		if name == "rpgpm_hours" then p.hours = v else p.minutes = v end
		local card = element.parent.parent.parent -- field < form row < form table < alarm card
		local e = card and card.valid and find(card, "rpgpm_preview")
		if e then e.caption = preview(p) end
	end
end

function P.on_confirmed(event)
	local element = event.element
	local name = element.name
	if name ~= "rpgpm_hours" and name ~= "rpgpm_minutes" and name ~= "rpgpm_note" then return end
	local player = game.get_player(event.player_index)
	if player then set_alarm(player, pstate(player.index)) end
end

function P.on_selection_changed(event)
	local element = event.element
	local p
	if element.name == "rpgpm_sound" then
		p = pstate(event.player_index)
		local s = SOUNDS[element.selected_index]
		if s then p.sound = s.id end
	elseif element.name == "rpgpm_rest_every" then
		p = pstate(event.player_index)
		local minutes = REST_EVERY[element.selected_index]
		if minutes then
			p.rest_every = minutes
			rest_schedule(p)
		end
	end
end

function P.on_value_changed(event)
	local element = event.element
	if element.name ~= "rpgpm_volume" then return end
	local p = pstate(event.player_index)
	p.volume = math.max(10, math.min(100, math.floor(element.slider_value + 0.5)))
	local label = element.parent.rpgpm_volume_text
	if label then label.caption = L("volume", p.volume) end
end

function P.on_checked_changed(event)
	local element = event.element
	if element.name ~= "rpgpm_rest" then return end
	local player = game.get_player(event.player_index)
	if not player then return end
	local p = pstate(player.index)
	p.rest = element.state
	rest_schedule(p)
	update_watch(player, p)
	rerender(player)
end

function P.on_location_changed(event)
	local element = event.element
	if element.name ~= PIN then return end
	local p = pstate(event.player_index)
	p.pin_loc = element.location
end

-- Hook for the diagnostic mod of the local test runs: GUI events cannot be raised by a script, so the
-- test calls the same handlers with the real elements. Registered only when that mod is active.
if script.active_mods["pd-port21-diag"] then
	local function element(index, name)
		local player = game.get_player(index)
		return player, player and find(player.gui.screen, name)
	end
	remote.add_interface("rpg-premium-test", {
		open = function(index) journal.open(game.get_player(index), "premium") end,
		exists = function(index, name) local _, e = element(index, name) return e ~= nil end,
		click = function(index, name)
			local player, e = element(index, name)
			if not e then return false end
			P.on_click({element = e, player_index = index}, player)
			return true
		end,
		text = function(index, name, text)
			local _, e = element(index, name)
			if not e then return false end
			e.text = text
			P.on_text_changed({element = e, player_index = index})
			return true
		end,
		select = function(index, name, i)
			local _, e = element(index, name)
			if not e then return false end
			e.selected_index = i
			P.on_selection_changed({element = e, player_index = index})
			return true
		end,
		value = function(index, name, v)
			local _, e = element(index, name)
			if not e then return false end
			e.slider_value = v
			P.on_value_changed({element = e, player_index = index})
			return true
		end,
		check = function(index, name, state)
			local _, e = element(index, name)
			if not e then return false end
			e.state = state
			P.on_checked_changed({element = e, player_index = index})
			return true
		end,
		close = function(index) journal.close(game.get_player(index)) end,
		-- a player state of 9.2.x: the old wish open, no layout mark
		legacy = function(index)
			local p = pstate(index)
			p.layout, p.open, p.donor = nil, "silkor-calendar", 3
		end,
		state = function(index)
			local s = root()
			local p = pstate(index)
			local ids = {}
			for _, a in ipairs(p.alarms) do ids[#ids + 1] = a.id end
			local sounds = 0
			for _, so in ipairs(SOUNDS) do
				if helpers.is_valid_sound_path("rpgpm-" .. so.id) then sounds = sounds + 1 end
			end
			return {alarms = #p.alarms, ids = ids, ringing = #ringing(p), watch = s.watch[index] == true,
				days = #s.days, today = today(), rest = p.rest, rest_next = p.rest_next, sound = p.sound,
				volume = p.volume, note = p.note, notes = #p.notes, pin = p.pin, valid_sounds = sounds,
				total_sounds = #SOUNDS, open = p.open, donor = p.donor, tab = stats.player(index).tab, view = p.view, vy = p.vy, vm = p.vm, sel = p.sel}
		end,
	})
end

P.DONORS, P.WISHES = DONORS, WISHES
return P
