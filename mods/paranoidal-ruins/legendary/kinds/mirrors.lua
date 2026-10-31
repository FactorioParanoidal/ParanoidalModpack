-- The Hall of Mirrors: an ancient emitter burns a beam across a hall of mirrors. Mine a mirror to
-- turn it; guide the beam into the crystal receiver. The beam burns anyone who crosses it.
local C = require("legendary.config")

local KIND = { name = "mirrors", tier = "trial", size = 64, weight = 1, relic = "pd-relic-prism-turret" }

local N, CELL, G0 = 10, 5, -25

local function center(i, j) return G0 + CELL * i + 2.5, G0 + CELL * j + 2.5 end

local function reflect(kind, dx, dy)
  if kind == "/" then return -dy, -dx end
  return dy, dx
end

-- Traces the beam; returns segments (relative points) and whether it reached the receiver.
local function trace(d)
  local pts = { { G0 - 2.5, G0 + CELL * d.row + 2.5 } }
  local i, j, dx, dy = 0, d.row, 1, 0
  local steps = 0
  while steps < 200 do
    steps = steps + 1
    if i < 0 or j < 0 or i >= N or j >= N then
      local cx, cy = center(i, j)
      pts[#pts + 1] = { cx, cy }
      local hit = d.receiver.i == i and d.receiver.j == j
      return pts, hit
    end
    local m = d.mirrors[i .. "," .. j]
    if d.blocks[i .. "," .. j] then
      local cx, cy = center(i, j)
      pts[#pts + 1] = { cx - dx * 2, cy - dy * 2 }
      return pts, false
    end
    if m then
      local cx, cy = center(i, j)
      pts[#pts + 1] = { cx, cy }
      dx, dy = reflect(m.kind, dx, dy)
    end
    i, j = i + dx, j + dy
  end
  return pts, false
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill("concrete", -32, -32, 31, 31)
  plan:fill(function(x, y) return ((math.floor((x - G0) / CELL) + math.floor((y - G0) / CELL)) % 2 == 0) and "lab-dark-1" or "lab-dark-2" end,
    G0, G0, G0 + N * CELL - 1, G0 + N * CELL - 1)
  plan:wall_ring(-32, -32, 31, 31, { { -1, 31 }, { 0, 31 } })
  plan:wall_ring(G0 - 1, G0 - 1, G0 + N * CELL, G0 + N * CELL, { { -1, G0 + N * CELL }, { 0, G0 + N * CELL } })
  -- a solvable path: random walk with turns from the west edge to an exit on the north or east
  local path, mirrors, exit_i, exit_j
  for _ = 1, 400 do
    local row = rng.next(1, N - 2)
    local i, j, dx, dy = 0, row, 1, 0
    local visited, m, ok = {}, {}, false
    local count = 0
    for _ = 1, 60 do
      if i < 0 or j < 0 or i >= N or j >= N then
        ok = (j < 0 or i >= N) and count >= 4
        exit_i, exit_j = i, j
        break
      end
      local k = i .. "," .. j
      if visited[k] then break end
      visited[k] = true
      if rng.chance(0.38) and i > 0 then
        local kind = rng.chance(0.5) and "/" or "\\"
        m[k] = { kind = kind, i = i, j = j }
        count = count + 1
        dx, dy = reflect(kind, dx, dy)
      end
      i, j = i + dx, j + dy
    end
    if ok then
      path, mirrors = visited, m
      d.row = row
      break
    end
  end
  if not path then
    -- fallback: one mirror turning the beam north
    d.row = 5
    path = { ["5,5"] = true }
    mirrors = { ["5,5"] = { kind = "/", i = 5, j = 5 } }
    exit_i, exit_j = 5, -1
    for x = 0, 4 do path[x .. ",5"] = true end
    for y = 0, 4 do path["5," .. y] = true end
  end
  d.receiver = { i = exit_i, j = exit_j }
  d.mirrors, d.blocks, d.solution = {}, {}, {}
  for k, m in pairs(mirrors) do d.solution[k] = m.kind end
  -- the solution mirrors start turned at random (at least two wrong), plus decoys
  local wrong = 0
  for k, m in pairs(mirrors) do
    local flip = rng.chance(0.6)
    if flip then wrong = wrong + 1 end
    d.mirrors[k] = { kind = flip and (m.kind == "/" and "\\" or "/") or m.kind, i = m.i, j = m.j }
  end
  if wrong < 2 then
    for _, m in pairs(d.mirrors) do
      m.kind = m.kind == "/" and "\\" or "/"
      wrong = wrong + 1
      if wrong >= 2 then break end
    end
  end
  local decoys = 0
  for _ = 1, 200 do
    if decoys >= 9 then break end
    local i, j = rng.next(1, N - 1), rng.next(0, N - 1)
    local k = i .. "," .. j
    if not path[k] and not d.mirrors[k] then
      d.mirrors[k] = { kind = rng.chance(0.5) and "/" or "\\", i = i, j = j }
      decoys = decoys + 1
    end
  end
  for _ = 1, 6 do
    local i, j = rng.next(1, N - 1), rng.next(0, N - 1)
    local k = i .. "," .. j
    if not path[k] and not d.mirrors[k] then d.blocks[k] = true end
  end
  for k, m in pairs(d.mirrors) do
    local cx, cy = center(m.i, m.j)
    plan:lever("m:" .. k, math.floor(cx), math.floor(cy))
  end
  for k in pairs(d.blocks) do
    local i, j = k:match("^(%-?%d+),(%-?%d+)$")
    local cx, cy = center(tonumber(i), tonumber(j))
    plan:wall(math.floor(cx), math.floor(cy))
    plan:wall(math.floor(cx) - 1, math.floor(cy))
  end
  local ex, ey = G0 - 3, G0 + CELL * d.row + 2
  plan:put("small-lamp", ex, ey, { force = "legend", invincible = true, locked = true })
  local rx, ry = center(exit_i, exit_j)
  plan:put("small-lamp", math.floor(rx), math.floor(ry), { force = "legend", invincible = true, locked = true, key = "receiver" })
  plan:fill("refined-concrete", -6, 26, 5, 30)
  plan:vault(-3, 28)
  plan:vault(2, 28)
end

local function draw_mirror(site, K, m)
  local cx, cy = center(m.i, m.j)
  local a, b
  if m.kind == "/" then a, b = { cx - 1.8, cy + 1.8 }, { cx + 1.8, cy - 1.8 } else a, b = { cx - 1.8, cy - 1.8 }, { cx + 1.8, cy + 1.8 } end
  if m.render and m.render.valid then m.render.destroy() end
  m.render = rendering.draw_line({ surface = site.surface, from = K.abs(site, a[1], a[2]), to = K.abs(site, b[1], b[2]),
    color = { 0.7, 0.9, 1, 0.9 }, width = 4, draw_on_ground = true })
end

local function redraw_beam(site, K)
  local d = site.data
  for _, r in pairs(d.beam or {}) do if r.valid then r.destroy() end end
  local pts, hit = trace(d)
  d.beam, d.segments = {}, {}
  for n = 1, #pts - 1 do
    local a, b = pts[n], pts[n + 1]
    d.beam[#d.beam + 1] = rendering.draw_line({ surface = site.surface, from = K.abs(site, a[1], a[2]), to = K.abs(site, b[1], b[2]),
      color = hit and { 0.3, 1, 0.4, 0.9 } or { 1, 0.15, 0.1, 0.9 }, width = 5 })
    d.segments[#d.segments + 1] = { a[1], a[2], b[1], b[2] }
  end
  return hit
end

function KIND.built(site, K)
  for _, m in pairs(site.data.mirrors) do draw_mirror(site, K, m) end
  redraw_beam(site, K)
  K.text(site, K.abs(site, 0, 30.5), { "pd-legendary-mirrors.sign" }, { 0.8, 0.9, 1 }, 1.3, nil, true)
end

function KIND.lever(site, key, player, entity, K)
  local k = key:match("^m:(.+)$")
  local d = site.data
  local m = k and d.mirrors[k]
  if not m then return end
  m.kind = m.kind == "/" and "\\" or "/"
  local cx, cy = center(m.i, m.j)
  K.relever(site, key, math.floor(cx) + 0.5, math.floor(cy) + 0.5)
  draw_mirror(site, K, m)
  if redraw_beam(site, K) then
    K.say(site, { "pd-legendary-mirrors.lit" })
    K.solve(site, player)
  end
end

local function seg_dist(px, py, s)
  local ax, ay, bx, by = s[1], s[2], s[3], s[4]
  local vx, vy = bx - ax, by - ay
  local len2 = vx * vx + vy * vy
  local t = len2 > 0 and math.max(0, math.min(1, ((px - ax) * vx + (py - ay) * vy) / len2)) or 0
  local qx, qy = ax + vx * t, ay + vy * t
  return math.sqrt((px - qx) ^ 2 + (py - qy) ^ 2)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  for _, p in ipairs(ctx.players) do
    if p.inside then
      for _, s in ipairs(d.segments or {}) do
        if seg_dist(p.rx, p.ry, s) < 0.7 then
          K.damage(p.char, 18, "laser")
          K.stick(site, p.char, "fire-sticker")
          break
        end
      end
    end
  end
end

function KIND.solved(site, K)
  for _, r in pairs(site.data.beam or {}) do if r.valid then r.destroy() end end
end

return KIND
