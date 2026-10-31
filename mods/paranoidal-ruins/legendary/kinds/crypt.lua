-- The Archivist's Crypt: four tablets in the yard name four runes of the door code, each as
-- "as many <objects> as stand in <hall>". Count them in the halls (decoys stand elsewhere), set the
-- four dials at the door and pull the seal. A wrong code fills the porch with poison and wakes the
-- crypt's keepers.
local C = require("legendary.config")

local KIND = { name = "crypt", tier = "trial", size = 64, weight = 1, relic = "pd-relic-archive" }

local OBJECTS = { "small-lamp", "big-rock", "wooden-chest", "torch" }
local HALLS = {
  nw = { -27, -27 }, ne = { 15, -27 }, sw = { -27, 15 }, se = { 15, 15 },
}
local HALL_ORDER = { "nw", "ne", "sw", "se" }
local DIALS = { -6, -3, 2, 5 }
local ROMAN = { "I", "II", "III", "IV" }

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x + y) % 5 == 0) and "rough-stone-path" or "stone-path" end, -32, -32, 31, 31)
  plan:wall_ring(-32, -32, 31, 31, { { -1, 31 }, { 0, 31 } })
  -- the crypt
  plan:fill("lab-dark-1", -7, -7, 6, 6)
  plan:wall_ring(-8, -8, 7, 7, { { -1, 7 }, { 0, 7 } })
  for x = -1, 0 do plan:put(C.WALL, x, 7, { force = "legend", invincible = true, locked = true, list = "door" }) end
  plan:vault(-3, -3)
  plan:vault(2, -3)
  -- halls: 12 x 12 rooms with a door towards the centre
  local types = rng.shuffle({ 1, 2, 3, 4 })
  d.code, d.secret, d.clues = { 0, 0, 0, 0 }, {}, {}
  for h, name in ipairs(HALL_ORDER) do
    local o = HALLS[name]
    local x1, y1 = o[1], o[2]
    local door_x = name:sub(2, 2) == "w" and x1 + 11 or x1
    plan:fill("refined-concrete", x1 + 1, y1 + 1, x1 + 10, y1 + 10)
    plan:wall_ring(x1, y1, x1 + 11, y1 + 11, { { door_x, y1 + 5 }, { door_x, y1 + 6 } })
    local count = rng.next(1, 9)
    local obj = OBJECTS[types[h]]
    local placed = plan:scatter(obj, count, { force = "neutral", invincible = true, locked = true }, { x1 + 2, y1 + 2, x1 + 9, y1 + 9 })
    -- a decoy of another kind in the same hall
    local decoy = OBJECTS[types[h % 4 + 1]]
    plan:scatter(decoy, rng.next(1, 6), { force = "neutral", invincible = true, locked = true }, { x1 + 2, y1 + 2, x1 + 9, y1 + 9 })
    d.secret[h] = placed
    d.clues[h] = { obj = obj, hall = name }
  end
  -- the rune order differs from the hall order
  d.order = rng.shuffle({ 1, 2, 3, 4 })
  -- tablets in the yard, dials and the seal at the door
  local spots = { { -12, -30 }, { 11, -30 }, { -30, 0 }, { 29, -1 } }
  for i = 1, 4 do plan:tablet("tablet-" .. i, spots[i][1], spots[i][2]) end
  for i, x in ipairs(DIALS) do plan:lever("dial-" .. i, x, 10) end
  plan:lever("seal", -1, 13)
  -- decoys in the yard (not inside the crypt, not on the porch)
  plan:reserve(-8, -8, 7, 15)
  for _, obj in ipairs(OBJECTS) do
    plan:scatter(obj, rng.next(2, 5), { force = "neutral", invincible = true, locked = true }, { -30, -12, 29, 12 })
  end
end

local function dial_label(site, K, i)
  local d = site.data
  d.labels = d.labels or {}
  local obj = d.labels[i]
  if obj and obj.valid then obj.destroy() end
  d.labels[i] = K.text(site, K.abs(site, DIALS[i] + 0.5, 8.4), ROMAN[i] .. ": " .. d.code[i], { 1, 0.85, 0.3 }, 1.6, nil, true)
end

function KIND.built(site, K)
  local d = site.data
  for rune = 1, 4 do
    local hall = d.order[rune]
    local clue = d.clues[hall]
    local tablet = K.get(site, "tablet-" .. rune)
    if tablet then
      K.text(site, { x = tablet.position.x, y = tablet.position.y - 2 },
        { "pd-legendary-crypt.tablet", ROMAN[rune], { "pd-legendary-crypt.obj-" .. clue.obj }, { "pd-legendary-crypt.hall-" .. clue.hall } },
        { 0.85, 0.85, 1 }, 1.1, nil, true)
    end
  end
  for i = 1, 4 do dial_label(site, K, i) end
  K.text(site, K.abs(site, -0.5, 14.6), { "pd-legendary-crypt.seal" }, { 1, 0.5, 0.3 }, 1.2, nil, true)
end

function KIND.lever(site, key, player, entity, K)
  local d = site.data
  local i = tonumber(key:match("^dial%-(%d)$"))
  if i then
    d.code[i] = (d.code[i] + 1) % 10
    K.relever(site, key, DIALS[i] + 0.5, 10.5)
    dial_label(site, K, i)
    return
  end
  if key ~= "seal" then return end
  local right = true
  for rune = 1, 4 do
    if d.code[rune] ~= d.secret[d.order[rune]] then right = false end
  end
  if right then
    K.destroy_list(site, "door")
    K.say(site, { "pd-legendary-crypt.open" })
    K.sound(site, "utility/game_won", K.abs(site, 0, 7))
    d.open = true
  else
    K.say(site, { "pd-legendary-crypt.wrong" })
    K.fact(site, "crypt-wrong", player)
    for _ = 1, 8 do K.cloud(site, K.abs(site, math.random(-8, 8), math.random(8, 16))) end
    for _ = 1, 3 do
      local keeper = K.spawn(site, "bm_fake_human_melee_2", K.abs(site, math.random(-20, 20), -14), C.boss_tier(3))
        or K.spawn(site, "medium-biter", K.abs(site, math.random(-20, 20), -14), C.boss_tier(3))
      if keeper and player and player.character then K.attack(keeper, player.character) end
      if keeper then
        site.lists = site.lists or {}
        site.lists.guardian = site.lists.guardian or {}
        table.insert(site.lists.guardian, keeper)
      end
    end
    d.reseal = game.tick + K.ticks(10)
  end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if d.reseal and ctx.tick >= d.reseal then
    d.reseal = nil
    K.relever(site, "seal", -0.5, 13.5)
  end
end

function KIND.step(site, p, K)
  if site.data.open and p.rx > -7 and p.rx < 7 and p.ry > -7 and p.ry < 7 then K.solve(site, p.player) end
end

return KIND
