-- Main window of the tree: vanilla window anatomy (titlebar with drag and close, a top pane with the
-- toolbar, filters and queue, then three panes: eras, technologies, selected technology).
-- Built once on open; clicks update elements in place, only content changes rebuild a list.
local G = require("graph")
local Goal = require("goal")
local Toolbar = require("toolbar")
local Prefs = require("prefs")
local Effects = require("effects")
local Search = require("search")
local M = {}
local ROOT = "ptt_native"
local SETTINGS = "ptt_settings"
local HELP = "ptt_help"
M.ROOT = ROOT
local SIZES = {48, 64, 80, 96}
local QUEUE_SLOTS = 7 -- engine limit measured on 2.0.77: the 8th add_research is rejected
local NAV_WIDTH = 210
local MAX_WAVES = 5
local CARD_EXTRA = 112 -- card width = icon size + this
-- List row without the name: icon 32, status 120, cost 240, mark 60, four gaps of 8, left margin, scroll reserve.
local LIST_FIXED = 32 + 120 + 240 + 60 + 4 * 8 + 4 + 24
local GAP = 8
local COLORS = {done={0.55,0.8,0.55}, available={1,0.85,0.35}, locked={0.65,0.65,0.65},
  current={0.3,0.85,1}, queued={0.5,0.7,1}, disabled={0.6,0.6,0.6}, trigger={0.9,0.6,1},
  path={1,0.65,0.35}, goal={1,0.8,0.2}, warn={1,0.45,0.35}, name={0.9,0.9,0.9}, dim={0.6,0.6,0.6},
  new={0.45,0.95,0.55}}
local STYLES = {done="slot_sized_button_green", available="yellow_slot_button", locked="slot_sized_button",
  current="slot_sized_button_blue", queued="slot_sized_button_blue", disabled="red_slot_button",
  trigger="slot_sized_button"}
local STATUS_FILTERS = {"all", "available", "trigger", "queued", "locked", "done", "disabled"}
local STATUS_MATCH = {available={available=true}, trigger={trigger=true}, queued={queued=true, current=true},
  locked={locked=true}, done={done=true}, disabled={disabled=true}}
local ACTIONABLE = {available=true, current=true, queued=true, trigger=true}

local function state(p)
  storage.native_players = storage.native_players or {}
  local s = storage.native_players[p.index]
  if not s then
    s = { chain=false, query="", translations={}, pending={}, request_index=1, expanded={} }
    storage.native_players[p.index] = s
  end
  s.expanded = s.expanded or {}
  s.query = s.query or ""
  return s
end
M.state = state
local function graph(p) return Goal.graph(p.force) end
M.graph = graph
local function root(p) return p.gui.screen[ROOT] end
M.root = root
local function opt(p, key) return Prefs.get(p.index, key) end

-- Element builders -----------------------------------------------------------------------------------

local function tags_of(action, extra)
  local tags = {ptt=true, action=action}
  for k, v in pairs(extra or {}) do tags[k] = v end
  return tags
end
local function button(parent, action, caption, extra)
  return parent.add{type="button", caption=caption, tags=tags_of(action, extra)}
end
-- Light 28 px tool button with a dark vanilla icon (subheaders, light panes).
local function tool(parent, action, sprite, tooltip, extra)
  local b = parent.add{type="sprite-button", style="tool_button", sprite=sprite, tooltip=tooltip,
    tags=tags_of(action, extra)}
  return b
end
local function mini(parent, action, caption, tooltip, extra)
  local b = button(parent, action, caption, extra)
  b.style = "mini_button"; b.style.size = 20; b.style.font = "default-bold"
  b.tooltip = tooltip
  return b
end
local function text(parent, caption, width)
  local l = parent.add{type="label", caption=caption}
  l.style.single_line = false
  if width then l.style.maximal_width = width end
  return l
end
local function section(parent, caption)
  local l = parent.add{type="label", caption=caption, style="caption_label"}
  l.style.top_margin = 4
  return l
end
local function pusher(parent)
  local e = parent.add{type="empty-widget"}
  e.style.horizontally_stretchable = true
  return e
end
-- Titlebar of a standard window: title, drag handle, close button.
local function titlebar(frame, caption, close_action, extra)
  local bar = frame.add{type="flow", direction="horizontal"}
  bar.drag_target = frame
  bar.style.horizontal_spacing = 8
  bar.add{type="label", caption=caption, style="frame_title", ignored_by_interaction=true}
  local drag = bar.add{type="empty-widget", style="draggable_space_header", ignored_by_interaction=true}
  drag.style.height = 24; drag.style.horizontally_stretchable = true; drag.style.right_margin = 4
  bar.add{type="sprite-button", sprite="utility/close", style="frame_action_button",
    tags=tags_of(close_action, extra), tooltip={"ptt.close"}}
  return bar
end

-- Texts ----------------------------------------------------------------------------------------------

local EVOLUTION_SPRITE = "ptt-evolution"
-- Evolution after researching the path, by the rule of research_evolution_factor (its remote
-- interface; nil when absent). Returns the increase and the result, both as fractions.
local function path_evolution(p, plan)
  local api = remote.interfaces.research_evolution_factor
  if not (api and api.path_increment) then return nil end
  local names = {}
  for n in pairs(plan.set) do names[#names + 1] = n end
  local ok, sum = pcall(remote.call, "research_evolution_factor", "path_increment", p.force.name, names)
  if not ok or type(sum) ~= "number" or sum <= 0 then return nil end
  local enemy = game.forces.enemy
  local now = enemy and enemy.get_evolution_factor() or 0
  local after = 1 - (1 - now) * math.exp(-sum)
  return after - now, after, now
end
local function percent(v)
  return string.format("%.2f", v * 100)
end
local function sorted_keys(t)
  local a = {}; for n in pairs(t) do a[#a + 1] = n end; table.sort(a); return a
end
local function pack_caption(item)
  if not item then return {"ptt.era-none"} end
  local proto = prototypes.item[item]
  return {"", "[item=" .. item .. "] ", proto and proto.localised_name or item}
end
local TRIGGERS = {["craft-item"]=true, ["mine-entity"]=true, ["craft-fluid"]=true, ["build-entity"]=true,
  ["send-item-to-orbit"]=true, ["capture-spawner"]=true, ["create-space-platform"]=true, ["scripted"]=true}
local function trigger_kind(name)
  local t = prototypes.technology[name]
  local tr = t and t.research_trigger
  if not tr then return nil end
  return TRIGGERS[tr.type] and tr.type or "other", tr
end
local function thing(kind, id)
  if type(id) == "table" then id = id.name end
  if not id then return "" end
  local proto = (kind == "item" and prototypes.item[id]) or (kind == "entity" and prototypes.entity[id])
    or (kind == "fluid" and prototypes.fluid[id])
  if not proto then return id end
  return {"", "[" .. kind .. "=" .. id .. "] ", proto.localised_name}
end
-- Exact unlock condition of a trigger technology, e.g. "Craft 50 × [item] Steel plate".
local function trigger_text(name)
  local kind, tr = trigger_kind(name)
  if not kind then return nil end
  if kind == "craft-item" then return {"ptt.trigger-craft-item", tr.count or 1, thing("item", tr.item)} end
  if kind == "craft-fluid" then return {"ptt.trigger-craft-fluid", tr.amount or 1, thing("fluid", tr.fluid)} end
  if kind == "mine-entity" then
    -- Factorio 2.1: the mine-entity trigger names a list of entities (ResearchTrigger entities; 2.0: entity)
    local list, line = tr.entities or {tr.entity}, {""}
    for i = 1, math.min(#list, 5) do
      if i > 1 then line[#line + 1] = ", " end
      line[#line + 1] = thing("entity", list[i])
    end
    return {"ptt.trigger-mine-entity", line}
  end
  if kind == "build-entity" then return {"ptt.trigger-build-entity", thing("entity", tr.entity)} end
  if kind == "send-item-to-orbit" then return {"ptt.trigger-send-item-to-orbit", thing("item", tr.item)} end
  if kind == "scripted" and tr.trigger_description then return tr.trigger_description end
  return {"ptt.trigger-" .. kind}
end
M.trigger_text = trigger_text

-- "New": technologies that became available after a research finished, until the player selects them.
local function new_set(force)
  storage.ptt_new = storage.ptt_new or {}
  storage.ptt_new[force.index] = storage.ptt_new[force.index] or {}
  return storage.ptt_new[force.index]
end
local function is_new(p, n, st)
  if st ~= "available" and st ~= "trigger" then return false end
  local set = storage.ptt_new and storage.ptt_new[p.force.index]
  if not (set and set[n]) then return false end
  local seen = Prefs.prefs(p.index).seen_new
  return not (seen and seen[n])
end
local function mark_seen(p, n)
  local pr = Prefs.prefs(p.index)
  pr.seen_new = pr.seen_new or {}
  pr.seen_new[n] = true
end

-- Shared per-refresh context: researched snapshot, queue, goal and plan of the chain target.
local function context(p)
  local s, force = state(p), p.force
  local g = graph(p)
  local done = G.snapshot(force)
  local queue, qi = G.queue(force)
  local target = s.pinned or s.selected
  local ctx = { g=g, done=done, queue=queue, qi=qi, goal=Goal.get(force), mark=G.marker() }
  -- "N left" counters depend only on the researched set; reuse them for queue-only events.
  local sig = 0
  for _ in pairs(done) do sig = sig + 1 end
  if not (s.rcache and s.rcache.sig == sig) then s.rcache = { sig = sig, map = {} } end
  ctx.rcache = s.rcache.map
  ctx.plan = target and G.plan(g, force, target, done) or nil
  return ctx
end

local function marker(p, n, st, ctx)
  if st == "done" then return {"ptt.mark-done"}, COLORS.done end
  if st == "current" then
    return {"ptt.mark-current", math.floor(p.force.research_progress * 100)}, COLORS.current
  end
  if st == "queued" then return {"ptt.mark-queued", ctx.qi[n] or "?"}, COLORS.queued end
  if st == "available" then return {"ptt.mark-ready"}, COLORS.available end
  if st == "trigger" then return {"ptt.mark-trigger-" .. (trigger_kind(n) or "other")}, COLORS.trigger end
  if st == "disabled" then return {"ptt.mark-disabled"}, COLORS.disabled end
  local left = ctx.rcache[n]
  if not left then left = G.remaining(ctx.g, ctx.done, n, ctx.mark); ctx.rcache[n] = left end
  -- Single accent: technologies on the path to the selected one.
  local on_path = ctx.plan and ctx.plan.set[n]
  return {"ptt.mark-left", left}, on_path and COLORS.path or COLORS.locked
end

local function badge(p, n, st, ctx)
  if ctx.goal and ctx.goal.tech == n then return {"ptt.mark-goal"}, COLORS.goal end
  if opt(p, "mark_new") and is_new(p, n, st) then return {"ptt.mark-new"}, COLORS.new end
  return nil
end

-- Tooltip of a card or list row: name, status and the quick actions.
local function card_tooltip(p, n, st, ctx)
  local t = p.force.technologies[n]
  local node = ctx.g.nodes[n]
  local lines = {"", "[font=default-bold]", t.localised_name, "[/font]\n", {"ptt.status-" .. st}, "\n",
    {"ptt.card-stage", node and node.depth or "?"}}
  local cost = Effects.cost_text(t)
  if cost then lines[#lines + 1] = {"", "\n", cost} end
  lines[#lines + 1] = {"", "\n", {"ptt.card-actions"}}
  return lines
end

local function update_card(p, n, ctx)
  local s = state(p)
  local ref = s.refs and s.refs[n]
  if not (ref and ref.button.valid) then return end
  local st = G.status(p.force, n, ctx.qi, ctx)
  if ref.status ~= st then
    ref.button.style = STYLES[st]; ref.button.style.size = ref.size
    ref.status = st
    local tip = card_tooltip(p, n, st, ctx)
    ref.tip.tooltip = tip
    if not ref.elem then ref.button.tooltip = tip end
  end
  ref.button.toggled = s.selected == n
  if ref.row and ref.row.valid then ref.row.toggled = s.selected == n end
  if ref.name and ref.name.valid then ref.name.style.font_color = st == "done" and COLORS.dim or COLORS.name end
  local caption, color = marker(p, n, st, ctx)
  if ref.prefix then caption = {"", ref.prefix, caption} end
  ref.marker.caption = caption; ref.marker.style.font_color = color
  local b, bcolor = badge(p, n, st, ctx)
  if ref.badge and ref.badge.valid then
    -- In list rows the label keeps its table cell: a hidden child takes no cell and shifts the columns.
    ref.badge.caption = b or ""
    if not ref.row then ref.badge.visible = b ~= nil end
    if bcolor then ref.badge.style.font_color = bcolor end
  end
end

-- `prefix`: rich text before the name (science pack icon of the era in flat search results).
local function card(parent, p, n, ctx, size, prefix)
  local s = state(p)
  local t = p.force.technologies[n]
  local tags = {ptt=true, action="select", tech=n}
  local reason = s.reasons and s.reasons[n]
  local c = parent.add{type="frame", direction="vertical", style="inside_shallow_frame", tags=tags}
  c.style.padding = 8; c.style.width = size + CARD_EXTRA
  -- Search results keep one height for all cards, with room for the "Unlocks: …" line.
  c.style.height = size + 66 + (s.searching and 18 or 0)
  local top = c.add{type="flow", direction="horizontal", tags=tags}
  top.style.horizontal_spacing = 8
  local elem = opt(p, "rich_tooltip") and {type="technology", name=n} or nil
  local b = top.add{type="sprite-button", sprite="technology/" .. n, style="slot_sized_button", tags=tags,
    elem_tooltip=elem}
  b.style.size = size
  local info = top.add{type="flow", direction="vertical", tags=tags}
  info.style.vertical_spacing = 2
  local m = info.add{type="label", tags=tags}; m.style.font = "default-small-semibold"
  m.style.maximal_width = CARD_EXTRA - 24; m.style.single_line = false
  local bl = info.add{type="label", tags=tags}; bl.style.font = "default-small-semibold"
  local name = c.add{type="label", caption=prefix and {"", prefix, t.localised_name} or t.localised_name, tags=tags}
  name.style.single_line = false; name.style.maximal_width = size + CARD_EXTRA - 16
  name.style.maximal_height = 40; name.style.top_margin = 4
  if reason then
    local r = c.add{type="label", caption={"ptt.found-in", reason}, tags=tags, tooltip={"ptt.found-in", reason}}
    r.style.font = "default-small"; r.style.font_color = COLORS.dim
    r.style.maximal_width = size + CARD_EXTRA - 16
  end
  s.cards[n] = c
  s.refs[n] = { button=b, name=name, marker=m, badge=bl, tip=c, elem=elem ~= nil, size=size }
  update_card(p, n, ctx)
end

-- List view: one row per technology (icon, name, status, cost or condition, mark).
local function list_row(tbl, p, n, ctx, name_width, prefix)
  local s = state(p)
  local t = p.force.technologies[n]
  local tags = {ptt=true, action="select", tech=n}
  local elem = opt(p, "rich_tooltip") and {type="technology", name=n} or nil
  local b = tbl.add{type="sprite-button", sprite="technology/" .. n, style="slot_sized_button", tags=tags,
    elem_tooltip=elem}
  b.style.size = 32
  local reason = s.reasons and s.reasons[n]
  local caption = reason and {"", t.localised_name, "   [color=0.6,0.6,0.6]", {"ptt.found-in", reason}, "[/color]"}
    or t.localised_name
  local row = tbl.add{type="button", style="list_box_item", caption=caption, tags=tags}
  row.style.width = name_width; row.style.height = 32
  local m = tbl.add{type="label", tags=tags}; m.style.width = 120; m.style.font = "default-small-semibold"
  local cost = t.prototype.research_trigger and "" or (Effects.cost_text(t) or "")
  local cl = tbl.add{type="label", caption=cost, tags=tags}; cl.style.width = 240
  local bl = tbl.add{type="label", tags=tags}; bl.style.font = "default-small-semibold"; bl.style.width = 60
  s.cards[n] = row
  s.refs[n] = { button=b, row=row, marker=m, badge=bl, tip=row, elem=elem ~= nil, size=32, prefix=prefix }
  update_card(p, n, ctx)
end

local function expanded(s, key, default)
  if s.expanded[key] ~= nil then return s.expanded[key] end
  return default
end

local function count_done(names, done)
  local k = 0
  for _, n in ipairs(names) do if done[n] then k = k + 1 end end
  return k
end

local function columns(p, s)
  local cw = SIZES[opt(p, "size")] + CARD_EXTRA
  return math.max(1, math.floor((s.tree_width + GAP) / (cw + GAP)))
end

-- Open the era containing `name` (and its researched cards if needed) so its card exists.
local function reveal(p, name)
  local s, g = state(p), graph(p)
  local key = g.era_of[name]
  if not key then return end
  s.expanded[key] = true
  local t = p.force.technologies[name]
  if t and t.researched then s.expanded[key .. "/done"] = true end
end

function M.focus(p)
  local s = state(p)
  if not (s.scroll and s.scroll.valid) then return end
  if s.cards and s.focus_key and s.headers and s.headers[s.focus_key] and s.headers[s.focus_key].valid then
    s.scroll.scroll_to_element(s.headers[s.focus_key], "top-third")
  elseif s.cards and s.selected and s.cards[s.selected] and s.cards[s.selected].valid then
    s.scroll.scroll_to_element(s.cards[s.selected], "top-third")
  else
    s.scroll.scroll_to_top()
  end
end

-- Selected technology when the window opens: by the player's setting, then the last one, the force goal,
-- the current research, anything available.
local function choose(p, on_open)
  local s, g = state(p), graph(p)
  local goal = Goal.get(p.force)
  local q = p.force.research_queue
  local current = q and q[1] and q[1].name
  if on_open then
    local mode = opt(p, "open_with")
    if mode == "goal" and goal and g.nodes[goal.tech] then s.selected = goal.tech; return end
    if mode == "current" and current and g.nodes[current] then s.selected = current; return end
  end
  if s.selected and g.nodes[s.selected] then return end
  if goal and g.nodes[goal.tech] then s.selected = goal.tech; return end
  if current and g.nodes[current] then s.selected = current; return end
  for d = 1, g.max_depth do
    for _, n in ipairs(g.layers[d] or {}) do
      if G.status(p.force, n) == "available" then s.selected = n; return end
    end
  end
  s.selected = g.names[1]
end

-- Era navigator ---------------------------------------------------------------------------------------

local function era_by_key(g, key)
  for _, e in ipairs(g.eras) do if e.key == key then return e end end
  return nil
end

local function nav(p, ctx, shown)
  local s = state(p)
  if not (s.nav and s.nav.valid) then return end
  s.nav.clear(); s.nav_buttons = {}; s.nav_bars = {}
  for _, era in ipairs(ctx.g.eras) do
    if shown[era.key] then
      local f = s.nav.add{type="flow", direction="vertical"}
      f.style.vertical_spacing = 0
      local b = f.add{type="button", style="list_box_item", tags=tags_of("nav", {key=era.key})}
      b.style.width = NAV_WIDTH - 28; b.style.height = 28
      b.tooltip = {"", pack_caption(era.item), "\n", {"ptt.nav-hint"}}
      local bar = f.add{type="progressbar", value=0}
      bar.style.width = NAV_WIDTH - 28; bar.style.bar_width = 4; bar.style.color = COLORS.done
      s.nav_buttons[era.key] = b; s.nav_bars[era.key] = bar
    end
  end
  M.nav_captions(p, ctx, shown)
end

function M.nav_captions(p, ctx, shown)
  local s = state(p)
  local current = s.selected and ctx.g.era_of[s.selected]
  for key, b in pairs(s.nav_buttons or {}) do
    local info = shown[key]
    if b.valid and info then
      local era = era_by_key(ctx.g, key)
      local icon = era.item and ("[item=" .. era.item .. "]  ") or ""
      local name = era.item and "" or {"ptt.era-none-short"}
      local done = count_done(info, ctx.done)
      b.caption = {"", icon, name, " ", done, " / ", #info}
      b.toggled = key == current
      local bar = s.nav_bars and s.nav_bars[key]
      if bar and bar.valid then bar.value = #info > 0 and done / #info or 0 end
    end
  end
end

-- Technology tree ---------------------------------------------------------------------------------------

-- Header and content of one era. Rebuilt alone when the era or its researched cards are toggled.
local function fill_era(p, block, era, names, ctx)
  local s = state(p)
  block.clear()
  local key = era.key
  local done = count_done(names, ctx.done)
  local forced = s.searching or s.filtered
  local default
  if s.chain then
    default = done ~= #names
  else
    -- Full view: open only eras with something to research now.
    default = false
    for _, n in ipairs(names) do
      if ACTIONABLE[G.status(p.force, n, ctx.qi, ctx)] then default = true; break end
    end
  end
  local open = forced or expanded(s, key, default)
  local show_done = forced or expanded(s, key .. "/done", opt(p, "show_done"))
  s.open_now[key] = open; s.open_now[key .. "/done"] = show_done
  local head = block.add{type="flow", direction="horizontal"}
  head.style.vertical_align = "center"; head.style.horizontal_spacing = 8
  if not forced then
    mini(head, "toggle", open and "−" or "+", {open and "ptt.collapse" or "ptt.expand"}, {key=key})
  end
  local label = head.add{type="label", caption=pack_caption(era.item), style="heading_2_label"}
  local bar = head.add{type="progressbar", value=#names > 0 and done / #names or 0}
  bar.style.width = 120; bar.style.color = COLORS.done
  local count = head.add{type="label", caption={"ptt.era-count", done, #names}}
  count.style.font_color = done == #names and COLORS.done or COLORS.name
  if open and done > 0 and done < #names and not forced then
    local tb = button(head, "toggle", {"ptt.show-done", done}, {key=key .. "/done"})
    tb.toggled = show_done; tb.style.height = 24; tb.style.font = "default-small"; tb.style.left_margin = 8
    tb.tooltip = {show_done and "ptt.hide-done" or "ptt.show-done-hint"}
  end
  s.headers[key] = head; s.era_labels[key] = {label=label, bar=bar, count=count}
  if not open then return end
  local all_done = done == #names
  if opt(p, "view") == "list" then
    local tbl = block.add{type="table", column_count=5}
    tbl.style.horizontal_spacing = 8; tbl.style.vertical_spacing = 2; tbl.style.left_margin = 4
    local name_width = math.max(160, s.tree_width - LIST_FIXED)
    for _, n in ipairs(names) do
      if show_done or all_done or not ctx.done[n] then list_row(tbl, p, n, ctx, name_width) end
    end
  else
    local grid = block.add{type="table", column_count=columns(p, s)}
    grid.style.horizontal_spacing = GAP; grid.style.vertical_spacing = GAP
    local size = SIZES[opt(p, "size")]
    for _, n in ipairs(names) do
      if show_done or all_done or not ctx.done[n] then card(grid, p, n, ctx, size) end
    end
  end
end

-- Search results: one grid (or list) for all eras in era order, the era shown by its pack icon on each card.
-- The navigator scrolls to the first result of an era.
local function fill_flat(p, block, eras, shown, ctx)
  local s = state(p)
  local list = opt(p, "view") == "list"
  local parent
  if list then
    parent = block.add{type="table", column_count=5}
    parent.style.horizontal_spacing = 8; parent.style.vertical_spacing = 2; parent.style.left_margin = 4
  else
    parent = block.add{type="table", column_count=columns(p, s)}
    parent.style.horizontal_spacing = GAP; parent.style.vertical_spacing = GAP
  end
  local size = SIZES[opt(p, "size")]
  local name_width = math.max(160, s.tree_width - LIST_FIXED)
  for _, era in ipairs(eras) do
    local names = shown[era.key]
    if names then
      local prefix = era.item and ("[item=" .. era.item .. "] ") or nil
      for _, n in ipairs(names) do
        if list then list_row(parent, p, n, ctx, name_width, prefix) else card(parent, p, n, ctx, size, prefix) end
      end
      s.headers[era.key] = s.cards[names[1]]
    end
  end
end

function M.tree(p, focus)
  local s, g = state(p), graph(p)
  if not (root(p) and s.scroll and s.scroll.valid) then return end
  s.scroll.clear(); s.cards = {}; s.refs = {}; s.headers = {}; s.era_labels = {}; s.open_now = {}; s.blocks = {}
  s.reasons = {}; s.first_shown = nil
  local ctx = context(p)
  local stack = s.scroll.add{type="flow", direction="vertical"}
  stack.style.vertical_spacing = 12; stack.style.padding = 12
  local flt = Prefs.filters(p.index)
  local fstatus = flt.status or "all"
  local fpack = flt.pack
  if fpack and not era_by_key(g, fpack) then fpack = nil; flt.pack = nil end
  local query = G.lower(s.query)
  local searching = query ~= ""
  s.searching = searching; s.filtered = fstatus ~= "all" or fpack ~= nil
  local subset = (s.chain and not searching) and G.chain(g, s.pinned or s.selected) or nil
  local show_disabled, show_trigger = opt(p, "show_disabled"), opt(p, "show_trigger")
  local function keep(n)
    if fpack and g.era_of[n] ~= fpack then return false end
    local st = G.status(p.force, n, ctx.qi, ctx)
    if fstatus ~= "all" then
      if not STATUS_MATCH[fstatus][st] then return false end
    else
      if not show_disabled and st == "disabled" then return false end
      if not show_trigger and g.trigger[n] then return false end
    end
    if searching then
      local m = Search.match(s, n, query)
      if not m then return false end
      if type(m) == "string" then s.reasons[n] = m end
      return true
    end
    return not subset or subset[n]
  end
  local total, shown = 0, {}
  for _, era in ipairs(g.eras) do
    local names = {}
    for _, d in ipairs(era.depths) do
      for _, n in ipairs(era.layers[d]) do if keep(n) then names[#names + 1] = n end end
    end
    if #names > 0 then
      shown[era.key] = names
      s.first_shown = s.first_shown or names[1]
      if not searching then
        local block = stack.add{type="flow", direction="vertical"}
        block.style.vertical_spacing = 8
        s.blocks[era.key] = block
        fill_era(p, block, era, names, ctx)
      end
      total = total + #names
    end
  end
  if searching and total > 0 then fill_flat(p, stack, g.eras, shown, ctx) end
  if total == 0 then
    local key = searching and "ptt.no-results" or (s.filtered and "ptt.no-results-filter" or "ptt.no-results-chain")
    local l = text(stack, {key}, 520); l.style.font_color = COLORS.dim
  end
  s.shown = total
  s.shown_eras = shown
  if s.summary and s.summary.valid then
    local t = s.selected and p.force.technologies[s.pinned or s.selected]
    if searching then s.summary.caption = {"ptt.summary-search", s.query, total}
    elseif s.filtered then s.summary.caption = {"ptt.summary-filter", total}
    elseif s.chain and t then s.summary.caption = {"ptt.summary-chain", t.localised_name, total}
    else s.summary.caption = {"ptt.summary-all", total} end
  end
  nav(p, ctx, shown)
  if focus then
    M.focus(p)
    -- Native scroll bounds settle after layout; repeat once on the next update.
    s.focus_due = game.tick + 1
  else
    s.focus_key = nil
  end
end

-- Rebuild one era after its toggle; the rest of the tree, refs and scroll position stay.
local function refill_era(p, key)
  local s = state(p)
  local block = s.blocks and s.blocks[key]
  local names = s.shown_eras and s.shown_eras[key]
  local era = era_by_key(graph(p), key)
  if not (block and block.valid and names and era) then M.tree(p, true); return end
  for _, n in ipairs(names) do s.refs[n] = nil; s.cards[n] = nil end
  fill_era(p, block, era, names, context(p))
end

-- Goal and queue -----------------------------------------------------------------------------------------

-- Goal in the queue row: one clickable line, pause/resume and a small clear button.
function M.goal_line(p, ctx)
  local s = state(p)
  if not (s.goal_flow and s.goal_flow.valid) then return end
  s.goal_flow.clear()
  local goal = ctx.goal
  if not goal then
    local l = s.goal_flow.add{type="label", caption={"ptt.goal-none"}}
    l.style.font_color = COLORS.dim; l.tooltip = {"ptt.goal-hint"}
    return
  end
  local t = p.force.technologies[goal.tech]
  if not t then return end
  local plan = G.plan(ctx.g, p.force, goal.tech, ctx.done)
  local by = (goal.by and goal.by ~= "") and goal.by or "?"
  local b = button(s.goal_flow, "select", {"ptt.goal-line", t.localised_name, plan and plan.count or 0},
    {tech=goal.tech, jump=true})
  b.style.font_color = COLORS.goal; b.style.height = 28
  b.tooltip = {"ptt.goal-line-hint", by}
  if goal.paused then
    local pt = p.force.technologies[goal.paused]
    local l = s.goal_flow.add{type="label", caption={"ptt.goal-paused-line", pt and pt.localised_name or goal.paused}}
    l.style.font_color = COLORS.warn
    local r = button(s.goal_flow, "goal_resume", {"ptt.goal-resume"}); r.style.height = 28
  end
  mini(s.goal_flow, "goal_clear", "×", {"ptt.goal-clear"})
end

-- Research queue: icons only. Click selects, Shift+click moves up, right click or × removes.
-- Items placed by the goal use a yellow frame.
function M.queue_bar(p, ctx)
  local s = state(p)
  if not (s.queue_flow and s.queue_flow.valid) then return end
  s.queue_flow.clear(); s.progress = nil
  local ql = s.queue_flow.add{type="label", caption={"ptt.queue"}, style="caption_label"}
  ql.tooltip = {"ptt.queue-hint"}; ql.style.right_margin = 4
  local force = p.force
  local goal = ctx.goal
  for i = 1, math.max(QUEUE_SLOTS, #ctx.queue) do
    local n = ctx.queue[i]
    local slot = s.queue_flow.add{type="flow", direction="horizontal"}
    slot.style.horizontal_spacing = 0
    if n then
      local t = force.technologies[n]
      local ours = goal and goal.ours and goal.ours[n]
      local style = i == 1 and "slot_sized_button_blue" or (ours and "yellow_slot_button" or "slot_sized_button")
      local b = slot.add{type="sprite-button", sprite="technology/" .. n, style=style,
        tags={ptt=true, action="q_slot", tech=n, index=i},
        tooltip={"", t.localised_name, "\n", {"ptt.status-" .. (i == 1 and "current" or "queued")},
          ours and {"", "\n", {"ptt.queue-goal"}} or "", "\n", {"ptt.queue-hint"}}}
      b.style.size = 40
      if i == 1 then
        b.number = math.floor(force.research_progress * 100)
        s.progress = b
      end
      mini(slot, "q_remove", "×", {"ptt.queue-remove"}, {index=i})
    else
      local e = slot.add{type="sprite-button", style="slot_sized_button", enabled=false}
      e.style.size = 40
      local pad = slot.add{type="empty-widget"}; pad.style.width = 20
    end
  end
end

-- Does `n` (transitively) require `p`?
function M.depends(g, n, p)
  if not p then return false end
  local seen, stack = {[n]=true}, {n}
  while #stack > 0 do
    local c = table.remove(stack)
    for _, x in ipairs(g.pre[c] or {}) do
      if x == p then return true end
      if not seen[x] then seen[x] = true; stack[#stack + 1] = x end
    end
  end
  return false
end

-- Selected technology panel --------------------------------------------------------------------------------

local function techbutton(parent, p, name, size, st)
  local t = p.force.technologies[name]
  if not t then return end
  st = st or G.status(p.force, name)
  local s = state(p)
  local b = parent.add{type="sprite-button", sprite="technology/" .. name, style=STYLES[st],
    tooltip={"", t.localised_name, "\n", {"ptt.status-" .. st}},
    tags={ptt=true, action="select", tech=name, jump=true}, toggled=s.selected == name}
  b.style.size = size
  if s.collect_panel_buttons then
    s.panel_buttons[#s.panel_buttons + 1] = {button=b, tech=name, size=size}
  end
  return b
end

local function panel_columns(s, size) return math.max(3, math.floor((s.panel_width - 40) / (size + 4))) end

local function tech_table(parent, p, names, ctx)
  local s = state(p)
  local tbl = parent.add{type="table", column_count=panel_columns(s, 48)}
  for _, n in ipairs(names) do techbutton(tbl, p, n, 48, G.status(p.force, n, ctx.qi, ctx)) end
  return tbl
end

local function slots(parent, s, list)
  local tbl = parent.add{type="table", column_count=panel_columns(s, 40)}
  for _, x in ipairs(list) do
    tbl.add{type="sprite-button", sprite=x.sprite, number=x.number, elem_tooltip=x.elem, style="slot_button"}
  end
  return tbl
end

function M.panel(p, queue_only)
  local s = state(p)
  if not root(p) or not (s.panel and s.panel.valid) then return end
  if queue_only and s.panel_buttons then
    local ctx = context(p)
    for _, ref in ipairs(s.panel_buttons) do
      if ref.button.valid then
        local status = G.status(p.force, ref.tech, ctx.qi, ctx)
        ref.button.style = STYLES[status]; ref.button.style.size = ref.size
        ref.button.tooltip = {"", p.force.technologies[ref.tech].localised_name, "\n", {"ptt.status-" .. status}}
      end
    end
    for name, add in pairs(s.panel_add or {}) do
      if add.valid then add.enabled = G.status(p.force, name, ctx.qi, ctx) == "available" end
    end
    local status = s.selected and G.status(p.force, s.selected, ctx.qi, ctx)
    if s.panel_research and s.panel_research.valid then s.panel_research.enabled = status == "available" end
    if s.panel_status and s.panel_status.valid and status then
      s.panel_status.caption = {"ptt.status-" .. status}; s.panel_status.style.font_color = COLORS[status]
    end
    if s.panel_notice and s.panel_notice.valid then
      s.panel_notice.caption = s.notice or ""; s.panel_notice.visible = s.notice ~= nil
    end
    return
  end
  local body = s.panel; body.clear()
  s.panel_buttons = {}; s.panel_add = {}; s.collect_panel_buttons = true
  local t = s.selected and p.force.technologies[s.selected]
  if s.panel_title and s.panel_title.valid then s.panel_title.caption = t and t.localised_name or {"ptt.selected"} end
  if not t then s.collect_panel_buttons = nil; text(body, {"ptt.select-hint"}); return end
  local ctx = context(p)
  local width = s.panel_width - 36
  local force = p.force
  -- Head: icon, status, description.
  local head = body.add{type="flow", direction="horizontal"}
  head.style.horizontal_spacing = 12
  techbutton(head, p, t.name, 64)
  local hv = head.add{type="flow", direction="vertical"}
  hv.style.vertical_spacing = 4
  local st = G.status(force, t.name)
  local l = text(hv, {"ptt.status-" .. st}, width - 76); l.style.font = "default-semibold"
  l.style.font_color = COLORS[st]
  s.panel_status = l
  if t.prototype.max_level and t.prototype.max_level > 1 then
    local lv = text(hv, {"ptt.level", t.level}, width - 76); lv.style.font_color = COLORS.dim
  end
  local d = text(body, {"?", t.localised_description, ""}, width); d.style.font_color = COLORS.dim
  -- Cost and actions.
  section(body, {"ptt.cost"})
  if t.prototype.research_trigger then
    local cond = text(body, trigger_text(t.name), width); cond.style.font_color = COLORS.trigger
    text(body, {"ptt.trigger-hint"}, width).style.font_color = COLORS.dim
  else
    local list = {}
    for _, i in ipairs(t.research_unit_ingredients or {}) do
      list[#list + 1] = {sprite="item/" .. i.name, number=i.amount, elem={type="item", name=i.name}}
    end
    slots(body, s, list)
    text(body, {"ptt.units", t.research_unit_count, t.research_unit_energy / 60}, width)
    local time = text(body, {"ptt.time", Effects.duration(Effects.seconds(force, t))}, width)
    time.tooltip = {"ptt.time-hint", Effects.number(force.laboratory_speed_modifier or 0, true)}
  end
  local actions = body.add{type="flow", direction="horizontal"}
  actions.style.horizontal_spacing = 8; actions.style.top_margin = 4
  local half = math.floor((width - 8) / 2)
  local b = button(actions, "research", {"ptt.research"})
  b.style.width = half; b.tooltip = {"ptt.research-hint"}
  b.enabled = st == "available"
  s.panel_research = b
  local goal = ctx.goal
  local gb
  if goal and goal.tech == t.name then
    gb = button(actions, "goal_clear", {"ptt.goal-clear"})
  else
    gb = button(actions, "goal_set", {"ptt.goal-set-button"}); gb.tooltip = {"ptt.goal-hint"}
    gb.enabled = st ~= "done"
  end
  gb.style.width = half
  s.panel_notice = text(body, s.notice or "", width)
  s.panel_notice.visible = s.notice ~= nil
  -- What it gives.
  local recipes = Effects.recipes(t)
  local bonuses = Effects.bonuses(t)
  section(body, {"ptt.unlocks"})
  if #recipes > 0 then
    local list = {}
    for _, r in ipairs(recipes) do list[#list + 1] = {sprite="recipe/" .. r, elem={type="recipe", name=r}} end
    slots(body, s, list)
  end
  for _, bonus in ipairs(bonuses) do
    local row = body.add{type="flow", direction="horizontal"}
    row.style.vertical_align = "center"; row.style.horizontal_spacing = 8
    if bonus.sprite then
      local icon = row.add{type="sprite", sprite=bonus.sprite}
      icon.style.size = 24; icon.style.stretch_image_to_widget_size = true
    end
    text(row, bonus.text, width - 32)
  end
  if #recipes == 0 and #bonuses == 0 then text(body, {"ptt.unlocks-none"}, width).style.font_color = COLORS.dim end
  -- Path to the selected technology.
  local plan = st ~= "done" and G.plan(ctx.g, force, t.name, ctx.done) or nil
  if plan then
    section(body, {"ptt.path"})
    local seconds = 0
    for n in pairs(plan.set) do seconds = seconds + Effects.seconds(force, force.technologies[n]) end
    text(body, {"ptt.path-count", plan.count, Effects.duration(seconds)}, width)
    local list = {}
    for _, c in ipairs(plan.cost) do
      list[#list + 1] = {sprite="item/" .. c.name, number=c.amount, elem={type="item", name=c.name}}
    end
    local costs = #list > 0 and slots(body, s, list) or nil
    local gain, after, now = nil, nil, nil
    if opt(p, "evolution") then gain, after, now = path_evolution(p, plan) end
    if gain then
      costs = costs or body.add{type="table", column_count=5}
      local tip = {"ptt.path-evolution-tip", percent(gain), percent(now), percent(after)}
      local cell = costs.add{type="flow", direction="horizontal"}
      cell.style.vertical_align = "center"; cell.style.height = 40; cell.style.horizontal_spacing = 2
      cell.add{type="label", caption="+", style="heading_2_label", tooltip=tip}
      if helpers.is_valid_sprite_path(EVOLUTION_SPRITE) then
        local icon = cell.add{type="sprite", sprite=EVOLUTION_SPRITE, tooltip=tip}
        icon.style.size = 28; icon.style.stretch_image_to_widget_size = true
      end
      local el = cell.add{type="label", caption={"ptt.path-evolution", percent(gain)}, tooltip=tip}
      el.style.font = "default-bold"; el.style.font_color = COLORS.warn
    end
    if #plan.ready > 0 then
      local r = section(body, {"ptt.path-ready", #plan.ready}); r.style.font_color = COLORS.available
      local ready = body.add{type="table", column_count=math.max(2, math.floor((s.panel_width - 40) / 72))}
      for _, name in ipairs(plan.ready) do
        local cell = ready.add{type="flow", direction="horizontal"}
        cell.style.horizontal_spacing = 0
        cell.style.vertical_align = "center"
        local status = G.status(force, name, ctx.qi, ctx)
        techbutton(cell, p, name, 48, status)
        local add = mini(cell, "queue_one", "+", {"ptt.queue-one", force.technologies[name].localised_name}, {tech=name})
        add.enabled = status == "available"
        s.panel_add[name] = add
      end
    end
    if #plan.triggers > 0 then
      local r = section(body, {"ptt.path-triggers", #plan.triggers}); r.style.font_color = COLORS.trigger
      tech_table(body, p, plan.triggers, ctx)
    end
    if #plan.blocked > 0 then
      local r = section(body, {"ptt.path-blocked", #plan.blocked}); r.style.font_color = COLORS.warn
      tech_table(body, p, plan.blocked, ctx)
    end
    local rest = 0
    for k = 2, #plan.waves do
      if k <= MAX_WAVES then
        section(body, {"ptt.path-wave", k, #plan.waves[k]})
        tech_table(body, p, plan.waves[k], ctx)
      else rest = rest + #plan.waves[k] end
    end
    if rest > 0 then text(body, {"ptt.path-more", rest, #plan.waves - MAX_WAVES}, width) end
  end
  local parents = sorted_keys(t.prerequisites)
  section(body, {"ptt.parents"})
  if #parents > 0 then tech_table(body, p, parents, ctx) else text(body, {"ptt.parents-none"}, width).style.font_color = COLORS.dim end
  local node = ctx.g.nodes[t.name]
  local children = node and node.children or {}
  section(body, {"ptt.children"})
  if #children > 0 then tech_table(body, p, children, ctx) else text(body, {"ptt.children-none"}, width).style.font_color = COLORS.dim end
  s.collect_panel_buttons = nil
end

-- Toolbar state: view switch, pin, grid/list, filters button, search status.
local function update_view(p)
  local s = state(p)
  if s.view_all and s.view_all.valid then
    s.view_all.toggled = not s.chain
    s.view_chain.toggled = s.chain and true or false
    s.pin_button.enabled = s.chain and true or false
    s.pin_button.toggled = s.pinned ~= nil
    local list = opt(p, "view") == "list"
    s.grid_button.toggled = not list; s.list_button.toggled = list
  end
  if s.filters_button and s.filters_button.valid then
    local flt = Prefs.filters(p.index)
    local active = ((flt.status or "all") ~= "all" and 1 or 0) + (flt.pack and 1 or 0)
    s.filters_button.caption = active > 0 and {"ptt.filters-active", active} or {"ptt.filters"}
    s.filters_button.toggled = s.filters_open and true or false
    if s.filter_row and s.filter_row.valid then s.filter_row.visible = s.filters_open and true or false end
  end
end

-- Popups: settings and help ---------------------------------------------------------------------------------

local function popup(p, name, title)
  local f = p.gui.screen.add{type="frame", name=name, direction="vertical"}
  titlebar(f, title, "popup_close", {popup=name})
  local pane = f.add{type="frame", style="inside_shallow_frame_with_padding", direction="vertical"}
  local content = pane.add{type="flow", direction="vertical"}
  content.style.vertical_spacing = 8
  return f, content
end

local function index_of(list, value)
  for i, v in ipairs(list) do if v == value then return i end end
  return 1
end

local function settings_window(p)
  local f, c = popup(p, SETTINGS, {"ptt.settings-title"})
  local tbl = c.add{type="table", column_count=2}
  tbl.style.horizontal_spacing = 16; tbl.style.vertical_spacing = 8
  tbl.style.column_alignments[1] = "middle-left"
  local function row(key, items, values)
    local l = tbl.add{type="label", caption={"ptt.opt-" .. key}, tooltip={"ptt.opt-" .. key .. "-hint"}}
    l.style.width = 200
    local dd = tbl.add{type="drop-down", items=items, selected_index=index_of(values, opt(p, key)),
      tags=tags_of("pref", {key=key}), tooltip={"ptt.opt-" .. key .. "-hint"}}
    dd.style.width = 240
  end
  local window_items, size_items, view_items, open_items = {}, {}, {}, {}
  for _, v in ipairs(Prefs.WINDOW) do window_items[#window_items + 1] = {"ptt.opt-window-value", v} end
  for _, v in ipairs(SIZES) do size_items[#size_items + 1] = {"ptt.opt-size-value", v} end
  for _, v in ipairs(Prefs.VIEW) do view_items[#view_items + 1] = {"ptt.opt-view-" .. v} end
  for _, v in ipairs(Prefs.OPEN_WITH) do open_items[#open_items + 1] = {"ptt.opt-open_with-" .. v} end
  row("window", window_items, Prefs.WINDOW)
  row("size", size_items, {1, 2, 3, 4})
  row("view", view_items, Prefs.VIEW)
  row("open_with", open_items, Prefs.OPEN_WITH)
  local flags = c.add{type="flow", direction="vertical"}
  flags.style.vertical_spacing = 6; flags.style.top_margin = 4
  for _, key in ipairs(Prefs.FLAGS) do
    flags.add{type="checkbox", caption={"ptt.opt-" .. key}, state=opt(p, key) and true or false,
      tooltip={"ptt.opt-" .. key .. "-hint"}, tags=tags_of("pref_flag", {key=key})}
  end
  local bottom = c.add{type="flow", direction="horizontal"}
  bottom.style.top_margin = 8
  pusher(bottom)
  local reset = button(bottom, "settings_reset", {"ptt.settings-reset"})
  reset.tooltip = {"ptt.settings-reset-hint"}
  f.force_auto_center()
  return f
end

-- Help block: one "what to do now" line plus how to use and the colour legend.
local function next_step(p, ctx)
  local s = state(p)
  local goal = ctx.goal
  if goal and goal.paused then return {"ptt.help-step-paused"}, COLORS.warn end
  if goal then return {"ptt.help-step-goal"}, COLORS.done end
  if not s.user_selected then return {"ptt.help-step-select"}, COLORS.available end
  local t = s.selected and p.force.technologies[s.selected]
  if t and t.researched then return {"ptt.help-step-done"}, COLORS.available end
  return {"ptt.help-step-set-goal"}, COLORS.available
end

local HELP_LINES = 8
local function help_window(p)
  local f, c = popup(p, HELP, {"ptt.help-title"})
  local width = 440
  local step, color = next_step(p, context(p))
  local l = text(c, step, width); l.style.font = "default-semibold"; l.style.font_color = color
  for k = 1, HELP_LINES do text(c, {"ptt.help-" .. k}, width) end
  f.force_auto_center()
  return f
end

local function toggle_popup(p, name)
  local f = p.gui.screen[name]
  if f then f.destroy(); return end
  if name == SETTINGS then settings_window(p) else help_window(p) end
end
M.toggle_popup = toggle_popup

local function close_popups(p)
  for _, name in ipairs({SETTINGS, HELP}) do
    local f = p.gui.screen[name]
    if f then f.destroy() end
  end
end

-- Window --------------------------------------------------------------------------------------------------

function M.search_status(p)
  local s = state(p)
  local l = s.search_status
  if not (l and l.valid) then return end
  local pct = Search.percent(p, s)
  l.visible = pct < 100
  if pct < 100 then l.caption = {"ptt.search-preparing", pct} end
end

function M.close(p, keep_popups)
  local s = state(p)
  local r = root(p)
  if r then r.destroy() end
  if not keep_popups then close_popups(p) end
  Toolbar.sync(p, false)
  s.scroll = nil; s.panel = nil; s.cards = nil; s.refs = nil; s.open = false; s.blocks = nil
  s.nav = nil; s.queue_flow = nil; s.goal_flow = nil; s.progress = nil; s.headers = nil
  s.view_all = nil; s.view_chain = nil; s.pin_button = nil; s.grid_button = nil; s.list_button = nil
  s.search_status = nil; s.search_field = nil; s.summary = nil; s.panel_title = nil
  s.filters_button = nil; s.filter_row = nil; s.status_dd = nil; s.pack_dd = nil
end

local function filter_row(p, parent, g)
  local s = state(p)
  local flt = Prefs.filters(p.index)
  local fr = parent.add{type="flow", direction="horizontal"}
  fr.style.padding = {8, 12, 0, 12}; fr.style.horizontal_spacing = 8; fr.style.vertical_align = "center"
  fr.add{type="label", caption={"ptt.filter-status"}}
  local items = {}
  for _, k in ipairs(STATUS_FILTERS) do items[#items + 1] = {"ptt.filter-" .. k} end
  s.status_dd = fr.add{type="drop-down", items=items, selected_index=index_of(STATUS_FILTERS, flt.status or "all"),
    tags=tags_of("filter_status")}
  s.status_dd.style.width = 220
  local pl = fr.add{type="label", caption={"ptt.filter-pack"}}; pl.style.left_margin = 12
  local packs, keys = {{"ptt.filter-pack-all"}}, {false}
  for _, era in ipairs(g.eras) do packs[#packs + 1] = pack_caption(era.item); keys[#keys + 1] = era.key end
  s.pack_keys = keys
  local sel = 1
  for i, k in ipairs(keys) do if k == flt.pack then sel = i end end
  s.pack_dd = fr.add{type="drop-down", items=packs, selected_index=sel, tags=tags_of("filter_pack")}
  s.pack_dd.style.width = 320
  local reset = button(fr, "filters_reset", {"ptt.filters-reset"}); reset.style.left_margin = 12
  s.filter_row = fr
end

function M.open(p)
  if root(p) then return end
  -- Scripts may enable/disable technologies during play; rebuild the cached graph if needed.
  local graphs = storage.native_graphs
  if graphs and graphs[p.force.index] and G.stale(graphs[p.force.index], p.force.technologies) then
    graphs[p.force.index] = nil
  end
  local s = state(p); choose(p, true)
  local g = graph(p)
  local scale = p.display_scale
  local sw = math.floor(p.display_resolution.width / scale)
  local sh = math.floor(p.display_resolution.height / scale)
  local pct = opt(p, "window") / 100
  local w = math.min(sw, math.max(960, math.floor(sw * pct)))
  local h = math.min(sh, math.max(560, math.floor(sh * pct)))
  local pw = math.max(300, math.min(380, math.floor(w * 0.24)))
  s.panel_width = pw
  -- Usable width of the technology pane: window padding, both side panes, gaps, inner padding, scroll bar.
  s.tree_width = w - 22 - NAV_WIDTH - pw - 24 - 24 - 16
  local r = p.gui.screen.add{type="frame", name=ROOT, direction="vertical"}
  r.style.width = w; r.style.height = h
  local loc = Prefs.prefs(p.index).location
  if pct >= 1 then
    r.location = {0, 0}
  elseif loc and loc.x >= 0 and loc.y >= 0 and loc.x + w * scale <= p.display_resolution.width
      and loc.y + h * scale <= p.display_resolution.height then
    r.location = loc
  else
    r.force_auto_center()
  end
  titlebar(r, {"ptt.title"}, "close")
  local body = r.add{type="flow", direction="vertical"}
  body.style.vertical_spacing = 12; body.style.vertically_stretchable = true
  body.style.horizontally_stretchable = true
  -- Top pane: toolbar, filters, queue and goal.
  local top = body.add{type="frame", style="inside_shallow_frame", direction="vertical"}
  local tb = top.add{type="frame", style="subheader_frame", direction="horizontal"}
  tb.style.horizontally_stretchable = true
  local flow = tb.add{type="flow", direction="horizontal"}
  flow.style.vertical_align = "center"; flow.style.horizontal_spacing = 4
  tool(flow, "search_focus", "utility/search_icon", {"ptt.search-hint"})
  local field = flow.add{type="textfield", name="ptt_query", text=s.query, tags=tags_of("search"),
    tooltip={"ptt.search-hint"}}
  field.style.width = 240; field.lose_focus_on_confirm = true
  s.search_field = field
  tool(flow, "clear", "utility/close_black", {"ptt.clear"})
  s.filters_button = button(flow, "filters", {"ptt.filters"})
  s.filters_button.style.height = 28; s.filters_button.style.left_margin = 12
  s.filters_button.tooltip = {"ptt.filters-hint"}
  s.view_all = button(flow, "view_all", {"ptt.view-all"}); s.view_all.tooltip = {"ptt.view-all-hint"}
  s.view_all.style.left_margin = 12
  s.view_chain = button(flow, "view_chain", {"ptt.view-chain"}); s.view_chain.tooltip = {"ptt.view-chain-hint"}
  for _, x in ipairs({s.view_all, s.view_chain}) do x.style.height = 28 end
  s.pin_button = tool(flow, "pin", "utility/track_button", {"ptt.pin-hint"})
  tool(flow, "focus", "utility/center", {"ptt.focus-hint"})
  s.grid_button = tool(flow, "view_grid", "utility/grid_view", {"ptt.view-grid-hint"})
  s.grid_button.style.left_margin = 12
  s.list_button = tool(flow, "view_list", "utility/list_view", {"ptt.view-list-hint"})
  pusher(flow)
  s.search_status = flow.add{type="label", tooltip={"ptt.search-preparing-hint"}}
  s.search_status.style.font = "default-small"; s.search_status.style.right_margin = 8
  tool(flow, "settings", "utility/preset", {"ptt.settings-hint"})
  tool(flow, "help", "utility/questionmark", {"ptt.help-hint"})
  filter_row(p, top, g)
  local qr = top.add{type="flow", direction="horizontal"}
  qr.style.padding = {8, 12, 8, 12}; qr.style.vertical_align = "center"
  s.queue_flow = qr.add{type="flow", direction="horizontal"}
  s.queue_flow.style.vertical_align = "center"; s.queue_flow.style.horizontal_spacing = 4
  pusher(qr)
  s.goal_flow = qr.add{type="flow", direction="horizontal"}
  s.goal_flow.style.vertical_align = "center"; s.goal_flow.style.horizontal_spacing = 8
  -- Three panes: eras, technologies, selected technology.
  local main = body.add{type="flow", direction="horizontal"}
  main.style.horizontal_spacing = 12; main.style.vertically_stretchable = true
  main.style.horizontally_stretchable = true
  local left = main.add{type="frame", style="inside_shallow_frame", direction="vertical"}
  left.style.width = NAV_WIDTH; left.style.vertically_stretchable = true
  local lh = left.add{type="frame", style="subheader_frame"}
  lh.style.horizontally_stretchable = true
  lh.add{type="label", caption={"ptt.eras"}, style="subheader_caption_label"}
  local navpane = left.add{type="scroll-pane", style="naked_scroll_pane", horizontal_scroll_policy="never",
    vertical_scroll_policy="auto"}
  navpane.style.vertically_stretchable = true; navpane.style.horizontally_stretchable = true
  s.nav = navpane.add{type="flow", direction="vertical"}
  s.nav.style.padding = 8; s.nav.style.vertical_spacing = 4
  local center = main.add{type="frame", style="inside_deep_frame", direction="vertical"}
  center.style.horizontally_stretchable = true; center.style.vertically_stretchable = true
  local chd = center.add{type="frame", style="subheader_frame"}
  chd.style.horizontally_stretchable = true
  s.summary = chd.add{type="label", style="subheader_caption_label"}
  s.scroll = center.add{type="scroll-pane", name="ptt_scroll", style="naked_scroll_pane",
    horizontal_scroll_policy="never", vertical_scroll_policy="always"}
  s.scroll.style.vertically_stretchable = true; s.scroll.style.horizontally_stretchable = true
  local right = main.add{type="frame", style="inside_shallow_frame", direction="vertical"}
  right.style.width = pw; right.style.vertically_stretchable = true
  local rh = right.add{type="frame", style="subheader_frame"}
  rh.style.horizontally_stretchable = true
  s.panel_title = rh.add{type="label", style="subheader_caption_label"}
  s.panel_title.style.maximal_width = pw - 24
  local panel = right.add{type="scroll-pane", style="naked_scroll_pane", horizontal_scroll_policy="never",
    vertical_scroll_policy="auto"}
  panel.style.vertically_stretchable = true; panel.style.horizontally_stretchable = true
  s.panel = panel.add{type="flow", direction="vertical"}
  s.panel.style.padding = 12; s.panel.style.vertical_spacing = 8
  s.open = true -- no world camera or surface exists in this implementation
  p.opened = r
  Toolbar.sync(p, true)
  update_view(p)
  local goal = Goal.get(p.force)
  if s.selected and (s.user_selected or (goal and goal.tech == s.selected)) then reveal(p, s.selected) end
  M.tree(p, true); M.panel(p)
  local ctx = context(p)
  M.goal_line(p, ctx); M.queue_bar(p, ctx)
  M.search_status(p)
  if opt(p, "focus_search") then field.focus(); field.select_all() end
end

-- Rebuild the window with new sizes; popups stay open on top.
function M.reopen(p)
  if not root(p) then return end
  M.close(p, true)
  M.open(p)
  for _, name in ipairs({SETTINGS, HELP}) do
    local f = p.gui.screen[name]
    if f then f.bring_to_front() end
  end
end

local function clear_search(p)
  local s = state(p)
  s.query = ""
  if s.search_field and s.search_field.valid then s.search_field.text = "" end
end

function M.focus_search(p)
  local s = state(p)
  if root(p) and s.search_field and s.search_field.valid then
    s.search_field.focus(); s.search_field.select_all()
  end
end

-- Select a technology. Cards update in place; only the chain view follows the selection by a rebuild.
-- `jump` (clicks outside the tree: panel, queue, goal line) also scrolls to the card or reveals it.
function M.select(p, name, jump)
  if not p.force.technologies[name] then return end
  local s = state(p)
  s.selected = name; s.user_selected = true; s.notice = nil; s.focus_key = nil
  mark_seen(p, name)
  if not root(p) then return end
  if s.chain and not s.pinned and not s.searching then
    reveal(p, name)
    M.tree(p, true)
  elseif jump and not (s.cards and s.cards[name] and s.cards[name].valid) and not s.searching then
    reveal(p, name)
    M.tree(p, true)
  else
    local ctx = context(p)
    for n in pairs(s.refs or {}) do update_card(p, n, ctx) end
    M.nav_captions(p, ctx, s.shown_eras or {})
    if jump and s.cards and s.cards[name] and s.cards[name].valid then
      s.scroll.scroll_to_element(s.cards[name], "top-third")
    end
  end
  M.panel(p)
end

-- Mark open windows of every player in the force for a deferred refresh.
function M.refresh_force(force, queue_only)
  for _, q in pairs(force.connected_players) do
    if root(q) then
      local s = state(q)
      s.refresh_due = true
      if not queue_only then s.full_panel_refresh = true end
    end
  end
end

local function rewrite_queue(force, list)
  storage.ptt_filling = true
  force.research_queue = list
  storage.ptt_filling = nil
end

local function queue_remove(p, i)
  local force = p.force
  local list = G.queue(force)
  local n = list[i]
  if not n then return end
  local goal = Goal.get(force)
  if goal and not goal.paused and Goal.needed(force, n) then Goal.pause(force, n) end
  local new = {}
  for k, x in ipairs(list) do if k ~= i then new[#new + 1] = x end end
  rewrite_queue(force, new)
  if goal and goal.ours then goal.ours[n] = nil end
  Goal.fill(force)
end

local function queue_up(p, i)
  local force, s = p.force, state(p)
  local list = G.queue(force)
  local n = list[i]
  if not n or i < 2 then return end
  if M.depends(graph(p), n, list[i - 1]) then s.notice = {"ptt.queue-move-rejected"}; return end
  local new = {}
  for k, x in ipairs(list) do new[k] = x end
  new[i], new[i - 1] = new[i - 1], new[i]
  rewrite_queue(force, new)
  local after = G.queue(force)
  if #after ~= #list then rewrite_queue(force, list); s.notice = {"ptt.queue-move-rejected"} end
end
M.queue_up = queue_up

local function flying(p, message)
  p.create_local_flying_text{text=message, create_at_cursor=true}
end

-- Shift+click on a card: add to the end of the queue. Returns the message shown.
local function quick_queue(p, name)
  local force = p.force
  local status = G.status(force, name)
  local message
  if status == "available" then
    if #G.queue(force) >= QUEUE_SLOTS then
      message = {"ptt.queue-full"}
    else
      local ok = force.add_research(name)
      message = {ok and "ptt.added" or "ptt.rejected"}
    end
  elseif status == "locked" then
    message = {"ptt.quick-locked"}
  else
    message = {"ptt.status-" .. status}
  end
  state(p).notice = message
  flying(p, message)
end

-- Ctrl+click on a card: make it the force goal.
local function quick_goal(p, name)
  local t = p.force.technologies[name]
  if t and not t.researched and Goal.set(p.force, name, p) then
    state(p).notice = {"ptt.goal-accepted"}
    flying(p, {"ptt.goal-accepted"})
  else
    flying(p, {"ptt.status-done"})
  end
end

local function after_change(p, queue_only)
  M.refresh_force(p.force, queue_only)
  M.refresh(p)
  M.panel(p, queue_only)
end

function M.click(e)
  if not (e.element and e.element.valid) then return end
  local tag = e.element.tags
  if not tag.ptt then return end
  local p = game.get_player(e.player_index); if not p then return end
  local s = state(p); local a = tag.action
  local force = p.force
  if a == "toolbar_toggle" then
    if root(p) then M.close(p) else M.open(p) end
  elseif a == "close" then M.close(p)
  elseif a == "popup_close" then
    local f = p.gui.screen[tag.popup]
    if f then f.destroy() end
  elseif a == "select" then
    if e.shift and not tag.jump then quick_queue(p, tag.tech); after_change(p, true)
    elseif e.control and not tag.jump then quick_goal(p, tag.tech); after_change(p)
    else M.select(p, tag.tech, tag.jump) end
  elseif a == "settings" then toggle_popup(p, SETTINGS)
  elseif a == "help" then toggle_popup(p, HELP)
  elseif a == "settings_reset" then
    Prefs.reset(p.index)
    local f = p.gui.screen[SETTINGS]
    if f then f.destroy() end
    M.reopen(p)
    settings_window(p)
  elseif a == "search_focus" then M.focus_search(p)
  elseif a == "clear" then
    clear_search(p); M.tree(p, true)
  elseif a == "filters" then
    s.filters_open = not s.filters_open; update_view(p)
  elseif a == "filters_reset" then
    local flt = Prefs.filters(p.index)
    flt.status = nil; flt.pack = nil
    if s.status_dd and s.status_dd.valid then s.status_dd.selected_index = 1 end
    if s.pack_dd and s.pack_dd.valid then s.pack_dd.selected_index = 1 end
    update_view(p); M.tree(p, true)
  elseif a == "focus" then
    clear_search(p); s.focus_key = nil; choose(p)
    if s.selected then reveal(p, s.selected) end
    M.tree(p, true); M.panel(p)
  elseif a == "view_all" or a == "view_chain" then
    s.chain = a == "view_chain"
    if not s.chain then s.pinned = nil end
    update_view(p); M.tree(p, true)
  elseif a == "view_grid" or a == "view_list" then
    Prefs.set(p.index, "view", a == "view_list" and "list" or "grid")
    update_view(p); M.tree(p, true)
  elseif a == "pin" then
    if s.chain then
      s.pinned = (not s.pinned) and s.selected or nil
      s.focus_due = nil
      update_view(p)
      if not s.pinned then M.tree(p, true) end
    end
  elseif a == "toggle" then
    local key = tag.key
    local era = key:match("^(.-)/done$") or key
    s.expanded[key] = not (s.open_now and s.open_now[key])
    refill_era(p, era)
  elseif a == "nav" then
    local h = s.headers and s.headers[tag.key]
    if h and h.valid then s.scroll.scroll_to_element(h, "top-third") end
  elseif a == "queue_one" then
    -- Do not select the prerequisite, rebuild the tree or create an automatic goal.
    local status = G.status(force, tag.tech)
    if status == "available" then
      if #G.queue(force) >= QUEUE_SLOTS then
        s.notice = {"ptt.queue-full"}
      else
        local ok = force.add_research(tag.tech)
        s.notice = {ok and "ptt.added" or "ptt.rejected"}
      end
    else
      s.notice = {"ptt.status-" .. status}
    end
    after_change(p, true)
  elseif a == "research" then
    if s.selected and G.status(force, s.selected) == "available" then
      if #G.queue(force) >= QUEUE_SLOTS then
        s.notice = {"ptt.queue-full"}
      else
        local ok = force.add_research(s.selected)
        s.notice = {ok and "ptt.added" or "ptt.rejected"}
      end
    else s.notice = {"ptt.rejected"} end
    M.panel(p); M.refresh(p)
  elseif a == "goal_set" then
    if s.selected and Goal.set(force, s.selected, p) then s.notice = {"ptt.goal-accepted"} end
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a == "goal_clear" then
    local goal = Goal.get(force)
    if goal then
      local t = force.technologies[goal.tech]
      Goal.announce(force, {"ptt.goal-cleared", p.name, t and t.localised_name or goal.tech})
      Goal.clear(force)
    end
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a == "goal_resume" then
    Goal.resume(force)
    M.refresh_force(force); M.panel(p); M.refresh(p)
  elseif a == "q_slot" then
    if e.button == defines.mouse_button_type.right then
      queue_remove(p, tag.index)
    elseif e.shift then
      queue_up(p, tag.index); M.panel(p)
    else
      M.select(p, tag.tech, true); return
    end
    M.refresh_force(force); M.refresh(p)
  elseif a == "q_remove" then
    queue_remove(p, tag.index)
    M.refresh_force(force); M.refresh(p)
  end
end

function M.changed(e)
  if not (e.element and e.element.valid and e.element.tags.ptt) then return end
  local p = game.get_player(e.player_index); local s = state(p)
  if e.element.tags.action == "search" then s.query = e.element.text; s.search_due = game.tick + 15 end
end

-- Checkboxes of the settings window.
function M.checked(e)
  if not (e.element and e.element.valid and e.element.tags.ptt) then return end
  local tag = e.element.tags
  if tag.action ~= "pref_flag" then return end
  local p = game.get_player(e.player_index)
  Prefs.set(p.index, tag.key, e.element.state)
  if root(p) then
    if tag.key == "evolution" then M.panel(p)
    elseif tag.key ~= "focus_search" and tag.key ~= "chat_goal" then M.tree(p, false) end
  end
end

-- Drop-downs: settings and filters.
function M.selection(e)
  if not (e.element and e.element.valid and e.element.tags.ptt) then return end
  local tag = e.element.tags
  local p = game.get_player(e.player_index)
  local s = state(p)
  local i = e.element.selected_index
  if tag.action == "pref" then
    local values = ({window=Prefs.WINDOW, size={1, 2, 3, 4}, view=Prefs.VIEW, open_with=Prefs.OPEN_WITH})[tag.key]
    if not (values and values[i]) then return end
    Prefs.set(p.index, tag.key, values[i])
    if tag.key == "window" then M.reopen(p)
    elseif tag.key == "size" or tag.key == "view" then update_view(p); M.tree(p, true) end
  elseif tag.action == "filter_status" then
    Prefs.filters(p.index).status = STATUS_FILTERS[i] ~= "all" and STATUS_FILTERS[i] or nil
    update_view(p); M.tree(p, true)
  elseif tag.action == "filter_pack" then
    local key = s.pack_keys and s.pack_keys[i]
    Prefs.filters(p.index).pack = key or nil
    update_view(p); M.tree(p, true)
  end
end

-- Enter in the search field selects the first match.
function M.confirmed(e)
  if not (e.element and e.element.valid and e.element.tags.ptt and e.element.tags.action == "search") then return end
  local p = game.get_player(e.player_index)
  local s = state(p)
  s.query = e.element.text
  s.search_due = nil
  M.tree(p, false)
  if s.first_shown then M.select(p, s.first_shown, true) end
end

function M.location(e)
  if e.element and e.element.valid and e.element.name == ROOT then
    local p = game.get_player(e.player_index)
    local loc = e.element.location
    if loc then Prefs.prefs(p.index).location = {x = loc.x, y = loc.y} end
  end
end

-- In-place refresh: statuses, markers, counters, navigator, queue and goal line. No tree rebuild,
-- so the scroll position is preserved.
function M.refresh(p)
  local s = state(p)
  if not s.open or not root(p) then return end
  local ctx = context(p)
  for n in pairs(s.refs or {}) do update_card(p, n, ctx) end
  for key, ref in pairs(s.era_labels or {}) do
    local names = s.shown_eras and s.shown_eras[key]
    if ref.count.valid and names then
      local done = count_done(names, ctx.done)
      ref.count.caption = {"ptt.era-count", done, #names}
      ref.count.style.font_color = done == #names and COLORS.done or COLORS.name
      ref.bar.value = #names > 0 and done / #names or 0
    end
  end
  M.nav_captions(p, ctx, s.shown_eras or {})
  M.goal_line(p, ctx); M.queue_bar(p, ctx)
end

function M.tick()
  for _, p in pairs(game.connected_players) do
    local s = state(p)
    Search.step(p, s)
    if s.open and root(p) then
      if s.search_due and game.tick >= s.search_due then s.search_due = nil; M.tree(p, false) end
      if s.focus_due and game.tick >= s.focus_due then s.focus_due = nil; M.focus(p); s.focus_key = nil end
      if s.progress and s.progress.valid then
        s.progress.number = math.floor(p.force.research_progress * 100)
      end
      M.search_status(p)
    end
  end
end

-- A new translation only adds search text: rebuild the results when it matches the current query.
-- An already scheduled rebuild is never pushed later (answers arriving without a pause used to
-- postpone it until the whole translation finished).
function M.translated(e)
  local s = storage.native_players and storage.native_players[e.player_index]
  if not s then return end
  local found = Search.translated(s, e)
  if not found or s.query == "" or s.search_due or not s.open then return end
  if string.find(found, G.lower(s.query), 1, true) then s.search_due = game.tick + 30 end
end

function M.locale_changed(e)
  local s = storage.native_players and storage.native_players[e.player_index]
  if s then Search.reset(s) end
end

-- Technologies whose last prerequisite was just researched are marked "new".
function M.research_finished(tech)
  local force = tech.force
  local set = new_set(force)
  set[tech.name] = nil
  local g = Goal.graph(force)
  for _, child in ipairs(g.post[tech.name] or {}) do
    local t = force.technologies[child]
    if t and g.nodes[child] and not t.researched and t.enabled then
      local ready = true
      for _, pre in pairs(t.prerequisites) do if not pre.researched then ready = false; break end end
      if ready then set[child] = true end
    end
  end
end

function M.invalidate()
  for _, p in pairs(game.players) do
    M.close(p)
    -- Close only our old prototype GUI; preserve the old private surface/save data.
    for _, name in ipairs({"ptt_toolbar", "ptt_view", "ptt_panel"}) do
      if p.gui.screen[name] then p.gui.screen[name].destroy() end
    end
    local old = storage.players and storage.players[p.index]
    if old then
      for _, f in pairs(old.frames or {}) do if f.valid then f.destroy() end end
      if old.select_box and old.select_box.valid then old.select_box.destroy() end
      old.open = false
    end
  end
  storage.native_players = {}; storage.native_graphs = {}
end

-- Remote interface "paranoidal-tech-tree" (other mods, tests). Player index first.
M.remote = {
  -- Open the window, optionally selecting a technology. Returns true when the window is open.
  open = function(player_index, tech)
    local p = game.get_player(player_index)
    if not p then return false end
    if not root(p) then M.open(p) end
    if tech and p.force.technologies[tech] then M.select(p, tech, true) end
    return root(p) ~= nil
  end,
  close = function(player_index)
    local p = game.get_player(player_index)
    if p then M.close(p) end
  end,
  is_open = function(player_index)
    local p = game.get_player(player_index)
    return p ~= nil and root(p) ~= nil
  end,
  -- Set the search text and rebuild the results now.
  search = function(player_index, query)
    local p = game.get_player(player_index)
    if not (p and root(p)) then return false end
    local s = state(p)
    s.query = query or ""
    if s.search_field and s.search_field.valid then s.search_field.text = s.query end
    M.tree(p, true)
    return s.shown or 0
  end,
  -- Change one window setting (keys of prefs.lua DEFAULTS, same value type) and rebuild the open window.
  set_option = function(player_index, key, value)
    local p = game.get_player(player_index)
    if not p or Prefs.DEFAULTS[key] == nil or type(value) ~= type(Prefs.DEFAULTS[key]) then return false end
    Prefs.set(p.index, key, value)
    if root(p) then M.reopen(p) end
    return true
  end,
  -- Show a part of the window: "settings", "help" or "filters"; "none" closes them.
  show = function(player_index, what)
    local p = game.get_player(player_index)
    if not (p and root(p)) then return false end
    if what == "none" then
      close_popups(p)
      state(p).filters_open = false; update_view(p)
    elseif what == "settings" or what == "help" then
      if not p.gui.screen[what == "settings" and SETTINGS or HELP] then
        toggle_popup(p, what == "settings" and SETTINGS or HELP)
      end
    elseif what == "filters" then
      state(p).filters_open = true; update_view(p)
    elseif what == "chain" or what == "all" then
      local s = state(p)
      s.chain = what == "chain"
      if not s.chain then s.pinned = nil end
      update_view(p); M.tree(p, true)
    end
    return true
  end,
  -- Make `tech` the force goal on behalf of the player (same as "Set as goal"). Returns true when accepted.
  set_goal = function(player_index, tech)
    local p = game.get_player(player_index)
    if not (p and tech and p.force.technologies[tech]) then return false end
    local ok = Goal.set(p.force, tech, p)
    M.refresh_force(p.force)
    return ok
  end,
  -- Set the filters: status (one of "all", "available", "trigger", "queued", "locked", "done", "disabled")
  -- and science pack item name of an era (nil = all). Returns the number of shown technologies.
  set_filter = function(player_index, status, pack)
    local p = game.get_player(player_index)
    if not p then return false end
    local flt = Prefs.filters(p.index)
    flt.status = (status and status ~= "all" and STATUS_MATCH[status]) and status or nil
    flt.pack = pack and era_by_key(graph(p), pack) and pack or nil
    if root(p) then M.reopen(p) end
    return state(p).shown or 0
  end,
}

return M
