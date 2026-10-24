-- The Dune: a sea of sand around a rock sietch. Every step makes the sand tremble: the vibration
-- meter grows while you move (three times faster in a vehicle), and falls while you stand still.
-- When it is full, the ground rumbles and Shai-Hulud bursts out where you stood. Thumpers draw the
-- worm away for half a minute. In the heart of the sietch lie the reward and, once it is taken,
-- an endless vein of ore.
local C = require("legendary.config")

local KIND = { name = "dune", tier = "trial", size = 160, weight = 1, relic = "pd-relic-deep-drill" }

local SIETCH = 12
local THUMPERS = { { -50, 40 }, { 45, 45 }, { -55, -35 }, { 50, -40 }, { 0, 60 } }
local VEIN = { "infinite-angels-ore1", "infinite-angels-ore3", "infinite-angels-ore5", "infinite-angels-ore6", "infinite-coal" }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "sand-1", "sand-2", "sand-3", "sand-2" }) end, -80, -80, 79, 79)
  for _ = 1, 26 do plan:disc("red-desert-1", rng.next(-70, 70), rng.next(-70, 70), rng.next(3, 9), 0.7) end
  plan:scatter({ "big-sand-rock", "big-sand-rock", "huge-rock" }, 70, { force = "neutral" }, { -78, -78, 77, 77 })
  -- the sietch: a ring of huge rocks with one gap, a stone floor and the reward
  plan:disc("rough-stone-path", 0, 0, SIETCH + 2)
  for i = 0, 35 do
    local a = i * math.pi / 18
    if not (a > 1.2 and a < 1.9) then
      plan:put("huge-rock", math.floor(math.cos(a) * SIETCH) - 1, math.floor(math.sin(a) * SIETCH) - 1,
        { force = "neutral", invincible = true, locked = true })
    end
  end
  plan:fill("lab-dark-1", -3, -3, 2, 2)
  plan:vault(-2, -1)
  plan:vault(1, -1)
  d.thumpers = {}
  for i, t in ipairs(THUMPERS) do
    plan:lever("thumper-" .. i, t[1], t[2])
    d.thumpers[i] = { x = t[1] + 0.5, y = t[2] + 0.5, used = false }
  end
  -- decorations last: they take tiles
  plan:sprinkle({ "big-biter-corpse", "medium-biter-corpse", "behemoth-biter-corpse" }, 60)
  d.meter = {}
end

function KIND.built(site, K)
  K.text(site, K.abs(site, 0, 79), { "pd-legendary-dune.sign" }, { 1, 0.85, 0.5 }, 1.6, nil, true)
end

local function bar(v)
  local n = math.floor(v / 10 + 0.5)
  return string.rep("|", n) .. string.rep(".", 10 - n)
end

local function strike(site, ctx, K, pos)
  K.explode(site, pos, 4.5, 170, "big-explosion")
  for _ = 1, 6 do
    K.effect(site, "explosion-hit", { x = pos.x + math.random(-3, 3), y = pos.y + math.random(-3, 3) })
  end
  local worm = K.spawn(site, "big-worm-turret", pos, C.boss_tier(6))
  if worm then
    worm.destructible = false
    site.data.worms = site.data.worms or {}
    table.insert(site.data.worms, { entity = worm, until_tick = ctx.tick + K.ticks(4) })
  end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  d.last = d.last or {}
  -- worms sink back into the sand
  for i = #(d.worms or {}), 1, -1 do
    local w = d.worms[i]
    if not w.entity.valid or ctx.tick >= w.until_tick then
      if w.entity.valid then w.entity.destroy() end
      table.remove(d.worms, i)
    end
  end
  -- pending strikes
  for i = #(d.strikes or {}), 1, -1 do
    local s = d.strikes[i]
    if ctx.tick >= s.at then
      table.remove(d.strikes, i)
      strike(site, ctx, K, s.pos)
    end
  end
  local lure = d.lure_until and ctx.tick < d.lure_until
  for _, p in ipairs(ctx.players) do
    local id = p.player.index
    local last = d.last[id]
    local moved = last and math.sqrt((p.pos.x - last.x) ^ 2 + (p.pos.y - last.y) ^ 2) or 0
    d.last[id] = { x = p.pos.x, y = p.pos.y }
    local in_sand = p.inside and (p.rx * p.rx + p.ry * p.ry) > (SIETCH + 1) ^ 2
    local m = d.meter[id] or 0
    if in_sand and not lure then
      local gain = moved * 1.5
      if p.vehicle then gain = gain * 3 end
      if p.player.shooting_state and p.player.shooting_state.state ~= defines.shooting.not_shooting then gain = gain + 2 end
      if moved < 0.05 then gain = -4 end
      m = math.max(0, math.min(100, m + gain))
    else
      m = math.max(0, m - 6)
    end
    if m >= 100 then
      m = 35
      p.player.print({ "pd-legendary-dune.rumble" }, { color = { 1, 0.6, 0.2 } })
      K.feat(site, "dune-dinner", p.player)
      K.circle(site, p.pos, 4.5, { 0.9, 0.6, 0.2, 0.35 }, 75, true)
      d.strikes = d.strikes or {}
      table.insert(d.strikes, { at = ctx.tick + 75, pos = { x = p.pos.x, y = p.pos.y } })
    end
    d.meter[id] = m
    if in_sand then
      local color = m > 75 and { 1, 0.3, 0.2 } or (m > 45 and { 1, 0.8, 0.3 } or { 0.8, 0.9, 1 })
      rendering.draw_text({ text = { "pd-legendary-dune.meter", bar(m) }, surface = site.surface,
        target = { entity = p.char, offset = { 0, -2.6 } }, color = color, scale = 1.1, alignment = "center",
        time_to_live = 7, players = { p.player } })
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  local i = tonumber(key:match("^thumper%-(%d)$"))
  local d = site.data
  local t = i and d.thumpers[i]
  if not t or t.used then return end
  t.used = true
  d.lure_until = game.tick + K.ticks(30)
  K.say(site, { "pd-legendary-dune.thumper", math.floor(K.ticks(30) / 60) })
  local pos = K.abs(site, t.x, t.y + 3)
  d.strikes = d.strikes or {}
  table.insert(d.strikes, { at = game.tick + 120, pos = pos })
  K.circle(site, pos, 4.5, { 0.9, 0.6, 0.2, 0.35 }, 120, true)
end

function KIND.step(site, p, K)
  if p.rx > -3 and p.rx < 3 and p.ry > -3 and p.ry < 3 then K.solve(site, p.player) end
end

-- After the victory the sietch floor becomes an endless vein; the sanctuary rules are gone, so an
-- outpost can be built around it.
function KIND.solved(site, K)
  local surface = K.surface(site)
  if not surface then return end
  local k = 0
  for x = -8, 7 do
    for y = 4, 11 do
      k = k + 1
      local name = VEIN[(k % #VEIN) + 1]
      if prototypes.entity[name] then
        surface.create_entity({ name = name, position = { site.x + x + 0.5, site.y + y + 0.5 }, amount = 600000,
          enable_tree_removal = false, snap_to_tile_center = true })
      end
    end
  end
  K.say(site, { "pd-legendary-dune.vein" })
end

return KIND
