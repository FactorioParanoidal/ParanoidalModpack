if settings.startup["coppermine-bob-module-expensive-beacons"].value then
  bobmods.lib.tech.add_prerequisite("effect-transmission-2", "pollution-create-module-4")
  bobmods.lib.tech.add_prerequisite("effect-transmission-3", "pollution-create-module-8")
  bobmods.lib.recipe.add_ingredient("beacon-2", {"pollution-create-module-4", 20})
  bobmods.lib.recipe.add_ingredient("beacon-3", {"pollution-create-module-8", 20})
end
