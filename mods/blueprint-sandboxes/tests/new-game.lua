local TestHelpers = require("tests/test-helpers")

test("Begins without the expected surfaces", function()
  assert.is.falsy(game.get_surface(TestHelpers.playerSurfaceName))
  assert.is.falsy(game.get_surface(TestHelpers.forceSurfaceName))
end)

test("Begins without the expected forces", function()
  assert.is.falsy(game.forces[TestHelpers.sandboxForce])
end)

test("Begins with minor storage data", function()
  assert.are_equal(1, table_size(storage.forces))
  assert.are_equal(TestHelpers.sandboxForce, storage.forces[TestHelpers.playerForce].sandboxForceName)

  assert.are_equal(1, table_size(storage.players))
  assert.are_equal(TestHelpers.playerForce, storage.players[1].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.players[1].sandboxForceName)
  assert.are_equal(TestHelpers.playerSurfaceName, storage.players[1].labName)
  assert.are_equal(Sandbox.player, storage.players[1].selectedSandbox)
  assert.are_equal(nil, storage.players[1].insideSandbox)

  assert.are_equal(1, table_size(storage.sandboxForces))
  assert.are_equal(TestHelpers.playerForce, storage.sandboxForces[TestHelpers.sandboxForce].forceName)
  assert.are_equal(TestHelpers.forceSurfaceName, storage.sandboxForces[TestHelpers.sandboxForce].labName)

  assert.are_equal(0, table_size(storage.labSurfaces))
end)