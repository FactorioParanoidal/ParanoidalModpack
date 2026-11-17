-- Paranoidal: animations of the "Power districts" tips (prototypes/gui.lua).
-- Live scenes (districts, priorities) load the mod's own script in the tips window (field mods): the transformer is
-- built with raise_built, so the mod registers it, draws the plug icons and the status lamp, moves the energy, sheds
-- and restores districts itself; the scene only lays the wires, changes the power plant and writes captions.
-- Formula scenes (green zone, matching, smoothing) need minutes of the 30 s average or a scheme, so they run the
-- formulas of scripts/engine.lua themselves with the numbers of shared.lua and the startup settings put into the
-- scene text below (K); the lamp uses the mod's own sprites. Machines, transformers, poles and accumulators are
-- real entities; bars, gauges and charts are drawn. An error is shown as text (ppd-tips-sim.error).
local SH = require("shared")

local function rgb(c) return { c.r, c.g, c.b } end

local K = {
  tiers = {},
  limit = SH.LIMIT,
  idle = SH.IDLE,
  tau = SH.TAU,
  tap_step = SH.TAP_STEP,
  hw = settings.startup["ppd-zone-half-width"].value / 100,
  mult = settings.startup["ppd-bonus-multiplier"].value,
  lamp = SH.LAMP,
  tip_in = SH.TIP_IN,
  tip_out = SH.TIP_OUT,
  pole_in = SH.POLE_IN,
  pole_out = SH.POLE_OUT,
  tech_auto = SH.TECH.automation,
  tech_taps = (SH.TECH.taps:gsub("%-$", "")),  -- "ppd-taps": the levels ppd-taps-1/2 share its name
  colors = {},
  -- copy of scripts/engine.lua (M.STATUS diode and colour, LAMP): keep in sync when the statuses change
  status = {
    zone = { diode = "green", color = { 0.56, 0.89, 0.42 } },
    under = { diode = "yellow", color = { 1, 0.85, 0.36 } },
    over = { diode = "yellow", color = { 1, 0.85, 0.36 } },
    limit = { diode = "red", color = { 1, 0.48, 0.41 } },
    idle = { diode = "yellow", color = { 0.7, 0.7, 0.7 } },
    off_auto = { diode = "red", color = { 1, 0.48, 0.41 } },
    noinput = { diode = "red", color = { 1, 0.48, 0.41 } },
    nowire_in = { diode = "red", color = { 1, 0.48, 0.41 } },
    nowire_out = { diode = "yellow", color = { 0.7, 0.7, 0.7 } },
  },
  lamp_color = {
    green = { color = { 0.30, 1, 0.35 }, blink = 0 },
    yellow = { color = { 1, 0.78, 0.12 }, blink = 0 },
    red = { color = { 1, 0.16, 0.10 }, blink = 45 },
  },
}
for _, t in ipairs(SH.TIERS) do
  K.tiers[t.key] = { name = t.name, nominal = t.nominal / 1e6, bonus = t.bonus }
end
for i, c in ipairs(SH.COLORS) do K.colors[i] = rgb(c) end

local PRELUDE = "local K = " .. serpent.line(K, { comment = false }) .. "\n" .. [=[
local surface = game.surfaces[1]
local force = game.forces.player
local sim = game.simulation
local COPPER = defines.wire_connector_id.pole_copper
S = {t = 0, stats = {first = {}}}
sim.hide_cursor = true
surface.always_day = true

function S.fail(message)
  if S.err then return end
  S.err = tostring(message)
  pcall(log, "ppd tips simulation: " .. S.err)
  pcall(rendering.draw_text, {text = {"ppd-tips-sim.error", S.err}, surface = surface, target = S.cam or {0, 0},
    color = {1, 0.35, 0.35}, scale = 1.5, alignment = "center"})
end

-- build() on the first tick, when the scripts of the simulation's mods are initialised; it sets S.tick(t)
function S.run(build)
  script.on_nth_tick(1, function()
    if S.err then return end
    S.t = S.t + 1
    local ok, message = true, nil
    if S.t == 1 then ok, message = pcall(build) end
    if ok and S.t > 1 and S.tick then ok, message = pcall(S.tick, S.t) end
    if ok then ok, message = pcall(S.animate) end
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
    alignment = options.align or "center", vertical_alignment = "middle", use_rich_text = true}
end

function S.rect(left_top, right_bottom, color, filled)
  return rendering.draw_rectangle{surface = surface, left_top = left_top, right_bottom = right_bottom, color = color,
    filled = filled ~= false, width = 2}
end

function S.line(from, to, color, width, dash)
  return rendering.draw_line{surface = surface, from = from, to = to, color = color, width = width or 2,
    dash_length = dash or 0, gap_length = dash or 0}
end

function S.board(x1, y1, x2, y2)
  surface.build_checkerboard{{x1, y1}, {x2, y2}}
end

function S.create(name, position, extra)
  local spec = {name = name, position = position, force = force, create_build_effect_smoke = false}
  for key, value in pairs(extra or {}) do spec[key] = value end
  local entity = surface.create_entity(spec)
  if not entity then error("cannot create " .. name .. " at " .. position[1] .. "," .. position[2]) end
  return entity
end

-- Numbers as the mod writes them (scripts/util.lua U.num): locale decimal separator, trailing zero dropped
function S.num(x, digits)
  digits = digits or 1
  local m = 10 ^ digits
  local v = math.floor(math.abs(x) * m + 0.5)
  local whole = math.floor(v / m)
  local frac = v - whole * m
  if digits > 0 and frac ~= 0 then
    return {"", x < 0 and "−" or "", tostring(whole), {"ppd-unit.dec"}, string.format("%0" .. digits .. "d", frac)}
  end
  return {"", x < 0 and "−" or "", tostring(whole)}
end
function S.mw(x, digits) return {"", S.num(x, digits or 1), " ", {"ppd-unit.mw"}} end
function S.pct(r) return {"", tostring(math.floor(r * 100 + 0.5)), " %"} end
function S.hex(c)
  return string.format("%d,%d,%d", math.floor(c[1] * 255), math.floor(c[2] * 255), math.floor(c[3] * 255))
end

-- Copper wires
function S.wire(a, b)
  local ok = a.get_wire_connector(COPPER, true).connect_to(b.get_wire_connector(COPPER, true), false)
  if not ok then error("no wire " .. a.name .. " - " .. b.name) end
end
function S.unwire(a, b)
  a.get_wire_connector(COPPER, true).disconnect_from(b.get_wire_connector(COPPER, true))
end
-- automatic wires of new poles go: every wire of the scene is laid by hand
function S.bare(poles)
  for _, pole in ipairs(poles) do pole.get_wire_connector(COPPER, true).disconnect_all() end
end

-- An invisible power source: the mod's own hidden output interface (no picture, no collision) set to produce,
-- placed under a pole. mw = nil makes it unlimited.
function S.source(position, mw)
  local e = S.create("ppd-out-320", position)
  e.electric_interface_mode = defines.electric_interface_mode.secondary_output
  S.set_source(e, mw or 1000)
  return e
end
function S.set_source(e, mw)
  local per_tick = mw * 1e6 / 60
  e.power_production = per_tick
  e.electric_buffer_size = per_tick
end

-- A wire being pulled: a copper line grows from a to b in n ticks, then done() lays the real wire
local anims = {}
function S.pull(from, to, n, done)
  local a = {from = from, to = to, n = n, k = 0, done = done}
  a.line = S.line(from, from, {0.85, 0.5, 0.25, 1}, 2)
  anims[#anims + 1] = a
end
function S.animate()
  for i = #anims, 1, -1 do
    local a = anims[i]
    a.k = a.k + 1
    local f = math.min(1, a.k / a.n)
    a.line.to = {a.from[1] + (a.to[1] - a.from[1]) * f, a.from[2] + (a.to[2] - a.from[2]) * f}
    if f >= 1 then
      a.line.destroy()
      table.remove(anims, i)
      a.done()
    end
  end
end

-- Status lamp as the mod draws it (scripts/engine.lua lamp()): its own lens and halo sprites over the glass
function S.lamp(entity)
  local target = {entity = entity, offset = K.lamp}
  return {
    lens = rendering.draw_sprite{sprite = "ppd-lamp-lens", target = target, surface = surface, render_layer = "higher-object-under"},
    halo = rendering.draw_sprite{sprite = "ppd-lamp-halo", target = target, surface = surface, render_layer = "higher-object-under"},
  }
end
function S.set_lamp(l, status)
  local diode = (K.status[status] or K.status.idle).diode
  if l.diode == diode then return end
  l.diode = diode
  local spec = K.lamp_color[diode]
  local c = spec.color
  l.lens.color = c
  l.halo.color = {c[1] * 0.55, c[2] * 0.55, c[3] * 0.55, 0.55}
  l.lens.blink_interval = spec.blink
  l.halo.blink_interval = spec.blink
end
function S.status_color(status) return (K.status[status] or K.status.idle).color end

-- District status as scripts/engine.lua M.process (no switches, loops or converters in these scenes):
-- r = 30 s average / nominal, rnow = this moment / nominal
function S.status(r, rnow, N, L)
  if rnow >= K.limit * 0.985 or r >= K.limit * 0.985 then return "limit" end
  if L < N * 0.005 then return "idle" end
  if r < 1 - K.hw then return "under" end
  if r > 1 + K.hw then return "over" end
  return "zone"
end
function S.bonus(key, zone) return zone and K.tiers[key].bonus * K.mult or 0 end
-- the average follows the load with the time constant of the mod (S.TAU)
function S.average(avg, x, dt) return avg + (x - avg) * (1 - math.exp(-dt / K.tau)) end

-- Load gauge of the transformer window: 0..limit of the nominal, the green zone stripe under it, a white tick for
-- "this moment" and the bar for the 30 s average, in the status colour
function S.gauge(x, y, w, h)
  local g = {x = x, y = y, w = w, h = h or 0.55}
  local lo, hi = 1 - K.hw, 1 + K.hw
  S.rect({x - 0.05, y - 0.05}, {x + w + 0.05, y + g.h + 0.05}, {0.02, 0.02, 0.02, 0.9})
  g.fill = S.rect({x, y}, {x, y + g.h}, {0.5, 0.5, 0.5, 1})
  S.rect({x, y + g.h + 0.1}, {x + w, y + g.h + 0.3}, {0.32, 0.32, 0.32, 1})
  S.rect({x + w * lo / K.limit, y + g.h + 0.1}, {x + w * hi / K.limit, y + g.h + 0.3}, {0.35, 0.85, 0.35, 1})
  g.now = S.line({x, y - 0.25}, {x, y + g.h + 0.25}, {1, 1, 1, 1}, 3)
  local small = {scale = 0.62, font = "default", color = {0.75, 0.75, 0.75}}
  S.text({x, y + g.h + 0.75}, "0", small)
  S.text({x + w * lo / K.limit, y + g.h + 0.75}, S.pct(lo), {scale = 0.62, font = "default", color = {0.5, 1, 0.5}})
  S.text({x + w * hi / K.limit, y + g.h + 0.75}, S.pct(hi), {scale = 0.62, font = "default", color = {0.5, 1, 0.5}})
  S.text({x + w, y + g.h + 0.75}, S.pct(K.limit), small)
  return g
end
function S.set_gauge(g, r, rnow, status)
  local f = math.max(0, math.min(1, r / K.limit))
  g.fill.right_bottom = {g.x + g.w * f, g.y + g.h}
  g.fill.color = S.status_color(status)
  local n = g.x + g.w * math.max(0, math.min(1, rnow / K.limit))
  g.now.from = {n, g.y - 0.25}
  g.now.to = {n, g.y + g.h + 0.25}
end

-- A transformer that is only a picture (formula scenes): the bushing poles at the tips of the art, the main grid
-- pole wired to the input, a lamp. The mod script is not running here.
function S.still(key, position, main_at)
  local e = S.create(K.tiers[key].name, position)
  local pin = S.create(K.pole_in, {position[1] + K.tip_in[1], position[2] + K.tip_in[2]})
  local pout = S.create(K.pole_out, {position[1] + K.tip_out[1], position[2] + K.tip_out[2]})
  local list = {pin, pout}
  local main
  if main_at then
    main = S.create("big-electric-pole", main_at)
    list[#list + 1] = main
  end
  S.bare(list)
  if main then S.wire(main, pin) end
  return {e = e, pin = pin, pout = pout, lamp = S.lamp(e)}
end

-- Assembling machines making gears: on/off by disabled_by_script, a dark veil over the stopped ones
function S.machines(list)
  local out = {}
  for _, p in ipairs(list) do
    local m = S.create("assembling-machine-2", p)
    m.set_recipe("iron-gear-wheel")
    m.insert{name = "iron-plate", count = 100}
    local veil = S.rect({p[1] - 1.5, p[2] - 1.5}, {p[1] + 1.5, p[2] + 1.5}, {0, 0, 0, 0.55})
    veil.visible = false
    out[#out + 1] = {e = m, veil = veil, on = true}
  end
  return out
end
function S.switch(machines, n)
  for i, m in ipairs(machines) do
    local on = i <= n
    if m.on ~= on then
      m.on = on
      m.e.disabled_by_script = not on
      m.veil.visible = not on
    end
  end
end
function S.feed(machines)
  for _, m in ipairs(machines) do
    if m.e.valid then
      m.e.get_output_inventory().clear()
      local input = m.e.get_inventory(defines.inventory.crafter_input)
      if input and input.get_item_count("iron-plate") < 50 then m.e.insert{name = "iron-plate", count = 100} end
    end
  end
end

-- Live scenes: the mod's script must run in the simulation
function S.need()
  if remote.interfaces["ppd"] then return true end
  S.fail({"ppd-tips-sim.no-script"})
  return false
end
-- built through the mod (raise_built): it adds the bushing poles, the hidden parts and the lamp
function S.transformer(key, position)
  local e = S.create(K.tiers[key].name, position, {raise_built = true})
  local parts = remote.call("ppd", "parts", e.unit_number)
  if not (parts and parts.pin and parts.pout) then error("the mod did not register " .. e.name) end
  return {e = e, unit = e.unit_number, pin = parts.pin, pout = parts.pout}
end
function S.info(tr) return remote.call("ppd", "get", tr.unit) or {} end

-- Satisfaction of a network as the mod reads it (scripts/engine.lua flow_numbers)
function S.satisfaction(pole)
  local sub = pole.electric_network
  local net = sub and sub.parent_network
  local f = net and net.flow_last_tick
  if not f then return nil end
  local demand = f.primary_demand + f.secondary_demand
  local got = f.primary_demand * f.primary_demand_usage + f.secondary_demand * f.secondary_demand_usage
  return demand > 0 and got / demand or 1, demand * 60 / 1e6
end
]=]

local function simulation(body, extra)
  local definition = { init = PRELUDE .. body }
  for key, value in pairs(extra or {}) do definition[key] = value end
  return definition
end

local LIVE = { "paranoidal-power-districts" }

local simulations = {}

-- 1. A new transformer: the plug icons blink over both bushings, a wire from the main grid goes to the tall input,
-- a wire from the short output to the district pole, and the radars of the district start. Live: the mod script.
simulations.districts = simulation([=[
S.run(function()
  S.camera({1.5, 0.3}, 1.6)
  sim.camera_alt_info = true
  S.board(-40, -24, 40, 24)
  if not S.need() then return end
  local main = S.create("big-electric-pole", {-8, -1})
  local pole = S.create("medium-electric-pole", {8.5, 0.5})
  S.bare({main, pole})
  S.source({-8, -1}, 30)
  local radars = {}
  for _, p in ipairs({{6.2, -2.4}, {10.8, -2.4}, {6.2, 3.4}, {10.8, 3.4}}) do radars[#radars + 1] = S.create("radar", p) end
  local tr = S.transformer("40", {0, 1})
  S.text({-8, -5.6}, {"ppd-tips-sim.main-grid"}, {scale = 0.8, color = {0.75, 0.85, 1}})
  S.text({8.5, -5.6}, {"ppd-tips-sim.district"}, {scale = 0.8, color = {1, 0.85, 0.4}})
  S.text({tr.pin.position.x - 0.75, tr.pin.position.y + 0.2}, {"ppd-tips-sim.input"}, {scale = 0.62, align = "right", color = {0.9, 0.6, 0.45}})
  S.text({tr.pout.position.x + 0.75, tr.pout.position.y + 0.2}, {"ppd-tips-sim.output"}, {scale = 0.62, align = "left", color = {0.8, 0.8, 0.8}})
  local status = S.text({0, 2.9}, "", {scale = 0.75})
  local step = S.text({1.5, 5.6}, "", {scale = 0.75})
  local from_main = {main.position.x, main.position.y - 2.6}
  local from_out = {tr.pout.position.x, tr.pout.position.y}
  local to_pole = {pole.position.x, pole.position.y - 2.2}
  local CYCLE, phase = 1020, nil
  S.stats.statuses, S.stats.radars_on, S.stats.radars_off, S.stats.icon_in = {}, 0, 0, false
  S.tick = function(t)
    local c = (t - 2) % CYCLE
    if c == 0 then
      phase = 0
      if main.get_wire_connector(COPPER, true).is_connected_to(tr.pin.get_wire_connector(COPPER, true)) then S.unwire(main, tr.pin) end
      if pole.get_wire_connector(COPPER, true).is_connected_to(tr.pout.get_wire_connector(COPPER, true)) then S.unwire(pole, tr.pout) end
    elseif c == 150 then
      phase = 1
      S.pull(from_main, {tr.pin.position.x, tr.pin.position.y}, 45, function() S.wire(main, tr.pin) end)
    elseif c == 390 then
      phase = 2
      S.pull(from_out, to_pole, 45, function() S.wire(tr.pout, pole) S.event("district") end)
    elseif c == 480 then
      phase = 3
    end
    if t % 10 == 0 then
      local info = S.info(tr)
      local s = info.status or "idle"
      S.stats.statuses[s] = true
      if info.icon_in then S.stats.icon_in = true end
      status.text = {"", "[color=" .. S.hex(S.status_color(s)) .. "]", {"ppd-status." .. s}, "[/color]"}
      local working = 0
      for _, r in ipairs(radars) do if r.status == defines.entity_status.working then working = working + 1 end end
      if phase == 3 and c > 600 then
        if working == #radars then S.stats.radars_on = S.stats.radars_on + 1 else S.stats.radars_off = S.stats.radars_off + 1 end
      end
      step.text = {"ppd-tips-sim.wire-step" .. (phase or 0)}
    end
  end
end)
]=], { mods = LIVE, init_update_count = 30 })

-- 2. The green zone: machines switch on and off, the 30 s average follows them (time sped up), the gauge and the
-- lamp change colour; in the zone the district gets the bonus. Formulas of scripts/engine.lua.
simulations.green_zone = simulation([=[
S.run(function()
  S.camera({-1, 0}, 1.4)
  S.board(-40, -24, 40, 24)
  local SPEED, EACH, KEY = 6, 4, "40"
  local N = K.tiers[KEY].nominal
  local tr = S.still(KEY, {-12, -1}, {-15, -4})
  local spots = {}
  for _, y in ipairs({-3.5, 0.5}) do
    for i = 0, 5 do spots[#spots + 1] = {-5.5 + i * 3, y} end
  end
  local machines = S.machines(spots)
  local poles = {}
  for i, x in ipairs({-4.5, 2.5, 9.5}) do poles[i] = S.create("medium-electric-pole", {x, -1.5}) end
  S.bare(poles)
  S.wire(tr.pout, poles[1]) S.wire(poles[1], poles[2]) S.wire(poles[2], poles[3])
  S.source({2.5, -1.5})
  S.text({-1, -6.9}, {"ppd-tips-sim.zone-title", S.pct(1 - K.hw), S.pct(1 + K.hw)}, {scale = 0.85})
  local status = S.text({-12, 1.0}, "", {scale = 0.8})
  S.text({-12, 1.9}, {"ppd-tips-sim.nominal", "[item=" .. K.tiers[KEY].name .. "]", S.mw(N, 0), KEY}, {scale = 0.62, font = "default"})
  local count = S.text({2, 2.75}, "", {scale = 0.7, font = "default", color = {0.85, 0.85, 0.85}})
  local avg_text = S.text({-15, 3.4}, "", {scale = 0.72, align = "left"})
  local now_text = S.text({13, 3.4}, "", {scale = 0.66, font = "default", align = "right", color = {0.85, 0.85, 0.85}})
  local gauge = S.gauge(-15, 4.1, 28)
  local bonus = S.text({-1, 6.25}, "", {scale = 0.72})
  S.text({13, 7.2}, {"ppd-tips-sim.sped-up", SPEED}, {scale = 0.6, font = "default", align = "right", color = {0.7, 0.7, 0.7}})
  local PLAN = {{n = 7, want = "under"}, {n = 10, want = "zone"}, {n = 12, want = "over"}, {n = 10, want = "zone"}}
  local step, held = 1, 0
  local avg = PLAN[1].n * EACH
  S.stats.seen, S.stats.cycles, S.stats.bonus_in_zone = {}, 0, false
  S.tick = function(t)
    local plan = PLAN[step]
    S.switch(machines, plan.n)
    if t % 300 == 0 then S.feed(machines) end
    local x = plan.n * EACH
    avg = S.average(avg, x, SPEED)
    local r, rnow = avg / N, x / N
    local s = S.status(r, rnow, N, avg)
    S.stats.seen[s] = true
    S.event(s)
    local B = S.bonus(KEY, s == "zone")
    if B > 0 then S.stats.bonus_in_zone = true end
    if s == plan.want then held = held + 1 else held = 0 end
    if held >= 150 then
      step, held = step % #PLAN + 1, 0
      if step == 1 then S.stats.cycles = S.stats.cycles + 1 end
    end
    S.set_lamp(tr.lamp, s)
    S.set_gauge(gauge, r, rnow, s)
    local c = "[color=" .. S.hex(S.status_color(s)) .. "]"
    status.text = {"", c, {"ppd-status." .. s}, "[/color]"}
    avg_text.text = {"ppd-tips-sim.average", c, S.pct(r), S.mw(avg)}
    now_text.text = {"ppd-tips-sim.now", S.pct(rnow)}
    count.text = {"ppd-tips-sim.machines", plan.n, #machines, S.mw(EACH, 0), S.mw(x, 0)}
    if B > 0 then
      bonus.text = {"ppd-tips-sim.bonus-on", S.mw(avg / (1 + B) + N * K.idle), S.mw(avg), S.pct(B)}
      bonus.color = {0.6, 1, 0.6}
    else
      bonus.text = {"ppd-tips-sim.bonus-off", S.mw(avg + N * K.idle), S.mw(avg)}
      bonus.color = {1, 0.85, 0.5}
    end
  end
end)
]=], { init_update_count = 30 })

-- 3. Choosing a transformer: 52 MW against the zones of T-40 and T-80 on one axis, then the three ways out of the
-- tip (split the district, more machines with a T-80 or two T-40, a +20 % tap). A scheme with real transformers.
simulations.matching = simulation([=[
S.run(function()
  S.camera({0.5, 0}, 1.35)
  S.board(-40, -24, 40, 24)
  local MAX, LOAD, MORE, TAP = 100, 52, 76, 2
  local X0, X1 = -8.5, 15.5
  local function px(mw) return X0 + (X1 - X0) * math.min(mw, MAX) / MAX end
  local rows = {}
  for i, spec in ipairs({{key = "40", y = -2.4, ty = -2}, {key = "80", y = 2.6, ty = 3}}) do
    local row = {key = spec.key, y = spec.y, tap = 0}
    row.tr = S.still(spec.key, {-13, spec.ty})
    local by = spec.y - 0.2
    row.by = by
    S.rect({px(0) - 0.05, by - 0.05}, {px(MAX) + 0.05, by + 0.65}, {0.02, 0.02, 0.02, 0.9})
    row.fill = S.rect({px(0), by}, {px(0), by + 0.6}, {0.5, 0.5, 0.5, 1})
    row.split = S.rect({px(0), by}, {px(0), by + 0.6}, {0.45, 0.45, 0.45, 1})
    row.split.visible = false
    S.rect({px(0), by + 0.7}, {px(MAX), by + 0.9}, {0.32, 0.32, 0.32, 1})
    row.over = S.rect({px(0), by + 0.7}, {px(MAX), by + 0.9}, {0.8, 0.25, 0.2, 1})
    row.zone = S.rect({px(0), by + 0.7}, {px(0), by + 0.9}, {0.35, 0.85, 0.35, 1})
    row.limit = S.line({px(0), by - 0.3}, {px(0), by + 1.0}, {1, 0.4, 0.3, 1}, 2)
    row.title = S.text({px(0), by - 0.8}, "", {scale = 0.7, font = "default", align = "left", color = {0.85, 0.85, 0.85}})
    row.verdict = S.text({px(0), by + 1.5}, "", {scale = 0.75, align = "left"})
    rows[i] = row
  end
  for v = 0, MAX, 20 do
    S.line({px(v), 4.6}, {px(v), 4.85}, {0.6, 0.6, 0.6, 1}, 1)
    S.text({px(v), 5.25}, S.mw(v, 0), {scale = 0.6, font = "default", color = {0.65, 0.65, 0.65}})
  end
  local marker = S.line({px(LOAD), -4.4}, {px(LOAD), 4.6}, {1, 1, 1, 0.9}, 2, 0.25)
  local marker_text = S.text({px(LOAD), -4.8}, "", {scale = 0.75})
  local title = S.text({0.5, -6.6}, "", {scale = 0.85})
  local note = S.text({0.5, 6.5}, "", {scale = 0.75, font = "default", color = {1, 0.9, 0.55}})
  local PHASE = 330
  local load, shown = LOAD, LOAD
  S.stats.phases, S.stats.verdicts = {}, {}
  local function set_row(row, mw, tap, split)
    local N = K.tiers[row.key].nominal * (1 + K.tap_step * tap)
    local lo, hi, lim = N * (1 - K.hw), N * (1 + K.hw), N * K.limit
    row.zone.left_top = {px(lo), row.by + 0.7}
    row.zone.right_bottom = {px(hi), row.by + 0.9}
    row.over.left_top = {px(lim), row.by + 0.7}
    row.limit.from = {px(lim), row.by - 0.3}
    row.limit.to = {px(lim), row.by + 1.0}
    local own = split or mw
    local s = S.status(own / N, own / N, N, own)
    row.fill.right_bottom = {px(math.min(own, lim)), row.by + 0.6}
    row.fill.color = S.status_color(s)
    row.split.visible = split ~= nil
    if split then
      row.split.left_top = {px(split), row.by}
      row.split.right_bottom = {px(mw), row.by + 0.6}
    end
    S.set_lamp(row.tr.lamp, s)
    row.title.text = {"ppd-tips-sim.row", "[item=" .. K.tiers[row.key].name .. "]", row.key, S.mw(N),
      S.num(lo, 1), S.num(hi, 1), S.mw(lim), tap ~= 0 and {"ppd-tips-sim.row-tap", "+" .. math.floor(tap * K.tap_step * 100 + 0.5)} or ""}
    local c = "[color=" .. S.hex(S.status_color(s)) .. "]"
    row.verdict.text = {"", c, S.pct(own / N), " — ", {"ppd-status." .. s}, s == "limit" and {"ppd-tips-sim.slower"} or "",
      s == "zone" and {"ppd-tips-sim.bonus-short", S.pct(S.bonus(row.key, true))} or "", "[/color]"}
    S.stats.verdicts[row.key .. "/" .. tap .. "/" .. (split and "split" or tostring(math.floor(mw + 0.5)))] = s
    return s
  end
  S.tick = function(t)
    local p = math.floor((t - 2) / PHASE) % 4
    local c = (t - 2) % PHASE
    S.stats.phases[p] = true
    S.event("phase" .. p)
    local target = p == 2 and MORE or LOAD
    if shown ~= target then
      local d = target - shown
      shown = math.abs(d) < 0.6 and target or shown + d * 0.08
    end
    marker.from = {px(shown), -4.4}
    marker.to = {px(shown), 4.6}
    marker_text.target = {px(shown), -4.8}
    marker_text.text = {"ppd-tips-sim.load-marker", S.mw(shown, 0)}
    local r1, r2 = rows[1], rows[2]
    if p == 0 then
      title.text = {"ppd-tips-sim.match-title", S.mw(LOAD, 0)}
      set_row(r1, shown, 0) set_row(r2, shown, 0)
      note.text = {"ppd-tips-sim.match-none"}
    elseif p == 1 then
      title.text = {"ppd-tips-sim.match-split"}
      set_row(r1, shown, 0, K.tiers["40"].nominal) set_row(r2, shown, 0)
      note.text = {"ppd-tips-sim.match-split-note", S.mw(K.tiers["40"].nominal, 0), S.mw(LOAD - K.tiers["40"].nominal, 0)}
    elseif p == 2 then
      title.text = {"ppd-tips-sim.match-more", S.mw(K.tiers["80"].nominal * (1 - K.hw), 0)}
      set_row(r1, shown, 0) set_row(r2, shown, 0)
      note.text = {"ppd-tips-sim.match-more-note", "[item=" .. K.tiers["40"].name .. "]"}
    else
      title.text = {"ppd-tips-sim.match-tap", "+" .. math.floor(TAP * K.tap_step * 100 + 0.5), {"technology-name." .. K.tech_taps}, TAP, "[technology=" .. K.tech_taps .. "-" .. TAP .. "]"}
      local tap = c < 40 and 0 or TAP
      set_row(r1, shown, tap) set_row(r2, shown, 0)
      note.text = {"ppd-tips-sim.match-tap-note", S.mw(K.tiers["40"].nominal * (1 + K.tap_step * TAP), 0)}
    end
  end
end)
]=], { init_update_count = 30 })

-- 4. Smoothing: the machines ask 60 MW and 20 MW by turns (3 s each); a T-40 gives at most 125 % (50 MW). The
-- accumulators give the missing 10 MW at the peak and charge in the dip, so their charging counts as load and the
-- 30 s average stays in the zone; without them it would be below it (and the machines slower at the peaks).
simulations.smoothing = simulation([=[
S.run(function()
  S.camera({0, 0}, 1.2)
  S.board(-40, -24, 40, 24)
  local SPEED, KEY, EACH, PEAK_N, DIP_N, PEAK_S, CYCLE_S = 1, "40", 10, 6, 2, 3, 6
  local ACC, ACC_N = "bi-bio-accumulator", 4
  local N = K.tiers[KEY].nominal
  local LIM = N * K.limit
  local acc_proto = prototypes.entity[ACC]
  if not acc_proto then error("no " .. ACC) end
  local source = acc_proto.electric_energy_source_prototype
  local A = source.get_output_flow_limit("normal") * 60 / 1e6 * ACC_N   -- MW
  local EMAX = source.buffer_capacity / 1e6 * ACC_N                     -- MJ
  local tr = S.still(KEY, {-15, -5}, {-18, -7})
  local spots = {}
  for i = 0, 5 do spots[#spots + 1] = {-10.5 + i * 3, -5.5} end
  local machines = S.machines(spots)
  local poles = {}
  for i, x in ipairs({-9.5, -2.5, 3.5}) do poles[i] = S.create("medium-electric-pole", {x, -2.5}) end
  -- the accumulators stand on their own pole without any producer: the scene draws their flow by the formulas
  local acc_pole = S.create("medium-electric-pole", {13.5, -3.5})
  S.bare({poles[1], poles[2], poles[3], acc_pole})
  S.wire(tr.pout, poles[1]) S.wire(poles[1], poles[2]) S.wire(poles[2], poles[3])
  S.source({-2.5, -2.5})
  local accs = {}
  for _, p in ipairs({{11, -6}, {16, -6}, {11, -1}, {16, -1}}) do accs[#accs + 1] = S.create(ACC, p) end
  S.text({-1, -8.5}, {"ppd-tips-sim.smooth-title", "[item=" .. K.tiers[KEY].name .. "]", S.mw(LIM, 0), S.pct(K.limit), KEY}, {scale = 0.75})
  S.text({13.5, 1.6}, {"ppd-tips-sim.acc-count", ACC_N, "[item=" .. ACC .. "]", S.mw(A, 1)}, {scale = 0.62, font = "default"})
  local acc_text = S.text({13.5, 2.45}, "", {scale = 0.66})
  local status = S.text({-15, -3.2}, "", {scale = 0.72})
  local machines_text = S.text({-3, -0.9}, "", {scale = 0.66, font = "default", color = {0.85, 0.85, 0.85}})
  -- chart: last 40 s of game time; grey = what the machines ask, colour = what the district takes from the transformer
  local CX0, CX1, CY0, CY1, YMAX, POINTS = -17, 17, 3.2, 7.0, 70, 80
  local function cy(mw) return CY1 - (CY1 - CY0) * math.min(mw, YMAX) / YMAX end
  S.rect({CX0, CY0}, {CX1, CY1}, {0.02, 0.02, 0.02, 0.85})
  S.rect({CX0, cy(N * (1 + K.hw))}, {CX1, cy(N * (1 - K.hw))}, {0.12, 0.35, 0.12, 0.6})
  S.line({CX0, cy(LIM)}, {CX1, cy(LIM)}, {1, 0.4, 0.3, 0.9}, 2, 0.3)
  S.text({CX1 - 0.2, cy(LIM) - 0.35}, {"ppd-tips-sim.limit-line", S.mw(LIM, 0)}, {scale = 0.56, font = "default", align = "right", color = {1, 0.55, 0.45}})
  S.text({CX1 - 0.2, cy(N) - 0.0}, {"ppd-tips-sim.zone-band"}, {scale = 0.56, font = "default", align = "right", color = {0.5, 1, 0.5}})
  S.text({CX0 + 0.2, CY0 + 0.4}, {"ppd-tips-sim.chart-legend"}, {scale = 0.6, font = "default", align = "left"})
  local ask_lines, take_lines, ask, take = {}, {}, {}, {}
  for i = 1, POINTS - 1 do
    ask_lines[i] = S.line({0, 0}, {0, 0}, {0.6, 0.6, 0.6, 1}, 2)
    take_lines[i] = S.line({0, 0}, {0, 0}, {0.56, 0.89, 0.42, 1}, 3)
  end
  local result = S.text({-17, 7.65}, "", {scale = 0.7, align = "left"})
  local without = S.text({-17, 8.5}, "", {scale = 0.66, font = "default", align = "left", color = {1, 0.85, 0.5}})
  local ask_mean = (PEAK_N * PEAK_S + DIP_N * (CYCLE_S - PEAK_S)) * EACH / CYCLE_S
  local avg = ask_mean
  local avg_wo = (LIM * PEAK_S + DIP_N * EACH * (CYCLE_S - PEAK_S)) / CYCLE_S
  local E, game_s = EMAX, 0
  S.stats.give, S.stats.charge, S.stats.min_avg, S.stats.max_avg, S.stats.max_wo = 0, 0, 2, 0, 0
  S.tick = function(t)
    local dt = SPEED / 60
    game_s = game_s + dt
    local peak = (game_s % CYCLE_S) >= CYCLE_S - PEAK_S  -- the dip first
    local n = peak and PEAK_N or DIP_N
    S.switch(machines, n)
    if t % 300 == 0 then S.feed(machines) end
    local D = n * EACH
    local T, flow = D, 0
    if D > LIM then
      flow = -math.min(A, D - LIM, E / dt)
      T = LIM
    else
      flow = math.min(A, LIM - D, (EMAX - E) / dt)
      T = D + flow
    end
    E = math.max(0, math.min(EMAX, E + flow * dt))
    avg = S.average(avg, T, SPEED)
    avg_wo = S.average(avg_wo, math.min(D, LIM), SPEED)
    local s = S.status(avg / N, T / N, N, avg)
    local s_wo = S.status(avg_wo / N, avg_wo / N, N, avg_wo)
    if flow < -0.01 then S.stats.give = S.stats.give + 1 S.event("give") end
    if flow > 0.01 then S.stats.charge = S.stats.charge + 1 S.event("charge") end
    if t > 60 then
      S.stats.min_avg = math.min(S.stats.min_avg, avg / N)
      S.stats.max_avg = math.max(S.stats.max_avg, avg / N)
      S.stats.max_wo = math.max(S.stats.max_wo, avg_wo / N)
    end
    S.set_lamp(tr.lamp, s)
    local c = "[color=" .. S.hex(S.status_color(s)) .. "]"
    status.text = {"", c, {"ppd-status." .. s}, "[/color]"}
    machines_text.text = {"ppd-tips-sim.smooth-machines", n, #machines, S.mw(D, 0), S.mw(T, 0)}
    if flow < -0.01 then
      acc_text.text = {"ppd-tips-sim.acc-give", S.mw(-flow), S.pct(E / EMAX)}
      acc_text.color = {0.55, 0.8, 1}
    elseif flow > 0.01 then
      acc_text.text = {"ppd-tips-sim.acc-charge", S.mw(flow), S.pct(E / EMAX)}
      acc_text.color = {0.6, 1, 0.6}
    else
      acc_text.text = {"ppd-tips-sim.acc-full", S.pct(E / EMAX)}
      acc_text.color = {0.8, 0.8, 0.8}
    end
    local zone = avg / N >= 1 - K.hw and avg / N <= 1 + K.hw
    local cz = "[color=" .. S.hex(S.status_color(zone and "zone" or s)) .. "]"
    result.text = {"ppd-tips-sim.smooth-result", cz, S.pct(avg / N), {"ppd-status." .. (zone and "zone" or s)},
      zone and {"ppd-tips-sim.bonus-short", S.pct(S.bonus(KEY, true))} or ""}
    without.text = {"ppd-tips-sim.smooth-without", S.pct(avg_wo / N), {"ppd-status." .. s_wo}, S.pct(LIM / (PEAK_N * EACH))}
    if t % 15 == 0 then
      ask[#ask + 1], take[#take + 1] = D, T
      if #ask > POINTS then table.remove(ask, 1) table.remove(take, 1) end
      local k = #ask
      for i = 1, POINTS - 1 do
        local a, b = k - POINTS + i, k - POINTS + i + 1
        local x1 = CX0 + (CX1 - CX0) * (i - 1) / (POINTS - 1)
        local x2 = CX0 + (CX1 - CX0) * i / (POINTS - 1)
        local visible = a >= 1
        ask_lines[i].visible, take_lines[i].visible = visible, visible
        if visible then
          ask_lines[i].from, ask_lines[i].to = {x1, cy(ask[a])}, {x2, cy(ask[b])}
          take_lines[i].from, take_lines[i].to = {x1, cy(take[a])}, {x2, cy(take[b])}
        end
      end
    end
  end
end)
]=], { init_update_count = 30 })

-- 5. Priorities and automation: the power plant loses most of its power; after 3 s below the threshold the
-- automation sheds the secondary district, then the normal one marked "may be switched off"; the important one
-- keeps working. When the power is back, the districts return one by one. Live: the mod script.
simulations.priorities = simulation([=[
S.run(function()
  S.camera({0, 0}, 1.1)
  S.board(-40, -24, 40, 24)
  if not S.need() then return end
  local tech = force.technologies[K.tech_auto]
  if tech and not tech.researched then tech.researched = true end
  remote.call("ppd", "refresh_research", force.index)
  local auto = remote.call("ppd", "force", force.index).auto or {}
  local threshold, pause = auto.threshold or 0.95, (auto.pause or 900) / 60
  local FULL, LOW = 4, 1
  local SPEC = {{x = -12, prio = 1, color = K.colors[4]}, {x = 0, prio = 2, shed = true, color = K.colors[3]},
    {x = 12, prio = 3, color = K.colors[1]}}
  -- the main grid: a line of medium poles; the 1st, 3rd and 5th feed the transformer inputs
  local line = {}
  for i, x in ipairs({-15.5, -9.5, -3.5, 2.5, 8.5}) do line[i] = S.create("medium-electric-pole", {x, -5.5}) end
  local mains = {line[1], line[3], line[5]}
  for i, d in ipairs(SPEC) do
    d.pole = S.create("medium-electric-pole", {d.x + 2.5, 1.5})
    d.radars = {S.create("radar", {d.x + 0.5, 3.5}), S.create("radar", {d.x + 4.5, 3.5})}
  end
  local all = {}
  for _, pole in ipairs(line) do all[#all + 1] = pole end
  for _, d in ipairs(SPEC) do all[#all + 1] = d.pole end
  S.bare(all)
  for i = 1, #line - 1 do S.wire(line[i], line[i + 1]) end
  local plant = S.source({-15.5, -5.5}, FULL)
  for i, d in ipairs(SPEC) do
    d.tr = S.transformer("40", {d.x, -2})
    remote.call("ppd", "set", d.tr.unit, "prio", d.prio)
    if d.shed then remote.call("ppd", "set", d.tr.unit, "can_shed", true) end
    S.wire(mains[i], d.tr.pin)
    S.wire(d.tr.pout, d.pole)
    S.text({d.x + 2.5, 5.6}, {"", "[color=" .. S.hex(d.color) .. "]", {"ppd-prio." .. d.prio}, "[/color]"}, {scale = 0.75})
    if d.shed then S.text({d.x + 2.5, 6.35}, {"ppd-tips-sim.can-shed"}, {scale = 0.58, font = "default", color = {0.8, 0.8, 0.8}}) end
    d.status = S.text({d.x + 2.5, 7.15}, "", {scale = 0.68})
    d.take = S.text({d.x + 2.5, 7.95}, "", {scale = 0.6, font = "default", color = {0.8, 0.8, 0.8}})
  end
  local plant_text = S.text({-19.5, -9.0}, "", {scale = 0.68, align = "left"})
  local sat_text = S.text({19.5, -9.0}, "", {scale = 0.68, align = "right"})
  local step = S.text({0, 9.05}, "", {scale = 0.62, color = {1, 0.9, 0.55}})
  local low_since
  local CYCLE, mw = 3900, FULL
  S.stats.off, S.stats.important_off, S.stats.restored, S.stats.order = {}, false, {}, {}
  S.tick = function(t)
    local c = (t - 2) % CYCLE
    if c == 600 then mw = LOW S.set_source(plant, LOW) S.event("drop") end
    if c == 1800 then mw = FULL S.set_source(plant, FULL) S.event("back") end
    if t % 10 ~= 0 then return end
    local sat = S.satisfaction(mains[2]) or 1
    if sat < threshold then low_since = low_since or t else low_since = nil end
    plant_text.text = {"ppd-tips-sim.plant", mw < FULL and "[color=255,120,100]" or "[color=140,230,140]", S.mw(mw, 0)}
    local below = low_since and (t - low_since) / 60 or 0
    sat_text.text = {"ppd-tips-sim.satisfaction", sat < threshold and "[color=255,120,100]" or "[color=140,230,140]",
      S.pct(sat), S.pct(threshold)}
    for i, d in ipairs(SPEC) do
      local info = S.info(d.tr)
      local s = info.status or "idle"
      local off = s == "off_auto"
      if off and not S.stats.off[i] then
        S.stats.off[i] = t
        S.stats.order[#S.stats.order + 1] = d.prio
        S.event("shed" .. d.prio)
      elseif not off and S.stats.off[i] then
        S.stats.off[i] = nil
        S.stats.restored[d.prio] = true
        S.event("back" .. d.prio)
      end
      if off and d.prio == 1 then S.stats.important_off = true end
      d.status.text = {"", "[color=" .. S.hex(S.status_color(s)) .. "]", {"ppd-status." .. s}, "[/color]"}
      d.take.text = {"ppd-tips-sim.takes", S.mw((info.draw or 0) * 60 / 1e6)}
    end
    if c < 600 then
      step.text = {"ppd-tips-sim.prio-step0"}
    elseif c < 1800 then
      step.text = below > 0 and {"ppd-tips-sim.prio-step1", S.num(math.min(below, 3), 1)} or {"ppd-tips-sim.prio-step2"}
    else
      step.text = {"ppd-tips-sim.prio-step3", pause}
    end
  end
end)
]=], { mods = LIVE, init_update_count = 240 })

return simulations
