local TestHelpers = require("tests/test-helpers")
local player = nil

before_all(function()
  player = game.players[1]
end)

test("Begins with the expected surfaces", function()
  assert.is.truthy(game.get_surface(TestHelpers.playerSurfaceName))
  assert.is.truthy(game.get_surface(TestHelpers.forceSurfaceName))
end)

test("Begins with the expected forces", function()
  assert.is.truthy(game.forces[TestHelpers.sandboxForce])
end)

test("Begins with minor storage data", function()
  assert.are_equal(1, table_size(storage.forces))
  assert.are_equal(TestHelpers.sandboxForce, storage.forces[TestHelpers.playerForce].sandboxForceName)

  assert.are_equal(1, table_size(storage.players))
  assert.are_equal(TestHelpers.playerForce, storage.players[player.index].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.players[player.index].sandboxForceName)
  assert.are_equal(TestHelpers.playerSurfaceName, storage.players[player.index].labName)

  assert.are_equal(1, table_size(storage.sandboxForces))
  assert.are_equal(TestHelpers.playerForce, storage.sandboxForces[TestHelpers.sandboxForce].forceName)
  assert.are_equal(TestHelpers.forceSurfaceName, storage.sandboxForces[TestHelpers.sandboxForce].labName)

  assert.are_equal(2, table_size(storage.labSurfaces))
  assert.are_equal(TestHelpers.playerForce, storage.labSurfaces[TestHelpers.playerSurfaceName].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.labSurfaces[TestHelpers.playerSurfaceName].sandboxForceName)

  assert.are_equal(TestHelpers.playerForce, storage.labSurfaces[TestHelpers.forceSurfaceName].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.labSurfaces[TestHelpers.forceSurfaceName].sandboxForceName)
end)