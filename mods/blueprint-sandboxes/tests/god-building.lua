local TestHelpers = require("tests/test-helpers")
local player = nil

before_all(function()
  settings.global[Settings.godAsyncCreateRequestsPerTick] = { value = 0 }
  settings.global[Settings.godAsyncUpgradeRequestsPerTick] = { value = 0 }
  settings.global[Settings.godAsyncDeleteRequestsPerTick] = { value = 0 }
  player = game.players[1]
end)

test("Enters the sandbox on toggle", function()
  Sandbox.Toggle(player.index)
end)

test("Places ghosts from a blueprint", function()
  local blueprintString = "0eNqFkdFqhDAQRf9lnuOi2WbB/EopQd3RDsRRkrjUSv69iQtSikvzNrlzz51MNmjtgrMjDqA3oG5iD/p9A08DNzbfcTMiaECLXXDUFcjohrVIDnR90yFEAcR3/AJdRXHibGkoDvc82d8OGT8EIAcKhM/gvVgNL2OLLiHFa4yAefLJOXFOS7RSwAq6kDHP8Qckxf8veQEs07zt0vfojKfvhKjK45wkXY8k4p44SUX3iT6c4C9qD5AXta/k2W08hkA8+NzlcJweaJak2TQm3g0FHJMU3IIxby/XeT3HPwp4oPN7irrJ+q2ulZLqdpVVjD/mj6gB"
  player.cursor_stack.import_stack(blueprintString)
  player.cursor_stack.build_blueprint({
    surface = player.surface.name,
    force = player.force.name,
    position = { 6, 6 },
    skip_fog_of_war = false, -- This works BACKWARDS??
    raise_built = true,
  })
  player.cursor_stack.clear()
end)

test("Revives the ghosts into real entities", function()
  TestHelpers.CheckGhostCounts(player.surface, 0)
  TestHelpers.CheckEntityCounts(player.surface, 6)
end)

test("Resets the lab", function()
  Lab.Reset(player)
end)

test("Has the original equipment again", function()
  TestHelpers.CheckGhostCounts(player.surface, 0)
  TestHelpers.CheckEntityCounts(player.surface, 3)
end)

test("Configures async god-building", function()
  settings.global[Settings.godAsyncCreateRequestsPerTick] = { value = 5 }
  settings.global[Settings.godAsyncUpgradeRequestsPerTick] = { value = 5 }
  settings.global[Settings.godAsyncDeleteRequestsPerTick] = { value = 5 }
end)

test("Places ghosts from a blueprint", function()
  local blueprintString = "0eNqFkdFqhDAQRf9lnuOi2WbB/EopQd3RDsRRkrjUSv69iQtSikvzNrlzz51MNmjtgrMjDqA3oG5iD/p9A08DNzbfcTMiaECLXXDUFcjohrVIDnR90yFEAcR3/AJdRXHibGkoDvc82d8OGT8EIAcKhM/gvVgNL2OLLiHFa4yAefLJOXFOS7RSwAq6kDHP8Qckxf8veQEs07zt0vfojKfvhKjK45wkXY8k4p44SUX3iT6c4C9qD5AXta/k2W08hkA8+NzlcJweaJak2TQm3g0FHJMU3IIxby/XeT3HPwp4oPN7irrJ+q2ulZLqdpVVjD/mj6gB"
  player.cursor_stack.import_stack(blueprintString)
  player.cursor_stack.build_blueprint({
    surface = player.surface.name,
    force = player.force.name,
    position = { 6, 6 },
    skip_fog_of_war = false, -- This works BACKWARDS??
    raise_built = true,
  })
  player.cursor_stack.clear()
end)

test("Revives the ghosts after the configured ticks have passed", function()
  TestHelpers.CheckGhostCounts(player.surface, 3)
  TestHelpers.CheckEntityCounts(player.surface, 3)
  after_ticks(20, function()
    TestHelpers.CheckGhostCounts(player.surface, 0)
    TestHelpers.CheckEntityCounts(player.surface, 6)
  end)
end)

test("Cannot place labs", function()
  player.surface.create_entity({
    name = "lab",
    position = { 10, 10 },
    force = player.force,
    raise_built = true,
  })
  TestHelpers.CheckGhostCounts(player.surface, 0)
  TestHelpers.CheckEntityCounts(player.surface, 6)
end)

test("Cannot place labs, even as ghosts", function()
  player.surface.create_entity({
    name = "entity-ghost",
    inner_name = "lab",
    position = { 10, 10 },
    force = player.force,
    raise_built = true,
  })
  TestHelpers.CheckGhostCounts(player.surface, 0)
  TestHelpers.CheckEntityCounts(player.surface, 6)
end)

test("Can place something else", function()
  player.surface.create_entity({
    name = "infinity-chest",
    position = { 10, 10 },
    force = player.force,
    raise_built = true,
  })
  TestHelpers.CheckGhostCounts(player.surface, 0)
  TestHelpers.CheckEntityCounts(player.surface, 7)
end)