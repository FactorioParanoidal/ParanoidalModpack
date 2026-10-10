local TestHelpers = require("tests/test-helpers")
local player = nil

before_all(function()
  settings.global[Settings.isolationLevel] = { value = Isolation.none }
  player = game.players[1]
end)

test("Creates and enters the player sandbox on toggle", function()
  Sandbox.Toggle(player.index)
  local surface = game.get_surface(TestHelpers.playerSurfaceName)
  assert.are_equal(TestHelpers.playerSurfaceName, surface.name)
  assert.are_equal(TestHelpers.playerSurfaceName, player.surface.name)
end)

test("Is using the Remote View controller", function()
  assert.is.truthy(Controllers.IsUsingRemoteView(player))
end)

test("Does not create the Sandbox force", function()
  assert.are_equal(1, table_size(storage.forces))
  assert.are_equal(1, table_size(storage.sandboxForces))
  assert.is.falsy(game.forces[TestHelpers.sandboxForce])
  assert.are_equal(TestHelpers.playerForce, player.force.name)
end)

test("Creates equipment with the right force (player sandbox)", function()
  TestHelpers.CheckDefaultEquipment(player.surface, TestHelpers.playerForce)
end)

test("Can see surface lists and all surfaces (part 1)", function()
  assert.is.truthy(player.game_view_settings.show_surface_list)
  for _, surface in pairs(game.surfaces) do
    if Lab.IsLab(surface) then
      assert.message(surface.name).is.falsy(player.force.get_surface_hidden(surface))
    end
  end
end)

test("Transfers to the force sandbox", function()
  storage.players[player.index].selectedSandbox = Sandbox.force
  Sandbox.Transfer(player)
  local surface = game.get_surface(TestHelpers.forceSurfaceName)
  assert.are_equal(TestHelpers.forceSurfaceName, surface.name)
  assert.are_equal(TestHelpers.forceSurfaceName, player.surface.name)
end)

test("Creates equipment with the right force (force sandbox)", function()
  TestHelpers.CheckDefaultEquipment(player.surface, TestHelpers.playerForce)
end)

test("Can see surface lists and all surfaces (part 2)", function()
  assert.is.truthy(player.game_view_settings.show_surface_list)
  for _, surface in pairs(game.surfaces) do
    if Lab.IsLab(surface) then
      assert.message(surface.name).is.falsy(player.force.get_surface_hidden(surface))
    end
  end
end)

test("Exits the sandbox appropriately", function()
  Sandbox.Exit(player)
end)

test("Returns to the character after exit", function()
  assert.are_equal("nauvis", player.surface.name)
  assert.is.truthy(Controllers.IsCharacter(player))
end)