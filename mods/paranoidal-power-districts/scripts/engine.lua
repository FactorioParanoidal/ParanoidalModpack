-- The update loop. Once per period (setting, 60 ticks by default) `plan` reads the network ids of all
-- transformers, groups them into districts (one district = one output network), finds bypasses, loops,
-- transit and converters, runs the automation and the load banks and queues the districts. The queue is
-- processed in equal slices on the following ticks, so every district is handled once per period and the
-- work is spread evenly over the ticks.
local S = require("shared")
local state = require("scripts.state")
local build = require("scripts.build")
local journal = require("scripts.journal")
local U = require("scripts.util")

local M = {}
local exp, floor, min, max, abs = math.exp, math.floor, math.min, math.max, math.abs
local RED, GREEN = defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green
local COPPER = defines.wire_connector_id.pole_copper
local DIODE = defines.entity_status_diode

M.STATUS = {
  zone = { diode = DIODE.green, code = 1, color = { 0.56, 0.89, 0.42 } },
  under = { diode = DIODE.yellow, code = 2, color = { 1, 0.85, 0.36 } },
  over = { diode = DIODE.yellow, code = 3, color = { 1, 0.85, 0.36 } },
  limit = { diode = DIODE.red, code = 4, color = { 1, 0.48, 0.41 }, alarm = true },
  noinput = { diode = DIODE.red, code = 5, color = { 1, 0.48, 0.41 }, alarm = true },
  bypass = { diode = DIODE.red, code = 6, color = { 1, 0.48, 0.41 }, alarm = true },
  loop = { diode = DIODE.red, code = 7, color = { 1, 0.48, 0.41 }, alarm = true },
  converter = { diode = DIODE.red, code = 7, color = { 1, 0.48, 0.41 }, alarm = true },
  idle = { diode = DIODE.yellow, code = 2, color = { 0.7, 0.7, 0.7 } },
  off_manual = { diode = DIODE.red, code = 8, color = { 0.7, 0.7, 0.7 } },
  off_auto = { diode = DIODE.red, code = 8, color = { 1, 0.48, 0.41 } },
  off_circuit = { diode = DIODE.yellow, code = 8, color = { 0.7, 0.7, 0.7 } },
  reserve_wait = { diode = DIODE.green, code = 8, color = { 0.7, 0.7, 0.7 } },
  reserve_on = { diode = DIODE.yellow, code = 1, color = { 1, 0.85, 0.36 } },
  -- 0.2.0
  nowire_in = { diode = DIODE.red, code = 5, color = { 1, 0.48, 0.41 } },
  nowire_out = { diode = DIODE.yellow, code = 2, color = { 0.7, 0.7, 0.7 } },
  boost = { diode = DIODE.yellow, code = 4, color = { 1, 0.66, 0.22 } },
}
local OK_STATUS = { zone = true, under = true, over = true, idle = true, reserve_wait = true, boost = true }

local function cmp(v, op, c)
  if op == ">" then return v > c elseif op == "<" then return v < c elseif op == "=" then return v == c
  elseif op == "≥" then return v >= c elseif op == "≤" then return v <= c elseif op == "≠" then return v ~= c end
  return true
end

local function push(arr, v)
  arr[#arr + 1] = v
  if #arr > 60 then table.remove(arr, 1) end
end

---------------------------------------------------------------- plan

-- strongly connected components over network ids (iterative Tarjan); returns comp id by node
local function scc(adj)
  local index, low, onstack, comp = {}, {}, {}, {}
  local stack, idx, cid = {}, 0, 0
  for root in pairs(adj) do
    if not index[root] then
      local work = { { root, nil } }
      while #work > 0 do
        local top = work[#work]
        local v = top[1]
        if not index[v] then
          idx = idx + 1
          index[v], low[v] = idx, idx
          stack[#stack + 1] = v
          onstack[v] = true
          top[2] = next(adj[v] or {})
          top.started = true
        end
        local w = top[2]
        if w ~= nil then
          top[2] = next(adj[v] or {}, w)
          if not index[w] then
            work[#work + 1] = { w, nil }
          elseif onstack[w] then
            low[v] = min(low[v], index[w])
          end
        else
          if low[v] == index[v] then
            cid = cid + 1
            local size = 0
            repeat
              local x = stack[#stack]
              stack[#stack] = nil
              onstack[x] = nil
              comp[x] = cid
              size = size + 1
            until x == v
            if size > 1 then comp[-cid] = true end
          end
          work[#work] = nil
          local parent = work[#work]
          if parent then low[parent[1]] = min(low[parent[1]], low[v]) end
        end
      end
    end
  end
  return comp
end

local function name_of(m)
  if m.name and m.name ~= "" then return m.name end
  return { "ppd-name.default", m.dnum or 0 }
end
M.name_of = name_of

local function flow_numbers(pin)
  local sub = pin.electric_network
  if not sub then return nil end
  local net = sub.parent_network
  local f = net and net.flow_last_tick
  if not f then return nil end
  local demand = f.primary_demand + f.secondary_demand
  local got = f.primary_demand * f.primary_demand_usage + f.secondary_demand * f.secondary_demand_usage
  local sat = demand > 0 and got / demand or 1
  local avail = f.solar_output + f.primary_output + f.secondary_output
  return sat, avail - got, avail, demand
end
M.flow_numbers = flow_numbers

local function automation(t, by_in, groups_of_in)
  local st = storage
  local tr = st.tr
  local seen = {}
  for net, units in pairs(by_in) do
    local m0 = tr[units[1]]
    if m0 and m0.pin and m0.pin.valid then
      local f = state.force(m0.force)
      local ns = st.nets[net]
      if not ns then
        ns = {}
        st.nets[net] = ns
      end
      seen[net] = true
      local sat, spare, avail = flow_numbers(m0.pin)
      ns.sat = sat
      -- spare generation of the main grid and how many inputs share it: new buffers charge only from it
      ns.spare = spare
      ns.n = #units
      if f.has_auto and sat then
        local a = f.auto
        if sat < a.threshold and avail > 0 then
          ns.high = nil
          ns.low = ns.low or t
          if a.shed and t - ns.low >= 180 and t - (ns.act or -1e9) >= 180 then
            -- shed the next district in the queue
            local rank = {}
            for i, did in ipairs(a.queue) do rank[did] = i end
            local best, best_rank
            for _, g in ipairs(groups_of_in[net] or {}) do
              local lead = tr[g.lead]
              if lead and not lead.off and not lead.shed and (lead.prio == 3 or (lead.prio == 2 and lead.can_shed)) then
                local r = rank[lead.did] or (1e6 + (lead.prio == 3 and 0 or 1e5) + lead.did)
                if not best_rank or r < best_rank then best, best_rank = g, r end
              end
            end
            if best then
              local load = 0
              for _, u in ipairs(best.units) do
                local m = tr[u]
                if m then load = load + m.avg end
              end
              -- a starved district drew less than it needs: remember what it asks (machines and downstream inputs),
              -- else the restore check below sees room for it at once and the district flaps on and off (0.2.1)
              local lead = tr[best.lead]
              local sub = lead and lead.pout and lead.pout.valid and lead.pout.electric_network
              local fl = sub and sub.parent_network and sub.parent_network.flow_last_tick
              if fl then load = max(load, fl.primary_demand + fl.secondary_demand) end
              for _, u in ipairs(best.units) do
                local m = tr[u]
                if m then
                  m.shed = t
                  m.shed_load = load
                end
              end
              ns.act = t
              journal.add(lead.force, "auto", "alarm", { "ppd-journal.shed", name_of(lead), floor(sat * 100 + 0.5) }, lead)
            end
          end
        else
          ns.low = nil
          if sat >= 0.999 then ns.high = ns.high or t else ns.high = nil end
          if a.restore and ns.high and t - ns.high >= 900 and t - (ns.act or -1e9) >= a.pause then
            local best, best_t
            for _, g in ipairs(groups_of_in[net] or {}) do
              local lead = tr[g.lead]
              if lead and lead.shed and not lead.off and (not best_t or lead.shed > best_t)
                and spare >= 1.1 * (lead.shed_load or 0) then
                best, best_t = g, lead.shed
              end
            end
            if best then
              for _, u in ipairs(best.units) do
                local m = tr[u]
                if m then m.shed = nil end
              end
              ns.act = t
              local lead = tr[best.lead]
              journal.add(lead.force, "auto", "info", { "ppd-journal.restored", name_of(lead) }, lead)
            end
          end
        end
      end
      if not f.has_auto then
        -- without the research nothing stays shed
        for _, g in ipairs(groups_of_in[net] or {}) do
          for _, u in ipairs(g.units) do
            local m = tr[u]
            if m then m.shed = nil end
          end
        end
      end
    end
  end
  for net in pairs(st.nets) do
    if not seen[net] then st.nets[net] = nil end
  end
end

local function load_banks()
  local st = storage
  for unit, lb in pairs(st.lb) do
    local e = lb.e
    if not (e and e.valid) then
      build.remove_load_bank(unit)
    elseif build.ensure_load_bank(lb) then
      local w = 0
      if lb.mode == 1 then
        w = lb.w
      elseif lb.mode == 2 then
        local v = e.get_signal({ type = "virtual", name = "signal-W" }, RED, GREEN)
        w = U.clamp(v * 1000, 0, S.LOAD_BANK_MAX)
      else
        local did = st.out2did[lb.eei.electric_network_id]
        local ds = did and st.dist[did]
        lb.did = did
        if ds and ds.N > 0 and not ds.off and ds.status ~= "limit" and ds.status ~= "noinput" then
          -- half a step towards the lower zone border + 1 % (the effect shows one period later; a full step would
          -- swing); converges to (target - machines) when the bank draws fully
          w = U.clamp((lb.cur or 0) + 0.5 * (ds.lo * 1.01 * ds.N - ds.Lnow) * 60, 0, S.LOAD_BANK_MAX)
        end
      end
      if lb.mode ~= 3 then lb.did = st.out2did[lb.eei.electric_network_id] end
      lb.cur = w
      local pt = w / 60
      lb.eei.power_usage = pt
      lb.eei.electric_buffer_size = max(pt * 4, 1)
    end
  end
end

-- read the network ids of one transformer (spread over the period by M.gather_slice)
local function gather_one(unit, m, t, P)
  local e = m.e
  if not (e and e.valid) then
    build.remove_transformer(unit)
    storage.order_dirty = true
    return
  end
  local pin, pout = m.pin, m.pout
  if not (pin and pin.valid and pout and pout.valid and m.ein and m.ein.valid and m.eout and m.eout.valid) then
    if not build.ensure_parts(m) then return end
    pin, pout = m.pin, m.pout
  end
  local inn, out = pin.electric_network_id, pout.electric_network_id
  if inn ~= m.in_net or out ~= m.out_net then
    m.in_net, m.out_net = inn, out
    storage.topo_dirty = true
  end
  local period_no = floor(t / P)
  if inn and out and inn ~= out and (period_no + unit) % 5 == 0 then
    -- a closed power switch joins two sub-networks into one network: that is a bypass too
    local a, b = pin.electric_network, pout.electric_network
    local ps = (a and b and a.parent_network == b.parent_network) or false
    if ps ~= (m.ps_bypass or false) then
      m.ps_bypass = ps
      storage.topo_dirty = true
    end
  end
  if (period_no + unit) % 30 == 0 then
    if m.ain and m.ain.valid and m.aout and m.aout.valid then build.check_links(m) else build.ensure_parts(m) end
  end
  -- wire marks: every period while a bushing has no wire (the icon goes at once), else every 5th period
  if m.win ~= true or m.wout ~= true or (period_no + unit) % 5 == 1 then M.update_marks(m) end
  m.gathered = true
end

function M.gather_slice(t)
  local st = storage
  local order = st.order
  if st.order_dirty or not order then
    order = {}
    for unit in pairs(st.tr) do order[#order + 1] = unit end
    table.sort(order)
    st.order = order
    st.order_dirty = false
    st.oi = 1
  end
  local n = #order
  if n == 0 then return end
  local P = st.period
  local per = math.ceil(n / P)
  local i = st.oi or 1
  local tr = st.tr
  for _ = 1, per do
    if i > n then i = 1 end
    local u = order[i]
    local m = tr[u]
    if m then gather_one(u, m, t, P) end
    i = i + 1
  end
  st.oi = i
end

-- optional phase timing for the bench (never saved)
M.prof = nil
local function mark(name)
  local prof = M.prof
  if not prof then return end
  prof.cur.stop()
  prof[name] = prof[name] or helpers.create_profiler(true)
  prof[name].add(prof.cur)
  prof.cur.reset()
end

-- converters in networks: signature to notice when one is built, removed or rewired
local function converter_nets()
  local st = storage
  local nets, ids = {}, {}
  for unit, c in pairs(st.conv) do
    if c.valid then
      local id = c.electric_network_id
      if id and not nets[id] then
        nets[id] = true
        ids[#ids + 1] = id
      end
    else
      st.conv[unit] = nil
    end
  end
  table.sort(ids)
  return nets, table.concat(ids, ",")
end

-- groups, loops, transit and district settings from the gathered network ids
local function rebuild(t, conv_nets)
  local st = storage
  local tr = st.tr
  local P = st.period
  local groups, list = {}, {}
  local by_in = {}
  local adj = {}
  local edges = {}
  for unit, m in pairs(tr) do
    if not m.gathered then gather_one(unit, m, t, P) end
    local inn, out = m.in_net, m.out_net
    if m.gathered and tr[unit] then
      local bypass = (inn == nil or out == nil or inn == out)
      if not bypass then bypass = m.ps_bypass or false end
      if bypass then
        list[#list + 1] = { key = "b" .. unit, units = { unit }, lead = unit, bypass = true }
      else
        local g = groups[out]
        if not g then
          g = { key = out, units = {}, lead = unit, ins = {} }
          groups[out] = g
          list[#list + 1] = g
        end
        g.units[#g.units + 1] = unit
        g.ins[inn] = true
        if unit < g.lead then g.lead = unit end
        local bi = by_in[inn]
        if not bi then
          bi = {}
          by_in[inn] = bi
        end
        bi[#bi + 1] = unit
        local a = adj[inn]
        if not a then
          a = {}
          adj[inn] = a
        end
        a[out] = true
        if not adj[out] then adj[out] = {} end
        edges[unit] = true
      end
    end
  end
  mark("1-groups")
  -- loops: an edge in -> out inside one strongly connected component; only networks that are both
  -- some transformer's input and some district can be on a cycle
  local core = {}
  local any = false
  for net in pairs(by_in) do
    if groups[net] then
      core[net] = {}
      any = true
    end
  end
  local comp = {}
  if any then
    for net, a in pairs(core) do
      for out in pairs(adj[net]) do
        if core[out] then a[out] = true end
      end
    end
    comp = scc(core)
  end
  for unit in pairs(edges) do
    local m = tr[unit]
    local ci = comp[m.in_net]
    m.loop = ci ~= nil and ci == comp[m.out_net] and comp[-ci] == true
  end
  mark("2-loops")
  -- unify district settings, ids, transit and loops per group
  local used_did = {}
  local groups_of_in = {}
  st.out2did = {}
  for _, g in ipairs(list) do
    if not g.bypass then
      local lead = tr[g.lead]
      -- the leader is the lowest non-reserve transformer
      for _, u in ipairs(g.units) do
        local m = tr[u]
        if not m.reserve and (tr[g.lead].reserve or u < g.lead) then g.lead = u end
      end
      lead = tr[g.lead]
      if #g.units > 1 or lead.did == nil then g.multi = true end
      if used_did[lead.did] then
        local did, dnum = state.new_did(lead.force)
        lead.did, lead.dnum = did, dnum
        if lead.name then lead.name = lead.name .. " 2" end
      end
      used_did[lead.did] = true
      for _, u in ipairs(g.units) do
        local m = tr[u]
        if u ~= g.lead then
          if m.did ~= lead.did or m.name ~= lead.name or m.color ~= lead.color or m.prio ~= lead.prio
            or m.can_shed ~= lead.can_shed or m.off ~= lead.off then
            m.did, m.dnum, m.name, m.color, m.can_shed, m.off = lead.did, lead.dnum, lead.name, lead.color, lead.can_shed, lead.off
            if m.prio ~= lead.prio then
              m.prio = lead.prio
              build.apply_priority(m)
            end
          end
          if (m.tap or 0) ~= (lead.tap or 0) or (m.tap_auto or false) ~= (lead.tap_auto or false) then
            m.tap, m.tap_auto = lead.tap, lead.tap_auto
            build.apply_limits(m)
          end
          if lead.shed and not m.shed then m.shed, m.shed_load = lead.shed, lead.shed_load end
        end
        if m.loop then g.loop = true end
      end
      g.transit = by_in[g.key]
      g.conv = conv_nets[g.key] or false
      st.out2did[g.key] = lead.did
      for inn in pairs(g.ins) do
        local l = groups_of_in[inn]
        if not l then
          l = {}
          groups_of_in[inn] = l
        end
        l[#l + 1] = g
      end
    end
  end
  for did in pairs(st.dist) do
    if not used_did[did] then st.dist[did] = nil end
  end
  mark("3-unify")
  table.sort(list, function(a, b) return a.lead < b.lead end)
  st.queue = list
  st.by_in = by_in
  st.groups_of_in = groups_of_in
  mark("4-sort")
end

function M.plan(t)
  if M.prof then M.prof.cur.reset() end
  local st = storage
  st.next_plan = t + st.period
  local conv_nets, sig = converter_nets()
  if sig ~= st.conv_sig then
    st.conv_sig = sig
    st.topo_dirty = true
  end
  -- the districts are rebuilt only when a network id, a transformer or a converter changed
  if st.topo_dirty or not st.by_in then
    st.topo_dirty = false
    rebuild(t, conv_nets)
    st.rebuilds = (st.rebuilds or 0) + 1
  end
  mark("5-rebuild")
  automation(t, st.by_in, st.groups_of_in)
  load_banks()
  -- forces: saved power of the last period
  for _, f in pairs(st.forces) do
    f.saved_now = f.saved_acc or 0
    f.saved_acc = 0
  end
  st.qi = 1
  st.slice = math.ceil(#st.queue / st.period)
  mark("6-automation-banks")
end

---------------------------------------------------------------- signals, labels, statuses

local SIGNALS = { "signal-L", "signal-P", "signal-B", "signal-D", "signal-S", "signal-A" }

local function write_signals(m, values)
  local cache = m.sigc
  if cache and values then
    local same = true
    for i = 1, 6 do
      if cache[i] ~= values[i] then
        same = false
        break
      end
    end
    if same then return end
  end
  local cb = m.e.get_or_create_control_behavior()
  if not cb then return end
  if cb.sections_count == 0 then cb.add_section() end
  local sec = cb.get_section(1)
  if not sec then return end
  if values then
    local filters = {}
    for i = 1, 6 do
      filters[i] = { value = { type = "virtual", name = SIGNALS[i], quality = "normal" }, min = values[i] }
    end
    sec.filters = filters
  else
    sec.filters = {}
  end
  m.sigc = values
end

function M.clear_signals(m)
  write_signals(m, nil)
  m.sigc = nil
end

-- Status lamp on the front (0.2.1): the colour of the status diode (green - all right, yellow - out of the green zone
-- or waiting, red - not working, blinking). A tinted lens over the unlit glass of the art, an additive halo and a
-- light at night; drawn once, recoloured on a status change. Render objects on the entity go with it.
local LAMP = {
  [DIODE.green] = { color = { 0.30, 1, 0.35 }, blink = 0 },
  [DIODE.yellow] = { color = { 1, 0.78, 0.12 }, blink = 0 },
  [DIODE.red] = { color = { 1, 0.16, 0.10 }, blink = 45 },
}

local function lamp(m, status)
  local e = m.e
  if not (e and e.valid) then return end
  local l = LAMP[(M.STATUS[status] or M.STATUS.idle).diode] or LAMP[DIODE.yellow]
  local c = l.color
  local halo_c = { c[1] * 0.55, c[2] * 0.55, c[3] * 0.55, 0.55 }
  local target = { entity = e, offset = S.LAMP }
  local lens, halo, light = m.lamp_lens, m.lamp_halo, m.lamp_light
  if not (lens and lens.valid) then
    lens = rendering.draw_sprite({ sprite = "ppd-lamp-lens", target = target, surface = e.surface,
      render_layer = "higher-object-under" })
    m.lamp_lens = lens
  end
  if not (halo and halo.valid) then
    halo = rendering.draw_sprite({ sprite = "ppd-lamp-halo", target = target, surface = e.surface,
      render_layer = "higher-object-under" })
    m.lamp_halo = halo
  end
  if not (light and light.valid) then
    light = rendering.draw_light({ sprite = "utility/light_small", target = target, surface = e.surface, scale = 0.5,
      intensity = 0.8, minimum_darkness = 0.2 })
    m.lamp_light = light
  end
  lens.color, halo.color, light.color = c, halo_c, c
  lens.blink_interval, halo.blink_interval, light.blink_interval = l.blink, l.blink, l.blink
end
M.lamp = lamp

local function set_status(m, status)
  if m.status == status then
    -- transformers of 0.2.0 saves and ones whose marks were rebuilt get the lamp on the next pass
    if not (m.lamp_lens and m.lamp_lens.valid) then lamp(m, status) end
    return false
  end
  m.status = status
  m.since = game.tick
  local s = M.STATUS[status]
  if m.e.valid then m.e.custom_status = { diode = s.diode, label = { "ppd-status." .. status } } end
  lamp(m, status)
  return true
end

-- who sees the alt-mode texts (setting ppd-alt-labels); nil = everybody, so players joining later see them too
-- (0.1.0 always stored the list: `(all and nil) or list` is never nil)
function M.label_players()
  local list, all = {}, true
  for _, p in pairs(game.players) do
    if settings.get_player_settings(p)["ppd-alt-labels"].value then list[#list + 1] = p.index else all = false end
  end
  storage.labels_none = (#list == 0)
  if all then storage.label_players = nil else storage.label_players = list end
  for _, m in pairs(storage.tr) do
    local o = m.label
    if o and o.valid then
      if storage.labels_none then
        o.destroy()
        m.label = nil
      else
        o.players = storage.label_players
      end
    end
  end
end

---------------------------------------------------------------- "plug here" marks

-- A bushing without a wire gets the blinking vanilla "not connected" icon above it. 0.2.1: the art itself tells the
-- sides apart (tall brown input, short grey output); the 0.2.0 Input/Output captions are gone (user disliked them,
-- old ones are destroyed by the layout migration in control.lua).
local function plug_icon(m, key, pole, show)
  local o = m[key]
  if not show then
    if o and o.valid then o.destroy() end
    m[key] = nil
    return
  end
  if o and o.valid then return end
  m[key] = rendering.draw_sprite({ sprite = "utility/electricity_icon_unplugged", surface = pole.surface,
    target = { type = "entity", entity = pole, offset = { 0, -0.6 } }, x_scale = 0.5, y_scale = 0.5,
    blink_interval = 30, render_layer = "entity-info-icon" })
end

-- is a bushing wired to anything besides its own hidden link
local function wired(pole)
  local c = pole.get_wire_connector(COPPER, false)
  return c ~= nil and c.real_connection_count > 1
end
M.wired = wired

function M.update_marks(m)
  local pin, pout = m.pin, m.pout
  if not (m.e and m.e.valid and pin and pin.valid and pout and pout.valid) then return end
  local win, wout = wired(pin), wired(pout)
  if win == m.win and wout == m.wout then return end
  m.win, m.wout = win, wout
  plug_icon(m, "icon_in", pin, not win)
  plug_icon(m, "icon_out", pout, not wout)
end

-- 0.2.1: no alt-mode text over the transformer (user: not needed; the status lamp shows the state); a label drawn
-- by 0.2.0 goes on the next pass
local function drop_label(m)
  local l = m.label
  if l and l.valid then l.destroy() end
  m.label, m.lkey = nil, nil
end

---------------------------------------------------------------- districts

local function history(lead, r, dt, t)
  lead.a5 = (lead.a5 or 0) + r * dt
  lead.n5 = (lead.n5 or 0) + dt
  local slot = floor(t / 300)
  if lead.s5 ~= slot then
    if lead.s5 and lead.n5 > 0 then
      local v = lead.a5 / lead.n5
      push(lead.h5, v)
      lead.a60 = (lead.a60 or 0) + v
      lead.n60 = (lead.n60 or 0) + 1
      if lead.n60 >= 12 then
        local v60 = lead.a60 / lead.n60
        push(lead.h60, v60)
        lead.a60, lead.n60 = 0, 0
        lead.a600 = (lead.a600 or 0) + v60
        lead.n600 = (lead.n600 or 0) + 1
        if lead.n600 >= 10 then
          push(lead.h600, lead.a600 / lead.n600)
          lead.a600, lead.n600 = 0, 0
        end
      end
    end
    lead.s5 = slot
    lead.a5, lead.n5 = 0, 0
  end
end

-- J per tick the district asks: machines and downstream inputs (primary + secondary), plus accumulators and
-- low-priority inputs (tertiary); known even when the district buffer ran dry
local function district_demand(lead)
  local sub = lead.pout and lead.pout.valid and lead.pout.electric_network
  local net = sub and sub.parent_network
  local fl = net and net.flow_last_tick
  if not fl then return 0, 0 end
  local ps = fl.primary_demand + fl.secondary_demand
  return ps, ps + fl.tertiary_demand
end

-- J per tick an input may draw on top of its district's use to fill its buffers: empty buffers fill in about 30 s,
-- and never faster than a share of the main grid's spare generation (shared by all inputs on that grid)
function M.charge_allowance(m, ns)
  local c = build.charge_rate(m)
  if ns and ns.spare then
    local share = max(0, ns.spare) * 0.3 / max(1, ns.n or 1)
    if share < c then c = share end
  end
  return c
end

function M.tap_text(tap)
  tap = tap or 0
  if tap == 0 then return { "", "0 %" } end
  return { "", tap > 0 and "+" or "−", floor(abs(tap) * S.TAP_STEP * 100 + 0.5), " %" }
end

local function bypass_group(g, t)
  local m = storage.tr[g.units[1]]
  if not (m and m.e.valid and m.ein and m.ein.valid and m.eout and m.eout.valid) then return end
  local oe = m.eout.energy
  local ie = m.ein.energy
  if oe > 0 then
    ie = min(m.cap, ie + oe)
    m.ein.energy = ie
    m.eout.energy = 0
  end
  m.ie_last, m.draw = ie, 0
  m.lo, m.take, m.saved, m.lt, m.avg, m.ld, m.b = 0, 0, 0, t, 0, 0, 0
  build.set_rate(m, min((m.cap - ie) / storage.period, M.charge_allowance(m, nil)))
  if set_status(m, "bypass") then
    journal.add(m.force, "wire", "alarm", { "ppd-journal.bypass", name_of(m) }, m)
  end
  if m.sig then write_signals(m, { 0, 0, 0, 0, 6, 0 }) end
  if m.label then drop_label(m) end
end

function M.process(g, t)
  if g.bypass then return bypass_group(g, t) end
  local st = storage
  local tr = st.tr
  local members = {}
  for _, u in ipairs(g.units) do
    local m = tr[u]
    if m and m.e.valid and m.ein and m.ein.valid and m.eout and m.eout.valid then members[#members + 1] = m end
  end
  if #members == 0 then return end
  local lead = tr[g.lead]
  if not (lead and lead.e.valid) then lead = members[1] end
  local f = state.force(lead.force)
  local has_auto = f.has_auto

  -- district switches
  local off
  for _, m in ipairs(members) do
    if m.cond and m.cond.on and m.cond.sig then
      local ok, v = pcall(m.e.get_signal, m.cond.sig, RED, GREEN)
      m.cond_off = ok and not cmp(v, m.cond.cmp or ">", tonumber(m.cond.val) or 0) or false
    else
      m.cond_off = false
    end
    if m.off then off = "off_manual" end
  end
  if not off then
    for _, m in ipairs(members) do
      if m.shed then off = "off_auto" break end
    end
  end
  if not off then
    for _, m in ipairs(members) do
      if m.cond_off then off = "off_circuit" break end
    end
  end

  -- measure what the district drew from the outputs
  local drate = 0
  for _, m in ipairs(members) do
    local dt = t - (m.lt or t)
    if dt < 1 then dt = 1 end
    local oe = m.eout.energy
    local dr = (m.lo or 0) - oe
    if dr < 0 then dr = 0 end
    m._dt, m._oe, m._dr = dt, oe, dr
    drate = drate + dr / dt
  end
  local trate = 0
  if g.transit then
    for _, u in ipairs(g.transit) do
      local x = tr[u]
      if x then trate = trate + (x.draw or 0) end
    end
  end
  local fr = 1
  if drate > 0 then fr = U.clamp(1 - trate / drate, 0, 1) end

  -- reserve
  local ds = st.dist[lead.did]
  if not ds then
    ds = { did = lead.did }
    st.dist[lead.did] = ds
  end
  local prim_n, prim_ok = 0, 0
  for _, m in ipairs(members) do
    if not (m.reserve and has_auto) then
      prim_n = prim_n + 1
      if not m.noin then prim_ok = prim_ok + 1 end
    end
  end
  local over_long = ds.over_since and (t - ds.over_since >= 600) or false
  local engaged = has_auto and (prim_n == 0 or prim_ok == 0 or over_long)
  if engaged then
    ds.res_until = t + 1800
  elseif ds.res_until and t < ds.res_until and has_auto then
    engaged = true
  end

  -- averages and nominal
  local N, L, Lnow = 0, 0, 0
  for _, m in ipairs(members) do
    local active = (not (m.reserve and has_auto)) or engaged
    m._active = active
    local x = (m._dr / m._dt) * fr
    m.avg = (m.avg or 0) + (x - (m.avg or 0)) * (1 - exp(-m._dt / S.TAU))
    m.ld = x
    L = L + m.avg
    Lnow = Lnow + x
    if active then N = N + m.nominal end
  end
  local r = N > 0 and L / N or 0
  local rnow = N > 0 and Lnow / N or 0
  local hw = state.half_width(f)
  local lo, hi = 1 - hw, 1 + hw
  local zone = (not off) and (not g.loop) and (not g.conv) and N > 0 and r >= lo and r <= hi
  local mult = state.bonus_mult(f)

  -- what the district asks (read only when needed: boost research, or a district buffer that ran dry)
  local dem_ps, dem_all
  if f.boost and not off and N > 0 and (ds.boost_until or rnow >= S.LIMIT * 0.97) then
    dem_ps, dem_all = district_demand(lead)
  end

  -- short overload (research): up to 150 % for 60 s when the district asks for more than the limit, then 5 min rest
  local boosting = false
  if dem_ps then
    local ask = dem_ps / N
    if ds.boost_until then
      if t >= ds.boost_until or ask < S.LIMIT * 0.92 then
        ds.boost_until = nil
        ds.boost_ready = t + S.BOOST_COOLDOWN
      else
        boosting = true
      end
    elseif ask >= S.LIMIT * 0.99 and t >= (ds.boost_ready or 0) then
      ds.boost_until = t + S.BOOST_TICKS
      boosting = true
      journal.add(lead.force, "overload", "info", { "ppd-journal.boost", name_of(lead) }, lead)
    end
  elseif ds.boost_until then
    ds.boost_until = nil
    ds.boost_ready = t + S.BOOST_COOLDOWN
  end
  for _, m in ipairs(members) do
    if (m.boosting or false) ~= boosting then
      m.boosting = boosting
      build.apply_limits(m)
    end
  end

  local nowire_in, nowire_out = true, (#members == 1 and lead.wout == false)
  local noin_all = true
  for _, m in ipairs(members) do
    if m.win ~= false then nowire_in = false end
    if m._active and not m.noin then noin_all = false end
  end
  local status
  if nowire_in then status = "nowire_in"
  elseif nowire_out then status = "nowire_out"
  elseif off then status = off
  elseif g.loop then status = "loop"
  elseif g.conv then status = "converter"
  elseif noin_all and N > 0 then status = "noinput"
  elseif boosting then status = "boost"
  elseif rnow >= S.LIMIT * 0.985 or r >= S.LIMIT * 0.985 then status = "limit"
  elseif L < N * 0.005 then status = "idle"
  elseif r < lo then status = "under"
  elseif r > hi then status = "over"
  else status = "zone" end
  if r > 1.10 and not off then ds.over_since = ds.over_since or t else ds.over_since = nil end

  -- automatic tap changer (research): one step per 30 s while the 30 s average stays out of the zone
  ds.born = ds.born or t
  if zone then ds.out_since = nil else ds.out_since = ds.out_since or t end
  local tapmax = f.taps or 0
  if lead.tap_auto and f.auto_taps and tapmax > 0 and (status == "under" or status == "over" or status == "limit")
    and t - ds.born >= 3 * S.TAP_DELAY and t - (ds.out_since or t) >= S.TAP_DELAY and t - (ds.tap_t or -1e9) >= S.TAP_DELAY then
    local nt = (lead.tap or 0) + (r < lo and -1 or 1)
    if abs(nt) <= tapmax then
      for _, m in ipairs(members) do
        m.tap = nt
        build.apply_limits(m)
      end
      ds.tap_t = t
      journal.add(lead.force, "auto", "info", { "ppd-journal.tap", name_of(lead), M.tap_text(nt) }, lead)
    end
  end

  -- transfer: refill the district buffer from the input buffer once per period, then let the input draw the next
  -- period's energy evenly (0.1.0 refilled the input at its full limit in 2-3 ticks: a spike on the main grid)
  local P = st.period
  local saved_sum, take_sum, bonus_w, saved_j = 0, 0, 0, 0
  for _, m in ipairs(members) do
    local ein, eout = m.ein, m.eout
    local dt = m._dt
    local ie0 = ein.energy
    local drew = ie0 - (m.ie_last or ie0)
    if drew < 0 then drew = 0 end
    m.draw = drew / dt
    local charge = M.charge_allowance(m, st.nets[m.in_net])
    if off or not m._active then
      local oe = m._oe
      local ie = ie0
      if oe > 0 then
        local mv = min(oe, m.cap - ie)
        if mv > 0 then
          ie = ie + mv
          ein.energy = ie
        end
        eout.energy = 0
      end
      m.ie_last = ie
      m.lo, m.take, m.saved, m.b, m.noin = 0, 0, 0, 0, false
      build.set_rate(m, min((m.cap - ie) / P, charge))
    else
      local B = zone and S.TIERS[m.tier].bonus * mult or 0
      m.b = B
      local unit_cost = fr / (1 + B) + (1 - fr)
      local ie = ie0
      local idle = m.idle * dt
      local want = m.cap - m._oe
      local need = want * unit_cost + idle
      local starved = false
      if need > ie then
        starved = true
        if ie > idle then want = (ie - idle) / unit_cost else want, idle = 0, ie end
        need = want * unit_cost + idle
      end
      local rest = ie - need
      if rest < 0 then rest = 0 end
      ein.energy = rest
      m.ie_last = rest
      local newo = m._oe + want
      eout.energy = newo
      m.lo = newo
      m.take = need / dt
      m.saved = (want * fr * B / (1 + B) - idle) / dt
      -- no input: the grid gave clearly less than allowed, the transfer ran short and the district buffer is low
      m.noin = starved and drew < (m.rate or 0) * dt * 0.9 and newo < m.cap * 0.25
      -- next period: what the district uses (measured, or asked when its buffer ran dry) plus a gentle charge,
      -- never more than the input buffer takes in one period, so the main grid sees a flat line
      local run = m._dr / dt
      if m._oe <= m.cap * 0.02 then
        -- the district buffer ran dry: the measured draw is too low, take what the district asks
        if not dem_all then dem_ps, dem_all = district_demand(lead) end
        run = max(run, dem_all * (N > 0 and m.nominal / N or 0))
      end
      run = run * unit_cost + m.idle
      build.set_rate(m, min((m.cap - rest) / P, run + charge))
      m.sum_out = (m.sum_out or 0) + m._dr
      m.sum_saved = (m.sum_saved or 0) + m.saved * dt
      saved_sum = saved_sum + m.saved
      saved_j = saved_j + m.saved * dt
      take_sum = take_sum + m.take
      bonus_w = bonus_w + B * m.avg
    end
    m.lt = t
  end
  f.saved = f.saved + saved_j
  f.saved_acc = (f.saved_acc or 0) + saved_sum

  -- district summary for the windows, the advisor and the load banks
  local prev = ds.status
  ds.did, ds.lead, ds.force, ds.units = lead.did, lead.unit, lead.force, g.units
  ds.N, ds.L, ds.Lnow, ds.r, ds.rnow, ds.lo, ds.hi = N, L, Lnow, r, rnow, lo, hi
  ds.status, ds.zone, ds.off = status, zone, off ~= nil
  ds.bonus = L > 0 and bonus_w / L or 0
  ds.take, ds.saved, ds.engaged, ds.t = take_sum, saved_sum, engaged, t
  ds.transit = trate
  ds.loop, ds.conv = g.loop, g.conv
  ds.ins = g.ins
  ds.out_net = g.key
  ds.dem, ds.boosting, ds.tap = dem_all or ds.dem, boosting, lead.tap or 0
  if zone then ds.zone_since = ds.zone_since or t else ds.zone_since = nil end
  history(lead, r, members[1]._dt, t)

  -- journal on district status changes
  if prev ~= status and prev ~= nil then
    local name = name_of(lead)
    if status == "zone" then
      journal.add(lead.force, "zone", "info", { "ppd-journal.zone-in", name }, lead)
    elseif prev == "zone" then
      journal.add(lead.force, "zone", "info", { "ppd-journal.zone-out", name, floor(r * 100 + 0.5) }, lead)
      if lead.e.valid then
        for _, p in pairs(lead.e.force.connected_players) do
          if settings.get_player_settings(p)["ppd-zone-sound"].value then p.play_sound({ path = "utility/console_message" }) end
        end
      end
    end
    if status == "limit" then
      journal.add(lead.force, "overload", "alarm", { "ppd-journal.limit", name, floor(r * 100 + 0.5) }, lead)
    elseif status == "over" and prev ~= "limit" then
      journal.add(lead.force, "overload", "info", { "ppd-journal.over", name, floor(r * 100 + 0.5) }, lead)
    elseif status == "noinput" then
      journal.add(lead.force, "overload", "alarm", { "ppd-journal.noinput", name }, lead)
    elseif status == "loop" then
      journal.add(lead.force, "wire", "alarm", { "ppd-journal.loop", name }, lead)
    elseif status == "converter" then
      journal.add(lead.force, "wire", "alarm", { "ppd-journal.converter", name }, lead)
    end
    if OK_STATUS[status] and not OK_STATUS[prev] then
      for _, m in ipairs(members) do journal.clear_alerts(m) end
    end
  end
  if engaged and not ds.was_engaged then
    for _, m in ipairs(members) do
      if m.reserve then
        journal.add(m.force, "auto", "alarm", { "ppd-journal.reserve-on", name_of(lead) }, m)
        break
      end
    end
  end
  ds.was_engaged = engaged

  -- per transformer: status, signals, labels
  local A = 0
  for inn in pairs(g.ins) do
    local ns = st.nets[inn]
    if ns and ns.sat then A = max(A, ns.sat) end
  end
  local pct = floor(r * 100 + 0.5)
  local d_kw = 0
  if r < lo then d_kw = (lo * N - L) * 0.06 elseif r > hi then d_kw = (hi * N - L) * 0.06 end
  for _, m in ipairs(members) do
    local s = status
    if m.reserve and has_auto and not off then s = engaged and "reserve_on" or "reserve_wait" end
    if m.win == false then s = "nowire_in" elseif m.wout == false then s = "nowire_out" end
    set_status(m, s)
    if m.sig then
      write_signals(m, { pct, floor(L * 0.06 + 0.5), floor((m.b or 0) * 1000 + 0.5), floor(d_kw + 0.5),
        M.STATUS[s].code, floor(A * 100 + 0.5) })
    elseif m.sigc then
      M.clear_signals(m)
    end
    if m.label then drop_label(m) end
  end
end

function M.on_tick(t)
  local st = storage
  local planned = false
  if t >= st.next_plan then
    M.plan(t)
    planned = true
  end
  M.gather_slice(t)
  local q = st.queue
  local i = st.qi
  local n = st.slice
  for _ = 1, n do
    local g = q[i]
    if not g then break end
    M.process(g, t)
    i = i + 1
  end
  st.qi = i
  return planned
end

return M
