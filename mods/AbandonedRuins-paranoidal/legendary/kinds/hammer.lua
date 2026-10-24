-- The Citadel of the Hammer: four siege mortars on the citadel shell everything that moves on the
-- killing field. Before each salvo the landing spots glow red. Bunkers along the trenches give
-- cover: nobody is targeted inside them. Reach each mortar and spike it with its lever; when all
-- four are silent the gate opens and the garrison makes its last stand.
local C = require("legendary.config")

local KIND = { name = "hammer", tier = "citadel", size = 160, weight = 1, relic = "pd-relic-hammer" }

local KEEP = { -20, -78, 19, -52 }
local MORTARS = { { -28, -60 }, { 25, -60 }, { -28, -44 }, { 25, -44 } }
local SALVO = 7

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "dirt-4", "dirt-5", "dirt-6", "dirt-7" }) end, -80, -80, 79, 79)
  -- the keep
  plan:fill("stone-path", KEEP[1], KEEP[2], KEEP[3], KEEP[4])
  plan:wall_ring(KEEP[1], KEEP[2], KEEP[3], KEEP[4], { { -1, KEEP[4] }, { 0, KEEP[4] }, { 1, KEEP[4] } })
  for x = -1, 1 do plan:put(C.WALL, x, KEEP[4], { force = "legend", invincible = true, locked = true, list = "gate" }) end
  plan:fill("refined-concrete", -6, -74, 5, -66)
  plan:vault(-2, -71)
  plan:vault(1, -71)
  -- mortars and their spike levers
  for i, m in ipairs(MORTARS) do
    plan:fill("concrete", m[1] - 2, m[2] - 2, m[1] + 4, m[2] + 4)
    plan:put("artillery-turret", m[1], m[2], { force = "legend", invincible = true, locked = true, sealed = true, key = "mortar-" .. i })
    plan:lever("spike-" .. i, m[1] + 4, m[2] + 1)
  end
  -- trenches (zig-zag wall runs) and bunkers
  d.bunkers = {}
  for row = 0, 5 do
    local y = 70 - row * 20
    local x = (row % 2 == 0) and rng.next(-60, -20) or rng.next(10, 50)
    for t = 0, 18 do plan:wall(x + t, y) end
    for t = 1, 6 do plan:wall(x, y - t) end
    -- bunkers: 5 x 5 rooms with a door to the south
    for _, bx in ipairs({ rng.next(-70, -40), rng.next(-25, 15), rng.next(35, 65) }) do
      local by = y - 10
      if plan:free(bx - 3, by - 3, 7, 7) then
        plan:wall_ring(bx - 2, by - 2, bx + 2, by + 2, { { bx, by + 2 } })
        plan:fill("rough-stone-path", bx - 1, by - 1, bx + 1, by + 1)
        d.bunkers[#d.bunkers + 1] = { bx - 1, by - 1, bx + 1, by + 1 }
      end
    end
  end
  -- decorations last: they take tiles
  plan:sprinkle({ "huge-scorchmark", "big-scorchmark", "medium-scorchmark" }, 140)
  d.spiked = {}
end

function KIND.built(site, K)
  K.text(site, K.abs(site, 0.5, 77), { "pd-legendary-hammer.sign" }, { 1, 0.6, 0.3 }, 1.6, nil, true)
  for _, b in ipairs(site.data.bunkers) do
    rendering.draw_rectangle({ surface = site.surface, left_top = K.abs(site, b[1] - 1, b[2] - 1), right_bottom = K.abs(site, b[3] + 2, b[4] + 2),
      color = { 0, 0, 0, 0.35 }, filled = true })
  end
end

local function in_bunker(d, rx, ry)
  for _, b in ipairs(d.bunkers) do
    if rx >= b[1] and rx < b[3] + 1 and ry >= b[2] and ry < b[4] + 1 then return true end
  end
  return false
end

function KIND.tick(site, ctx, K)
  local d = site.data
  -- impacts
  for i = #(d.shells or {}), 1, -1 do
    local s = d.shells[i]
    if ctx.tick >= s.at then
      table.remove(d.shells, i)
      K.explode(site, s.pos, 3.5, 180, "big-artillery-explosion")
    end
  end
  if d.gate_open then
    -- the garrison
    if not d.garrison then
      d.garrison = true
      for n = 1, 8 do
        local name = n <= 2 and "bm_fake_human_rocket_4" or "bm_fake_human_pistol_gunner_4"
        local u = K.spawn(site, name, K.abs(site, math.random(-12, 12), -60), C.boss_tier(4))
          or K.spawn(site, "big-biter", K.abs(site, 0, -60), C.boss_tier(6))
        if u then
          site.lists = site.lists or {}
          site.lists.guardian = site.lists.guardian or {}
          table.insert(site.lists.guardian, u)
        end
      end
    end
    return
  end
  d.next_salvo = d.next_salvo or ctx.tick + K.ticks(SALVO)
  if ctx.tick < d.next_salvo then return end
  d.next_salvo = ctx.tick + K.ticks(SALVO)
  d.last = d.last or {}
  local targets = {}
  for _, p in ipairs(ctx.players) do
    if p.inside and not in_bunker(d, p.rx, p.ry) and p.ry > KEEP[4] - 30 then targets[#targets + 1] = p end
  end
  for i, m in ipairs(MORTARS) do
    if not d.spiked[i] and #targets > 0 then
      local p = targets[math.random(#targets)]
      local last = d.last[p.player.index] or p.pos
      local lead = { x = p.pos.x + (p.pos.x - last.x) * 0.6, y = p.pos.y + (p.pos.y - last.y) * 0.6 }
      for n = 1, 2 do
        local at = { x = lead.x + math.random(-30, 30) / 10, y = lead.y + math.random(-30, 30) / 10 }
        K.circle(site, at, 3.5, { 1, 0.15, 0.1, 0.35 }, 110, true)
        d.shells = d.shells or {}
        d.shells[#d.shells + 1] = { at = ctx.tick + 110 + n * 8, pos = at }
      end
      local mortar = K.get(site, "mortar-" .. i)
      if mortar then K.effect(site, "explosion-gunshot", mortar.position) end
    end
  end
  for _, p in ipairs(ctx.players) do d.last[p.player.index] = { x = p.pos.x, y = p.pos.y } end
end

function KIND.lever(site, key, player, entity, K)
  local i = tonumber(key:match("^spike%-(%d)$"))
  local d = site.data
  if not i or d.spiked[i] then return end
  d.spiked[i] = true
  local n = 0
  for _ in pairs(d.spiked) do n = n + 1 end
  local mortar = K.get(site, "mortar-" .. i)
  if mortar then K.effect(site, "big-explosion", mortar.position) end
  K.say(site, { "pd-legendary-hammer.spiked", n, #MORTARS })
  if n >= #MORTARS then
    d.gate_open = true
    K.destroy_list(site, "gate")
    K.say(site, { "pd-legendary-hammer.gate" })
  end
end

function KIND.step(site, p, K)
  local d = site.data
  if d.gate_open and p.rx >= -6 and p.rx < 6 and p.ry >= -74 and p.ry < -65 then K.solve(site, p.player) end
end

return KIND
