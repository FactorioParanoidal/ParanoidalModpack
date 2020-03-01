-- log("CBMR.RCU")
if settings.startup["coppermine-bob-module-modules-in-rocket"].value then
  -- log("CBMR.RCU active")
  -- First we remove any existing module ingredients
  -- (these are all the different module ingredients I know of any mod adding)
  bobmods.lib.recipe.remove_ingredient("rocket-control-unit", "speed-module")
  bobmods.lib.recipe.remove_ingredient("rocket-control-unit", "speed-module-3")
  bobmods.lib.recipe.remove_ingredient("rocket-control-unit", "speed-module-8")
  bobmods.lib.recipe.remove_ingredient("rocket-control-unit", "raw-speed-module-8")
  bobmods.lib.recipe.remove_ingredient("rocket-control-unit", "god-module-5")
  bobmods.lib.tech.remove_prerequisite("rocket-control-unit", "speed-module")

  -- Now put in either raw speed or speed
  if data.raw["module"]["raw-speed-module-8"] then
    -- log("Adding raw speed 8")
    -- log(serpent.block(bobmods.lib.item.basic_item("raw-speed-module-8")))
    -- log(serpent.block(bobmods.lib.item.item("raw-speed-module-8")))
    bobmods.lib.recipe.add_ingredient("rocket-control-unit", { "raw-speed-module-8", 1 })
    bobmods.lib.tech.add_prerequisite("rocket-control-unit", "raw-speed-module-8")
    -- log(serpent.block(data.raw.recipe["rocket-control-unit"]))
  elseif data.raw["module"]["speed-module-8"] then
    -- log("Adding speed 8")
    bobmods.lib.recipe.add_ingredient("rocket-control-unit", "speed-module-8")
    bobmods.lib.tech.add_prerequisite("rocket-control-unit", "speed-module-8")
  else
    -- log("Could not find appropriate module to add to rocket control unit recipe")
  end
end
