-- The Observatory on the Cliff: an island plateau in a ring of deep water, reached by four narrow
-- causeways. Attune the telescope with its lever and hold it for three minutes: the creatures of the
-- night come across the causeways in growing waves. Anything may be built on the plateau. If the
-- telescope falls, it is rebuilt by the ancients a minute later and the ritual starts over.
local C = require("legendary.config")

local KIND = { name = "observatory", tier = "citadel", size = 128, weight = 1, relic = "pd-relic-star-telescope" }

local ISLAND, MOAT = 38, 50
local ENDS = { { 0, -58 }, { 58, 0 }, { 0, 57 }, { -58, 0 } }
local WAVE_UNITS = { "medium-biter", "medium-spitter", "big-biter", "big-spitter", "behemoth-biter" }

KIND.allow_build = function(name, type)
  return type ~= "car" and type ~= "spider-vehicle" and type ~= "locomotive"
end

function KIND.layout(plan, site)
  local rng, d = plan.rng, site.data
  plan:fill(function(x, y)
    local r = math.sqrt((x + 0.5) ^ 2 + (y + 0.5) ^ 2)
    if r < ISLAND then return rng.chance(0.2) and "grass-2" or "grass-1" end
    if r < MOAT then
      local causeway = (math.abs(x + 0.5) < 1.6) or (math.abs(y + 0.5) < 1.6)
      return causeway and "stone-path" or "deepwater"
    end
    return rng.chance(0.3) and "dirt-3" or "dirt-2"
  end, -64, -64, 63, 63)
  plan:fill("refined-concrete", -6, -6, 5, 5)
  plan:put("radar", -2, -2, { force = "neutral", key = "telescope", invincible = true, locked = true, sealed = true, quality = C.boss_tier(8) })
  plan:lever("attune", 3, 3)
  plan:vault(-5, 3)
  plan:vault(-3, 3)
  plan:sprinkle({ "tree-01", "tree-02", "tree-03", "tree-04" }, 50, { force = "neutral" }, { -30, -30, 29, 29 })
end

function KIND.built(site, K)
  K.text(site, K.abs(site, 3.5, 1.8), { "pd-legendary-observatory.attune" }, { 0.7, 0.8, 1 }, 1.1, nil, true)
  K.text(site, K.abs(site, 0.5, 60), { "pd-legendary-observatory.sign" }, { 0.7, 0.8, 1 }, 1.5, nil, true)
end

local function stop_ritual(site, K, message)
  local d = site.data
  d.ritual = nil
  for _, u in ipairs(K.list(site, "wave")) do u.destroy() end
  if site.lists then site.lists.wave = nil end
  if message then K.say(site, message) end
end

function KIND.lever(site, key, player, entity, K)
  if key ~= "attune" then return end
  local d = site.data
  local scope = K.get(site, "telescope")
  if not scope or not player then
    K.relever(site, key, 3.5, 3.5, 60)
    return
  end
  scope.force = player.force
  scope.destructible = true
  scope.minable_flag = false
  K.watch(site, scope, "telescope")
  d.ritual = { start = game.tick, ends = game.tick + K.ticks(180), wave = 0, next_wave = game.tick + 300 }
  K.say(site, { "pd-legendary-observatory.start", math.floor(K.ticks(180) / 60) })
end

function KIND.tick(site, ctx, K)
  local d = site.data
  if d.rebuild_at and ctx.tick >= d.rebuild_at then
    d.rebuild_at = nil
    K.place(site, "radar", -0.5, -0.5, { force = "neutral", key = "telescope", invincible = true, locked = true, sealed = true, quality = C.boss_tier(8) })
    K.relever(site, "attune", 3.5, 3.5)
    K.say(site, { "pd-legendary-observatory.rebuilt" })
  end
  local r = d.ritual
  if not r then return end
  local scope = K.get(site, "telescope")
  if not scope then return end
  local left = r.ends - ctx.tick
  if ctx.tick % 60 < 6 then
    K.text(site, K.abs(site, 0, -4), { "pd-legendary.timer", K.clock(left) }, { 0.7, 0.8, 1 }, 1.8, 61)
  end
  if left <= 0 then
    stop_ritual(site, K, { "pd-legendary-observatory.done" })
    K.solve(site, ctx.players[1] and ctx.players[1].player)
    return
  end
  if ctx.tick >= r.next_wave then
    r.wave = r.wave + 1
    r.next_wave = ctx.tick + K.ticks(12)
    local size = math.min(9, 2 + math.floor(r.wave * 0.6))
    local tier = math.min(#WAVE_UNITS, 1 + math.floor(r.wave / 4))
    if #K.list(site, "wave") > 120 then size = 0 end
    for _, e in ipairs(ENDS) do
      for _ = 1, size do
        local name = WAVE_UNITS[math.random(1, tier)]
        local u = K.spawn(site, name, K.abs(site, e[1] + math.random(-2, 2), e[2] + math.random(-2, 2)), C.boss_tier(1 + math.floor(r.wave / 3)))
        if u then
          site.lists = site.lists or {}
          site.lists.wave = site.lists.wave or {}
          table.insert(site.lists.wave, u)
          K.attack(u, scope)
        end
      end
    end
  end
end

function KIND.destroyed(site, tag, _, K)
  if tag ~= "telescope" then return end
  stop_ritual(site, K, { "pd-legendary-observatory.fallen" })
  site.data.rebuild_at = game.tick + K.ticks(60)
end

function KIND.sleep(site, K)
  local d = site.data
  if not d.ritual then return end
  stop_ritual(site, K, nil)
  local scope = K.get(site, "telescope")
  if scope then
    scope.force = "neutral"
    scope.destructible = false
  end
  K.relever(site, "attune", 3.5, 3.5)
end

function KIND.solved(site, K)
  local scope = K.get(site, "telescope")
  if scope then scope.destructible = false end
end

return KIND
