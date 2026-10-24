-- Reactor "Half-Life": the old reactor wakes when someone walks in, and a countdown starts. Three
-- coolant pumps are broken: bring 20 repair packs into each pump's service hatch and pull its
-- lever. Radiation grows towards the core; mutants crawl out of the wreckage. If time runs out the
-- reactor goes up in a nuclear blast and takes the reward with it.
local C = require("legendary.config")

local KIND = { name = "reactor", tier = "citadel", size = 96, weight = 1, relic = "pd-relic-heart-of-reactor" }

local PUMPS = { { -36, -36 }, { 35, -36 }, { -1, 38 } }
local NEED = 20

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x * y) % 13 == 0) and "nuclear-ground" or "concrete" end, -48, -48, 47, 47)
  plan:disc("nuclear-ground", 0, 0, 18, 0.7)
  plan:wall_ring(-46, -46, 45, 45, { { -1, 45 }, { 0, 45 }, { -46, -1 }, { -46, 0 } })
  plan:put("nuclear-reactor", -3, -3, { force = "legend", key = "core", invincible = true, locked = true, sealed = true })
  d.pumps = {}
  for i, p in ipairs(PUMPS) do
    plan:fill("hazard-concrete-left", p[1] - 3, p[2] - 3, p[1] + 3, p[2] + 3)
    plan:put("storage-tank", p[1] - 1, p[2] - 1, { force = "legend", invincible = true, locked = true, sealed = true })
    plan:put("steel-chest", p[1] + 2, p[2] + 2, { force = "neutral", key = "hatch-" .. i, invincible = true, locked = true })
    plan:lever("pump-" .. i, p[1] - 3, p[2] + 2)
    d.pumps[i] = false
  end
  plan:scatter({ "crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2", "crash-site-spaceship-wreck-medium-3" },
    14, { force = "neutral", invincible = true, locked = true, sealed = true }, { -40, -40, 39, 39 })
  plan:fill("refined-concrete", -44, -10, -38, 9)
  plan:vault(-42, -2)
  plan:vault(-42, 1)
  -- decorations last: they take tiles
  plan:sprinkle({ "big-scorchmark", "medium-scorchmark" }, 30)
end

function KIND.built(site, K)
  for i, p in ipairs(PUMPS) do
    K.text(site, K.abs(site, p[1] + 0.5, p[2] - 3.5), { "pd-legendary-reactor.pump", i, NEED }, { 0.6, 0.9, 1 }, 1.1, nil, true)
  end
  K.light(site, K.abs(site, 0, 0), 4, { 0.3, 1, 0.3 }, true)
end

local function count(inv, name)
  local n = 0
  for _, c in pairs(inv.get_contents()) do if c.name == name then n = n + c.count end end
  return n
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if not d.deadline then
    for _, p in ipairs(ctx.players) do
      if p.inside then
        d.deadline = ctx.tick + K.ticks(600)
        K.say(site, { "pd-legendary-reactor.wake", math.floor(K.ticks(600) / 3600) })
        K.sound(site, "utility/alert_destroyed", p.pos)
        break
      end
    end
    return
  end
  local left = d.deadline - ctx.tick
  if ctx.tick % 60 < 6 then
    K.text(site, K.abs(site, 0, -5), { "pd-legendary-reactor.timer", K.clock(left) }, left < 3600 and { 1, 0.2, 0.2 } or { 1, 0.8, 0.2 }, 2, 61)
  end
  -- radiation
  for _, p in ipairs(ctx.players) do
    if p.inside then
      local dist = math.sqrt(p.rx * p.rx + p.ry * p.ry)
      K.damage(p.char, 0.25 + 2.2 * math.max(0, 1 - dist / 46), "poison")
    end
  end
  -- mutants
  d.next_mutants = d.next_mutants or ctx.tick + K.ticks(40)
  if ctx.tick >= d.next_mutants then
    d.next_mutants = ctx.tick + K.ticks(40)
    if #K.list(site, "guardian") < 12 then
      for _ = 1, 3 do
        local unit = K.spawn(site, math.random() < 0.5 and "big-spitter" or "medium-spitter", K.abs(site, math.random(-6, 6), math.random(5, 9)), C.boss_tier(4))
        if unit then
          site.lists = site.lists or {}
          site.lists.guardian = site.lists.guardian or {}
          table.insert(site.lists.guardian, unit)
          local target = ctx.players[math.random(#ctx.players)]
          if target then K.attack(unit, target.char) end
        end
      end
    end
  end
  if left <= 0 then
    local surface = ctx.surface
    if C.ferocity().truce then
      K.effect(site, "nuke-explosion", K.abs(site, 0, 0))
    else
      surface.create_entity({ name = "atomic-rocket", position = K.abs(site, 0, 0), target = K.abs(site, 0, 0), speed = 1, force = C.FORCE })
    end
    K.ruin(site, { "pd-legendary-reactor.meltdown" })
  end
end

function KIND.lever(site, key, player, entity, K)
  local i = tonumber(key:match("^pump%-(%d)$"))
  local d = site.data
  if not i or d.pumps[i] then return end
  local hatch = K.get(site, "hatch-" .. i)
  local inv = hatch and hatch.get_inventory(defines.inventory.chest)
  if not inv or count(inv, "repair-pack") < NEED then
    if player then player.print({ "pd-legendary-reactor.need", NEED }) end
    K.relever(site, key, PUMPS[i][1] - 2.5, PUMPS[i][2] + 2.5)
    return
  end
  local left = NEED
  for _, c in pairs(inv.get_contents()) do
    if c.name == "repair-pack" and left > 0 then
      left = left - inv.remove({ name = "repair-pack", count = math.min(left, c.count), quality = c.quality })
    end
  end
  d.pumps[i] = true
  local running = 0
  for _, v in ipairs(d.pumps) do if v then running = running + 1 end end
  K.say(site, { "pd-legendary-reactor.pump-on", running, #PUMPS })
  K.line(site, K.abs(site, PUMPS[i][1] + 0.5, PUMPS[i][2] + 0.5), K.abs(site, 0, 0), { 0.3, 0.6, 1, 0.8 }, 600, 6)
  if running >= #PUMPS then
    K.say(site, { "pd-legendary-reactor.stable" })
    K.solve(site, player)
  end
end

return KIND
