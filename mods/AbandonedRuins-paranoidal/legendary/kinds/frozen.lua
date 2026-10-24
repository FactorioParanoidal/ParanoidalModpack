-- The Frozen Moment: time here is a loop. Step on the hourglass and a minute starts; five gates
-- block the way to the great clock, each opened by a lever in a side room. When the minute ends,
-- time rolls back: gates close, levers return and everyone inside is thrown back to the hourglass.
-- Learn the way, then run it in one minute. Thick time (slowing fields) and the clock's sentinels
-- (bolts) do not make it easier.
local C = require("legendary.config")

local KIND = { name = "frozen", tier = "trial", size = 96, weight = 1, relic = "pd-relic-time-anchor" }

local START = { -1, 40 }
local CLOCK = { -4, -46, 3, -39 }
-- zig-zag: gates on horizontal walls between bands, lever rooms beside the corridor
local BANDS = { 30, 16, 2, -12, -26 }       -- y of the gate walls

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill("refined-concrete", -48, -48, 47, 47)
  plan:fill(function(x, y) return ((x + y) % 4 == 0) and "black-refined-concrete" or nil end, -40, -38, 39, 38)
  plan:wall_ring(-46, -48, 45, 46, { { -1, 46 }, { 0, 46 } })
  plan:fill("yellow-refined-concrete", START[1] - 1, START[2] - 1, START[1] + 2, START[2] + 2)
  d.gates, d.levers, d.slow = {}, {}, {}
  for g, y in ipairs(BANDS) do
    -- a band wall across the hall with a 3-tile gate alternating left / right
    local gx = (g % 2 == 1) and rng.next(-36, -24) or rng.next(20, 32)
    for x = -45, 44 do
      if x >= gx and x <= gx + 2 then
        plan:put(C.WALL, x, y, { force = "legend", invincible = true, locked = true, list = "gate-" .. g })
      else
        plan:wall(x, y)
      end
    end
    d.gates[g] = { x = gx, y = y }
    -- the lever room on the other side of the band, open to the corridor
    local lx = (g % 2 == 1) and rng.next(18, 36) or rng.next(-38, -20)
    local ly = y + 6
    plan:wall_ring(lx - 3, ly - 3, lx + 3, ly + 3, { { lx, ly + 3 }, { lx + 1, ly + 3 } })
    plan:lever("lever-" .. g, lx, ly)
    d.levers[g] = { x = lx, y = ly }
    -- thick time: a slowing patch in the corridor
    local sx, sy = rng.next(-30, 30), y + rng.next(8, 11)
    plan:fill("purple-refined-concrete", sx - 2, sy - 1, sx + 2, sy + 1)
    d.slow[#d.slow + 1] = { sx - 2, sy - 1, sx + 2, sy + 1 }
  end
  -- the great clock
  plan:fill("lab-white", CLOCK[1], CLOCK[2], CLOCK[3], CLOCK[4])
  plan:vault(-3, -44)
  plan:vault(2, -44)
  -- sentinels: bolt throwers at the side walls
  d.sentinels = {}
  for g, y in ipairs(BANDS) do
    local sy = y + 7
    d.sentinels[#d.sentinels + 1] = { x = -44.5, y = sy + 0.5, dir = 1, next = 0 }
    d.sentinels[#d.sentinels + 1] = { x = 43.5, y = sy - 2.5, dir = -1, next = 0 }
    plan:put("small-lamp", -45, sy, { force = "legend", invincible = true, locked = true, loose = true })
    plan:put("small-lamp", 44, sy - 3, { force = "legend", invincible = true, locked = true, loose = true })
  end
end

function KIND.built(site, K)
  K.text(site, K.abs(site, 0.5, 37.5), { "pd-legendary-frozen.sign" }, { 0.8, 0.8, 1 }, 1.4, nil, true)
  K.light(site, K.abs(site, 0, -42), 3, { 0.7, 0.8, 1 }, true)
end

local function close_gate(site, K, g)
  local gate = site.data.gates[g]
  if #K.list(site, "gate-" .. g) > 0 then return end
  for x = gate.x, gate.x + 2 do
    K.place(site, C.WALL, x + 0.5, gate.y + 0.5, { force = "legend", invincible = true, locked = true, list = "gate-" .. g })
  end
end

local function reset(site, K)
  local d = site.data
  d.loop = nil
  for g in ipairs(d.gates) do close_gate(site, K, g) end
  for g, l in ipairs(d.levers) do
    if not K.get(site, "lever-" .. g) then
      K.relever(site, "lever-" .. g, l.x + 0.5, l.y + 0.5)
    end
  end
  d.pulled = {}
end

local function rewind(site, ctx, K)
  reset(site, K)
  for _, p in ipairs(ctx.players) do
    if p.inside then
      p.player.teleport({ x = site.x + START[1] + 0.5, y = site.y + START[2] + 4.5 })
      p.player.print({ "pd-legendary-frozen.rewind" }, { color = { 0.7, 0.7, 1 } })
    end
  end
  K.effect(site, "spark-explosion", K.abs(site, START[1], START[2]))
end

function KIND.step(site, p, K)
  local d = site.data
  local rx, ry = p.rx, p.ry
  if not d.loop and rx >= START[1] - 1 and rx < START[1] + 3 and ry >= START[2] - 1 and ry < START[2] + 3 then
    d.loop = { start = game.tick, ends = game.tick + K.ticks(90) }
    d.pulled = {}
    K.say(site, { "pd-legendary-frozen.start", math.floor(K.ticks(90) / 60) })
  end
  if d.loop and rx >= CLOCK[1] and rx < CLOCK[3] + 1 and ry >= CLOCK[2] and ry < CLOCK[4] + 1 then
    K.say(site, { "pd-legendary-frozen.stopped", p.player.name })
    K.solve(site, p.player)
    return
  end
  for _, r in ipairs(d.slow) do
    if rx >= r[1] and rx < r[3] + 1 and ry >= r[2] and ry < r[4] + 1 then K.stick(site, p.char, "slowdown-sticker") end
  end
end

function KIND.lever(site, key, player, entity, K)
  local d = site.data
  local g = tonumber(key:match("^lever%-(%d)$"))
  if not g then return end
  if not d.loop then
    -- outside the loop the lever is stuck in time
    K.relever(site, key, d.levers[g].x + 0.5, d.levers[g].y + 0.5)
    if player then player.print({ "pd-legendary-frozen.stuck" }) end
    return
  end
  d.pulled = d.pulled or {}
  d.pulled[g] = true
  K.destroy_list(site, "gate-" .. g)
  K.say(site, { "pd-legendary-frozen.gate", g, #BANDS })
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if d.loop then
    local left = d.loop.ends - ctx.tick
    if ctx.tick % 60 < 6 then
      for _, p in ipairs(ctx.players) do
        if p.inside then
          p.player.create_local_flying_text({ text = { "pd-legendary.timer", K.clock(left) }, position = p.pos, color = { 0.7, 0.8, 1 } })
        end
      end
    end
    if left <= 0 then rewind(site, ctx, K) end
  end
  for _, s in ipairs(d.sentinels) do
    if ctx.tick >= s.next then
      s.next = ctx.tick + 120 + math.random(0, 60)
      for _, p in ipairs(ctx.players) do
        if p.inside and math.abs(p.ry - s.y) < 6 then
          K.line(site, K.abs(site, s.x, s.y), p.pos, { 0.6, 0.6, 1, 0.8 }, 30, 2, 0.4)
          s.aim = { x = p.rx, y = p.ry, at = ctx.tick + 30 }
          break
        end
      end
    end
    if s.aim and ctx.tick >= s.aim.at then
      local dx, dy = s.aim.x - s.x, s.aim.y - s.y
      local len = math.sqrt(dx * dx + dy * dy)
      if len > 1 then
        K.bolt(site, K.abs(site, s.x + dx / len, s.y + dy / len), K.abs(site, s.x + dx / len * 90, s.y + dy / len * 90), 0.8)
      end
      s.aim = nil
    end
  end
end

function KIND.sleep(site, K)
  if site.data.loop then reset(site, K) end
end

return KIND
