local S = require("shared")
local state = require("scripts.state")
local build = require("scripts.build")
local engine = require("scripts.engine")
local guard = require("scripts.guard")
local journal = require("scripts.journal")
local map = require("scripts.map")
local bpwires = require("scripts.bpwires")
local meter = require("scripts.meter")
local ui_tr = require("scripts.ui_transformer")
local ui_lb = require("scripts.ui_loadbank")
local ui_dsp = require("scripts.ui_dispatcher")
local U = require("scripts.util")

local E = defines.events
local CONVERTERS = build.converter_names()
local CONVERTER_SET = {}
for _, n in ipairs(CONVERTERS) do CONVERTER_SET[n] = true end
-- 2 = 0.2.0: one fixed layout, the transformer does not rotate; 3 = 0.2.1: new art, bushing tips moved, no captions
local LAYOUT = 3

ui_dsp.set_hub({ open_transformer = function(player, m) ui_tr.open(player, m) end })

---------------------------------------------------------------- tick registration

-- a window error must not stop the game: log it once and close that window
local function safe_refresh(ui, player)
  local ok, err = pcall(ui.refresh, player)
  if not ok then
    log("ppd UI error: " .. tostring(err))
    pcall(ui.close, player)
  end
end

-- performance probe for tests (not saved): bench_start / bench_stop through the remote interface
local BENCH

local function on_tick(e)
  local t = e.tick
  if BENCH then
    BENCH.p.reset()
    local planned = engine.on_tick(t)
    BENCH.p.stop()
    if planned then
      BENCH.plan.add(BENCH.p)
      BENCH.np = BENCH.np + 1
    else
      BENCH.other.add(BENCH.p)
      BENCH.no = BENCH.no + 1
    end
  else
    engine.on_tick(t)
  end
  if t % 60 == 15 and next(storage.meters) then meter.tick() end
  if t % 30 == 0 then
    for _, player in pairs(game.connected_players) do
      local pd = storage.players[player.index]
      if pd then
        if pd.tr then safe_refresh(ui_tr, player) end
        if pd.lb then safe_refresh(ui_lb, player) end
        if pd.meter then safe_refresh(meter, player) end
        if pd.dsp and t % 60 == 0 then safe_refresh(ui_dsp, player) end
      end
    end
  end
  if t % 60 == 30 then map.tick() end
  if t % 3600 == 45 and next(storage.pending) then bpwires.cleanup(t) end
end

local function register_tick()
  local active = storage.tr and (next(storage.tr) ~= nil or next(storage.lb) ~= nil
    or (storage.meters and next(storage.meters) ~= nil))
  script.on_event(E.on_tick, active and on_tick or nil)
end

---------------------------------------------------------------- init

local function scan_converters()
  storage.conv = {}
  if #CONVERTERS == 0 then return end
  for _, surface in pairs(game.surfaces) do
    for _, c in pairs(surface.find_entities_filtered({ name = CONVERTERS })) do
      storage.conv[c.unit_number] = c
    end
  end
end

-- research-dependent sizes (taps, boost, amorphous cores) of all transformers of a force
local function resize_force(force_index)
  for _, m in pairs(storage.tr) do
    if m.force == force_index then
      local taps = state.force(m.force).taps or 0
      if math.abs(m.tap or 0) > taps then m.tap = (m.tap or 0) > 0 and taps or -taps end
      build.size_buffers(m)
    end
  end
end

local function init_all()
  state.init()
  for _, force in pairs(game.forces) do
    state.force(force.index)
    state.refresh_research(force.index)
  end
  if storage.layout ~= LAYOUT then
    -- 0.1.0/0.2.0 -> current: fixed layout, bushing poles moved to the current tips with their wires, marks redrawn;
    -- the inputs start at the gentle charge rate (the next transfer sets the working rate)
    for _, m in pairs(storage.tr) do
      build.destroy_marks(m)
      build.migrate_layout(m)
      if m.ein and m.ein.valid and m.cap then build.set_rate(m, build.charge_rate(m)) end
    end
    storage.layout = LAYOUT
  end
  for _, m in pairs(storage.tr) do
    build.register_bushings(m)
    build.size_buffers(m)
  end
  scan_converters()
  engine.label_players()
  register_tick()
end

script.on_init(init_all)
script.on_configuration_changed(function()
  init_all()
  for _, player in pairs(game.players) do
    ui_tr.close(player)
    ui_lb.close(player)
    ui_dsp.close(player)
    meter.close(player)
  end
end)
script.on_load(register_tick)

---------------------------------------------------------------- build / remove

local BUILD_FILTER = { { filter = "type", type = "electric-pole" }, { filter = "name", name = S.LOAD_BANK },
  { filter = "name", name = S.METER } }
for _, t in ipairs(S.TIERS) do BUILD_FILTER[#BUILD_FILTER + 1] = { filter = "name", name = t.name } end
for _, n in ipairs(CONVERTERS) do BUILD_FILTER[#BUILD_FILTER + 1] = { filter = "name", name = n } end
local REMOVE_FILTER = { { filter = "name", name = S.LOAD_BANK }, { filter = "name", name = S.METER } }
for _, t in ipairs(S.TIERS) do REMOVE_FILTER[#REMOVE_FILTER + 1] = { filter = "name", name = t.name } end
for _, n in ipairs(CONVERTERS) do REMOVE_FILTER[#REMOVE_FILTER + 1] = { filter = "name", name = n } end

local function on_built(e)
  local entity = e.entity
  if not (entity and entity.valid) then return end
  local name = entity.name
  if S.TIER_BY_NAME[name] then
    local m = build.add_transformer(entity, e.tags)
    if m.bp_wires then
      bpwires.restore(m, m.bp_wires)
      m.bp_wires = nil
    end
    bpwires.on_built(entity)
    engine.update_marks(m)
    register_tick()
  elseif name == S.LOAD_BANK then
    build.add_load_bank(entity, e.tags)
    register_tick()
  elseif name == S.METER then
    meter.update(meter.add(entity))
    register_tick()
  elseif CONVERTER_SET[name] then
    storage.conv[entity.unit_number] = entity
  elseif entity.type == "electric-pole" then
    guard.on_pole_built(entity, e.player_index and game.get_player(e.player_index) or nil)
    if next(storage.pending) then bpwires.on_built(entity) end
  end
end

for _, ev in ipairs({ E.on_built_entity, E.on_robot_built_entity, E.script_raised_built, E.script_raised_revive,
  E.on_space_platform_built_entity }) do
  if ev then script.on_event(ev, on_built, BUILD_FILTER) end
end

local function on_removed(e)
  local entity = e.entity
  if not (entity and entity.valid) then return end
  local name = entity.name
  local unit = entity.unit_number
  if S.TIER_BY_NAME[name] then
    local m = storage.tr[unit]
    if m and e.name == E.on_entity_died then
      journal.add(m.force, "destroy", "alarm", { "ppd-journal.destroyed", engine.name_of(m) }, m, entity)
      -- the ghost left by the death gets the settings (on_post_entity_died)
      storage.dead[unit] = build.tags_of(m)
    end
    build.remove_transformer(unit)
    register_tick()
  elseif name == S.LOAD_BANK then
    local lb = storage.lb[unit]
    if lb and e.name == E.on_entity_died then storage.dead[unit] = { ppd = { mode = lb.mode, w = lb.w } } end
    build.remove_load_bank(unit)
    register_tick()
  elseif name == S.METER then
    meter.remove(unit)
    register_tick()
  elseif CONVERTER_SET[name] then
    storage.conv[unit] = nil
  end
end

for _, ev in ipairs({ E.on_player_mined_entity, E.on_robot_mined_entity, E.on_entity_died, E.script_raised_destroy,
  E.on_space_platform_mined_entity }) do
  if ev then script.on_event(ev, on_removed, REMOVE_FILTER) end
end

-- a transformer or load bank rebuilt from its death ghost keeps its settings (wires to the bushings are not kept)
script.on_event(E.on_post_entity_died, function(e)
  local unit = e.unit_number
  local tags = unit and storage.dead[unit]
  if not tags then return end
  storage.dead[unit] = nil
  local ghost = e.ghost
  if ghost and ghost.valid then ghost.tags = tags end
end, { { filter = "type", type = "constant-combinator" } })

script.on_event(E.on_object_destroyed, function(e)
  local id = e.useful_id
  if not id then return end
  if storage.tr[id] then
    build.remove_transformer(id)
    register_tick()
  elseif storage.lb[id] then
    build.remove_load_bank(id)
    register_tick()
  elseif storage.meters[id] then
    meter.remove(id)
    register_tick()
  end
  storage.dead[id] = nil
end)

-- 0.2.0 transformers do not rotate; a 0.1.0 one rotated before the update only gets its bushings put right
script.on_event(E.on_player_rotated_entity, function(e)
  local entity = e.entity
  if entity and entity.valid and S.TIER_BY_NAME[entity.name] then
    local m = storage.tr[entity.unit_number]
    if m then build.relocate_poles(m) end
  end
end)

script.on_event(E.on_entity_settings_pasted, function(e)
  local a, b = e.source, e.destination
  if not (a and b and a.valid and b.valid) then return end
  local ma, mb = storage.tr[a.unit_number], storage.tr[b.unit_number]
  if mb then
    if ma then
      mb.prio, mb.can_shed, mb.reserve, mb.msg, mb.sig = ma.prio, ma.can_shed, ma.reserve, ma.msg, ma.sig
      if mb.guard ~= ma.guard then
        storage.guarded = storage.guarded + (ma.guard and 1 or -1)
        mb.guard = ma.guard
      end
      mb.cond = ma.cond and { on = ma.cond.on, sig = ma.cond.sig, cmp = ma.cond.cmp, val = ma.cond.val } or nil
      local taps = state.force(mb.force).taps or 0
      mb.tap = math.max(-taps, math.min(taps, ma.tap or 0))
      mb.tap_auto = ma.tap_auto
      build.apply_priority(mb)
      build.apply_limits(mb)
      storage.topo_dirty = true
    end
    -- the engine copied the source combinator's constants: ours outputs only what the script writes
    build.reset_signals(b)
    mb.sigc = nil
    return
  end
  if storage.lb[b.unit_number] then
    local la, lb = storage.lb[a.unit_number], storage.lb[b.unit_number]
    if la then lb.mode, lb.w = la.mode, la.w end
    build.reset_signals(b)
    return
  end
  local mt = storage.meters[b.unit_number]
  if mt then
    build.reset_signals(b)
    mt.sigc = nil
  end
end)

script.on_event(E.on_player_setup_blueprint, function(e)
  local mapping = e.mapping and e.mapping.get()
  if not mapping then return end
  local bp = (e.stack and e.stack.valid_for_read and e.stack.is_blueprint and e.stack) or e.record
  if not bp then return end
  local index_of = {}
  for index, ent in pairs(mapping) do
    if ent.valid and ent.unit_number then index_of[ent.unit_number] = index end
  end
  for index, ent in pairs(mapping) do
    if ent.valid then
      local m = storage.tr[ent.unit_number]
      local lb = storage.lb[ent.unit_number]
      if m then
        local tags = build.tags_of(m).ppd
        local wires = bpwires.record(m, index_of)
        if #wires > 0 then tags.wires = wires end
        pcall(bp.set_blueprint_entity_tag, index, "ppd", tags)
      elseif lb then
        pcall(bp.set_blueprint_entity_tag, index, "ppd", { mode = lb.mode, w = lb.w })
      end
    end
  end
end)

script.on_event(E.on_surface_deleted, function(e)
  local alt = storage.alt[e.surface_index]
  storage.alt[e.surface_index] = nil
  storage.pending[e.surface_index] = nil
  if alt and alt.valid then game.delete_surface(alt) end
end)

script.on_event(E.on_force_created, function(e)
  for _, alt in pairs(storage.alt) do
    if alt.valid then e.force.set_surface_hidden(alt, true) end
  end
  state.force(e.force.index)
end)

-- merged forces: the entities now belong to the destination force
script.on_event(E.on_forces_merged, function(e)
  local from, to = e.source_index, e.destination.index
  state.force(to)
  for _, m in pairs(storage.tr) do
    if m.force == from then m.force = to end
  end
  for _, lb in pairs(storage.lb) do
    if lb.force == from then lb.force = to end
  end
  for _, mt in pairs(storage.meters) do
    if mt.force == from then mt.force = to end
  end
  for _, ds in pairs(storage.dist) do
    if ds.force == from then ds.force = to end
  end
  storage.forces[from] = nil
  state.refresh_research(to)
  resize_force(to)
  storage.topo_dirty = true
end)

---------------------------------------------------------------- research, settings, players

local function research(force)
  state.force(force.index)
  state.refresh_research(force.index)
  resize_force(force.index)
end
script.on_event(E.on_research_finished, function(e) research(e.research.force) end)
script.on_event(E.on_research_reversed, function(e) research(e.research.force) end)
script.on_event(E.on_technology_effects_reset, function(e) research(e.force) end)

script.on_event(E.on_runtime_mod_setting_changed, function(e)
  if e.setting == "ppd-update-period" then
    storage.period = settings.global["ppd-update-period"].value
    for _, m in pairs(storage.tr) do build.size_buffers(m) end
    storage.next_plan = game.tick + 1
  elseif e.setting == "ppd-alt-labels" then
    engine.label_players()
  end
end)

for _, ev in ipairs({ E.on_player_created, E.on_player_joined_game, E.on_player_removed }) do
  script.on_event(ev, function() engine.label_players() end)
end

---------------------------------------------------------------- GUI

local function open_dispatcher(player)
  local tech = player.force.technologies[S.TECH.t40]
  if not (tech and tech.researched) then
    player.create_local_flying_text({ text = { "ppd-flying.no-dispatcher" }, create_at_cursor = true })
    return
  end
  ui_dsp.toggle(player)
end

script.on_event(E.on_lua_shortcut, function(e)
  if e.prototype_name == "ppd-dispatcher" then open_dispatcher(game.get_player(e.player_index)) end
end)
script.on_event("ppd-dispatcher", function(e) open_dispatcher(game.get_player(e.player_index)) end)

script.on_event(E.on_gui_opened, function(e)
  local entity = e.entity
  if not (entity and entity.valid) then return end
  local player = game.get_player(e.player_index)
  local name = entity.name
  if S.TIER_BY_NAME[name] then
    local m = storage.tr[entity.unit_number] or build.add_transformer(entity)
    ui_tr.open(player, m)
  elseif name == S.LOAD_BANK then
    local lb = storage.lb[entity.unit_number] or build.add_load_bank(entity)
    ui_lb.open(player, lb)
  elseif name == S.METER then
    local mt = storage.meters[entity.unit_number] or meter.add(entity)
    register_tick()
    meter.open(player, mt)
  end
end)

script.on_event(E.on_gui_closed, function(e)
  local el = e.element
  if not (el and el.valid) then return end
  local player = game.get_player(e.player_index)
  if el.name == "ppd_transformer" then ui_tr.close(player)
  elseif el.name == "ppd_loadbank" then ui_lb.close(player)
  elseif el.name == "ppd_meter" then meter.close(player)
  elseif el.name == "ppd_dispatcher" then ui_dsp.close(player) end
end)

local function tags_of(el)
  if not (el and el.valid) then return nil end
  local t = el.tags
  if t and t.ppd then return t end
  return nil
end

script.on_event(E.on_gui_click, function(e)
  local tags = tags_of(e.element)
  if not tags then return end
  local player = game.get_player(e.player_index)
  local a = tags.ppd
  if a == "open-dispatcher" then
    ui_tr.close(player)
    ui_dsp.open(player)
  elseif a == "meter-close" then
    meter.close(player)
  elseif a == "tr-show" or a == "tr-findwire" then
    local pd = state.player(player.index)
    local m = pd.tr and storage.tr[pd.tr.unit]
    if m and m.e.valid then
      if a == "tr-show" then map.show_district(player, m) else map.find_wire(player, m) end
    end
  elseif a:sub(1, 3) == "tr-" then
    ui_tr.on_click(player, e.element, tags, e)
  elseif a:sub(1, 3) == "lb-" then
    ui_lb.on_click(player, e.element, tags)
  elseif a:sub(1, 4) == "dsp-" then
    ui_dsp.on_click(player, e.element, tags, e)
  end
end)

local function on_changed(e)
  local tags = tags_of(e.element)
  if not tags then return end
  local player = game.get_player(e.player_index)
  if tags.ppd:sub(1, 3) == "tr-" then ui_tr.on_changed(player, e.element, tags)
  elseif tags.ppd:sub(1, 4) == "dsp-" then ui_dsp.on_changed(player, e.element, tags) end
end
script.on_event(E.on_gui_checked_state_changed, on_changed)
script.on_event(E.on_gui_selection_state_changed, on_changed)
script.on_event(E.on_gui_elem_changed, on_changed)
script.on_event(E.on_gui_text_changed, on_changed)
script.on_event(E.on_gui_value_changed, function(e)
  local tags = tags_of(e.element)
  if not tags then return end
  local player = game.get_player(e.player_index)
  if tags.ppd == "lb-slider" then
    ui_lb.on_value(player, e.element, tags)
  else
    on_changed(e)
  end
end)
script.on_event(E.on_gui_selected_tab_changed, function(e)
  local tags = tags_of(e.element)
  if tags then ui_dsp.on_tab(game.get_player(e.player_index), e.element) end
end)

-- placement hint: a transformer in the cursor over a pole
script.on_event(E.on_selected_entity_changed, function(e)
  local player = game.get_player(e.player_index)
  local sel = player.selected
  if not (sel and sel.type == "electric-pole") then return end
  local stack = player.cursor_stack
  local held
  if stack and stack.valid_for_read then held = stack.name
  elseif player.cursor_ghost then held = player.cursor_ghost.name and player.cursor_ghost.name.name end
  if not (held and S.TIER_BY_NAME[held]) then return end
  if sel.name == S.POLE_IN or sel.name == S.POLE_OUT then return end
  local stats = sel.electric_network_statistics
  if not stats then return end
  local load = 0
  for name in pairs(stats.input_counts) do
    load = load + stats.get_flow_count({ name = name, category = "input", precision_index = defines.flow_precision_index.one_minute })
  end
  local f = state.force(player.force.index)
  local hw = state.half_width(f)
  local best
  for _, t in ipairs(S.TIERS) do
    local r = load * 60 / t.nominal
    if r >= 1 - hw and r <= 1 + hw then best = t break end
  end
  local text
  if best then
    text = { "ppd-flying.hint-fit", U.tpower(load), best.key, math.floor(load * 60 / best.nominal * 100 + 0.5) }
  else
    text = { "ppd-flying.hint-none", U.tpower(load) }
  end
  player.create_local_flying_text({ text = text, position = sel.position, surface = sel.surface, speed = 0.4 })
end)

---------------------------------------------------------------- remote (tests and other mods)

remote.add_interface("ppd", {
  -- numbers of a transformer
  get = function(unit)
    local m = storage.tr[unit]
    if not m then return nil end
    return { status = m.status, did = m.did, avg = m.avg, ld = m.ld, take = m.take, saved = m.saved, b = m.b,
      lo = m.lo, cap = m.cap, draw = m.draw, in_net = m.in_net, out_net = m.out_net, bypass = m.bypass, loop = m.loop,
      noin = m.noin, shed = m.shed, off = m.off, prio = m.prio, reserve = m.reserve, rate = m.rate, max_rate = m.max_rate,
      nominal = m.nominal, idle = m.idle, tap = m.tap, tap_auto = m.tap_auto, boosting = m.boosting, win = m.win,
      wout = m.wout, sum_out = m.sum_out, sum_saved = m.sum_saved, name = m.name,
      icon_in = m.icon_in ~= nil and m.icon_in.valid, icon_out = m.icon_out ~= nil and m.icon_out.valid,
      lamp = m.lamp_lens ~= nil and m.lamp_lens.valid and m.lamp_lens.color or nil,
      lamp_blink = m.lamp_lens ~= nil and m.lamp_lens.valid and m.lamp_lens.blink_interval or nil,
      ein = m.ein and m.ein.valid and m.ein.energy, eout = m.eout and m.eout.valid and m.eout.energy,
      ein_limit = m.ein and m.ein.valid and m.ein.input_flow_limit,
      eout_limit = m.eout and m.eout.valid and m.eout.output_flow_limit }
  end,
  district = function(did)
    local ds = storage.dist[did]
    if not ds then return nil end
    return { status = ds.status, N = ds.N, L = ds.L, Lnow = ds.Lnow, r = ds.r, zone = ds.zone, bonus = ds.bonus,
      take = ds.take, saved = ds.saved, transit = ds.transit, loop = ds.loop, conv = ds.conv, engaged = ds.engaged,
      units = ds.units, lead = ds.lead, dem = ds.dem, boosting = ds.boosting, tap = ds.tap }
  end,
  set = function(unit, key, value)
    local m = storage.tr[unit]
    if not m then return false end
    m[key] = value
    if key == "prio" then build.apply_priority(m) end
    if key == "reserve" then storage.topo_dirty = true end
    if key == "tap" then build.apply_limits(m) end
    if key == "guard" then
      local n = 0
      for _, x in pairs(storage.tr) do if x.guard then n = n + 1 end end
      storage.guarded = n
    end
    return true
  end,
  set_ds = function(did, key, value)
    local ds = storage.dist[did]
    if not ds then return false end
    ds[key] = value
    return true
  end,
  set_lb = function(unit, key, value)
    local lb = storage.lb[unit]
    if not lb then return false end
    lb[key] = value
    return true
  end,
  lb = function(unit)
    local lb = storage.lb[unit]
    return lb and { mode = lb.mode, w = lb.w, cur = lb.cur, did = lb.did } or nil
  end,
  force = function(index)
    local f = state.force(index)
    return { saved = f.saved, saved_now = f.saved_now, eff = f.eff, reg = f.reg, has_auto = f.has_auto, has_bank = f.has_bank,
      jn = f.jn, auto = f.auto, taps = f.taps, auto_taps = f.auto_taps, amorphous = f.amorphous, boost = f.boost }
  end,
  journal = function(index, n) return journal.list(index, "all", n or 20) end,
  refresh_research = function(index)
    state.refresh_research(index)
    resize_force(index)
  end,
  converters = function() return CONVERTERS end,
  meter = function(unit)
    local mt = storage.meters[unit]
    if not mt then return nil end
    meter.update(mt)
    local v = mt.last
    return { v = v, sig = mt.sigc, screen = mt.stext }
  end,
  bp_record = function(unit, units)
    local m = storage.tr[unit]
    if not m then return nil end
    local index_of = {}
    for i, u in ipairs(units or {}) do index_of[u] = i end
    return bpwires.record(m, index_of)
  end,
  pending = function() return storage.pending end,
  open_transformer = function(pi, unit) ui_tr.open(game.get_player(pi), storage.tr[unit]) end,
  click = function(pi, action, tags)
    local player = game.get_player(pi)
    tags = tags or {}
    tags.ppd = action
    local fake = { button = defines.mouse_button_type.left }
    if action:sub(1, 3) == "tr-" then return ui_tr.on_click(player, nil, tags, fake)
    elseif action:sub(1, 3) == "lb-" then return ui_lb.on_click(player, nil, tags)
    elseif action:sub(1, 4) == "dsp-" then return ui_dsp.on_click(player, nil, tags, fake) end
  end,
  open_load_bank = function(pi, unit) ui_lb.open(game.get_player(pi), storage.lb[unit]) end,
  open_meter = function(pi, unit) meter.open(game.get_player(pi), storage.meters[unit]) end,
  open_dispatcher = function(pi, tab) ui_dsp.open(game.get_player(pi), tab) end,
  refresh_ui = function(pi)
    local player = game.get_player(pi)
    ui_tr.refresh(player)
    ui_lb.refresh(player)
    ui_dsp.refresh(player)
    meter.refresh(player)
  end,
  bench_start = function()
    BENCH = { p = helpers.create_profiler(true), plan = helpers.create_profiler(true), other = helpers.create_profiler(true),
      np = 0, no = 0 }
  end,
  bench_stop = function()
    if not BENCH then return end
    local b = BENCH
    BENCH = nil
    log({ "", "PPD-BENCH ticks: transformers ", table_size(storage.tr), ", districts ", #storage.queue,
      "; plan ticks ", b.np, " total ", b.plan, "; other ticks ", b.no, " total ", b.other })
  end,
  show_district = function(pi, unit) map.show_district(game.get_player(pi), storage.tr[unit]) end,
  find_wire = function(pi, unit) map.find_wire(game.get_player(pi), storage.tr[unit]) end,
  toggle_map = function(pi) return map.toggle(game.get_player(pi)) end,
  parts = function(unit)
    local m = storage.tr[unit]
    return m and { pin = m.pin, pout = m.pout, ain = m.ain, aout = m.aout, ein = m.ein, eout = m.eout } or nil
  end,
  period = function() return storage.period end,
  -- timing of one full period of work (plan + all districts), repeated `loops` times; result goes to the log
  bench = function(loops)
    loops = loops or 10
    local t = game.tick
    engine.prof = { cur = helpers.create_profiler(true) }
    for i = 1, loops do
      if i % 2 == 1 then storage.topo_dirty = true end
      engine.plan(t)
    end
    local prof = engine.prof
    engine.prof = nil
    local msg = { "", "PPD-BENCH plan x", loops, " (half with a rebuild; totals): " }
    local names = {}
    for k in pairs(prof) do if k ~= "cur" then names[#names + 1] = k end end
    table.sort(names)
    for _, k in ipairs(names) do
      msg[#msg + 1] = { "", k, " ", prof[k], "; " }
    end
    log(msg)
    local p_proc = helpers.create_profiler()
    for _, g in ipairs(storage.queue) do engine.process(g, t) end
    p_proc.stop()
    local p_gather = helpers.create_profiler()
    for _ = 1, storage.period do engine.gather_slice(t) end
    p_gather.stop()
    log({ "", "PPD-BENCH transformers ", table_size(storage.tr), ", districts ", #storage.queue,
      "; one pass of all districts ", p_proc, "; one full gather ", p_gather, " (both spread over ", storage.period, " ticks)",
      "; rebuilds so far ", storage.rebuilds or 0 })
    storage.qi = #storage.queue + 1
  end,
})
