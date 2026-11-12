-- Power meter (0.2.0): a small display on any electric network. It shows the network's satisfaction on its screen,
-- puts the network numbers on circuit signals and opens a window with them. The network is the one a hidden zero-power
-- consumer at the meter's spot is connected to, so any pole that covers the meter works.
local S = require("shared")
local build = require("scripts.build")
local U = require("scripts.util")
local G = require("scripts.gui")
local state = require("scripts.state")

local M = {}
local NAME = "ppd_meter"
local floor = math.floor
-- E consumption kW, G production kW, M possible production kW, U satisfaction %, C accumulator charge %
local SIGNALS = { "signal-E", "signal-G", "signal-M", "signal-U", "signal-C" }
local GREEN, YELLOW, RED = { 0.56, 0.89, 0.42 }, { 1, 0.85, 0.36 }, { 1, 0.48, 0.41 }

function M.add(entity)
  local unit = entity.unit_number
  if storage.meters[unit] then return storage.meters[unit] end
  build.reset_signals(entity)
  local eei = entity.surface.create_entity({ name = S.METER_EEI, position = entity.position, force = entity.force,
    create_build_effect_smoke = false })
  if eei then eei.destructible = false end
  local mt = { e = entity, eei = eei, unit = unit, force = entity.force.index }
  storage.meters[unit] = mt
  script.register_on_object_destroyed(entity)
  return mt
end

function M.remove(unit)
  local mt = storage.meters[unit]
  if not mt then return end
  if mt.eei and mt.eei.valid then mt.eei.destroy() end
  if mt.screen and mt.screen.valid then mt.screen.destroy() end
  storage.meters[unit] = nil
end

-- numbers of the network the meter stands in: W, shares and J; nil without a network
function M.read(mt)
  local eei = mt.eei
  if not (eei and eei.valid) then
    if not (mt.e and mt.e.valid) then return nil end
    eei = mt.e.surface.create_entity({ name = S.METER_EEI, position = mt.e.position, force = mt.e.force,
      create_build_effect_smoke = false })
    if not eei then return nil end
    eei.destructible = false
    mt.eei = eei
  end
  local sub = eei.electric_network
  local net = sub and sub.parent_network
  local f = net and net.flow_last_tick
  if not f then return nil end
  local demand = f.primary_demand + f.secondary_demand
  local got = f.primary_demand * f.primary_demand_usage + f.secondary_demand * f.secondary_demand_usage
  return {
    use = (got + f.tertiary_demand * f.tertiary_demand_usage) * 60,
    prod = (f.solar_output * f.solar_output_usage + f.primary_output * f.primary_output_usage
      + f.secondary_output * f.secondary_output_usage + f.tertiary_output * f.tertiary_output_usage) * 60,
    max = (f.solar_output + f.primary_output + f.secondary_output) * 60,
    sat = demand > 0 and got / demand or 1,
    acc_e = f.accumulator_energy, acc_c = f.accumulator_capacity,
    id = eei.electric_network_id,
  }
end

local function clamp32(x)
  x = floor(x + 0.5)
  if x > 2147483647 then return 2147483647 elseif x < -2147483648 then return -2147483648 end
  return x
end

local function write(mt, values)
  local cache = mt.sigc
  if cache and values then
    local same = true
    for i = 1, #SIGNALS do
      if cache[i] ~= values[i] then
        same = false
        break
      end
    end
    if same then return end
  elseif not cache and not values then
    return
  end
  local cb = mt.e.get_or_create_control_behavior()
  if not cb then return end
  if cb.sections_count == 0 then cb.add_section() end
  local sec = cb.get_section(1)
  if not sec then return end
  local filters = {}
  if values then
    for i, name in ipairs(SIGNALS) do
      if values[i] ~= 0 then
        filters[#filters + 1] = { value = { type = "virtual", name = name, quality = "normal" }, min = values[i] }
      end
    end
  end
  sec.filters = filters
  if not cb.enabled then cb.enabled = true end
  mt.sigc = values
end

-- 0.2.1: no text over the meter (user: not needed); the one drawn by 0.2.0 goes on the next update
local function drop_screen(mt)
  local o = mt.screen
  if o and o.valid then o.destroy() end
  mt.screen, mt.stext = nil, nil
end

function M.update(mt)
  if not (mt.e and mt.e.valid) then
    M.remove(mt.unit)
    return
  end
  local v = M.read(mt)
  mt.last = v
  if v then
    local acc = v.acc_c > 0 and v.acc_e / v.acc_c * 100 or 0
    write(mt, { clamp32(v.use / 1000), clamp32(v.prod / 1000), clamp32(v.max / 1000), clamp32(v.sat * 100), clamp32(acc) })
  else
    write(mt, nil)
  end
  if mt.screen then drop_screen(mt) end
end

function M.tick()
  for _, mt in pairs(storage.meters) do M.update(mt) end
end

---------------------------------------------------------------- window

function M.close(player)
  local f = player.gui.screen[NAME]
  if f and f.valid then f.destroy() end
  state.player(player.index).meter = nil
end

local ROWS = { "use", "prod", "max", "sat", "acc" }

function M.open(player, mt)
  M.close(player)
  local refs = {}
  local frame = player.gui.screen.add({ type = "frame", name = NAME, direction = "vertical" })
  frame.auto_center = true
  G.titlebar(frame, { "entity-name." .. S.METER }, "meter-close")
  local body = frame.add({ type = "flow", direction = "horizontal" })
  body.style.horizontal_spacing = 12
  local left = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  local pf = left.add({ type = "frame", style = "deep_frame_in_shallow_frame" })
  pf.style.margin = 8
  local preview = pf.add({ type = "entity-preview" })
  preview.style.width = 110
  preview.style.height = 110
  preview.entity = mt.e
  local right = body.add({ type = "frame", style = "inside_shallow_frame", direction = "vertical" })
  right.style.width = 400
  G.add(right, { type = "frame", style = "subheader_frame", style_mods = { horizontally_stretchable = true }, children = {
    { type = "label", style = "subheader_caption_label", ref = "net" } } }, refs)
  local c = G.add(right, { type = "flow", direction = "vertical", style_mods = { padding = 12, vertical_spacing = 8 } })
  local t = G.add(c, { type = "table", column_count = 3, style_mods = { horizontal_spacing = 16, vertical_spacing = 4 } })
  for _, k in ipairs(ROWS) do
    t.add({ type = "label", caption = { "ppd-meter.row-" .. k } })
    local v = t.add({ type = "label" })
    v.style.font = "default-semibold"
    v.style.minimal_width = 110
    v.style.horizontal_align = "right"
    refs[k] = v
    local s = t.add({ type = "label", caption = { "ppd-meter.sig-" .. k } })
    s.style.font_color = { 0.7, 0.7, 0.7 }
  end
  G.add(c, { type = "label", caption = { "ppd-meter.note" },
    style_mods = { font = "default-small", font_color = { 0.7, 0.7, 0.7 }, single_line = false, maximal_width = 370 } })
  state.player(player.index).meter = { unit = mt.unit, refs = refs }
  player.opened = frame
  M.refresh(player)
end

function M.refresh(player)
  local pd = state.player(player.index)
  local w = pd.meter
  if not w then return end
  local mt = storage.meters[w.unit]
  local r = w.refs
  if not (mt and mt.e.valid and r.use and r.use.valid) then
    M.close(player)
    return
  end
  local v = mt.last or M.read(mt)
  if not v then
    r.net.caption = { "ppd-meter.no-network" }
    for _, k in ipairs(ROWS) do r[k].caption = "—" end
    return
  end
  r.net.caption = { "ppd-meter.network", v.id or "?" }
  r.use.caption = U.power(v.use)
  r.prod.caption = U.power(v.prod)
  r.max.caption = U.power(v.max)
  r.sat.caption = U.pct(v.sat)
  r.sat.style.font_color = (v.sat >= 0.999 and GREEN) or (v.sat >= 0.9 and YELLOW) or RED
  if v.acc_c > 0 then
    r.acc.caption = { "", U.pct(v.acc_e / v.acc_c), " (", U.energy(v.acc_e), " / ", U.energy(v.acc_c), ")" }
  else
    r.acc.caption = { "ppd-meter.no-acc" }
  end
end

return M
