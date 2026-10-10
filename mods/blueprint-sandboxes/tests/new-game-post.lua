local TestHelpers = require("tests/test-helpers")

test("Creates the surface data", function()
  assert.are_equal(2, table_size(storage.labSurfaces))
  assert.are_equal(TestHelpers.playerForce, storage.labSurfaces[TestHelpers.playerSurfaceName].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.labSurfaces[TestHelpers.playerSurfaceName].sandboxForceName)

  assert.are_equal(TestHelpers.playerForce, storage.labSurfaces[TestHelpers.forceSurfaceName].forceName)
  assert.are_equal(TestHelpers.sandboxForce, storage.labSurfaces[TestHelpers.forceSurfaceName].sandboxForceName)
end)