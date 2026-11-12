-- Dispatcher: overview, scheme, map, districts (+ advisor), journal, automation.
local S = require("shared")
local state = require("scripts.state")
local engine = require("scripts.engine")
local advisor = require("scripts.advisor")
local journal = require("scripts.journal")
local map = require("scripts.map")
local U = require("scripts.util")
local G = require("scripts.gui")

local W = {}
local NAME = "ppd_dispatcher"
local TABS = { "overview", "scheme", "map", "districts", "journal", "automation" }
local GREY = { 0.7, 0.7, 0.7 }
local DIODE_SPRITE = {
  [defines.entity_status_diode.green] = "utility/status_working",
  [defines.entity_status_diode.yellow] = "utility/status_yellow",
  [defines.entity_status_diode.red] = "utility/status_not_working",
}
local STEAM_ENGINE_W = 900e3
local ui_hub -- set by control.lua (the transformer window opens from here)
local COAL_J = 4e6

local function districts(force_index)
  local list = {}
  for _, ds in pairs(storage.dist) do
    if ds.force == force_index and ds.N and storage.tr[ds.lead] then list[#list + 1] = ds end
  end
  table.sort(list, function(a, b) return a.did < b.did end)
  return list
end

-- the general network: the upstream network feeding the most districts; else the pole nearest to the player
local function general_pole(player)
  local best, best_n
  for net, groups in pairs(storage.groups_of_in or {}) do
    local g = groups[1]
    local m = g and storage.tr[g.lead]
    if m and m.force == player.force.index and m.pin and m.pin.valid and (not best_n or #groups > best_n) then
      best, best_n = m.pin, #groups
    end
  end
  if best then return best end
  local p = player.surface.find_entities_filtered({ type = "electric-pole", position = player.position, radius = 40,
    force = player.force, limit = 30 })
  local d, pick = math.huge, nil
  for _, e in ipairs(p) do
    local n = e.name
    if n ~= S.POLE_IN and n ~= S.POLE_OUT and n ~= S.POLE_ALT then
      local dx, dy = e.position.x - player.position.x, e.position.y - player.position.y
      if dx * dx + dy * dy < d then d, pick = dx * dx + dy * dy, e end
    end
  end
  return pick
end

local function producers(pole, count)
  local stats = pole.electric_network_statistics
  local list, total = {}, 0
  if not stats then return list, 0 end
  for name in pairs(stats.output_counts) do
    local v = stats.get_flow_count({ name = name, category = "output", precision_index = defines.flow_precision_index.one_minute })
    if v > 0 then
      list[#list + 1] = { name = name, v = v }
      total = total + v
    end
  end
  table.sort(list, function(a, b) return a.v > b.v end)
  while #list > count do list[#list] = nil end
  return list, total
end

local function consumption(pole)
  local stats = pole.electric_network_statistics
  if not stats then return 0 end
  local total = 0
  for name in pairs(stats.input_counts) do
    total = total + stats.get_flow_count({ name = name, category = "input", precision_index = defines.flow_precision_index.one_minute })
  end
  return total
end

function W.close(player)
  local f = player.gui.screen[NAME]
  if f and f.valid then f.destroy() end
  local pd = state.player(player.index)
  pd.dsp = nil
  player.set_shortcut_toggled("ppd-dispatcher", false)
end

function W.toggle(player)
  if player.gui.screen[NAME] then W.close(player) else W.open(player) end
end

function W.open(player, tab)
  W.close(player)
  local pd = state.player(player.index)
  local frame = player.gui.screen.add({ type = "frame", name = NAME, direction = "vertical" })
  frame.auto_center = true
  G.titlebar(frame, { "ppd-gui.dispatcher" }, "dsp-close")
  local tp = frame.add({ type = "tabbed-pane", tags = { ppd = "dsp-tab" } })
  tp.style.width = 1080
  local pages = {}
  for i, key in ipairs(TABS) do
    local tabel = tp.add({ type = "tab", caption = { "ppd-dsp.tab-" .. key } })
    local page = tp.add({ type = "flow", direction = "vertical" })
    page.style.vertical_spacing = 12
    page.style.minimal_height = 560
    page.style.horizontally_stretchable = true
    tp.add_tab(tabel, page)
    pages[i] = page
  end
  pd.tab = tab or pd.tab or 1
  tp.selected_tab_index = pd.tab
  pd.dsp = { pages = pages, built = {}, refs = {} }
  player.opened = frame
  player.set_shortcut_toggled("ppd-dispatcher", true)
  W.refresh(player, true)
end

---------------------------------------------------------------- overview

local function stat_box(parent, refs, key, caption)
  G.add(parent, { type = "frame", style = "deep_frame_in_shallow_frame", direction = "vertical",
    style_mods = { padding = 8, horizontally_stretchable = true }, children = {
    { type = "label", caption = caption, style_mods = { font = "default-small", font_color = GREY } },
    { type = "label", ref = key, style_mods = { font = "heading-1" } },
    { type = "label", ref = key .. "_sub", style_mods = { font = "default-small", font_color = GREY } },
  } }, refs)
end

local function build_overview(page, refs)
  local topf = page.add({ type = "frame", style = "inside_shallow_frame_with_padding", direction = "horizontal" })
  topf.style.horizontally_stretchable = true
  local top = topf.add({ type = "flow", direction = "horizontal" })
  top.style.horizontal_spacing = 12
  top.style.horizontally_stretchable = true
  stat_box(top, refs, "gen", { "ppd-dsp.gen" })
  stat_box(top, refs, "cons", { "ppd-dsp.cons" })
  stat_box(top, refs, "sat", { "ppd-dsp.sat" })
  stat_box(top, refs, "acc", { "ppd-dsp.acc" })
  local row = page.add({ type = "flow", direction = "horizontal" })
  row.style.horizontal_spacing = 12
  row.style.horizontally_stretchable = true
  local prod = G.add(row, { type = "frame", style = "inside_shallow_frame", direction = "vertical", style_mods = { width = 520 }, children = {
    { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
      { type = "label", style = "subheader_caption_label", caption = { "ppd-dsp.production" } },
      { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
      { type = "label", caption = { "ppd-dsp.per-minute" }, style_mods = { font_color = GREY } } } } } })
  refs.prod = prod.add({ type = "table", column_count = 4 })
  refs.prod.style.padding = 8
  refs.prod.style.horizontal_spacing = 8
  local dist = G.add(row, { type = "frame", style = "inside_shallow_frame", direction = "vertical", style_mods = { width = 524 }, children = {
    { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
      { type = "label", style = "subheader_caption_label", caption = { "ppd-dsp.districts" } },
      { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
      { type = "label", ref = "dcount", style_mods = { font_color = GREY } } } } } }, refs)
  G.add(dist, { type = "flow", direction = "vertical", style_mods = { padding = 8, vertical_spacing = 6 }, children = {
    { type = "label", ref = "inzone", style_mods = { font = "heading-2" } },
    { type = "table", column_count = 2, ref = "savings", style_mods = { horizontal_spacing = 24 } },
  } }, refs)
  local att = G.add(page, { type = "frame", style = "inside_shallow_frame", direction = "vertical", children = {
    { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
      { type = "sprite", sprite = "utility/warning_icon", style_mods = { width = 20, height = 20, stretch_image_to_widget_size = true } },
      { type = "label", style = "subheader_caption_label", caption = { "ppd-dsp.attention" } } } } } })
  refs.attention = att.add({ type = "flow", direction = "vertical" })
  refs.attention.style.padding = 8
  refs.attention.style.vertical_spacing = 4
end

local function refresh_overview(player, refs)
  local pole = general_pole(player)
  local f = state.force(player.force.index)
  if pole then
    local plist, total = producers(pole, 6)
    local sat, spare, avail = engine.flow_numbers(pole)
    refs.gen.caption = U.tpower(total)
    refs.gen_sub.caption = { "ppd-dsp.gen-max", U.tpower(avail or 0) }
    local cons = consumption(pole)
    refs.cons.caption = U.tpower(cons)
    refs.cons_sub.caption = { "ppd-dsp.cons-sub" }
    refs.sat.caption = U.pct(sat or 1)
    refs.sat.style.font_color = (sat or 1) >= 0.999 and { 0.56, 0.89, 0.42 } or { 1, 0.48, 0.41 }
    refs.sat_sub.caption = (sat or 1) >= 0.999 and { "ppd-dsp.sat-ok" } or { "ppd-dsp.sat-bad" }
    local sub = pole.electric_network
    local net = sub and sub.parent_network
    local fl = net and net.flow_last_tick
    local energy = fl and fl.accumulator_energy or 0
    local cap = fl and fl.accumulator_capacity or 0
    refs.acc.caption = cap > 0 and U.pct(energy / cap) or "—"
    refs.acc_sub.caption = { "ppd-dsp.acc-sub", U.energy(energy), U.energy(cap) }
    refs.prod.clear()
    for _, p in ipairs(plist) do
      local proto = prototypes.entity[p.name]
      local ic = refs.prod.add({ type = "sprite", sprite = proto and ("entity/" .. p.name) or "utility/questionmark" })
      ic.style.size = 28
      ic.style.stretch_image_to_widget_size = true
      local l = refs.prod.add({ type = "label", caption = proto and proto.localised_name or p.name })
      l.style.width = 220
      local bar = refs.prod.add({ type = "progressbar", value = total > 0 and p.v / total or 0 })
      bar.style.width = 130
      G.bar_color(bar, { 0.98, 0.66, 0.22 })
      local v = refs.prod.add({ type = "label", caption = U.tpower(p.v) })
      v.style.font = "default-semibold"
      v.style.minimal_width = 80
      v.style.horizontal_align = "right"
    end
    if #plist == 0 then refs.prod.add({ type = "label", caption = { "ppd-dsp.no-production" } }) end
  else
    for _, k in ipairs({ "gen", "cons", "sat", "acc" }) do
      refs[k].caption = "—"
      refs[k .. "_sub"].caption = ""
    end
    refs.prod.clear()
    refs.prod.add({ type = "label", caption = { "ppd-dsp.no-network" } })
  end
  local list = districts(player.force.index)
  local inzone, saved_now = 0, 0
  for _, ds in ipairs(list) do
    if ds.zone then inzone = inzone + 1 end
    saved_now = saved_now + (ds.saved or 0)
  end
  refs.dcount.caption = { "ppd-dsp.dcount", #list }
  refs.inzone.caption = { "ppd-dsp.inzone", inzone, #list }
  refs.savings.clear()
  local function kv(a, b, good)
    refs.savings.add({ type = "label", caption = a })
    local l = refs.savings.add({ type = "label", caption = b })
    l.style.font = "default-semibold"
    if good then l.style.font_color = { 0.56, 0.89, 0.42 } end
  end
  kv({ "ppd-dsp.saved-now" }, U.tpower(saved_now), true)
  kv({ "ppd-dsp.saved-engines" }, { "ppd-dsp.engines", math.floor(saved_now * 60 / STEAM_ENGINE_W + 0.5) })
  kv({ "ppd-dsp.saved-coal" }, { "ppd-dsp.coal-per-s", U.num(saved_now * 60 / COAL_J, 1) })
  kv({ "ppd-dsp.saved-total" }, U.energy(f.saved or 0), true)
  kv({ "ppd-dsp.saved-total-coal" }, U.num((f.saved or 0) / COAL_J, 0))
  -- attention
  local items = 0
  refs.attention.clear()
  for _, ds in ipairs(list) do
    if ds.status ~= "zone" and items < 6 then
      local lead = storage.tr[ds.lead]
      local adv = advisor.district(ds)
      local st = engine.STATUS[ds.status] or engine.STATUS.idle
      local row = refs.attention.add({ type = "flow", direction = "horizontal" })
      row.style.vertical_align = "center"
      row.style.horizontal_spacing = 8
      row.add({ type = "sprite", sprite = DIODE_SPRITE[st.diode] })
      local msg = adv[1] and adv[1].msg or { "", engine.name_of(lead), ": ", { "ppd-status." .. ds.status } }
      local l = row.add({ type = "label", caption = msg })
      l.style.maximal_width = 860
      G.spacer(row)
      row.add({ type = "button", caption = { "ppd-dsp.show" }, tags = { ppd = "dsp-show", unit = ds.lead } })
      row.add({ type = "button", caption = { "ppd-dsp.open" }, tags = { ppd = "dsp-open", unit = ds.lead } })
      items = items + 1
    end
  end
  if items == 0 then
    refs.attention.add({ type = "label", caption = #list > 0 and { "ppd-dsp.all-good" } or { "ppd-dsp.no-districts" } })
  end
end

---------------------------------------------------------------- scheme

local function build_scheme(page, refs)
  local frame = page.add({ type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical" })
  frame.style.horizontally_stretchable = true
  local fr = frame.add({ type = "flow", direction = "vertical" })
  fr.style.vertical_spacing = 8
  fr.style.horizontally_stretchable = true
  refs.gens = fr.add({ type = "flow", direction = "horizontal" })
  refs.gens.style.horizontal_spacing = 8
  refs.bus = fr.add({ type = "progressbar", value = 1 })
  refs.bus.style.horizontally_stretchable = true
  refs.bus.style.bar_width = 8
  G.bar_color(refs.bus, { 0.98, 0.66, 0.22 })
  refs.busl = fr.add({ type = "label" })
  refs.busl.style.font = "default-semibold"
  local sp = fr.add({ type = "scroll-pane", horizontal_scroll_policy = "auto", vertical_scroll_policy = "auto" })
  sp.style.maximal_height = 380
  sp.style.horizontally_stretchable = true
  refs.cards = sp.add({ type = "table", column_count = 6 })
  refs.cards.style.horizontal_spacing = 8
  refs.cards.style.vertical_spacing = 8
  G.add(page, { type = "label", caption = { "ppd-dsp.scheme-hint" }, style_mods = { font = "default-small", font_color = GREY } })
end

local function card(parent, ds)
  local lead = storage.tr[ds.lead]
  local st = engine.STATUS[ds.status] or engine.STATUS.idle
  local c = S.COLORS[lead.color or 1]
  local frame = parent.add({ type = "frame", style = "deep_frame_in_shallow_frame", direction = "vertical" })
  frame.style.width = 162
  frame.style.padding = 6
  local fr = frame.add({ type = "flow", direction = "vertical" })
  fr.style.vertical_spacing = 2
  local stripe = fr.add({ type = "progressbar", value = 1 })
  stripe.style.horizontally_stretchable = true
  stripe.style.bar_width = 6
  stripe.style.color = c
  local icons = fr.add({ type = "flow", direction = "horizontal" })
  icons.style.horizontal_align = "center"
  icons.style.horizontally_stretchable = true
  for _, u in ipairs(ds.units) do
    local m = storage.tr[u]
    if m then
      icons.add({ type = "sprite-button", style = "slot_button", sprite = "item/" .. m.e.name,
        tags = { ppd = "dsp-open", unit = u }, tooltip = { "ppd-dsp.card-tip" }, raise_hover_events = false })
    end
  end
  local l = fr.add({ type = "label", caption = engine.name_of(lead) })
  l.style.font = "default-bold"
  l.style.maximal_width = 150
  local tiers = {}
  for _, u in ipairs(ds.units) do
    local m = storage.tr[u]
    if m then tiers[#tiers + 1] = "Т-" .. S.TIERS[m.tier].key end
  end
  fr.add({ type = "label", caption = { "", table.concat(tiers, " + "), " · ", { "ppd-prio." .. (lead.prio or 2) } } }).style.font_color = GREY
  local bar = fr.add({ type = "progressbar", value = U.clamp((ds.r or 0) / S.LIMIT, 0, 1) })
  bar.style.horizontally_stretchable = true
  G.bar_color(bar, st.color)
  local b = math.floor((ds.bonus or 0) * 1000 + 0.5)
  local pl = fr.add({ type = "label", caption = b > 0 and { "", U.pct(ds.r or 0), " · +", U.num(b / 10, 1), " %" }
    or { "", U.pct(ds.r or 0), " · ", { "ppd-gui.none" } } })
  pl.style.font = "default-bold"
  pl.style.font_color = st.color
  fr.add({ type = "label", caption = { "ppd-dsp.card-load", U.tpower(ds.L or 0) } }).style.font_color = GREY
  fr.add({ type = "label", caption = { "ppd-dsp.card-take", U.tpower(ds.take or 0) } }).style.font_color = GREY
  local sl = fr.add({ type = "label", caption = { "ppd-status." .. ds.status } })
  sl.style.font = "default-small"
  sl.style.font_color = st.color
end

local function refresh_scheme(player, refs)
  local pole = general_pole(player)
  refs.gens.clear()
  local total = 0
  if pole then
    local plist
    plist, total = producers(pole, 5)
    for _, p in ipairs(plist) do
      local f = refs.gens.add({ type = "frame", style = "deep_frame_in_shallow_frame", direction = "horizontal" })
      f.style.padding = 4
      f.style.vertical_align = "center"
      local ic = f.add({ type = "sprite", sprite = "entity/" .. p.name })
      ic.style.size = 32
      ic.style.stretch_image_to_widget_size = true
      local fl = f.add({ type = "flow", direction = "vertical" })
      fl.style.vertical_spacing = 0
      local proto = prototypes.entity[p.name]
      fl.add({ type = "label", caption = proto and proto.localised_name or p.name }).style.font = "default-semibold"
      fl.add({ type = "label", caption = U.tpower(p.v) }).style.font_color = { 0.98, 0.66, 0.22 }
    end
  end
  local sat = pole and engine.flow_numbers(pole) or 1
  local list = districts(player.force.index)
  local outside = pole and consumption(pole) or 0
  for _, ds in ipairs(list) do outside = outside - (ds.take or 0) end
  refs.busl.caption = { "ppd-dsp.bus", U.tpower(total), U.pct(sat or 1), U.tpower(math.max(0, outside)) }
  refs.cards.clear()
  for _, ds in ipairs(list) do card(refs.cards, ds) end
  if #list == 0 then refs.cards.add({ type = "label", caption = { "ppd-dsp.no-districts" } }) end
end

---------------------------------------------------------------- map

local function build_map(page, refs, player)
  local row = page.add({ type = "flow", direction = "horizontal" })
  row.style.horizontal_spacing = 12
  local left = row.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  left.style.width = 260
  local sp = left.add({ type = "scroll-pane" })
  sp.style.maximal_height = 470
  sp.style.padding = 8
  refs.mlist = sp.add({ type = "flow", direction = "vertical" })
  refs.mlist.style.vertical_spacing = 4
  local btn = left.add({ type = "flow" })
  btn.style.padding = 8
  refs.emap = btn.add({ type = "button", caption = { "ppd-dsp.energy-map" }, tags = { ppd = "dsp-emap" }, tooltip = { "ppd-dsp.energy-map-tip" } })
  refs.emap.style.horizontally_stretchable = true
  local right = row.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  right.style.horizontally_stretchable = true
  local mf = right.add({ type = "frame", style = "deep_frame_in_shallow_frame" })
  mf.style.margin = 8
  refs.minimap = mf.add({ type = "minimap", zoom = 1, surface_index = player.surface.index, position = player.position })
  refs.minimap.style.width = 760
  refs.minimap.style.height = 460
  refs.minimap.minimap_player_index = player.index
  refs.mcaption = right.add({ type = "label" })
  refs.mcaption.style.margin = { 0, 8, 8, 8 }
  refs.mcaption.style.font = "default-semibold"
end

local function refresh_map(player, refs)
  local pd = state.player(player.index)
  local list = districts(player.force.index)
  local keys = {}
  for _, ds in ipairs(list) do keys[#keys + 1] = ds.did end
  local key = table.concat(keys, ",")
  if refs.mkey ~= key then
    refs.mkey = key
    refs.mlist.clear()
    refs.mbtn = {}
    for _, ds in ipairs(list) do
      local lead = storage.tr[ds.lead]
      local b = refs.mlist.add({ type = "button", caption = engine.name_of(lead), tags = { ppd = "dsp-map-select", did = ds.did } })
      b.style.horizontally_stretchable = true
      b.style.horizontal_align = "left"
      refs.mbtn[ds.did] = b
    end
    if #list == 0 then refs.mlist.add({ type = "label", caption = { "ppd-dsp.no-districts" } }) end
  end
  if not (pd.map_did and storage.dist[pd.map_did]) then pd.map_did = list[1] and list[1].did or nil end
  for did, b in pairs(refs.mbtn or {}) do
    local ds = storage.dist[did]
    if b.valid and ds then
      local st = engine.STATUS[ds.status] or engine.STATUS.idle
      b.toggled = (did == pd.map_did)
      b.style.font_color = st.color
    end
  end
  local ds = pd.map_did and storage.dist[pd.map_did]
  local lead = ds and storage.tr[ds.lead]
  if lead and lead.e.valid then
    refs.minimap.surface_index = lead.e.surface.index
    refs.minimap.position = lead.e.position
    local b = math.floor((ds.bonus or 0) * 1000 + 0.5)
    refs.mcaption.caption = { "", engine.name_of(lead), " · ", U.pct(ds.r or 0), b > 0 and { "", " · +", U.num(b / 10, 1), " %" } or "",
      " · ", { "ppd-status." .. ds.status } }
  else
    refs.mcaption.caption = { "ppd-dsp.no-districts" }
  end
  local on = storage.emap_players[player.index] ~= nil
  refs.emap.toggled = on
  refs.emap.caption = on and { "ppd-dsp.energy-map-off" } or { "ppd-dsp.energy-map" }
end

---------------------------------------------------------------- districts

local COLS = { { "name", 170 }, { "tr", 120 }, { "load", 160 }, { "power", 90 }, { "bonus", 70 }, { "prio", 120 }, { "hour", 120 }, { "status", 160 } }

local function build_districts(page, refs)
  local fr = page.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  fr.style.horizontally_stretchable = true
  local sp = fr.add({ type = "scroll-pane" })
  sp.style.maximal_height = 280
  sp.style.horizontally_stretchable = true
  refs.rows = sp.add({ type = "table", column_count = #COLS + 1 })
  refs.rows.style.horizontal_spacing = 0
  refs.rows.style.vertical_spacing = 2
  local adv = page.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  adv.style.horizontally_stretchable = true
  G.add(adv, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
    { type = "label", style = "subheader_caption_label", caption = { "ppd-dsp.advisor" } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "label", caption = { "ppd-dsp.advisor-note" }, style_mods = { font_color = GREY } } } })
  local asp = adv.add({ type = "scroll-pane" })
  asp.style.maximal_height = 180
  refs.advice = asp.add({ type = "flow", direction = "vertical" })
  refs.advice.style.padding = 8
  refs.advice.style.vertical_spacing = 4
end

local function sort_value(ds, col)
  local lead = storage.tr[ds.lead]
  if col == "name" then return 0 end
  if col == "tr" then return ds.N or 0 end
  if col == "load" then return ds.r or 0 end
  if col == "power" then return ds.L or 0 end
  if col == "bonus" then return ds.bonus or 0 end
  if col == "prio" then return lead and lead.prio or 2 end
  if col == "hour" then return advisor.zone_share(lead and lead.h60, ds.lo, ds.hi) or -1 end
  if col == "status" then return (engine.STATUS[ds.status] or {}).code or 0 end
  return 0
end

local function refresh_districts(player, refs)
  local pd = state.player(player.index)
  local list = districts(player.force.index)
  local col = pd.sort or "load"
  table.sort(list, function(a, b)
    if col == "name" then
      local na, nb = storage.tr[a.lead].name or "", storage.tr[b.lead].name or ""
      if na ~= nb then return na < nb end
      return a.did < b.did
    end
    local va, vb = sort_value(a, col), sort_value(b, col)
    if va == vb then return a.did < b.did end
    if pd.sort_desc then return va > vb end
    return va < vb
  end)
  local t = refs.rows
  t.clear()
  for _, c in ipairs(COLS) do
    local caption = { "ppd-dsp.col-" .. c[1] }
    if pd.sort == c[1] then caption = { "", caption, pd.sort_desc and " ▼" or " ▲" } end
    local b = t.add({ type = "button", caption = caption, tags = { ppd = "dsp-sort", col = c[1] }, style = "list_box_item",
      tooltip = { "ppd-dsp.sort-tip" } })
    b.style.width = c[2]
    b.style.font = "default-bold"
  end
  t.add({ type = "empty-widget" })
  for _, ds in ipairs(list) do
    local lead = storage.tr[ds.lead]
    local st = engine.STATUS[ds.status] or engine.STATUS.idle
    local c = S.COLORS[lead.color or 1]
    local nf = t.add({ type = "flow", direction = "horizontal" })
    nf.style.width = 170
    nf.style.vertical_align = "center"
    local chip = nf.add({ type = "sprite", sprite = "ppd-color-" .. (lead.color or 1) })
    chip.style.size = 14
    chip.style.stretch_image_to_widget_size = true
    nf.add({ type = "label", caption = engine.name_of(lead) }).style.maximal_width = 150
    local tiers = {}
    for _, u in ipairs(ds.units) do
      local m = storage.tr[u]
      if m then tiers[#tiers + 1] = "Т-" .. S.TIERS[m.tier].key .. ((m.reserve and state.force(m.force).has_auto) and "*" or "") end
    end
    t.add({ type = "label", caption = table.concat(tiers, " + ") }).style.width = 120
    local lf = t.add({ type = "flow", direction = "horizontal" })
    lf.style.width = 160
    lf.style.vertical_align = "center"
    local bar = lf.add({ type = "progressbar", value = U.clamp((ds.r or 0) / S.LIMIT, 0, 1) })
    bar.style.width = 110
    G.bar_color(bar, st.color)
    lf.add({ type = "label", caption = U.pct(ds.r or 0) })
    local pl = t.add({ type = "label", caption = U.tpower(ds.L or 0) })
    pl.style.width = 90
    local bl = t.add({ type = "label", caption = (ds.bonus or 0) > 0 and U.signed_pct(ds.bonus) or { "ppd-gui.none" } })
    bl.style.width = 70
    if (ds.bonus or 0) > 0 then bl.style.font_color = { 0.56, 0.89, 0.42 } end
    local prl = t.add({ type = "label", caption = { "ppd-prio." .. (lead.prio or 2) } })
    prl.style.width = 120
    local share = advisor.zone_share(lead.h60, ds.lo, ds.hi)
    t.add({ type = "label", caption = share and U.pct(share) or "—" }).style.width = 120
    local sl = t.add({ type = "label", caption = { "ppd-status." .. ds.status } })
    sl.style.width = 160
    sl.style.font_color = st.color
    t.add({ type = "sprite-button", style = "tool_button", sprite = "utility/center", tooltip = { "ppd-dsp.show" },
      tags = { ppd = "dsp-show", unit = ds.lead } })
  end
  if #list == 0 then t.add({ type = "label", caption = { "ppd-dsp.no-districts" } }) end
  local items = {}
  for _, ds in ipairs(list) do
    for _, a in ipairs(advisor.district(ds)) do
      if #items < 30 then items[#items + 1] = a end
    end
  end
  if #items == 0 then items[1] = { level = "ok", msg = { "ppd-dsp.advisor-empty" } } end
  G.lines(refs.advice, items, 1000)
end

---------------------------------------------------------------- journal

local JKINDS = { "all", "zone", "overload", "auto", "destroy", "wire" }

local function build_journal(page, refs)
  local row = page.add({ type = "flow", direction = "horizontal" })
  row.style.horizontal_spacing = 4
  refs.jbtn = {}
  for _, k in ipairs(JKINDS) do
    refs.jbtn[k] = row.add({ type = "button", caption = { "ppd-dsp.j-" .. k }, tags = { ppd = "dsp-jfilter", k = k } })
    refs.jbtn[k].style.minimal_width = 0
  end
  G.spacer(row)
  row.add({ type = "label", caption = { "ppd-dsp.j-last" } }).style.font_color = GREY
  local fr = page.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  fr.style.horizontally_stretchable = true
  local sp = fr.add({ type = "scroll-pane" })
  sp.style.maximal_height = 500
  sp.style.horizontally_stretchable = true
  refs.jt = sp.add({ type = "table", column_count = 3 })
  refs.jt.style.padding = 8
  refs.jt.style.horizontal_spacing = 12
end

local function refresh_journal(player, refs)
  local pd = state.player(player.index)
  local k = pd.jfilter or "all"
  for kk, b in pairs(refs.jbtn) do
    b.toggled = (kk == k)
    b.style.font = (kk == k) and "default-bold" or "default"
  end
  local f = state.force(player.force.index)
  if refs.jn == f.jn and refs.jk == k then return end
  refs.jn, refs.jk = f.jn, k
  local t = refs.jt
  t.clear()
  local list = journal.list(player.force.index, k, 120)
  for _, e in ipairs(list) do
    t.add({ type = "label", caption = U.clock(e.t) }).style.font_color = GREY
    local l = t.add({ type = "label", caption = e.msg })
    l.style.width = 860
    l.style.single_line = false
    if e.l == "alarm" then l.style.font_color = { 1, 0.6, 0.5 } end
    if e.u and storage.tr[e.u] then
      t.add({ type = "button", caption = { "ppd-dsp.show" }, tags = { ppd = "dsp-show", unit = e.u } })
    elseif e.pos and e.s then
      t.add({ type = "button", caption = { "ppd-dsp.show" }, tags = { ppd = "dsp-goto", x = e.pos.x, y = e.pos.y, s = e.s } })
    else
      t.add({ type = "empty-widget" })
    end
  end
  if #list == 0 then t.add({ type = "label", caption = { "ppd-dsp.j-empty" } }) end
end

---------------------------------------------------------------- automation

local function build_automation(page, refs, player)
  local f = state.force(player.force.index)
  refs.anote = page.add({ type = "label", caption = { "ppd-dsp.a-locked" } })
  refs.anote.style.font_color = { 1, 0.85, 0.36 }
  local row = page.add({ type = "flow", direction = "horizontal" })
  row.style.horizontal_spacing = 12
  row.style.horizontally_stretchable = true
  local left = row.add({ type = "flow", direction = "vertical" })
  left.style.width = 500
  left.style.vertical_spacing = 12
  local function section(parent, caption_key, check_key, check_ref)
    local fr = parent.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
    fr.style.horizontally_stretchable = true
    local head = fr.add({ type = "frame", style = "subheader_frame" })
    head.style.horizontally_stretchable = true
    if check_key then
      refs[check_ref] = head.add({ type = "checkbox", state = true, tags = { ppd = check_key } })
    end
    head.add({ type = "label", style = "subheader_caption_label", caption = { caption_key } })
    local body = fr.add({ type = "flow", direction = "vertical" })
    body.style.padding = 10
    body.style.vertical_spacing = 6
    return body
  end
  local s1 = section(left, "ppd-dsp.a-shed", "dsp-a-shed", "a_shed")
  G.add(s1, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 8 }, children = {
    { type = "label", caption = { "ppd-dsp.a-threshold" }, style_mods = { width = 120 } },
    { type = "slider", ref = "a_thr", minimum_value = 50, maximum_value = 99, value = 95, value_step = 1, tags = { ppd = "dsp-a-thr" },
      style_mods = { width = 250 } },
    { type = "label", ref = "a_thr_l", style_mods = { font = "default-semibold", width = 50 } } } }, refs)
  G.add(s1, { type = "label", caption = { "ppd-dsp.a-shed-note" }, style_mods = { font = "default-small", font_color = GREY, single_line = false, maximal_width = 470 } })
  local s2 = section(left, "ppd-dsp.a-restore", "dsp-a-restore", "a_restore")
  G.add(s2, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 8 }, children = {
    { type = "label", caption = { "ppd-dsp.a-pause" }, style_mods = { width = 120 } },
    { type = "slider", ref = "a_pause", minimum_value = 5, maximum_value = 120, value = 15, value_step = 5, tags = { ppd = "dsp-a-pause" },
      style_mods = { width = 250 } },
    { type = "label", ref = "a_pause_l", style_mods = { font = "default-semibold", width = 50 } } } }, refs)
  G.add(s2, { type = "label", caption = { "ppd-dsp.a-restore-note" }, style_mods = { font = "default-small", font_color = GREY, single_line = false, maximal_width = 470 } })
  local s3 = section(left, "ppd-dsp.a-reserves")
  refs.reserves = s3.add({ type = "flow", direction = "vertical" })
  local right = row.add({ type = "flow", direction = "vertical" })
  right.style.horizontally_stretchable = true
  right.style.vertical_spacing = 12
  local q = section(right, "ppd-dsp.a-queue")
  refs.queue = q.add({ type = "flow", direction = "vertical" })
  refs.queue.style.vertical_spacing = 4
  refs.qnote = q.add({ type = "label" })
  refs.qnote.style.font = "default-small"
  refs.qnote.style.font_color = GREY
  refs.qnote.style.single_line = false
  refs.qnote.style.maximal_width = 520
  local d = section(right, "ppd-dsp.a-drill")
  d.add({ type = "button", caption = { "ppd-dsp.a-drill-btn" }, tags = { ppd = "dsp-drill" }, tooltip = { "ppd-dsp.a-drill-tip" } })
  refs.drill = d.add({ type = "label" })
  refs.drill.style.single_line = false
  refs.drill.style.maximal_width = 520
end

-- ordered shed candidates of the force: queue order first, then secondary before normal
function W.shed_order(force_index)
  local f = state.force(force_index)
  local rank = {}
  for i, did in ipairs(f.auto.queue) do rank[did] = i end
  local list = {}
  for _, ds in ipairs(districts(force_index)) do
    local lead = storage.tr[ds.lead]
    if lead.prio == 3 or (lead.prio == 2 and lead.can_shed) then list[#list + 1] = ds end
  end
  table.sort(list, function(a, b)
    local la, lb = storage.tr[a.lead], storage.tr[b.lead]
    local ra = rank[a.did] or (1e6 + (la.prio == 3 and 0 or 1e5) + a.did)
    local rb = rank[b.did] or (1e6 + (lb.prio == 3 and 0 or 1e5) + b.did)
    return ra < rb
  end)
  return list
end

local function refresh_automation(player, refs)
  local f = state.force(player.force.index)
  local a = f.auto
  refs.anote.visible = not f.has_auto
  refs.a_shed.state = a.shed
  refs.a_restore.state = a.restore
  refs.a_thr.slider_value = math.floor(a.threshold * 100 + 0.5)
  refs.a_thr_l.caption = { "", math.floor(a.threshold * 100 + 0.5), " %" }
  refs.a_pause.slider_value = math.floor(a.pause / 60 + 0.5)
  refs.a_pause_l.caption = { "ppd-unit.seconds", math.floor(a.pause / 60 + 0.5) }
  local order = W.shed_order(player.force.index)
  local key = {}
  for _, ds in ipairs(order) do key[#key + 1] = ds.did end
  key = table.concat(key, ",")
  if refs.qkey ~= key then
    refs.qkey = key
    refs.queue.clear()
    for i, ds in ipairs(order) do
      local lead = storage.tr[ds.lead]
      local row = refs.queue.add({ type = "frame", style = "deep_frame_in_shallow_frame", direction = "horizontal" })
      row.style.padding = 4
      row.style.vertical_align = "center"
      row.style.horizontally_stretchable = true
      row.add({ type = "label", caption = tostring(i) }).style.font = "default-bold"
      local chip = row.add({ type = "sprite", sprite = "ppd-color-" .. (lead.color or 1) })
      chip.style.size = 14
      chip.style.stretch_image_to_widget_size = true
      row.add({ type = "label", caption = engine.name_of(lead) }).style.width = 200
      local pl = row.add({ type = "label", caption = { "ppd-prio." .. lead.prio } })
      pl.style.width = 120
      row.add({ type = "label", caption = U.tpower(ds.L or 0) }).style.width = 80
      G.spacer(row)
      local up = row.add({ type = "button", caption = "▲", tags = { ppd = "dsp-q", did = ds.did, d = -1 }, tooltip = { "ppd-dsp.a-up" } })
      up.style.minimal_width = 28
      up.style.width = 28
      up.enabled = i > 1
      local dn = row.add({ type = "button", caption = "▼", tags = { ppd = "dsp-q", did = ds.did, d = 1 }, tooltip = { "ppd-dsp.a-down" } })
      dn.style.minimal_width = 28
      dn.style.width = 28
      dn.enabled = i < #order
    end
    if #order == 0 then refs.queue.add({ type = "label", caption = { "ppd-dsp.a-queue-empty" } }) end
  end
  local never, other = {}, {}
  for _, ds in ipairs(districts(player.force.index)) do
    local lead = storage.tr[ds.lead]
    if lead.prio == 1 then never[#never + 1] = engine.name_of(lead)
    elseif lead.prio == 2 and not lead.can_shed then other[#other + 1] = engine.name_of(lead) end
  end
  local function join(list)
    local out = { "" }
    for i, n in ipairs(list) do
      if i > 1 then out[#out + 1] = ", " end
      if #out > 18 then out[#out + 1] = "…" break end
      out[#out + 1] = { "", "«", n, "»" }
    end
    if #list == 0 then out[#out + 1] = "—" end
    return out
  end
  refs.qnote.caption = { "ppd-dsp.a-queue-note", join(never), join(other) }
  refs.reserves.clear()
  local any = false
  for _, ds in ipairs(districts(player.force.index)) do
    for _, u in ipairs(ds.units) do
      local m = storage.tr[u]
      if m and m.reserve then
        any = true
        local row = refs.reserves.add({ type = "flow", direction = "horizontal" })
        row.style.vertical_align = "center"
        row.style.horizontal_spacing = 6
        local ic = row.add({ type = "sprite", sprite = "item/" .. m.e.name })
        ic.style.size = 24
        ic.style.stretch_image_to_widget_size = true
        local st = engine.STATUS[m.status] or engine.STATUS.idle
        row.add({ type = "label", caption = { "ppd-dsp.a-reserve-of", engine.name_of(m), { "", "Т-", S.TIERS[m.tier].key } } })
        G.spacer(row)
        row.add({ type = "sprite", sprite = DIODE_SPRITE[m.noin and defines.entity_status_diode.red or st.diode] })
        row.add({ type = "label", caption = m.noin and { "ppd-status.noinput" } or { "ppd-status." .. m.status } })
      end
    end
  end
  if not any then refs.reserves.add({ type = "label", caption = { "ppd-dsp.a-no-reserves" } }) end
end

local function drill(player, refs)
  local f = state.force(player.force.index)
  local pole = general_pole(player)
  if not pole then
    refs.drill.caption = { "ppd-dsp.no-network" }
    return
  end
  local level = math.max(0.5, f.auto.threshold - 0.10)
  local _, _, _, demand = engine.flow_numbers(pole)
  local deficit = (demand or 0) * (1 - level)
  local names, sum = { "" }, 0
  for _, ds in ipairs(W.shed_order(player.force.index)) do
    if sum >= deficit then break end
    local lead = storage.tr[ds.lead]
    if #names > 1 then names[#names + 1] = ", " end
    names[#names + 1] = { "", "«", engine.name_of(lead), "»" }
    sum = sum + (ds.L or 0)
  end
  local ok = sum >= deficit
  local important = {}
  for _, ds in ipairs(districts(player.force.index)) do
    if storage.tr[ds.lead].prio == 1 then important[#important + 1] = engine.name_of(storage.tr[ds.lead]) end
  end
  refs.drill.caption = { ok and "ppd-dsp.a-drill-ok" or "ppd-dsp.a-drill-short", math.floor(level * 100 + 0.5),
    U.tpower(deficit), #names > 1 and names or { "ppd-gui.none" }, U.tpower(sum), #important }
end

---------------------------------------------------------------- dispatch

local BUILD = { build_overview, build_scheme, build_map, build_districts, build_journal, build_automation }
local REFRESH = { refresh_overview, refresh_scheme, refresh_map, refresh_districts, refresh_journal, refresh_automation }

function W.refresh(player, force)
  local pd = state.player(player.index)
  local d = pd.dsp
  if not d then return end
  local frame = player.gui.screen[NAME]
  if not (frame and frame.valid) then
    pd.dsp = nil
    return
  end
  local i = pd.tab or 1
  local page = d.pages[i]
  if not (page and page.valid) then return end
  if not d.built[i] then
    page.clear()
    d.refs[i] = {}
    BUILD[i](page, d.refs[i], player)
    d.built[i] = true
  end
  REFRESH[i](player, d.refs[i])
end

function W.on_tab(player, el)
  if el.tags.ppd ~= "dsp-tab" then return false end
  local pd = state.player(player.index)
  pd.tab = el.selected_tab_index or 1
  W.refresh(player, true)
  return true
end

local function goto_entity(player, e)
  if not (e and e.valid) then return end
  player.centered_on = e
end

function W.on_click(player, el, tags, event)
  local a = tags.ppd
  if a == "dsp-close" then
    W.close(player)
    return true
  end
  local pd = state.player(player.index)
  if not pd.dsp then return false end
  local refs = pd.dsp.refs[pd.tab or 1] or {}
  local f = state.force(player.force.index)
  if a == "dsp-show" then
    local m = storage.tr[tags.unit]
    if m and m.e.valid then
      goto_entity(player, m.e)
      map.show_district(player, m)
    end
    return true
  elseif a == "dsp-goto" then
    local s = game.surfaces[tags.s]
    if s then player.set_controller({ type = defines.controllers.remote, position = { tags.x, tags.y }, surface = s }) end
    return true
  elseif a == "dsp-open" then
    local m = storage.tr[tags.unit]
    if m and m.e.valid then
      if event.button == defines.mouse_button_type.right then
        goto_entity(player, m.e)
        map.show_district(player, m)
      else
        W.close(player)
        ui_hub.open_transformer(player, m)
      end
    end
    return true
  elseif a == "dsp-map-select" then
    pd.map_did = tags.did
  elseif a == "dsp-emap" then
    map.toggle(player)
  elseif a == "dsp-sort" then
    if pd.sort == tags.col then pd.sort_desc = not pd.sort_desc else pd.sort, pd.sort_desc = tags.col, true end
  elseif a == "dsp-jfilter" then
    pd.jfilter = tags.k
  elseif a == "dsp-q" then
    local order = W.shed_order(player.force.index)
    local ids = {}
    for i, ds in ipairs(order) do ids[i] = ds.did end
    for i, did in ipairs(ids) do
      if did == tags.did then
        local j = i + tags.d
        if ids[j] then ids[i], ids[j] = ids[j], ids[i] end
        break
      end
    end
    f.auto.queue = ids
    refs.qkey = nil
  elseif a == "dsp-drill" then
    drill(player, refs)
    return true
  else
    return false
  end
  W.refresh(player)
  return true
end

function W.on_changed(player, el, tags)
  local a = tags.ppd
  local f = state.force(player.force.index)
  if a == "dsp-a-shed" then f.auto.shed = el.state
  elseif a == "dsp-a-restore" then f.auto.restore = el.state
  elseif a == "dsp-a-thr" then f.auto.threshold = el.slider_value / 100
  elseif a == "dsp-a-pause" then f.auto.pause = el.slider_value * 60
  else return false end
  W.refresh(player)
  return true
end

function W.set_hub(h) ui_hub = h end

return W
