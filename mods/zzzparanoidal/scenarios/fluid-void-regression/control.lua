-- Run with --test-scenario zzzparanoidal/fluid-void-regression.
script.on_event(defines.events.on_tick, function(event)
  if not storage.rigs then
    local surface = game.create_surface("fluid-void-regression", { width = 256, height = 256 })
    surface.generate_with_lab_tiles = true
    surface.request_to_generate_chunks({ 0, 0 }, 2)
    surface.force_generate_chunk_requests()
    storage.rigs, storage.started = {}, event.tick
    for i, fluid in ipairs({ "angels-gas-nitrogen", "angels-gas-oxygen", "angels-gas-hydrogen", "water" }) do
      local name = fluid == "water" and "angels-clarifier" or "angels-flare-stack"
      local category = fluid == "water" and "angels-water-void" or "angels-chemical-void"
      for n, direction in ipairs({ defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west }) do
        local entity = assert(surface.create_entity({
          name = name, position = { i * 16, n * 16 }, direction = direction, force = "player",
        }))
        local initial = entity.insert_fluid({ name = fluid, amount = 1000 })
        assert(initial == 1000, "The voider must receive its fluid")
        storage.rigs[#storage.rigs + 1] = {
          entity = entity, fluid = fluid, initial = initial, recipe = category .. "-" .. fluid,
        }
      end
    end
  end

  for _, rig in ipairs(storage.rigs) do rig.entity.energy = 1000000 end
  if event.tick - storage.started < 180 then return end
  for _, rig in ipairs(storage.rigs) do
    local entity, label = rig.entity, rig.entity.name .. ": " .. rig.fluid .. ", direction " .. rig.entity.direction
    assert(entity.get_fluid_count(rig.fluid) < rig.initial, "Fluid is not consumed by " .. label)
    assert(entity.products_finished > 0, "No voiding cycles completed by " .. label)
    assert(entity.get_recipe().name == rig.recipe, "Wrong automatic recipe in " .. label)
    assert(entity.get_inventory(defines.inventory.crafter_output).is_empty(), "Voiding must not create items: " .. label)
  end
  log("PASS: 16 fluid voiders consume nitrogen, oxygen, hydrogen and water without producing items")
  script.finish_test()
end)
