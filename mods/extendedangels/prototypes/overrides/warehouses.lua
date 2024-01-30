if not (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then return end

-- Tech overhaul recipe adjustments
if angelsmods.industries and settings.startup["angels-enable-tech"].value == true then
    bobmods.lib.recipe.replace_ingredient_in_all("brass-gear-wheel", "angels-roller-chain")
    bobmods.lib.recipe.replace_ingredient_in_all("advanced-processing-unit", "circuit-yellow-loaded")
end

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
    if (mods["angelsaddons-storage"] and angelsmods.addons.storage.warehouses) then
        data.raw["container"]["warehouse-mk2"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-passive-provider-mk2"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-active-provider-mk2"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-storage-mk2"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-requester-mk2"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-buffer-mk2"].scale_info_icons = true

        data.raw["container"]["warehouse-mk3"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-passive-provider-mk3"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-active-provider-mk3"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-storage-mk3"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-requester-mk3"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-buffer-mk3"].scale_info_icons = true

        data.raw["container"]["warehouse-mk4"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-passive-provider-mk4"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-active-provider-mk4"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-storage-mk4"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-requester-mk4"].scale_info_icons = true
        data.raw["logistic-container"]["warehouse-buffer-mk4"].scale_info_icons = true
    end
end
