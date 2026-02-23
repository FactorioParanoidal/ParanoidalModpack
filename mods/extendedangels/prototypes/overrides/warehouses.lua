if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then
  return
end

-- Tech overhaul recipe adjustments
--[[ Angels industries already has replacements for these as far as i can tell
if angelsmods.industries and settings.startup["angels-enable-tech"].value == true then
  bobmods.lib.recipe.replace_ingredient_in_all("brass-gear-wheel", "angels-roller-chain")
  bobmods.lib.recipe.replace_ingredient_in_all("advanced-processing-unit", "circuit-yellow-loaded")
end]]

-- Group with Industries logistics tab
if angelsmods.industries then
  data.raw["item-subgroup"]["angels-warehouses-2"].group = "angels-logistics"
  data.raw["item-subgroup"]["angels-warehouses-3"].group = "angels-logistics"
  data.raw["item-subgroup"]["angels-warehouses-4"].group = "angels-logistics"
  data.raw["item-subgroup"]["angels-warehouses-2"].order = "ad[chests-warehouse]"
  data.raw["item-subgroup"]["angels-warehouses-3"].order = "ad[chests-warehouse]"
  data.raw["item-subgroup"]["angels-warehouses-4"].order = "ad[chests-warehouse]"
end

-- Icon scaling
if angelsmods.addons.storage.icon_scaling then
  if mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses then
    data.raw["container"]["angels-warehouse-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-passive-provider-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-active-provider-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-storage-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-requester-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-buffer-mk2"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }

    data.raw["container"]["angels-warehouse-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-passive-provider-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-active-provider-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-storage-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-requester-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-buffer-mk3"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }

    data.raw["container"]["angels-warehouse-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-passive-provider-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-active-provider-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-storage-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-requester-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
    data.raw["logistic-container"]["angels-warehouse-buffer-mk4"].icon_draw_specification = {
      scale = 3.5,
      scale_for_many = 3.5,
    }
  end
end
