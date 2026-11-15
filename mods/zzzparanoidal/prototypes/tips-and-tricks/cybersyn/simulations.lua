-- Анимации к «Советам и подсказкам» о диспетчерской сети поездов (prototypes/tips-and-tricks/cybersyn/cybersyn.lua).
-- Каждая симуляция = общий пролог C + своя сцена. Живые сцены запускают настоящий скрипт Cybersyn
-- (поле mods = {"cybersyn"}): доставки, заправку и обход депо назначает сам мод, сцена только строит станции,
-- изображает расход груза, подсвечивает нужное место и подписывает происходящее. Схемы (режимы, сети, маски,
-- ячейки вагона) нарисованы. Любая ошибка сцены выводится текстом в окне симуляции (ключ zzz-cybersyn-sim.error).

local PRELUDE = [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
C = {t = 0, jobs = {}, movers = {}, trains = {}, pulses = {},
  stats = {dispatch = 0, deliveries = 0, bypass = 0, refuel = 0, depot = 0}}
surface.always_day = true
-- The default checkerboard ({-20, -15} to {20, 15}) is smaller than the rail loop of the big scenes
surface.build_checkerboard{{-48, -28}, {48, 28}}
-- Reading sim.camera_position gives {x = , y = }: the scene keeps its own copy of the camera position
C.cam = {0, 0}
sim.camera_position = C.cam
sim.camera_zoom = 1
sim.camera_alt_info = true
sim.hide_cursor = true

local GREEN = defines.wire_connector_id.circuit_green
local IN = defines.wire_connector_id.combinator_input_green
C.GREEN, C.IN = GREEN, IN
C.INPUTS = {defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green}
C.OUTPUTS = {defines.wire_connector_id.combinator_output_red, defines.wire_connector_id.combinator_output_green}
-- Text size: the scenes give relative sizes, this factor makes them readable in the 1408x704 tips window
C.TEXT = 1.35
C.COL = {depot = {0.8, 0.8, 0.8}, provider = {0.45, 1, 0.5}, requester = {0.55, 0.75, 1}, refuel = {1, 0.75, 0.35},
  note = {1, 0.9, 0.55}, dim = {0.55, 0.55, 0.55}, green = {0.5, 1, 0.5}, red = {1, 0.45, 0.45}, white = {1, 1, 1}}

function C.fail(message)
  if C.err then return end
  C.err = message
  pcall(log, {"", "zzz cybersyn tips simulation: ", message})
  pcall(rendering.draw_text, {text = {"zzz-cybersyn-sim.error", message}, surface = surface, target = C.cam,
    color = {1, 0.35, 0.35}, scale = 1.4, alignment = "center", vertical_alignment = "middle"})
end

function C.step()
  for i = #C.jobs, 1, -1 do
    local job = C.jobs[i]
    if C.t >= job.at then
      table.remove(C.jobs, i)
      job.fn()
    end
  end
  if C.main then C.main(C.t) end
  C.step_movers()
  C.step_pulses()
  if C.t % 6 == 0 then C.poll() end
end

script.on_nth_tick(1, function()
  if C.err then return end
  C.t = C.t + 1
  local ok, message = pcall(C.step)
  if not ok then C.fail(tostring(message)) end
end)

function C.at(t, fn) C.jobs[#C.jobs + 1] = {at = t, fn = fn} end
function C.after(ticks, fn) C.at(C.t + ticks, fn) end
-- The scene is built on the first tick: the scripts of the simulation's mods are initialised by then.
function C.scene(fn) C.at(1, fn) end

function C.camera(position, zoom)
  C.cam = position
  sim.camera_position = position
  sim.camera_zoom = zoom
end

-- Cybersyn -----------------------------------------------------------------------------------------
function C.need()
  if remote.interfaces["cybersyn"] then
    C.live = true
    return true
  end
  C.fail({"zzz-cybersyn-sim.no-script"})
  return false
end

function C.setting(key, value) remote.call("cybersyn", "write_setting", key, value) end

function C.status_of(train)
  if not (train and train.valid) then return nil end
  return remote.call("cybersyn", "read_global", "trains", train.id, "status")
end

-- Cargo on its way to (+) or from (-) a station, as Cybersyn counts it
function C.in_transit(stop, item)
  if not (stop and stop.valid) then return 0 end
  return remote.call("cybersyn", "read_global", "stations", stop.unit_number, "deliveries", item) or 0
end

-- Drawing: every object goes into C.group while a scene phase collects them ---------------------------
function C.keep(object)
  if C.group then C.group[#C.group + 1] = object end
  return object
end

function C.clear(group)
  for _, object in ipairs(group or {}) do
    if object.valid then object.destroy() end
  end
end

function C.text(position, text, o)
  o = o or {}
  return C.keep(rendering.draw_text{text = text, surface = surface, target = position, color = o.color or C.COL.white,
    scale = (o.scale or 1) * C.TEXT, font = o.font or "default-bold", alignment = o.align or "center",
    vertical_alignment = o.valign or "middle", use_rich_text = true})
end

function C.rect(left_top, right_bottom, color, filled, width)
  return C.keep(rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = width or 2})
end

function C.line(from, to, color, width, dash)
  return C.keep(rendering.draw_line{surface = surface, from = from, to = to, color = color, width = width or 3,
    dash_length = dash or 0, gap_length = dash or 0})
end

function C.sprite(sprite, position, scale, tint)
  return C.keep(rendering.draw_sprite{sprite = sprite, surface = surface, target = position, x_scale = scale or 1,
    y_scale = scale or 1, tint = tint})
end

-- Dark plate under the explanations
function C.board(left, top, right, bottom)
  C.rect({left, top}, {right, bottom}, {0, 0, 0, 0.72})
  C.rect({left, top}, {right, bottom}, {0.45, 0.45, 0.45, 0.9}, false, 2)
end

-- Box with a title: a station, a train or a combinator of a scheme
function C.box(x, y, w, h, color, title, scale)
  C.rect({x - w / 2, y - h / 2}, {x + w / 2, y + h / 2}, {color[1] * 0.22, color[2] * 0.22, color[3] * 0.22, 0.9})
  C.rect({x - w / 2, y - h / 2}, {x + w / 2, y + h / 2}, color, false, 3)
  if title then return C.text({x, y}, title, {scale = scale or 1}) end
end

function C.title(text, y, scale)
  return C.text({C.cam[1], y}, text, {scale = scale or 1.5, color = C.COL.note})
end

-- Arrow: a line with a head at `to`
function C.arrow(from, to, color, width)
  local dx, dy = to[1] - from[1], to[2] - from[2]
  local length = math.sqrt(dx * dx + dy * dy)
  if length == 0 then return end
  local ux, uy = dx / length, dy / length
  C.line(from, to, color, width or 4)
  for _, s in ipairs({1, -1}) do
    C.line(to, {to[1] - 0.7 * (ux * 0.87 - s * uy * 0.5), to[2] - 0.7 * (uy * 0.87 + s * ux * 0.5)}, color, width or 4)
  end
end

-- Pulsing frame around the place the text talks about
function C.pulse(left_top, right_bottom, color)
  local p = {color = color or C.COL.note}
  p.object = C.rect(left_top, right_bottom, p.color, false, 5)
  C.pulses[#C.pulses + 1] = p
  return p
end

function C.unpulse(p)
  if p and p.object.valid then p.object.destroy() end
end

function C.step_pulses()
  local a = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(C.t * 0.12))
  local list = {}
  for _, p in ipairs(C.pulses) do
    if p.object.valid then
      p.object.color = {p.color[1] * a, p.color[2] * a, p.color[3] * a, a}
      list[#list + 1] = p
    end
  end
  C.pulses = list
end

-- Moving tokens: a group of sprites moving together ----------------------------------------------------
function C.token(sprites, position)
  local token = {parts = {}, position = position}
  for i, s in ipairs(sprites) do
    local offset = s.offset or {0, 0}
    token.parts[i] = {offset = offset, object = C.sprite(s.sprite, {position[1] + offset[1], position[2] + offset[2]}, s.scale or 0.8)}
  end
  return token
end

function C.place(token, position)
  token.position = position
  for _, part in ipairs(token.parts) do
    if part.object.valid then part.object.target = {position[1] + part.offset[1], position[2] + part.offset[2]} end
  end
end

function C.destroy(token)
  for _, part in ipairs(token.parts) do if part.object.valid then part.object.destroy() end end
end

function C.path(token, points, ticks, done)
  C.movers[#C.movers + 1] = {token = token, points = points, index = 1, from = token.position, ticks = math.max(1, ticks), i = 0, done = done}
end

function C.step_movers()
  local list = C.movers
  C.movers = {}
  for _, m in ipairs(list) do
    m.i = m.i + 1
    local to = m.points[m.index]
    local f = m.i / m.ticks
    if f >= 1 then
      C.place(m.token, to)
      if m.index < #m.points then
        m.index, m.i, m.from = m.index + 1, 0, to
        C.movers[#C.movers + 1] = m
      elseif m.done then
        m.done(m.token)
      end
    else
      C.place(m.token, {m.from[1] + (to[1] - m.from[1]) * f, m.from[2] + (to[2] - m.from[2]) * f})
      C.movers[#C.movers + 1] = m
    end
  end
end

-- Entities -----------------------------------------------------------------------------------------
function C.make(name, position, direction, extra)
  local spec = {name = name, position = position, direction = direction, force = force, create_build_effect_smoke = false}
  for k, v in pairs(extra or {}) do spec[k] = v end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. ", " .. position[2]) end
  return entity
end

function C.straight(x1, x2, y)
  for x = x1, x2, 2 do C.make("straight-rail", {x, y}, defines.direction.east) end
end

-- Oval loop, the geometry of the base game's fluid wagon tip: the top straight (y = T, odd) is driven east,
-- the bottom one (y = T + 26) west; XL/XR (even) are the x of the curves at the ends of the straights.
function C.loop(XL, XR, T)
  C.straight(XL + 3, XR - 3, T)
  C.straight(XL + 3, XR - 3, T + 26)
  local left = {{"curved-rail-a", 0, 0, 12}, {"curved-rail-b", -5, 2, 12}, {"curved-rail-b", -9, 6, 2}, {"curved-rail-a", -11, 11, 2},
    {"curved-rail-a", -11, 15, 8}, {"curved-rail-b", -9, 20, 8}, {"curved-rail-b", -5, 24, 14}, {"curved-rail-a", 0, 26, 14}}
  local right = {{"curved-rail-a", 0, 0, 6}, {"curved-rail-b", 5, 2, 6}, {"curved-rail-b", 9, 6, 0}, {"curved-rail-a", 11, 11, 0},
    {"curved-rail-a", 11, 15, 10}, {"curved-rail-b", 9, 20, 10}, {"curved-rail-b", 5, 24, 4}, {"curved-rail-a", 0, 26, 4}}
  for _, p in ipairs(left) do C.make(p[1], {XL + p[2], T + p[3]}, p[4]) end
  for _, p in ipairs(right) do C.make(p[1], {XR + p[2], T + p[3]}, p[4]) end
end

function C.wire(a, a_id, b, b_id)
  a.get_wire_connector(a_id, true).connect_to(b.get_wire_connector(b_id, true), false)
end

-- Substations at the points, each wired to the nearest earlier one, and one energy interface
function C.power(points, interface)
  local poles = {}
  local id = defines.wire_connector_id.pole_copper
  for i, p in ipairs(points) do
    poles[i] = C.make("substation", p)
    local best, distance
    for j = 1, i - 1 do
      local d = math.sqrt((p[1] - points[j][1]) ^ 2 + (p[2] - points[j][2]) ^ 2)
      if not distance or d < distance then best, distance = j, d end
    end
    if best then
      pcall(function() poles[best].get_wire_connector(id, true).connect_to(poles[i].get_wire_connector(id, true), false) end)
    end
  end
  if interface then C.make("electric-energy-interface", interface) end
  return poles
end

function C.stop(x, y, direction, name, color, limit)
  local stop = C.make("train-stop", {x, y}, direction, {station = name, color = color, raise_built = true})
  stop.backer_name = name
  if limit then stop.trains_limit = limit end
  return stop
end

-- Station controller (cybersyn-combinator). Modes and settings bits as in cybersyn scripts/constants.lua.
C.MODE = {station = "/", depot = "+", refueler = ">>", control = "%", wagon = "-", active = "<<", failed = "^"}
C.BIT = {allow_off = 2, stack = 3, inactive = 4, any_depot = 5, no_bypass = 6, train_count = 9}
-- o: network (virtual signal name), pr (0 provide and request, 1 provide only, 2 request only), bits {name = true},
-- register = false keeps Cybersyn from seeing it (a picture of a mode)
function C.controller(position, mode, o)
  o = o or {}
  local bits = o.pr or 0
  local flags = o.bits or {any_depot = true, train_count = true}
  for name, on in pairs(flags) do
    if on then bits = bit32.bor(bits, bit32.lshift(1, C.BIT[name])) end
  end
  local entity = C.make("cybersyn-combinator", position, defines.direction.north, {control_behavior = {arithmetic_conditions = {
    operation = C.MODE[mode], first_signal = {type = "virtual", name = o.network or "signal-A"}, second_constant = bits}}})
  if o.register ~= false then script.raise_script_built{entity = entity} end
  return entity
end

function C.set_mode(entity, mode)
  local control = entity.get_or_create_control_behavior()
  local p = control.parameters
  p.operation = C.MODE[mode]
  control.parameters = p
end

function C.mode_of(entity)
  return entity.get_or_create_control_behavior().parameters.operation
end

-- Constant combinator with signals {{type, name, count}, ...}
function C.constant(name, position, signals)
  local entity = C.make(name, position, defines.direction.north)
  C.set_signals(entity, signals)
  return entity
end

function C.set_signals(entity, signals)
  local control = entity.get_or_create_control_behavior()
  local section = control.get_section(1) or control.add_section()
  local filters = {}
  for i, s in ipairs(signals) do
    filters[i] = {value = {type = s[1], name = s[2], quality = "normal", comparator = "="}, min = s[3]}
  end
  section.filters = filters
end

function C.signals_of(entity, ids)
  local ok, list = pcall(function() return entity.get_signals(ids[1], ids[2]) end)
  return ok and list or nil
end

-- Signals as rich text: "[item=iron-ore] +4000  [virtual-signal=...] 2000"
function C.signal_text(list)
  if not list or #list == 0 then return {"zzz-cybersyn-sim.no-signals"} end
  local parts = {}
  for _, s in ipairs(list) do
    local kind = s.signal.type or "item"
    local tag = kind == "virtual" and "virtual-signal" or kind
    parts[#parts + 1] = "[" .. tag .. "=" .. s.signal.name .. "] " .. (s.count > 0 and "+" or "") .. s.count
  end
  return table.concat(parts, "   ")
end

-- Inserter between a chest row and a wagon: tries both directions until it drops towards drop_y
function C.inserter(name, position, drop_y)
  local entity = C.make(name, position, defines.direction.north)
  if (entity.drop_position.y - position[2]) * (drop_y - position[2]) < 0 then
    entity.destroy()
    entity = C.make(name, position, defines.direction.south)
  end
  return entity
end

-- Inserters at y_inserter for x = x1..x2 and a chest behind each one (at y_chest), chests wired together
function C.loader(x1, x2, y_inserter, y_chest, drop_y, chest)
  local chests = {}
  for x = x1, x2 do
    C.inserter("bulk-inserter", {x, y_inserter}, drop_y)
    chests[#chests + 1] = C.make(chest or "iron-chest", {x, y_chest})
    if #chests > 1 then C.wire(chests[#chests - 1], GREEN, chests[#chests], GREEN) end
  end
  return chests
end

function C.count(chests, item)
  local total = 0
  for _, chest in ipairs(chests) do
    if chest.valid then total = total + chest.get_inventory(defines.inventory.chest).get_item_count(item) end
  end
  return total
end

function C.fill(chests, item, amount)
  local i = 0
  while amount > 0 and i < #chests * 2 do
    i = i + 1
    local chest = chests[(i - 1) % #chests + 1]
    local share = math.ceil(amount / #chests)
    local done = chest.get_inventory(defines.inventory.chest).insert{name = item, count = math.min(share, amount)}
    amount = amount - done
  end
end

function C.drain(chests, item, amount)
  for _, chest in ipairs(chests) do
    if amount <= 0 then return end
    amount = amount - chest.get_inventory(defines.inventory.chest).remove{name = item, count = amount}
  end
end

-- Train parked `back` tiles before the stop: {"locomotive", "cargo-wagon", ...}
function C.train(stop, cars, o)
  o = o or {}
  local east = stop.direction == defines.direction.east
  local sign = east and -1 or 1
  local y = east and stop.position.y - 2 or stop.position.y + 2
  local first = stop.position.x + sign * (3 + (o.back or 2))
  local carriages = {}
  for i, name in ipairs(cars) do
    carriages[i] = C.make(name, {first + sign * 7 * (i - 1), y}, nil, {orientation = east and 0.25 or 0.75})
  end
  local loco = carriages[1]
  loco.get_fuel_inventory().insert{name = "coal", count = o.fuel or 1200}
  if o.cargo then
    for _, car in ipairs(carriages) do
      if car.type == "cargo-wagon" then car.get_inventory(defines.inventory.cargo_wagon).insert(o.cargo) end
    end
  end
  if o.depot then
    loco.train.schedule = {current = 1, records = {{station = o.depot, wait_conditions = {{type = "inactivity", compare_type = "and", ticks = 120}}}}}
    loco.train.manual_mode = false
  end
  return loco, carriages
end

-- Status label over a locomotive (below it on the bottom half of the loop); C.poll follows the Cybersyn status
-- and calls C.on_status(tracked, old, new)
function C.track(loco)
  local tracked = {loco = loco, status = "none", below = false}
  tracked.label = rendering.draw_text{text = {"zzz-cybersyn-sim.status-none"}, surface = surface,
    target = {entity = loco, offset = {0, -2.6}}, color = {1, 1, 0.75}, scale = 2.2, font = "default-bold",
    alignment = "center", vertical_alignment = "middle", use_rich_text = true}
  C.trains[#C.trains + 1] = tracked
  return tracked
end

function C.poll()
  if not remote.interfaces["cybersyn"] then return end
  -- Cybersyn reloads all its settings when any runtime setting changes; keep new stations from waiting 20 s
  if C.live and C.t % 120 == 0 then C.setting("warmup_time", 0) end
  for _, tracked in ipairs(C.trains) do
    if tracked.loco.valid and tracked.label.valid then
      local below = tracked.loco.position.y > 0
      if below ~= tracked.below then
        tracked.below = below
        tracked.label.target = {entity = tracked.loco, offset = {0, below and 2.6 or -2.6}}
      end
      local status = C.status_of(tracked.loco.train) or "none"
      if status ~= tracked.status then
        local old = tracked.status
        tracked.status = status
        tracked.label.text = {"zzz-cybersyn-sim.status-" .. status}
        if old == 0 and status == 1 then C.stats.dispatch = C.stats.dispatch + 1 end
        if old == 6 and status == 1 then C.stats.bypass = C.stats.bypass + 1 end
        if old == 4 and status ~= 4 then C.stats.deliveries = C.stats.deliveries + 1 end
        if status == 7 then C.stats.refuel = C.stats.refuel + 1 end
        if status == 0 and old ~= "none" then C.stats.depot = C.stats.depot + 1 end
        if C.on_status then C.on_status(tracked, old, status) end
      end
    end
  end
end

function C.busy(tracked)
  local s = tracked.status
  return s == 1 or s == 2 or s == 3 or s == 4
end

-- The network of the big scenes ---------------------------------------------------------------------
-- Loop XL = -20, XR = 20, T = -13: depot and provider on the top straight (driven east), requesters and the
-- refueler on the bottom one (driven west). A parked train: the locomotive 3-10 tiles and the wagon 10-17 tiles
-- past the stop. The middle of the loop (x -15..15, y -4..4) is kept free for the board with explanations.
C.NAMES = {depot = "[virtual-signal=signal-D]", provider = "[virtual-signal=up-arrow]", requester = "[virtual-signal=down-arrow]",
  requester2 = "[virtual-signal=down-arrow][virtual-signal=signal-2]", refueler = "[item=coal]"}
C.REQ = {
  {stop = {-17, 11}, comb = {-15.5, 11}, const = {-15.5, 8.5}, x1 = -9.5, x2 = -4.5, label = {-7, 8.8}},
  {stop = {3, 11}, comb = {4.5, 11}, const = {4.5, 8.5}, x1 = 10.5, x2 = 15.5, label = {13, 8.8}},
}

function C.net_power(extra)
  local points = {{-4, -5.5}, {10, -5.5}, {4, 5.5}, {-10, 5.5}}
  if extra then points[#points + 1] = {13, 5.5} end
  C.power(points, {17, -1})
end

-- o: item, request, threshold, start, start2, consume, consume2 (per second), stock, stock_cap, refill,
-- second (a second requester), refueler, fuel, constant (combinator name), no_bypass
function C.net_base(o)
  local N = {o = o or {}, req = {}}
  N.item = N.o.item or "iron-ore"
  N.capacity = 20 * prototypes.item[N.item].stack_size
  C.setting("warmup_time", 0)
  force.bulk_inserter_capacity_bonus = 40
  C.loop(-20, 20, -13)
  C.net_power(N.o.second)
  return N
end

function C.net_depot(N)
  N.depot = C.stop(-1, -11, defines.direction.east, C.NAMES.depot, C.COL.depot, 1)
  N.depot_comb = C.controller({-2.5, -11}, "depot", {bits = {any_depot = true, train_count = true, no_bypass = N.o.no_bypass}})
end

-- Provider: chests south of the top rail, inserters load the wagon (north)
function C.net_provider(N)
  N.p_stop = C.stop(17, -11, defines.direction.east, C.NAMES.provider, C.COL.provider)
  N.p_chests = C.loader(4.5, 9.5, -11.5, -10.5, -13)
  N.p_comb = C.controller({15.5, -11}, "station", {pr = 1})
  C.wire(N.p_chests[#N.p_chests], GREEN, N.p_comb, IN)
  C.fill(N.p_chests, N.item, N.o.stock or 9000)
end

-- Requester k: chests north of the bottom rail, inserters unload the wagon (south)
function C.net_requester(N, k)
  local d = C.REQ[k]
  local r = {k = k, request = N.o.request or 8000, threshold = N.o.threshold or 2000, priority = nil,
    consume = (k == 1 and N.o.consume or N.o.consume2) or 80}
  r.stop = C.stop(d.stop[1], d.stop[2], defines.direction.west, k == 1 and C.NAMES.requester or C.NAMES.requester2, C.COL.requester)
  r.chests = C.loader(d.x1, d.x2, 11.5, 10.5, 9.5)
  r.comb = C.controller(d.comb, "station", {pr = 2})
  r.const = C.constant(N.o.constant or "constant-combinator", d.const, {})
  C.wire(r.const, GREEN, r.comb, IN)
  C.wire(r.chests[1], GREEN, r.comb, IN)
  N.req[k] = r
  C.set_request(N, k, {})
  C.fill(r.chests, N.item, (k == 1 and N.o.start or N.o.start2) or 4000)
  return r
end

-- Rewrites the request combinator: the cargo with a minus sign, the threshold and the priority (if set)
function C.set_request(N, k, o)
  local r = N.req[k]
  for key, value in pairs(o) do r[key] = value end
  local signals = {{"item", N.item, -r.request}, {"virtual", "cybersyn-request-threshold", r.threshold}}
  if r.priority then signals[#signals + 1] = {"virtual", "cybersyn-priority", r.priority} end
  C.set_signals(r.const, signals)
end

function C.net_refueler(N)
  N.f_stop = C.stop(3, 11, defines.direction.west, C.NAMES.refueler, C.COL.refuel)
  N.f_chests = C.loader(4.5, 5.5, 11.5, 10.5, 13.5, "wooden-chest")
  N.f_comb = C.controller({1.5, 11}, "refueler")
  C.fill(N.f_chests, "coal", 1000)
end

function C.net_train(N, o)
  o = o or {}
  N.loco = C.train(N.depot, {"locomotive", "cargo-wagon"}, {depot = C.NAMES.depot, fuel = o.fuel or N.o.fuel or 1200, back = o.back})
  N.tracked = C.track(N.loco)
end

function C.network(o)
  local N = C.net_base(o)
  C.net_depot(N)
  C.net_provider(N)
  C.net_requester(N, 1)
  if N.o.second then C.net_requester(N, 2) end
  if N.o.refueler then C.net_refueler(N) end
  C.net_train(N)
  return N
end

-- Mining at the provider and consumption at the requesters, every 30 ticks
function C.economy(N, t)
  if t % 30 ~= 0 then return end
  local o = N.o
  if N.p_chests then
    local have = C.count(N.p_chests, N.item)
    local cap = o.stock_cap or 12000
    if have < cap then C.fill(N.p_chests, N.item, math.min(cap - have, math.floor((o.refill or 400) / 2))) end
  end
  for _, r in pairs(N.req) do C.drain(r.chests, N.item, math.floor(r.consume / 2)) end
  if N.f_chests then
    local coal = C.count(N.f_chests, "coal")
    if coal < 800 then C.fill(N.f_chests, "coal", 800 - coal) end
  end
end

-- Station names next to the stations
function C.label(N, kind)
  local scale = 1.6
  if kind == "depot" then
    C.text({-6, -8.8}, {"zzz-cybersyn-sim.depot"}, {scale = scale, color = C.COL.depot})
  elseif kind == "provider" then
    C.text({7, -8.8}, {"zzz-cybersyn-sim.provider"}, {scale = scale, color = C.COL.provider})
  elseif kind == "requester" then
    C.text(C.REQ[1].label, N.req[2] and {"zzz-cybersyn-sim.requester-n", 1} or {"zzz-cybersyn-sim.requester"}, {scale = scale, color = C.COL.requester})
  elseif kind == "requester2" then
    C.text(C.REQ[2].label, {"zzz-cybersyn-sim.requester-n", 2}, {scale = scale, color = C.COL.requester})
  elseif kind == "refueler" then
    C.text({5, 8.8}, {"zzz-cybersyn-sim.refueler"}, {scale = scale, color = C.COL.refuel})
  end
end

function C.labels(N)
  if N.depot then C.label(N, "depot") end
  if N.p_stop then C.label(N, "provider") end
  if N.req[1] then C.label(N, "requester") end
  if N.req[2] then C.label(N, "requester2") end
  if N.f_stop then C.label(N, "refueler") end
end

function C.stock_text(N)
  local r = N.req[1]
  return {"zzz-cybersyn-sim.stock", "[item=" .. N.item .. "]", N.p_chests and C.count(N.p_chests, N.item) or 0,
    C.count(r.chests, N.item), r.request, C.stats.deliveries}
end
]=]

local function simulation(body, extra)
    local definition = {init = PRELUDE .. body}
    for key, value in pairs(extra or {}) do definition[key] = value end
    return definition
end

-- Scenes with trains run the real Cybersyn script.
local function live(body, extra)
    extra = extra or {}
    extra.mods = {"cybersyn"}
    return simulation(body, extra)
end

local simulations = {}

-- 1. Быстрый старт: сеть собирается по шагам (депо и поезд, снабжение, запрос), потом поезд возит сам.
simulations.quickstart = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.net_base{start = 2000, consume = 80}
  C.board(-15, -3.9, 15, 3.9)
  local lines = {}
  for i = 1, 4 do
    lines[i] = C.text({-14, -3.0 + (i - 1) * 1.5}, {"zzz-cybersyn-sim.quick-" .. i}, {scale = 1.45, align = "left", color = C.COL.dim})
  end
  local stock = C.text({-14, 3.0}, "", {scale = 1.3, align = "left"})
  local marks, current = {}, 0
  local function step(i, boxes)
    current = i
    C.quick_step = i
    for k, line in ipairs(lines) do
      line.color = k == i and C.COL.note or (k < i and C.COL.green or C.COL.dim)
    end
    for _, p in ipairs(marks) do C.unpulse(p) end
    marks = {}
    for _, b in ipairs(boxes) do marks[#marks + 1] = C.pulse(b[1], b[2], b[3]) end
  end
  C.after(40, function()
    C.net_depot(N)
    C.net_train(N, {back = 6})
    C.label(N, "depot")
    step(1, {{{-3.4, -12.3}, {0.2, -9.7}, C.COL.depot}})
  end)
  C.after(480, function()
    C.net_provider(N)
    C.label(N, "provider")
    step(2, {{{3.8, -12.3}, {10.2, -9.9}, C.COL.provider}, {{14.8, -12.2}, {16.2, -9.8}, C.COL.note}})
  end)
  C.after(900, function()
    C.net_requester(N, 1)
    C.label(N, "requester")
    step(3, {{{-10.2, 9.9}, {-3.8, 12.3}, C.COL.requester}, {{-16.2, 7.8}, {-14.8, 12.2}, C.COL.note}})
  end)
  C.on_status = function(tracked, old, new)
    if new == 1 and current == 3 then step(4, {}) end
  end
  C.main = function(t)
    if current >= 3 then
      C.economy(N, t)
      if t % 15 == 0 then stock.text = C.stock_text(N) end
    end
  end
end)
]=])

-- 2. Станционный контроллер: режимы у остановок, питание и расстояние, цвета буквы S. Картинка без скрипта мода.
simulations.controller = simulation([=[
C.scene(function()
  C.camera({1, 0.5}, 1)
  C.straight(-23, 25, 0)
  C.power({{-14, -3.5}, {-2, -4}, {8, -4}}, {3, -6.5})
  local function stop(x, name, color)
    return C.make("train-stop", {x, 2}, defines.direction.east, {station = name, color = color})
  end
  local function letter(letter_text, key)
    return {"", "[font=default-large-bold]" .. letter_text .. "[/font]  ", {key}}
  end
  local y1 = 4.7
  C.title({"zzz-cybersyn-sim.controller-title"}, -8.7, 1.3)
  -- Depot
  stop(-17, C.NAMES.depot, C.COL.depot)
  C.controller({-18.5, 2}, "depot", {register = false})
  C.text({-17.5, y1}, letter("D", "cybersyn-gui.depot"), {scale = 1.1})
  -- Too far from the depot stop
  C.controller({-13, 4}, "station", {register = false})
  C.line({-13.7, 3.3}, {-12.3, 4.7}, {1, 0.2, 0.2}, 5)
  C.line({-13.7, 4.7}, {-12.3, 3.3}, {1, 0.2, 0.2}, 5)
  C.text({-13, 6.3}, {"zzz-cybersyn-sim.too-far"}, {scale = 0.9, color = C.COL.red})
  -- Station with station control and a parked train with wagon control
  stop(3, C.NAMES.provider, C.COL.provider)
  local comb = C.controller({1.5, 2}, "station", {register = false})
  C.controller({4.5, 2}, "control", {register = false})
  C.make("locomotive", {-2, 0}, nil, {orientation = 0.25})
  C.make("cargo-wagon", {-9, 0}, nil, {orientation = 0.25})
  C.controller({-9, -2}, "wagon", {register = false})
  C.text({-8, -4.2}, letter("W", "cybersyn-gui.wagon-manifest"), {scale = 1.0})
  C.pulse({0.8, 0.8}, {5.2, 3.2}, C.COL.note)
  C.text({2, y1}, letter("S", "cybersyn-gui.comb1"), {scale = 1.1})
  local state = C.text({2, y1 + 1.4}, "", {scale = 1.0})
  C.text({5, y1 + 2.8}, letter("C", "cybersyn-gui.comb2"), {scale = 1.0})
  -- Refueler
  stop(12, C.NAMES.refueler, C.COL.refuel)
  C.controller({10.5, 2}, "refueler", {register = false})
  C.text({11.5, y1}, letter("R", "cybersyn-gui.refueler"), {scale = 1.1})
  -- A station without power: the letter still glows, but Cybersyn does not read its input
  stop(20, C.NAMES.requester, C.COL.requester)
  C.controller({18.5, 2}, "station", {register = false})
  C.sprite("utility/electricity_icon_unplugged", {18.5, 4.3}, 0.9)
  C.text({19.5, y1 + 1.4}, {"zzz-cybersyn-sim.no-power"}, {scale = 0.9, color = C.COL.red})
  C.text({1, 9.6}, {"zzz-cybersyn-sim.one-tile"}, {scale = 1.1, color = C.COL.green})
  local cycle = {{"station", "zzz-cybersyn-sim.s-blue"}, {"active", "zzz-cybersyn-sim.s-green"}, {"failed", "zzz-cybersyn-sim.s-red"}}
  local index = 0
  C.main = function(t)
    if t % 150 == 1 then
      index = index % #cycle + 1
      C.set_mode(comb, cycle[index][1])
      state.text = {cycle[index][2]}
    end
  end
end)
]=])

-- 3. Депо: пустой поезд входит в сеть, поезд с грузом задержан; груз убрали, поезд тоже в сети.
simulations.depot = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  C.net_base{}
  local name = C.NAMES.depot
  local top = C.stop(-1, -11, defines.direction.east, name, C.COL.depot, 1)
  C.controller({-2.5, -11}, "depot")
  local bottom = C.stop(3, 11, defines.direction.west, name, C.COL.depot, 1)
  C.controller({1.5, 11}, "depot")
  C.text({-6, -8.8}, {"zzz-cybersyn-sim.depot"}, {scale = 1.6, color = C.COL.depot})
  C.text({10, 8.8}, {"zzz-cybersyn-sim.depot"}, {scale = 1.6, color = C.COL.depot})
  C.board(-15, -3.9, 15, 3.9)
  C.text({-14, -2.4}, {"zzz-cybersyn-sim.depot-same-name", name}, {scale = 1.35, align = "left"})
  local note = C.text({-14, 0.2}, "", {scale = 1.35, align = "left", color = C.COL.note})
  local a, b
  local function spawn()
    a = C.train(top, {"locomotive", "cargo-wagon"}, {depot = name})
    C.track(a)
    b = C.train(bottom, {"locomotive", "cargo-wagon"}, {depot = name, back = 1, cargo = {name = "iron-ore", count = 600}})
    C.track(b)
    note.text = {"zzz-cybersyn-sim.depot-arrive"}
  end
  spawn()
  C.main = function(t)
    local cycle = t % 1500
    if cycle == 600 and b and b.valid then
      -- The player unloads the train and sends it to the depot again
      for _, car in ipairs(b.train.cargo_wagons) do car.get_inventory(defines.inventory.cargo_wagon).clear() end
      b.train.schedule = {current = 1, records = {{station = name, wait_conditions = {{type = "inactivity", compare_type = "and", ticks = 120}}}}}
      b.train.manual_mode = true
      note.text = {"zzz-cybersyn-sim.depot-unloaded"}
    elseif cycle == 602 and b and b.valid then
      b.train.manual_mode = false
    elseif cycle == 1499 then
      for _, tracked in ipairs(C.trains) do
        if tracked.label.valid then tracked.label.destroy() end
        if tracked.loco.valid then
          for _, car in ipairs(tracked.loco.train.carriages) do car.destroy{raise_destroy = true} end
        end
      end
      C.trains = {}
      C.after(30, spawn)
    end
    if cycle < 600 and t % 30 == 0 and b and b.valid and b.train.state == defines.train_state.wait_station then
      for _, tracked in ipairs(C.trains) do
        if tracked.loco == b and tracked.status == "none" and b.train.get_item_count() > 0 and tracked.label.valid then
          tracked.label.text = {"zzz-cybersyn-sim.status-held"}
        end
      end
    end
  end
end)
]=])

-- 4. Снабжение крупно: сундуки → вход контроллера (плюс = могу отдать), на выходе заказ поезда.
simulations.provider = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({6, -7.5}, 1.1)
  local N = C.network{start = 3000, consume = 80}
  C.label(N, "depot")
  C.label(N, "provider")
  C.board(-13, -3.8, 15, 1.9)
  local input = C.text({-12, -2.8}, "", {scale = 1.2, align = "left"})
  local output = C.text({-12, -1.2}, "", {scale = 1.2, align = "left"})
  C.text({-12, 0.6}, {"zzz-cybersyn-sim.provider-rule"}, {scale = 1.1, align = "left", color = C.COL.note})
  C.pulse({3.8, -12.3}, {10.2, -9.9}, C.COL.provider)
  C.pulse({14.8, -12.2}, {16.2, -9.8}, C.COL.note)
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      input.text = {"zzz-cybersyn-sim.comb-input", C.signal_text(C.signals_of(N.p_comb, C.INPUTS))}
      output.text = {"zzz-cybersyn-sim.comb-output", C.signal_text(C.signals_of(N.p_comb, C.OUTPUTS))}
    end
  end
end)
]=])

-- 5. Запрос крупно: заявка −8000 и порог в комбинаторе заявок, сундуки, сумма на входе, груз в пути.
simulations.requester = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({-6, 7.5}, 1.1)
  local N = C.network{start = 6500, consume = 90, constant = "cybersyn-constant-combinator"}
  C.label(N, "requester")
  local r = N.req[1]
  C.board(-15, -1.9, 13, 3.9)
  local sum = C.text({-14, -0.9}, "", {scale = 1.2, align = "left"})
  local transit = C.text({-14, 0.7}, "", {scale = 1.2, align = "left"})
  local verdict = C.text({-14, 2.4}, "", {scale = 1.2, align = "left", color = C.COL.note})
  C.pulse({-10.2, 9.9}, {-3.8, 12.3}, C.COL.requester)
  C.pulse({-16.2, 7.8}, {-14.8, 9.2}, C.COL.note)
  C.text({-15.5, 6.9}, {"zzz-cybersyn-sim.request-combinator"}, {scale = 1.0, color = C.COL.note})
  local icon = "[item=" .. N.item .. "]"
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      local have = C.count(r.chests, N.item)
      local coming = C.in_transit(r.stop, N.item)
      local missing = math.max(0, r.request - have - coming)
      sum.text = {"zzz-cybersyn-sim.request-sum", icon, -r.request, have, have - r.request}
      transit.text = {"zzz-cybersyn-sim.request-transit", coming, missing, r.threshold}
      verdict.text = {missing >= r.threshold and "zzz-cybersyn-sim.request-yes" or "zzz-cybersyn-sim.request-no"}
    end
  end
end)
]=])

-- 6. Порог запроса: шкала склада, линия порога, момент вызова поезда.
simulations.threshold = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 7600, consume = 90}
  C.labels(N)
  local r = N.req[1]
  C.board(-15, -3.9, 15, 3.9)
  local left, top, width, height = -12, -1.9, 24, 1.2
  C.rect({left, top}, {left + width, top + height}, {0.12, 0.12, 0.12, 1})
  local fill = C.rect({left, top}, {left, top + height}, {0.3, 0.55, 1, 1})
  local coming = C.rect({left, top}, {left, top + height}, {0.3, 0.55, 1, 0.45})
  local x_threshold = left + width * (r.request - r.threshold) / r.request
  C.line({x_threshold, top - 0.5}, {x_threshold, top + height + 0.5}, {1, 0.85, 0.2}, 4)
  C.text({x_threshold, top - 1.1}, {"zzz-cybersyn-sim.threshold-line", r.threshold}, {scale = 1.25, color = {1, 0.85, 0.2}})
  C.text({left + width, top - 1.1}, {"zzz-cybersyn-sim.threshold-full", r.request}, {scale = 1.15, align = "right"})
  C.text({left, top - 1.1}, "0", {scale = 1.15, align = "left"})
  local value = C.text({0, top + height + 1.1}, "", {scale = 1.35})
  local verdict = C.text({0, top + height + 2.6}, "", {scale = 1.35, color = C.COL.note})
  local icon = "[item=" .. N.item .. "]"
  C.main = function(t)
    C.economy(N, t)
    if t % 10 == 0 then
      local have = C.count(r.chests, N.item)
      local transit = C.in_transit(r.stop, N.item)
      local a = math.max(0, math.min(1, have / r.request))
      local b = math.max(0, math.min(1, (have + transit) / r.request))
      fill.right_bottom = {left + width * a, top + height}
      coming.left_top = {left + width * a, top}
      coming.right_bottom = {left + width * b, top + height}
      local missing = math.max(0, r.request - have - transit)
      value.text = {"zzz-cybersyn-sim.threshold-value", icon, have, transit, missing}
      if transit > 0 then
        verdict.text = {"zzz-cybersyn-sim.threshold-busy"}
      elseif missing >= r.threshold then
        verdict.text = {"zzz-cybersyn-sim.threshold-call"}
      else
        verdict.text = {"zzz-cybersyn-sim.threshold-wait", r.threshold - missing}
      end
    end
  end
end)
]=])

-- 7. Как сеть выбирает: один поезд, две станции запроса; приоритет 1 и 0, потом равные (по очереди).
simulations.delivery = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  -- The requests are larger than a train load plus the threshold: even while a train unloads (its cargo counts as
  -- on the way) both stations keep requesting, so only the priority decides
  local N = C.network{second = true, request = 12000, start = 3000, start2 = 5000, consume = 200, consume2 = 100,
    stock = 16000, stock_cap = 20000, refill = 700}
  C.labels(N)
  C.board(-15, -3.9, 15, 3.9)
  local title = C.text({-14, -3.0}, "", {scale = 1.35, align = "left", color = C.COL.note})
  local rows = {C.text({-14, -1.4}, "", {scale = 1.3, align = "left"}), C.text({-14, 0.1}, "", {scale = 1.3, align = "left"})}
  local going = C.text({-14, 1.6}, "", {scale = 1.3, align = "left"})
  C.text({-14, 3.0}, {"zzz-cybersyn-sim.choice-red"}, {scale = 1.1, align = "left", color = C.COL.red})
  C.choice = {phase = 1, total = {{0, 0}, {0, 0}}}
  local counts = {0, 0}
  local function set_phase(p)
    C.choice.phase = p
    counts = {0, 0}
    local priority = p == 1 and {1, 0} or {0, 0}
    for k = 1, 2 do C.set_request(N, k, {priority = priority[k]}) end
    title.text = {"zzz-cybersyn-sim.choice-phase-" .. p}
    going.text = ""
  end
  set_phase(1)
  C.on_status = function(tracked, old, new)
    if new ~= 1 then return end
    local id = remote.call("cybersyn", "read_global", "trains", tracked.loco.train.id, "r_station_id")
    for k, r in ipairs(N.req) do
      if r.stop.unit_number == id then
        counts[k] = counts[k] + 1
        local total = C.choice.total[C.choice.phase]
        total[k] = total[k] + 1
        going.text = {"zzz-cybersyn-sim.choice-going", k}
      end
    end
  end
  C.main = function(t)
    C.economy(N, t)
    if t % 3000 == 0 then set_phase(3 - C.choice.phase) end
    if t % 15 == 0 then
      for k, r in ipairs(N.req) do
        rows[k].text = {"zzz-cybersyn-sim.choice-row", k, "[virtual-signal=cybersyn-priority]", r.priority or 0,
          C.count(r.chests, N.item), counts[k]}
      end
    end
  end
end)
]=])

-- 8. После доставки: через раз поезд возвращается почти без топлива и заезжает на заправку,
-- в остальные разы сразу берёт новый заказ (обход депо). Завод забирает груз, как только поезд свободен.
simulations.bypass = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{refueler = true, start = 5000, consume = 0}
  C.labels(N)
  local r = N.req[1]
  C.board(-15, -3.9, 15, 3.9)
  local fuel = C.text({-14, -2.8}, "", {scale = 1.35, align = "left"})
  local bypass = C.text({-14, -1.2}, "", {scale = 1.35, align = "left", color = C.COL.note})
  local refuel = C.text({-14, 0.4}, "", {scale = 1.35, align = "left", color = C.COL.refuel})
  C.text({-14, 2.4}, {"zzz-cybersyn-sim.bypass-hint"}, {scale = 1.1, align = "left"})
  local unloads = 0
  C.on_status = function(tracked, old, new)
    if new == 4 and N.loco.valid then
      -- Every second delivery the train comes back nearly without fuel
      unloads = unloads + 1
      local inventory = N.loco.get_fuel_inventory()
      inventory.clear()
      inventory.insert{name = "coal", count = unloads % 2 == 1 and 150 or 1200}
    end
    if new == 6 and (old == 4 or old == 8) then
      -- The train is free after unloading or refueling, and the factory takes the cargo:
      -- the requester needs a train again right away
      C.drain(r.chests, N.item, 3000)
    end
  end
  local function fuel_share()
    local inventory = N.loco.get_fuel_inventory()
    local total = 0
    for i = 1, #inventory do
      local stack = inventory[i]
      if stack.valid_for_read then total = total + stack.count / stack.prototype.stack_size end
    end
    return total / #inventory
  end
  C.main = function(t)
    C.economy(N, t)
    if t % 10 == 0 and N.loco.valid then
      fuel.text = {"zzz-cybersyn-sim.fuel", "[item=coal]", math.floor(fuel_share() * 100 + 0.5)}
      bypass.text = {"zzz-cybersyn-sim.bypass-count", C.stats.bypass, C.stats.depot}
      refuel.text = {"zzz-cybersyn-sim.refuel-count", C.stats.refuel}
    end
  end
end)
]=])

-- 9. Сети и подсети: сначала сети A/B для поездов разной длины, потом маски подсетей. Схема.
simulations.networks = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  -- phase_id grows with every phase: delayed calls of an earlier round see a changed id and stop
  local phase_id, kind, group = 0, 0, nil
  C.phases_seen = {}
  local function begin(k)
    C.clear(group)
    C.movers = {}
    group = {}
    C.group = group
    phase_id = phase_id + 1
    kind = k
    C.phases_seen[k] = true
  end
  -- Networks A and B
  local X = {depot = -15, provider = -2, requester = 12}
  local lanes = {
    {y = -3.5, signal = "signal-A", color = {0.35, 0.9, 0.4}, cars = 1},
    {y = 4.5, signal = "signal-B", color = {0.4, 0.6, 1}, cars = 2},
  }
  local function train_sprites(cars)
    local list = {{sprite = "item/locomotive", offset = {0, 0}, scale = 1.8}}
    for i = 1, cars do list[#list + 1] = {sprite = "item/cargo-wagon", offset = {-1.9 * i, 0}, scale = 1.8} end
    return list
  end
  local function run(lane, id)
    if phase_id ~= id then return end
    local y = lane.y - 2.7
    local token = C.token(train_sprites(lane.cars), {X.depot, y})
    C.path(token, {{X.provider, y}, {X.requester, y}, {X.depot, y}}, 70, function(t)
      C.destroy(t)
      C.after(20, function() run(lane, id) end)
    end)
  end
  local function networks()
    begin(1)
    C.title({"zzz-cybersyn-sim.networks-title"}, -9.2, 1.4)
    for _, lane in ipairs(lanes) do
      local net = "[virtual-signal=" .. lane.signal .. "]"
      C.box(X.depot, lane.y, 6, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.depot"}}, 1.1)
      C.box(X.provider, lane.y, 7, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.provider"}}, 1.1)
      C.box(X.requester, lane.y, 7, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.requester"}}, 1.1)
      C.line({X.depot + 3, lane.y}, {X.provider - 3.5, lane.y}, {lane.color[1], lane.color[2], lane.color[3], 0.5}, 3, 0.4)
      C.line({X.provider + 3.5, lane.y}, {X.requester - 3.5, lane.y}, {lane.color[1], lane.color[2], lane.color[3], 0.5}, 3, 0.4)
      C.text({X.requester + 5, lane.y}, {"zzz-cybersyn-sim.train-length-" .. lane.cars}, {scale = 1.0, color = lane.color, align = "left"})
    end
    local id = phase_id
    run(lanes[1], id)
    C.after(35, function() run(lanes[2], id) end)
    C.after(260, function()
      if phase_id ~= id then return end
      C.arrow({X.depot + 2, lanes[2].y - 1.6}, {X.requester - 3.6, lanes[1].y + 1.6}, {1, 0.3, 0.3, 1}, 4)
      C.sprite("virtual-signal/signal-deny", {(X.depot + X.requester) / 2 - 1.5, 0.4}, 1.6)
      C.text({(X.depot + X.requester) / 2 + 3, 1.0}, {"zzz-cybersyn-sim.networks-wrong"}, {scale = 1.0, color = C.COL.red, align = "left"})
    end)
  end
  -- Sub-network masks
  local stations = {
    {x = -13, y = -2.5, mask = 1, name = "1"},
    {x = 0, y = -2.5, mask = 5, name = "2"},
    {x = 13, y = -2.5, mask = 4, name = "3"},
  }
  local function bits(x, y, mask, highlight)
    for b = 0, 3 do
      local on = bit32.btest(mask, bit32.lshift(1, b))
      local cx = x + 2.25 - b * 1.5
      C.rect({cx - 0.6, y - 0.6}, {cx + 0.6, y + 0.6}, on and (highlight or {0.35, 0.9, 0.4, 1}) or {0.15, 0.15, 0.15, 1})
      C.text({cx, y}, on and "1" or "0", {scale = 1.0})
    end
  end
  local pair_objects, pair_index = {}, 0
  local result
  local function masks()
    begin(2)
    C.title({"zzz-cybersyn-sim.masks-title"}, -9.2, 1.4)
    C.text({0, -7.2}, {"zzz-cybersyn-sim.masks-hint"}, {scale = 1.0, color = C.COL.note})
    for _, s in ipairs(stations) do
      C.box(s.x, s.y, 10, 5, {0.6, 0.6, 0.6}, nil)
      C.text({s.x, s.y - 1.3}, {"zzz-cybersyn-sim.mask-station", s.name, "[virtual-signal=signal-A]", s.mask}, {scale = 1.05})
      bits(s.x, s.y + 0.9, s.mask)
    end
    C.text({-2.4, 4.6}, {"zzz-cybersyn-sim.masks-and"}, {scale = 1.05, align = "right"})
    result = C.text({0, 7.8}, "", {scale = 1.1})
    pair_objects, pair_index = {}, 0
  end
  local pairs_list = {{1, 2}, {2, 3}, {1, 3}}
  local function next_pair()
    C.clear(pair_objects)
    pair_objects = {}
    C.group = pair_objects
    pair_index = pair_index % #pairs_list + 1
    local a, b = stations[pairs_list[pair_index][1]], stations[pairs_list[pair_index][2]]
    local both = bit32.band(a.mask, b.mask)
    local ok = both ~= 0
    -- The pair is framed; lines lead from it to the bits both masks share
    local color = ok and {0.35, 1, 0.4, 1} or {1, 0.3, 0.3, 1}
    for _, s in ipairs({a, b}) do
      C.rect({s.x - 5.2, s.y - 2.7}, {s.x + 5.2, s.y + 2.7}, color, false, 5)
      C.line({s.x, s.y + 2.7}, {1, 3.6}, color, 3, ok and 0 or 0.5)
    end
    bits(1, 4.6, both, {1, 0.85, 0.25, 1})
    C.sprite(ok and "virtual-signal/signal-check" or "virtual-signal/signal-deny", {5.4, 4.6}, 1.2)
    C.group = group
    result.text = {"zzz-cybersyn-sim.masks-result-" .. (ok and "yes" or "no"), a.name, b.name, a.mask, b.mask, both}
  end
  networks()
  C.main = function(t)
    local cycle = t % 1500
    if cycle == 0 then
      C.clear(pair_objects)
      pair_objects = {}
      networks()
    elseif cycle == 600 then
      masks()
    end
    if kind == 2 and (cycle - 600) % 220 == 1 then next_pair() end
  end
end)
]=])

-- 10. Список разрешённых поездов: манипуляторы у одного вагона, поезд 1-1 проходит, 1-2 нет. Картинка.
simulations.allow_list = simulation([=[
C.scene(function()
  C.camera({-2, 0.5}, 0.9)
  C.title({"zzz-cybersyn-sim.allow-title"}, -10.2, 1.4)
  C.power({{6, 0}}, {10, 0})
  local rows = {{y = -5, cars = {"locomotive", "cargo-wagon"}}, {y = 5, cars = {"locomotive", "cargo-wagon", "cargo-wagon"}}}
  for _, row in ipairs(rows) do
    C.straight(-31, 23, row.y)
    local sx = 13
    C.make("train-stop", {sx, row.y + 2}, defines.direction.east, {color = C.COL.provider})
    C.controller({sx - 1.5, row.y + 2}, "station", {register = false})
    for x = sx - 12.5, sx - 7.5 do
      C.inserter("bulk-inserter", {x, row.y - 1.5}, row.y)
      C.make("iron-chest", {x, row.y - 2.5})
    end
    C.pulse({sx - 13.2, row.y - 3.2}, {sx - 6.8, row.y - 0.9}, C.COL.note)
    for i, name in ipairs(row.cars) do
      local x = sx - 3 - 7 * (i - 1)
      C.make(name, {x, row.y}, nil, {orientation = 0.25})
      local ok = name == "locomotive" or i == 2
      C.sprite(ok and "virtual-signal/signal-check" or "virtual-signal/signal-deny", {x, row.y + 2.4}, 1.0)
    end
    local fits = #row.cars == 2
    local layout = ""
    for _, name in ipairs(row.cars) do layout = layout .. "[item=" .. name .. "]" end
    C.text({-25, row.y - 2.4}, {"", layout, "  ", {fits and "zzz-cybersyn-sim.allow-yes" or "zzz-cybersyn-sim.allow-no"}},
      {scale = 1.1, align = "left", color = fits and C.COL.green or C.COL.red})
  end
  C.board(-25, -1.3, 1, 1.3)
  C.text({-24, 0}, {"zzz-cybersyn-sim.allow-hint"}, {scale = 1.1, align = "left", color = C.COL.note})
end)
]=])

-- 11. Жидкости: цистерна и насосы у станций; запасы баков изображены сигналами постоянных комбинаторов.
simulations.fluids = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local fluid = "crude-oil"
  local N = C.net_base{}
  C.net_depot(N)
  -- Provider: pumps fill the fluid wagon from an endless source (the tank farm of the scene)
  C.stop(17, -11, defines.direction.east, "[fluid=crude-oil][virtual-signal=up-arrow]", C.COL.provider)
  for _, x in ipairs({9.5, 7.5, 5.5}) do
    C.make("pump", {x, -11}, defines.direction.north)
    C.make("infinity-pipe", {x, -9.5}, nil, {infinity_settings = {name = fluid, percentage = 1, mode = "at-least", temperature = 25}})
  end
  local p_comb = C.controller({15.5, -11}, "station", {pr = 1})
  local p_const = C.constant("constant-combinator", {15.5, -8.5}, {})
  C.wire(p_const, C.GREEN, p_comb, C.IN)
  -- Requester: pumps empty the fluid wagon into the consumers
  C.stop(-17, 11, defines.direction.west, "[fluid=crude-oil][virtual-signal=down-arrow]", C.COL.requester)
  for _, x in ipairs({-9.5, -7.5, -5.5}) do
    C.make("pump", {x, 11}, defines.direction.north)
    C.make("infinity-pipe", {x, 9.5}, nil, {infinity_settings = {name = fluid, percentage = 0, mode = "at-most", temperature = 25}})
  end
  local r_comb = C.controller({-15.5, 11}, "station", {pr = 2})
  local r_const = C.constant("constant-combinator", {-15.5, 8.5}, {})
  C.wire(r_const, C.GREEN, r_comb, C.IN)
  local loco = C.train(N.depot, {"locomotive", "fluid-wagon"}, {depot = C.NAMES.depot})
  C.track(loco)
  local request, threshold = 50000, 15000
  local stock, level, carried = 80000, 30000, 0
  C.text({-6, -8.8}, {"zzz-cybersyn-sim.depot"}, {scale = 1.6, color = C.COL.depot})
  C.text({7, -7.6}, {"zzz-cybersyn-sim.fluid-provider"}, {scale = 1.5, color = C.COL.provider})
  C.text({-7, 7.6}, {"zzz-cybersyn-sim.fluid-requester"}, {scale = 1.5, color = C.COL.requester})
  C.board(-15, -3.9, 15, 3.9)
  local panel1 = C.text({-14, -2.6}, "", {scale = 1.35, align = "left"})
  local panel2 = C.text({-14, -0.6}, "", {scale = 1.35, align = "left"})
  local panel3 = C.text({-14, 1.4}, "", {scale = 1.35, align = "left"})
  local icon = "[fluid=" .. fluid .. "]"
  local function wagon_fluid()
    if not loco.valid then return 0 end
    local total = 0
    for _, wagon in ipairs(loco.train.fluid_wagons) do total = total + wagon.get_fluid_count(fluid) end
    return total
  end
  C.on_status = function(tracked, old, new)
    if old == 2 and new == 3 then stock = stock - wagon_fluid() end
    if old == 3 and new == 4 then carried = wagon_fluid() end
    if old == 4 then level = level + carried carried = 0 end
  end
  C.main = function(t)
    if t % 30 == 0 then
      stock = math.min(120000, stock + 1200)
      level = math.max(0, level - 600)
      C.set_signals(p_const, {{"fluid", fluid, math.floor(stock)}})
      C.set_signals(r_const, {{"fluid", fluid, math.floor(level - request)}, {"virtual", "cybersyn-fluid-request-threshold", threshold}})
      panel1.text = {"zzz-cybersyn-sim.fluid-stock", icon, math.floor(stock)}
      panel2.text = {"zzz-cybersyn-sim.fluid-level", icon, math.floor(level), request, threshold}
      panel3.text = {"zzz-cybersyn-sim.fluid-wagon", icon, math.floor(wagon_fluid())}
    end
  end
end)
]=])

-- 12. Для опытных: заказ из нескольких грузов по ячейкам вагона, затем W и C. Схема.
simulations.multi = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  local phase_id, group = 0, nil
  C.phases_seen = {}
  local function begin(id)
    C.clear(group)
    group = {}
    C.group = group
    phase_id = id
    C.phases_seen[id] = true
  end
  -- Phase 1: one order of three cargos in a 20-slot wagon with 2 locked slots
  local slots, locked, cols = 20, 2, 10
  local manifest = {{"iron-plate", 7}, {"copper-plate", 6}, {"steel-plate", 5}}
  local cells, filled
  local function slots_phase()
    begin(1)
    C.title({"zzz-cybersyn-sim.multi-title"}, -9.2, 1.4)
    cells, filled = {}, 0
    for i = 1, slots do
      local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
      local x, y = -11.25 + col * 2.5, -4.5 + row * 2.5
      cells[i] = {x = x, y = y}
      -- Only a frame: render shapes are drawn over sprites, a filled cell would hide the item
      C.rect({x - 1.1, y - 1.1}, {x + 1.1, y + 1.1}, {0.5, 0.5, 0.5, 1}, false, 2)
      if i > slots - locked then
        C.line({x - 0.8, y - 0.8}, {x + 0.8, y + 0.8}, {1, 0.3, 0.3}, 4)
        C.line({x - 0.8, y + 0.8}, {x + 0.8, y - 0.8}, {1, 0.3, 0.3}, 4)
      end
    end
    C.sprite("item/cargo-wagon", {-15.6, -3.25}, 1.6)
    local text = {""}
    for _, m in ipairs(manifest) do text[#text + 1] = "[item=" .. m[1] .. "]×" .. m[2] .. "   " end
    C.text({0, 1.4}, {"zzz-cybersyn-sim.multi-order", text}, {scale = 1.2, color = C.COL.note})
    C.text({0, 3.2}, {"zzz-cybersyn-sim.multi-locked", locked, "[virtual-signal=cybersyn-locked-slots]", slots - locked}, {scale = 1.1})
    C.text({0, 5.0}, {"zzz-cybersyn-sim.multi-inactive"}, {scale = 1.1})
  end
  -- Phase 2: wagon control (W) and station control (C)
  local function control_phase()
    begin(2)
    C.title({"zzz-cybersyn-sim.control-title"}, -9.2, 1.4)
    local orders = {"[item=iron-plate]×3200", "[item=copper-plate]×2400", "[item=steel-plate]×2000"}
    C.sprite("item/locomotive", {-14, -4}, 1.6)
    for i = 1, 3 do
      local x = -14 + 5.5 * i
      C.sprite("item/cargo-wagon", {x, -4}, 1.6)
      C.box(x, -0.6, 4.6, 2.2, {0.55, 0.75, 1}, {"", "[font=default-large-bold]W[/font]  ", orders[i]}, 0.9)
      C.arrow({x, -1.8}, {x, -3.0}, {0.55, 0.75, 1, 1}, 3)
    end
    C.text({-11.5, 1.6}, {"zzz-cybersyn-sim.control-w"}, {scale = 1.05, align = "left"})
    C.box(-7, 5.2, 8, 3, {1, 0.85, 0.3}, {"", "[font=default-large-bold]C[/font]  ", {"cybersyn-gui.comb2"}}, 0.95)
    C.arrow({-15, 5.2}, {-11.2, 5.2}, {1, 0.85, 0.3, 1}, 3)
    C.arrow({-2.8, 5.2}, {1, 5.2}, {1, 0.85, 0.3, 1}, 3)
    C.text({-15.5, 3.4}, {"zzz-cybersyn-sim.control-in"}, {scale = 1.0, align = "left"})
    C.text({1.5, 4.5}, {"zzz-cybersyn-sim.control-out-1"}, {scale = 1.0, align = "left"})
    C.text({1.5, 5.9}, {"zzz-cybersyn-sim.control-out-2"}, {scale = 1.0, align = "left"})
  end
  slots_phase()
  C.main = function(t)
    local cycle = t % 1200
    if cycle == 0 then slots_phase() elseif cycle == 600 then control_phase() end
    if phase_id == 1 and t % 15 == 0 then
      local total = 0
      for _, m in ipairs(manifest) do total = total + m[2] end
      if filled < total then
        filled = filled + 1
        local acc, item = 0, nil
        for _, m in ipairs(manifest) do
          acc = acc + m[2]
          if filled <= acc then item = m[1] break end
        end
        local cell = cells[filled]
        C.sprite("item/" .. item, {cell.x, cell.y}, 0.9)
      end
    end
  end
end)
]=])

-- 13. Если поезда не едут: порог больше вместимости поезда, красная S; порог исправили, поезд поехал.
simulations.problems = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 0, consume = 0, request = 10000, threshold = 9000, stock = 12000}
  C.labels(N)
  local r = N.req[1]
  C.board(-15, -3.9, 15, 3.9)
  local state = C.text({-14, -2.4}, "", {scale = 1.5, align = "left"})
  local reason = C.text({-14, -0.3}, "", {scale = 1.3, align = "left", color = C.COL.note})
  C.text({-14, 2.2}, {"zzz-cybersyn-sim.problem-hint"}, {scale = 1.1, align = "left"})
  local mark = C.pulse({-16.2, 7.8}, {-14.8, 12.2}, C.COL.red)
  local bad = true
  C.main = function(t)
    C.economy(N, t)
    local cycle = t % 2400
    if cycle == 900 then
      bad = false
      C.set_request(N, 1, {threshold = 2000})
    elseif cycle == 0 then
      bad = true
      C.set_request(N, 1, {threshold = 9000})
      C.drain(r.chests, N.item, C.count(r.chests, N.item))
    end
    if t % 10 == 0 then
      local mode = C.mode_of(r.comb)
      if mode == C.MODE.failed then
        state.text = {"zzz-cybersyn-sim.problem-red"}
      elseif mode == C.MODE.active then
        state.text = {"zzz-cybersyn-sim.problem-green"}
      else
        state.text = {"zzz-cybersyn-sim.problem-blue"}
      end
      mark.color = bad and C.COL.red or C.COL.green
      reason.text = bad and {"zzz-cybersyn-sim.problem-capacity", r.threshold, N.capacity} or {"zzz-cybersyn-sim.problem-fixed", r.threshold}
    end
  end
end)
]=])

return simulations
