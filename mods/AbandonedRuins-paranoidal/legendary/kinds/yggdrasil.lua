-- Yggdrasil: a living maze of hedges around the World Tree. Hedges can be cut, but they grow back
-- within half a minute; strangling roots slow and hurt; spores drift through the corridors and
-- spitters lurk in the dead ends. Fire is forbidden: every flame near the World Tree burns away the
-- reward, and a great fire destroys it.
local C = require("legendary.config")
local MZ = require("legendary.maze")

local KIND = { name = "yggdrasil", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-yggdrasil-sprout" }

local N, CELL, X0 = 12, 9, -54
local TREES = { "tree-01", "tree-02", "tree-03", "tree-04", "tree-05", "tree-06" }
local HEART = { 5, 6 }
-- real flames only: the acid of the spitters is a "fire" entity too
local FLAMES = { "fire-flame", "fire-flame-on-tree", "Schall-napalm-fire-flame", "flo-long-fire", "flo-tank-fire" }

local function heart(i, j) return i >= HEART[1] and i <= HEART[2] and j >= HEART[1] and j <= HEART[2] end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "grass-1", "grass-2", "grass-1", "grass-3" }) end, -64, -64, 63, 63)
  local entry = { 5, N - 1 }
  local open = MZ.generate(N, rng, entry, heart)
  MZ.loops(N, open, rng, 0.05, heart)
  for i = HEART[1], HEART[2] do
    for j = HEART[1], HEART[2] do
      if i < HEART[2] then open[MZ.edge(i, j, i + 1, j)] = true end
      if j < HEART[2] then open[MZ.edge(i, j, i, j + 1)] = true end
    end
  end
  open[MZ.edge(5, 6, 5, 7)] = true
  -- hedge tiles
  local hedge = {}
  local function tile(x, y) hedge[x .. "," .. y] = { x, y } end
  for a = 0, N do
    for b = 0, N do
      local inner = a > HEART[1] and a <= HEART[2] and b > HEART[1] and b <= HEART[2]
      if not inner then tile(X0 + CELL * a, X0 + CELL * b) end
    end
  end
  for i = 0, N - 1 do
    for j = -1, N - 1 do
      local e = (j >= 0 and j < N - 1) and MZ.edge(i, j, i, j + 1) or nil
      local border = j == -1 or j == N - 1
      local is_entry = j == N - 1 and i == entry[1]
      if (border and not is_entry) or (e and not open[e]) then
        for t = 1, CELL - 1 do tile(X0 + CELL * i + t, X0 + CELL * (j + 1)) end
      end
    end
  end
  for j = 0, N - 1 do
    for i = -1, N - 1 do
      local e = (i >= 0 and i < N - 1) and MZ.edge(i, j, i + 1, j) or nil
      if i == -1 or i == N - 1 or (e and not open[e]) then
        for t = 1, CELL - 1 do tile(X0 + CELL * (i + 1), X0 + CELL * j + t) end
      end
    end
  end
  d.hedge = {}
  local keys = {}
  for k in pairs(hedge) do keys[#keys + 1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local t = hedge[k]
    for _, o in ipairs({ { 0.25, 0.25 }, { 0.75, 0.25 }, { 0.25, 0.75 }, { 0.75, 0.75 } }) do
      local name = rng.pick(TREES)
      plan:at(name, t[1] + o[1], t[2] + o[2], { force = "neutral" })
      d.hedge[#d.hedge + 1] = { name, t[1] + o[1], t[2] + o[2] }
    end
  end
  -- the heart: the World Tree circle
  plan:fill("grass-4", -8, -8, 8, 8)
  plan:disc("dirt-3", 0, 0, 2.5)
  for k = 0, 11 do
    local a = k * math.pi / 6
    plan:at(rng.pick(TREES), math.cos(a) * 6, math.sin(a) * 6, { force = "neutral", invincible = true, locked = true })
  end
  plan:vault(-2, -1)
  plan:vault(1, -1)
  -- roots and lurkers
  d.roots = {}
  for i = 0, N - 1 do
    for j = 0, N - 1 do
      if not heart(i, j) then
        local cx, cy = X0 + CELL * i + 1, X0 + CELL * j + 1
        if rng.chance(0.18) then
          local x, y = cx + rng.next(0, 4), cy + rng.next(0, 4)
          plan:fill("dirt-7", x, y, x + 2, y + 2)
          d.roots[#d.roots + 1] = { x, y, x + 2, y + 2 }
        end
        if MZ.degree(N, open, i, j) == 1 and rng.chance(0.4) then
          plan:at("big-spitter", cx + 4, cy + 4, { force = "legend", list = "guardian", quality = C.boss_tier(5) })
        end
      end
    end
  end
  d.scan, d.missing, d.burn = 1, {}, 0
end

function KIND.built(site, K)
  K.light(site, K.abs(site, 0, 0), 5, { 0.6, 1, 0.5 }, true)
  K.text(site, K.abs(site, X0 + CELL * 5 + 4.5, 57), { "pd-legendary-yggdrasil.sign" }, { 0.6, 1, 0.5 }, 1.5, nil, true)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  local surface = ctx.surface
  -- hedges grow back
  local n = #d.hedge
  for _ = 1, 40 do
    local i = d.scan
    d.scan = d.scan % n + 1
    local h = d.hedge[i]
    local pos = { x = site.x + h[2], y = site.y + h[3] }
    if surface.count_entities_filtered({ position = pos, radius = 0.15, type = "tree" }) > 0 then
      d.missing[i] = nil
    elseif not d.missing[i] then
      d.missing[i] = ctx.tick
    elseif ctx.tick - d.missing[i] >= K.ticks(30)
      and surface.count_entities_filtered({ position = pos, radius = 0.7, type = { "character", "car", "unit" } }) == 0 then
      surface.create_entity({ name = h[1], position = pos })
      d.missing[i] = nil
    end
  end
  -- roots and spores
  for _, p in ipairs(ctx.players) do
    if p.inside then
      for _, r in ipairs(d.roots) do
        if p.rx >= r[1] and p.rx < r[3] + 1 and p.ry >= r[2] and p.ry < r[4] + 1 then
          K.damage(p.char, 4, "poison")
          K.stick(site, p.char, "slowdown-sticker")
          break
        end
      end
      if ctx.tick % 240 < 6 then K.cloud(site, { x = p.pos.x + math.random(-6, 6), y = p.pos.y + math.random(-6, 6) }) end
    end
  end
  -- fire near the World Tree
  if ctx.tick % 120 < 6 then
    local fires = surface.count_entities_filtered({ position = { x = site.x, y = site.y }, radius = 30, name = K.names(FLAMES) })
    if fires > 0 then
      d.burn = d.burn + 1
      d.extra_stacks = (d.extra_stacks or 0) - 1
      K.say(site, { "pd-legendary-yggdrasil.fire", d.burn, 5 })
      if d.burn >= 5 then K.ruin(site, { "pd-legendary-yggdrasil.burnt" }) end
    end
  end
end

function KIND.step(site, p, K)
  if p.rx * p.rx + p.ry * p.ry < 9 then K.solve(site, p.player) end
end

return KIND
