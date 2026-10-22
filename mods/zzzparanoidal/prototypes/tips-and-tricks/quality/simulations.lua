-- Анимации к «Советам и подсказкам» о браке и качестве (prototypes/tips-and-tricks/quality/quality.lua).
-- Каждая симуляция = общий пролог Z + своя сцена. Скрипты модов в симуляции не работают, поэтому
-- брак, доводка, пост и режимы показаны отрисовкой по тем же правилам, что в ic-more-qualities
-- (model.lua, rules.lua); модули качества, качество ингредиентов и переработку считает сам движок.
-- Любая ошибка сцены выводится текстом в окне симуляции (ключ zzz-tips-sim.error).

local PRELUDE = [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
Z = {t = 0, movers = {}}
sim.camera_position = {0, 0}
sim.camera_zoom = 1
sim.camera_alt_info = true
sim.hide_cursor = true

function Z.fail(message)
  if Z.err then return end
  Z.err = tostring(message)
  pcall(log, "zzz tips simulation: " .. Z.err)
  pcall(rendering.draw_text,{text = {"zzz-tips-sim.error", Z.err}, surface = surface, target = {0, -5}, color = {1, 0.35, 0.35}, scale = 1, alignment = "center"})
end

function Z.start(fn)
  local ok, message = pcall(fn)
  if not ok then Z.fail(message) end
end

function Z.on_tick(fn)
  script.on_nth_tick(1, function()
    if Z.err then return end
    Z.t = Z.t + 1
    local ok, message = pcall(fn, Z.t)
    if ok then ok, message = pcall(Z.step_movers) end
    if not ok then Z.fail(message) end
  end)
end

function Z.text(position, text, options)
  options = options or {}
  return rendering.draw_text{text = text, surface = surface, target = position, color = options.color or {1, 1, 1},
    scale = options.scale or 1, font = options.font or "default-bold", alignment = options.align or "center",
    vertical_alignment = options.valign or "middle", use_rich_text = true}
end

function Z.rect(left_top, right_bottom, color, filled)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = 2}
end

function Z.line(from, to, color, width)
  return rendering.draw_line{surface = surface, from = from, to = to, color = color, width = width or 3}
end

function Z.sprite(sprite, position, scale)
  return rendering.draw_sprite{sprite = sprite, surface = surface, target = position, x_scale = scale or 1, y_scale = scale or 1}
end

function Z.pct(value)
  value = (value or 0) * 100
  if value <= 0 then return "0%" end
  if value < 0.01 then return "<0.01%" end
  if value < 1 then return string.format("%.2f%%", value) end
  return string.format("%.1f%%", value)
end

-- Qualities --------------------------------------------------------------------------------------
Z.grades = {[-5] = "ic-defect-5", [-4] = "ic-defect-4", [-3] = "ic-defect-3", [-2] = "ic-defect-2", [-1] = "ic-defect-1", [0] = "normal"}
Z.defect_list = {"ic-defect-5", "ic-defect-4", "ic-defect-3", "ic-defect-2", "ic-defect-1", "normal"}

function Z.qicon(name) return "[img=quality/" .. name .. "]" end
function Z.qname(name) return {"", Z.qicon(name), " ", prototypes.quality[name].localised_name} end

function Z.grade_of(name)
  for grade, quality in pairs(Z.grades) do if quality == name then return grade end end
  return 0
end

-- normal and the next `count - 1` positive tiers
function Z.positive(count)
  local list, quality = {}, prototypes.quality.normal
  while quality and #list < count do
    list[#list + 1] = quality
    quality = quality.next
  end
  return list
end

function Z.unlock_all()
  for name, quality in pairs(prototypes.quality) do
    if not quality.hidden then pcall(function() force.unlock_quality(name) end) end
  end
end

-- ic-more-qualities scripts/defects/model.lua: distribution of a new finished product by control level
function Z.distribution(level)
  local function geometric(minimum)
    local result, total, weight = {}, 0, 1
    for grade = -5, 0 do result[grade] = 0 end
    for grade = minimum, 0 do
      result[grade] = weight
      total = total + weight
      weight = weight / 10
    end
    for grade = minimum, 0 do result[grade] = result[grade] / total end
    return result
  end
  level = math.max(0, math.min(10, level))
  local minimum = -5 + math.floor(level / 2)
  local lower = geometric(minimum)
  if level % 2 == 0 then return lower end
  local upper = geometric(minimum + 1)
  for grade = -5, 0 do lower[grade] = (lower[grade] + upper[grade]) / 2 end
  return lower
end

function Z.draw(level)
  local distribution, sample, sum = Z.distribution(level), math.random(), 0
  for grade = -5, 0 do
    sum = sum + distribution[grade]
    if sample < sum then return grade end
  end
  return 0
end

-- ic-more-qualities rules.lua: one workshop attempt in the normal mode
function Z.refine(grade)
  if grade >= 0 or math.random() >= 0.9 then return grade end
  local result = grade + 1
  while result < 0 and math.random() < 0.1 do result = result + 1 end
  return result
end

-- Engine quality roll: effect x next_probability of the input quality, then the chain
function Z.upgrade(quality, effect, rolls)
  local chance = math.min(1, effect * (quality.next_probability or 0))
  if rolls and rolls > 1 then chance = 1 - (1 - chance) ^ rolls end
  if not quality.next or math.random() >= chance then return quality end
  local result = quality.next
  while result.next and math.random() < (result.next_probability or 0) do result = result.next end
  return result
end

-- Entities ---------------------------------------------------------------------------------------
function Z.create(name, position, quality)
  return surface.create_entity{name = name, position = position, force = force, quality = quality or "normal",
    create_build_effect_smoke = false}
end

-- Two substations and an energy interface along y; returns nothing
function Z.power(x1, x2, y)
  local a = Z.create("substation", {x1, y})
  local b = Z.create("substation", {x2, y})
  Z.create("electric-energy-interface", {(x1 + x2) / 2, y})
  pcall(function()
    local id = defines.wire_connector_id.pole_copper
    a.get_wire_connector(id, true).connect_to(b.get_wire_connector(id, true), false)
  end)
end

function Z.machine(name, position, quality, recipe, recipe_quality)
  local entity = Z.create(name, position, quality)
  if recipe then
    force.recipes[recipe].enabled = true
    entity.set_recipe(recipe, recipe_quality or "normal")
  end
  return entity
end

function Z.input(entity)
  return entity.get_inventory(defines.inventory.crafter_input)
end

-- Workshop with repair packs in its fuel slots: no "no fuel" warning icon in the scene
function Z.workshop(position)
  local entity = Z.create("ic-refine-workshop", position)
  pcall(function() entity.get_fuel_inventory().insert{name = "repair-pack", count = 10} end)
  return entity
end

-- Red cross over a position
function Z.cross(position, size)
  local x, y, d = position[1], position[2], size or 1
  Z.line({x - d, y - d}, {x + d, y + d}, {1, 0.2, 0.2, 1}, 8)
  Z.line({x - d, y + d}, {x + d, y - d}, {1, 0.2, 0.2, 1}, 8)
end

-- Keep `times` crafts of every item ingredient of `recipe` at `quality` in the machine input
function Z.feed(entity, recipe, quality, times)
  local inventory = Z.input(entity)
  for _, ingredient in pairs(prototypes.recipe[recipe].ingredients) do
    if ingredient.type == "item" then
      local want = ingredient.amount * (times or 4)
      local have = inventory.get_item_count({name = ingredient.name, quality = quality or "normal"})
      if have < want then inventory.insert{name = ingredient.name, count = want - have, quality = quality or "normal"} end
    end
  end
end

-- Empty the output; returns {{name, quality, count}, ...}
function Z.take(entity)
  local inventory = entity.get_output_inventory()
  local list = inventory.get_contents()
  inventory.clear()
  return list
end

-- Moving tokens: item icon + quality badge ------------------------------------------------------
function Z.token(item, quality, position)
  local token = {item = item, quality = quality, position = position}
  token.sprite = Z.sprite("item/" .. item, position, 0.7)
  token.badge = Z.sprite("quality/" .. quality, {position[1] - 0.3, position[2] + 0.3}, 0.35)
  token.badge.visible = quality ~= "normal"
  return token
end

function Z.set_quality(token, quality)
  token.quality = quality
  token.badge.sprite = "quality/" .. quality
  token.badge.visible = quality ~= "normal"
end

function Z.place(token, position)
  token.position = position
  token.sprite.target = position
  token.badge.target = {position[1] - 0.3, position[2] + 0.3}
end

function Z.destroy(token)
  if token.sprite.valid then token.sprite.destroy() end
  if token.badge.valid then token.badge.destroy() end
end

-- Move along points {{x, y}, ...}: `ticks` per segment; `done(token)` at the end
function Z.path(token, points, ticks, done)
  Z.movers[#Z.movers + 1] = {token = token, points = points, index = 1, from = token.position, ticks = math.max(1, ticks), i = 0, done = done}
end

function Z.move(token, to, ticks, done) Z.path(token, {to}, ticks, done) end

function Z.step_movers()
  local list = Z.movers
  Z.movers = {}
  for _, m in ipairs(list) do
    m.i = m.i + 1
    local to = m.points[m.index]
    local f = m.i / m.ticks
    if f >= 1 then
      Z.place(m.token, to)
      if m.index < #m.points then
        m.index, m.i, m.from = m.index + 1, 0, to
        Z.movers[#Z.movers + 1] = m
      elseif m.done then
        m.done(m.token)
      end
    else
      Z.place(m.token, {m.from[1] + (to[1] - m.from[1]) * f, m.from[2] + (to[2] - m.from[2]) * f})
      Z.movers[#Z.movers + 1] = m
    end
  end
end

-- Bars and histograms ----------------------------------------------------------------------------
function Z.bar(left, top, width, color, height)
  local bar = {left = left, top = top, width = width, height = height or 0.3}
  bar.back = Z.rect({left, top}, {left + width, top + bar.height}, {0.05, 0.05, 0.05, 0.75})
  bar.fill = Z.rect({left, top}, {left, top + bar.height}, color or {0.35, 0.8, 0.35, 1})
  return bar
end

function Z.set_bar(bar, fraction)
  fraction = math.max(0, math.min(1, fraction or 0))
  bar.fill.right_bottom = {bar.left + bar.width * fraction, bar.top + bar.height}
end

-- Rows of qualities with a bar and "count (share)"; labels left of `x`
function Z.histogram(x, y, names, width, step, labels)
  local h = {rows = {}, order = {}, total = 0}
  for i, name in ipairs(names) do
    local row = {name = name, count = 0, y = y + (i - 1) * (step or 0.8)}
    row.title = Z.text({x - 0.3, row.y}, labels and Z.qname(name) or Z.qicon(name), {align = "right", scale = 0.85})
    row.bar = Z.bar(x, row.y - 0.15, width, {0.35, 0.75, 1, 1})
    row.label = Z.text({x + width + 0.3, row.y}, "0", {align = "left", scale = 0.85, font = "default"})
    h.rows[name] = row
    h.order[i] = row
  end
  return h
end

function Z.hist_refresh(h)
  local max = 0
  for _, row in pairs(h.rows) do max = math.max(max, row.count) end
  for _, row in pairs(h.rows) do
    Z.set_bar(row.bar, max > 0 and row.count / max or 0)
    row.label.text = row.count .. "  (" .. Z.pct(h.total > 0 and row.count / h.total or 0) .. ")"
  end
end

function Z.hist_add(h, name, count)
  local row = h.rows[name]
  if not row then return end
  row.count = row.count + (count or 1)
  h.total = h.total + (count or 1)
  Z.hist_refresh(h)
end

function Z.hist_reset(h)
  for _, row in pairs(h.rows) do row.count = 0 end
  h.total = 0
  Z.hist_refresh(h)
end
]=]

local function simulation(body, extra)
    local definition = {init = PRELUDE .. body}
    for key, value in pairs(extra or {}) do definition[key] = value end
    return definition
end

local simulations = {}

---------------------------------------------------------------------------------------------------
-- Брак
---------------------------------------------------------------------------------------------------

-- Шесть одинаковых автоматов от −5 до обычного: скорость и счётчик сделанных шестерней.
simulations.defects = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  Z.text({0, -4.6}, {"zzz-tips-sim.grades-title"}, {scale = 1.3})
  local machines = {}
  for i = 0, 5 do
    local quality = Z.grades[i - 5]
    local x = -8.75 + i * 3.5
    local entity = Z.machine("assembling-machine-1", {x, 0}, quality, "iron-gear-wheel")
    local prototype = prototypes.quality[quality]
    Z.text({x, -3.2}, Z.qicon(quality), {scale = 1.6})
    Z.text({x, -2.2}, {"zzz-tips-sim.speed", tostring(math.floor(prototype.crafting_machine_speed_multiplier * 100 + 0.5))}, {scale = 0.85, color = {1, 0.85, 0.4}})
    Z.text({x, 2.3}, {"zzz-tips-sim.energy", string.format("%.2f", prototype.crafting_machine_energy_usage_multiplier)}, {scale = 0.8, color = {1, 0.6, 0.6}, font = "default"})
    machines[#machines + 1] = {entity = entity, counter = Z.text({x, 3.2}, "", {scale = 1.1}), base = 0}
  end
  Z.on_tick(function(t)
    for _, m in ipairs(machines) do
      if t % 30 == 0 then
        Z.feed(m.entity, "iron-gear-wheel", "normal", 4)
        Z.take(m.entity)
      end
      if t % 3600 == 0 then m.base = m.entity.products_finished end
      m.counter.text = "[item=iron-gear-wheel] " .. (m.entity.products_finished - m.base)
    end
  end)
end)
]=])

-- Автомат делает железные сундуки (готовое изделие); каждое изделие получает ступень по
-- распределению уровня контроля 0 и улетает в свою строку гистограммы.
simulations.defects_origin = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  local machine = Z.machine("assembling-machine-1", {-7.5, 0}, "normal", "iron-chest")
  Z.text({-7.5, -2.4}, {"zzz-tips-sim.level", "0"}, {scale = 1})
  Z.text({4, -4.6}, {"zzz-tips-sim.new-products"}, {scale = 1.1})
  local hist = Z.histogram(0.5, -3.2, Z.defect_list, 5, 1.0, true)
  local last = machine.products_finished
  Z.on_tick(function(t)
    if t % 20 == 0 then Z.feed(machine, "iron-chest", "normal", 2) end
    local done = machine.products_finished
    if done > last then
      Z.take(machine)
      for _ = 1, done - last do
        local quality = Z.grades[Z.draw(0)]
        local row = hist.rows[quality]
        local token = Z.token("iron-chest", quality, {-5.6, 0})
        Z.move(token, {-0.2, row.y}, 40, function(item)
          Z.destroy(item)
          Z.hist_add(hist, quality, 1)
        end)
      end
      last = done
    end
    if hist.total >= 120 then Z.hist_reset(hist) end
  end)
end)
]=])

-- Распределение брака у нового изделия на уровнях контроля 0…10 (плавно меняющиеся полосы).
simulations.defects_research = simulation([=[
Z.start(function()
  local rows = {}
  for i, quality in ipairs(Z.defect_list) do
    local y = -2.6 + (i - 1) * 1.1
    rows[i] = {grade = i - 6, value = 0,
      title = Z.text({-3.3, y}, Z.qname(quality), {align = "right", scale = 0.9}),
      bar = Z.bar(-3, y - 0.25, 9, i == 6 and {0.4, 0.85, 0.4, 1} or {0.85, 0.45, 0.3, 1}, 0.5),
      label = Z.text({6.4, y}, "", {align = "left", scale = 0.95})}
  end
  local title = Z.text({0, -4.4}, "", {scale = 1.35})
  local note = Z.text({0, 4.4}, "", {scale = 0.9, color = {1, 0.85, 0.4}, font = "default"})
  local level, wait = 0, 0
  Z.on_tick(function(t)
    wait = wait + 1
    if wait >= (level == 10 and 360 or 150) then
      wait = 0
      level = level < 10 and level + 1 or 0
    end
    local distribution = Z.distribution(level)
    title.text = {"zzz-tips-sim.level", tostring(level)}
    note.text = level == 10 and {"zzz-tips-sim.level-10"} or {"zzz-tips-sim.level-step"}
    for _, row in ipairs(rows) do
      row.value = row.value + (distribution[row.grade] - row.value) * 0.1
      Z.set_bar(row.bar, row.value)
      row.label.text = Z.pct(distribution[row.grade])
    end
  end)
end)
]=])

-- Рецепт из готовых изделий: −3 + −3 → −3 (движок), обычные → обычный, смешать нельзя.
simulations.defects_ingredients = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  local recipe = "lighted-small-electric-pole"
  local lanes = {
    {x = -7, quality = "ic-defect-3"},
    {x = 0, quality = "normal"},
  }
  for _, lane in ipairs(lanes) do
    local q = lane.quality
    lane.entity = Z.machine("assembling-machine-1", {lane.x, 0}, "normal", recipe, q)
    Z.text({lane.x, -2.6}, "[item=small-electric-pole,quality=" .. q .. "] + [item=small-lamp,quality=" .. q .. "] → [item=lighted-small-electric-pole,quality=" .. q .. "]", {scale = 1.2})
    lane.last = lane.entity.products_finished
  end
  Z.text({-3.5, -4.7}, {"zzz-tips-sim.same-grade"}, {scale = 0.95})
  -- Third lane: mixed qualities do not fit one recipe
  Z.create("assembling-machine-1", {7, 0}, "normal")
  Z.text({7, -2.6}, "[item=small-electric-pole,quality=ic-defect-3] + [item=small-lamp]", {scale = 1.2})
  Z.cross({7, 0}, 1.1)
  Z.text({7, -3.9}, {"zzz-tips-sim.mixed"}, {scale = 0.95, color = {1, 0.5, 0.5}})
  Z.on_tick(function(t)
    for _, lane in ipairs(lanes) do
      if t % 30 == 0 then Z.feed(lane.entity, recipe, lane.quality, 2) end
      local done = lane.entity.products_finished
      if done > lane.last then
        lane.last = done
        for _, stack in pairs(Z.take(lane.entity)) do
          local token = Z.token(stack.name, stack.quality, {lane.x, 1})
          Z.move(token, {lane.x, 3.6}, 50, function(item) Z.destroy(item) end)
        end
      end
    end
  end)
end)
]=])

-- Столбы −5, −3 и обычный: покрытие и дальность провода из прототипа.
simulations.defects_buildings = simulation([=[
Z.start(function()
  Z.unlock_all()
  local pole = prototypes.entity["small-electric-pole"]
  local list = {{x = -7.5, q = "ic-defect-5"}, {x = 0.5, q = "ic-defect-3"}, {x = 8.5, q = "normal"}}
  for _, p in ipairs(list) do
    Z.create("small-electric-pole", {p.x, 0.5}, p.q)
    local d = pole.get_supply_area_distance(p.q)
    Z.rect({p.x - d, 0.5 - d}, {p.x + d, 0.5 + d}, {0.15, 0.35, 0.6, 0.35}, true)
    Z.rect({p.x - d, 0.5 - d}, {p.x + d, 0.5 + d}, {0.4, 0.7, 1, 1}, false)
    Z.text({p.x, -3.6}, Z.qname(p.q), {scale = 0.95})
    Z.text({p.x, 4.0}, {"zzz-tips-sim.pole", string.format("%.1f", d * 2), string.format("%.1f", pole.get_max_wire_distance(p.q))}, {scale = 0.85, font = "default"})
  end
  Z.text({0.5, -4.7}, {"zzz-tips-sim.poles-title"}, {scale = 1.2})
  Z.on_tick(function() end)
end)
]=])

-- Мастерская: изделие −5 заходит, попытка, исход по правилам ic (90% вверх, затем по 10%),
-- не обычное — по кругу на новую попытку.
simulations.defects_workshop = simulation([=[
Z.start(function()
  Z.workshop({0, 0})
  local item = "burner-mining-drill"
  Z.line({-9, 0}, {-1.6, 0}, {0.8, 0.8, 0.3, 0.6}, 4)
  Z.line({1.6, 0}, {9, 0}, {0.4, 0.9, 0.4, 0.6}, 4)
  Z.line({3, 0}, {3, 3}, {0.9, 0.7, 0.2, 0.6}, 4)
  Z.line({3, 3}, {-6, 3}, {0.9, 0.7, 0.2, 0.6}, 4)
  Z.line({-6, 3}, {-6, 0}, {0.9, 0.7, 0.2, 0.6}, 4)
  Z.text({-1.5, 3.6}, {"zzz-tips-sim.again"}, {scale = 0.85, color = {1, 0.8, 0.4}})
  Z.text({8, -1}, {"zzz-tips-sim.done"}, {scale = 0.9, color = {0.5, 1, 0.5}})
  Z.text({0, -4.6}, {"zzz-tips-sim.workshop-title"}, {scale = 1.2})
  local bar = Z.bar(-1.5, -2.2, 3, {0.9, 0.75, 0.3, 1})
  local status = Z.text({0, -3.3}, "", {scale = 0.95})
  local stats = Z.text({0, 4.7}, "", {scale = 0.85, font = "default"})
  local s = {attempts = 0, same = 0, one = 0, more = 0, done = 0}
  local work
  local function refresh()
    stats.text = {"zzz-tips-sim.workshop-stats", s.attempts, s.same, s.one, s.more, s.done}
  end
  local function attempt(token)
    work = {token = token, i = 0, n = 90}
  end
  local function spawn()
    local token = Z.token(item, "ic-defect-5", {-9, 0})
    Z.move(token, {0, 0}, 70, attempt)
  end
  refresh()
  spawn()
  Z.on_tick(function()
    if not work then return end
    work.i = work.i + 1
    Z.set_bar(bar, work.i / work.n)
    if work.i < work.n then return end
    local token = work.token
    work = nil
    Z.set_bar(bar, 0)
    local before = Z.grade_of(token.quality)
    local after = Z.refine(before)
    s.attempts = s.attempts + 1
    if after == before then s.same = s.same + 1 elseif after == before + 1 then s.one = s.one + 1 else s.more = s.more + 1 end
    Z.set_quality(token, Z.grades[after])
    status.text = {"", Z.qicon(Z.grades[before]), " → ", Z.qicon(Z.grades[after])}
    if after == 0 then
      s.done = s.done + 1
      Z.path(token, {{3, 0}, {9, 0}}, 40, function(t) Z.destroy(t) spawn() end)
    else
      Z.path(token, {{3, 0}, {3, 3}, {-6, 3}, {-6, 0}, {0, 0}}, 25, attempt)
    end
    refresh()
  end)
end)
]=])

-- Три мастерские в режимах I/II/III доводят −5 до обычного: время и число попыток (= наборы).
simulations.defects_workshop_modes = simulation([=[
Z.start(function()
  local base = 45
  local lanes = {
    {x = -7.5, mode = "normal", time = 1, steps = nil, roman = "I"},
    {x = 0, mode = "careful", time = 5, steps = 2, roman = "II"},
    {x = 7.5, mode = "precise", time = 20, steps = 5, roman = "III"},
  }
  Z.text({0, -4.7}, {"zzz-tips-sim.workshop-modes-title"}, {scale = 1.15})
  for _, lane in ipairs(lanes) do
    Z.workshop({lane.x, 0})
    Z.text({lane.x, -3.8}, {"", lane.roman, ". ", {"ic-quality.mode-" .. lane.mode}}, {scale = 1.1})
    Z.text({lane.x, -3.1}, {"zzz-tips-sim.workshop-mode-" .. lane.mode}, {scale = 0.8, font = "default", color = {1, 0.85, 0.4}})
    Z.text({lane.x, -2.5}, {"zzz-tips-sim.workshop-mode-" .. lane.mode .. "-effect"}, {scale = 0.8, font = "default", color = {1, 0.85, 0.4}})
    lane.bar = Z.bar(lane.x - 1.5, 1.8, 3, {0.9, 0.75, 0.3, 1})
    lane.info = Z.text({lane.x, 3}, "", {scale = 0.85, font = "default"})
    lane.result = Z.text({lane.x, 4.1}, "", {scale = 0.85, font = "default", color = {0.6, 1, 0.6}})
    lane.grade, lane.i, lane.attempts, lane.ticks, lane.pause = -5, 0, 0, 0, 0
    lane.token = Z.token("burner-mining-drill", "ic-defect-5", {lane.x, -0.2})
  end
  Z.on_tick(function()
    for _, lane in ipairs(lanes) do
      if lane.pause > 0 then
        lane.pause = lane.pause - 1
        if lane.pause == 0 then
          lane.grade, lane.attempts, lane.ticks = -5, 0, 0
          Z.set_quality(lane.token, "ic-defect-5")
        end
      else
        lane.i = lane.i + 1
        lane.ticks = lane.ticks + 1
        local n = base * lane.time
        Z.set_bar(lane.bar, lane.i / n)
        if lane.i >= n then
          lane.i = 0
          lane.attempts = lane.attempts + 1
          if lane.steps then lane.grade = math.min(0, lane.grade + lane.steps) else lane.grade = Z.refine(lane.grade) end
          Z.set_quality(lane.token, Z.grades[lane.grade])
          if lane.grade == 0 then
            lane.result.text = {"zzz-tips-sim.workshop-mode-result", lane.attempts, string.format("%.1f", lane.ticks / 60)}
            lane.pause = 150
            Z.set_bar(lane.bar, 1)
          end
        end
        lane.info.text = {"zzz-tips-sim.attempts", lane.attempts}
      end
    end
  end)
end)
]=])

-- Режимы производства I/II/III: время операции и ступени новых изделий на уровне контроля 0.
simulations.defects_production_modes = simulation([=[
Z.start(function()
  local base = 40
  local lanes = {
    {x = -7.5, mode = "normal", time = 1, level = 0, roman = "I"},
    {x = 0, mode = "careful", time = 5, level = 4, roman = "II"},
    {x = 7.5, mode = "precise", time = 20, level = 10, roman = "III"},
  }
  Z.power(-9, 9, 5.5)
  Z.text({0, -4.7}, {"zzz-tips-sim.production-modes-title"}, {scale = 1.15})
  for _, lane in ipairs(lanes) do
    Z.create("assembling-machine-1", {lane.x, -0.5})
    Z.text({lane.x, -3.8}, {"", lane.roman, ". ", {"ic-quality.mode-" .. lane.mode}}, {scale = 1.1})
    Z.text({lane.x, -3.1}, {"zzz-tips-sim.production-mode-" .. lane.mode}, {scale = 0.8, font = "default", color = {1, 0.85, 0.4}})
    Z.text({lane.x, -2.5}, {"zzz-tips-sim.production-mode-" .. lane.mode .. "-effect"}, {scale = 0.8, font = "default", color = {1, 0.85, 0.4}})
    lane.bar = Z.bar(lane.x - 1.5, 1.2, 3, {0.4, 0.8, 1, 1})
    lane.counts = {}
    for grade = -5, 0 do lane.counts[grade] = 0 end
    lane.summary = Z.text({lane.x, 2.4}, "", {scale = 0.8, font = "default"})
    lane.summary2 = Z.text({lane.x, 3.2}, "", {scale = 0.8, font = "default"})
    lane.i = 0
  end
  local function summary(lane)
    local a, b = {""}, {""}
    for grade = -5, 0 do
      local target = grade < -2 and a or b
      target[#target + 1] = Z.qicon(Z.grades[grade]) .. lane.counts[grade] .. "  "
    end
    lane.summary.text, lane.summary2.text = a, b
  end
  for _, lane in ipairs(lanes) do summary(lane) end
  Z.on_tick(function()
    for _, lane in ipairs(lanes) do
      lane.i = lane.i + 1
      local n = base * lane.time
      Z.set_bar(lane.bar, lane.i / n)
      if lane.i >= n then
        lane.i = 0
        local grade = Z.draw(lane.level)
        lane.counts[grade] = lane.counts[grade] + 1
        local token = Z.token("iron-chest", Z.grades[grade], {lane.x, -0.5})
        Z.move(token, {lane.x, -1.9}, 30, function(item) Z.destroy(item) end)
        summary(lane)
      end
    end
  end)
end)
]=])

-- Контрольный пост: заказ «строго обычное ×10»; годное вперёд, брак влево в мастерскую
-- и обратно на пост, излишек и чужое — вправо.
simulations.defects_post = simulation([=[
Z.start(function()
  Z.create("ic-control-post", {0, 0})
  Z.workshop({-7, 0})
  Z.create("wooden-chest", {0.5, -4.5})
  Z.create("wooden-chest", {7.5, 0.5})
  Z.line({0, 5}, {0, 1.6}, {0.8, 0.8, 0.8, 0.6}, 4)
  Z.line({0, -1.6}, {0, -3.8}, {0.3, 0.9, 0.3, 0.8}, 5)
  Z.line({-1.6, 0}, {-5.4, 0}, {1, 0.8, 0.2, 0.8}, 5)
  Z.line({-7, 1.6}, {-7, 4}, {1, 0.8, 0.2, 0.5}, 3)
  Z.line({-7, 4}, {0, 4}, {1, 0.8, 0.2, 0.5}, 3)
  Z.line({1.6, 0}, {6.8, 0}, {0.6, 0.6, 0.6, 0.8}, 5)
  Z.text({1.4, -3}, {"zzz-tips-sim.post-good"}, {align = "left", scale = 0.85, color = {0.5, 1, 0.5}})
  Z.text({-3.5, -0.6}, {"zzz-tips-sim.post-refine"}, {scale = 0.85, color = {1, 0.85, 0.3}})
  Z.text({4.2, -0.6}, {"zzz-tips-sim.post-other"}, {scale = 0.85, color = {0.8, 0.8, 0.8}})
  Z.text({0.6, 5.2}, {"zzz-tips-sim.post-input"}, {align = "left", scale = 0.85, font = "default"})
  local order = Z.text({-10.5, -4.5}, "", {align = "left", scale = 0.95})
  local accepted, spawned, hold = 0, 0, 0
  local goal = 10
  local function refresh() order.text = {"zzz-tips-sim.post-order", accepted, goal} end
  refresh()
  local route
  local function to_post(token)
    Z.move(token, {0, 0}, 20, route)
  end
  route = function(token)
    if token.item ~= "burner-mining-drill" or (accepted >= goal and token.quality == "normal") then
      Z.move(token, {7, 0}, 45, function(t) Z.destroy(t) end)
    elseif token.quality == "normal" then
      accepted = accepted + 1
      refresh()
      Z.move(token, {0, -4}, 30, function(t) Z.destroy(t) end)
    else
      Z.move(token, {-7, 0}, 45, function(t)
        local after = Z.refine(Z.grade_of(t.quality))
        Z.set_quality(t, Z.grades[after])
        Z.path(t, {{-7, 4}, {0, 4}}, 30, to_post)
      end)
    end
  end
  Z.on_tick(function(t)
    if accepted >= goal then
      hold = hold + 1
      if hold > 240 then accepted, hold = 0, 0 refresh() end
    end
    if t % 45 == 0 then
      spawned = spawned + 1
      local item = spawned % 7 == 0 and "iron-chest" or "burner-mining-drill"
      local token = Z.token(item, Z.grades[Z.draw(7)], {0, 5.5})
      Z.move(token, {0, 1.4}, 40, to_post)
    end
  end)
end)
]=])

---------------------------------------------------------------------------------------------------
-- Качество
---------------------------------------------------------------------------------------------------

-- Один столб и один автомат меняют качество по кругу: покрытие, провод, скорость, здоровье.
simulations.quality = simulation([=[
Z.start(function()
  Z.unlock_all()
  -- Three tiers: the supply area of higher tiers does not fit the scene.
  local tiers = Z.positive(3)
  Z.power(3.5, 9, 5.5)
  local pole_proto, machine_proto = prototypes.entity["small-electric-pole"], prototypes.entity["assembling-machine-2"]
  local index, wait = 1, 0
  local pole, machine
  local area = Z.rect({0, 0}, {0, 0}, {0.15, 0.35, 0.6, 0.3}, true)
  local frame = Z.rect({0, 0}, {0, 0}, {0.4, 0.7, 1, 1}, false)
  local title = Z.text({0, -4.6}, "", {scale = 1.4})
  local pole_info = Z.text({-6, 4.3}, "", {scale = 0.85, font = "default"})
  local machine_info = Z.text({6, 4.3}, "", {scale = 0.85, font = "default"})
  local function show()
    local quality = tiers[index]
    if pole and pole.valid then pole.destroy() end
    if machine and machine.valid then machine.destroy() end
    pole = Z.create("small-electric-pole", {-5.5, 0.5}, quality.name)
    machine = Z.create("assembling-machine-2", {6, 0}, quality.name)
    local d = pole_proto.get_supply_area_distance(quality.name)
    local left_top, right_bottom = {-5.5 - d, 0.5 - d}, {-5.5 + d, 0.5 + d}
    area.left_top, area.right_bottom = left_top, right_bottom
    frame.left_top, frame.right_bottom = left_top, right_bottom
    title.text = Z.qname(quality.name)
    pole_info.text = {"zzz-tips-sim.pole", string.format("%.1f", d * 2), string.format("%.1f", pole_proto.get_max_wire_distance(quality.name))}
    machine_info.text = {"zzz-tips-sim.machine-quality", string.format("%.2f", machine_proto.get_crafting_speed(quality.name)),
      tostring(math.floor(machine_proto.get_max_health(quality.name) + 0.5))}
  end
  show()
  Z.on_tick(function()
    wait = wait + 1
    if wait >= 150 then
      wait = 0
      index = index % #tiers + 1
      show()
    end
  end)
end)
]=])

-- Четыре автомата II с модулями качества делают шестерни; движок сам бросает качество.
-- Справа — факт против расчёта «эффект × шанс перехода».
simulations.quality_modules = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  local module = "quality-module-3"
  local machines = {}
  local positions = {{-9, -1.5}, {-5.5, -1.5}, {-9, 2}, {-5.5, 2}}
  local slots = 0
  for _, position in ipairs(positions) do
    local entity = Z.machine("assembling-machine-3", position, "normal", "iron-gear-wheel")
    local modules = entity.get_module_inventory()
    slots = #modules
    modules.insert{name = module, count = #modules}
    machines[#machines + 1] = {entity = entity}
  end
  local effect = (prototypes.item[module].get_module_effects("normal").quality or 0) * slots
  local tiers = Z.positive(4)
  local names = {}
  for i, q in ipairs(tiers) do names[i] = q.name end
  local hist = Z.histogram(0.5, -2.4, names, 4.5, 1.1, true)
  -- expected share: stay / +1 / +2 / +3 and more from normal ingredients
  local n, u, r = tiers[1], tiers[2], tiers[3]
  local reach1 = math.min(1, effect * n.next_probability)
  local reach2 = reach1 * (u.next_probability or 0)
  local reach3 = reach2 * (r.next_probability or 0)
  local expected = {1 - reach1, reach1 - reach2, reach2 - reach3, reach3}
  for i, q in ipairs(names) do
    Z.text({7.9, hist.rows[q].y + 0.45}, {"zzz-tips-sim.expected", Z.pct(expected[i])}, {align = "left", scale = 0.7, font = "default", color = {1, 0.85, 0.4}})
  end
  Z.text({0, -4.6}, {"zzz-tips-sim.modules-title", slots, "[item=" .. module .. "]", Z.pct(effect / 10), Z.pct(reach1)}, {scale = 1})
  Z.on_tick(function(t)
    if t % 30 ~= 0 then return end
    for _, m in ipairs(machines) do
      Z.feed(m.entity, "iron-gear-wheel", "normal", 4)
      for _, stack in pairs(Z.take(m.entity)) do
        local row = hist.rows[stack.quality]
        if not row then
          row = hist.rows[names[#names]]
        end
        Z.hist_add(hist, row.name, stack.count)
      end
    end
    if hist.total >= 600 then Z.hist_reset(hist) end
  end)
end)
]=])

-- Таблица шансов по ступеням для разных наборов модулей (окно, как в подсказке DLC «Качество»).
simulations.quality_ladder = simulation([=[
Z.start(function()
  Z.unlock_all()
  local player = sim.create_test_player{name = "Quality"}
  player.teleport({0, 12})
  sim.camera_player = player
  sim.camera_position = {0, 0}
  local sets = {}
  for _, entry in ipairs({{"quality-module", 1}, {"quality-module", 4}, {"quality-module-3", 4}, {"bob-quality-module-5", 4}}) do
    if prototypes.item[entry[1]] then sets[#sets + 1] = entry end
  end
  local tiers = Z.positive(10)
  local frame
  local function build(set)
    if frame and frame.valid then frame.destroy() end
    local effect = (prototypes.item[set[1]].get_module_effects("normal").quality or 0) * set[2]
    frame = player.gui.screen.add{type = "frame", caption = {"zzz-tips-sim.ladder-title"}, direction = "vertical"}
    frame.auto_center = true
    local inner = frame.add{type = "frame", style = "inside_shallow_frame_with_padding", direction = "vertical"}
    inner.add{type = "label", caption = {"zzz-tips-sim.ladder-modules", set[2], "[item=" .. set[1] .. "]", Z.pct(effect / 10)}, style = "bold_label"}
    local grid = inner.add{type = "table", column_count = 6, style = "bordered_table"}
    for _, key in ipairs({"input", "step", "stay", "plus1", "plus2", "plus3"}) do
      grid.add{type = "label", caption = {"zzz-tips-sim.ladder-" .. key}, style = "bold_label"}
    end
    for _, q in ipairs(tiers) do
      local a = q.next and math.min(1, effect * q.next_probability) or 0
      local b = q.next and q.next.next and a * q.next.next_probability or 0
      local c = q.next and q.next.next and q.next.next.next and b * q.next.next.next_probability or 0
      grid.add{type = "label", caption = Z.qname(q.name)}
      grid.add{type = "label", caption = string.format("%.3f", q.next_probability or 0)}
      grid.add{type = "label", caption = Z.pct(1 - a)}
      grid.add{type = "label", caption = Z.pct(a - b)}
      grid.add{type = "label", caption = Z.pct(b - c)}
      grid.add{type = "label", caption = Z.pct(c)}
    end
  end
  local index = 1
  build(sets[index])
  Z.on_tick(function(t)
    if t % 240 == 0 then
      index = index % #sets + 1
      build(sets[index])
    end
  end)
end)
]=])

-- Рецепт выбранного качества: обычные, хорошие и добротные пластины дают шестерни того же качества.
simulations.quality_ingredients = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  local tiers = Z.positive(3)
  local lanes = {}
  for i, q in ipairs(tiers) do
    local x = -7.5 + (i - 1) * 7.5
    local lane = {x = x, quality = q.name}
    lane.entity = Z.machine("assembling-machine-2", {x, -0.5}, "normal", "iron-gear-wheel", q.name)
    lane.last = lane.entity.products_finished
    Z.text({x, -3}, "[item=iron-plate,quality=" .. q.name .. "] → [item=iron-gear-wheel,quality=" .. q.name .. "]", {scale = 1.3})
    Z.text({x, -2.2}, Z.qname(q.name), {scale = 0.85, font = "default"})
    lanes[#lanes + 1] = lane
  end
  Z.text({0, -4.6}, {"zzz-tips-sim.ingredients-title"}, {scale = 1.1})
  Z.on_tick(function(t)
    for _, lane in ipairs(lanes) do
      if t % 30 == 0 then Z.feed(lane.entity, "iron-gear-wheel", lane.quality, 4) end
      local done = lane.entity.products_finished
      if done > lane.last then
        lane.last = done
        for _, stack in pairs(Z.take(lane.entity)) do
          local token = Z.token(stack.name, stack.quality, {lane.x, 0.5})
          Z.move(token, {lane.x, 3.8}, 45, function(item) Z.destroy(item) end)
        end
      end
    end
  end)
end)
]=])

-- Режимы I/II/III с одинаковыми модулями: шанс за операцию растёт, повышений в минуту — нет.
simulations.quality_modes = simulation([=[
Z.start(function()
  Z.unlock_all()
  local module = "quality-module-3"
  local effect = (prototypes.item[module].get_module_effects("normal").quality or 0) * 2
  local normal = prototypes.quality.normal
  local base = 30
  local lanes = {
    {x = -7.5, mode = "normal", time = 1, rolls = 1, roman = "I"},
    {x = 0, mode = "careful", time = 5, rolls = 3, roman = "II"},
    {x = 7.5, mode = "precise", time = 20, rolls = 10, roman = "III"},
  }
  Z.power(-9, 9, 5.5)
  Z.text({0, -4.7}, {"zzz-tips-sim.quality-modes-title", "[item=" .. module .. "]"}, {scale = 1})
  for _, lane in ipairs(lanes) do
    local entity = Z.create("assembling-machine-3", {lane.x, -0.5})
    pcall(function() local m = entity.get_module_inventory() m.insert{name = module, count = #m} end)
    local chance = 1 - (1 - math.min(1, effect * normal.next_probability)) ^ lane.rolls
    Z.text({lane.x, -3.4}, {"", lane.roman, ". ", {"ic-quality.mode-" .. lane.mode}}, {scale = 1.1})
    Z.text({lane.x, -2.5}, {"zzz-tips-sim.quality-mode-chance", Z.pct(chance), lane.time}, {scale = 0.75, font = "default", color = {1, 0.85, 0.4}})
    lane.bar = Z.bar(lane.x - 1.5, 1.2, 3, {0.4, 0.8, 1, 1})
    lane.info = Z.text({lane.x, 2.4}, "", {scale = 0.85, font = "default"})
    lane.rate = Z.text({lane.x, 3.3}, {"zzz-tips-sim.per-minute", string.format("%.1f", 3600 / (base * lane.time) * chance)}, {scale = 0.85, font = "default", color = {0.6, 1, 0.6}})
    lane.i, lane.crafts, lane.up = 0, 0, 0
  end
  Z.on_tick(function()
    for _, lane in ipairs(lanes) do
      lane.i = lane.i + 1
      local n = base * lane.time
      Z.set_bar(lane.bar, lane.i / n)
      if lane.i >= n then
        lane.i = 0
        lane.crafts = lane.crafts + 1
        local result = Z.upgrade(normal, effect, lane.rolls)
        if result.name ~= "normal" then lane.up = lane.up + 1 end
        local token = Z.token("iron-gear-wheel", result.name, {lane.x, -0.5})
        Z.move(token, {lane.x, -1.9}, 30, function(item) Z.destroy(item) end)
        lane.info.text = {"zzz-tips-sim.crafts-upgrades", lane.crafts, lane.up}
      end
    end
  end)
end)
]=])

-- Переработчик 4 с модулями качества разбирает сундуки: 25% железа, качество может вырасти.
simulations.quality_recycling = simulation([=[
Z.start(function()
  Z.unlock_all()
  Z.power(-9, 9, 5.5)
  local recycler = Z.create("recycler", {-6, 0})
  local slots = 0
  pcall(function() local m = recycler.get_module_inventory() slots = #m m.insert{name = "quality-module-3", count = #m} end)
  local tiers = Z.positive(4)
  local names = {}
  for i, q in ipairs(tiers) do names[i] = q.name end
  local hist = Z.histogram(1.5, -2, names, 4.5, 1.1, true)
  Z.text({-6, -3.3}, {"zzz-tips-sim.recycling-in", "[item=iron-chest]", slots, "[item=quality-module-3]"}, {scale = 0.9})
  Z.text({4, -4.6}, {"zzz-tips-sim.recycling-title"}, {scale = 1.1})
  local returned = Z.text({-6, 3.4}, "", {scale = 0.85, font = "default"})
  local fed, got = 0, 0
  Z.on_tick(function(t)
    if t % 30 ~= 0 then return end
    local input = Z.input(recycler)
    local have = input.get_item_count({name = "iron-chest", quality = "normal"})
    if have < 5 then
      input.insert{name = "iron-chest", count = 5 - have}
      fed = fed + 5 - have
    end
    for _, stack in pairs(Z.take(recycler)) do
      got = got + stack.count
      if hist.rows[stack.quality] then Z.hist_add(hist, stack.quality, stack.count) end
    end
    returned.text = {"zzz-tips-sim.recycling-out", got}
    if hist.total >= 1000 then Z.hist_reset(hist) end
  end)
end)
]=])

return simulations
