-- Paranoidal: animations of the "Robot attrition" tips (data.lua).
-- The tips were text only because of the note "simulations crash in the build" (2026-10-30). It repeated the cause
-- found on 2026-10-22 (zzzparanoidal removals/tips-and-tricks.lua): the vanilla "Bulk crafting" scene asks the
-- crafting window for the transport-belt recipe slot (game.simulation.get_widget_position), gets nil in this build and
-- fails in game.simulation.move_cursor{position = nil}. These scenes use no test player, cursor, widget or GUI: only
-- entities, rendering, force values and the mod's remote interface on the simulation surface.
--
-- Live: every scene loads the mod's script (field mods) and builds a real logistic network (roboport, chests,
-- logistic and construction robots) of its own force. The mod checks only forces with players, so the scene turns
-- its force on with the remote set_force_enabled and raises the crash rate of its surface with set_surface_multiplier
-- (the factor is written on screen); the mod itself picks the robots, leaves the wrecks, explodes, burns and
-- detonates. The scene listens to the mod's event on_robot_crashed only for the markers and labels. The mod creates
-- no hidden surfaces.
-- Copied from the mod (keep in sync, risk of drift): the load of scripts/model.lua (busy x busy_weight + waiting x
-- queue_weight) in the jam scene, the reliability formula of scripts/reliability.lua and the dispatch and storm
-- multipliers of scripts/model.lua in the chart of the reliability scene; their numbers come from shared.lua (K).
-- Shown faster than in the game: the crash rate (factor on screen) and, in the jam scene, the batteries (the scene
-- empties them, as long flights would).
local shared = require("shared")

local K = {
  setting = shared.setting,
  setting_cargo = shared.setting_cargo,
  min_busy = shared.min_busy,
  busy_weight = shared.busy_weight,
  queue_weight = shared.queue_weight,
  quality_k = shared.quality_k,
  dispatch_levels = shared.dispatch_levels,
  dispatch_multiplier = shared.dispatch_multiplier,
  dispatch_prefix = shared.dispatch_prefix,
  technology = shared.technology,
  safety_per_level = shared.safety_per_level,
  storm_start = shared.storm_start,
  storm_span = shared.storm_span,
  storm_cap = shared.storm_cap,
  repair_packs = shared.repair_packs,
  repair_success = shared.repair_success,
  explosive_loss = shared.explosive_loss,
  flammable_mj = shared.flammable_fuel_value / 1e6,
  crash_rings = shared.crash_rings,
  cargo_rings = shared.cargo_rings,
  explosion = shared.explosion_entity,
  cargo_explosion = shared.cargo_explosion_entity,
  wreck = shared.wreck_item_prefix .. "logistic-robot",
  repair = shared.repair_recipe_prefix .. "logistic-robot",
}

local PRELUDE = "local K = " .. serpent.line(K, { comment = false }) .. "\n" .. [=[
local surface = game.surfaces[1]
local sim = game.simulation
local MOD = "paranoidal-robot-attrition"
local force = game.forces.player
local pending, wrecks, remnants = {}, {}, nil
S = {t = 0, stats = {first = {}, crashes = 0, booms = 0, quiet = 0, detonated = 0, ignited = 0, wrecks = 0, collected = 0}}
sim.hide_cursor = true
surface.always_day = true

function S.fail(message)
  if S.err then return end
  S.err = type(message) == "table" and serpent.line(message) or tostring(message)
  pcall(log, "pra tips simulation: " .. S.err)
  pcall(rendering.draw_text, {text = {"pra-tips-sim.error", type(message) == "table" and message or S.err},
    surface = surface, target = S.cam or {0, 0}, color = {1, 0.35, 0.35}, scale = 1.5, alignment = "center"})
end

-- build() on the first tick, when the scripts of the simulation's mods are initialised; it sets S.tick(t)
function S.run(build)
  script.on_nth_tick(1, function()
    if S.err then return end
    S.t = S.t + 1
    local ok, message = true, nil
    if S.t == 1 then ok, message = pcall(build) end
    if ok and S.t > 1 and S.tick then ok, message = pcall(S.tick, S.t) end
    if ok then ok, message = pcall(S.watch) end
    if not ok then S.fail(message) end
  end)
end

function S.event(kind)
  if not S.stats.first[kind] then S.stats.first[kind] = S.t end
end

-- Camera of the tips window (1408x704 px); text keeps one size on screen whatever the zoom.
function S.camera(position, zoom)
  sim.camera_position = position
  sim.camera_zoom = zoom
  S.cam, S.zoom = position, zoom
end

-- options.scale is relative: 1 = about 24 px high in the window
function S.text(target, text, options)
  options = options or {}
  return rendering.draw_text{text = text, surface = surface, target = target, color = options.color or {1, 1, 1},
    scale = 1.6 * (options.scale or 1) / (S.zoom or 1), font = options.font or "default-bold",
    alignment = options.align or "center", vertical_alignment = "middle", use_rich_text = true,
    time_to_live = options.ttl}
end
function S.rect(left_top, right_bottom, color, filled)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = 2}
end
function S.circle(target, radius, color, ttl, width, filled)
  return rendering.draw_circle{surface = surface, target = target, radius = radius, color = color, width = width or 2,
    filled = filled or false, time_to_live = ttl, draw_on_ground = filled or nil}
end
function S.board(x1, y1, x2, y2)
  surface.build_checkerboard{{x1, y1}, {x2, y2}}
end

-- Numbers with the locale decimal separator, trailing zero dropped
function S.num(x, digits)
  digits = digits or 1
  local m = 10 ^ digits
  local v = math.floor(math.abs(x) * m + 0.5)
  local whole, frac = math.floor(v / m), v - math.floor(v / m) * m
  if digits > 0 and frac ~= 0 then
    local f = string.format("%0" .. digits .. "d", frac):gsub("0+$", "")
    return {"", tostring(whole), {"pra-tips-sim.dec"}, f}
  end
  return tostring(whole)
end
function S.pct(r) return tostring(math.floor(r * 100 + 0.5)) .. " %" end

-- Own forces: no players (the mod is told to check them), own research. The mod's script is needed (field mods).
local own = {}
local function own_force(key)
  local f = game.forces["pra-tips-" .. key] or game.create_force("pra-tips-" .. key)
  f.worker_robots_speed_modifier = 1
  own[f.index] = true
  return f
end
function S.setup(key, multiplier)
  force = own_force(key)
  S.force = force
  if not remote.interfaces[MOD] then
    S.fail({"pra-tips-sim.no-script"})
    return false
  end
  remote.call(MOD, "set_force_enabled", force.name, true)
  remote.call(MOD, "set_surface_multiplier", surface.index, multiplier)
  S.multiplier = multiplier
  local ids = remote.call(MOD, "get_event_ids")
  script.on_event(ids.on_robot_crashed, function(event)
    if event.surface_index ~= surface.index or not own[event.force.index] then return end
    local ok, message = pcall(S.crashed, event)
    if not ok then S.fail(message) end
  end)
  return true
end

-- Footer: how much faster the crashes are here; a map with crashes turned off says so
function S.footer(position)
  local options = {scale = 0.55, font = "default", align = "right", color = {0.7, 0.7, 0.7}}
  if settings.global[K.setting].value <= 0 then
    return S.text(position, {"", {"pra.panel-off"}, " ", {"pra-tips-sim.setting-off"}}, {scale = 0.6, align = "right", color = {1, 0.6, 0.4}})
  end
  return S.text(position, {"pra-tips-sim.faster", S.multiplier}, options)
end

-- A second network of its own force on the same surface (same crash rate); S.use picks the force to build with
function S.second(key)
  local f = own_force(key)
  remote.call(MOD, "set_force_enabled", f.name, true)
  return f
end
function S.use(f) force = f end

function S.create(name, position, extra)
  local spec = {name = name, position = position, force = force, create_build_effect_smoke = false}
  for key, value in pairs(extra or {}) do spec[key] = value end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. "," .. position[2]) end
  return entity
end

-- Power: the hidden electric interface of the base game (no picture, no collision) under a medium pole
function S.power(position)
  local pole = S.create("medium-electric-pole", position)
  pole.destructible = false
  S.create("hidden-electric-energy-interface", position)
  return pole
end

function S.roboport(position, robots, builders)
  local port = S.create("roboport", position)
  port.destructible = false
  port.energy = port.electric_buffer_size or 0
  local pole = S.power({position[1] + 2.5, position[2] + 2.5})
  if robots and robots > 0 then port.insert{name = "logistic-robot", count = robots} end
  if builders and builders > 0 then port.insert{name = "construction-robot", count = builders} end
  return port, pole
end

function S.chest(name, position)
  local chest = S.create(name, position)
  chest.destructible = false
  return chest
end

function S.request(chest, item, count)
  local sections = chest.get_logistic_sections()
  local section = sections.get_section(1) or sections.add_section()
  if count and count > 0 then section.set_slot(1, {value = item, min = count}) else section.clear_slot(1) end
end

-- A logistic network: a roboport with robots, passive providers with the cargo, requesters that always want it
-- (S.feed empties them), a storage chest for the wreck contents
function S.network(spec)
  local net = {items = spec.items, item = spec.items[1], providers = {}, requesters = {}, builders = spec.builders}
  net.port, net.pole = S.roboport(spec.roboport, spec.robots, spec.builders)
  for _, p in ipairs(spec.providers) do net.providers[#net.providers + 1] = S.chest("passive-provider-chest", p) end
  for _, p in ipairs(spec.requesters) do
    local chest = S.chest("requester-chest", p)
    S.request(chest, net.item, 1000)
    net.requesters[#net.requesters + 1] = chest
  end
  if spec.storage then net.storage = S.chest("storage-chest", spec.storage) end
  S.feed(net)
  return net
end
function S.feed(net)
  for _, chest in ipairs(net.providers) do
    for _, item in ipairs(net.items) do
      local have = chest.get_item_count(item)
      if have < 400 then chest.insert{name = item, count = 400 - have} end
    end
  end
  for _, chest in ipairs(net.requesters) do chest.clear_items_inside() end
  -- the storage chest keeps the wreck items; cargo from the wrecks is removed before it fills up
  if net.storage and net.storage.valid then
    local inventory = net.storage.get_inventory(defines.inventory.chest)
    if inventory.count_empty_stacks() < 16 then
      for _, item in ipairs(inventory.get_contents()) do
        if item.name ~= K.wreck then inventory.remove{name = item.name, count = item.count, quality = item.quality} end
      end
    end
  end
end
function S.want(net, item, count)
  net.item = item
  for _, chest in ipairs(net.requesters) do S.request(chest, item, count) end
end
-- busy, all logistic robots and the network, as the mod counts them
function S.busy(net)
  local n = net.port.valid and net.port.logistic_network
  if not n then return 0, 0, nil end
  return n.all_logistic_robots - n.available_logistic_robots, n.all_logistic_robots, n
end
-- robots waiting to charge (scripts/model.lua M.queues reads the same cell counters)
function S.waiting(n)
  local w = 0
  for _, cell in ipairs(n.cells) do w = w + cell.to_charge_robot_count end
  return w
end
-- also the construction robots (explosions and fire kill some of them)
function S.top_up(net, total)
  local _, all, n = S.busy(net)
  if all < total then net.port.insert{name = "logistic-robot", count = total - all} end
  local builders = net.builders or 0
  if n and n.all_construction_robots < builders then
    net.port.insert{name = "construction-robot", count = builders - n.all_construction_robots}
  end
end
-- docked robots above total go out of the network
function S.trim(net, total)
  local _, all = S.busy(net)
  if all > total then net.port.remove_item{name = "logistic-robot", count = all - total} end
end

-- A crash reported by the mod (raised before the robot dies; the wreck already holds the cargo)
function S.crashed(event)
  local robot = event.robot
  if not (robot and robot.valid) then return end
  local at = robot.position
  S.stats.crashes = S.stats.crashes + 1
  S.event("crash")
  if event.detonated then
    S.stats.detonated = S.stats.detonated + 1
    S.event("detonate")
  end
  if event.ignited then
    S.stats.ignited = S.stats.ignited + 1
    S.event("fire")
  end
  S.circle(at, 0.9, {1, 0.3, 0.2, 1}, 100, 3)
  pending[#pending + 1] = {t = S.t + 1, at = at, event = event}
  local wreck = event.wreck
  if wreck and wreck.valid then
    S.stats.wrecks = S.stats.wrecks + 1
    local parts, items = {""}, {}
    for _, item in ipairs(wreck.get_inventory(defines.inventory.chest).get_contents()) do
      items[item.name] = item.count
      parts[#parts + 1] = "[item=" .. item.name .. "]" .. (item.count > 1 and ("×" .. item.count) or "") .. " "
    end
    local label = S.text({at.x, at.y - 1.3}, parts, {scale = 1, font = "default"})
    wrecks[#wrecks + 1] = {e = wreck, label = label}
    if S.on_wreck then S.on_wreck(wreck, items, event) end
  end
  if S.on_crash then S.on_crash(event, at) end
end

-- A tick after a crash: did the mod's crash explosion go off (Swarm safety removes it)?
function S.watch()
  for i = #pending, 1, -1 do
    local p = pending[i]
    if S.t >= p.t then
      table.remove(pending, i)
      local boom = surface.count_entities_filtered{name = K.explosion, position = p.at, radius = 2} > 0
      if boom then
        S.stats.booms = S.stats.booms + 1
        S.event("boom")
      else
        S.stats.quiet = S.stats.quiet + 1
        S.event("quiet")
      end
      if S.after_crash then S.after_crash(p, boom) end
    end
  end
  -- Remnants (dead robots, also those hit by an explosion or fire; destroyed belts) go 2-4 s later: cosmetic, the
  -- wreck of the mod stays until it is picked up
  if S.t % 120 == 0 then
    local now = {}
    for _, corpse in ipairs(surface.find_entities_filtered{type = "corpse"}) do
      if corpse.name:find("remnants", 1, true) then
        local key = string.format("%.2f,%.2f,%s", corpse.position.x, corpse.position.y, corpse.name)
        if remnants and remnants[key] then corpse.destroy() else now[key] = true end
      end
    end
    remnants = now
  end
  for i = #wrecks, 1, -1 do
    local w = wrecks[i]
    if not w.e.valid then
      if w.label.valid then w.label.destroy() end
      table.remove(wrecks, i)
      S.stats.collected = S.stats.collected + 1
      S.event("collected")
    end
  end
end

-- Damage at the centre, at the edge and the radius of an explosion: each ring adds its damage inside its radius
function S.reach(rings)
  local total = 0
  for _, ring in ipairs(rings) do total = total + ring[2] end
  return total, rings[#rings][2], rings[#rings][1]
end

-- Damage rings of an explosion (data-final-fixes.lua)
function S.rings(at, rings, color, ttl)
  local total = 0
  for _, ring in ipairs(rings) do total = total + ring[2] end
  local side = at.x > (S.cam and S.cam[1] or 0) and -1 or 1  -- numbers on the side towards the middle
  for _, ring in ipairs(rings) do
    S.circle(at, ring[1], color, ttl, 2)
    S.text({at.x + side * ring[1], at.y}, tostring(total), {scale = 0.6, color = color, ttl = ttl})
    total = total - ring[2]
  end
end

local GREEN, RED, GREY = {0.55, 1, 0.55}, {1, 0.5, 0.4}, {0.75, 0.75, 0.75}
S.GREEN, S.RED, S.GREY = GREEN, RED, GREY
]=]

local function simulation(body, extra)
  local definition = { init = PRELUDE .. body, mods = { "paranoidal-robot-attrition" } }
  for key, value in pairs(extra or {}) do definition[key] = value end
  return definition
end

local simulations = {}

-- 1. 40 robots: never more than 50 busy, no crashes. 60 more: more than 50 busy, now and then one crashes; its wreck
-- keeps the cargo and construction robots take it to the storage chest. Then the orders end and the cycle repeats.
simulations.intro = simulation([=[
S.run(function()
  S.camera({0, 0.3}, 1.3)
  S.board(-40, -24, 40, 24)
  if not S.setup("intro", 1000) then return end
  local BASE, ADD = 40, 60
  local net = S.network{roboport = {0, 4.5}, robots = BASE, builders = 6, items = {"electronic-circuit"},
    providers = {{-13.5, -2.5}, {-13.5, 0}}, requesters = {{13.5, -2.5}, {13.5, 0}}, storage = {-4, 4.5}}
  S.text({-13.5, -4}, {"pra-tips-sim.providers"}, {scale = 0.55, font = "default", color = S.GREY})
  S.text({13.5, -4}, {"pra-tips-sim.requesters"}, {scale = 0.55, font = "default", color = S.GREY})
  S.text({-4, 6.1}, {"pra-tips-sim.storage"}, {scale = 0.5, font = "default", color = S.GREY})
  local busy_text = S.text({0, -7.3}, "", {scale = 0.85})
  local phase_text = S.text({0, -6.1}, "", {scale = 0.68, font = "default"})
  local crash_text = S.text({-16.2, 7.6}, "", {scale = 0.62, align = "left"})
  S.footer({16.2, 7.6})
  -- a: BASE robots for 10 s; b: ADD more for 25 s; c: no orders until the extra robots have docked and left
  local phase, since = "a", 1
  S.stats.max_a, S.stats.max_b, S.stats.crash_a, S.stats.crash_b, S.stats.cycles = 0, 0, 0, 0, 0
  S.on_crash = function()
    if phase == "a" then S.stats.crash_a = S.stats.crash_a + 1 elseif phase == "b" then S.stats.crash_b = S.stats.crash_b + 1 end
  end
  S.tick = function(t)
    local age = t - since
    if phase == "a" and age >= 600 then
      phase, since = "b", t
      S.top_up(net, BASE + ADD)
      S.event("more")
    elseif phase == "b" and age >= 1500 then
      phase, since = "c", t
      S.want(net, "electronic-circuit", 0)
    elseif phase == "c" then
      if t % 30 == 0 then S.trim(net, BASE) end
      local _, all = S.busy(net)
      if (all <= BASE and age >= 120) or age >= 1200 then
        phase, since = "a", t
        S.want(net, "electronic-circuit", 1000)
        S.stats.cycles = S.stats.cycles + 1
      end
    end
    if t % 300 == 0 then S.feed(net) end
    local busy, all = S.busy(net)
    if phase == "a" then S.stats.max_a = math.max(S.stats.max_a, busy) end
    if phase == "b" then S.stats.max_b = math.max(S.stats.max_b, busy) end
    busy_text.text = {"pra.panel-busy", busy, K.min_busy + 1}
    busy_text.color = busy > K.min_busy and S.RED or S.GREEN
    if phase == "a" then
      phase_text.text = {"pra-tips-sim.intro-a", all, K.min_busy}
    elseif phase == "b" then
      phase_text.text = {"pra-tips-sim.intro-b", ADD, K.min_busy}
    else
      phase_text.text = {"pra-tips-sim.intro-c"}
    end
    crash_text.text = {"pra-tips-sim.crashed", S.stats.crashes, S.stats.collected}
  end
end)
]=], { init_update_count = 60 })

-- 2. Two networks side by side with the same robots, cargo and flights: the batteries run low (the scene empties
-- them, as long flights would). Above, one roboport: a charging queue and the load of the network
-- (busy x 0.5 + waiting x 5, scripts/model.lua) grow, robots crash more often. Below, four roboports: no queue.
simulations.congestion = simulation([=[
S.run(function()
  S.camera({0, 0}, 1.25)
  S.board(-40, -24, 40, 24)
  if not S.setup("congestion-1", 200) then return end
  local ROBOTS = 80
  local nets = {}
  nets[1] = S.network{roboport = {0, -6}, robots = ROBOTS, builders = 4, items = {"iron-gear-wheel"},
    providers = {{-15.5, -5}}, requesters = {{15.5, -5}}, storage = {-4, -6}}
  nets[1].force = S.force
  S.use(S.second("congestion-4"))
  nets[2] = S.network{roboport = {-10.5, 6}, robots = ROBOTS, builders = 4, items = {"iron-gear-wheel"},
    providers = {{-15.5, 4.5}}, requesters = {{15.5, 4.5}}, storage = {-7, 7.5}}
  nets[2].force = game.forces["pra-tips-congestion-4"]
  for _, p in ipairs({{-3.5, 6}, {3.5, 6}, {10.5, 6}}) do S.roboport(p) end
  local max_energy = prototypes.entity["logistic-robot"].get_max_energy()
  local ring = S.circle({0, -6}, 2.7, {1, 0.75, 0.2, 0.9}, nil, 3)
  ring.visible = false
  for i, net in ipairs(nets) do
    local y = i == 1 and -2.25 or 1.3
    net.head = S.text({-17.2, y}, "", {scale = 0.66, align = "left"})
    net.load = S.text({-17.2, y + 0.95}, "", {scale = 0.58, font = "default", align = "left"})
    net.crashes, net.max_queue, net.late_sum, net.late_n = 0, 0, 0, 0
  end
  S.footer({17.2, -0.35})
  S.text({17.2, 0.35}, {"pra-tips-sim.jam-batteries"}, {scale = 0.55, font = "default", align = "right", color = S.GREY})
  S.on_crash = function(event)
    for _, net in ipairs(nets) do
      if event.force.index == net.force.index then net.crashes = net.crashes + 1 end
    end
  end
  -- long flights: a charged robot is emptied again at a random moment, at the earliest 10 s after the last time
  -- (on average every 15 s; random, so that the robots do not come to charge in waves)
  local drained = {}
  local function drain(n)
    for _, robot in ipairs(n.logistic_robots) do
      local last = drained[robot.unit_number] or -600
      if robot.energy > 0.85 * max_energy and S.t - last > 600 and math.random() < 0.05 then
        robot.energy = 0.15 * max_energy
        drained[robot.unit_number] = S.t
      end
    end
  end
  S.tick = function(t)
    for i, net in ipairs(nets) do
      if t % 300 == 0 then
        S.feed(net)
        S.top_up(net, ROBOTS)
      end
      local busy, _, n = S.busy(net)
      if n then
        if t % 15 == 0 then drain(n) end
        local waiting = S.waiting(n)
        net.max_queue = math.max(net.max_queue, waiting)
        if t >= 1800 then net.late_sum, net.late_n = net.late_sum + waiting, net.late_n + 1 end
        local load = busy * K.busy_weight + waiting * K.queue_weight
        local plain = math.max(1, busy * K.busy_weight)
        net.head.text = {"pra-tips-sim.jam-net", i == 1 and {"pra-tips-sim.jam-one"} or {"pra-tips-sim.jam-four", 4},
          busy, waiting}
        net.head.color = waiting >= 5 and {1, 0.8, 0.45} or S.GREEN
        net.load.text = {"pra-tips-sim.load", busy, S.num(K.busy_weight), waiting, S.num(K.queue_weight), S.num(load, 0),
          S.num(load / plain, 1), net.crashes}
        if i == 1 then
          ring.visible = waiting >= 5
          if waiting >= 20 then S.event("queue") end
        end
      end
    end
    S.stats.queue_one, S.stats.queue_four = nets[1].max_queue, nets[2].max_queue
    S.stats.late_one = nets[1].late_n > 0 and math.floor(nets[1].late_sum / nets[1].late_n * 10 + 0.5) / 10 or 0
    S.stats.late_four = nets[2].late_n > 0 and math.floor(nets[2].late_sum / nets[2].late_n * 10 + 0.5) / 10 or 0
    S.stats.crash_one, S.stats.crash_four = nets[1].crashes, nets[2].crashes
  end
end)
]=], { init_update_count = 600 })

-- 3. Wrecks and repair: a crashed robot leaves a wreck with its cargo and the wreck item; construction robots take it
-- to the storage chest, an inserter feeds the wreck items to an assembling machine with the repair recipe (2 repair
-- packs, 75 %), a repaired robot goes back into the roboport.
simulations.wreck = simulation([=[
S.run(function()
  S.camera({0, 0.3}, 1.3)
  S.board(-40, -24, 40, 24)
  if not S.setup("wreck", 1000) then return end
  local ROBOTS = 90
  local net = S.network{roboport = {-5, 4.5}, robots = ROBOTS, builders = 8, items = {"iron-gear-wheel"},
    providers = {{-14, -3}, {-14, -0.5}}, requesters = {{6, -3}, {6, -0.5}}, storage = {9.5, 4.5}}
  local recipe = prototypes.recipe[K.repair]
  if not (recipe and prototypes.item[K.wreck]) then error("no " .. K.repair) end
  local pack
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.name ~= K.wreck then pack = ingredient.name end
  end
  force.recipes[K.repair].enabled = true
  S.power({10.5, 7})
  S.create("inserter", {10.5, 4.5}, {direction = defines.direction.west}).destructible = false
  local bench = S.create("assembling-machine-3", {12.5, 4.5})
  bench.destructible = false
  bench.set_recipe(K.repair)
  net.storage.insert{name = K.wreck, count = 1}
  S.text({-14, -4.5}, {"pra-tips-sim.providers"}, {scale = 0.5, font = "default", color = S.GREY})
  S.text({6, -4.5}, {"pra-tips-sim.requesters"}, {scale = 0.5, font = "default", color = S.GREY})
  S.text({9.5, 2.9}, {"pra-tips-sim.storage"}, {scale = 0.5, font = "default", color = S.GREY})
  S.text({0, -7.3}, {"pra-tips-sim.wreck-title"}, {scale = 0.72})
  S.text({12.5, 0.9}, {"pra-tips-sim.repair-recipe", "[item=" .. K.wreck .. "]", K.repair_packs, "[item=" .. pack .. "]",
    "[item=logistic-robot]", S.pct(K.repair_success)}, {scale = 0.6})
  local score = S.text({12.5, 7.4}, "", {scale = 0.6})
  local crash_text = S.text({-16.2, 7.6}, "", {scale = 0.6, align = "left"})
  S.footer({16.2, -6.1})
  local progress, crafts = 0, 0
  S.stats.repaired, S.stats.failed, S.stats.wreck_items, S.stats.cargo_kept = 0, 0, 0, 0
  S.on_wreck = function(wreck, items)
    if items[K.wreck] then S.stats.wreck_items = S.stats.wreck_items + 1 end
    for name in pairs(items) do if name ~= K.wreck then S.stats.cargo_kept = S.stats.cargo_kept + 1 end end
  end
  S.tick = function(t)
    if t % 300 == 0 then S.feed(net) end
    if t % 60 == 0 then
      S.top_up(net, ROBOTS)
      local input = bench.get_inventory(defines.inventory.crafter_input)
      if input.get_item_count(pack) < K.repair_packs * 2 then bench.insert{name = pack, count = K.repair_packs * 2} end
    end
    -- a finished craft: the progress wraps or drops to zero
    local now = bench.crafting_progress
    if now < progress - 0.5 then
      crafts = crafts + 1
      local output = bench.get_output_inventory()
      local got = 0
      for _, item in ipairs(output.get_contents()) do
        if item.name == "logistic-robot" then
          got = got + item.count
          net.port.insert{name = item.name, count = item.count, quality = item.quality}
        end
      end
      output.clear()
      local at = {bench.position.x, bench.position.y - 2}
      if got > 0 then
        S.stats.repaired = S.stats.repaired + 1
        S.event("repaired")
        S.text(at, {"pra-tips-sim.repair-ok"}, {scale = 0.6, color = S.GREEN, ttl = 120})
        rendering.draw_line{surface = surface, from = bench, to = net.port, color = {0.5, 1, 0.5, 0.8}, width = 3,
          dash_length = 0.3, gap_length = 0.2, time_to_live = 90}
      else
        S.stats.failed = S.stats.failed + 1
        S.event("failed")
        S.text(at, {"pra-tips-sim.repair-fail"}, {scale = 0.6, color = S.RED, ttl = 120})
      end
    end
    progress = now
    score.text = {"pra-tips-sim.repair-score", S.stats.repaired, crafts}
    crash_text.text = {"pra-tips-sim.crashed", S.stats.crashes, S.stats.collected}
  end
end)
]=], { init_update_count = 60 })

-- 4. Cargo: the robots carry ordinary, then flammable, then explosive cargo over a belt. Every crash shows the rings of
-- the crash explosion (data-final-fixes.lua); flammable cargo sets the ground on fire, explosive cargo detonates (its
-- own rings) and loses half of the stack. The belts are repaired between the phases; at a phase change the scene
-- swaps the cargo of the robots in flight.
simulations.cargo = simulation([=[
S.run(function()
  S.camera({0, 0.3}, 1.25)
  S.board(-40, -24, 40, 24)
  if not S.setup("cargo", 300) then return end
  force.worker_robots_storage_bonus = 3
  local ROBOTS = 90
  local PHASES = {
    {item = "iron-gear-wheel", key = "plain"},
    {item = "solid-fuel", key = "fire"},
    {item = "explosives", key = "detonate"},
  }
  local items = {}
  for i, p in ipairs(PHASES) do items[i] = p.item end
  local net = S.network{roboport = {0, 5}, robots = ROBOTS, builders = 6, items = items,
    providers = {{-15.5, -2.5}, {-15.5, 0}}, requesters = {{15.5, -2.5}, {15.5, 0}}, storage = {-4, 5}}
  local belts = {}
  local function lay()
    for x = -12, 12 do
      local belt = belts[x]
      if belt and belt.valid then
        belt.health = belt.max_health
      else
        belt = S.create("transport-belt", {x + 0.5, -1.0}, {direction = defines.direction.east})
        belts[x] = belt
      end
    end
  end
  lay()
  local title = S.text({0, -7.6}, "", {scale = 0.72})
  local detail = S.text({0, -6.5}, "", {scale = 0.58, font = "default"})
  local cargo_off = not settings.global[K.setting_cargo].value
  if cargo_off then S.text({0, -5.6}, {"pra-tips-sim.cargo-off"}, {scale = 0.58, color = S.RED}) end
  local crash_text = S.text({-16.8, 7.8}, "", {scale = 0.58, align = "left"})
  S.footer({16.8, 7.8})
  local CYCLE, LEN, index = 3600, 1200, 1
  S.stats.belts_lost, S.stats.half_lost, S.stats.kinds, S.stats.carry, S.stats.req = 0, 0, {}, {}, {}
  S.after_crash = function(p, boom)
    if boom then S.rings(p.at, K.crash_rings, {1, 0.75, 0.3, 1}, 150) end
    if p.event.detonated then S.rings(p.at, K.cargo_rings, {1, 0.35, 0.25, 1}, 150) end
  end
  S.on_wreck = function(wreck, wreck_items, event)
    local kind = event.detonated and "detonate" or event.ignited and "fire" or "plain"
    S.stats.kinds[kind] = (S.stats.kinds[kind] or 0) + 1
    if event.detonated and (wreck_items.explosives or 0) > 0 then S.stats.half_lost = S.stats.half_lost + 1 end
  end
  S.tick = function(t)
    local c = (t - 2) % CYCLE
    if c % LEN == 0 then
      index = math.floor(c / LEN) + 1
      S.want(net, PHASES[index].item, 1000)
      S.feed(net)
      -- robots in flight get the new cargo at once (otherwise the old one is carried well into the next phase)
      local _, _, n = S.busy(net)
      for _, robot in ipairs(n and n.logistic_robots or {}) do
        local cargo = robot.get_inventory(defines.inventory.robot_cargo)
        if cargo and not cargo.is_empty() and cargo[1].name ~= PHASES[index].item then
          cargo[1].set_stack{name = PHASES[index].item, count = cargo[1].count}
        end
      end
      S.top_up(net, ROBOTS)
      for x, belt in pairs(belts) do if not belt.valid then S.stats.belts_lost = S.stats.belts_lost + 1 end end
      lay()
      S.event("phase-" .. PHASES[index].key)
    end
    if t % 300 == 0 then
      S.feed(net)
      S.top_up(net, ROBOTS)
    end
    local p = PHASES[index]
    if t % 60 == 0 then
      local _, _, n = S.busy(net)
      local carry = S.stats.carry[p.key] or {}
      S.stats.carry[p.key] = carry
      for _, robot in ipairs(n and n.logistic_robots or {}) do
        local cargo = robot.get_inventory(defines.inventory.robot_cargo)
        if cargo and not cargo.is_empty() then carry[cargo[1].name] = (carry[cargo[1].name] or 0) + 1 end
      end
      local slot = net.requesters[1].get_logistic_sections().get_section(1).get_slot(1)
      S.stats.req[p.key] = slot and slot.value and (slot.value.name or tostring(slot.value)) or "none"
    end
    title.text = {"pra-tips-sim.cargo-" .. p.key, "[item=" .. p.item .. "]"}
    if p.key == "plain" then
      local centre, edge, radius = S.reach(K.crash_rings)
      detail.text = {"pra-tips-sim.cargo-plain-detail", centre, edge, S.num(radius)}
    elseif p.key == "fire" then
      detail.text = {"pra-tips-sim.cargo-fire-detail", S.num(K.flammable_mj, 0)}
    else
      local centre, edge, radius = S.reach(K.cargo_rings)
      detail.text = {"pra-tips-sim.cargo-detonate-detail", centre, edge, S.num(radius), S.pct(K.explosive_loss)}
    end
    crash_text.text = {"pra-tips-sim.crashed", S.stats.crashes, S.stats.collected}
  end
end)
]=], { init_update_count = 60, hide_health_bars = false })

-- 5. Reliability. Left, live: robots crash with the explosion until Swarm safety 1 is researched, then without it
-- (up to 500 busy robots per level). Right, a chart from the formulas of the mod: Swarm dispatch levels, storms, robot
-- tiers (health) and quality.
simulations.reliability = simulation([=[
S.run(function()
  S.camera({0, 0.3}, 1.25)
  S.board(-40, -24, 40, 24)
  if not S.setup("reliability", 1000) then return end
  local ROBOTS = 80
  local net = S.network{roboport = {-9.5, 4.5}, robots = ROBOTS, builders = 6, items = {"iron-gear-wheel"},
    providers = {{-16, -3}, {-16, -0.5}}, requesters = {{-2.5, -3}, {-2.5, -0.5}}, storage = {-13.5, 4.5}}
  local tech = force.technologies[K.technology]
  local title = S.text({-9.3, -7.6}, "", {scale = 0.62})
  local state = S.text({-9.3, -6.6}, "", {scale = 0.55, font = "default"})
  local crash_text = S.text({-16.8, 7.8}, "", {scale = 0.55, align = "left"})
  S.footer({-1.2, 7.8})
  local CYCLE, safe = 2400, false
  S.stats.boom_off, S.stats.boom_on, S.stats.quiet_off, S.stats.quiet_on = 0, 0, 0, 0
  S.after_crash = function(p, boom)
    if boom then S.rings(p.at, K.crash_rings, {1, 0.75, 0.3, 1}, 120) end
    if safe then
      if boom then S.stats.boom_on = S.stats.boom_on + 1 else S.stats.quiet_on = S.stats.quiet_on + 1 S.event("safe-crash") end
    else
      if boom then S.stats.boom_off = S.stats.boom_off + 1 else S.stats.quiet_off = S.stats.quiet_off + 1 end
    end
  end

  -- Chart: bars of the crash rate (1 = full) from the formulas of the mod
  local X0, BAR_H = 1.5, 2.2
  local blocks = {}
  local function block(x, y, w, caption, bars)
    S.text({x + w / 2, y - 0.4}, caption, {scale = 0.52})
    local step = w / #bars
    local b = {bars = bars, rects = {}}
    for i, bar in ipairs(bars) do
      local cx = x + step * (i - 0.5)
      local base = y + 0.5 + BAR_H
      S.rect({cx - step * 0.32, y + 0.5}, {cx + step * 0.32, base}, {0.12, 0.12, 0.12, 0.85})
      b.rects[i] = {r = S.rect({cx - step * 0.32, base}, {cx + step * 0.32, base}, bar.color or {0.9, 0.6, 0.3, 1}),
        cx = cx, base = base, half = step * 0.32}
      S.text({cx, base + 0.55}, bar.label, {scale = bar.text and 0.55 or 0.75, font = "default"})
      b.rects[i].value = S.text({cx, base - 0.3}, "", {scale = 0.45})
    end
    blocks[#blocks + 1] = b
  end
  -- Swarm dispatch: x0.85 per level
  local dispatch = {}
  for level = 0, K.dispatch_levels do
    dispatch[#dispatch + 1] = {value = K.dispatch_multiplier ^ level,
      label = level == 0 and "0" or ("[technology=" .. K.dispatch_prefix .. level .. "]"), text = level == 0}
  end
  block(X0, -5.6, 9.4, {"pra-tips-sim.chart-dispatch"}, dispatch)
  -- Storm: above storm_start of the full wind output +1 per storm_span, counted up to storm_cap
  local storm = {}
  for _, output in ipairs({K.storm_start, K.storm_start + K.storm_span, K.storm_cap}) do
    local m = 1 + (math.min(output, K.storm_cap) - K.storm_start) / K.storm_span
    storm[#storm + 1] = {value = m, label = S.pct(output), text = true, max = 3, color = {0.5, 0.75, 1, 1}}
  end
  block(X0 + 10.4, -5.6, 5.4, {"pra-tips-sim.chart-storm"}, storm)
  -- Robot tiers: min(1, health of the vanilla robot / health)
  local tiers, reference = {}, prototypes.entity["logistic-robot"].get_max_health()
  for _, name in ipairs({"logistic-robot", "bob-logistic-robot-2", "bob-logistic-robot-3", "bob-logistic-robot-4", "bob-logistic-robot-5"}) do
    local p = prototypes.entity[name]
    if p and prototypes.item[name] then
      local health = p.get_max_health()
      tiers[#tiers + 1] = {value = health > reference and reference / health or 1, label = "[item=" .. name .. "]"}
    end
  end
  block(X0, 0.6, 7.6, {"pra-tips-sim.chart-tier"}, tiers)
  -- Quality: quality_k / (quality_k + level)
  local qualities = {}
  for _, name in ipairs({"normal", "uncommon", "rare", "epic", "legendary"}) do
    local q = prototypes.quality[name]
    if q and not q.hidden then
      qualities[#qualities + 1] = {value = K.quality_k / (K.quality_k + math.max(0, q.level)), label = "[quality=" .. name .. "]",
        color = {0.75, 0.55, 1, 1}}
    end
  end
  block(X0 + 8.4, 0.6, 7.4, {"pra-tips-sim.chart-quality"}, qualities)
  S.text({X0 + 7.9, 6.9}, {"pra-tips-sim.chart-note"}, {scale = 0.48, font = "default", color = S.GREY})
  S.stats.bars = 0
  for _, b in ipairs(blocks) do S.stats.bars = S.stats.bars + #b.bars end

  S.tick = function(t)
    local c = (t - 2) % CYCLE
    if c == 0 then
      tech.level = 1
      safe = false
    elseif c == 1200 then
      tech.level = 2
      safe = true
      S.event("safety")
    end
    if t % 300 == 0 then
      S.feed(net)
      S.top_up(net, ROBOTS)
    end
    local busy = S.busy(net)
    local level = tech.researched and tech.level or tech.level - 1
    local limit = level * K.safety_per_level
    if limit == 0 then
      title.text = {"pra-tips-sim.safety-off"}
      state.text = {"pra.panel-safety-none"}
      state.color = S.RED
    else
      title.text = {"pra-tips-sim.safety-on", level}
      state.text = busy <= limit and {"pra.panel-safe", limit} or {"pra.panel-unsafe", limit}
      state.color = busy <= limit and S.GREEN or S.RED
    end
    crash_text.text = {"pra-tips-sim.crashed", S.stats.crashes, S.stats.collected}
    -- bars grow at the start of each cycle, one block after another
    for i, b in ipairs(blocks) do
      local f = math.max(0, math.min(1, (c - (i - 1) * 45) / 60))
      for j, bar in ipairs(b.bars) do
        local r = b.rects[j]
        local h = BAR_H * math.min(bar.value, bar.max or 1) / (bar.max or 1) * f
        r.r.left_top = {r.cx - r.half, r.base - h}
        if bar.max then
          r.value.text = {"", "×", S.num(bar.value, 0)}
        else
          r.value.text = S.pct(bar.value)
        end
        r.value.target = {r.cx, r.base - h - 0.3}
      end
    end
  end
end)
]=], { init_update_count = 60 })

return simulations
