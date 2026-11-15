-- Анимации к «Советам и подсказкам» о диспетчерской сети поездов (prototypes/tips-and-tricks/cybersyn/cybersyn.lua).
-- Каждая симуляция = общий пролог C + своя сцена. Сцены с поездами запускают настоящий скрипт Cybersyn
-- (поле mods = {"cybersyn"}): доставки, заправку и обход депо назначает сам мод, сцена только строит станции,
-- изображает добычу и расход груза и подписывает происходящее. Схемы (сети, маски, приоритет, ячейки вагона)
-- нарисованы. Любая ошибка сцены выводится текстом в окне симуляции (ключ zzz-cybersyn-sim.error).

local PRELUDE = [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
C = {t = 0, jobs = {}, movers = {}, trains = {}, stats = {dispatch = 0, deliveries = 0, bypass = 0, refuel = 0}}
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
  if remote.interfaces["cybersyn"] then return true end
  C.fail({"zzz-cybersyn-sim.no-script"})
  return false
end

function C.setting(key, value) remote.call("cybersyn", "write_setting", key, value) end

function C.status_of(train)
  if not (train and train.valid) then return nil end
  return remote.call("cybersyn", "read_global", "trains", train.id, "status")
end

-- Drawing ------------------------------------------------------------------------------------------
function C.text(position, text, o)
  o = o or {}
  return rendering.draw_text{text = text, surface = surface, target = position, color = o.color or {1, 1, 1},
    scale = o.scale or 1, font = o.font or "default-bold", alignment = o.align or "center",
    vertical_alignment = o.valign or "middle", use_rich_text = true}
end

function C.rect(left_top, right_bottom, color, filled, width)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = width or 2}
end

function C.line(from, to, color, width, dash)
  return rendering.draw_line{surface = surface, from = from, to = to, color = color, width = width or 3,
    dash_length = dash or 0, gap_length = dash or 0}
end

function C.sprite(sprite, position, scale, tint)
  return rendering.draw_sprite{sprite = sprite, surface = surface, target = position, x_scale = scale or 1,
    y_scale = scale or 1, tint = tint}
end

-- Box with a title: a station, a train or a combinator of a scheme
function C.box(x, y, w, h, color, title, scale)
  local back = C.rect({x - w / 2, y - h / 2}, {x + w / 2, y + h / 2}, {color[1] * 0.25, color[2] * 0.25, color[3] * 0.25, 0.85})
  local frame = C.rect({x - w / 2, y - h / 2}, {x + w / 2, y + h / 2}, color, false, 3)
  local label = title and C.text({x, y}, title, {scale = scale or 1}) or nil
  return {back = back, frame = frame, label = label, x = x, y = y}
end

function C.title(text, y, scale)
  return C.text({C.cam[1], y}, text, {scale = scale or 1.6, color = {1, 0.9, 0.6}})
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

-- Substations at the points, wired together, and an energy interface
function C.power(points, interface)
  local poles = {}
  for i, p in ipairs(points) do
    poles[i] = C.make("substation", p)
    if i > 1 then
      pcall(function()
        local id = defines.wire_connector_id.pole_copper
        poles[i - 1].get_wire_connector(id, true).connect_to(poles[i].get_wire_connector(id, true), false)
      end)
    end
  end
  C.make("electric-energy-interface", interface)
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
  if o.color then loco.color = o.color end
  if o.cargo then
    for i, car in ipairs(carriages) do
      if car.type == "cargo-wagon" then car.get_inventory(defines.inventory.cargo_wagon).insert(o.cargo) end
    end
  end
  if o.depot then
    loco.train.schedule = {current = 1, records = {{station = o.depot, wait_conditions = {{type = "inactivity", compare_type = "and", ticks = 120}}}}}
    loco.train.manual_mode = false
  end
  return loco, carriages
end

-- Status label over a locomotive; C.poll follows the Cybersyn status and calls C.on_status(train, old, new)
function C.track(loco, name)
  local tracked = {loco = loco, status = "none", name = name}
  tracked.label = rendering.draw_text{text = {"zzz-cybersyn-sim.status-none"}, surface = surface,
    target = {entity = loco, offset = {0, -2.6}}, color = {1, 1, 0.75}, scale = 1.7, font = "default-bold",
    alignment = "center", vertical_alignment = "middle", use_rich_text = true}
  C.trains[#C.trains + 1] = tracked
  return tracked
end

function C.poll()
  if not remote.interfaces["cybersyn"] then return end
  for _, tracked in ipairs(C.trains) do
    if tracked.loco.valid then
      local status = C.status_of(tracked.loco.train) or "none"
      if status ~= tracked.status then
        local old = tracked.status
        tracked.status = status
        if tracked.label.valid then tracked.label.text = {"zzz-cybersyn-sim.status-" .. status} end
        if old == 0 and status == 1 then C.stats.dispatch = C.stats.dispatch + 1 end
        if old == 6 and status == 1 then C.stats.bypass = C.stats.bypass + 1 end
        if old == 4 and status ~= 4 then C.stats.deliveries = C.stats.deliveries + 1 end
        if status == 7 then C.stats.refuel = C.stats.refuel + 1 end
        if C.on_status then C.on_status(tracked, old, status) end
      end
    end
  end
end

function C.cargo(loco)
  if not loco.valid then return 0 end
  return loco.train.get_item_count()
end

-- The network of the big scenes ---------------------------------------------------------------------
-- Loop XL = -20, XR = 20, T = -13: depot and provider on the top straight (driven east), requester and
-- refueler on the bottom one (driven west). Parked trains: locomotive 3 tiles and wagon 10 tiles before the stop.
-- o: item, request, threshold, start (requester stock), stock (provider), refill / consume (per second),
-- refueler, fuel, constant (combinator name), no_bypass, control (station control at the requester)
C.NAMES = {depot = "[virtual-signal=signal-D]", provider = "[virtual-signal=up-arrow]", requester = "[virtual-signal=down-arrow]", refueler = "[item=coal]"}

-- Power inside the loop: station controllers read their input only while powered (Cybersyn checks the status),
-- inserters and pumps need it too.
function C.network_power()
  C.power({{-16, 6}, {-2, 6}, {5, -7}, {16, -7}}, {13, -5})
end

function C.network(o)
  o = o or {}
  local N = {o = o, item = o.item or "iron-ore"}
  C.setting("warmup_time", 0)
  force.bulk_inserter_capacity_bonus = 40
  C.loop(-20, 20, -13)
  C.network_power()
  -- Depot
  N.depot = C.stop(-1, -11, defines.direction.east, C.NAMES.depot, {0.55, 0.55, 0.55}, 1)
  N.depot_comb = C.controller({-2.5, -11}, "depot", {bits = {any_depot = true, train_count = true, no_bypass = o.no_bypass}})
  -- Provider: chests south of the top rail, inserters load the wagon (north)
  N.p_stop = C.stop(17, -11, defines.direction.east, C.NAMES.provider, {0.25, 0.85, 0.3})
  N.p_chests = C.loader(4.5, 9.5, -11.5, -10.5, -13)
  N.p_comb = C.controller({15.5, -11}, "station", {pr = 1})
  C.wire(N.p_chests[#N.p_chests], GREEN, N.p_comb, IN)
  C.fill(N.p_chests, N.item, o.stock or 9000)
  -- Requester: chests north of the bottom rail, inserters unload the wagon (south)
  N.r_stop = C.stop(-17, 11, defines.direction.west, C.NAMES.requester, {0.3, 0.55, 1})
  N.r_chests = C.loader(-9.5, -4.5, 11.5, 10.5, 9.5)
  N.r_comb = C.controller({-15.5, 11}, "station", {pr = 2})
  N.request = o.request or 8000
  N.threshold = o.threshold or 2000
  N.const = C.constant(o.constant or "constant-combinator", {-15.5, 8.5},
    {{"item", N.item, -N.request}, {"virtual", "cybersyn-request-threshold", N.threshold}})
  C.wire(N.const, GREEN, N.r_comb, IN)
  C.wire(N.r_chests[1], GREEN, N.r_comb, IN)
  C.fill(N.r_chests, N.item, o.start or 4000)
  if o.refueler then
    N.f_stop = C.stop(3, 11, defines.direction.west, C.NAMES.refueler, {1, 0.6, 0.15})
    N.f_chests = C.loader(4.5, 5.5, 11.5, 10.5, 13.5, "wooden-chest")
    N.f_comb = C.controller({1.5, 11}, "refueler")
    C.fill(N.f_chests, "coal", 1000)
  end
  local loco = C.train(N.depot, {"locomotive", "cargo-wagon"}, {depot = C.NAMES.depot, fuel = o.fuel or 1200})
  N.loco = loco
  N.tracked = C.track(loco)
  N.capacity = 20 * prototypes.item[N.item].stack_size
  return N
end

-- Mining at the provider and consumption at the requester, every 30 ticks
function C.economy(N, t)
  if t % 30 ~= 0 then return end
  local o = N.o
  local have = C.count(N.p_chests, N.item)
  local cap = o.stock_cap or 12000
  if have < cap then C.fill(N.p_chests, N.item, math.min(cap - have, math.floor((o.refill or 400) / 2))) end
  C.drain(N.r_chests, N.item, math.floor((o.consume or 300) / 2))
  if N.f_chests then
    local coal = C.count(N.f_chests, "coal")
    if coal < 800 then C.fill(N.f_chests, "coal", 800 - coal) end
  end
end

function C.labels(N, scale)
  scale = scale or 2.0
  C.text({-8, -8.6}, {"zzz-cybersyn-sim.depot"}, {scale = scale, color = {0.8, 0.8, 0.8}})
  C.text({10, -8.6}, {"zzz-cybersyn-sim.provider"}, {scale = scale, color = {0.45, 1, 0.5}})
  C.text({-8, 8.4}, {"zzz-cybersyn-sim.requester"}, {scale = scale, color = {0.55, 0.75, 1}})
  if N.f_stop then C.text({6, 8.4}, {"zzz-cybersyn-sim.refueler"}, {scale = scale, color = {1, 0.75, 0.35}}) end
end

-- Stock panel in the middle of the loop
function C.panel(N, x, y, scale)
  scale = scale or 1.6
  local icon = "[item=" .. N.item .. "]"
  local p = C.text({x, y}, "", {scale = scale, align = "left"})
  local r = C.text({x, y + 1.7}, "", {scale = scale, align = "left"})
  local d = C.text({x, y + 3.4}, "", {scale = scale, align = "left"})
  return function()
    p.text = {"zzz-cybersyn-sim.panel-provider", icon, C.count(N.p_chests, N.item)}
    r.text = {"zzz-cybersyn-sim.panel-requester", icon, C.count(N.r_chests, N.item), N.request, N.threshold}
    d.text = {"zzz-cybersyn-sim.panel-deliveries", C.stats.deliveries}
  end
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

-- Обзор: депо, снабжение, запрос; один поезд возит руду, над ним статус из Cybersyn.
simulations.overview = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 4500, consume = 260}
  C.labels(N)
  local panel = C.panel(N, -10, -3.6)
  C.text({0, 3.4}, {"zzz-cybersyn-sim.overview-hint"}, {scale = 1.61, color = {1, 0.9, 0.6}})
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then panel() end
  end
end)
]=])

-- Станционный контроллер: пять режимов у остановок, зона «1 клетка» и цвета буквы S.
simulations.controller = simulation([=[
C.scene(function()
  C.camera({1, 0.5}, 0.82)
  C.straight(-27, 29, 3)
  -- Combinators need power; the crossed-out one far from the stop stays without it
  C.power({{-18, -2}, {-4, -2}, {9, -2}, {20, -2}}, {-22, -2})
  local function station(sx, name, color)
    return C.make("train-stop", {sx, 5}, defines.direction.east, {station = name, color = color})
  end
  local y_label = 8.3
  -- Depot
  station(-19, "[virtual-signal=signal-D]", {0.55, 0.55, 0.55})
  C.controller({-20.5, 5}, "depot", {register = false})
  C.text({-19.5, y_label}, {"", "[font=default-large-bold]D[/font]  ", {"cybersyn-gui.depot"}}, {scale = 1.1})
  -- Station + wagon control, a parked train
  local s = station(-1, "[virtual-signal=up-arrow]", {0.25, 0.85, 0.3})
  local comb = C.controller({-2.5, 5}, "station", {register = false})
  C.make("locomotive", {-4, 3}, nil, {orientation = 0.25})
  C.make("cargo-wagon", {-11, 3}, nil, {orientation = 0.25})
  C.controller({-11.5, 1}, "wagon", {register = false})
  C.text({-11.5, -1.8}, {"", "[font=default-large-bold]W[/font]  ", {"cybersyn-gui.wagon-manifest"}}, {scale = 1.0})
  C.rect({-3, 3}, {1, 7}, {0.3, 1, 0.3, 1}, false, 3)
  C.text({-1, y_label}, {"", "[font=default-large-bold]S[/font]  ", {"cybersyn-gui.comb1"}}, {scale = 1.1})
  local state = C.text({-1, y_label + 1.3}, "", {scale = 0.95})
  C.text({-1, y_label + 2.6}, {"zzz-cybersyn-sim.one-tile"}, {scale = 0.95, color = {0.5, 1, 0.5}})
  -- Refueler
  station(11, "[item=coal]", {1, 0.6, 0.15})
  C.controller({9.5, 5}, "refueler", {register = false})
  C.text({10.5, y_label}, {"", "[font=default-large-bold]R[/font]  ", {"cybersyn-gui.refueler"}}, {scale = 1.1})
  -- Station + station control
  station(23, "[virtual-signal=down-arrow]", {0.3, 0.55, 1})
  C.controller({21.5, 5}, "station", {register = false})
  C.controller({24.5, 5}, "control", {register = false})
  C.text({23, y_label}, {"", "[font=default-large-bold]S + C[/font]  ", {"cybersyn-gui.comb2"}}, {scale = 1.1})
  -- Too far from the stop
  C.controller({14.5, 9}, "station", {register = false})
  C.line({13.8, 8.3}, {15.2, 9.7}, {1, 0.2, 0.2}, 5)
  C.line({13.8, 9.7}, {15.2, 8.3}, {1, 0.2, 0.2}, 5)
  C.text({14.5, 10.9}, {"zzz-cybersyn-sim.too-far"}, {scale = 0.9, color = {1, 0.5, 0.5}})
  C.title({"zzz-cybersyn-sim.controller-title"}, -6.5, 1.5)
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

-- Депо: пустой поезд входит в сеть, поезд с грузом задержан; груз убрали — поезд тоже в сети.
simulations.depot = live([=[
C.scene(function()
  if not C.need() then return end
  C.setting("warmup_time", 0)
  C.camera({0, -0.5}, 0.66)
  C.loop(-20, 20, -13)
  local name = C.NAMES.depot
  local top = C.stop(-1, -11, defines.direction.east, name, {0.55, 0.55, 0.55}, 1)
  C.controller({-2.5, -11}, "depot")
  local bottom = C.stop(3, 11, defines.direction.west, name, {0.55, 0.55, 0.55}, 1)
  C.controller({1.5, 11}, "depot")
  C.text({-8, -8.6}, {"zzz-cybersyn-sim.depot"}, {scale = 2.1, color = {0.8, 0.8, 0.8}})
  C.text({10, 8.4}, {"zzz-cybersyn-sim.depot"}, {scale = 2.1, color = {0.8, 0.8, 0.8}})
  C.text({0, -4.6}, {"zzz-cybersyn-sim.depot-same-name", name}, {scale = 1.54})
  local note = C.text({0, 0}, "", {scale = 1.68, color = {1, 0.9, 0.6}})
  local a, b, phase
  local function spawn()
    a = C.train(top, {"locomotive", "cargo-wagon"}, {depot = name})
    C.track(a)
    b = C.train(bottom, {"locomotive", "cargo-wagon"}, {depot = name, back = 1, cargo = {name = "iron-ore", count = 600}})
    C.track(b)
    phase = 1
    note.text = {"zzz-cybersyn-sim.depot-arrive"}
  end
  spawn()
  C.on_status = function(tracked, old, new) end
  C.main = function(t)
    local cycle = t % 1500
    if cycle == 600 and b and b.valid then
      -- The player unloads the train and sends it to the depot again
      for _, car in ipairs(b.train.cargo_wagons) do car.get_inventory(defines.inventory.cargo_wagon).clear() end
      b.train.schedule = {current = 1, records = {{station = name, wait_conditions = {{type = "inactivity", compare_type = "and", ticks = 120}}}}}
      b.train.manual_mode = true
      phase = 2
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
    if phase == 1 and t % 30 == 0 and b and b.valid and b.train.state == defines.train_state.wait_station then
      local held = C.status_of(b.train) == nil and b.train.get_item_count() > 0
      for _, tracked in ipairs(C.trains) do
        if tracked.loco == b and held and tracked.label.valid then tracked.label.text = {"zzz-cybersyn-sim.status-held"} end
      end
    end
  end
end)
]=])

-- Снабжение крупно: сундуки → вход контроллера (плюс = отдаём), загрузка вагона, выход контроллера.
simulations.provider = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({9, -7.5}, 1.05)
  local N = C.network{start = 3000, consume = 300}
  C.text({7, -8.4}, {"zzz-cybersyn-sim.provider-chests"}, {scale = 1.0, color = {0.6, 1, 0.6}})
  C.text({17, -15.6}, {"zzz-cybersyn-sim.provider"}, {scale = 1.4, color = {0.45, 1, 0.5}})
  local input = C.text({-1.5, -4.6}, "", {scale = 1.05, align = "left"})
  local output = C.text({-1.5, -3.4}, "", {scale = 1.05, align = "left"})
  C.text({-1.5, -2.0}, {"zzz-cybersyn-sim.provider-rule"}, {scale = 0.95, align = "left", color = {1, 0.9, 0.6}})
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      input.text = {"zzz-cybersyn-sim.comb-input", C.signal_text(C.signals_of(N.p_comb, {defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green}))}
      output.text = {"zzz-cybersyn-sim.comb-output", C.signal_text(C.signals_of(N.p_comb, {defines.wire_connector_id.combinator_output_red, defines.wire_connector_id.combinator_output_green}))}
    end
  end
end)
]=])

-- Запрос крупно: комбинатор заявок (−8000 и порог), сундуки, сумма на входе контроллера.
simulations.requester = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({-8, 7.5}, 1.05)
  local N = C.network{start = 6500, consume = 330, constant = "cybersyn-constant-combinator"}
  C.text({-7, 8.4}, {"zzz-cybersyn-sim.requester-chests"}, {scale = 1.0, color = {0.6, 0.8, 1}})
  C.text({-15.5, 7.2}, {"zzz-cybersyn-sim.request-combinator"}, {scale = 0.9, color = {1, 0.9, 0.6}})
  C.text({-17, 15.6}, {"zzz-cybersyn-sim.requester"}, {scale = 1.4, color = {0.55, 0.75, 1}})
  local stock = C.text({-20, 1.0}, "", {scale = 1.05, align = "left"})
  local sum = C.text({-20, 2.3}, "", {scale = 1.05, align = "left"})
  local verdict = C.text({-20, 3.6}, "", {scale = 1.05, align = "left"})
  local icon = "[item=" .. N.item .. "]"
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      local have = C.count(N.r_chests, N.item)
      stock.text = {"zzz-cybersyn-sim.request-sum", icon, -N.request, have, have - N.request}
      local deficit = N.request - have
      sum.text = {"zzz-cybersyn-sim.request-deficit", icon, math.max(0, deficit), N.threshold}
      if N.tracked.status ~= 0 and N.tracked.status ~= "none" and N.tracked.status ~= 6 then
        verdict.text = {"zzz-cybersyn-sim.request-on-way"}
      elseif deficit >= N.threshold then
        verdict.text = {"zzz-cybersyn-sim.request-yes"}
      else
        verdict.text = {"zzz-cybersyn-sim.request-no"}
      end
    end
  end
end)
]=])

-- Порог запроса: шкала запаса станции запроса, линия порога, момент вызова поезда.
simulations.threshold = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 7600, consume = 240}
  C.labels(N)
  local left, top, width, height = -12, -4.2, 24, 1.2
  C.rect({left, top}, {left + width, top + height}, {0.05, 0.05, 0.05, 0.85})
  local fill = C.rect({left, top}, {left, top + height}, {0.3, 0.55, 1, 1})
  local x_threshold = left + width * (N.request - N.threshold) / N.request
  C.line({x_threshold, top - 0.6}, {x_threshold, top + height + 0.6}, {1, 0.85, 0.2}, 4)
  C.text({x_threshold, top - 1.2}, {"zzz-cybersyn-sim.threshold-line", N.threshold}, {scale = 1.4, color = {1, 0.85, 0.2}})
  C.text({left + width, top - 1.2}, {"zzz-cybersyn-sim.threshold-full", N.request}, {scale = 1.26, align = "right"})
  C.text({left, top - 1.2}, "0", {scale = 1.26, align = "left"})
  local value = C.text({0, top + height + 1.4}, "", {scale = 1.54})
  local verdict = C.text({0, top + height + 3.2}, "", {scale = 1.54, color = {1, 0.9, 0.6}})
  local icon = "[item=" .. N.item .. "]"
  C.main = function(t)
    C.economy(N, t)
    if t % 10 == 0 then
      local have = C.count(N.r_chests, N.item)
      local fraction = math.max(0, math.min(1, have / N.request))
      fill.right_bottom = {left + width * fraction, top + height}
      local deficit = math.max(0, N.request - have)
      value.text = {"zzz-cybersyn-sim.threshold-value", icon, have, deficit}
      local busy = N.tracked.status ~= 0 and N.tracked.status ~= "none" and N.tracked.status ~= 6
      if busy then
        verdict.text = {"zzz-cybersyn-sim.threshold-busy"}
      elseif deficit >= N.threshold then
        verdict.text = {"zzz-cybersyn-sim.threshold-call"}
      else
        verdict.text = {"zzz-cybersyn-sim.threshold-wait", N.threshold - deficit}
      end
    end
  end
end)
]=])

-- Как проходит доставка: шаги подсвечиваются по статусу поезда; заказ поезда из Cybersyn.
simulations.delivery = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 4000, consume = 280}
  C.labels(N)
  local steps = {}
  for i = 1, 6 do
    steps[i] = C.text({-14, -6.6 + (i - 1) * 1.75}, {"zzz-cybersyn-sim.step-" .. i}, {scale = 1.47, align = "left", color = {0.6, 0.6, 0.6}})
  end
  local manifest = C.text({-14, 4.2}, "", {scale = 1.47, align = "left", color = {1, 0.9, 0.6}})
  local function light(i)
    for k, s in ipairs(steps) do s.color = k == i and {1, 1, 0.4} or {0.55, 0.55, 0.55} end
  end
  local STEP = {[0] = 1, [1] = 3, [2] = 4, [3] = 5, [4] = 5, [5] = 6, [6] = 6, [7] = 6, [8] = 6}
  C.main = function(t)
    C.economy(N, t)
    if t % 10 == 0 then
      local status = N.tracked.status
      local step = STEP[status] or 1
      if status == 0 then
        local have = C.count(N.r_chests, N.item)
        step = N.request - have >= N.threshold and 2 or 1
      end
      light(step)
      local m = N.loco.valid and remote.call("cybersyn", "read_global", "trains", N.loco.train.id, "manifest")
      if m and m[1] then
        manifest.text = {"zzz-cybersyn-sim.manifest", "[item=" .. m[1].name .. "]", m[1].count}
      else
        manifest.text = ""
      end
    end
  end
end)
]=])

-- Обход депо: расход большой, поезд берёт новые заказы, не заезжая в депо.
simulations.bypass = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 3000, consume = 700, request = 12000, stock = 12000, refill = 900, stock_cap = 16000}
  C.labels(N)
  local counter = C.text({0, -2.6}, "", {scale = 1.82, color = {1, 0.9, 0.6}})
  local visits = C.text({0, -0.4}, "", {scale = 1.54})
  C.text({0, 2.0}, {"zzz-cybersyn-sim.bypass-hint"}, {scale = 1.4})
  local depot_visits = 0
  C.on_status = function(tracked, old, new)
    if new == 0 and old ~= "none" then depot_visits = depot_visits + 1 end
  end
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      counter.text = {"zzz-cybersyn-sim.bypass-count", C.stats.bypass}
      visits.text = {"zzz-cybersyn-sim.bypass-depot", depot_visits, C.stats.deliveries}
    end
  end
end)
]=])

-- Заправка: топлива мало, после доставки поезд заезжает на заправку и уезжает за новым заказом.
simulations.refuel = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 3000, consume = 450, refueler = true, fuel = 150, request = 10000}
  C.labels(N)
  local gauge = rendering.draw_text{text = "", surface = game.surfaces[1], target = {entity = N.loco, offset = {0, -3.9}},
    color = {1, 0.8, 0.4}, scale = 1.68, font = "default-bold", alignment = "center", vertical_alignment = "middle", use_rich_text = true}
  local count = C.text({0, -2.4}, "", {scale = 1.68, color = {1, 0.9, 0.6}})
  C.text({0, -0.4}, {"zzz-cybersyn-sim.refuel-hint"}, {scale = 1.4})
  local function fuel_share()
    local inventory = N.loco.get_fuel_inventory()
    local total = 0
    for i = 1, #inventory do
      local stack = inventory[i]
      if stack.valid_for_read then total = total + stack.count / stack.prototype.stack_size end
    end
    return total / #inventory
  end
  C.on_status = function(tracked, old, new)
    -- Burn the fuel down again for the next round: the next delivery will need the refueler too
    if old == 8 and N.loco.valid then
      C.after(240, function()
        if N.loco.valid then
          local inventory = N.loco.get_fuel_inventory()
          inventory.clear()
          inventory.insert{name = "coal", count = 150}
        end
      end)
    end
  end
  C.main = function(t)
    C.economy(N, t)
    if t % 10 == 0 and N.loco.valid then
      gauge.text = {"zzz-cybersyn-sim.fuel", "[item=coal]", math.floor(fuel_share() * 100 + 0.5)}
      count.text = {"zzz-cybersyn-sim.refuel-count", C.stats.refuel, C.stats.deliveries}
    end
  end
end)
]=])

-- Сети: сеть A — короткие поезда, сеть B — длинные; поезд чужой сети к станции не едет.
simulations.networks = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  C.title({"zzz-cybersyn-sim.networks-title"}, -9.3, 1.3)
  local lanes = {
    {y = -4.5, signal = "signal-A", color = {0.35, 0.9, 0.4}, cars = 1},
    {y = 4.5, signal = "signal-B", color = {0.4, 0.6, 1}, cars = 2},
  }
  local X = {depot = -15, provider = -2, requester = 12}
  for _, lane in ipairs(lanes) do
    local net = "[virtual-signal=" .. lane.signal .. "]"
    C.box(X.depot, lane.y, 6, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.depot"}})
    C.box(X.provider, lane.y, 7, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.provider"}})
    C.box(X.requester, lane.y, 7, 3, lane.color, {"", net, " ", {"zzz-cybersyn-sim.requester"}})
    C.line({X.depot + 3, lane.y}, {X.provider - 3.5, lane.y}, {lane.color[1], lane.color[2], lane.color[3], 0.5}, 3, 0.4)
    C.line({X.provider + 3.5, lane.y}, {X.requester - 3.5, lane.y}, {lane.color[1], lane.color[2], lane.color[3], 0.5}, 3, 0.4)
    lane.label = C.text({X.requester + 5, lane.y - 2.2}, {"zzz-cybersyn-sim.train-length-" .. lane.cars}, {scale = 0.9, color = lane.color})
  end
  local function train_sprites(cars)
    local list = {{sprite = "item/locomotive", offset = {0, 0}, scale = 0.9}}
    for i = 1, cars do list[#list + 1] = {sprite = "item/cargo-wagon", offset = {-1.1 * i, 0}, scale = 0.9} end
    return list
  end
  local function run(lane)
    local y = lane.y - 2.2
    local token = C.token(train_sprites(lane.cars), {X.depot, y})
    C.path(token, {{X.provider, y}, {X.requester, y}, {X.depot, y}}, 70, function(t) C.destroy(t) C.after(20, function() run(lane) end) end)
  end
  run(lanes[1])
  C.after(35, function() run(lanes[2]) end)
  -- A train of network B looks at the requester of network A: no
  local cross = {}
  local wrong = C.text({0, 0}, "", {scale = 1.0, color = {1, 0.45, 0.45}})
  C.main = function(t)
    local phase = t % 300
    if phase == 150 then
      cross[1] = C.line({X.depot + 3, lanes[2].y - 1.5}, {X.requester - 3.5, lanes[1].y + 1.5}, {1, 0.3, 0.3, 0.9}, 4, 0.5)
      cross[2] = C.sprite("virtual-signal/signal-deny", {(X.depot + X.requester) / 2, 0}, 1.2)
      wrong.text = {"zzz-cybersyn-sim.networks-wrong"}
      wrong.target = {(X.depot + X.requester) / 2, 1.6}
    elseif phase == 270 then
      for _, object in ipairs(cross) do if object.valid then object.destroy() end end
      cross = {}
      wrong.text = ""
    end
  end
end)
]=])

-- Маски подсетей: значение сигнала сети — набор битов; доставка, если маски пересекаются.
simulations.masks = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  C.title({"zzz-cybersyn-sim.masks-title"}, -9.3, 1.3)
  local stations = {
    {x = -13, y = -2, mask = 1, name = "1"},
    {x = 0, y = 4, mask = 5, name = "2"},
    {x = 13, y = -2, mask = 4, name = "3"},
  }
  local function bits(x, y, mask, highlight)
    local objects = {}
    for b = 0, 3 do
      local on = bit32.btest(mask, bit32.lshift(1, b))
      local cx = x + 2.25 - b * 1.5
      objects[#objects + 1] = C.rect({cx - 0.6, y - 0.6}, {cx + 0.6, y + 0.6}, on and (highlight or {0.35, 0.9, 0.4, 1}) or {0.15, 0.15, 0.15, 1})
      objects[#objects + 1] = C.text({cx, y}, on and "1" or "0", {scale = 0.9})
    end
    return objects
  end
  for _, s in ipairs(stations) do
    C.box(s.x, s.y, 9, 5, {0.6, 0.6, 0.6}, nil)
    C.text({s.x, s.y - 1.6}, {"zzz-cybersyn-sim.mask-station", s.name, "[virtual-signal=signal-A]", s.mask}, {scale = 1.0})
    bits(s.x, s.y + 0.7, s.mask)
  end
  local pairs_list = {{1, 2}, {2, 3}, {1, 3}}
  local index, objects = 0, {}
  local result = C.text({0, 8.3}, "", {scale = 1.1})
  C.text({0, -6.6}, {"zzz-cybersyn-sim.masks-hint"}, {scale = 0.95, color = {1, 0.9, 0.6}})
  C.main = function(t)
    if t % 180 ~= 1 then return end
    for _, object in ipairs(objects) do if object.valid then object.destroy() end end
    objects = {}
    index = index % #pairs_list + 1
    local a, b = stations[pairs_list[index][1]], stations[pairs_list[index][2]]
    local both = bit32.band(a.mask, b.mask)
    local ok = both ~= 0
    local color = ok and {0.35, 1, 0.4, 1} or {1, 0.3, 0.3, 1}
    objects[#objects + 1] = C.line({a.x, a.y}, {b.x, b.y}, color, 5, ok and 0 or 0.6)
    local mx, my = (a.x + b.x) / 2, (a.y + b.y) / 2
    for _, object in ipairs(bits(mx, my - 2.2, both, {1, 0.85, 0.25, 1})) do objects[#objects + 1] = object end
    objects[#objects + 1] = C.sprite(ok and "virtual-signal/signal-check" or "virtual-signal/signal-deny", {mx, my - 0.5}, 1)
    result.text = {"zzz-cybersyn-sim.masks-result-" .. (ok and "yes" or "no"), a.name, b.name, a.mask, b.mask, both}
  end
end)
]=])

-- Приоритет: снабжение одно, двум запросам нужно; сначала обслуживается приоритет 1, при равных — по очереди.
simulations.priority = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  C.title({"zzz-cybersyn-sim.priority-title"}, -9.3, 1.3)
  local P = {x = -14, y = 0}
  local R = {{x = 12, y = -4.5, need = 0}, {x = 12, y = 4.5, need = 0}}
  C.box(P.x, P.y, 8, 4, {0.35, 0.9, 0.4}, nil)
  C.text({P.x, P.y - 0.8}, {"zzz-cybersyn-sim.provider"}, {scale = 1.1})
  local p_stock = C.text({P.x, P.y + 0.7}, "", {scale = 1.0})
  for i, r in ipairs(R) do
    C.box(r.x, r.y, 9, 4, {0.4, 0.6, 1}, nil)
    C.text({r.x, r.y - 1.0}, {"zzz-cybersyn-sim.requester-n", i}, {scale = 1.1})
    r.prio = C.text({r.x, r.y + 0.1}, "", {scale = 0.95})
    r.label = C.text({r.x, r.y + 1.1}, "", {scale = 0.95})
    C.line({P.x + 4, P.y}, {r.x - 4.5, r.y}, {0.6, 0.6, 0.6, 0.5}, 2, 0.4)
  end
  local mode_text = C.text({0, 8.2}, "", {scale = 1.05, color = {1, 0.9, 0.6}})
  p_stock.text = {"zzz-cybersyn-sim.priority-trains"}
  local priorities, last, busy, stock
  local function setup(phase)
    if phase == 1 then priorities = {1, 0} else priorities = {0, 0} end
    for i, r in ipairs(R) do
      r.need = 4
      r.prio.text = {"zzz-cybersyn-sim.priority-value", "[virtual-signal=cybersyn-priority]", priorities[i]}
      r.served = 0
    end
    stock = 99
    last = {0, 0}
    mode_text.text = {"zzz-cybersyn-sim.priority-mode-" .. phase}
  end
  local phase = 1
  setup(phase)
  local function pick()
    local best
    for i, r in ipairs(R) do
      if r.need > 0 then
        if not best or priorities[i] > priorities[best] or (priorities[i] == priorities[best] and last[i] < last[best]) then best = i end
      end
    end
    return best
  end
  C.main = function(t)
    for i, r in ipairs(R) do r.label.text = {"zzz-cybersyn-sim.priority-need", r.need} end
    if busy then return end
    local i = pick()
    if not i then
      if t % 120 == 0 then phase = 3 - phase setup(phase) end
      return
    end
    busy = true
    local r = R[i]
    last[i] = t
    local token = C.token({{sprite = "item/locomotive", offset = {0, 0}, scale = 0.9}, {sprite = "item/iron-ore", offset = {-1.1, 0}, scale = 0.8}}, {P.x + 4, P.y})
    C.path(token, {{r.x - 4.5, r.y}}, 50, function(tk)
      C.destroy(tk)
      r.need = r.need - 1
      busy = false
    end)
  end
end)
]=])

-- Список разрешённых поездов: манипуляторы стоят у одного вагона — поезд 1-1 проходит, 1-2 — нет.
simulations.allow_list = simulation([=[
C.scene(function()
  C.camera({-2, 0.5}, 0.9)
  C.title({"zzz-cybersyn-sim.allow-title"}, -10.2, 1.3)
  C.power({{6, 0}}, {10, 0})
  local rows = {{y = -5, cars = {"locomotive", "cargo-wagon"}}, {y = 5, cars = {"locomotive", "cargo-wagon", "cargo-wagon"}}}
  for _, row in ipairs(rows) do
    C.straight(-31, 23, row.y)
    local sx = 13
    C.make("train-stop", {sx, row.y + 2}, defines.direction.east, {color = {0.25, 0.85, 0.3}})
    C.controller({sx - 1.5, row.y + 2}, "station", {register = false})
    for x = sx - 12.5, sx - 7.5 do
      C.inserter("bulk-inserter", {x, row.y - 1.5}, row.y)
      C.make("iron-chest", {x, row.y - 2.5})
    end
    for i, name in ipairs(row.cars) do
      local x = sx - 3 - 7 * (i - 1)
      C.make(name, {x, row.y}, nil, {orientation = 0.25})
      local ok = name == "locomotive" or i == 2
      C.sprite(ok and "virtual-signal/signal-check" or "virtual-signal/signal-deny", {x, row.y + 2.4}, 0.9)
    end
    local fits = #row.cars == 2
    local layout = ""
    for _, name in ipairs(row.cars) do layout = layout .. "[item=" .. name .. "]" end
    C.text({sx + 3, row.y - 1.6}, layout, {scale = 1.3, align = "left"})
    C.text({sx + 3, row.y + 0.2}, {fits and "zzz-cybersyn-sim.allow-yes" or "zzz-cybersyn-sim.allow-no"}, {scale = 1.0, align = "left",
      color = fits and {0.5, 1, 0.5} or {1, 0.5, 0.5}})
  end
  C.text({-12, 0}, {"zzz-cybersyn-sim.allow-hint"}, {scale = 1.0, color = {1, 0.9, 0.6}})
end)
]=])

-- Жидкости: цистерна, насосы у станций; запасы баков изображены сигналами постоянных комбинаторов.
simulations.fluids = live([=[
C.scene(function()
  if not C.need() then return end
  C.setting("warmup_time", 0)
  C.camera({0, -0.5}, 0.66)
  local fluid = "crude-oil"
  C.loop(-20, 20, -13)
  C.network_power()
  local depot = C.stop(-1, -11, defines.direction.east, C.NAMES.depot, {0.55, 0.55, 0.55}, 1)
  C.controller({-2.5, -11}, "depot")
  -- Provider: pumps fill the wagon from an endless source (the tank farm of the scene)
  local p_stop = C.stop(17, -11, defines.direction.east, "[fluid=crude-oil][virtual-signal=up-arrow]", {0.25, 0.85, 0.3})
  for _, x in ipairs({9.5, 7.5, 5.5}) do
    C.make("pump", {x, -11}, defines.direction.north)
    C.make("infinity-pipe", {x, -9.5}, nil, {infinity_settings = {name = fluid, percentage = 1, mode = "at-least", temperature = 25}})
  end
  local p_comb = C.controller({15.5, -11}, "station", {pr = 1})
  local p_const = C.constant("constant-combinator", {15.5, -8.5}, {})
  C.wire(p_const, C.GREEN, p_comb, C.IN)
  -- Requester: pumps empty the wagon into the consumers
  local r_stop = C.stop(-17, 11, defines.direction.west, "[fluid=crude-oil][virtual-signal=down-arrow]", {0.3, 0.55, 1})
  for _, x in ipairs({-9.5, -7.5, -5.5}) do
    C.make("pump", {x, 11}, defines.direction.north)
    C.make("infinity-pipe", {x, 9.5}, nil, {infinity_settings = {name = fluid, percentage = 0, mode = "at-most", temperature = 25}})
  end
  local r_comb = C.controller({-15.5, 11}, "station", {pr = 2})
  local r_const = C.constant("constant-combinator", {-15.5, 8.5}, {})
  C.wire(r_const, C.GREEN, r_comb, C.IN)
  local loco = C.train(depot, {"locomotive", "fluid-wagon"}, {depot = C.NAMES.depot})
  local tracked = C.track(loco)
  local request, threshold = 50000, 15000
  local stock, level, carried = 80000, 30000, 0
  C.labels({})
  C.text({8, -6.4}, {"zzz-cybersyn-sim.fluid-provider"}, {scale = 1.4, color = {0.6, 1, 0.6}})
  C.text({-8, 6.2}, {"zzz-cybersyn-sim.fluid-requester"}, {scale = 1.4, color = {0.6, 0.8, 1}})
  local panel1 = C.text({-12, -3.6}, "", {scale = 1.54, align = "left"})
  local panel2 = C.text({-12, -1.8}, "", {scale = 1.54, align = "left"})
  local panel3 = C.text({-12, 0.0}, "", {scale = 1.54, align = "left"})
  local icon = "[fluid=" .. fluid .. "]"
  local function wagon_fluid()
    if not loco.valid then return 0 end
    local total = 0
    for _, wagon in ipairs(loco.train.fluid_wagons) do total = total + wagon.get_fluid_count(fluid) end
    return total
  end
  C.on_status = function(t, old, new)
    if old == 2 and new == 3 then stock = stock - wagon_fluid() end
    if old == 3 and new == 4 then carried = wagon_fluid() end
    if old == 4 then level = level + carried carried = 0 end
  end
  C.main = function(t)
    if t % 30 == 0 then
      stock = math.min(120000, stock + 1200)
      level = math.max(0, level - 900)
      C.set_signals(p_const, {{"fluid", fluid, math.floor(stock)}})
      C.set_signals(r_const, {{"fluid", fluid, math.floor(level - request)}, {"virtual", "cybersyn-fluid-request-threshold", threshold}})
      panel1.text = {"zzz-cybersyn-sim.fluid-stock", icon, math.floor(stock)}
      panel2.text = {"zzz-cybersyn-sim.fluid-level", icon, math.floor(level), request, threshold}
      panel3.text = {"zzz-cybersyn-sim.fluid-wagon", icon, math.floor(wagon_fluid())}
    end
  end
end)
]=])

-- Несколько грузов в одном вагоне: заказ раскладывается по ячейкам, заблокированные ячейки остаются пустыми.
simulations.multi = simulation([=[
C.scene(function()
  C.camera({0, 0}, 1)
  C.title({"zzz-cybersyn-sim.multi-title"}, -9.3, 1.3)
  local slots, locked = 20, 2
  local cols = 10
  local cells = {}
  for i = 1, slots do
    local col, row = (i - 1) % cols, math.floor((i - 1) / cols)
    local x, y = -11.25 + col * 2.5, -3 + row * 2.5
    cells[i] = {x = x, y = y, back = C.rect({x - 1.1, y - 1.1}, {x + 1.1, y + 1.1}, {0.12, 0.12, 0.12, 1})}
    if i > slots - locked then
      C.line({x - 0.8, y - 0.8}, {x + 0.8, y + 0.8}, {1, 0.3, 0.3}, 4)
      C.line({x - 0.8, y + 0.8}, {x + 0.8, y - 0.8}, {1, 0.3, 0.3}, 4)
    end
  end
  C.sprite("item/cargo-wagon", {-15.5, -1.75}, 1.6)
  C.text({0, 1.9}, {"zzz-cybersyn-sim.multi-locked", locked, "[virtual-signal=cybersyn-locked-slots]", slots - locked}, {scale = 1.0})
  local order = C.text({0, 3.4}, "", {scale = 1.05, color = {1, 0.9, 0.6}})
  C.text({0, 5.4}, {"zzz-cybersyn-sim.multi-wagon"}, {scale = 0.95})
  C.text({0, 6.7}, {"zzz-cybersyn-sim.multi-inactive"}, {scale = 0.95})
  local manifest = {{"iron-plate", 7}, {"copper-plate", 6}, {"steel-plate", 5}}
  local filled, step, objects = 0, 0, {}
  local function reset()
    for _, object in ipairs(objects) do if object.valid then object.destroy() end end
    objects, filled, step = {}, 0, 0
  end
  local text = {""}
  for _, m in ipairs(manifest) do text[#text + 1] = "[item=" .. m[1] .. "]×" .. m[2] .. "  " end
  order.text = {"zzz-cybersyn-sim.multi-order", text}
  C.main = function(t)
    if t % 12 ~= 0 then return end
    step = step + 1
    if step > 40 then reset() return end
    local total, k = 0, 0
    for _, m in ipairs(manifest) do total = total + m[2] end
    if filled >= total then return end
    filled = filled + 1
    local acc = 0
    for _, m in ipairs(manifest) do
      acc = acc + m[2]
      if filled <= acc then k = m[1] break end
    end
    local cell = cells[filled]
    objects[#objects + 1] = C.sprite("item/" .. k, {cell.x, cell.y}, 0.9)
  end
end)
]=])

-- Управление станцией (C): свой порог для руды на входе, на выходе — доставки в пути и число поездов.
simulations.station_control = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 5000, consume = 300}
  C.labels(N)
  local control = C.controller({-18.5, 9}, "control", {bits = {train_count = true}})
  local own = C.constant("constant-combinator", {-18.5, 6.5}, {{"item", N.item, 1000}})
  C.wire(own, C.GREEN, control, C.IN)
  C.text({-18.5, 4.0}, {"zzz-cybersyn-sim.control-own"}, {scale = 1.33, color = {1, 0.9, 0.6}})
  local input = C.text({-12, -3.4}, "", {scale = 1.54, align = "left"})
  local output = C.text({-12, -1.6}, "", {scale = 1.54, align = "left"})
  C.text({-12, 0.4}, {"zzz-cybersyn-sim.control-hint"}, {scale = 1.33, align = "left"})
  C.main = function(t)
    C.economy(N, t)
    if t % 15 == 0 then
      input.text = {"zzz-cybersyn-sim.control-input", C.signal_text(C.signals_of(control, {defines.wire_connector_id.combinator_input_red, defines.wire_connector_id.combinator_input_green}))}
      output.text = {"zzz-cybersyn-sim.control-output", C.signal_text(C.signals_of(control, {defines.wire_connector_id.combinator_output_red, defines.wire_connector_id.combinator_output_green}))}
    end
  end
end)
]=])

-- Если поезда не едут: порог больше вместимости поезда — красная S; порог исправили — поезд поехал.
simulations.problems = live([=[
C.scene(function()
  if not C.need() then return end
  C.camera({0, -0.5}, 0.66)
  local N = C.network{start = 0, consume = 0, request = 10000, threshold = 9000, stock = 12000}
  C.labels(N)
  local state = C.text({0, -3.8}, "", {scale = 1.75})
  local reason = C.text({0, -2.0}, "", {scale = 1.47, color = {1, 0.9, 0.6}})
  local bad = true
  local function set(threshold)
    N.threshold = threshold
    C.set_signals(N.const, {{"item", N.item, -N.request}, {"virtual", "cybersyn-request-threshold", threshold}})
  end
  C.main = function(t)
    C.economy(N, t)
    local cycle = t % 2400
    if cycle == 900 then
      bad = false
      set(2000)
    elseif cycle == 0 then
      bad = true
      set(9000)
      local have = C.count(N.r_chests, N.item)
      C.drain(N.r_chests, N.item, have)
    end
    if t % 10 == 0 then
      local mode = C.mode_of(N.r_comb)
      if mode == C.MODE.failed then
        state.text = {"zzz-cybersyn-sim.problem-red"}
      elseif mode == C.MODE.active then
        state.text = {"zzz-cybersyn-sim.problem-green"}
      else
        state.text = {"zzz-cybersyn-sim.problem-blue"}
      end
      reason.text = bad and {"zzz-cybersyn-sim.problem-capacity", N.threshold, N.capacity} or {"zzz-cybersyn-sim.problem-fixed", N.threshold}
    end
  end
end)
]=])

return simulations
