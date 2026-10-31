-- The "Red Director" works: a mad factory still arms its own defence. Each of the four sectors has
-- turrets fed by a cartridge workshop over a conveyor line; coal depots keep the workshops running.
-- While any sector is supplied, the Director's core is shielded and sends gun drones. Break the
-- workshops, cut the lines or burn the depots - when the last supply chain falls, the shield drops.
local C = require("legendary.config")

local KIND = { name = "director", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-director-hive" }

local SECTORS = { { -40, -40 }, { 40, -40 }, { -40, 40 }, { 40, 40 } }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x + y) % 9 == 0) and "hazard-concrete-left" or "concrete" end, -64, -64, 63, 63)
  plan:fill("refined-concrete", -10, -10, 9, 9)
  plan:wall_ring(-62, -62, 61, 61, { { -1, 61 }, { 0, 61 }, { 1, 61 } })
  plan:put("radar", -2, -2, { force = "legend", key = "core", quality = C.boss_tier(14), invincible = true })
  d.sectors = {}
  for k, s in ipairs(SECTORS) do
    local sx, sy = s[1], s[2]
    local sector = { x = sx, y = sy }
    -- four turrets in a square
    for _, o in ipairs({ { -6, -6 }, { 4, -6 }, { -6, 4 }, { 4, 4 } }) do
      plan:put("gun-turret", sx + o[1], sy + o[2], { force = "legend", quality = C.boss_tier(4), items = { ["firearm-magazine"] = 20 } })
    end
    -- the workshop between the sector and the core, the conveyor line from it to the turrets
    local fx, fy = math.floor(sx / 2) - 1, math.floor(sy / 2) - 1
    plan:put("burner-assembling-machine", fx, fy, { force = "legend", key = "fab-" .. k, recipe = "firearm-magazine",
      quality = C.boss_tier(6), items = { coal = 5, ["iron-plate"] = 40 } })
    -- horizontal run from the workshop to the sector column, then towards the turret square
    local hdir = sx < 0 and "west" or "east"
    local vdir = sy < 0 and "north" or "south"
    local y = fy + 1
    local x1 = sx < 0 and fx - 1 or fx + 3
    local hstep = sx < 0 and -1 or 1
    for x = x1, sx - hstep, hstep do
      plan:put("transport-belt", x, y, { force = "legend", dir = hdir, list = "belt-" .. k, quality = C.boss_tier(3) })
    end
    local vstep = sy < 0 and -1 or 1
    local y2 = sy < 0 and sy + 6 or sy - 7
    for yy = y, y2, vstep do
      plan:put("transport-belt", sx, yy, { force = "legend", dir = vdir, list = "belt-" .. k, quality = C.boss_tier(3) })
    end
    d.sectors[k] = sector
  end
  -- coal depots: two on the axes
  for _, p in ipairs({ { -1, -30 }, { -1, 29 } }) do
    plan:put("iron-chest", p[1], p[2], { force = "legend", list = "depot", quality = C.boss_tier(8), items = { coal = 200 } })
  end
  -- crates and cover
  plan:scatter(C.WALL, 30, { force = "legend", invincible = true, locked = true }, { -56, -56, 55, 55 })
  plan:vault(-2, 5)
  plan:vault(1, 5)
end

function KIND.built(site, K)
  local core = K.get(site, "core")
  if core then
    K.watch(site, core, "core")
    site.data.shield = rendering.draw_circle({ surface = site.surface, target = core, radius = 4, color = { 1, 0.1, 0.1, 0.25 }, filled = true })
    rendering.draw_text({ text = { "pd-legendary-director.core" }, surface = site.surface, target = { entity = core, offset = { 0, -3 } },
      color = { 1, 0.3, 0.2 }, scale = 1.5, alignment = "center" })
  end
end

local function chain_alive(site, K, k)
  local fab = K.get(site, "fab-" .. k)
  if not fab then return false end
  local belts = site.lists and site.lists["belt-" .. k] or {}
  for _, b in ipairs(belts) do if not b.valid then return false end end
  return #K.list(site, "depot") > 0
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if ctx.tick % 360 >= 6 then return end
  local surface = ctx.surface
  local alive = 0
  local depots = K.list(site, "depot")
  for k, s in ipairs(d.sectors) do
    if chain_alive(site, K, k) then
      alive = alive + 1
      local fab = K.get(site, "fab-" .. k)
      -- the workshop keeps working
      if fab.get_item_count("coal") < 2 and depots[1] and depots[1].get_item_count("coal") > 0 then
        depots[1].remove_item({ name = "coal", count = 1 })
        fab.insert({ name = "coal", count = 1 })
      end
      if fab.get_item_count("iron-plate") < 20 then fab.insert({ name = "iron-plate", count = 20 }) end
      local area = { { site.x + s.x - 10, site.y + s.y - 10 }, { site.x + s.x + 10, site.y + s.y + 10 } }
      for _, t in pairs(surface.find_entities_filtered({ area = area, type = "ammo-turret", force = C.FORCE })) do
        if t.get_item_count("firearm-magazine") < 30 then t.insert({ name = "firearm-magazine", count = 2 }) end
      end
    end
  end
  local core = K.get(site, "core")
  if not core then return end
  if alive == 0 and not d.shield_down then
    d.shield_down = true
    core.destructible = true
    if d.shield and d.shield.valid then d.shield.destroy() end
    K.say(site, { "pd-legendary-director.shield" })
  elseif alive > 0 then
    -- gun drones
    local drones = K.list(site, "drone")
    if #drones < 6 and #ctx.players > 0 then
      local drone = K.spawn(site, "bob-robot-gun-drone", core.position, C.boss_tier(3))
        or K.spawn(site, "medium-biter", core.position, C.boss_tier(3))
      if drone then
        site.lists = site.lists or {}
        site.lists.drone = site.lists.drone or {}
        table.insert(site.lists.drone, drone)
        site.lists.guardian = site.lists.guardian or {}
        table.insert(site.lists.guardian, drone)
        K.attack(drone, ctx.players[math.random(#ctx.players)].char)
      end
    end
  end
end

function KIND.destroyed(site, tag, _, K)
  if tag == "core" then
    K.say(site, { "pd-legendary-director.dead" })
    K.solve(site, nil)
  end
end

function KIND.solved(site, K)
  for k = 1, 4 do
    local fab = K.get(site, "fab-" .. k)
    if fab then fab.die() end
  end
  local surface = K.surface(site)
  for _, t in pairs(surface.find_entities_filtered({ area = K.area(site, 0), type = "ammo-turret", force = C.FORCE })) do t.die() end
end

return KIND
