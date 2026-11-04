-- Run with --test-scenario paranoidal-ruins/legendary-hammer-regression.
local K = require("__paranoidal-ruins__/legendary/kit")
local hammer = require("__paranoidal-ruins__/legendary/kinds/hammer")

script.on_event(defines.events.on_tick, function()
  local surface = game.surfaces.nauvis
  local force = game.forces["pd-legend"]
  local site = {
    x = 0, y = 0, half = 80, surface = surface.index,
    data = { spiked = {}, bunkers = {}, next_salvo = game.tick }, ents = {},
  }
  for i, pos in ipairs({ { -28, -60 }, { 25, -60 }, { -28, -44 }, { 25, -44 } }) do
    site.ents["mortar-" .. i] = assert(surface.create_entity({
      name = "artillery-turret", position = pos, force = force,
    }))
  end
  local player = assert(game.players[1])
  hammer.tick(site, { tick = game.tick, players = {
    { player = player, pos = { x = 10, y = 20 }, rx = 10, ry = 20, inside = true },
  } }, K)
  assert(#site.data.shells == 8, "All four mortars must fire two shells")
  assert(#surface.find_entities_filtered({ name = "explosion-gunshot" }) == 4,
    "Each mortar must create its muzzle flash")

  -- The pending impacts must still resolve when the player leaves the killing field.
  hammer.tick(site, { tick = game.tick + 126, players = {} }, K)
  assert(#site.data.shells == 0, "All queued shells must land")
  log("PASS: Hammer salvo, four directed muzzle flashes and eight impacts")
  script.finish_test()
end)
