-- The Broken Gates: stone platforms in a deep lake, connected only by portal pads. Every platform
-- has two pads; each pad sends you to some platform. Two platforms are worm pits. Map the jumps and
-- find the one pad that leads to the treasury. Every three minutes two pads trade destinations.
local C = require("legendary.config")

local KIND = { name = "gates", tier = "trial", size = 96, weight = 1, relic = "pd-relic-forerunner-gate" }

local GRID = { -30, 0, 30 }
local ROWS = { -24, 0, 24 }
local PAD_TILES = { "red-refined-concrete", "blue-refined-concrete", "green-refined-concrete",
  "yellow-refined-concrete", "cyan-refined-concrete", "purple-refined-concrete", "orange-refined-concrete",
  "pink-refined-concrete", "black-refined-concrete", "brown-refined-concrete", "acid-refined-concrete" }
local LETTERS = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T" }

-- Is the treasury reachable from the start? (BFS over platforms)
local function solvable(d)
  local seen, queue, head = { [0] = true }, { 0 }, 1
  while head <= #queue do
    local plat = queue[head]
    head = head + 1
    for _, pad in ipairs(d.pads) do
      if pad.from == plat then
        if pad.dest == -1 then return true end
        if pad.dest >= 0 and not seen[pad.dest] then
          seen[pad.dest] = true
          queue[#queue + 1] = pad.dest
        end
      end
    end
  end
  return false
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill("deepwater", -48, -48, 47, 47)
  plan:fill(function() return rng.pick({ "sand-1", "sand-2" }) end, -48, 38, 47, 47)
  -- platforms: 0 = shore (start), 1..9 grid, -1 = treasury
  d.platforms = { [0] = { x = 0, y = 42, kind = "start" } }
  local k = 0
  for _, py in ipairs(ROWS) do
    for _, px in ipairs(GRID) do
      k = k + 1
      d.platforms[k] = { x = px, y = py, kind = "normal" }
      plan:fill("stone-path", px - 5, py - 5, px + 4, py + 4)
      plan:fill("rough-stone-path", px - 5, py - 5, px + 4, py - 5)
    end
  end
  local pits = { rng.next(1, 9) }
  repeat pits[2] = rng.next(1, 9) until pits[2] ~= pits[1]
  for _, i in ipairs(pits) do d.platforms[i].kind = "pit" end
  d.platforms[-1] = { x = 0, y = -42, kind = "vault" }
  plan:fill("lab-dark-1", -6, -45, 5, -38)
  plan:vault(-2, -43)
  plan:vault(1, -43)
  -- pads: two per platform (one on pits, leading home)
  d.pads = {}
  local function add_pad(from, side)
    local p = d.platforms[from]
    local x = from == 0 and (side == 1 and -6 or 3) or (side == 1 and p.x - 4 or p.x + 1)
    local y = from == 0 and 40 or p.y - 3
    d.pads[#d.pads + 1] = { from = from, x = x, y = y, dest = 0, letter = LETTERS[#d.pads + 1], tile = PAD_TILES[(#d.pads % #PAD_TILES) + 1] }
    plan:fill(d.pads[#d.pads].tile, x, y, x + 2, y + 2)
  end
  add_pad(0, 1) add_pad(0, 2)
  for i = 1, 9 do
    if d.platforms[i].kind == "pit" then add_pad(i, 1) else add_pad(i, 1) add_pad(i, 2) end
  end
  -- destinations: a hidden chain start -> a -> b -> c -> treasury, the rest random
  local normal = {}
  for i = 1, 9 do if d.platforms[i].kind == "normal" then normal[#normal + 1] = i end end
  rng.shuffle(normal)
  local chain = { 0, normal[1], normal[2], normal[3] }
  for _, pad in ipairs(d.pads) do
    if d.platforms[pad.from].kind == "pit" then
      pad.dest = 0
    else
      local r = rng.next()
      if r < 0.2 then pad.dest = pits[rng.next(1, 2)]
      elseif r < 0.35 then pad.dest = 0
      else pad.dest = rng.pick(normal) end
    end
  end
  -- wire the chain through the first pad of each chain platform
  for c = 1, #chain do
    for _, pad in ipairs(d.pads) do
      if pad.from == chain[c] then
        pad.dest = chain[c + 1] or -1
        break
      end
    end
  end
  -- worms in the pits
  for _, i in ipairs(pits) do
    local p = d.platforms[i]
    plan:put("medium-worm-turret", p.x - 3, p.y + 1, { force = "legend", list = "worm", quality = "rare" })
    plan:put("medium-worm-turret", p.x + 2, p.y + 1, { force = "legend", list = "worm", quality = "rare" })
  end
  d.cool = {}
end

function KIND.built(site, K)
  local d = site.data
  for _, pad in ipairs(d.pads) do
    K.ground_text(site, K.abs(site, pad.x + 1.5, pad.y + 1.5), pad.letter, { 1, 1, 1 }, 3, true)
  end
  K.text(site, K.abs(site, 0, 46), { "pd-legendary-gates.sign" }, { 0.7, 0.9, 1 }, 1.4, nil, true)
end

local function arrival(site, plat)
  local p = site.data.platforms[plat]
  if plat == 0 then return { x = site.x + p.x + 0.5, y = site.y + p.y + 3.5 } end
  if plat == -1 then return { x = site.x + 0.5, y = site.y - 40 } end
  return { x = site.x + p.x + 0.5, y = site.y + p.y + 2.5 }
end

function KIND.step(site, p, K)
  local d = site.data
  if p.ry < -38 and p.ry > -46 and p.rx > -6 and p.rx < 6 then
    K.solve(site, p.player)
    return
  end
  if (d.cool[p.player.index] or 0) > game.tick or p.vehicle then return end
  for _, pad in ipairs(d.pads) do
    if p.rx >= pad.x and p.rx < pad.x + 3 and p.ry >= pad.y and p.ry < pad.y + 3 then
      local dest = arrival(site, pad.dest)
      d.cool[p.player.index] = game.tick + 45
      K.effect(site, "spark-explosion", p.pos)
      p.player.teleport(dest)
      K.effect(site, "spark-explosion", dest)
      if pad.dest > 0 and d.platforms[pad.dest].kind == "pit" then
        p.player.print({ "pd-legendary-gates.pit" }, { color = { 1, 0.4, 0.3 } })
      end
      return
    end
  end
end

-- The lake gives way: a stone path from the treasury to the shore.
function KIND.solved(site, K)
  local tiles = {}
  for y = -38, 38 do
    for x = -1, 1 do tiles[#tiles + 1] = { name = "stone-path", position = { site.x + x, site.y + y } } end
  end
  K.surface(site).set_tiles(tiles, true, true, true, false)
  K.say(site, { "pd-legendary-gates.bridge" })
end

function KIND.tick(site, ctx, K)
  local d = site.data
  d.next_drift = d.next_drift or ctx.tick + K.ticks(180)
  if ctx.tick < d.next_drift then return end
  d.next_drift = ctx.tick + K.ticks(180)
  for _ = 1, 10 do
    local a, b = math.random(#d.pads), math.random(#d.pads)
    local pa, pb = d.pads[a], d.pads[b]
    if a ~= b and d.platforms[pa.from].kind ~= "pit" and d.platforms[pb.from].kind ~= "pit" then
      pa.dest, pb.dest = pb.dest, pa.dest
      if solvable(d) then
        K.say(site, { "pd-legendary-gates.drift", pa.letter, pb.letter })
        for _, pad in ipairs({ pa, pb }) do
          K.circle(site, K.abs(site, pad.x + 1.5, pad.y + 1.5), 2, { 0.5, 0.7, 1, 0.5 }, 120, true)
        end
        return
      end
      pa.dest, pb.dest = pb.dest, pa.dest
    end
  end
end

return KIND
