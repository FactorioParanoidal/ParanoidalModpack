-- The Sapper's Field: literally minesweeper. Every stepped-on cell shows the number of mines among
-- its eight neighbours; a zero opens its neighbours. A mine explodes under the careless. Reach the
-- far row and the gate of the sapper's cache opens. A magnetometer at the entrance shows three safe
-- cells every two minutes.
local C = require("legendary.config")

local KIND = { name = "minesweeper", tier = "trial", size = 96, weight = 1, relic = "pd-relic-minelayer" }

local N, CELL, F0 = 20, 4, -40     -- 20 x 20 cells of 4 x 4 tiles, field from -40 to 39
local MINES = 66
local COLORS = {
  { 0.3, 0.5, 1 }, { 0.3, 0.9, 0.3 }, { 1, 0.3, 0.3 }, { 0.5, 0.3, 1 },
  { 0.8, 0.3, 0.1 }, { 0.2, 0.9, 0.9 }, { 1, 1, 1 }, { 0.7, 0.7, 0.7 },
}

local function idx(i, j) return j * N + i end

local function around(i, j)
  local out = {}
  for di = -1, 1 do
    for dj = -1, 1 do
      local a, b = i + di, j + dj
      if (di ~= 0 or dj ~= 0) and a >= 0 and b >= 0 and a < N and b < N then out[#out + 1] = { a, b } end
    end
  end
  return out
end

local function count_mines(d, i, j)
  local n = 0
  for _, c in ipairs(around(i, j)) do if d.mines[idx(c[1], c[2])] then n = n + 1 end end
  return n
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill("concrete", -48, -48, 47, 47)
  plan:fill("stone-path", F0, F0, F0 + N * CELL - 1, F0 + N * CELL - 1)
  for i = 0, N - 1 do
    for j = 0, N - 1 do
      if (i + j) % 2 == 0 then plan:fill("rough-stone-path", F0 + CELL * i, F0 + CELL * j, F0 + CELL * i + 3, F0 + CELL * j + 3) end
    end
  end
  plan:fill("hazard-concrete-left", F0, 40, F0 + N * CELL - 1, 40)
  plan:wall_ring(-48, -48, 47, 47, { { -1, 47 }, { 0, 47 }, { 1, 47 } })
  plan:wall_line(F0 - 1, -47, F0 - 1, 46)
  plan:wall_line(F0 + N * CELL, -47, F0 + N * CELL, 46)
  -- the cache room behind a gate in the north
  for x = F0, F0 + N * CELL - 1 do
    if x >= -2 and x <= 1 then
      plan:put(C.WALL, x, -41, { force = "legend", invincible = true, locked = true, list = "gate" })
    else
      plan:wall(x, -41)
    end
  end
  plan:fill("refined-concrete", F0, -47, F0 + N * CELL - 1, -42)
  plan:vault(-2, -45)
  plan:vault(1, -45)
  plan:lever("magnetometer", 6, 43)
  -- mines: none in the bottom row, which starts revealed
  d.mines, d.revealed, d.boom = {}, {}, {}
  local placed = 0
  while placed < MINES do
    local i, j = rng.next(0, N - 1), rng.next(0, N - 2)
    if not d.mines[idx(i, j)] then
      d.mines[idx(i, j)] = true
      placed = placed + 1
    end
  end
end

local function cell_center(site, i, j)
  return { x = site.x + F0 + CELL * i + 2, y = site.y + F0 + CELL * j + 2 }
end

local function reveal(site, K, i, j, tiles, out)
  local d = site.data
  local queue = { { i, j } }
  local head = 1
  while head <= #queue do
    local c = queue[head]
    head = head + 1
    local k = idx(c[1], c[2])
    if not d.revealed[k] and not d.mines[k] then
      d.revealed[k] = true
      local n = count_mines(d, c[1], c[2])
      out[#out + 1] = { c[1], c[2], n }
      for x = 0, CELL - 1 do
        for y = 0, CELL - 1 do
          tiles[#tiles + 1] = { name = "refined-concrete", position = {
            site.x + F0 + CELL * c[1] + x, site.y + F0 + CELL * c[2] + y } }
        end
      end
      if n == 0 then
        for _, nb in ipairs(around(c[1], c[2])) do queue[#queue + 1] = nb end
      end
    end
  end
end

local function open(site, K, list)
  local tiles, out = {}, {}
  for _, c in ipairs(list) do reveal(site, K, c[1], c[2], tiles, out) end
  if #tiles > 0 then K.surface(site).set_tiles(tiles, true, false, true, false) end
  for _, c in ipairs(out) do
    if c[3] > 0 then
      K.ground_text(site, cell_center(site, c[1], c[2]), tostring(c[3]), COLORS[c[3]], 3, true)
    end
  end
end

function KIND.built(site, K)
  local row = {}
  for i = 0, N - 1 do row[#row + 1] = { i, N - 1 } end
  open(site, K, row)
  K.text(site, K.abs(site, 0, 44), { "pd-legendary-minesweeper.sign" }, { 1, 0.9, 0.4 }, 1.4, nil, true)
end

local function cell_at(rx, ry)
  local i, j = math.floor((rx - F0) / CELL), math.floor((ry - F0) / CELL)
  if i < 0 or j < 0 or i >= N or j >= N then return nil end
  return i, j
end

function KIND.step(site, p, K)
  local d = site.data
  if p.ry < -41 then
    if d.gate_open then K.solve(site, p.player) end
    return
  end
  local i, j = cell_at(p.rx, p.ry)
  if not i then return end
  local k = idx(i, j)
  if d.mines[k] and not d.boom[k] then
    d.boom[k] = true
    d.revealed[k] = true
    local pos = cell_center(site, i, j)
    K.explode(site, p.pos, 3.5, 160, "big-explosion")
    K.effect(site, "medium-scorchmark", pos)
    K.ground_text(site, pos, "X", { 1, 0.1, 0.1 }, 3, true)
    p.player.print({ "pd-legendary-minesweeper.boom" }, { color = { 1, 0.3, 0.2 } })
  elseif not d.revealed[k] then
    open(site, K, { { i, j } })
  end
  if j == 0 and not d.gate_open then
    d.gate_open = true
    K.destroy_list(site, "gate")
    K.say(site, { "pd-legendary-minesweeper.gate" })
    K.sound(site, "utility/game_won", K.abs(site, 0, -41))
  end
end

function KIND.lever(site, key, player, entity, K)
  if key ~= "magnetometer" then return end
  local d = site.data
  -- three hidden safe cells next to the revealed area
  local frontier = {}
  for i = 0, N - 1 do
    for j = 0, N - 1 do
      local k = idx(i, j)
      if not d.revealed[k] and not d.mines[k] then
        for _, nb in ipairs(around(i, j)) do
          if d.revealed[idx(nb[1], nb[2])] then frontier[#frontier + 1] = { i, j } break end
        end
      end
    end
  end
  local shown = 0
  while shown < 3 and #frontier > 0 do
    local pick = table.remove(frontier, math.random(#frontier))
    K.circle(site, cell_center(site, pick[1], pick[2]), 1.6, { 0.2, 1, 0.3, 0.45 }, 60 * 40, true)
    shown = shown + 1
  end
  K.say(site, { "pd-legendary-minesweeper.magnet", shown })
  d.magnet_ready = game.tick + K.ticks(120)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if d.magnet_ready and ctx.tick >= d.magnet_ready and not K.get(site, "magnetometer") then
    K.relever(site, "magnetometer", 6.5, 43.5)
    d.magnet_ready = nil
  end
end

return KIND
