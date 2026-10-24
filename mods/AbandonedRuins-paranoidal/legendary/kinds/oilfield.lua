-- The Inferno Oilfield: a web of old pipelines between wellheads and a tank depot. When someone
-- arrives, a wellhead in the far corner bursts into flames, and the fire runs along the pipes from
-- junction to junction; gas lines pass it on at once. Close valves to cut the fire off from the
-- depot. Each tank that catches fire explodes and burns part of the reward; lose all four and the
-- depot is gone.
local C = require("legendary.config")

local KIND = { name = "oilfield", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-eternal-spring" }

local NN, SPACE, O = 6, 20, -50
local DEPOT = { 5, 5 }

local function node_pos(a, b) return O + SPACE * a, O + SPACE * b end
local function ekey(a1, b1, a2, b2)
  if a2 < a1 or b2 < b1 then a1, b1, a2, b2 = a2, b2, a1, b1 end
  return a1 .. ":" .. b1 .. ":" .. a2 .. ":" .. b2
end

local function connected(edges)
  local seen, queue, head, count = { ["0:0"] = true }, { { 0, 0 } }, 1, 1
  while head <= #queue do
    local n = queue[head]
    head = head + 1
    for _, dlt in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local a, b = n[1] + dlt[1], n[2] + dlt[2]
      if a >= 0 and b >= 0 and a < NN and b < NN and edges[ekey(n[1], n[2], a, b)] and not seen[a .. ":" .. b] then
        seen[a .. ":" .. b] = true
        count = count + 1
        queue[#queue + 1] = { a, b }
      end
    end
  end
  return count == NN * NN
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "dirt-6", "dirt-5", "dirt-7", "dry-dirt" }) end, -64, -64, 63, 63)
  plan:wall_ring(-62, -62, 61, 61, { { -1, -62 }, { 0, -62 }, { 1, -62 } })
  -- edges
  d.edges = {}
  for a = 0, NN - 1 do
    for b = 0, NN - 1 do
      if a < NN - 1 then d.edges[ekey(a, b, a + 1, b)] = { a1 = a, b1 = b, a2 = a + 1, b2 = b } end
      if b < NN - 1 then d.edges[ekey(a, b, a, b + 1)] = { a1 = a, b1 = b, a2 = a, b2 = b + 1 } end
    end
  end
  local keys = {}
  for k in pairs(d.edges) do keys[#keys + 1] = k end
  table.sort(keys)
  rng.shuffle(keys)
  local removed = 0
  for _, k in ipairs(keys) do
    local e = d.edges[k]
    local band = e.a1 == e.a2 and e.b1 == 3 and e.b2 == 4
    local depot = (e.a2 == DEPOT[1] and e.b2 == DEPOT[2])
    if removed < 14 and not band and not depot then
      d.edges[k] = nil
      if connected(d.edges) then removed = removed + 1 else d.edges[k] = e end
    end
  end
  -- valves and gas lines
  for k, e in pairs(d.edges) do
    local band = e.a1 == e.a2 and e.b1 == 3 and e.b2 == 4
    local depot = (e.a2 == DEPOT[1] and e.b2 == DEPOT[2])
    -- no valves around the burning wellhead: the fire cannot be choked at its source
    local near_start = e.a1 <= 1 and e.b1 <= 1 and e.a2 <= 1 and e.b2 <= 1
    e.valve = band or (not depot and not near_start and rng.chance(0.45))
    e.gas = not band and not depot and rng.chance(0.2)
    -- pipes along the edge
    local x1, y1 = node_pos(e.a1, e.b1)
    local x2, y2 = node_pos(e.a2, e.b2)
    local horizontal = y1 == y2
    for t = 1, SPACE - 1 do
      local x, y = horizontal and x1 + t or x1, horizontal and y1 or y1 + t
      plan:put(e.gas and "bob-steel-pipe" or "pipe", x, y, { force = "legend", invincible = true, locked = true, sealed = true })
    end
    if e.valve then
      local mx, my = horizontal and x1 + SPACE / 2 or x1 + 1, horizontal and y1 + 1 or y1 + SPACE / 2
      plan:lever("valve:" .. k, mx, my)
      e.vx, e.vy = mx + 0.5, my + 0.5
    end
  end
  for a = 0, NN - 1 do
    for b = 0, NN - 1 do
      local x, y = node_pos(a, b)
      plan:put("pipe", x, y, { force = "legend", invincible = true, locked = true, sealed = true })
    end
  end
  plan:put("pumpjack", O - 5, O - 5, { force = "legend", invincible = true, locked = true, sealed = true })
  -- the depot
  local dx, dy = node_pos(DEPOT[1], DEPOT[2])
  for i, o in ipairs({ { -5, -5 }, { 3, -5 }, { -5, 3 }, { 3, 3 } }) do
    plan:put("storage-tank", dx + o[1], dy + o[2], { force = "legend", invincible = true, locked = true, sealed = true, key = "tank-" .. i,
      fluids = { ["crude-oil"] = 20000 } })
  end
  plan:fill("refined-concrete", dx - 12, dy - 2, dx - 8, dy + 2)
  plan:vault(dx - 11, dy - 1)
  plan:vault(dx - 9, dy - 1)
  d.burning, d.closed, d.tanks = {}, {}, 4
end

function KIND.built(site, K)
  for k, e in pairs(site.data.edges) do
    if e.valve then K.circle(site, K.abs(site, e.vx, e.vy - 1.2), 0.5, { 0.3, 0.6, 1, 0.8 }, nil, true, true) end
  end
  K.text(site, K.abs(site, 0.5, -60), { "pd-legendary-oilfield.sign" }, { 1, 0.7, 0.3 }, 1.4, nil, true)
end

local function ignite(site, K, a, b, from)
  local d = site.data
  d.burning[a .. ":" .. b] = true
  local x, y = node_pos(a, b)
  K.explode(site, K.abs(site, x + 0.5, y + 0.5), 4, 90, "big-explosion")
  for _ = 1, 5 do K.flame(site, K.abs(site, x + math.random(-3, 3), y + math.random(-3, 3))) end
  if from then
    local fx, fy = node_pos(from[1], from[2])
    for t = 2, SPACE - 2, 3 do
      K.flame(site, K.abs(site, fx + (x - fx) * t / SPACE + 0.5, fy + (y - fy) * t / SPACE + 0.5))
    end
  end
  if a == DEPOT[1] and b == DEPOT[2] then
    d.depot_fire = game.tick
    K.say(site, { "pd-legendary-oilfield.depot" })
  end
end

local function spread(site, K)
  local d = site.data
  local front, grew = {}, false
  for key in pairs(d.burning) do
    local a, b = key:match("^(%d+):(%d+)$")
    front[#front + 1] = { tonumber(a), tonumber(b) }
  end
  local head = 1
  while head <= #front do
    local n = front[head]
    head = head + 1
    for _, dlt in ipairs({ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }) do
      local a, b = n[1] + dlt[1], n[2] + dlt[2]
      local k = ekey(n[1], n[2], a, b)
      local e = d.edges[k]
      if e and not d.closed[k] and not d.burning[a .. ":" .. b] then
        ignite(site, K, a, b, n)
        grew = true
        -- a gas line passes the fire on in the same moment
        if e.gas then front[#front + 1] = { a, b } end
      end
    end
  end
  return grew
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if not d.started then
    for _, p in ipairs(ctx.players) do
      if p.inside then
        d.started = true
        ignite(site, K, 0, 0)
        d.next_spread = ctx.tick + K.ticks(12)
        K.say(site, { "pd-legendary-oilfield.fire", math.floor(K.ticks(12) / 60) })
        break
      end
    end
    return
  end
  if d.depot_fire then
    if ctx.tick >= d.depot_fire + K.ticks(6) * (5 - d.tanks) and d.tanks > 0 then
      local tank = K.get(site, "tank-" .. d.tanks)
      if tank then
        K.explode(site, tank.position, 9, 260, "massive-explosion")
        for _ = 1, 8 do K.flame(site, { x = tank.position.x + math.random(-5, 5), y = tank.position.y + math.random(-5, 5) }) end
        tank.destroy()
      end
      d.tanks = d.tanks - 1
      d.extra_stacks = (d.extra_stacks or 0) - 2
      K.say(site, { "pd-legendary-oilfield.tank", 4 - d.tanks })
      if d.tanks == 0 then K.ruin(site, { "pd-legendary-oilfield.lost" }) end
    end
    return
  end
  if ctx.tick >= (d.next_spread or 0) then
    d.next_spread = ctx.tick + K.ticks(12)
    if not spread(site, K) then
      K.say(site, { "pd-legendary-oilfield.contained" })
      local p = ctx.players[1]
      K.solve(site, p and p.player)
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  local k = key:match("^valve:(.+)$")
  local d = site.data
  local e = k and d.edges[k]
  if not e or d.closed[k] then return end
  d.closed[k] = true
  K.circle(site, K.abs(site, e.vx, e.vy - 1.2), 0.6, { 1, 0.2, 0.1, 0.9 }, nil, true, true)
  if player then player.print({ "pd-legendary-oilfield.closed" }) end
end

return KIND
