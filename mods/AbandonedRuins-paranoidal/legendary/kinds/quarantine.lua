-- The Plague Quarantine: a sealed research station overgrown with spore pods. Inside, an infection
-- meter grows (much faster in spore clouds); a full meter poisons and slows. Decontamination
-- showers reset it and recharge in twenty seconds. Take three samples from the infected labs - each
-- releases a spore burst and the infected - and the central lab opens.
local C = require("legendary.config")

local KIND = { name = "quarantine", tier = "citadel", size = 96, weight = 1, relic = "pd-relic-healing-spring" }

local LABS = { { -32, -32 }, { 31, -32 }, { -32, 31 } }
local SHOWERS = { { -4, 38 }, { -20, 0 }, { 19, 0 }, { 0, -22 } }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x + 2 * y) % 7 == 0) and "acid-refined-concrete" or "concrete" end, -48, -48, 47, 47)
  plan:fill("hazard-concrete-left", -48, 44, 47, 47)
  plan:wall_ring(-46, -46, 45, 45, { { -1, 45 }, { 0, 45 } })
  -- central lab
  plan:fill("lab-white", -8, -8, 7, 7)
  plan:wall_ring(-9, -9, 8, 8, { { -1, 8 }, { 0, 8 } })
  for x = -1, 0 do plan:put(C.WALL, x, 8, { force = "legend", invincible = true, locked = true, list = "door" }) end
  plan:vault(-3, -3)
  plan:vault(2, -3)
  -- infected labs with samples
  for i, l in ipairs(LABS) do
    plan:fill("green-refined-concrete", l[1] - 6, l[2] - 6, l[1] + 6, l[2] + 6)
    plan:wall_ring(l[1] - 7, l[2] - 7, l[1] + 7, l[2] + 7, { { l[1], l[2] + (l[2] < 0 and 7 or -7) }, { l[1] + 1, l[2] + (l[2] < 0 and 7 or -7) } })
    plan:put("lab", l[1] - 4, l[2] - 4, { force = "neutral", invincible = true, locked = true, sealed = true })
    plan:lever("sample-" .. i, l[1] + 2, l[2] + 1)
  end
  for i, s in ipairs(SHOWERS) do plan:lever("shower-" .. i, s[1], s[2]) end
  -- spore pods
  d.pods = {}
  for _ = 1, 22 do
    local x, y = rng.next(-42, 40), rng.next(-42, 40)
    if plan:put("bob-hardened-bile", x, y, { force = "neutral", invincible = true, locked = true }) or
       plan:put("big-sand-rock", x, y, { force = "neutral", invincible = true, locked = true }) then
      d.pods[#d.pods + 1] = { x + 1, y + 1 }
    end
  end
  d.meter, d.samples, d.taken = {}, 0, {}
end

function KIND.built(site, K)
  for _, s in ipairs(SHOWERS) do
    K.text(site, K.abs(site, s[1] + 0.5, s[2] - 1.5), { "pd-legendary-quarantine.shower-label" }, { 0.5, 0.9, 1 }, 1, nil, true)
  end
  for _, pod in ipairs(site.data.pods) do K.light(site, K.abs(site, pod[1], pod[2]), 0.7, { 0.4, 1, 0.2 }, true) end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  -- spores
  if ctx.tick % 180 < 6 and #d.pods > 0 then
    for _ = 1, 3 do
      local pod = d.pods[math.random(#d.pods)]
      K.cloud(site, K.abs(site, pod[1] + math.random(-3, 3), pod[2] + math.random(-3, 3)))
    end
  end
  for _, p in ipairs(ctx.players) do
    local id = p.player.index
    local m = d.meter[id] or 0
    if p.inside then
      local gain = 0.15
      for _, pod in ipairs(d.pods) do
        if (p.rx - pod[1]) ^ 2 + (p.ry - pod[2]) ^ 2 < 36 then gain = 1 break end
      end
      m = math.min(100, m + gain)
    else
      m = math.max(0, m - 1)
    end
    d.meter[id] = m
    if m >= 100 then
      K.damage(p.char, 1.5, "poison")
      K.stick(site, p.char, "slowdown-sticker")
    end
    if p.inside then
      local n = math.floor(m / 10 + 0.5)
      rendering.draw_text({ text = { "pd-legendary-quarantine.meter", string.rep("|", n) .. string.rep(".", 10 - n) },
        surface = site.surface, target = { entity = p.char, offset = { 0, -2.6 } }, players = { p.player },
        color = m >= 100 and { 1, 0.2, 0.2 } or { 0.5, 1, 0.3 }, scale = 1.1, alignment = "center", time_to_live = 7 })
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  local d = site.data
  local s = tonumber(key:match("^shower%-(%d)$"))
  if s then
    local pos = entity.position
    for _, p in ipairs(K.players(site, 0)) do
      if (p.pos.x - pos.x) ^ 2 + (p.pos.y - pos.y) ^ 2 < 25 then
        d.meter[p.player.index] = 0
        p.player.print({ "pd-legendary-quarantine.clean" }, { color = { 0.5, 0.9, 1 } })
      end
    end
    K.effect(site, "water-splash", pos)
    K.relever(site, key, SHOWERS[s][1] + 0.5, SHOWERS[s][2] + 0.5, K.ticks(20))
    return
  end
  local i = tonumber(key:match("^sample%-(%d)$"))
  if not i or d.taken[i] then return end
  d.taken[i] = true
  d.samples = d.samples + 1
  local l = LABS[i]
  for _ = 1, 6 do K.cloud(site, K.abs(site, l[1] + math.random(-5, 5), l[2] + math.random(-5, 5))) end
  for _ = 1, 4 do
    local z = K.spawn(site, "bm_fake_human_melee_3", K.abs(site, l[1] + math.random(-5, 5), l[2] + math.random(-5, 5)), C.boss_tier(4))
      or K.spawn(site, "big-biter", K.abs(site, l[1], l[2]), C.boss_tier(4))
    if z then
      site.lists = site.lists or {}
      site.lists.guardian = site.lists.guardian or {}
      table.insert(site.lists.guardian, z)
      if player and player.character then K.attack(z, player.character) end
    end
  end
  K.say(site, { "pd-legendary-quarantine.sample", d.samples, #LABS })
  if d.samples >= #LABS then
    K.destroy_list(site, "door")
    K.say(site, { "pd-legendary-quarantine.open" })
    d.open = true
  end
end

function KIND.step(site, p, K)
  if site.data.open and p.rx > -8 and p.rx < 8 and p.ry > -8 and p.ry < 8 then K.solve(site, p.player) end
end

return KIND
