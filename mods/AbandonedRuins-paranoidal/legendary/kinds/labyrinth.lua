-- Labyrinth of the Minotaur: an untouchable maze that rebuilds itself, ballistas glowing red in the
-- wall pillars (hide behind corners: their bolts are stopped by walls), and the Minotaur that hunts by the sound
-- of steps. Four levers in far dead ends silence the ballistas and open the sanctum; killing the
-- Minotaur opens it too. The reward waits in the sanctum.
local C = require("legendary.config")
local MZ = require("legendary.maze")

local KIND = { name = "labyrinth", tier = "trial", size = 128, weight = 1.2, relic = "pd-relic-daedalus-workshop" }

local N, CELL, X0 = 30, 4, -60
local SANCTUM = { 13, 16 }            -- sanctum cells i, j in [13, 16]
local ENTRY = { 14, 29 }
local DOOR = { -3, 8, 3, 8 }          -- door tiles (x1, y, x2, y)

local function sanctum_cell(i, j) return i >= SANCTUM[1] and i <= SANCTUM[2] and j >= SANCTUM[1] and j <= SANCTUM[2] end

local function cell_center(i, j) return X0 + CELL * i + 2.5, X0 + CELL * j + 2.5 end

local function cell_of(rx, ry)
  local i, j = math.floor((rx - X0) / CELL), math.floor((ry - X0) / CELL)
  if i < 0 or j < 0 or i >= N or j >= N then return nil end
  return i, j
end

-- Wall tiles of an edge (3 tiles between two cells).
local function edge_tiles(edge)
  local kind, i, j = edge:match("^(%a):(%d+):(%d+)$")
  i, j = tonumber(i), tonumber(j)
  local out = {}
  for t = 1, 3 do
    if kind == "h" then
      out[#out + 1] = { X0 + CELL * (i + 1), X0 + CELL * j + t }
    else
      out[#out + 1] = { X0 + CELL * i + t, X0 + CELL * (j + 1) }
    end
  end
  return out, kind, i, j
end

local function quadrant(rx, ry)
  if rx < 0 then return ry < 0 and 1 or 3 end
  return ry < 0 and 2 or 4
end

function KIND.layout(plan, site)
  local rng = plan.rng
  local d = site.data
  plan:fill("concrete", -64, -64, 63, 63)
  plan:fill("stone-path", X0, X0, X0 + N * CELL, X0 + N * CELL)
  plan:fill(function(x, y) return ((x + y) % 2 == 0) and "black-refined-concrete" or "refined-concrete" end, -7, -7, 7, 7)
  plan:fill("red-refined-concrete", -1, -1, 0, 0)
  local blocked = function(i, j) return sanctum_cell(i, j) end
  local open = MZ.generate(N, rng, ENTRY, blocked)
  MZ.loops(N, open, rng, 0.06, blocked)
  -- sanctum: one room without inner walls
  for i = SANCTUM[1], SANCTUM[2] do
    for j = SANCTUM[1], SANCTUM[2] do
      if i < SANCTUM[2] then open[MZ.edge(i, j, i + 1, j)] = true end
      if j < SANCTUM[2] then open[MZ.edge(i, j, i, j + 1)] = true end
    end
  end
  -- the door edge is open in the graph but closed by the door walls
  open[MZ.edge(14, 16, 14, 17)] = true
  open[MZ.edge(15, 16, 15, 17)] = true
  d.open = open

  -- walls: pillars, closed edges and the border; the door is a separate list
  local door = {}
  for x = DOOR[1], DOOR[3] do door[x .. "," .. DOOR[2]] = true end
  for a = 0, N do
    for b = 0, N do
      local x, y = X0 + CELL * a, X0 + CELL * b
      local inner = a > SANCTUM[1] and a <= SANCTUM[2] and b > SANCTUM[1] and b <= SANCTUM[2]
      if not inner and not door[x .. "," .. y] then plan:wall(x, y) end
    end
  end
  for i = 0, N - 1 do
    for j = -1, N - 1 do
      -- vertical neighbours (i, j) - (i, j + 1); j = -1 is the top border
      local e = j >= 0 and j < N - 1 and MZ.edge(i, j, i, j + 1) or nil
      local border = j == -1 or j == N - 1
      local entry = (j == N - 1 and i == ENTRY[1])
      if (border and not entry) or (e and not open[e]) then
        for t = 1, 3 do plan:wall(X0 + CELL * i + t, X0 + CELL * (j + 1)) end
      end
    end
  end
  for j = 0, N - 1 do
    for i = -1, N - 1 do
      local e = i >= 0 and i < N - 1 and MZ.edge(i, j, i + 1, j) or nil
      local border = i == -1 or i == N - 1
      if border or (e and not open[e]) then
        for t = 1, 3 do plan:wall(X0 + CELL * (i + 1), X0 + CELL * j + t) end
      end
    end
  end
  for x = DOOR[1], DOOR[3] do
    plan:put(C.WALL, x, DOOR[2], { force = "legend", invincible = true, locked = true, list = "door" })
    plan.walls[x .. "," .. DOOR[2]] = true
  end

  -- levers in the farthest dead end of each quadrant
  local dist = MZ.distances(N, open, ENTRY)
  local best = {}
  for i = 0, N - 1 do
    for j = 0, N - 1 do
      local k = dist[i * N + j]
      if k and not sanctum_cell(i, j) and MZ.degree(N, open, i, j) == 1 then
        local cx, cy = cell_center(i, j)
        local q = quadrant(cx, cy)
        if not best[q] or k > best[q].k then best[q] = { k = k, i = i, j = j } end
      end
    end
  end
  d.levers, d.lever_total = {}, 0
  for q = 1, 4 do
    local b = best[q]
    if b then
      local cx, cy = cell_center(b.i, b.j)
      plan:lever("lever-" .. q, math.floor(cx), math.floor(cy))
      d.levers[q] = false
      d.lever_total = d.lever_total + 1
    end
  end

  -- ballistas replace wall pillars
  d.ballistas = {}
  local pillars = {}
  for a = 1, N - 1 do
    for b = 1, N - 1 do
      local near_sanctum = a >= SANCTUM[1] - 1 and a <= SANCTUM[2] + 2 and b >= SANCTUM[1] - 1 and b <= SANCTUM[2] + 2
      local near_entry = b >= N - 3 and a >= ENTRY[1] - 2 and a <= ENTRY[1] + 3
      if not near_sanctum and not near_entry then pillars[#pillars + 1] = { a, b } end
    end
  end
  rng.shuffle(pillars)
  for k = 1, 26 do
    local p = pillars[k]
    local x, y = X0 + CELL * p[1], X0 + CELL * p[2]
    d.ballistas[#d.ballistas + 1] = { x = x + 0.5, y = y + 0.5, q = quadrant(x, y), next = 0 }
  end

  -- sanctum: the reward and two braziers of light
  plan:vault(-2, -1)
  plan:vault(1, -1)
  d.walls = plan.walls
  d.minotaur_cell = { 2, 2 }
  d.shift_every = 300
end

function KIND.built(site, K)
  for _, b in ipairs(site.data.ballistas) do K.light(site, K.abs(site, b.x, b.y), 0.6, { 1, 0.15, 0.1 }, true) end
  K.light(site, K.abs(site, 0, 0), 3, { 1, 0.8, 0.3 }, true)
  K.text(site, K.abs(site, -2.5, 61), { "pd-legendary-labyrinth.gate" }, { 1, 0.8, 0.4 }, 1.6, nil, true)
end

-- Minotaur ---------------------------------------------------------------------------------

local function random_far_cell(site, from_rx, from_ry)
  local best, best_d
  for _ = 1, 8 do
    local i, j = math.random(0, N - 1), math.random(0, N - 1)
    if not sanctum_cell(i, j) then
      local cx, cy = cell_center(i, j)
      local dd = (cx - from_rx) ^ 2 + (cy - from_ry) ^ 2
      if not best_d or dd > best_d then best, best_d = { cx, cy }, dd end
    end
  end
  return best
end

local function spawn_minotaur(site, K)
  local d = site.data
  local cx, cy = cell_center(d.minotaur_cell[1], d.minotaur_cell[2])
  local unit = K.spawn(site, "big-biter", K.abs(site, cx, cy), C.boss_tier(12))
  if not unit then return end
  site.ents = site.ents or {}
  site.ents.minotaur = unit
  site.lists = site.lists or {}
  site.lists.guardian = site.lists.guardian or {}
  table.insert(site.lists.guardian, unit)
  K.watch(site, unit, "minotaur")
  rendering.draw_text({ text = { "pd-legendary-labyrinth.minotaur" }, surface = site.surface, target = { entity = unit, offset = { 0, -2.2 } },
    color = { 1, 0.3, 0.2 }, scale = 1.4, alignment = "center" })
  d.minotaur_alive = true
  d.mode = "roam"
  d.next_roam = 0
end

local function open_door(site, K, message)
  local d = site.data
  if d.door_open then return end
  d.door_open = true
  K.destroy_list(site, "door")
  for x = DOOR[1], DOOR[3] do d.walls[x .. "," .. DOOR[2]] = nil end
  K.say(site, message)
  K.sound(site, "utility/game_won", K.abs(site, 0, 8))
end

local function minotaur_tick(site, ctx, K)
  local d = site.data
  local unit = site.ents and site.ents.minotaur
  if not (unit and unit.valid) then return end
  local mpos = unit.position
  local mrx, mry = mpos.x - site.x, mpos.y - site.y
  d.last = d.last or {}
  local target, target_p
  if d.hunt then
    for _, p in ipairs(ctx.players) do
      if p.player.index == d.hunt.player then target_p = p end
    end
  end
  for _, p in ipairs(ctx.players) do
    local last = d.last[p.player.index]
    local moved = last and ((p.pos.x - last.x) ^ 2 + (p.pos.y - last.y) ^ 2) > 0.04
    d.last[p.player.index] = { x = p.pos.x, y = p.pos.y }
    p.moved = moved
    local close = ((p.pos.x - mpos.x) ^ 2 + (p.pos.y - mpos.y) ^ 2) < 30 * 30
    if not d.hunt and moved and close and p.inside and ctx.tick >= (d.calm_until or 0) then
      target = p
    end
  end
  if target then
    d.hunt = { player = target.player.index, still = 0 }
    d.mode = "hunt"
    K.attack(unit, target.char)
    target.player.print({ "pd-legendary-labyrinth.hunt" }, { color = { 1, 0.3, 0.2 } })
    K.sound(site, "utility/alert_destroyed", target.pos)
    return
  end
  if d.hunt then
    local far = not target_p or ((target_p.pos.x - mpos.x) ^ 2 + (target_p.pos.y - mpos.y) ^ 2) > 45 * 45
    if target_p and not target_p.moved then d.hunt.still = d.hunt.still + 6 elseif target_p then d.hunt.still = 0 end
    if far or d.hunt.still >= 120 then
      if target_p and not far then target_p.player.print({ "pd-legendary-labyrinth.lost" }) end
      d.hunt = nil
      d.mode = "roam"
      d.calm_until = ctx.tick + 300
      local dest = random_far_cell(site, mrx, mry)
      K.go(unit, K.abs(site, dest[1], dest[2]), defines.distraction.none)
      d.next_roam = ctx.tick + 900
    end
    return
  end
  if ctx.tick >= (d.next_roam or 0) then
    local dest = random_far_cell(site, mrx, mry)
    K.go(unit, K.abs(site, dest[1], dest[2]), defines.distraction.none)
    d.next_roam = ctx.tick + 600 + math.random(0, 600)
  end
end

-- Ballistas --------------------------------------------------------------------------------

local function ballista_tick(site, ctx, K)
  local d = site.data
  local aimed = 0
  for _, b in ipairs(d.ballistas) do
    if b.aim and ctx.tick >= b.aim.at then
      local dx, dy = b.aim.x - b.x, b.aim.y - b.y
      local len = math.sqrt(dx * dx + dy * dy)
      if len > 0.5 then
        local from = K.abs(site, b.x + dx / len * 1.2, b.y + dy / len * 1.2)
        local to = K.abs(site, b.x + dx / len * 40, b.y + dy / len * 40)
        K.bolt(site, from, to, 0.8)
      end
      b.aim = nil
    elseif not b.aim and ctx.tick >= b.next and not d.levers[b.q] and aimed < 5 then
      for _, p in ipairs(ctx.players) do
        local dx, dy = p.rx - b.x, p.ry - b.y
        if p.inside and dx * dx + dy * dy < 22 * 22 and not K.blocked(site, b.x, b.y, p.rx, p.ry) then
          b.aim = { x = p.rx, y = p.ry, at = ctx.tick + 42 }
          b.next = ctx.tick + 150 + math.random(0, 90)
          K.line(site, K.abs(site, b.x, b.y), p.pos, { 1, 0.1, 0.1, 0.8 }, 42, 2, 0.4)
          aimed = aimed + 1
          break
        end
      end
    end
  end
end

-- Shifting walls -----------------------------------------------------------------------------

local function occupied(site, K, tiles)
  local surface = K.surface(site)
  for _, t in ipairs(tiles) do
    local area = { { site.x + t[1], site.y + t[2] }, { site.x + t[1] + 1, site.y + t[2] + 1 } }
    if surface.count_entities_filtered({ area = area, type = { "character", "unit", "car", "spider-vehicle" } }) > 0 then return true end
  end
  return false
end

local function set_edge(site, K, edge, opened)
  local d = site.data
  local tiles = edge_tiles(edge)
  local surface = K.surface(site)
  d.open[edge] = opened or nil
  for _, t in ipairs(tiles) do
    local k = t[1] .. "," .. t[2]
    if opened then
      local area = { { site.x + t[1] + 0.1, site.y + t[2] + 0.1 }, { site.x + t[1] + 0.9, site.y + t[2] + 0.9 } }
      for _, w in pairs(surface.find_entities_filtered({ area = area, name = C.WALL, force = C.FORCE })) do w.destroy() end
      d.walls[k] = nil
    else
      K.place(site, C.WALL, t[1] + 0.5, t[2] + 0.5, { force = "legend", invincible = true, locked = true })
      d.walls[k] = true
    end
    K.effect(site, "explosion-hit", K.abs(site, t[1] + 0.5, t[2] + 0.5))
  end
end

-- Path of edges between two cells avoiding one edge (BFS with parents).
local function path_edges(open, a, b, skip)
  local start, goal = a[1] * N + a[2], b[1] * N + b[2]
  local parent = { [start] = false }
  local queue, head = { a }, 1
  while head <= #queue do
    local c = queue[head]
    head = head + 1
    local ck = c[1] * N + c[2]
    if ck == goal then break end
    for _, nb in ipairs(MZ.neighbours(N, c[1], c[2])) do
      local k = nb[1] * N + nb[2]
      local e = MZ.edge(c[1], c[2], nb[1], nb[2])
      if parent[k] == nil and e ~= skip and open[e] then
        parent[k] = c
        queue[#queue + 1] = nb
      end
    end
  end
  if parent[goal] == nil then return nil end
  local edges, cur = {}, b
  while parent[cur[1] * N + cur[2]] do
    local p = parent[cur[1] * N + cur[2]]
    edges[#edges + 1] = MZ.edge(p[1], p[2], cur[1], cur[2])
    cur = p
  end
  return edges
end

local function movable(edge)
  local _, kind, i, j = edge_tiles(edge)
  local a, b
  if kind == "h" then a, b = { i, j }, { i + 1, j } else a, b = { i, j }, { i, j + 1 } end
  if sanctum_cell(a[1], a[2]) or sanctum_cell(b[1], b[2]) then return nil end
  if (a[1] == 14 or a[1] == 15) and a[2] == 17 and kind == "v" then return nil end
  return a, b, kind
end

local function shift(site, K)
  local d = site.data
  local swaps = 0
  for _ = 1, 60 do
    if swaps >= 10 then break end
    local i, j = math.random(0, N - 2), math.random(0, N - 2)
    local e = math.random() < 0.5 and MZ.edge(i, j, i + 1, j) or MZ.edge(i, j, i, j + 1)
    local a, b = movable(e)
    if a and not d.open[e] and not occupied(site, K, edge_tiles(e)) then
      local path = path_edges(d.open, a, b, e)
      if path and #path > 1 then
        -- close one edge of the cycle that the new passage creates
        local candidates = {}
        for _, pe in ipairs(path) do
          if movable(pe) and not occupied(site, K, edge_tiles(pe)) then candidates[#candidates + 1] = pe end
        end
        if #candidates > 0 then
          local close = candidates[math.random(#candidates)]
          set_edge(site, K, e, true)
          set_edge(site, K, close, false)
          swaps = swaps + 1
        end
      end
    end
  end
  K.say(site, { "pd-legendary-labyrinth.shift" })
end

-- Hooks -------------------------------------------------------------------------------------

function KIND.tick(site, ctx, K)
  local d = site.data
  if d.minotaur_alive == nil then spawn_minotaur(site, K) end
  if not d.next_shift then d.next_shift = ctx.tick + K.ticks(d.shift_every) end
  if not d.warned and ctx.tick >= d.next_shift - 300 then
    d.warned = true
    K.say(site, { "pd-legendary-labyrinth.shift-warning" }, 0)
  end
  if ctx.tick >= d.next_shift then
    shift(site, K)
    d.next_shift = ctx.tick + K.ticks(d.shift_every)
    d.warned = false
  end
  minotaur_tick(site, ctx, K)
  ballista_tick(site, ctx, K)
end

function KIND.lever(site, key, player, entity, K)
  local q = tonumber(key:match("^lever%-(%d)$"))
  local d = site.data
  if not q or d.levers[q] then return end
  d.levers[q] = true
  local pulled = 0
  for _, v in pairs(d.levers) do if v then pulled = pulled + 1 end end
  K.say(site, { "pd-legendary-labyrinth.lever", pulled, d.lever_total })
  -- the noise wakes the Minotaur
  local unit = site.ents and site.ents.minotaur
  if unit and unit.valid and player and player.character then
    d.hunt = { player = player.index, still = -120 }
    d.mode = "hunt"
    K.attack(unit, player.character)
  end
  if pulled >= d.lever_total then open_door(site, K, { "pd-legendary-labyrinth.door" }) end
end

function KIND.destroyed(site, tag, _, K)
  if tag == "minotaur" then
    site.data.minotaur_alive = false
    K.feat(site, "labyrinth-theseus", nil)
    open_door(site, K, { "pd-legendary-labyrinth.minotaur-dead" })
  end
end

function KIND.step(site, p, K)
  if site.data.door_open and p.rx >= -7 and p.rx < 8 and p.ry >= -7 and p.ry < 8 then
    if site.data.minotaur_alive ~= false then K.feat(site, "labyrinth-pacifist", p.player) end
    K.solve(site, p.player)
  end
end

return KIND
