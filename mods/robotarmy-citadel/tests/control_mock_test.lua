-- Control stage dry run without the game: lua tests/control_mock_test.lua (from the mod root).
-- The fake game API of tests/fake_api.lua runs the whole life of the citadel: waiting, warning,
-- appearance, growth, shields, loss of the hive and the new hive, defeat. It catches Lua errors and
-- broken flows; it is not engine evidence (pathing, combat, power, real placement and the events of
-- other mods are not simulated).
local F = dofile("tests/fake_api.lua")
local S = require("lib.shared")
F.load_citadel()
local surface, new_entity, run, said = F.surface, F.new_entity, F.run, F.said

local fails = 0
local function check(ok, msg)
  if not ok then
    fails = fails + 1
    print("FAIL " .. msg)
  else
    print("ok   " .. msg)
  end
end
local function status() return remote.call(S.mod, "status") end

F.init()
check(status().phase == "dormant", "starts dormant")
check(game.forces[S.force].get_cease_fire(game.forces.enemy) and game.forces.enemy.get_cease_fire(game.forces[S.force]),
  "truce with the biters both ways")
check(not game.forces[S.force].get_cease_fire(game.forces.player), "war with the player")
check(game.forces[S.force].ai_controllable, "citadel force can create unit groups")

-- a player base at the centre
new_entity({name = "stone-furnace", position = {5, 5}, force = "player"})
new_entity({name = "gun-turret", position = {40, 5}, force = "player"})

game.forces.enemy.evolution = 0.46
run(3600)
check(said("replicator-message.warning"), "warning at 45 %")
game.forces.enemy.evolution = 0.5
run(3600 + 1200) -- the next evolution look, the search of the place, the hive under construction
local st = status()
check(st.phase == "active", "citadel appears at 50 % (phase " .. st.phase .. ")")
check(said("replicator-message.appeared"), "appearance message")
check(game.forces.player.recipes[S.decrypt_recipe].enabled, "decryption recipe learned")
local d = math.sqrt(st.center.x ^ 2 + st.center.y ^ 2) / 32
check(d >= 59 and d <= 62, string.format("distance from spawn %.1f chunks", d))
check(st.core, "hive built")
check(st.foundries == 0, "the hive is not a foundry")
-- a biter nest two chunks from the hive
new_entity({name = "biter-spawner", position = {st.center.x + 64, st.center.y}, force = "enemy"})

-- one hour of life
run(3600 * 60)
st = status()
check(st.modules >= 6 and st.modules <= 8, "modules after an hour: " .. st.modules)
check((st.alive["foundry-light"] or 0) == 1 and (st.alive["power-plant"] or 0) == 1, "opening modules")
check(st.stats.produced > 20, "droids produced: " .. st.stats.produced)
check(st.stats.launched > 0, "squads launched: " .. st.stats.launched)
check(not st.building, "build queue empty")
local nests = surface.count_entities_filtered({type = "unit-spawner"})
check(nests == 0, "nest near the citadel cleared")

-- growth to the shield stage
remote.call(S.mod, "grow", 20)
run(3600 * 10)
st = status()
check(st.modules >= 25, "modules after forced growth: " .. st.modules)
check(st.shields, "shield stage")
local f = game.forces[S.force]
check(f.technologies["turret-shields-base"].researched and f.technologies["repair-turret-range-10"].researched,
  "shield and tower range research for the citadel force")
local towers = surface.count_entities_filtered({name = S.entity.shield_tower})
check(towers >= 25, "shield towers placed: " .. towers)
check(st.droids <= settings.global[S.setting.unit_limit].value, "droid limit holds: " .. st.droids)

-- the hive falls
local core = surface.find_entities_filtered({name = S.entity.core})[1]
core.die()
st = status()
check(st.stunned_until ~= nil and st.phase == "active", "hive lost: pause, not defeat")
check(said("replicator-message.core-destroyed"), "hive lost message")
local before = st.modules
run(3600 * 30)
check(status().modules == before, "no growth during the pause")
run(3600 * 31)
st = status()
check(said("replicator-message.new-core"), "new hive message")
check(st.core, "new hive built")
-- the old hive becomes a foundry; its cores lie on the ground where it stood and are moved aside
local function module_at(x, y)
  for _, m in pairs(remote.call(S.mod, "modules")) do if m.x * 32 + 16 == x and m.y * 32 + 16 == y then return m end end
end
local old_hive = module_at(core.position.x - (core.position.x % 32) + 16, core.position.y - (core.position.y % 32) + 16)
check(old_hive and old_hive.type == "foundry-light", "old hive module becomes a foundry")
local cores_before = surface.count_entities_filtered({type = "item-entity"})
check(cores_before > 0, "hive loot on the ground: " .. cores_before)
run(3600 * 25)
old_hive = module_at(old_hive.x * 32 + 16, old_hive.y * 32 + 16)
check(old_hive and old_hive.built and not old_hive.ruined and old_hive.placed == old_hive.planned,
  string.format("old hive rebuilt as a foundry despite the loot (placed %s of %s)", tostring(old_hive and old_hive.placed),
    tostring(old_hive and old_hive.planned)))
check(surface.count_entities_filtered({type = "item-entity"}) >= cores_before, "loot kept, moved aside")

-- every foundry and the hive: defeat
for _, e in pairs(surface.find_entities_filtered({force = S.force})) do
  if e.valid and (e.name == S.entity.core or e.name:find("foundry", 1, true)) then e.die() end
end
st = status()
check(st.phase == "destroyed", "defeat when the hive and every foundry are down (phase " .. st.phase .. ")")
run(3600 * 5)
local left = surface.count_entities_filtered({force = S.force})
check(left == 0, "the city blew up: " .. left .. " left")
check(said("replicator-message.destroyed"), "defeat message")

-- the save/load path keeps the build queue handler consistent
F.on_load()

print(string.format("kills %d, groups %d", F.kills, #F.groups))
print(fails == 0 and "ALL PASS" or ("FAILS " .. fails))
os.exit(fails == 0 and 0 or 1)
