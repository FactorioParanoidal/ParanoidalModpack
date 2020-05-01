if settings.startup["coppermine-bob-module-expensive-beacons"].value then
  local dep1 = nil
  local dep2 = nil

  if data.raw.module["pollution-create-module-8"] then
    dep1 = "pollution-create-module-4"
    dep2 = "pollution-create-module-8"
  elseif data.raw.module["effectivity-module-8"] then
    -- This falback is used e.g. when CircuitProcessing mod is active
    dep1 = "effectivity-module-4"
    dep2 = "effectivity-module-8"
  end

  if dep1 then
    bobmods.lib.tech.add_prerequisite("effect-transmission-2", dep1)
    bobmods.lib.tech.add_prerequisite("effect-transmission-3", dep2)
    bobmods.lib.recipe.add_ingredient("beacon-2", {dep1, 20})
    bobmods.lib.recipe.add_ingredient("beacon-3", {dep2, 20})
  end
end
