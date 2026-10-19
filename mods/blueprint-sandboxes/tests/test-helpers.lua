TestHelpers = {}
TestHelpers.playerForce = "player"
TestHelpers.sandboxForce = "bpsb-sb-f-player"
TestHelpers.playerSurfaceName = "bpsb-lab-p-somethingtohide"
TestHelpers.forceSurfaceName = "bpsb-lab-f-player"

function TestHelpers.CheckDefaultEquipment(surface, forceName)
  local equipment = surface.find_entities()
  TestHelpers.CheckGhostCounts(surface, 0)
  TestHelpers.CheckEntityCounts(surface, 3)
  for _, entity in pairs(equipment) do
    assert.are_equal(forceName, entity.force.name)
  end
end

---@param surface LuaSurface
---@param count number
function TestHelpers.CheckGhostCounts(surface, count)
  local found = surface.count_entities_filtered {
    type = "entity-ghost",
  }
  assert.message("Count of ghosts").are_equal(count, found)
end

---@param surface LuaSurface
---@param count number
function TestHelpers.CheckEntityCounts(surface, count)
  local found = surface.count_entities_filtered {
    type = "entity-ghost",
    invert = true,
  }
  assert.message("Count of non-ghosts").are_equal(count, found)
end

return TestHelpers