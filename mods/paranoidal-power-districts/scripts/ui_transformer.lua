-- Transformer window: main view (status, load gauge, flows, history, advice) and settings view.
local S = require("shared")
local state = require("scripts.state")
local engine = require("scripts.engine")
local build = require("scripts.build")
local advisor = require("scripts.advisor")
local journal = require("scripts.journal")
local U = require("scripts.util")
local G = require("scripts.gui")

local W = {}
local NAME = "ppd_transformer"
local GAUGE_W = 496
local DIODE_SPRITE = {
  [defines.entity_status_diode.green] = "utility/status_working",
  [defines.entity_status_diode.yellow] = "utility/status_yellow",
  [defines.entity_status_diode.red] = "utility/status_not_working",
}
local CMPS = { ">", "<", "=", "≥", "≤", "≠" }

local function members_of(m)
  local ds = storage.dist[m.did]
  local out = {}
  if ds and ds.units then
    for _, u in ipairs(ds.units) do
      local x = storage.tr[u]
      if x then out[#out + 1] = x end
    end
  end
  if #out == 0 then out[1] = m end
  return out
end
W.members_of = members_of

function W.close(player)
  local pd = state.player(player.index)
  local f = player.gui.screen[NAME]
  if f and f.valid then f.destroy() end
  pd.tr = nil
end

local function build_main(parent, refs, m)
  G.add(parent, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
    { type = "label", style = "subheader_caption_label", ref = "dname" },
    { type = "sprite", ref = "chip", style_mods = { width = 16, height = 16, stretch_image_to_widget_size = true } },
    { type = "sprite-button", style = "tool_button", sprite = "utility/rename_icon", tooltip = { "ppd-gui.rename" },
      tags = { ppd = "tr-rename" } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "button", caption = { "ppd-prio.1" }, ref = "prio1", tags = { ppd = "tr-prio", prio = 1 }, tooltip = { "ppd-prio-tip.1" },
      style_mods = { minimal_width = 0, padding = { 0, 8 } } },
    { type = "button", caption = { "ppd-prio.2" }, ref = "prio2", tags = { ppd = "tr-prio", prio = 2 }, tooltip = { "ppd-prio-tip.2" },
      style_mods = { minimal_width = 0, padding = { 0, 8 } } },
    { type = "button", caption = { "ppd-prio.3" }, ref = "prio3", tags = { ppd = "tr-prio", prio = 3 }, tooltip = { "ppd-prio-tip.3" },
      style_mods = { minimal_width = 0, padding = { 0, 8 } } },
  } }, refs)
  local c = G.add(parent, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 8 } })
  G.add(c, { type = "flow", direction = "horizontal", style_mods = { vertical_align = "center", horizontal_spacing = 8 }, children = {
    { type = "label", style = "caption_label", caption = { "ppd-gui.load" } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "label", ref = "pct", style_mods = { font = "heading-2" } },
    { type = "label", ref = "loadtxt", style_mods = { font_color = { 0.7, 0.7, 0.7 } } },
  } }, refs)
  G.add(c, { type = "progressbar", ref = "bar", value = 0, style_mods = { width = GAUGE_W, bar_width = 14 } }, refs)
  G.add(c, { type = "flow", direction = "horizontal", style_mods = { horizontal_spacing = 0, top_margin = -6 }, children = {
    { type = "empty-widget", style = "ppd_bar_grey", ref = "z1", style_mods = { height = 4 } },
    { type = "empty-widget", style = "ppd_bar_green", ref = "z2", style_mods = { height = 4 } },
    { type = "empty-widget", style = "ppd_bar_grey", ref = "z3", style_mods = { height = 4 } },
  } }, refs)
  G.add(c, { type = "label", ref = "scale", style_mods = { font = "default-small", font_color = { 0.7, 0.7, 0.7 } } }, refs)
  G.add(c, { type = "table", column_count = 4, ref = "kv",
    style_mods = { horizontal_spacing = 16, vertical_spacing = 2 }, children = {
    { type = "label", caption = { "ppd-gui.from-grid" } }, { type = "label", ref = "v_take", style_mods = { font = "default-semibold", minimal_width = 90, horizontal_align = "right" } },
    { type = "label", caption = { "ppd-gui.bonus" } }, { type = "label", ref = "v_bonus", style_mods = { font = "default-semibold", minimal_width = 90, horizontal_align = "right" } },
    { type = "label", caption = { "ppd-gui.to-district" } }, { type = "label", ref = "v_out", style_mods = { font = "default-semibold", minimal_width = 90, horizontal_align = "right" } },
    { type = "label", caption = { "ppd-gui.saving" } }, { type = "label", ref = "v_saved", style_mods = { font = "default-semibold", minimal_width = 90, horizontal_align = "right" } },
  } }, refs)
  G.add(c, { type = "flow", direction = "horizontal", style_mods = { vertical_align = "center", horizontal_spacing = 4 }, children = {
    { type = "label", style = "caption_label", caption = { "ppd-gui.history" }, style_mods = { right_margin = 8 } },
    { type = "button", caption = { "ppd-gui.h5" }, ref = "h1", tags = { ppd = "tr-hist", h = 1 }, style_mods = { minimal_width = 0, height = 24, padding = { 0, 6 } } },
    { type = "button", caption = { "ppd-gui.h60" }, ref = "h2", tags = { ppd = "tr-hist", h = 2 }, style_mods = { minimal_width = 0, height = 24, padding = { 0, 6 } } },
    { type = "button", caption = { "ppd-gui.h600" }, ref = "h3", tags = { ppd = "tr-hist", h = 3 }, style_mods = { minimal_width = 0, height = 24, padding = { 0, 6 } } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "label", ref = "hshare", style_mods = { font = "default-small", font_color = { 0.7, 0.7, 0.7 } } },
  } }, refs)
  local chart = c.add({ type = "frame", style = "ppd_chart_frame", direction = "horizontal" })
  chart.style.width = GAUGE_W
  refs.bars = {}
  for i = 1, 60 do
    local b = chart.add({ type = "empty-widget", style = "ppd_bar_grey" })
    b.style.height = 1
    refs.bars[i] = b
  end
  local why = c.add({ type = "frame", style = "deep_frame_in_shallow_frame", direction = "vertical" })
  why.style.horizontally_stretchable = true
  why.style.padding = 8
  refs.why = why.add({ type = "flow", direction = "vertical" })
  refs.why.style.vertical_spacing = 4
end

local function build_settings(parent, refs, m)
  local f = state.force(m.force)
  G.add(parent, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true },
    children = { { type = "label", style = "subheader_caption_label", caption = { "ppd-gui.s-district" } } } })
  local c = G.add(parent, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 8 } })
  G.add(c, { type = "flow", style_mods = { vertical_align = "center" }, children = {
    { type = "label", caption = { "ppd-gui.s-name" }, style_mods = { width = 150 } },
    { type = "textfield", ref = "name_field", tags = { ppd = "tr-name" }, style_mods = { width = 260 } },
  } }, refs)
  local colors = G.add(c, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 4 }, children = {
    { type = "label", caption = { "ppd-gui.s-color" }, style_mods = { width = 150 } } } })
  refs.colors = {}
  for i = 1, #S.COLORS do
    refs.colors[i] = colors.add({ type = "sprite-button", style = "slot_sized_button", sprite = "ppd-color-" .. i,
      tags = { ppd = "tr-color", c = i } })
    refs.colors[i].style.size = 28
    refs.colors[i].style.padding = 2
  end
  G.add(c, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 0 }, children = {
    { type = "label", caption = { "ppd-gui.s-mode" }, style_mods = { width = 150 } },
    { type = "button", caption = { "ppd-gui.mode-main" }, ref = "mode_main", tags = { ppd = "tr-mode", reserve = false } },
    { type = "button", caption = { "ppd-gui.mode-reserve" }, ref = "mode_res", tags = { ppd = "tr-mode", reserve = true },
      tooltip = { "ppd-gui.mode-reserve-tip" } },
  } }, refs)
  -- taps (research "Отпайки"): the nominal of the whole district in steps of 10 %
  local taps = G.add(c, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 0 }, children = {
    { type = "label", caption = { "ppd-gui.s-tap" }, tooltip = { "ppd-gui.tap-tip" }, style_mods = { width = 150 } } } })
  refs.taps = {}
  for v = -S.TAP_LEVELS, S.TAP_LEVELS do
    local b = taps.add({ type = "button", caption = engine.tap_text(v), tags = { ppd = "tr-tap", v = v },
      tooltip = { "ppd-gui.tap-tip" } })
    b.style.minimal_width = 52
    b.style.padding = { 0, 4 }
    refs.taps[v] = b
  end
  G.add(c, { type = "checkbox", state = false, ref = "tap_auto", caption = { "ppd-gui.tap-auto" }, tooltip = { "ppd-gui.tap-auto-tip" },
    tags = { ppd = "tr-tap-auto" }, style_mods = { left_margin = 150 } }, refs)
  G.add(parent, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true },
    children = { { type = "label", style = "subheader_caption_label", caption = { "ppd-gui.s-auto" } } } })
  local a = G.add(parent, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 6 } })
  G.add(a, { type = "checkbox", state = false, ref = "can_shed", caption = { "ppd-gui.can-shed" }, tooltip = { "ppd-gui.can-shed-tip" },
    tags = { ppd = "tr-can-shed" } }, refs)
  G.add(a, { type = "checkbox", state = true, ref = "guard", caption = { "ppd-gui.guard" }, tooltip = { "ppd-gui.guard-tip" },
    tags = { ppd = "tr-guard" } }, refs)
  G.add(a, { type = "flow", style_mods = { vertical_align = "center" }, children = {
    { type = "label", caption = { "ppd-gui.messages" }, style_mods = { width = 150 } },
    { type = "drop-down", ref = "msg", tags = { ppd = "tr-msg" },
      items = { { "ppd-gui.msg-all" }, { "ppd-gui.msg-alarms" }, { "ppd-gui.msg-none" } } },
  } }, refs)
  G.add(parent, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true },
    children = { { type = "label", style = "subheader_caption_label", caption = { "ppd-gui.s-circuit" } } } })
  local s = G.add(parent, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 6 } })
  G.add(s, { type = "checkbox", state = false, ref = "sig", caption = { "ppd-gui.signals" }, tooltip = { "ppd-gui.signals-tip" },
    tags = { ppd = "tr-sig" } }, refs)
  G.add(s, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 8 }, children = {
    { type = "checkbox", state = false, ref = "cond_on", caption = { "ppd-gui.cond" }, tooltip = { "ppd-gui.cond-tip" },
      tags = { ppd = "tr-cond-on" } },
    { type = "choose-elem-button", elem_type = "signal", ref = "cond_sig", tags = { ppd = "tr-cond-sig" }, style = "slot_button_in_shallow_frame" },
    { type = "drop-down", ref = "cond_cmp", items = CMPS, selected_index = 1, tags = { ppd = "tr-cond-cmp" }, style_mods = { width = 56 } },
    { type = "textfield", ref = "cond_val", numeric = true, allow_negative = true, allow_decimal = false, text = "90",
      tags = { ppd = "tr-cond-val" }, style_mods = { width = 70 } },
  } }, refs)
  G.add(parent, { type = "flow", style_mods = { padding = { 0, 12, 12, 12 } }, children = {
    { type = "button", style = "back_button", caption = { "ppd-gui.back" }, tags = { ppd = "tr-back" } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "label", caption = { "ppd-gui.applied" }, style_mods = { font_color = { 0.7, 0.7, 0.7 } } },
  } })
  refs.has_auto = f.has_auto
end

function W.open(player, m)
  W.close(player)
  local pd = state.player(player.index)
  local refs = {}
  local tier = S.TIERS[m.tier]
  local frame = player.gui.screen.add({ type = "frame", name = NAME, direction = "vertical" })
  frame.auto_center = true
  G.titlebar(frame, { "ppd-gui.transformer-title", tier.key }, "tr-close")
  local body = frame.add({ type = "flow", direction = "horizontal" })
  body.style.horizontal_spacing = 12
  local left = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  left.style.width = 210
  local pf = left.add({ type = "frame", style = "deep_frame_in_shallow_frame" })
  pf.style.margin = 8
  local preview = pf.add({ type = "entity-preview" })
  preview.style.width = 186
  preview.style.height = 150
  preview.entity = m.e
  G.add(left, { type = "flow", direction = "vertical", style_mods = { padding = { 0, 8, 8, 8 }, vertical_spacing = 4 }, children = {
    { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 6 }, children = {
      { type = "sprite", ref = "st_sprite", sprite = "utility/status_yellow" },
      { type = "label", ref = "st_label", style_mods = { single_line = false, maximal_width = 170 } } } },
    { type = "label", ref = "info", style_mods = { font = "default-small", font_color = { 0.7, 0.7, 0.7 }, single_line = false, maximal_width = 186 } },
  } }, refs)
  local right = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  right.style.width = GAUGE_W + 24
  refs.main = right.add({ type = "flow", direction = "vertical" })
  refs.main.style.vertical_spacing = 0
  refs.settings = right.add({ type = "flow", direction = "vertical", visible = false })
  refs.settings.style.vertical_spacing = 0
  build_main(refs.main, refs, m)
  build_settings(refs.settings, refs, m)
  G.add(frame, { type = "flow", style_mods = { top_margin = 8, horizontal_spacing = 8, vertical_align = "center" }, children = {
    { type = "button", caption = { "ppd-gui.show-district" }, tags = { ppd = "tr-show" }, tooltip = { "ppd-gui.show-district-tip" } },
    { type = "button", caption = { "ppd-gui.dispatcher" }, tags = { ppd = "open-dispatcher" } },
    { type = "button", caption = { "ppd-gui.find-wire" }, ref = "findwire", tags = { ppd = "tr-findwire" }, visible = false,
      tooltip = { "ppd-gui.find-wire-tip" } },
    { type = "empty-widget", style_mods = { horizontally_stretchable = true } },
    { type = "sprite-button", style = "tool_button", sprite = "ppd-gear-black", ref = "gear", tags = { ppd = "tr-settings" },
      tooltip = { "ppd-gui.settings" } },
    { type = "button", ref = "toggle", tags = { ppd = "tr-toggle" } },
  } }, refs)
  pd.tr = { unit = m.unit, refs = refs, settings = false }
  pd.hist = pd.hist or 1
  player.opened = frame
  W.fill_settings(player)
  W.refresh(player)
end

local function set_toggled(btn, on)
  btn.toggled = on
  btn.style.font = on and "default-bold" or "default"
end

function W.fill_settings(player)
  local pd = state.player(player.index)
  local t = pd.tr
  if not t then return end
  local m = storage.tr[t.unit]
  if not m then return end
  local r = t.refs
  r.name_field.text = m.name or ""
  for i, b in ipairs(r.colors) do b.toggled = (m.color == i) end
  local f = state.force(m.force)
  set_toggled(r.mode_main, not m.reserve)
  set_toggled(r.mode_res, m.reserve)
  r.mode_res.enabled = f.has_auto
  local tapmax = f.taps or 0
  for v, b in pairs(r.taps) do
    set_toggled(b, (m.tap or 0) == v)
    b.enabled = math.abs(v) <= tapmax
    b.tooltip = tapmax > 0 and { "ppd-gui.tap-tip" } or { "ppd-gui.tap-locked" }
  end
  r.tap_auto.state = m.tap_auto and true or false
  r.tap_auto.enabled = f.auto_taps and tapmax > 0 or false
  r.can_shed.state = m.can_shed and true or false
  r.can_shed.enabled = (m.prio == 2) and f.has_auto
  r.guard.state = m.guard and true or false
  r.msg.selected_index = (m.msg == "all" and 1) or (m.msg == "none" and 3) or 2
  r.sig.state = m.sig and true or false
  local c = m.cond or {}
  r.cond_on.state = c.on and true or false
  r.cond_sig.elem_value = c.sig
  local idx = 1
  for i, op in ipairs(CMPS) do if op == c.cmp then idx = i end end
  r.cond_cmp.selected_index = idx
  r.cond_val.text = tostring(c.val or 90)
end

local function hist_of(lead, h)
  if not lead then return {} end
  if h == 2 then return lead.h60 or {} elseif h == 3 then return lead.h600 or {} end
  return lead.h5 or {}
end

function W.refresh(player)
  local pd = state.player(player.index)
  local t = pd.tr
  if not t then return end
  local m = storage.tr[t.unit]
  local r = t.refs
  if not (m and m.e.valid and r.bar and r.bar.valid) then
    W.close(player)
    return
  end
  local f = state.force(m.force)
  local ds = storage.dist[m.did]
  local st = engine.STATUS[m.status] or engine.STATUS.idle
  r.st_sprite.sprite = DIODE_SPRITE[st.diode]
  r.st_label.caption = { "ppd-status." .. m.status }
  local tier = S.TIERS[m.tier]
  local hw = state.half_width(f)
  local n = (m.nominal and m.nominal * 60) or tier.nominal -- with the tap
  local group_n = ds and ds.N and ds.N * 60 or n
  local members = members_of(m)
  local info = { "", { "ppd-gui.info-nominal", U.power(n) }, "\n",
    { "ppd-gui.info-zone", U.power(n * (1 - hw)), U.power(n * (1 + hw)) }, "\n", { "ppd-gui.info-limit", U.power(n * S.LIMIT) } }
  if #members > 1 then
    info[#info + 1] = "\n"
    info[#info + 1] = { "ppd-gui.info-group", #members, U.power(group_n) }
  end
  if m.reserve and f.has_auto then
    info[#info + 1] = "\n"
    info[#info + 1] = { "ppd-gui.info-reserve" }
  end
  if (m.tap or 0) ~= 0 or m.tap_auto then
    info[#info + 1] = "\n"
    info[#info + 1] = { m.tap_auto and "ppd-gui.info-tap-auto" or "ppd-gui.info-tap", engine.tap_text(m.tap), U.tpower(m.nominal or 0) }
  end
  if f.boost then
    local left = ds and ds.boost_until and math.max(0, ds.boost_until - game.tick)
    local wait = ds and ds.boost_ready and math.max(0, ds.boost_ready - game.tick) or 0
    info[#info + 1] = "\n"
    if left then info[#info + 1] = { "ppd-gui.info-boost-on", math.ceil(left / 60) }
    elseif wait > 0 then info[#info + 1] = { "ppd-gui.info-boost-wait", math.ceil(wait / 60) }
    else info[#info + 1] = { "ppd-gui.info-boost-ready" } end
  end
  local sum_out, sum_saved = 0, 0
  for _, x in ipairs(members) do
    sum_out = sum_out + (x.sum_out or 0)
    sum_saved = sum_saved + (x.sum_saved or 0)
  end
  info[#info + 1] = "\n"
  info[#info + 1] = { "ppd-gui.info-total", U.energy(sum_out), U.energy(math.max(0, sum_saved)) }
  r.info.caption = info
  -- header
  r.dname.caption = engine.name_of(m)
  r.chip.sprite = "ppd-color-" .. (m.color or 1)
  for i = 1, 3 do set_toggled(r["prio" .. i], m.prio == i) end
  -- load
  local ratio = ds and ds.r or 0
  local lo, hi = 1 - hw, 1 + hw
  r.pct.caption = U.pct(ratio)
  r.pct.style.font_color = st.color
  r.loadtxt.caption = { "ppd-gui.load-of", U.tpower(ds and ds.L or 0), U.power(group_n) }
  r.bar.value = U.clamp(ratio / S.LIMIT, 0, 1)
  G.bar_color(r.bar, st.color)
  local w1 = math.floor(GAUGE_W * lo / S.LIMIT)
  local w2 = math.floor(GAUGE_W * (hi - lo) / S.LIMIT)
  r.z1.style.width = w1
  r.z2.style.width = w2
  r.z3.style.width = GAUGE_W - w1 - w2
  r.scale.caption = { "ppd-gui.scale", math.floor(lo * 100 + 0.5), math.floor(hi * 100 + 0.5),
    U.power(group_n * lo), U.power(group_n * hi), U.power(group_n * S.LIMIT) }
  r.v_take.caption = U.tpower(ds and ds.take or 0)
  r.v_out.caption = U.tpower(ds and (ds.Lnow + (ds.transit or 0)) or 0)
  r.v_bonus.caption = (ds and ds.bonus and ds.bonus > 0) and U.signed_pct(ds.bonus) or { "ppd-gui.none" }
  r.v_saved.caption = U.tpower(ds and ds.saved or 0)
  -- history
  local h = pd.hist or 1
  for i = 1, 3 do set_toggled(r["h" .. i], h == i) end
  local lead = ds and storage.tr[ds.lead] or m
  local arr = hist_of(lead, h)
  local n_arr = #arr
  for i = 1, 60 do
    local v = arr[n_arr - 60 + i]
    local b = r.bars[i]
    local style, height = "ppd_bar_grey", 1
    if v then
      height = math.max(2, math.floor(U.clamp(v / S.LIMIT, 0, 1) * 64))
      if v >= S.LIMIT * 0.985 then style = "ppd_bar_red"
      elseif v >= lo and v <= hi then style = "ppd_bar_green"
      else style = "ppd_bar_yellow" end
    end
    if b.style.name ~= style then b.style = style end
    b.style.height = height
  end
  local share = advisor.zone_share(arr, lo, hi)
  r.hshare.caption = share and { "ppd-gui.zone-share", math.floor(share * 100 + 0.5) } or { "ppd-gui.no-history" }
  -- what keeps it from the zone
  local items = {}
  if m.status == "bypass" then
    items[1] = { level = "bad", msg = { "ppd-advice.bypass", engine.name_of(m) } }
  elseif m.status == "zone" then
    items[1] = { level = "ok", msg = { "ppd-gui.why-ok", U.minutes(game.tick - (ds and ds.zone_since or game.tick)) } }
  end
  for _, it in ipairs(advisor.district(ds)) do items[#items + 1] = it end
  if #items == 0 then items[1] = { level = "warn", msg = { "ppd-status-tip." .. m.status } } end
  local top = advisor.top_consumers(m, 3)
  if #top > 0 then
    local line = { "" }
    for i, x in ipairs(top) do
      if i > 1 then line[#line + 1] = ", " end
      line[#line + 1] = { "", "[entity=" .. x.name .. "] ", U.tpower(x.v) }
    end
    items[#items + 1] = { msg = { "ppd-gui.top-consumers", line } }
  end
  G.lines(r.why, items, 470)
  r.findwire.visible = (m.status == "bypass")
  local is_off = m.off
  r.toggle.caption = is_off and { "ppd-gui.turn-on" } or { "ppd-gui.turn-off" }
  r.toggle.style = is_off and "green_button" or "red_button"
  if t.settings and r.has_auto ~= f.has_auto then
    r.has_auto = f.has_auto
    W.fill_settings(player)
  end
end

local function for_district(m, fn)
  for _, x in ipairs(members_of(m)) do fn(x) end
end

local function current(player)
  local pd = state.player(player.index)
  local t = pd.tr
  if not t then return nil end
  local m = storage.tr[t.unit]
  if not (m and m.e.valid) then return nil end
  return m, t, pd
end

-- returns true if handled
function W.on_click(player, el, tags, e)
  local a = tags.ppd
  if a == "tr-close" then
    W.close(player)
    return true
  end
  local m, t, pd = current(player)
  if not m then return false end
  if a == "tr-prio" then
    for_district(m, function(x)
      x.prio = tags.prio
      build.apply_priority(x)
    end)
    W.fill_settings(player)
  elseif a == "tr-hist" then
    pd.hist = tags.h
  elseif a == "tr-settings" or a == "tr-rename" then
    t.settings = not t.settings or a == "tr-rename"
    t.refs.main.visible = not t.settings
    t.refs.settings.visible = t.settings
    W.fill_settings(player)
    if a == "tr-rename" then
      t.refs.name_field.focus()
      t.refs.name_field.select_all()
    end
  elseif a == "tr-back" then
    t.settings = false
    t.refs.main.visible = true
    t.refs.settings.visible = false
  elseif a == "tr-color" then
    for_district(m, function(x) x.color = tags.c end)
    W.fill_settings(player)
  elseif a == "tr-mode" then
    m.reserve = tags.reserve and state.force(m.force).has_auto or false
    storage.topo_dirty = true
    W.fill_settings(player)
  elseif a == "tr-tap" then
    local v = tonumber(tags.v) or 0
    if math.abs(v) <= (state.force(m.force).taps or 0) then
      for_district(m, function(x)
        x.tap = v
        build.apply_limits(x)
      end)
      local ds = storage.dist[m.did]
      if ds then ds.tap_t = game.tick end
    end
    W.fill_settings(player)
  elseif a == "tr-toggle" then
    local off = not m.off
    for_district(m, function(x)
      x.off = off
      if not off then x.shed = nil end
    end)
    journal.add(m.force, "auto", "info", { off and "ppd-journal.off-manual" or "ppd-journal.on-manual", engine.name_of(m) }, m)
  else
    return false
  end
  W.refresh(player)
  return true
end

function W.on_changed(player, el, tags)
  local m, t = current(player)
  if not m then return false end
  local a = tags.ppd
  if a == "tr-name" then
    local name = el.text
    for_district(m, function(x) x.name = (name ~= "" and name) or nil end)
  elseif a == "tr-can-shed" then
    for_district(m, function(x) x.can_shed = el.state end)
  elseif a == "tr-guard" then
    if m.guard ~= el.state then
      storage.guarded = storage.guarded + (el.state and 1 or -1)
      m.guard = el.state
    end
  elseif a == "tr-msg" then
    m.msg = ({ "all", "alarms", "none" })[el.selected_index] or "alarms"
  elseif a == "tr-tap-auto" then
    for_district(m, function(x) x.tap_auto = el.state end)
  elseif a == "tr-sig" then
    m.sig = el.state
  elseif a == "tr-cond-on" or a == "tr-cond-sig" or a == "tr-cond-cmp" or a == "tr-cond-val" then
    local r = t.refs
    m.cond = { on = r.cond_on.state, sig = r.cond_sig.elem_value, cmp = CMPS[r.cond_cmp.selected_index] or ">",
      val = tonumber(r.cond_val.text) or 0 }
  else
    return false
  end
  return true
end

return W
