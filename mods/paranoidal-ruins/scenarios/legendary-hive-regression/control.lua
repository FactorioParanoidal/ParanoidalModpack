-- Run with --test-scenario paranoidal-ruins/legendary-hive-regression.
local legendary = require("__paranoidal-ruins__/legendary/init")
local K = require("__paranoidal-ruins__/legendary/kit")
local hive = require("__paranoidal-ruins__/legendary/kinds/hive")

script.on_event(defines.events.on_object_destroyed, legendary.on_object_destroyed)

-- Another death handler can remove the next member of a list synchronously.
script.on_event(defines.events.on_entity_died, function(event)
  local site = storage.test_site
  if not site then return end
  for _, key in ipairs({ "egg", "worm", "nest", "brood" }) do
    local list = site.lists[key]
    if event.entity == list[1] and list[2].valid then
      list[2].destroy()
      storage.chain_deaths = storage.chain_deaths + 1
    end
  end
end)

script.on_event(defines.events.on_tick, function(event)
  legendary.on_tick(event)
  if storage.test_site then
    -- Let destruction notifications finish before checking the outcome.
    if game.tick < storage.started + 10 then return end
    assert(storage.test_site.state == "solved", "Killing the Queen must solve the hive")
    assert(storage.chain_deaths == 4, "Exercise invalidation during each cleanup list: " .. storage.chain_deaths)
    for _, key in ipairs({ "egg", "worm", "nest", "brood" }) do
      assert(#K.list(storage.test_site, key) == 0, "Surviving hive members: " .. key)
    end
    log("PASS: Queen destruction, chained hive deaths and solved site")
    script.finish_test()
    return
  end

  legendary.on_init()
  local surface = game.create_surface("hive-regression", { width = 256, height = 256 })
  surface.generate_with_lab_tiles = true
  surface.request_to_generate_chunks({ 0, 0 }, 2)
  surface.force_generate_chunk_requests()
  local function create(name, x, y)
    return assert(surface.create_entity({ name = name, position = { x, y }, force = "pd-legend" }))
  end
  local site = {
    id = 1, kind = "hive", state = "dormant", found = {}, forced = true,
    x = 0, y = 0, half = 80, surface = surface.index, data = {},
    ents = { queen = create("biter-spawner", 0, 0) },
    lists = {
      egg = { create("spitter-spawner", -20, 0), create("biter-spawner", 20, 0) },
      worm = { create("medium-worm-turret", -20, 20), create("big-worm-turret", 20, 20) },
      nest = { create("biter-spawner", -20, -20), create("biter-spawner", 20, -20) },
      brood = { create("big-biter", -10, 10), create("big-spitter", 10, 10) },
    },
  }
  storage.test_site, storage.chain_deaths, storage.started = site, 0, game.tick
  legendary.site.state().sites[site.id] = site
  hive.built(site, K)
  assert(site.ents.queen.die(), "The Queen must die before on_object_destroyed")
end)
