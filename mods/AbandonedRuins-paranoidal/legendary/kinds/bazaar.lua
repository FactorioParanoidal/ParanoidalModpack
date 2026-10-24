-- The Forerunners' Bazaar: a caravanserai where a nameless merchant still trades. Four stalls take
-- bulk standard materials and give quality goods. The treasury holds the relic: pay the tribute in
-- full - or break the lock and face the bazaar's guardian. After a robbery the merchant leaves.
local C = require("legendary.config")

local KIND = { name = "bazaar", tier = "trial", size = 64, weight = 1, relic = "pd-relic-themis-scales" }

local OFFERS = {
  { price = { { "iron-plate", 400 } }, goods = { { "inserter", 4, 5 } } },
  { price = { { "copper-plate", 300 }, { "iron-gear-wheel", 100 } }, goods = { { "assembling-machine-1", 2, 5 } } },
  { price = { { "stone", 300 }, { "coal", 300 } }, goods = { { "stone-furnace", 6, 6 } } },
  { price = { { "electronic-circuit", 150 } }, goods = { { "lab", 1, 6 } } },
  { price = { { "wood", 400 } }, goods = { { "small-electric-pole", 20, 6 } } },
  { price = { { "iron-plate", 300 }, { "copper-cable", 300 } }, goods = { { "electric-mining-drill", 2, 5 } } },
  { price = { { "raw-fish", 100 } }, goods = { { "light-armor", 1, 7 } } },
  { price = { { "steel-plate", 100 } }, goods = { { "gun-turret", 3, 5 } } },
  { price = { { "iron-plate", 200 }, { "steel-plate", 50 } }, goods = { { "submachine-gun", 1, 7 }, { "piercing-rounds-magazine", 50, 5 } } },
  { price = { { "coal", 600 } }, goods = { { "boiler", 1, 5 }, { "steam-engine", 2, 5 } } },
}
local TRIBUTE = { { "iron-plate", 2000 }, { "copper-plate", 1500 }, { "steel-plate", 400 }, { "electronic-circuit", 300 }, { "stone-brick", 500 } }
local STALLS = { { -18, -8 }, { 17, -8 }, { -18, 10 }, { 17, 10 } }

local function price_text(list)
  local parts = { "" }
  for _, p in ipairs(list) do
    parts[#parts + 1] = string.format("[item=%s]×%d ", p[1], p[2])
  end
  return table.concat(parts)
end

local function goods_text(list)
  local parts = { "" }
  for _, g in ipairs(list) do
    parts[#parts + 1] = string.format("[item=%s]×%d ", g[1], g[2])
  end
  return table.concat(parts)
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y) return ((x * x + y * y) % 7 == 0) and "sand-2" or "sand-1" end, -32, -32, 31, 31)
  plan:fill("rough-stone-path", -24, -16, 23, 18)
  plan:wall_ring(-32, -32, 31, 31, { { -1, 31 }, { 0, 31 }, { -1, -32 }, { 0, -32 } })
  local picks = rng.shuffle({ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 })
  d.stalls = {}
  for i, s in ipairs(STALLS) do
    plan:fill("orange-refined-concrete", s[1] - 2, s[2] - 2, s[1] + 2, s[2] + 2)
    plan:put("iron-chest", s[1], s[2], { force = "neutral", key = "stall-" .. i, invincible = true, locked = true })
    plan:put("small-lamp", s[1] - 2, s[2] - 2, { force = "neutral", invincible = true, locked = true })
    d.stalls[i] = { offer = picks[i], uses = 3 }
  end
  -- the treasury in the north with the tribute chest and the lock
  plan:fill("lab-dark-1", -8, -28, 7, -20)
  plan:wall_ring(-9, -29, 8, -19, { { -1, -19 }, { 0, -19 } })
  for x = -1, 0 do plan:put(C.WALL, x, -19, { force = "legend", invincible = true, locked = true, list = "door" }) end
  plan:vault(-3, -25)
  plan:vault(2, -25)
  plan:put("steel-chest", -4, -17, { force = "neutral", key = "tribute", invincible = true, locked = true })
  plan:lever("lock", 3, -17)
  plan:put("crash-site-spaceship", -6, 2, { force = "neutral", invincible = true, locked = true, sealed = true, loose = true })
end

function KIND.built(site, K)
  local d = site.data
  for i, s in ipairs(STALLS) do
    local offer = OFFERS[d.stalls[i].offer]
    K.text(site, K.abs(site, s[1] + 0.5, s[2] - 3), { "pd-legendary-bazaar.offer", price_text(offer.price), goods_text(offer.goods) },
      { 1, 0.9, 0.6 }, 1, nil, true)
  end
  K.text(site, K.abs(site, -3.5, -15.5), { "pd-legendary-bazaar.tribute", price_text(TRIBUTE) }, { 1, 0.8, 0.3 }, 1, nil, true)
  K.text(site, K.abs(site, 3.5, -15.5), { "pd-legendary-bazaar.lock" }, { 1, 0.4, 0.3 }, 1, nil, true)
end

local function has_all(inv, list)
  for _, p in ipairs(list) do
    if inv.get_item_count({ name = p[1], quality = "normal" }) < p[2] then return false end
  end
  return true
end

local function take(inv, list)
  for _, p in ipairs(list) do inv.remove({ name = p[1], count = p[2], quality = "normal" }) end
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if ctx.tick % 300 >= 6 then return end
  if not d.robbed then
    for i, stall in ipairs(d.stalls) do
      local chest = K.get(site, "stall-" .. i)
      local offer = OFFERS[stall.offer]
      if chest and stall.uses > 0 then
        local inv = chest.get_inventory(defines.inventory.chest)
        if has_all(inv, offer.price) then
          take(inv, offer.price)
          for _, g in ipairs(offer.goods) do
            if prototypes.item[g[1]] then inv.insert({ name = g[1], count = g[2], quality = C.tier(g[3]) }) end
          end
          stall.uses = stall.uses - 1
          K.float(site, chest.position, { "pd-legendary-bazaar.deal", stall.uses }, { 1, 0.9, 0.4 })
        end
      end
    end
    local tribute = K.get(site, "tribute")
    if tribute then
      local inv = tribute.get_inventory(defines.inventory.chest)
      if has_all(inv, TRIBUTE) then
        take(inv, TRIBUTE)
        K.destroy_list(site, "door")
        K.say(site, { "pd-legendary-bazaar.paid" })
        local p = ctx.players[1]
        K.solve(site, p and p.player)
      end
    end
  end
end

function KIND.lever(site, key, player, entity, K)
  if key ~= "lock" then return end
  local d = site.data
  d.robbed = true
  K.destroy_list(site, "door")
  K.say(site, { "pd-legendary-bazaar.robbery" })
  local guardian = K.spawn(site, "bm_fake_human_melee_5", K.abs(site, 0, -24), C.boss_tier(8))
    or K.spawn(site, "big-biter", K.abs(site, 0, -24), C.boss_tier(10))
  if guardian then
    site.lists = site.lists or {}
    site.lists.guardian = site.lists.guardian or {}
    table.insert(site.lists.guardian, guardian)
    K.watch(site, guardian, "guardian")
    rendering.draw_text({ text = { "pd-legendary-bazaar.guardian" }, surface = site.surface,
      target = { entity = guardian, offset = { 0, -2.4 } }, color = { 1, 0.4, 0.2 }, scale = 1.3, alignment = "center" })
    if player and player.character then K.attack(guardian, player.character) end
  end
  for _ = 1, 3 do
    local guard = K.spawn(site, "bm_fake_human_pistol_gunner_2", K.abs(site, math.random(-6, 6), -23), C.boss_tier(2))
    if guard then
      table.insert(site.lists.guardian, guard)
      if player and player.character then K.attack(guard, player.character) end
    end
  end
  for i in ipairs(d.stalls) do
    local chest = K.get(site, "stall-" .. i)
    if chest then chest.operable = false end
  end
end

function KIND.destroyed(site, tag, _, K)
  if tag == "guardian" then
    K.say(site, { "pd-legendary-bazaar.guardian-dead" })
    K.solve(site, nil)
  end
end

return KIND
