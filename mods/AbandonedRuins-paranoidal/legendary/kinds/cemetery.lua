-- The Cemetery of the First Colonists: rows of graves around the founder's crypt. Every grave is a
-- lottery - good gear of high quality, nothing, or the restless dead. Each dug grave raises the
-- wrath of the cemetery; at twenty a swarm of the dead rises and the graves close. The Founder sleeps
-- in the crypt: dig his grave and defeat him for the cemetery's own relic.
local C = require("legendary.config")
local loot = require("legendary.loot")

local KIND = { name = "cemetery", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-funeral-bell" }

local WRATH_MAX = 20
local DEAD = { "bm_fake_human_melee_3", "bm_fake_human_melee_4", "bm_fake_human_pistol_gunner_3" }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "grass-3", "grass-4", "dirt-4", "grass-3" }) end, -64, -64, 63, 63)
  plan:wall_ring(-62, -62, 61, 61, { { -1, 61 }, { 0, 61 }, { 1, 61 } })
  plan:fill("stone-path", -2, -60, 1, 60)
  plan:fill("stone-path", -60, -2, 59, 1)
  -- the founder's crypt
  plan:fill("lab-dark-1", -9, -9, 8, 8)
  plan:wall_ring(-10, -10, 9, 9, { { -1, 9 }, { 0, 9 }, { 1, 9 } })
  plan:lever("founder", -1, -4)
  plan:vault(-6, -7)
  plan:vault(5, -7)
  -- graves in four fields
  d.graves = {}
  for _, field in ipairs({ { -56, -56 }, { 8, -56 }, { -56, 8 }, { 8, 8 } }) do
    for row = 0, 5 do
      for col = 0, 5 do
        local gx, gy = field[1] + col * 8 + 2, field[2] + row * 8 + 2
        local r = rng.next()
        local fate = r < 0.4 and "treasure" or (r < 0.6 and "empty" or "dead")
        plan:fill("dirt-6", gx - 1, gy + 1, gx + 1, gy + 3)
        plan:lever("grave-" .. #d.graves + 1, gx, gy)
        d.graves[#d.graves + 1] = { x = gx, y = gy, fate = fate }
      end
    end
  end
  plan:sprinkle({ "dead-grey-trunk", "dead-tree-desert", "dry-tree" }, 40, { force = "neutral" })
  d.wrath = 0
end

function KIND.built(site, K)
  K.text(site, K.abs(site, 0.5, 58), { "pd-legendary-cemetery.sign" }, { 0.8, 0.8, 0.9 }, 1.5, nil, true)
  K.light(site, K.abs(site, 0, -4), 2, { 0.5, 0.6, 1 }, true)
end

local function rise(site, K, pos, count, target, tier)
  for _ = 1, count do
    local at = { x = pos.x + math.random(-4, 4), y = pos.y + math.random(-4, 4) }
    local u = K.spawn(site, DEAD[math.random(#DEAD)], at, C.boss_tier(tier)) or K.spawn(site, "big-biter", at, C.boss_tier(tier))
    if u then
      site.lists = site.lists or {}
      site.lists.guardian = site.lists.guardian or {}
      table.insert(site.lists.guardian, u)
      if target then K.attack(u, target) end
    end
  end
end

local function wake_founder(site, K, player)
  local d = site.data
  if d.founder then return end
  d.founder = true
  local boss = K.spawn(site, "bm_fake_human_melee_8", K.abs(site, 0, -2), C.boss_tier(8))
    or K.spawn(site, "behemoth-biter", K.abs(site, 0, -2), C.boss_tier(1))
  if boss then
    site.lists = site.lists or {}
    site.lists.guardian = site.lists.guardian or {}
    table.insert(site.lists.guardian, boss)
    K.watch(site, boss, "founder")
    rendering.draw_text({ text = { "pd-legendary-cemetery.founder" }, surface = site.surface, target = { entity = boss, offset = { 0, -2.5 } },
      color = { 0.6, 0.7, 1 }, scale = 1.5, alignment = "center" })
    if player and player.character then K.attack(boss, player.character) end
  end
  rise(site, K, K.abs(site, 0, 0), 8, player and player.character, 5)
  K.say(site, { "pd-legendary-cemetery.founder-wakes" })
end

function KIND.lever(site, key, player, entity, K)
  local d = site.data
  if key == "founder" then
    wake_founder(site, K, player)
    return
  end
  local i = tonumber(key:match("^grave%-(%d+)$"))
  local g = i and d.graves[i]
  if not g or g.dug then return end
  g.dug = true
  local pos = K.abs(site, g.x + 0.5, g.y + 0.5)
  d.wrath = d.wrath + (g.fate == "dead" and 2 or 1)
  if g.fate == "treasure" then
    local surface = K.surface(site)
    local chest = surface.create_entity({ name = "crash-site-chest-1", position = { pos.x, pos.y + 2 }, force = "neutral" })
    if chest then
      local pool = loot.pools.citadel
      for _ = 1, 2 do
        local e = pool[math.random(#pool)]
        if prototypes.item[e[1]] then
          chest.insert({ name = e[1], count = math.random(e[2], e[3]), quality = C.tier(loot.roll_tier(7, 10)) })
        end
      end
    end
    K.float(site, pos, { "pd-legendary-cemetery.treasure" }, { 1, 0.85, 0.3 })
  elseif g.fate == "dead" then
    K.cloud(site, pos)
    rise(site, K, pos, math.random(2, 4), player and player.character, 3 + math.floor(d.wrath / 5))
    K.float(site, pos, { "pd-legendary-cemetery.dead" }, { 0.7, 0.7, 1 })
  else
    K.float(site, pos, { "pd-legendary-cemetery.empty" }, { 0.8, 0.8, 0.8 })
  end
  K.say(site, { "pd-legendary-cemetery.wrath", d.wrath, WRATH_MAX })
  if d.wrath >= WRATH_MAX and not d.swarm then
    d.swarm = true
    K.say(site, { "pd-legendary-cemetery.swarm" })
    K.feat(site, "cemetery-gravedigger", player)
    rise(site, K, player and player.position or pos, 16, player and player.character, 6)
    for n, grave in ipairs(d.graves) do
      local lever = K.get(site, "grave-" .. n)
      if lever then lever.minable_flag = false end
      grave.dug = true
    end
    wake_founder(site, K, player)
  end
end

function KIND.destroyed(site, tag, _, K)
  if tag == "founder" then
    K.say(site, { "pd-legendary-cemetery.founder-dead" })
    K.solve(site, nil)
  end
end

return KIND
