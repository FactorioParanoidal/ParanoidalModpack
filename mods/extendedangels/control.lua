local migration = require("__flib__.migration")

script.on_configuration_changed(function(config)
  -- Check recipe and technology states and make corrections as needed
  for _, force in pairs(game.forces) do
    local technologies = force.technologies
    local recipes = force.recipes

    recipes["angels-washing-plant-3"].enabled = technologies["angels-water-washing-3"].researched
    recipes["angels-advanced-chemical-plant-3"].enabled = technologies["angels-advanced-chemistry-5"].researched
    recipes["angels-powder-zinc"].enabled = technologies["angels-zinc-smelting-2"].researched
    recipes["angels-gas-argon"].enabled = technologies["angels-nitrogen-processing-1"].researched
    recipes["angels-air-filter-4"].enabled = technologies["angels-advanced-chemistry-4"].researched

    if script.active_mods["Clowns-Processing"] then
      if technologies["phosphorus-processing-2"].researched then
        recipes["angels-solid-disodium-phosphate"].enabled = true
        recipes["angels-solid-tetrasodium-pyrophosphate"].enabled = true
      end
    end

    recipes["angels-hydro-plant-4"].enabled = technologies["angels-water-treatment-4"].researched
    recipes["angels-salination-plant-3"].enabled = technologies["angels-water-treatment-5"].researched
    recipes["angels-ore-crusher-4"].enabled = technologies["angels-advanced-ore-refining-3"].researched
    recipes["angels-ore-floatation-cell-4"].enabled = technologies["angels-advanced-ore-refining-4"].researched

    if technologies["angels-tungsten-smelting-3"].researched then
      recipes["angels-solid-tungsten-trioxide-smelting"].enabled = true
      recipes["angels-pellet-tungsten-smelting-2"].enabled = true
      recipes["angels-solid-sodium-tungstate-smelting"].enabled = true
      recipes["angels-casting-powder-tungsten-3"].enabled = true
    end

    if script.active_mods["angelsbioprocessing"] then
      if technologies["angels-bio-arboretum-2"].researched then
        recipes["angels-bio-generator-temperate-2"].enabled = true
        recipes["angels-bio-generator-swamp-2"].enabled = true
        recipes["angels-bio-generator-desert-2"].enabled = true
        recipes["angels-bio-arboretum-2"].enabled = true
      end

      if technologies["angels-bio-arboretum-3"].researched then
        recipes["angels-bio-generator-temperate-3"].enabled = true
        recipes["angels-bio-generator-swamp-3"].enabled = true
        recipes["angels-bio-generator-desert-3"].enabled = true
        recipes["angels-bio-arboretum-3"].enabled = true
      end

      if technologies["angels-bio-refugium-butchery-2"].researched then
        recipes["angels-bio-butchery-2"].enabled = true
      end

      if technologies["angels-bio-refugium-puffer-4"].researched then
        recipes["angels-bio-refugium-puffer-2"].enabled = true
        recipes["angels-bio-refugium-puffer-3"].enabled = true
      end

      if technologies["angels-bio-refugium-biter-2"].researched then
        recipes["angels-bio-refugium-biter-2"].enabled = true
      end

      if technologies["angels-bio-refugium-biter-3"].researched then
        recipes["angels-bio-refugium-biter-3"].enabled = true
      end

      if technologies["angels-bio-refugium-biter-3"].researched then
        recipes["angels-crop-farm-2"].enabled = true
        recipes["angels-composter-2"].enabled = true
        recipes["angels-bio-processor-2"].enabled = true
      end

      if technologies["angels-bio-pressing-2"].researched then
        recipes["angels-bio-press-2"].enabled = true
        recipes["angels-bio-press-3"].enabled = true
      end
    end
  end

  -- Notify about inventory change if migrating from a version prior to the change
  if
    config.mod_changes
    and config.mod_changes["extendedangels"]
    and config.mod_changes["extendedangels"].old_version
  then
    -- 0.4.3 update
    if not migration.is_newer_version("0.4.2", config.mod_changes["extendedangels"].old_version) then
      game.print({
        "",
        "[",
        { "mod-name.extendedangels" },
        "] ",
        {
          "extendedangels-notifications.legacy-inventory-sizes",
          { "mod-setting-name.extangels-legacy-inventory-sizes" },
        },
      })
    end
  end
end)
