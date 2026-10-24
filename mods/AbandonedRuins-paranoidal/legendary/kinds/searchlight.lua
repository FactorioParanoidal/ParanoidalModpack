-- The "Searchlight" vault: a stealth run. Searchlight cones sweep the yard; walls and crate stacks
-- block their view. Caught in a beam - alarm: guards run out of the guardhouses. The third alarm
-- locks the vault door for a while. Three breaker levers each switch off two searchlights.
local C = require("legendary.config")

local KIND = { name = "searchlight", tier = "trial", size = 96, weight = 1, relic = "pd-relic-all-seeing-eye" }

local RANGE, HALF_ANGLE = 26, 0.36
local LIGHTS = {
  { -30, -30, 0.55 }, { 30, -30, -0.6 }, { -30, 30, -0.5 }, { 30, 30, 0.65 }, { 0, -20, 0.8 }, { 0, 22, -0.75 },
}
local BREAKERS = { { -42, -42, { 1, 3 } }, { 41, -42, { 2, 5 } }, { 41, 41, { 4, 6 } } }
local GUARDHOUSES = { { -40, 0 }, { 39, 0 } }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x * 7 + y * 3) % 11 == 0) and "dirt-6" or "concrete" end, -48, -48, 47, 47)
  plan:wall_ring(-46, -46, 45, 45, { { -1, 45 }, { 0, 45 }, { 1, 45 } })
  -- crate stacks and wall stubs: cover from the searchlights
  for _ = 1, 46 do
    local x, y = rng.next(-42, 40), rng.next(-42, 40)
    if math.abs(x) > 9 or math.abs(y) > 9 then
      local horizontal = rng.chance(0.5)
      local len = rng.next(2, 5)
      for t = 0, len - 1 do
        local wx, wy = horizontal and x + t or x, horizontal and y or y + t
        if plan:free(wx, wy, 1, 1) and (math.abs(wx) > 8 or math.abs(wy) > 8) then plan:wall(wx, wy) end
      end
    end
  end
  -- the vault building
  plan:fill("lab-dark-2", -7, -7, 6, 6)
  plan:wall_ring(-8, -8, 7, 7, {})
  for x = -1, 0 do
    plan:put(C.WALL, x, 7, { force = "legend", invincible = true, locked = true, list = "door" })
    plan.walls[x .. ",7"] = true
  end
  -- the door list is created closed and opened in built(): the third alarm closes it again
  plan:vault(-3, -3)
  plan:vault(2, -3)
  d.lights = {}
  for i, l in ipairs(LIGHTS) do
    plan:put("small-lamp", l[1], l[2], { force = "legend", invincible = true, locked = true, key = "light-" .. i })
    d.lights[i] = { x = l[1] + 0.5, y = l[2] + 0.5, a = rng.next() * 6.283, w = l[3], on = true }
  end
  d.breakers = {}
  for i, b in ipairs(BREAKERS) do
    plan:lever("breaker-" .. i, b[1], b[2])
    d.breakers[i] = b[3]
  end
  for _, g in ipairs(GUARDHOUSES) do
    plan:wall_ring(g[1] - 2, g[2] - 2, g[1] + 2, g[2] + 2, { { g[1] + (g[1] < 0 and 2 or -2), g[2] } })
  end
  d.walls = plan.walls
  d.alarms = 0
end

local function set_door(site, K, closed)
  local d = site.data
  if closed then
    for x = -1, 0 do
      K.place(site, C.WALL, x + 0.5, 7.5, { force = "legend", invincible = true, locked = true, list = "door" })
      d.walls[x .. ",7"] = true
    end
  else
    K.destroy_list(site, "door")
    for x = -1, 0 do d.walls[x .. ",7"] = nil end
  end
  d.door_closed = closed
end

function KIND.built(site, K)
  set_door(site, K, false)
  local d = site.data
  for i, l in ipairs(d.lights) do
    l.arc = K.cone(site, K.abs(site, l.x, l.y), RANGE, l.a, HALF_ANGLE)
    site.renders = site.renders or {}
    site.renders[#site.renders + 1] = l.arc
    K.light(site, K.abs(site, l.x, l.y), 1.2, { 1, 1, 0.7 }, true)
    local lamp = K.get(site, "light-" .. i)
    if lamp then lamp.disabled_by_script = false end
  end
  K.text(site, K.abs(site, 0, 47), { "pd-legendary-searchlight.sign" }, { 0.8, 0.9, 1 }, 1.4, nil, true)
end

local function angle_diff(a, b)
  local d = (a - b) % 6.283185
  if d > 3.141593 then d = d - 6.283185 end
  return math.abs(d)
end

local function alarm(site, ctx, K, p)
  local d = site.data
  d.alarms = d.alarms + 1
  d.alarm_until = ctx.tick + K.ticks(25)
  K.say(site, { "pd-legendary-searchlight.alarm", p.player.name, d.alarms })
  K.sound(site, "utility/alert_destroyed", p.pos)
  for _, g in ipairs(GUARDHOUSES) do
    for _ = 1, 2 + math.min(3, d.alarms) do
      local guard = K.spawn(site, "bm_fake_human_pistol_gunner_2", K.abs(site, g[1], g[2]), C.boss_tier(3))
        or K.spawn(site, "medium-biter", K.abs(site, g[1], g[2]), C.boss_tier(3))
      if guard then
        site.lists = site.lists or {}
        site.lists.guardian = site.lists.guardian or {}
        table.insert(site.lists.guardian, guard)
        K.attack(guard, p.char)
      end
    end
  end
  if d.alarms % 3 == 0 then
    set_door(site, K, true)
    d.lockdown_until = ctx.tick + K.ticks(90)
    K.say(site, { "pd-legendary-searchlight.lockdown", math.floor(K.ticks(90) / 60) })
  end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  local dt = 6 / 60
  for _, l in ipairs(d.lights) do
    if l.on then
      l.a = (l.a + l.w * dt) % 6.283185
      if l.arc and l.arc.valid then l.arc.vertices = K.cone_vertices(K.abs(site, l.x, l.y), RANGE, l.a, HALF_ANGLE) end
    end
  end
  if d.lockdown_until and ctx.tick >= d.lockdown_until then
    d.lockdown_until = nil
    set_door(site, K, false)
    K.say(site, { "pd-legendary-searchlight.unlocked" })
  end
  -- guards go home when the alarm ends
  if d.alarm_until and ctx.tick >= d.alarm_until then
    d.alarm_until = nil
    for _, g in ipairs(K.list(site, "guardian")) do g.destroy() end
    site.lists.guardian = nil
  end
  if d.alarm_until then return end
  for _, p in ipairs(ctx.players) do
    if p.inside then
      for _, l in ipairs(d.lights) do
        if l.on then
          local dx, dy = p.rx - l.x, p.ry - l.y
          local dist = math.sqrt(dx * dx + dy * dy)
          if dist < RANGE and angle_diff(math.atan2(dy, dx), l.a) < HALF_ANGLE
            and not K.blocked(site, l.x, l.y, p.rx, p.ry) then
            alarm(site, ctx, K, p)
            return
          end
        end
      end
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  local i = tonumber(key:match("^breaker%-(%d)$"))
  local d = site.data
  if not i or not d.breakers[i] then return end
  for _, li in ipairs(d.breakers[i]) do
    local l = d.lights[li]
    l.on = false
    if l.arc and l.arc.valid then l.arc.visible = false end
    local lamp = K.get(site, "light-" .. li)
    if lamp then lamp.disabled_by_script = true end
  end
  d.breakers[i] = nil
  K.say(site, { "pd-legendary-searchlight.breaker" })
end

function KIND.step(site, p, K)
  if p.rx > -7 and p.rx < 7 and p.ry > -7 and p.ry < 7 then K.solve(site, p.player) end
end

return KIND
