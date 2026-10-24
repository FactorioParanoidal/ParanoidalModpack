-- The Pharaoh's Pyramid: a spiral of corridors with pressure plates (darts across the corridor,
-- jets of fire, a collapsing ceiling). The idol in the burial chamber is the relic itself: lift it and
-- the pyramid collapses - 45 seconds to get out with it, mummies awake, the entrance closes. Escape
-- and the treasury at the entrance opens; stay inside and the pyramid lets you out by a secret
-- passage, but the treasury is sealed forever.
local C = require("legendary.config")

local KIND = { name = "pyramid", tier = "trial", size = 96, weight = 1, relic = "pd-relic-sun-obelisk" }

local RINGS = { 40, 36, 32, 28, 24, 20, 16, 12, 8 }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function() return rng.pick({ "sand-1", "sand-2", "sand-3" }) end, -48, -48, 47, 47)
  plan:fill("stone-path", -40, -40, 40, 40)
  d.plates = {}
  for k, r in ipairs(RINGS) do
    -- opening: outer ring in the south, then alternating north / south
    local south = (k % 2 == 1)
    local doors = {}
    for x = -1, 1 do doors[#doors + 1] = { x, south and r or -r } end
    plan:wall_ring(-r, -r, r, r, doors)
    if k == 1 then d.entrance = { { -1, r }, { 0, r }, { 1, r } } end
    -- plates in the corridor inside this ring (between r and the next ring)
    local inner = RINGS[k + 1]
    if inner then
      for _ = 1, 3 + math.floor(r / 8) do
        local side = rng.next(1, 4)
        local along = rng.next(-r + 2, r - 2)
        local depth = rng.next(inner + 1, r - 1)
        local x, y
        if side == 1 then x, y = along, -depth elseif side == 2 then x, y = along, depth
        elseif side == 3 then x, y = -depth, along else x, y = depth, along end
        local kinds = { "darts", "darts", "fire", "ceiling" }
        d.plates[x .. "," .. y] = { kind = kinds[rng.next(1, #kinds)], side = side, inner = inner, outer = r, x = x, y = y }
        plan:tile("rough-stone-path", x, y)
      end
    end
  end
  -- burial chamber
  plan:fill("lab-dark-1", -7, -7, 7, 7)
  plan:fill("yellow-refined-concrete", -1, -1, 0, 0)
  plan:put("crash-site-chest-1", -1, -1, { force = "neutral", key = "altar", invincible = true, locked = true })
  d.sarcophagi = {}
  for _, s in ipairs({ { -5, -5 }, { 4, -5 }, { -5, 4 }, { 4, 4 }, { -22, 0 }, { 21, 0 }, { 0, -30 }, { 0, 29 } }) do
    d.sarcophagi[#d.sarcophagi + 1] = s
    plan:put("big-rock", s[1], s[2], { force = "neutral", invincible = true, locked = true, loose = true })
  end
  -- treasury in front of the entrance
  plan:fill("refined-concrete", -6, 42, 5, 46)
  plan:vault(-3, 44)
  plan:vault(2, 44)
  d.relic = false   -- the relic is the idol, not part of the treasury
  d.queue = {}
end

function KIND.built(site, K)
  local altar = K.get(site, "altar")
  if altar then
    altar.insert({ name = KIND.relic, count = 1 })
    K.light(site, altar.position, 1.5, { 1, 0.85, 0.3 }, true)
  end
  K.text(site, K.abs(site, 0, 42), { "pd-legendary-pyramid.sign" }, { 1, 0.85, 0.4 }, 1.4, nil, true)
end

-- Plates -------------------------------------------------------------------------------------

local function corridor_bolts(site, K, plate)
  -- bolts fly across the corridor from the inner wall to the outer wall, three abreast
  local inner, outer = plate.inner + 0.6, plate.outer + 2
  for o = -1, 1 do
    local from, to
    if plate.side == 1 then
      from, to = { plate.x + 0.5 + o, -inner }, { plate.x + 0.5 + o, -outer }
    elseif plate.side == 2 then
      from, to = { plate.x + 0.5 + o, inner + 1 }, { plate.x + 0.5 + o, outer + 1 }
    elseif plate.side == 3 then
      from, to = { -inner, plate.y + 0.5 + o }, { -outer, plate.y + 0.5 + o }
    else
      from, to = { inner + 1, plate.y + 0.5 + o }, { outer + 1, plate.y + 0.5 + o }
    end
    K.bolt(site, K.abs(site, from[1], from[2]), K.abs(site, to[1], to[2]), 0.9)
  end
end

local function trigger(site, K, plate, p, tick)
  local d = site.data
  if tick < (plate.ready or 0) then return end
  plate.ready = tick + 360
  if plate.kind == "darts" then
    K.sound(site, "utility/cannot_build", p.pos)
    d.queue[#d.queue + 1] = { at = tick + 12, what = "darts", plate = plate.x .. "," .. plate.y }
  elseif plate.kind == "fire" then
    for o = -2, 2 do
      local fx, fy = plate.x + 0.5, plate.y + 0.5
      if plate.side <= 2 then fx = fx + o * 1.5 else fy = fy + o * 1.5 end
      K.flame(site, K.abs(site, fx, fy))
    end
  else
    K.circle(site, K.abs(site, plate.x + 0.5, plate.y + 0.5), 2.5, { 1, 0.2, 0.1, 0.4 }, 50, true)
    d.queue[#d.queue + 1] = { at = tick + 50, what = "ceiling", x = plate.x, y = plate.y }
  end
end

function KIND.step(site, p, K)
  local d = site.data
  local key = math.floor(p.rx) .. "," .. math.floor(p.ry)
  local plate = d.plates[key]
  if plate then trigger(site, K, plate, p, game.tick) end
  if d.collapse and not d.done then
    local outside = math.abs(p.rx) > 41.5 or math.abs(p.ry) > 41.5
    if outside and p.player.get_item_count(KIND.relic) > 0 then
      d.done = true
      K.say(site, { "pd-legendary-pyramid.escaped", p.player.name })
      if d.deadline - game.tick < 300 then K.feat(site, "pyramid-last-second", p.player) end
      K.solve(site, p.player)
    end
  end
end

local function rockfall(site, K, x, y)
  K.explode(site, K.abs(site, x + 0.5, y + 0.5), 2.5, 90, "big-explosion")
  local surface = K.surface(site)
  local pos = K.abs(site, x, y)
  if surface.can_place_entity({ name = "big-rock", position = pos }) then
    surface.create_entity({ name = "big-rock", position = pos, force = "neutral" })
  end
end

local function seal_entrance(site, K)
  for _, t in ipairs(site.data.entrance) do
    K.place(site, C.WALL, t[1] + 0.5, t[2] + 0.5, { force = "legend", invincible = true, locked = true })
  end
end

-- secret passage on the east side through every ring
local function secret_passage(site, K)
  local surface = K.surface(site)
  for _, r in ipairs(RINGS) do
    for y = -1, 1 do
      local area = { { site.x + r + 0.1, site.y + y + 0.1 }, { site.x + r + 0.9, site.y + y + 0.9 } }
      for _, w in pairs(surface.find_entities_filtered({ area = area, name = C.WALL })) do w.destroy() end
    end
  end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  for i = #d.queue, 1, -1 do
    local q = d.queue[i]
    if ctx.tick >= q.at then
      table.remove(d.queue, i)
      if q.what == "darts" then
        local plate = d.plates[q.plate]
        if plate then corridor_bolts(site, K, plate) end
      elseif q.what == "ceiling" then
        rockfall(site, K, q.x, q.y)
      end
    end
  end
  local altar = K.get(site, "altar")
  if not d.collapse and altar and altar.get_item_count(KIND.relic) == 0 then
    d.collapse = ctx.tick
    d.deadline = ctx.tick + K.ticks(45)
    K.say(site, { "pd-legendary-pyramid.collapse", math.floor(K.ticks(45) / 60) })
    for _, s in ipairs(d.sarcophagi) do
      local mummy = K.spawn(site, "bm_fake_human_melee_3", K.abs(site, s[1] + 2, s[2] + 2), C.boss_tier(4))
        or K.spawn(site, "medium-biter", K.abs(site, s[1] + 2, s[2] + 2), C.boss_tier(4))
      if mummy then
        site.lists = site.lists or {}
        site.lists.guardian = site.lists.guardian or {}
        table.insert(site.lists.guardian, mummy)
        local target = ctx.players[1]
        if target then K.attack(mummy, target.char) end
      end
    end
  end
  if d.collapse and not d.done then
    local left = d.deadline - ctx.tick
    if ctx.tick % 60 < 6 then
      for _, p in ipairs(ctx.players) do
        p.player.create_local_flying_text({ text = { "pd-legendary.timer", K.clock(left) }, position = p.pos, color = { 1, 0.5, 0.2 } })
        if p.inside and math.random() < 0.7 then
          local x, y = math.floor(p.rx + math.random(-4, 4)), math.floor(p.ry + math.random(-4, 4))
          K.circle(site, K.abs(site, x + 0.5, y + 0.5), 2.2, { 1, 0.2, 0.1, 0.4 }, 45, true)
          d.queue[#d.queue + 1] = { at = ctx.tick + 45, what = "ceiling", x = x, y = y }
        end
      end
    end
    if left <= 0 then
      d.done = true
      seal_entrance(site, K)
      secret_passage(site, K)
      K.ruin(site, { "pd-legendary-pyramid.sealed" })
    end
  end
end

return KIND
