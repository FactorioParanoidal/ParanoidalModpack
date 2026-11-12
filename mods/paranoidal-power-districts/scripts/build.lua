-- Building, repairing and removing transformers and load banks with their hidden parts.
local S = require("shared")
local state = require("scripts.state")

local M = {}
local D = defines.direction
local copper = defines.wire_connector_id.pole_copper

-- 0.2.0: one fixed layout (the transformer does not rotate): input = tall bushing on the left, output = right

local SEC_OUT = defines.electric_interface_mode.secondary_output
local MODES = {
  [1] = defines.electric_interface_mode.primary_input,
  [2] = defines.electric_interface_mode.secondary_input,
  [3] = defines.electric_interface_mode.tertiary_input,
}

-- Electricity -> heat/steam converters. A district with one gets no bonus: its steam could run generators of the
-- main grid and the bonus would then make energy from nothing.
-- 1) boilers and reactors with an electric energy source (Bio Industries solar boiler);
-- 2) crafting machines with an electric energy source that can craft a steam recipe giving about as much steam power
--    as they draw (Angels electric boilers are assembling machines: 1.21 MW -> 1.2 MW of 165 C steam). Cooling towers
--    and other machines whose steam heat comes from hot inputs are far from that ratio and stay ordinary machines.
local function steam_power_by_category()
  local steam = prototypes.fluid["steam"]
  if not steam then return {} end
  local ok, recipes = pcall(prototypes.get_recipe_filtered,
    { { filter = "has-product-fluid", elem_filters = { { filter = "name", name = "steam" } } } })
  if not ok then recipes = prototypes.recipe end
  local by_cat = {}
  for _, r in pairs(recipes) do
    -- hidden recipes (voiding sinks) and recipes with item inputs get their heat from chemistry, not from electricity
    local plain = not r.hidden
    if plain then
      for _, i in ipairs(r.ingredients) do
        if i.type ~= "fluid" then plain = false end
      end
    end
    for _, p in ipairs(plain and r.products or {}) do
      if p.type == "fluid" and p.name == "steam" and r.energy > 0 then
        local amount = p.amount or ((p.amount_min or 0) + (p.amount_max or 0)) / 2
        local temp = p.temperature or steam.default_temperature
        local watts = amount * (p.probability or 1) * (temp - steam.default_temperature) * steam.heat_capacity / r.energy
        if watts > 0 then
          for _, c in ipairs(r.categories) do
            local l = by_cat[c]
            if not l then
              l = {}
              by_cat[c] = l
            end
            l[#l + 1] = watts
          end
        end
      end
    end
  end
  return by_cat
end

function M.converter_names()
  local names = {}
  for _, ty in ipairs({ "boiler", "reactor" }) do
    for name, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = ty } })) do
      if proto.electric_energy_source_prototype then names[#names + 1] = name end
    end
  end
  local by_cat = steam_power_by_category()
  for _, ty in ipairs({ "assembling-machine", "furnace" }) do
    for name, proto in pairs(prototypes.get_entity_filtered({ { filter = "type", type = ty } })) do
      local usage = proto.energy_usage -- J per tick
      if proto.electric_energy_source_prototype and usage and usage > 0 then
        local speed = proto.get_crafting_speed() or 1
        local hit = false
        for c in pairs(proto.crafting_categories or {}) do
          for _, w in ipairs(by_cat[c] or {}) do
            local ratio = w * speed / (usage * 60)
            if ratio >= 0.5 and ratio <= 2 then
              hit = true
              break
            end
          end
          if hit then break end
        end
        if hit then names[#names + 1] = name end
      end
    end
  end
  table.sort(names)
  return names
end

function M.alt_surface(surface)
  local alt = storage.alt[surface.index]
  if alt and alt.valid then return alt end
  local name = "ppd-hidden-" .. surface.index
  alt = game.get_surface(name)
  if not alt then
    alt = game.create_surface(name, {
      default_enable_all_autoplace_controls = false,
      autoplace_controls = {},
      autoplace_settings = {
        entity = { treat_missing_as_default = false, settings = {} },
        decorative = { treat_missing_as_default = false, settings = {} },
        tile = { treat_missing_as_default = false, settings = {} },
      },
      no_enemies_mode = true,
      peaceful_mode = true,
      width = 0, height = 0,
    })
    alt.generate_with_lab_tiles = true
    alt.show_clouds = false
    alt.always_day = true
    alt.freeze_daytime = true
  end
  for _, force in pairs(game.forces) do
    force.set_surface_hidden(alt, true)
  end
  storage.alt[surface.index] = alt
  return alt
end

local function ensure_chunk(surface, pos)
  local c = { x = math.floor(pos.x / 32), y = math.floor(pos.y / 32) }
  if not surface.is_chunk_generated(c) then
    surface.request_to_generate_chunks(pos, 0)
    surface.force_generate_chunk_requests()
  end
end

local function offset(pos, d) return { x = pos.x + d[1], y = pos.y + d[2] } end

-- nominal with the tap, output cap (125 %, 150 % while boosting) for the input and the output interface
function M.apply_limits(m)
  local tier = S.TIERS[m.tier]
  local nominal = tier.nominal * (1 + S.TAP_STEP * (m.tap or 0)) / 60
  m.nominal = nominal
  m.max_rate = nominal * (m.boosting and S.BOOST or S.LIMIT)
  local eout = m.eout
  if eout and eout.valid then
    if eout.electric_interface_mode ~= SEC_OUT then eout.electric_interface_mode = SEC_OUT end
    eout.output_flow_limit = m.max_rate
  end
  if m.rate and m.rate > m.max_rate then M.set_rate(m, m.max_rate) end
end

-- buffers hold two periods at the highest output the force can have (top tap, boost); idle draw by research
function M.size_buffers(m)
  local tier = S.TIERS[m.tier]
  local f = state.force(m.force)
  local top = tier.nominal * (1 + S.TAP_STEP * (f.taps or 0)) * (f.boost and S.BOOST or S.LIMIT) / 60
  local cap = top * (2 * storage.period + 10)
  m.cap = cap
  m.idle = tier.nominal * S.IDLE * (f.amorphous and S.AMORPHOUS or 1) / 60
  if m.ein and m.ein.valid then m.ein.electric_buffer_size = cap end
  if m.eout and m.eout.valid then m.eout.electric_buffer_size = cap end
  M.apply_limits(m)
end

-- J per tick the input may draw on top of the district's consumption to fill empty buffers (both in ~30 s)
function M.charge_rate(m)
  return 2 * m.cap / S.CHARGE_TICKS
end

-- how much the input takes from the main grid per tick; the engine fills the input buffer at most this fast.
-- 0.1.0 left the prototype limit (125 % of the nominal) and the buffer refilled in 2-3 ticks once a second.
function M.set_rate(m, rate)
  if rate < 0 then rate = 0 elseif rate > m.max_rate then rate = m.max_rate end
  local old = m.rate
  if old and math.abs(rate - old) <= old * 0.001 + 1 then return end
  m.rate = rate
  if m.ein and m.ein.valid then m.ein.input_flow_limit = rate end
end

function M.apply_priority(m)
  if m.ein and m.ein.valid then
    local mode = MODES[m.prio] or MODES[2]
    if m.ein.electric_interface_mode ~= mode then m.ein.electric_interface_mode = mode end
  end
end

local function make(surface, name, pos, force)
  local e = surface.create_entity({ name = name, position = pos, force = force, create_build_effect_smoke = false })
  if e then
    e.destructible = false
  end
  return e
end

-- create whatever hidden part is missing; returns true when all parts are valid
function M.ensure_parts(m)
  local e = m.e
  if not (e and e.valid) then return false end
  local surface, force, pos = e.surface, e.force, e.position
  local tier = S.TIERS[m.tier]
  -- a recreated bushing loses its "plug here" icon with it: m.win/m.wout = nil makes the next check redraw it
  if not (m.pin and m.pin.valid) then
    m.pin = make(surface, S.POLE_IN, offset(pos, S.TIP_IN), force)
    m.win = nil
  end
  if not (m.pout and m.pout.valid) then
    m.pout = make(surface, S.POLE_OUT, offset(pos, S.TIP_OUT), force)
    m.wout = nil
  end
  local alt = M.alt_surface(surface)
  local apin, apout = { x = pos.x - 0.4, y = pos.y }, { x = pos.x + 0.4, y = pos.y }
  if not (m.ain and m.ain.valid and m.ein and m.ein.valid and m.aout and m.aout.valid and m.eout and m.eout.valid) then
    ensure_chunk(alt, pos)
  end
  if not (m.ain and m.ain.valid) then m.ain = make(alt, S.POLE_ALT, apin, force) end
  if not (m.aout and m.aout.valid) then m.aout = make(alt, S.POLE_ALT, apout, force) end
  local new_in = false
  if not (m.ein and m.ein.valid) then
    m.ein = make(alt, tier.eei_in, apin, force)
    if m.ein then m.ein.energy = 0 end
    m.ie_last = 0
    new_in = true
  end
  if not (m.eout and m.eout.valid) then
    m.eout = make(alt, tier.eei_out, apout, force)
    if m.eout then m.eout.energy = 0 end
    m.lo = 0
  end
  if not (m.pin and m.pout and m.ain and m.aout and m.ein and m.eout) then return false end
  M.register_bushings(m)
  M.size_buffers(m)
  -- an empty new input must not fill at the prototype limit before the first transfer sets the rate
  if new_in then M.set_rate(m, M.charge_rate(m)) end
  M.apply_priority(m)
  M.check_links(m)
  return true
end

-- the script wires between the main-surface poles and the alt poles; a wire between input and output is cut
function M.check_links(m)
  local ci = m.pin.get_wire_connector(copper, true)
  local co = m.pout.get_wire_connector(copper, true)
  ci.connect_to(m.ain.get_wire_connector(copper, true), false, defines.wire_origin.script)
  co.connect_to(m.aout.get_wire_connector(copper, true), false, defines.wire_origin.script)
  ci.disconnect_from(co, defines.wire_origin.player)
  ci.disconnect_from(co, defines.wire_origin.script)
end

local function apply_tags(m, tags)
  local t = tags and tags.ppd
  if type(t) ~= "table" then return end
  if type(t.name) == "string" then m.name = t.name end
  if type(t.color) == "number" and S.COLORS[t.color] then m.color = t.color end
  if t.prio == 1 or t.prio == 2 or t.prio == 3 then m.prio = t.prio end
  m.can_shed = t.can_shed and true or false
  m.reserve = t.reserve and true or false
  if t.guard ~= nil then m.guard = t.guard and true or false end
  if t.msg == "all" or t.msg == "alarms" or t.msg == "none" then m.msg = t.msg end
  m.sig = t.sig and true or false
  if type(t.cond) == "table" then m.cond = t.cond end
  local taps = state.force(m.force).taps or 0
  if type(t.tap) == "number" then m.tap = math.max(-taps, math.min(taps, math.floor(t.tap + 0.5))) end
  m.tap_auto = t.tap_auto and true or false
  if type(t.wires) == "table" then m.bp_wires = t.wires end
end

function M.tags_of(m)
  return { ppd = { name = m.name, color = m.color, prio = m.prio, can_shed = m.can_shed, reserve = m.reserve,
    guard = m.guard, msg = m.msg, sig = m.sig, cond = m.cond, tap = m.tap, tap_auto = m.tap_auto } }
end

function M.add_transformer(entity, tags)
  local tier = S.TIER_BY_NAME[entity.name]
  local unit = entity.unit_number
  if storage.tr[unit] then return storage.tr[unit] end
  local did, dnum = state.new_did(entity.force.index)
  local m = {
    e = entity, unit = unit, tier = tier.index, force = entity.force.index, surface = entity.surface.index,
    did = did, dnum = dnum, color = ((dnum - 1) % #S.COLORS) + 1, prio = 2, can_shed = false, off = false,
    reserve = false, guard = true, msg = settings.global["ppd-default-messages"].value, sig = false, cond = nil,
    lo = 0, lt = game.tick, avg = 0, ld = 0, take = 0, saved = 0, status = "idle", since = game.tick,
    h5 = {}, h60 = {}, h600 = {}, hacc = 0, hdt = 0, hn = 0,
  }
  apply_tags(m, tags)
  storage.tr[unit] = m
  storage.order_dirty = true
  storage.topo_dirty = true
  script.register_on_object_destroyed(entity)
  if m.guard then storage.guarded = storage.guarded + 1 end
  M.reset_signals(entity)
  M.ensure_parts(m)
  entity.custom_status = { diode = defines.entity_status_diode.yellow, label = { "ppd-status.idle" } }
  storage.next_plan = math.min(storage.next_plan, game.tick + 1)
  return m
end

-- bushing pole unit_number -> its transformer and side (blueprint wires between two transformers)
function M.register_bushings(m)
  storage.bush = storage.bush or {}
  if m.pin and m.pin.valid then storage.bush[m.pin.unit_number] = { u = m.unit, s = "i" } end
  if m.pout and m.pout.valid then storage.bush[m.pout.unit_number] = { u = m.unit, s = "o" } end
end

function M.destroy_parts(m)
  for _, k in ipairs({ "pin", "pout" }) do
    local p = m[k]
    if p and p.valid and storage.bush then storage.bush[p.unit_number] = nil end
  end
  for _, k in ipairs({ "pin", "pout", "ain", "aout", "ein", "eout" }) do
    local x = m[k]
    if x and x.valid then x.destroy() end
    m[k] = nil
  end
  M.destroy_marks(m)
end

-- render objects drawn for a transformer: alt-mode status label, "plug here" icons (cap_in/cap_out: captions of
-- 0.2.0, kept here so the layout migration destroys them)
local MARKS = { "label", "icon_in", "icon_out", "cap_in", "cap_out", "lamp_lens", "lamp_halo", "lamp_light" }
function M.destroy_marks(m)
  for _, k in ipairs(MARKS) do
    local o = m[k]
    if o and o.valid then o.destroy() end
    m[k] = nil
  end
  m.lkey, m.win, m.wout = nil, nil, nil
end

function M.remove_transformer(unit)
  local m = storage.tr[unit]
  if not m then return end
  if m.guard then storage.guarded = math.max(0, storage.guarded - 1) end
  M.destroy_parts(m)
  storage.tr[unit] = nil
  storage.order_dirty = true
  storage.topo_dirty = true
  storage.next_plan = math.min(storage.next_plan, game.tick + 1)
end

-- 0.1.0 -> 0.2.0: the transformer no longer rotates. Old ones are turned to the one direction (their footprint is
-- now 4x2, it may overlap a neighbour until rebuilt) and their bushing poles move to the new tips with the wires.
function M.migrate_layout(m)
  local e = m.e
  if not (e and e.valid) then return end
  if e.direction ~= D.north then pcall(function() e.direction = D.north end) end
  M.relocate_poles(m)
end

-- put the bushing poles where the current layout has them and keep the player's wires
-- (0.1.0 transformers rotated and had other tips; also used if an old transformer still gets rotated)
function M.relocate_poles(m)
  local saved = {}
  for _, k in ipairs({ "pin", "pout" }) do
    local p = m[k]
    saved[k] = {}
    if p and p.valid then
      for _, c in pairs(p.get_wire_connector(copper, true).real_connections) do
        if c.origin == defines.wire_origin.player and c.target.owner ~= m.ain and c.target.owner ~= m.aout then
          saved[k][#saved[k] + 1] = c.target
        end
      end
      p.destroy()
    end
    m[k] = nil
  end
  M.ensure_parts(m)
  for _, k in ipairs({ "pin", "pout" }) do
    local con = m[k] and m[k].get_wire_connector(copper, true)
    if con then
      for _, target in ipairs(saved[k]) do
        if target.valid then con.connect_to(target, false, defines.wire_origin.player) end
      end
    end
  end
end

-- our combinators output only what the script writes: drop sections that came from a blueprint, a pasted vanilla
-- combinator or anything else (removing a section never touches a shared logistic group)
function M.reset_signals(entity)
  local cb = entity.valid and entity.get_control_behavior()
  if not cb then return end
  for i = cb.sections_count, 1, -1 do pcall(cb.remove_section, i) end
  cb.enabled = true
end

function M.add_load_bank(entity, tags)
  local unit = entity.unit_number
  if storage.lb[unit] then return storage.lb[unit] end
  M.reset_signals(entity)
  local eei = entity.surface.create_entity({ name = S.LOAD_BANK_EEI, position = entity.position, force = entity.force,
    create_build_effect_smoke = false })
  if eei then
    eei.destructible = false
    eei.power_usage = 0
    eei.electric_buffer_size = 1
  end
  local t = tags and tags.ppd or {}
  local lb = { e = entity, eei = eei, unit = unit, force = entity.force.index,
    mode = (t.mode == 1 or t.mode == 2 or t.mode == 3) and t.mode or 1,
    w = type(t.w) == "number" and math.max(0, math.min(S.LOAD_BANK_MAX, t.w)) or 0, cur = 0 }
  storage.lb[unit] = lb
  script.register_on_object_destroyed(entity)
  return lb
end

function M.remove_load_bank(unit)
  local lb = storage.lb[unit]
  if not lb then return end
  if lb.eei and lb.eei.valid then lb.eei.destroy() end
  storage.lb[unit] = nil
end

function M.ensure_load_bank(lb)
  if lb.eei and lb.eei.valid then return true end
  local e = lb.e
  if not (e and e.valid) then return false end
  lb.eei = e.surface.create_entity({ name = S.LOAD_BANK_EEI, position = e.position, force = e.force, create_build_effect_smoke = false })
  if lb.eei then lb.eei.destructible = false end
  return lb.eei ~= nil
end

return M
