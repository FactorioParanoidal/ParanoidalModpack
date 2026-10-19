local TestHelpers = require("tests/test-helpers")
local player = nil

before_all(function()
  settings.global[Settings.isolationLevel] = { value = Isolation.full }
  player = game.players[1]
  Sandbox.Toggle(player.index)
  storage.players[player.index].selectedSandbox = Sandbox.force
  Sandbox.Transfer(player)
end)

test("Exits the sandbox after changing the isolation level to none", function()
  settings.global[Settings.isolationLevel] = { value = Isolation.none }
  assert.are_equal("nauvis", player.surface.name)
end)

test("Is using the Remote View controller after re-entrance", function()
  Sandbox.Toggle(player.index)
  assert.is.truthy(Controllers.IsUsingRemoteView(player))
  assert.is.falsy(player.cheat_mode)
end)

test("Changed equipment to the player force", function()
  TestHelpers.CheckDefaultEquipment(player.surface, TestHelpers.playerForce)
end)

test("Exits the sandbox after changing the isolation level back to full", function()
  settings.global[Settings.isolationLevel] = { value = Isolation.full }
  assert.are_equal("nauvis", player.surface.name)
end)

test("Enters the sandbox again manually", function()
  Sandbox.Toggle(player.index)
end)

test("Is using the God controller after re-entrance", function()
  assert.is.truthy(Controllers.IsGod(player))
  assert.is.truthy(player.cheat_mode)
end)

test("Changed equipment back to the sandbox force", function()
  TestHelpers.CheckDefaultEquipment(player.surface, TestHelpers.sandboxForce)
end)