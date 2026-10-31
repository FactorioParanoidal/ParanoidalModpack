-- The Mothership: the wreck of the colony ship this world never heard of. Eight compartments behind
-- bulkheads; red, blue and yellow doors open only with the access codes from the terminals of other
-- compartments. Fires burn, broken conduits stun with sparks, the surviving crew shoot strangers.
-- The bridge in the bow holds the ship's last cargo.
local C = require("legendary.config")

local KIND = { name = "mothership", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-rescue-beacon" }

local XS = { { -58, -31 }, { -29, -3 }, { -1, 25 }, { 27, 57 } }   -- room x ranges (columns 0..3)
local YS = { { -28, -1 }, { 1, 27 } }                               -- room y ranges (rows 0..1)
local BULK_X = { -30, -2, 26 }
local DOORS = {
  -- {col1, row1, col2, row2, color}
  { 0, 1, 0, 0, "open" }, { 0, 1, 1, 1, "red" }, { 1, 1, 1, 0, "open" }, { 1, 0, 2, 0, "blue" },
  { 2, 0, 2, 1, "open" }, { 2, 1, 3, 1, "open" }, { 2, 0, 3, 0, "yellow" },
}
local COLORS = { red = { 1, 0.2, 0.2 }, blue = { 0.3, 0.5, 1 }, yellow = { 1, 0.9, 0.2 } }

local function room_center(c, r)
  return math.floor((XS[c + 1][1] + XS[c + 1][2]) / 2), math.floor((YS[r + 1][1] + YS[r + 1][2]) / 2)
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "dirt-5", "dirt-6", "red-desert-1" }) end, -64, -64, 63, 63)
  plan:fill(function(x, y) return ((x + y) % 2 == 0) and "lab-dark-1" or "lab-dark-2" end, -59, -29, 58, 28)
  -- hull with a breach in the stern (west, lower deck)
  plan:wall_ring(-60, -30, 59, 29, { { -60, 12 }, { -60, 13 }, { -60, 14 } })
  for _, x in ipairs(BULK_X) do plan:wall_line(x, -29, x, 28) end
  plan:wall_line(-59, 0, 58, 0)
  -- doors: open doors are holes, coloured doors are wall segments in lists
  d.doors = {}
  local function door_tiles(c1, r1, c2, r2)
    local tiles = {}
    if r1 == r2 then
      local x = BULK_X[math.max(c1, c2)]
      local _, cy = room_center(c1, r1)
      for y = cy - 1, cy + 1 do tiles[#tiles + 1] = { x, y } end
    else
      local cx = room_center(c1, r1)
      for x = cx - 1, cx + 1 do tiles[#tiles + 1] = { x, 0 } end
    end
    return tiles
  end
  for _, door in ipairs(DOORS) do
    local tiles = door_tiles(door[1], door[2], door[3], door[4])
    for _, t in ipairs(tiles) do
      -- remove the bulkhead wall here: walls were placed already, so rebuild the plan entry list
      plan.walls[t[1] .. "," .. t[2]] = nil
    end
    d.doors[#d.doors + 1] = { tiles = tiles, color = door[5] }
  end
  -- drop wall entries that are door tiles, then add coloured doors
  local holes = {}
  for _, door in ipairs(d.doors) do for _, t in ipairs(door.tiles) do holes[t[1] .. "," .. t[2]] = true end end
  local kept = {}
  for _, e in ipairs(plan.entities) do
    local tx, ty = math.floor(e.x), math.floor(e.y)
    if not (e.name == C.WALL and holes[tx .. "," .. ty]) then kept[#kept + 1] = e end
  end
  plan.entities = kept
  for i, door in ipairs(d.doors) do
    if door.color ~= "open" then
      for _, t in ipairs(door.tiles) do
        plan:put(C.WALL, t[1], t[2], { force = "legend", invincible = true, locked = true, list = "door-" .. door.color, loose = true })
      end
      plan:fill(door.color .. "-refined-concrete", door.tiles[1][1], door.tiles[1][2], door.tiles[#door.tiles][1], door.tiles[#door.tiles][2])
    end
  end
  -- terminals: red before the red door, blue after red and before blue, yellow after blue
  local spots = {
    red = { { 0, 0 } },
    blue = { { 1, 1 }, { 1, 0 } },
    yellow = { { 2, 0 }, { 2, 1 }, { 3, 1 } },
  }
  d.keys = {}
  for color, list in pairs(spots) do
    local room = list[rng.next(1, #list)]
    local cx, cy = room_center(room[1], room[2])
    plan:lever("terminal-" .. color, cx + rng.next(-6, 6), cy + rng.next(-6, 6))
  end
  -- the bridge (before the wreckage, so nothing takes its place)
  plan:fill("refined-concrete", 40, -24, 54, -6)
  plan:vault(46, -16)
  plan:vault(49, -16)
  -- hazards: fires and sparking conduits in random rooms, crew
  d.fires, d.sparks = {}, {}
  for c = 0, 3 do
    for r = 0, 1 do
      local cx, cy = room_center(c, r)
      if rng.chance(0.5) then d.fires[#d.fires + 1] = { cx + rng.next(-8, 8), cy + rng.next(-8, 8) } end
      if rng.chance(0.5) then d.sparks[#d.sparks + 1] = { cx + rng.next(-8, 8), cy + rng.next(-8, 8) } end
      if not (c == 0 and r == 1) then
        for _ = 1, rng.next(1, 3) do
          local x, y = cx + rng.next(-9, 9), cy + rng.next(-9, 9)
          plan:at(rng.pick({ "bm_fake_human_pistol_gunner_3", "bm_fake_human_laser_3", "bm_fake_human_melee_4" }), x + 0.5, y + 0.5,
            { force = "legend", list = "guardian", quality = C.boss_tier(3) })
        end
      end
      plan:scatter({ "crash-site-spaceship-wreck-medium-1", "crash-site-spaceship-wreck-medium-2" }, 3,
        { force = "neutral", invincible = true, locked = true, sealed = true }, { cx - 10, cy - 10, cx + 10, cy + 10 })
    end
  end
end

function KIND.built(site, K)
  local d = site.data
  for _, door in ipairs(d.doors) do
    if door.color ~= "open" then
      local t = door.tiles[2]
      K.text(site, K.abs(site, t[1] + 0.5, t[2] - 1.5), { "pd-legendary-mothership.door-" .. door.color }, COLORS[door.color], 1, nil, true)
    end
  end
  for color in pairs(COLORS) do
    local e = K.get(site, "terminal-" .. color)
    if e then K.circle(site, e.position, 1.2, { COLORS[color][1], COLORS[color][2], COLORS[color][3], 0.5 }, nil, true, true) end
  end
  K.text(site, K.abs(site, -61, 13), { "pd-legendary-mothership.sign" }, { 0.8, 0.9, 1 }, 1.4, nil, true)
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if ctx.tick % 600 < 6 then
    for _, f in ipairs(d.fires) do K.flame(site, K.abs(site, f[1] + 0.5, f[2] + 0.5)) end
  end
  for _, s in ipairs(d.sparks) do
    if ctx.tick % 90 < 6 then K.effect(site, "spark-explosion", K.abs(site, s[1] + 0.5, s[2] + 0.5)) end
    for _, p in ipairs(ctx.players) do
      if (p.rx - s[1]) ^ 2 + (p.ry - s[2]) ^ 2 < 6 and ctx.tick % 90 < 6 then
        K.damage(p.char, 35, "electric")
        K.stick(site, p.char, "electric-mini-stun")
      end
    end
  end
  for color, at in pairs(d.opening or {}) do
    if ctx.tick >= at then
      d.opening[color] = nil
      K.destroy_list(site, "door-" .. color)
      K.say(site, { "pd-legendary-mothership.opened-" .. color })
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  local color = key:match("^terminal%-(%a+)$")
  local d = site.data
  if not color or d.keys[color] then return end
  d.keys[color] = true
  d.opening = d.opening or {}
  d.opening[color] = game.tick + 180
  K.say(site, { "pd-legendary-mothership.code-" .. color })
end

function KIND.step(site, p, K)
  if p.rx >= 40 and p.rx < 55 and p.ry >= -24 and p.ry < -5 then K.solve(site, p.player) end
end

return KIND
