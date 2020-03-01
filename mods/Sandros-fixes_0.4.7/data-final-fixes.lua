local item = data.raw.item
local item_entity_data = item_entity_data
local fluid = data.raw.fluid
local lab = data.raw.lab
local recipe = data.raw.recipe
local subgroup = data.raw["item-subgroup"]

local function sort_item_entity_data_recipe(item_sort, subgroup)
  if item[item_sort] then
    item[item_sort].subgroup = subgroup
  else
    log("Item " .. item_sort .. " does not exist.")
  end
  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_item_entity_data_recipe_order(item_sort, subgroup, order)
  if item[item_sort] then
    item[item_sort].subgroup = subgroup
    item[item_sort].order = order
  else
    log("Item " .. item_sort .. " does not exist.")
  end
  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
    recipe[item_sort].order = order
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_item_recipe(item_sort, subgroup)
  if item[item_sort] then
    item[item_sort].subgroup = subgroup
  else
    log("Item " .. item_sort .. " does not exist.")
  end
  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_item_recipe_order(item_sort, subgroup, order)
  if item[item_sort] then
    item[item_sort].subgroup = subgroup
    item[item_sort].order = order
  else
    log("Item " .. item_sort .. " does not exist.")
  end
  if recipe[item_sort] then
    recipe[item_sort].subgroup = subgroup
    recipe[item_sort].order = order
  else
    log("Recipe " .. item_sort .. " does not exist.")
  end
end

local function sort_subgroup_order(subgroup_sort, group, order)
  if subgroup[subgroup_sort] then
    subgroup[subgroup_sort].group = group
    subgroup[subgroup_sort].order = order
  else
    log("Subgroup " .. subgroup_sort .. " does not exist.")
  end
end

if mods["ShinyIcons"] then
  if mods["angelsindustries"] then
    if mods["extrabobs"] then
      sort_item_recipe_order("angels-burner-generator-vequip", "shinyvehe3", "a7")
      sort_item_recipe_order("angels-fusion-reactor-vequip", "shinyvehe3", "a8")
      sort_item_recipe_order("angels-heavy-energy-shield-vequip", "shinyvehe4", "a7")
      sort_item_recipe_order("angels-construction-roboport-vequip", "shinyvehe8", "a3")
      sort_item_recipe_order("angels-repair-roboport-vequip", "shinyvehe8", "a4")
    end
  end

  if mods["boblogistics"] then
    if mods["angelspetrochem"] then
      sort_item_recipe_order("bob-valve", "shinyvalve1", "a5")
    end
  end

  if mods["bobwarfare"] then
    sort_item_recipe_order("gate", "shinywalls1", "a[wall]-ba")
    sort_item_recipe_order("reinforced-gate", "shinywalls1", "a[wall]-da")
    item["rocket-silo"].subgroup = "shinywalls1"

    if mods["extrabobs"] then
      if recipe["iron-gates"] then
        sort_item_recipe_order("iron-gates", "shinywalls1", "a[wall]-fa")
      end
    end
  end

  if mods["BotRecaller"] then
    sort_item_recipe_order("logistic-chest-botRecaller","shinyzone1","d1")
  end

  if mods["Clowns-Processing"] then
    sort_item_recipe_order("centrifuge-mk2", "shinynuke1", "d2")
    sort_item_recipe_order("centrifuge-mk3", "shinynuke1", "d3")
  end

  if mods["extendedangels"] then
    if mods["angelsindustries"] then
      data:extend(
        {
          {type = "item-subgroup", name = "shinyangellogchest3", group = "angels-logistics", order = "a5"},
          {type = "item-subgroup", name = "shinyangellogchest4", group = "angels-logistics", order = "a6"},
          {type = "item-subgroup", name = "shinyangellogchest5", group = "angels-logistics", order = "a7"}
        }
      )

      subgroup["angels-warehouses"].group = "angels-logistics"
      subgroup["warehouses-2"].group = "angels-logistics"
      subgroup["warehouses-3"].group = "angels-logistics"
      subgroup["warehouses-4"].group = "angels-logistics"
    else
      data:extend(
        {
          {type = "item-subgroup", name = "shinyangellogchest3", group = "resource-refining", order = "a5"},
          {type = "item-subgroup", name = "shinyangellogchest4", group = "resource-refining", order = "a6"},
          {type = "item-subgroup", name = "shinyangellogchest5", group = "resource-refining", order = "a7"}
        }
      )

      subgroup["angels-warehouses"].group = "resource-refining"
      subgroup["warehouses-2"].group = "resource-refining"
      subgroup["warehouses-3"].group = "resource-refining"
      subgroup["warehouses-4"].group = "resource-refining"
    end

    subgroup["warehouses-2"].order = "az1"
    subgroup["warehouses-3"].order = "az2"
    subgroup["warehouses-4"].order = "az3"

    sort_item_recipe_order("warehouse-mk2", "shinyangelchest1", "a4")
    sort_item_recipe_order("warehouse-mk3", "shinyangelchest1", "a5")
    sort_item_recipe_order("warehouse-mk4", "shinyangelchest1", "a6")

    sort_item_recipe_order("warehouse-passive-provider-mk2", "shinyangellogchest3", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk2", "shinyangellogchest3", "a2")
    sort_item_recipe_order("warehouse-storage-mk2", "shinyangellogchest3", "a3")
    sort_item_recipe_order("warehouse-requester-mk2", "shinyangellogchest3", "a4")

    sort_item_recipe_order("warehouse-passive-provider-mk3", "shinyangellogchest4", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk3", "shinyangellogchest4", "a2")
    sort_item_recipe_order("warehouse-storage-mk3", "shinyangellogchest4", "a3")
    sort_item_recipe_order("warehouse-requester-mk3", "shinyangellogchest4", "a4")

    sort_item_recipe_order("warehouse-passive-provider-mk4", "shinyangellogchest5", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk4", "shinyangellogchest5", "a2")
    sort_item_recipe_order("warehouse-storage-mk4", "shinyangellogchest5", "a3")
    sort_item_recipe_order("warehouse-requester-mk4", "shinyangellogchest5", "a4")

    if mods["buffer-warehouse"] or mods["extendedangels"] then
      sort_item_recipe("angels-warehouse-buffer", "shinyangellogchest2")
      sort_item_recipe_order("warehouse-buffer-mk2", "shinyangellogchest3", "a5")
      sort_item_recipe_order("warehouse-buffer-mk3", "shinyangellogchest4", "a5")
      sort_item_recipe_order("warehouse-buffer-mk4", "shinyangellogchest5", "a5")
    end
  end

  if mods["scattergun_turret"] then
    sort_item_recipe_order("w93-hardened-inserter", "shinyinserter1", "a8")
  end

  if mods["quarry"] then
    subgroup["extraction-machine"].order = "g3"
  end
end

if mods["angelsaddons-smeltingtrain"] then
  if mods["extrabobs"] then
    if subgroup["tank-locomotive"] then
      sort_item_entity_data_recipe_order("smelting-locomotive-1", "tank-locomotive", "c-03[smelting-locomotive-1]")
      sort_item_entity_data_recipe_order(
        "smelting-locomotive-tender",
        "tank-locomotive",
        "c-03[smelting-locomotive-tender]"
      )
      sort_item_entity_data_recipe_order("smelting-wagon-1", "tank-locomotive", "c-04[smelting-wagon-1]")
    end
  end
end

if mods["angelsbioprocessing"] then
  sort_subgroup_order("bio-processing-alien-intermediate", "bio-processing", "ze")
  sort_subgroup_order("bio-processing-paste", "bio-processing", "zf")
  sort_subgroup_order("bio-processing-alien-small", "bio-processing", "zi")
  sort_subgroup_order("bio-processing-alien-pre", "bio-processing", "zh")
end

if mods["Avatars"] then
  subgroup["avatar-intermediate-product"].group = "intermediate-products"
  subgroup["avatar-supporting-structures"].group = "production"
  item["avatar"].subgroup = "avatar-supporting-structures"
  recipe["avatar"].subgroup = "avatar-supporting-structures"

  if mods["angelspetrochem"] then
    fluid["copper-chloride"].subgroup = "petrochem-chlorine"
    fluid["dimethyldichlorosilane"].subgroup = "petrochem-chlorine"
    sort_item_recipe("silicone", "petrochem-chlorine")
  else
    if mods["angelsrefining"] and mods["angelspetrochem"] then
      fluid["copper-chloride"].subgroup = "intermediate-products"
      fluid["dimethyldichlorosilane"].subgroup = "intermediate-products"
    end
    sort_item_recipe("silicone", "intermediate-products")
  end

  if mods["ShinyIcons"] then
    subgroup["avatar-supporting-structures"].order = "y3"
  end
end

if bobmods and bobmods.plates then
  subgroup["bob-gems-ore"].group = "bob-resource-products"
  subgroup["bob-gems-raw"].group = "bob-resource-products"
  subgroup["bob-gems-cut"].group = "bob-resource-products"
  subgroup["bob-gems-polished"].group = "bob-resource-products"
  subgroup["bob-intermediates"].group = "bob-resource-products"
  subgroup["bob-gas-bottle"].group = "bob-resource-products"
  subgroup["bob-empty-gas-bottle"].group = "bob-resource-products"

  if mods["EndgameCombat"] then
    if lab["lab-2"] then
      table.insert(lab["lab-2"].inputs, "biter-flesh")
    end
  end

  if mods["expanded-rocket-payloads"] then
    if lab["lab-2"] then
      table.insert(lab["lab-2"].inputs, "planetary-data")
      table.insert(lab["lab-2"].inputs, "station-science")
    end
  end

  if mods["ShinyIcons"] then
    subgroup["shinygem1"].group = "bob-resource-products"
  else
    sort_item_recipe("grinding-wheel", "bob-intermediates")
    sort_item_recipe("polishing-wheel", "bob-intermediates")
    sort_item_recipe("polishing-compound", "bob-intermediates")
  end
end

if mods["Clowns-Processing"] then
  subgroup["armor"].group = "combat"
end

if mods["EndgameCombat"] then
  if mods["angelspetrochem"] then
    recipe["sticky-cheap"].subgroup = "petrochem-chemistry"
    if recipe["sticky-expensive"] then
      recipe["sticky-expensive"].subgroup = "petrochem-chemistry"
    end
  end
end

if mods["MoreScience-BobAngelsExtension"] then
  item["storage-tank"].order = "a1"
  recipe["storage-tank"].order = "a1"
end

if mods["RampantArsenal"] then
  if mods["extrabobs"] then
    if subgroup["tank-other-vehicle"] then
      sort_item_entity_data_recipe_order("advanced-car-recipe-rampant-arsenal", "tank-other-vehicle", "b-05")
      sort_item_entity_data_recipe_order("nuclear-car-recipe-rampant-arsenal", "tank-other-vehicle", "b-06")
      sort_item_entity_data_recipe_order("nuclear-train-recipe-rampant-arsenal", "tank-locomotive", "b-031")
    end
  end

  if mods["ShinyIcons"] then
    sort_item_entity_data_recipe_order("advanced-tank-recipe-rampant-arsenal", "shinyvehicle1", "b4")
    sort_item_entity_data_recipe_order("nuclear-tank-recipe-rampant-arsenal", "shinyvehicle1", "b5")
  end
end

if mods["tater_spacestation"] then
  subgroup["space-station"].group = "production"

  if mods["ShinyIcons"] then
    subgroup["space-station"].order = "y4"
  end
end
