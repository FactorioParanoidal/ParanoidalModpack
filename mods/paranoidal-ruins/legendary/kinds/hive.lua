-- The Hive of the Queen: a colony grown around a monstrous brood mother. Six egg clutches feed her:
-- while any of them lives, the Queen heals almost as fast as she is hurt. The clutches hatch broods,
-- worms guard the approaches and the Queen spits acid. Kill the Queen and the whole hive dies.
local C = require("legendary.config")

local KIND = { name = "hive", tier = "citadel", size = 160, weight = 1, relic = "pd-relic-xeno-incubator" }

local BROOD = { "medium-biter", "big-biter", "big-spitter", "medium-spitter" }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "red-desert-2", "red-desert-3", "dirt-7", "red-desert-2" }) end, -80, -80, 79, 79)
  for _ = 1, 30 do plan:disc("dirt-6", rng.next(-70, 70), rng.next(-70, 70), rng.next(3, 8), 0.8) end
  plan:put("biter-spawner", -3, -3, { force = "legend", key = "queen", quality = C.boss_tier(16) })
  d.eggs = {}
  for i = 0, 5 do
    local a = i * math.pi / 3 + 0.3
    local x, y = math.floor(math.cos(a) * 22) - 2, math.floor(math.sin(a) * 22) - 2
    plan:put(i % 2 == 0 and "spitter-spawner" or "biter-spawner", x, y, { force = "legend", list = "egg", quality = C.boss_tier(8) })
    d.eggs[#d.eggs + 1] = { x + 2, y + 2 }
  end
  for i = 0, 13 do
    local a = i * math.pi / 7 + rng.next() * 0.3
    local r = rng.next(34, 62)
    plan:put(r > 50 and "big-worm-turret" or "medium-worm-turret", math.floor(math.cos(a) * r) - 1, math.floor(math.sin(a) * r) - 1,
      { force = "legend", list = "worm", quality = C.boss_tier(5) })
  end
  for i = 0, 5 do
    local a = i * math.pi / 3 + 0.8
    local r = rng.next(52, 70)
    plan:put("biter-spawner", math.floor(math.cos(a) * r) - 3, math.floor(math.sin(a) * r) - 3, { force = "legend", list = "nest", quality = C.boss_tier(4) })
  end
  plan:vault(-2, 8)
  plan:vault(1, 8)
  -- decorations last: they take tiles
  plan:sprinkle({ "big-biter-corpse", "medium-spitter-corpse", "big-spitter-corpse", "medium-biter-corpse" }, 90)
end

function KIND.built(site, K)
  local queen = K.get(site, "queen")
  if queen then
    K.watch(site, queen, "queen")
    rendering.draw_text({ text = { "pd-legendary-hive.queen" }, surface = site.surface, target = { entity = queen, offset = { 0, -3.5 } },
      color = { 0.8, 1, 0.3 }, scale = 1.6, alignment = "center" })
  end
end

local function nearest(ctx, pos, radius)
  local best, bd
  for _, p in ipairs(ctx.players) do
    local dd = (p.pos.x - pos.x) ^ 2 + (p.pos.y - pos.y) ^ 2
    if dd < radius * radius and (not bd or dd < bd) then best, bd = p, dd end
  end
  return best
end

function KIND.tick(site, ctx, K)
  local d = site.data
  local queen = K.get(site, "queen")
  if not queen then return end
  local eggs = K.list(site, "egg")
  -- the clutches feed the Queen
  if ctx.tick % 60 < 6 and #eggs > 0 then
    queen.health = math.min(queen.max_health, queen.health + queen.max_health * 0.015 * #eggs)
    for _, egg in ipairs(eggs) do
      K.line(site, egg.position, queen.position, { 0.5, 1, 0.3, 0.5 }, 50, 3)
    end
  end
  -- broods
  d.next_brood = d.next_brood or 0
  if ctx.tick >= d.next_brood then
    d.next_brood = ctx.tick + K.ticks(15)
    local brood = K.list(site, "brood")
    for _, egg in ipairs(eggs) do
      local target = nearest(ctx, egg.position, 70)
      if target and #brood < 40 then
        for _ = 1, 2 do
          local unit = K.spawn(site, BROOD[math.random(#BROOD)], egg.position, C.boss_tier(2))
          if unit then
            site.lists = site.lists or {}
            site.lists.brood = site.lists.brood or {}
            table.insert(site.lists.brood, unit)
            K.attack(unit, target.char)
            brood[#brood + 1] = unit
          end
        end
      end
    end
  end
  -- acid volleys of the Queen
  d.next_acid = d.next_acid or 0
  if ctx.tick >= d.next_acid then
    d.next_acid = ctx.tick + K.ticks(8)
    for _, p in ipairs(ctx.players) do
      local dist = math.sqrt((p.pos.x - queen.position.x) ^ 2 + (p.pos.y - queen.position.y) ^ 2)
      if dist < 40 then
        local at = { x = p.pos.x + math.random(-2, 2), y = p.pos.y + math.random(-2, 2) }
        K.circle(site, at, 3, { 0.6, 1, 0.2, 0.4 }, 60, true)
        d.acid = d.acid or {}
        d.acid[#d.acid + 1] = { at = ctx.tick + 60, pos = at }
      end
    end
  end
  for i = #(d.acid or {}), 1, -1 do
    local a = d.acid[i]
    if ctx.tick >= a.at then
      table.remove(d.acid, i)
      K.effect(site, "acid-splash-fire-worm-big", a.pos)
      K.hurt(site, a.pos, 3, 70, "acid")
    end
  end
end

function KIND.destroyed(site, tag, _, K)
  if tag ~= "queen" then return end
  for _, list in ipairs({ "egg", "worm", "nest", "brood" }) do
    for _, e in ipairs(K.list(site, list)) do e.die() end
  end
  K.say(site, { "pd-legendary-hive.dead" })
  K.solve(site, nil)
end

return KIND
