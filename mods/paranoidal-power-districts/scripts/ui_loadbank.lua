-- Load bank window: mode, power, whether it pays off now.
local S = require("shared")
local state = require("scripts.state")
local engine = require("scripts.engine")
local U = require("scripts.util")
local G = require("scripts.gui")

local W = {}
local NAME = "ppd_loadbank"

function W.close(player)
  local f = player.gui.screen[NAME]
  if f and f.valid then f.destroy() end
  state.player(player.index).lb = nil
end

function W.open(player, lb)
  W.close(player)
  local refs = {}
  local frame = player.gui.screen.add({ type = "frame", name = NAME, direction = "vertical" })
  frame.auto_center = true
  G.titlebar(frame, { "entity-name.ppd-load-bank" }, "lb-close")
  local body = frame.add({ type = "flow", direction = "horizontal" })
  body.style.horizontal_spacing = 12
  local left = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  left.style.width = 170
  local pf = left.add({ type = "frame", style = "deep_frame_in_shallow_frame" })
  pf.style.margin = 8
  local preview = pf.add({ type = "entity-preview" })
  preview.style.width = 146
  preview.style.height = 120
  preview.entity = lb.e
  G.add(left, { type = "flow", style_mods = { padding = { 0, 8, 8, 8 }, vertical_align = "center", horizontal_spacing = 6 }, children = {
    { type = "sprite", ref = "st_sprite", sprite = "utility/status_working" },
    { type = "label", ref = "st_label" } } }, refs)
  local right = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  right.style.width = 470
  G.add(right, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
    { type = "label", style = "subheader_caption_label", ref = "dname" } } }, refs)
  local c = G.add(right, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 8 } })
  G.add(c, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 0 }, children = {
    { type = "label", caption = { "ppd-gui.lb-mode" }, style_mods = { width = 110 } },
    { type = "button", caption = { "ppd-gui.lb-manual" }, ref = "m1", tags = { ppd = "lb-mode", mode = 1 } },
    { type = "button", caption = { "ppd-gui.lb-signal" }, ref = "m2", tags = { ppd = "lb-mode", mode = 2 }, tooltip = { "ppd-gui.lb-signal-tip" } },
    { type = "button", caption = { "ppd-gui.lb-auto" }, ref = "m3", tags = { ppd = "lb-mode", mode = 3 }, tooltip = { "ppd-gui.lb-auto-tip" } },
  } }, refs)
  G.add(c, { type = "flow", style_mods = { vertical_align = "center", horizontal_spacing = 8 }, children = {
    { type = "label", caption = { "ppd-gui.lb-power" }, style_mods = { width = 110 } },
    { type = "slider", ref = "slider", minimum_value = 0, maximum_value = 100, value = 0, value_step = 1,
      tags = { ppd = "lb-slider" }, style_mods = { width = 230 } },
    { type = "label", ref = "cur", style_mods = { font = "default-semibold", minimal_width = 80, horizontal_align = "right" } },
  } }, refs)
  G.add(c, { type = "label", ref = "note", caption = { "ppd-gui.lb-note" },
    style_mods = { font = "default-small", font_color = { 0.7, 0.7, 0.7 }, single_line = false, maximal_width = 440 } }, refs)
  G.add(c, { type = "table", column_count = 2, style_mods = { horizontal_spacing = 16 }, children = {
    { type = "label", caption = { "ppd-gui.lb-without" } }, { type = "label", ref = "r_without", style_mods = { font = "default-semibold" } },
    { type = "label", caption = { "ppd-gui.lb-with" } }, { type = "label", ref = "r_with", style_mods = { font = "default-semibold" } },
  } }, refs)
  local box = c.add({ type = "frame", style = "deep_frame_in_shallow_frame", direction = "vertical" })
  box.style.padding = 8
  box.style.horizontally_stretchable = true
  refs.verdict = box.add({ type = "flow", direction = "vertical" })
  state.player(player.index).lb = { unit = lb.unit, refs = refs }
  player.opened = frame
  W.refresh(player)
end

function W.refresh(player)
  local pd = state.player(player.index)
  local t = pd.lb
  if not t then return end
  local lb = storage.lb[t.unit]
  local r = t.refs
  if not (lb and lb.e.valid and r.slider.valid) then
    W.close(player)
    return
  end
  for i = 1, 3 do
    r["m" .. i].toggled = (lb.mode == i)
    r["m" .. i].style.font = (lb.mode == i) and "default-bold" or "default"
  end
  r.slider.enabled = (lb.mode == 1)
  if lb.mode == 1 then r.slider.slider_value = math.floor(lb.w / 1e5 + 0.5) end
  r.cur.caption = U.power(lb.cur or 0)
  local ds = lb.did and storage.dist[lb.did]
  local lead = ds and storage.tr[ds.lead]
  local working = (lb.cur or 0) > 0 and lb.eei and lb.eei.valid and lb.eei.energy > 0
  r.st_sprite.sprite = working and "utility/status_working" or "utility/status_yellow"
  r.st_label.caption = working and { "ppd-gui.lb-working" } or { "ppd-gui.lb-idle" }
  if not (ds and lead and ds.N and ds.N > 0) then
    r.dname.caption = { "ppd-gui.lb-no-district" }
    r.r_without.caption = "—"
    r.r_with.caption = "—"
    G.lines(r.verdict, { { level = "warn", msg = { "ppd-gui.lb-pointless" } } }, 420)
    return
  end
  local tier = S.TIERS[lead.tier]
  r.dname.caption = { "ppd-gui.lb-district", engine.name_of(lead), { "", "Т-", tier.key } }
  local bank = (lb.cur or 0) / 60
  local machines = math.max(0, ds.Lnow - bank)
  r.r_without.caption = U.pct(machines / ds.N)
  r.r_with.caption = U.pct(ds.Lnow / ds.N)
  local f = state.force(ds.force)
  local B = tier.bonus * state.bonus_mult(f)
  local idle = 0
  local with_bank = ds.Lnow / (1 + ((ds.Lnow / ds.N >= ds.lo and ds.Lnow / ds.N <= ds.hi) and B or 0)) + idle
  local without = machines
  if machines / ds.N >= ds.lo and machines / ds.N <= ds.hi then without = machines / (1 + B) end
  if bank <= 0 then
    G.lines(r.verdict, { { level = "warn", msg = { "ppd-gui.lb-off" } } }, 420)
  elseif with_bank < without then
    G.lines(r.verdict, { { level = "ok", msg = { "ppd-gui.lb-good", U.tpower(with_bank), U.tpower(without), U.tpower(without - with_bank) } } }, 420)
  else
    G.lines(r.verdict, { { level = "bad", msg = { "ppd-gui.lb-bad", U.tpower(bank), U.tpower(with_bank), U.tpower(without),
      math.floor(ds.lo / (1 + B) * 100 + 0.5) } } }, 420)
  end
end

function W.on_click(player, el, tags)
  local a = tags.ppd
  if a == "lb-close" then
    W.close(player)
    return true
  end
  local t = state.player(player.index).lb
  local lb = t and storage.lb[t.unit]
  if not lb then return false end
  if a == "lb-mode" then
    lb.mode = tags.mode
    W.refresh(player)
    return true
  end
  return false
end

function W.on_value(player, el, tags)
  if tags.ppd ~= "lb-slider" then return false end
  local t = state.player(player.index).lb
  local lb = t and storage.lb[t.unit]
  if not lb then return false end
  lb.w = el.slider_value * 1e5
  return true
end

return W
