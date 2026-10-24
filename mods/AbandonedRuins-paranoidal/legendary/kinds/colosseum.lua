-- The Colosseum: step onto the sand and the gate closes behind you. Ten waves of gladiators and
-- beasts. Between waves a lever rises in the centre: take your reward and leave - or fight on for a
-- better one (more stacks, higher quality, the champion's banner from the fifth wave on).
-- Turrets and walls may be built on the sand. Die or leave the arena and the games start over.
local C = require("legendary.config")

local KIND = { name = "colosseum", tier = "citadel", size = 96, weight = 1, relic = "pd-relic-champion-banner" }

local R = 30
local WAVES = {
  { { "bm_fake_human_melee_2", 6 } },
  { { "bm_fake_human_pistol_gunner_2", 4 }, { "bm_fake_human_melee_3", 3 } },
  { { "big-biter", 8 } },
  { { "bm_fake_human_grenade_2", 3 }, { "bm_fake_human_pistol_gunner_3", 4 } },
  { { "bm_fake_human_machine_gunner_2", 2 }, { "bm_fake_human_melee_4", 4 } },
  { { "big-spitter", 8 }, { "big-biter", 6 } },
  { { "bm_fake_human_rocket_3", 3 }, { "bm_fake_human_pistol_gunner_4", 5 } },
  { { "bm_fake_human_flamethrower_3", 3 }, { "bm_fake_human_melee_5", 5 } },
  { { "bm_fake_human_machine_gunner_4", 3 }, { "bm_fake_human_sniper_3", 2 }, { "bm_fake_human_grenade_4", 3 } },
  { { "bm_fake_human_melee_8", 1, "champion" }, { "bm_fake_human_pistol_gunner_5", 4 } },
}
local FALLBACK = { "medium-biter", "big-biter", "big-spitter" }

KIND.allow_build = function(name, type)
  return type == "ammo-turret" or type == "electric-turret" or type == "fluid-turret" or type == "wall"
    or type == "gate" or type == "land-mine" or type == "electric-pole" or type == "accumulator"
    or type == "solar-panel" or type == "container"
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y)
    local r = math.sqrt((x + 0.5) ^ 2 + (y + 0.5) ^ 2)
    if r < R then return rng.chance(0.15) and "sand-2" or "sand-1" end
    if r < R + 3 then return "stone-path" end
    return ((math.floor(r) % 3) == 0) and "rough-stone-path" or "concrete"
  end, -48, -48, 47, 47)
  -- arena wall: a ring of wall tiles at radius R..R+1 with the south gate and the beasts' gate
  for x = -R - 2, R + 1 do
    for y = -R - 2, R + 1 do
      local r = math.sqrt((x + 0.5) ^ 2 + (y + 0.5) ^ 2)
      if r >= R and r < R + 1.5 then
        if y > 0 and x >= -1 and x <= 1 then
          plan:put(C.WALL, x, y, { force = "legend", invincible = true, locked = true, list = "gate-wall" })
        elseif not (y < 0 and x >= -2 and x <= 2) then
          plan:wall(x, y)
        end
      end
    end
  end
  -- the beasts' gate (north) is a closed iron door
  for x = -2, 2 do plan:put("gate", x, -R - 1, { force = "legend", invincible = true, locked = true, loose = true }) end
  -- stands with spectators' torches
  for i = 0, 23 do
    local a = i * math.pi / 12
    plan:put("small-lamp", math.floor(math.cos(a) * (R + 8)), math.floor(math.sin(a) * (R + 8)), { force = "neutral", invincible = true, locked = true })
  end
  plan:fill("refined-concrete", -4, 38, 3, 44)
  plan:vault(-2, 41)
  plan:vault(1, 41)
  d.wave = 0
end

function KIND.built(site, K)
  K.destroy_list(site, "gate-wall")
  K.text(site, K.abs(site, 0.5, 36), { "pd-legendary-colosseum.sign" }, { 1, 0.85, 0.4 }, 1.5, nil, true)
end

local function in_arena(p) return p.rx * p.rx + p.ry * p.ry < (R - 1) ^ 2 end

local function set_gate(site, K, closed)
  if closed then
    for x = -1, 1 do
      for y = R - 1, R + 1 do
        local r = math.sqrt((x + 0.5) ^ 2 + (y + 0.5) ^ 2)
        if r >= R and r < R + 1.5 then
          K.place(site, C.WALL, x + 0.5, y + 0.5, { force = "legend", invincible = true, locked = true, list = "gate-wall" })
        end
      end
    end
  else
    K.destroy_list(site, "gate-wall")
  end
end

local function spawn_wave(site, ctx, K)
  local d = site.data
  local wave = WAVES[d.wave]
  site.lists = site.lists or {}
  site.lists.wave = {}
  local quality = C.boss_tier(1 + math.floor(d.wave / 2))
  for _, group in ipairs(wave) do
    for n = 1, group[2] do
      local pos = K.abs(site, math.random(-8, 8), -R + 4 + math.random(0, 4))
      local name = group[1]
      local q = group[3] == "champion" and C.boss_tier(10) or quality
      local unit = K.spawn(site, name, pos, q) or K.spawn(site, FALLBACK[math.random(#FALLBACK)], pos, q)
      if unit then
        table.insert(site.lists.wave, unit)
        if group[3] == "champion" then
          rendering.draw_text({ text = { "pd-legendary-colosseum.champion" }, surface = site.surface,
            target = { entity = unit, offset = { 0, -2.4 } }, color = { 1, 0.8, 0.2 }, scale = 1.4, alignment = "center" })
        end
        local target = ctx.players[math.random(#ctx.players)]
        if target then K.attack(unit, target.char) end
      end
    end
  end
  K.say(site, { "pd-legendary-colosseum.wave", d.wave, #WAVES })
  K.sound(site, "utility/alert_destroyed", K.abs(site, 0, -R))
end

local function reset(site, K, reason)
  local d = site.data
  for _, u in ipairs(K.list(site, "wave")) do u.destroy() end
  site.lists.wave = nil
  local lever = K.get(site, "cashout")
  if lever then lever.destroy() end
  d.wave, d.fight, d.pause_until, d.next_wave = 0, false, nil, nil
  set_gate(site, K, false)
  K.say(site, reason)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  local inside = {}
  for _, p in ipairs(ctx.players) do if in_arena(p) then inside[#inside + 1] = p end end
  if not d.fight then
    if #inside > 0 then
      d.fight = true
      d.wave = 0
      d.next_wave = ctx.tick + K.ticks(15)
      set_gate(site, K, true)
      K.say(site, { "pd-legendary-colosseum.start", math.floor(K.ticks(15) / 60) })
    end
    return
  end
  if #inside == 0 then
    d.empty = (d.empty or 0) + 6
    if d.empty >= 300 then reset(site, K, { "pd-legendary-colosseum.lost" }) end
    return
  end
  d.empty = 0
  if d.next_wave and ctx.tick >= d.next_wave then
    d.next_wave = nil
    local lever = K.get(site, "cashout")
    if lever then lever.destroy() end
    d.wave = d.wave + 1
    spawn_wave(site, ctx, K)
    return
  end
  if not d.next_wave and #K.list(site, "wave") == 0 and d.wave > 0 then
    if d.wave >= #WAVES then
      d.bonus, d.extra_stacks = 3, 6
      K.say(site, { "pd-legendary-colosseum.victory" })
      K.feat(site, "colosseum-bread", inside[1].player)
      K.solve(site, inside[1].player)
      return
    end
    d.next_wave = ctx.tick + K.ticks(20)
    K.place(site, "pd-legend-lever", 0.5, 0.5, { force = "neutral", key = "cashout", invincible = true })
    K.text(site, K.abs(site, 0.5, -1.2), { "pd-legendary-colosseum.cashout-label" }, { 1, 0.85, 0.4 }, 1.2, K.ticks(20))
    K.say(site, { "pd-legendary-colosseum.cleared", d.wave, math.floor(K.ticks(20) / 60) })
  end
  -- gladiators keep hunting
  if ctx.tick % 120 < 6 then
    for _, u in ipairs(K.list(site, "wave")) do
      if u.commandable and not u.commandable.has_command then
        K.attack(u, inside[math.random(#inside)].char)
      end
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  if key ~= "cashout" then return end
  local d = site.data
  d.bonus = math.floor(d.wave / 3)
  d.extra_stacks = math.max(0, d.wave - 4)
  if d.wave < 5 then
    d.relic = false
    K.feat(site, "colosseum-coward", player)
  end
  K.say(site, { "pd-legendary-colosseum.cashout", player and player.name or "?", d.wave })
  K.solve(site, player)
end

function KIND.solved(site, K)
  for _, u in ipairs(K.list(site, "wave")) do u.destroy() end
  set_gate(site, K, false)
end

function KIND.sleep(site, K)
  if site.data.fight then reset(site, K, { "pd-legendary-colosseum.lost" }) end
end

return KIND
