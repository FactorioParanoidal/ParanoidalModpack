-- Анимации к «Советам и подсказкам» о железной дороге (prototypes/tips-and-tricks/railway/railway.lua).
-- Каждая симуляция = общий пролог R + своя сцена. Поезда, светофоры и станции — настоящие: движок сам
-- водит поезда по блокам; урон деревянным рельсам наносит скрипт JunkTrain3 (поле mods).
-- Геометрия как в ванильных сценах 2.1: прямые рельсы в нечётных клетках, станция в 2 клетках справа
-- по ходу, светофор в 1,5 клетки справа. Ошибка сцены выводится текстом (ключ zzz-tips-sim.error).

local PRELUDE = [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
R = {t = 0, stats = {}}
sim.camera_alt_info = true
sim.hide_cursor = true

function R.fail(message)
  if R.err then return end
  R.err = tostring(message)
  pcall(log, "zzz tips simulation: " .. R.err)
  pcall(rendering.draw_text, {text = {"zzz-tips-sim.error", R.err}, surface = surface, target = {0, -6}, color = {1, 0.35, 0.35},
    scale = 1.5, alignment = "center"})
end

function R.start(fn)
  local ok, message = pcall(fn)
  if not ok then R.fail(message) end
end

function R.on_tick(fn)
  script.on_nth_tick(1, function()
    if R.err then return end
    R.t = R.t + 1
    local ok, message = pcall(fn, R.t)
    if not ok then R.fail(message) end
  end)
end

-- Camera of the tips window (1408x704 px). R.zoom keeps the text the same size on screen in every scene.
function R.camera(position, zoom)
  sim.camera_position = position
  sim.camera_zoom = zoom
  R.zoom = zoom
end

-- options.scale is relative: 1 = about 24 px high in the window, whatever the zoom
function R.text(position, text, options)
  options = options or {}
  return rendering.draw_text{text = text, surface = surface, target = position, color = options.color or {1, 1, 1},
    scale = 1.6 * (options.scale or 1) / (R.zoom or 1), font = options.font or "default-bold",
    alignment = options.align or "center", vertical_alignment = "middle", use_rich_text = true}
end

function R.rect(left_top, right_bottom, color)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color, filled = true}
end

function R.board(x1, y1, x2, y2)
  surface.build_checkerboard{{x1, y1}, {x2, y2}}
end

function R.create(name, position, extra)
  local spec = {name = name, position = position, force = force, create_build_effect_smoke = false}
  for key, value in pairs(extra or {}) do spec[key] = value end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. "," .. position[2]) end
  return entity
end

-- Straight rails: horizontal at odd y from x1 to x2 (odd), vertical at odd x from y1 to y2
-- (a crossing has a horizontal and a vertical rail at one position: look for the direction too)
function R.rail(name, position, direction)
  for _, rail in pairs(surface.find_entities_filtered{name = name, position = position}) do
    if rail.direction % 8 == direction % 8 then return rail end
  end
  return R.create(name, position, {direction = direction})
end

function R.rails_h(x1, x2, y, name)
  for x = x1, x2, 2 do R.rail(name or "straight-rail", {x, y}, defines.direction.east) end
end

function R.rails_v(y1, y2, x, name)
  for y = y1, y2, 2 do R.rail(name or "straight-rail", {x, y}, defines.direction.north) end
end

-- Travel direction -> unit vector, right-hand side, orientation, direction facing the incoming train
R.ways = {
  east = {dx = 1, dy = 0, rx = 0, ry = 1, orientation = 0.25, face = defines.direction.west},
  west = {dx = -1, dy = 0, rx = 0, ry = -1, orientation = 0.75, face = defines.direction.east},
  south = {dx = 0, dy = 1, rx = -1, ry = 0, orientation = 0.5, face = defines.direction.north},
  north = {dx = 0, dy = -1, rx = 1, ry = 0, orientation = 0, face = defines.direction.south},
}

-- Signal on the right of a track at line coordinate `line` (y of a horizontal, x of a vertical track), at the
-- rail joint `at` (even x of a horizontal, even y of a vertical track)
function R.signal(name, way, line, at)
  local w = R.ways[way]
  local candidates = {}
  for _, shift in ipairs({-0.5, 0.5}) do
    if w.dy == 0 then
      candidates[#candidates + 1] = {at + shift, line + 1.5 * w.ry}
    else
      candidates[#candidates + 1] = {line + 1.5 * w.rx, at + shift}
    end
  end
  for _, position in ipairs(candidates) do
    if surface.can_place_entity{name = name, position = position, direction = w.face, force = force} then
      return R.create(name, position, {direction = w.face})
    end
  end
  error("no place for " .. name .. " at " .. at)
end

-- Train stop on the right of a horizontal track at odd x
function R.stop(way, line, x, name)
  local w = R.ways[way]
  local stop = R.create("train-stop", {x, line + 2 * w.ry}, {direction = way == "east" and defines.direction.east or defines.direction.west})
  stop.backer_name = name
  return stop
end

-- A train heading `way`, front car at `front` (x or y), cars listed from the front; "<name" = facing backwards
function R.train(way, line, front, cars, fuel)
  local w = R.ways[way]
  local first
  local offset = 0
  for i, car in ipairs(cars) do
    local name, back = car, false
    if car:sub(1, 1) == "<" then name, back = car:sub(2), true end
    local along = front - offset * (w.dx ~= 0 and w.dx or w.dy)
    local position = w.dy == 0 and {along, line} or {line, along}
    local orientation = back and (w.orientation + 0.5) % 1 or w.orientation
    local entity = R.create(name, position, {orientation = orientation})
    if fuel and entity.type == "locomotive" then entity.insert{name = fuel, count = 20} end
    first = first or entity
    offset = offset + (cars.gap or 7)
  end
  return first.train
end

function R.schedule(train, records)
  local list = {}
  for i, record in ipairs(records) do
    local entry = {wait_conditions = {{type = "time", ticks = record.wait or 0, compare_type = "or"}}}
    if record.station then entry.station = record.station else entry.rail = record.rail end
    list[i] = entry
  end
  train.schedule = {current = 1, records = list}
  train.manual_mode = false
end

function R.front(train)
  local loco = train.front_stock
  return loco and loco.valid and loco.position
end

function R.destroy(train)
  if not (train and train.valid) then return end
  for _, car in pairs(train.carriages) do if car.valid then car.destroy() end end
end

-- Coloured strip for the block that starts at `signal`
R.colors = {
  [defines.signal_state.open] = {0.2, 0.75, 0.25, 0.85},
  [defines.signal_state.closed] = {0.9, 0.2, 0.15, 0.85},
  [defines.signal_state.reserved] = {0.95, 0.75, 0.15, 0.85},
}
function R.block(signal, left_top, right_bottom)
  return {signal = signal, rect = R.rect(left_top, right_bottom, R.colors[defines.signal_state.open])}
end
function R.paint(block)
  if block.signal.valid and block.rect.valid then
    block.rect.color = R.colors[block.signal.signal_state] or {0.5, 0.5, 0.5, 0.8}
  end
end
]=]

local function simulation(body, extra)
    local definition = {init = PRELUDE .. body}
    for key, value in pairs(extra or {}) do definition[key] = value end
    return definition
end

local simulations = {}

-- Деревянные рельсы: сверху МК0 на 54 км/ч (рельсы целы), снизу локомотив на ~173 км/ч (рельсы ломаются).
-- Скорость держит сцена (ручной режим), урон наносит скрипт JunkTrain3, как в игре.
simulations.wood = simulation([=[
R.start(function()
  R.camera({0, 0}, 0.75)
  R.board(-60, -16, 60, 16)
  local lanes = {
    {y = -5, speed = 0.25, cars = {"yir_usl"}, broken = 0},
    {y = 5, speed = 0.8, cars = {"locomotive", "cargo-wagon"}, broken = 0},
  }
  R.stats.lanes = lanes
  local function build(lane)
    R.rails_h(-57, 57, lane.y, "straight-scrap-rail")
  end
  local function launch(lane)
    R.destroy(lane.train)
    -- Rail debris of the previous run, so that every run starts on a clean track
    for _, remnant in pairs(surface.find_entities_filtered{type = "rail-remnants", area = {{-60, lane.y - 3}, {60, lane.y + 3}}}) do
      remnant.destroy()
    end
    build(lane)
    lane.train = R.train("east", lane.y, -38, lane.cars)
    lane.train.manual_mode = true
    lane.train.speed = lane.speed
  end
  for _, lane in ipairs(lanes) do
    build(lane)
    lane.label = R.text({-24, lane.y - 3.7}, "", {align = "left"})
    lane.count = R.text({24, lane.y - 3.7}, "", {align = "right"})
    lane.rails = 0
    for _ in pairs(surface.find_entities_filtered{name = "straight-scrap-rail", area = {{-58, lane.y - 1}, {58, lane.y + 1}}}) do
      lane.rails = lane.rails + 1
    end
    launch(lane)
  end
  script.on_event(defines.events.on_entity_died, function(event)
    local entity = event.entity
    if entity and entity.name == "straight-scrap-rail" then
      for _, lane in ipairs(lanes) do
        if math.abs(entity.position.y - lane.y) < 1 then lane.broken = lane.broken + 1 end
      end
    end
  end)
  R.on_tick(function(t)
    for _, lane in ipairs(lanes) do
      local train = lane.train
      local front = train and train.valid and R.front(train)
      if front and front.x > 44 then
        R.destroy(train)
        lane.train, front = nil, nil
      end
      if not front then
        lane.wait = lane.wait or t + 60
        if t >= lane.wait then
          lane.wait = nil
          launch(lane)
        end
      elseif train.speed < lane.speed then
        train.speed = lane.speed
      end
      lane.label.text = {"zzz-tips-sim.rail-wood-speed", math.floor(lane.speed * 216 + 0.5)}
      lane.count.text = {"zzz-tips-sim.rail-wood-broken", lane.broken}
    end
  end)
end)
]=], {mods = {"JunkTrain3"}, hide_health_bars = false})

-- Светофоры и блоки: поток поездов на восток, передний стоит на станции, остальные ждут у красных
-- светофоров. Полосы под путём — блоки (цвет — состояние светофора на входе). Поездов не больше трёх,
-- чтобы между ними освобождались блоки и полосы меняли цвет; новый поезд выезжает, только когда первый
-- блок простоял свободным (зелёным) 3 с, иначе зелёный мелькает на один кадр.
simulations.signals = simulation([=[
R.start(function()
  R.camera({-6, 0}, 0.6)
  R.board(-80, -20, 80, 20)
  local y = 1
  R.rails_h(-79, 79, y)
  local end_rail = surface.find_entity("straight-rail", {77, y})
  local stop = R.stop("east", y, 19, "B")
  -- The spawn block ends at x = -46; trains appear only when it is empty.
  R.signal("rail-signal", "east", y, -46)
  local joints = {-30, -14, 2}
  local blocks = {}
  for i, x in ipairs(joints) do
    local signal = R.signal("rail-signal", "east", y, x)
    local right = joints[i + 1] or 26
    blocks[#blocks + 1] = R.block(signal, {x + 0.3, y + 3.9}, {right - 0.3, y + 4.6})
  end
  R.text({19, y + 6.4}, {"zzz-tips-sim.rail-unload"})
  R.stats.trains, R.stats.closed, R.stats.green = 0, 0, 0
  local trains = {}
  local green = 0 -- ticks the first block has been free in a row
  local function spawn()
    local train = R.train("east", y, -52, {"locomotive", "cargo-wagon"}, "coal")
    R.schedule(train, {{station = "B", wait = 300}, {rail = end_rail, wait = 0}})
    trains[#trains + 1] = train
  end
  spawn()
  R.on_tick(function(t)
    local kept, last_x = {}, nil
    for _, train in ipairs(trains) do
      local front = train.valid and R.front(train)
      if front and front.x > 45 then
        R.destroy(train)
      elseif front then
        kept[#kept + 1] = train
        last_x = (not last_x or front.x < last_x) and front.x or last_x
      end
    end
    trains = kept
    if blocks[1].signal.signal_state == defines.signal_state.open then green = green + 1 else green = 0 end
    R.stats.green = math.max(R.stats.green, green)
    if green >= 180 and #trains < 3 and (not last_x or last_x > -34) then spawn() end
    local closed = 0
    for _, block in ipairs(blocks) do
      R.paint(block)
      if block.signal.signal_state == defines.signal_state.closed then closed = closed + 1 end
    end
    R.stats.trains = math.max(R.stats.trains, #trains)
    R.stats.closed = math.max(R.stats.closed, closed)
  end)
end)
]=], {init_update_count = 900})

-- Перекрёсток: горизонтальный путь (на восток) и вертикальный (на юг). Перед перекрёстком — проходные
-- светофоры, за ним — обычные. Горизонтальный поезд стоит на станции сразу за перекрёстком, следующий
-- ждёт у проходного светофора, вертикальные поезда проезжают.
simulations.crossing = simulation([=[
R.start(function()
  R.camera({0, 0}, 0.8)
  R.board(-80, -50, 80, 50)
  local hy, vx = 1, 1
  R.rails_h(-79, 79, hy)
  R.rails_v(-47, 47, vx)
  local h_end = surface.find_entity("straight-rail", {77, hy})
  local v_end = surface.find_entity("straight-rail", {vx, 45})
  local h_chain = R.signal("rail-chain-signal", "east", hy, -4)
  local h_exit = R.signal("rail-signal", "east", hy, 6)
  local v_chain = R.signal("rail-chain-signal", "south", vx, -4)
  local v_exit = R.signal("rail-signal", "south", vx, 6)
  R.signal("rail-signal", "east", hy, -26)
  R.signal("rail-signal", "south", vx, -26)
  R.stop("east", hy, 21, "B")
  R.text({-12, hy + 4.4}, {"zzz-tips-sim.rail-chain-here"})
  R.stats.h_passed, R.stats.v_passed = 0, 0
  local passed = R.text({-26, -11.5}, "", {align = "left", scale = 0.85})
  local list = {}
  local function spawn(way)
    if way == "east" then
      local train = R.train("east", hy, -50, {"locomotive", "cargo-wagon"}, "coal")
      R.schedule(train, {{station = "B", wait = 420}, {rail = h_end}})
      list[#list + 1] = {train = train, way = way}
    else
      local train = R.train("south", vx, -30, {"locomotive", "cargo-wagon"}, "coal")
      R.schedule(train, {{rail = v_end}})
      list[#list + 1] = {train = train, way = way}
    end
  end
  spawn("east")
  R.on_tick(function(t)
    local kept, h_min, v_min = {}, nil, nil
    for _, entry in ipairs(list) do
      local front = entry.train.valid and R.front(entry.train)
      if front then
        local along = entry.way == "east" and front.x or front.y
        if along > 4 and not entry.passed then
          entry.passed = true
          if entry.way == "east" then R.stats.h_passed = R.stats.h_passed + 1 else R.stats.v_passed = R.stats.v_passed + 1 end
        end
        -- Out of view (wagon included), before the end rail: a train parked at the end would block its exit block.
        if along > 40 then
          R.destroy(entry.train)
        else
          kept[#kept + 1] = entry
          if entry.way == "east" then h_min = math.min(h_min or along, along) else v_min = math.min(v_min or along, along) end
        end
      end
    end
    list = kept
    -- Spawn blocks end at -26 (signals above); a new train only when the previous one has left it.
    if t % 180 == 0 and (not h_min or h_min > -15) then spawn("east") end
    if t % 240 == 120 and (not v_min or v_min > -15) then spawn("south") end
    passed.text = {"zzz-tips-sim.rail-crossing-passed", R.stats.h_passed, R.stats.v_passed}
  end)
end)
]=], {init_update_count = 600})

-- Челнок: локомотивы на обоих концах, вагон с рудой. Слева манипуляторы грузят вагон из сундуков,
-- справа разгружают в сундуки; поезд ездит туда-обратно по расписанию.
simulations.stations = simulation([=[
R.start(function()
  R.camera({0, 0}, 0.75)
  R.board(-40, -16, 40, 16)
  local y = 1
  R.rails_h(-35, 35, y)
  R.stop("west", y, -23, "A")
  R.stop("east", y, 23, "B")
  -- Wagon of a train standing at a stop at x = S: centre S -+ 10.5 (as in the vanilla train stop scene)
  local load, unload = {}, {}
  for i = 0, 3 do
    local x = -23 + 8.5 + i
    R.create("bulk-inserter", {x, y - 1.5}, {direction = defines.direction.north})
    load[#load + 1] = R.create("iron-chest", {x, y - 2.5})
    local ux = 23 - 12.5 + i
    R.create("bulk-inserter", {ux, y + 1.5}, {direction = defines.direction.north})
    unload[#unload + 1] = R.create("iron-chest", {ux, y + 2.5})
  end
  for _, x in ipairs({-18, 18}) do
    R.create("substation", {x, x < 0 and y - 4 or y + 5})
    R.create("electric-energy-interface", {x + 2, x < 0 and y - 4 or y + 5})
  end
  R.text({-12.5, y - 5.8}, {"zzz-tips-sim.rail-load"})
  R.text({12.5, y + 6}, {"zzz-tips-sim.rail-unload"})
  local delivered = R.text({0, y - 8.6}, "")
  local train = R.train("east", y, 7, {"locomotive", "cargo-wagon", "<locomotive"}, "coal")
  R.schedule(train, {{station = "A", wait = 240}, {station = "B", wait = 240}})
  R.stats.delivered = 0
  R.on_tick(function(t)
    if t % 30 ~= 0 then return end
    for _, chest in ipairs(load) do
      local have = chest.get_item_count("iron-ore")
      if have < 200 then chest.insert{name = "iron-ore", count = 200 - have} end
    end
    for _, chest in ipairs(unload) do
      local got = chest.get_item_count("iron-ore")
      if got > 0 then
        R.stats.delivered = R.stats.delivered + chest.remove_item{name = "iron-ore", count = got}
      end
    end
    delivered.text = {"zzz-tips-sim.rail-delivered", "[item=iron-ore]", R.stats.delivered}
  end)
end)
]=], {init_update_count = 120})

return simulations
