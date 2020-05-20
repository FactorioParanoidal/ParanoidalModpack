local armor = data.raw.armor
local ammo = data.raw.ammo
local item = data.raw.item
local item_with_enitity_data = data.raw["item-with-entity-data"]
local fluid = data.raw.fluid
local lab = data.raw.lab
local recipe = data.raw.recipe
local subgroup = data.raw["item-subgroup"]

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
  local any

  if item[item_sort] then
    any = item
  elseif ammo[item_sort] then
    any = ammo
  elseif armor[item_sort] then
    any = armor
  elseif item_with_enitity_data[item_sort] then
    any = item_with_enitity_data
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

if mods["ShinyIcons"] then
  if mods["angelsaddons-crawlertrain"] then
    data:extend({{type = "item-subgroup", name = "shinyangelvehicle2", group = "angels-logistics", order = "b2"}})

    sort_item_recipe_order("crawler-locomotive", "shinyangelvehicle2", "a1")
    sort_item_recipe_order("crawler-locomotive-2", "shinyangelvehicle2", "a2")
    sort_item_recipe_order("crawler-locomotive-3", "shinyangelvehicle2", "a3")
    sort_item_recipe_order("crawler-locomotive-wagon", "shinyangelvehicle2", "a4")
    sort_item_recipe_order("crawler-locomotive-wagon-2", "shinyangelvehicle2", "a5")
    sort_item_recipe_order("crawler-locomotive-wagon-3", "shinyangelvehicle2", "a6")
    sort_item_recipe_order("crawler-wagon", "shinyangelvehicle2", "a7")
    sort_item_recipe_order("crawler-wagon-2", "shinyangelvehicle2", "a8")
    sort_item_recipe_order("crawler-wagon-3", "shinyangelvehicle2", "a8")
    sort_item_recipe_order("crawler-bot-wagon", "shinyangelvehicle2", "a9")
    sort_item_recipe_order("crawler-bot-wagon-2", "shinyangelvehicle2", "b1")
    sort_item_recipe_order("crawler-bot-wagon-3", "shinyangelvehicle2", "b2")
  end

  if mods["angelsaddons-smeltingtrain"] then
    data:extend({{type = "item-subgroup", name = "shinyangelvehicle3", group = "angels-logistics", order = "b3"}})

    sort_item_recipe_order("smelting-locomotive-1", "shinyangelvehicle3", "a1")
    sort_item_recipe_order("smelting-locomotive-1-2", "shinyangelvehicle3", "a2")
    sort_item_recipe_order("smelting-locomotive-1-3", "shinyangelvehicle3", "a3")
    sort_item_recipe_order("smelting-locomotive-tender", "shinyangelvehicle3", "a4")
    sort_item_recipe_order("smelting-locomotive-tender-2", "shinyangelvehicle3", "a5")
    sort_item_recipe_order("smelting-locomotive-tender-3", "shinyangelvehicle3", "a6")
    sort_item_recipe_order("smelting-wagon-1", "shinyangelvehicle3", "a7")
    sort_item_recipe_order("smelting-wagon-1-2", "shinyangelvehicle3", "a8")
    sort_item_recipe_order("smelting-wagon-1-3", "shinyangelvehicle3", "a9")
  end

  if mods["angelsaddons-petrotrain"] then
    data:extend({{type = "item-subgroup", name = "shinyangelvehicle4", group = "angels-logistics", order = "b4"}})

    sort_item_recipe_order("petro-locomotive-1", "shinyangelvehicle4", "a1")
    sort_item_recipe_order("petro-locomotive-1-2", "shinyangelvehicle4", "a2")
    sort_item_recipe_order("petro-locomotive-1-3", "shinyangelvehicle4", "a3")
    sort_item_recipe_order("petro-tank1", "shinyangelvehicle4", "a4")
    sort_item_recipe_order("petro-tank1-2", "shinyangelvehicle4", "a5")
    sort_item_recipe_order("petro-tank1-3", "shinyangelvehicle4", "a6")
    sort_item_recipe_order("petro-tank2", "shinyangelvehicle4", "a7")
    sort_item_recipe_order("petro-tank2-2", "shinyangelvehicle4", "a8")
    sort_item_recipe_order("petro-tank2-3", "shinyangelvehicle4", "a9")
  end

  if mods["angelsexploration"] then
    subgroup["angels-warfare-bullet-guns"].group = "combat"
    subgroup["angels-explosion-b"].group = "combat"
    subgroup["angels-warfare-flamethrower-guns"].group = "combat"
    subgroup["angels-warfare-rocket-guns"].group = "combat"

    if mods["SchallTransportGroup"] then
      subgroup["angels-exploration-vehicles"].group = "transport"
    else
      subgroup["angels-exploration-vehicles"].group = "combat"
    end

    sort_item_recipe_order("gun-cotton", "bob-resource", "f[gun-cotton]")
    sort_item_recipe_order("petroleum-jelly", "bob-resource", "f[petroleum-jelly]")
    sort_item_recipe_order("robot-drone-frame", "intermediate-product", "I[robot-drone-frame-a-1]")
    sort_item_recipe_order("robot-drone-frame-large", "intermediate-product", "I[robot-drone-frame-b-1]")

    sort_item_recipe_order("plasma-bullet", "shinybullets1", "a8")
    sort_item_recipe_order("plasma-bullet-projectile", "shinybullets2", "a8")
    sort_item_recipe_order("plasma-rocket-warhead", "shinybullets3", "a7")
    sort_item_recipe_order("plasma-bullet-magazine", "shinymag1", "b2")
    sort_item_recipe_order("bob-plasma-rocket", "shinymag1", "b2")
    sort_item_recipe_order("shotgun-plasma-shell", "shinyshotgun1", "b2")
    sort_item_recipe_order("laser-rifle-battery", "bob-ammo", "f[laser-rifle-battery]-0")
    sort_item_recipe_order("laser-rifle-battery-ruby", "bob-ammo", "f[laser-rifle-battery]-1")
    sort_item_recipe_order("laser-rifle-battery-sapphire", "bob-ammo", "f[laser-rifle-battery]-2")
    sort_item_recipe_order("laser-rifle-battery-emerald", "bob-ammo", "f[laser-rifle-battery]-3")
    sort_item_recipe_order("laser-rifle-battery-amethyst", "bob-ammo", "f[laser-rifle-battery]-4")
    sort_item_recipe_order("laser-rifle-battery-topaz", "bob-ammo", "f[laser-rifle-battery]-5")
    sort_item_recipe_order("laser-rifle-battery-diamond", "bob-ammo", "f[laser-rifle-battery]-6")
    sort_item_recipe_order("cannon-shell", "ammo", "d[cannon-shell]-a[basic]")
    sort_item_recipe_order("explosive-cannon-shell", "ammo", "d[cannon-shell]-c[explosive]")
    sort_item_recipe_order("uranium-cannon-shell", "ammo", "d[cannon-shell]-c[uranium]")
    sort_item_recipe_order("explosive-uranium-cannon-shell", "ammo", "d[explosive-cannon-shell]-c[uranium]")
    sort_item_recipe_order("fire-artillery-shell", "shinycombat2", "d1")

    sort_item_recipe_order("rifle", "gun", "a[basic-clips]-c[rifle]")
    sort_item_recipe_order("sniper-rifle", "gun", "a[basic-clips]-c[sniper-rifle]")
    sort_item_recipe_order("laser-rifle", "gun", "b[laser-rifle]")
    sort_item_recipe_order("fire-capsule", "capsule", "b[fire-capsule]")
    sort_item_recipe_order("bob-robot-gun-drone", "bob-combat-robots", "b[drone]-a[gun-1]")
    sort_item_recipe_order("bob-robot-laser-drone", "bob-combat-robots", "b[drone]-b[laser-1]")
    sort_item_recipe_order("bob-robot-flamethrower-drone", "bob-combat-robots", "b[drone]-c[flamethrower-1]")
    sort_item_recipe_order("bob-robot-plasma-drone", "bob-combat-robots", "b[drone]-d[plasma-1]")

    sort_item_recipe_order("bob-plasma-turret-1", "defensive-structure", "b[turret]-b[plasma-turret-1]")
    sort_item_recipe_order("bob-plasma-turret-2", "defensive-structure", "b[turret]-b[plasma-turret-2]")
    sort_item_recipe_order("bob-plasma-turret-3", "defensive-structure", "b[turret]-b[plasma-turret-3]")
    sort_item_recipe_order("bob-plasma-turret-4", "defensive-structure", "b[turret]-b[plasma-turret-4]")
    sort_item_recipe_order("bob-plasma-turret-5", "defensive-structure", "b[turret]-b[plasma-turret-5]")
    sort_item_recipe_order("wall-0", "shinywalls1", "a[wall]-a[basic-wall]")

    sort_item_recipe_order("light-armor", "armor", "a[light-armor]")
    sort_item_recipe_order("heavy-armor", "armor", "b[heavy-armor]")
    sort_item_recipe_order("heavy-armor-2", "armor", "c[heavy-armor-2]")
    sort_item_recipe_order("heavy-armor-3", "armor", "c[heavy-armor-3]")
    sort_item_recipe_order("modular-armor", "armor", "c[modular-armor]")
    sort_item_recipe_order("power-armor", "armor", "d[power-armor]")
    sort_item_recipe_order("power-armor-mk2", "armor", "e[power-armor-mk2]")
    sort_item_recipe_order("bob-power-armor-mk3", "armor", "f[power-armor-mk3]")
    sort_item_recipe_order("bob-power-armor-mk4", "armor", "g[power-armor-mk4]")
    sort_item_recipe_order("bob-power-armor-mk5", "armor", "h[power-armor-mk5]")
  end

  if mods["angelsindustries"] then
    if mods["extrabobs"] then
      sort_item_recipe_order("angels-burner-generator-vequip", "shinyvehe3", "a7")
      sort_item_recipe_order("angels-fusion-reactor-vequip", "shinyvehe3", "a8")
      sort_item_recipe_order("angels-heavy-energy-shield-vequip", "shinyvehe4", "a7")
      sort_item_recipe_order("angels-construction-roboport-vequip", "shinyvehe8", "a3")
      if mods["angelsaddons-cab"] then
        sort_item_recipe_order("angels-cab-energy-interface-mk1", "shinyvehe8", "a4")
        sort_item_recipe_order("angels-cab-deploy-charge", "angels-vehicles", "c-z1")
        sort_item_recipe_order("angels-cab-undeploy-charge", "angels-vehicles", "c-z2")
      end
      sort_item_recipe_order("angels-repair-roboport-vequip", "shinyvehe8", "a5")
    end
  end

  if mods["angelsexploration"] then
    subgroup["angels-vehicle-equipment-bobrobot-a"].group = "combat"
    subgroup["angels-vehicle-equipment-bobrobot-b"].group = "combat"
    subgroup["angels-vehicle-equipment-bobrobot-c"].group = "combat"
    subgroup["angels-vehicle-equipment-bobrobot-d"].group = "combat"
  end

  if mods["angelsrefining"] then
    subgroup["angels-power-nuclear-reactor-a"].group = "production"
    subgroup["angels-power-nuclear-processing"].group = "production"
    subgroup["clowns-nuclear-fuels"].group = "production"
    subgroup["clowns-nuclear-cells"].group = "production"
    subgroup["clowns-uranium-centrifuging"].group = "production"

    subgroup["bob-fluid"].group = "bob-intermediate-products"
    subgroup["bob-fluid-electrolysis"].group = "bob-intermediate-products"
    subgroup["bob-resource"].group = "bob-intermediate-products"
    subgroup["bob-resource-chemical"].group = "bob-intermediate-products"
    subgroup["bob-material-chemical"].group = "bob-intermediate-products"


    sort_item_recipe_order("iron-stick", "intermediate-product", "b")
    sort_item_recipe_order("engine-unit", "intermediate-product", "b")
    sort_item_recipe_order("electric-engine-unit", "intermediate-product", "c")

    sort_item_recipe_order("basic-electronic-components", "bob-electronic-components", "0-b1[basic-electronic-components]")
    sort_item_recipe_order("electronic-components", "bob-electronic-components", "0-b2[electronic-components]")
    sort_item_recipe_order("intergrated-electronics", "bob-electronic-components", "0-b3[intergrated-components]")
    sort_item_recipe_order("processing-electronics", "bob-electronic-components", "0-b4[processing-electronics]")

    sort_item_recipe_order("repair-pack-2", "tool", "a2")
    sort_item_recipe_order("repair-pack-3", "tool", "a3")
    sort_item_recipe_order("repair-pack-4", "tool", "a4")
    sort_item_recipe_order("repair-pack-5", "tool", "a5")
  end

  if mods["boblogistics"] then
    if mods["angelspetrochem"] then sort_item_recipe_order("bob-valve", "shinyvalve1", "a5") end
  end

  if mods["bobpower"] then
    sort_item_recipe_order("heat-pipe-2", "shinynuke1", "e2")
    sort_item_recipe_order("heat-pipe-3", "shinynuke1", "e3")
    sort_item_recipe_order("nuclear-reactor-2", "shinynuke1", "c2")
    sort_item_recipe_order("nuclear-reactor-3", "shinynuke1", "c3")

    sort_item_recipe_order("bob-burner-generator", "shinysteam1", "b-2")
    sort_item_recipe_order("oil-boiler", "shinysteam1", "d-1")
    sort_item_recipe_order("oil-boiler-2", "shinysteam1", "d-1")
    sort_item_recipe_order("oil-boiler-3", "shinysteam1", "d-1")
    sort_item_recipe_order("oil-boiler-4", "shinysteam1", "d-1")
  end

  if mods["bobplates"] then
    sort_item_recipe_order("lithium-ion-battery", "bob-intermediates", "h[battery]-b")
    sort_item_recipe_order("silver-zinc-battery", "bob-intermediates", "h[battery]-c")
  end

  if mods["bobwarfare"] then
    sort_item_recipe_order("gate", "shinywalls1", "a[wall]-ba")
    sort_item_recipe_order("reinforced-gate", "shinywalls1", "a[wall]-da")
    sort_item_recipe_order("atomic-artillery-shell", "shinycombat2", "e3")

    item["rocket-silo"].subgroup = "shinywalls1"

    if mods["extrabobs"] then
      if recipe["iron-gates"] then sort_item_recipe_order("iron-gates", "shinywalls1", "a[wall]-fa") end
    end
  end

  if mods["BotRecaller"] then sort_item_recipe_order("logistic-chest-botRecaller", "shinyzone1", "d1") end

  if mods["Clowns-Nuclear"] then
    sort_item_recipe_order("artillery-shell-nuclear", "shinycombat2", "e1")
    sort_item_recipe_order("artillery-shell-thermonuclear", "shinycombat2", "e2")    

    sort_item_recipe_order("Schall-poison-bomb", "shinyrocket1", "a7-1")
  end

  if mods["Clowns-Processing"] then
    sort_item_recipe_order("centrifuge-mk2", "shinynuke1", "d2")
    sort_item_recipe_order("centrifuge-mk3", "shinynuke1", "d3")
  end

  if mods["extendedangels"] and mods["angelsaddons-warehouses"] then
    local warehouse_group = "resource-refining"

    if mods["angelsindustries"] then
      warehouse_group = "angels-logistics"
    end

    data:extend({
      {type = "item-subgroup", name = "shinyangellogchest7", group = warehouse_group, order = "z3"},
      {type = "item-subgroup", name = "shinyangellogchest8", group = warehouse_group, order = "z4"},
      {type = "item-subgroup", name = "shinyangellogchest9", group = warehouse_group, order = "z5"}
    })

    subgroup["angels-warehouses"].group = warehouse_group
    subgroup["angels-warehouses-2"].group = warehouse_group
    subgroup["angels-warehouses-3"].group = warehouse_group
    subgroup["angels-warehouses-4"].group = warehouse_group

    subgroup["angels-warehouses-2"].order = "az1"
    subgroup["angels-warehouses-3"].order = "az2"
    subgroup["angels-warehouses-4"].order = "az3"

    sort_item_recipe_order("warehouse-mk2", "shinyangelchest1", "a4")
    sort_item_recipe_order("warehouse-mk3", "shinyangelchest1", "a5")
    sort_item_recipe_order("angels-warehouse-buffer", "shinyangellogchest6", "a5")
    sort_item_recipe_order("warehouse-mk4", "shinyangelchest1", "a6")

    sort_item_recipe_order("warehouse-passive-provider-mk2", "shinyangellogchest7", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk2", "shinyangellogchest7", "a2")
    sort_item_recipe_order("warehouse-storage-mk2", "shinyangellogchest7", "a3")
    sort_item_recipe_order("warehouse-requester-mk2", "shinyangellogchest7", "a4")
    sort_item_recipe_order("warehouse-buffer-mk2", "shinyangellogchest7", "a5")

    sort_item_recipe_order("warehouse-passive-provider-mk3", "shinyangellogchest8", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk3", "shinyangellogchest8", "a2")
    sort_item_recipe_order("warehouse-storage-mk3", "shinyangellogchest8", "a3")
    sort_item_recipe_order("warehouse-requester-mk3", "shinyangellogchest8", "a4")
    sort_item_recipe_order("warehouse-buffer-mk3", "shinyangellogchest8", "a5")

    sort_item_recipe_order("warehouse-passive-provider-mk4", "shinyangellogchest9", "a1")
    sort_item_recipe_order("warehouse-active-provider-mk4", "shinyangellogchest9", "a2")
    sort_item_recipe_order("warehouse-storage-mk4", "shinyangellogchest9", "a3")
    sort_item_recipe_order("warehouse-requester-mk4", "shinyangellogchest9", "a4")
    sort_item_recipe_order("warehouse-buffer-mk4", "shinyangellogchest9", "a5")
  end

  if mods["scattergun_turret"] then
    sort_item_recipe_order("w93-hardened-inserter", "shinyinserter1", "a8")
    sort_item_recipe_order("w93-uranium-shotgun-shell", "shinyshotgun1", "b2")
    sort_item_recipe_order("w93-slowdown-magazine", "shinymag1", "a2-2")
  end

  if mods["SchallArtillery"] and mods["bobwarfare"] then
    sort_item_recipe_order("Schall-cluster-artillery-shell", "shinycombat2", "f1")
    sort_item_recipe_order("Schall-napalm-artillery-shell", "shinycombat2", "f2")
    sort_item_recipe_order("Schall-poison-artillery-shell", "shinycombat2", "f3")
    sort_item_recipe_order("Schall-atomic-artillery-shell", "shinycombat2", "f4")
  end

  if mods["SchallTankPlatoon"] then
    sort_item_recipe_order("Schall-sniper-firearm-magazine", "shinymag1", "a1-1")
    sort_item_recipe_order("Schall-sniper-piercing-rounds-magazine", "shinymag1", "a2-2")
    sort_item_recipe_order("Schall-sniper-uranium-rounds-magazine", "shinymag1", "b1-1")
    sort_item_recipe_order("Schall-concrete-wall", "shinywalls1", "a[wall]-ca")
    sort_item_recipe_order("Schall-concrete-gate", "shinywalls1", "a[wall]-cb")
    sort_item_recipe_order("Schall-uranium-wall", "shinywalls1", "a[wall]-ea")
    sort_item_recipe_order("Schall-uranium-gate", "shinywalls1", "a[wall]-eb")
    sort_item_recipe_order("Schall-poison-bomb", "shinyrocket1", "a7-1")
    sort_item_recipe_order("Schall-incendiary-rocket", "shinyrocket1", "b2")
    sort_item_recipe_order("Schall-napalm-bomb", "shinyrocket1", "b3")
  end

  if mods["PCPRedux"] then sort_item_recipe_order("plaswall", "shinywalls1", "b1") end

  if mods["quarry"] then subgroup["extraction-machine"].order = "g3" end

else
  -- no ShinyBobs
  if mods["angelsindustries"] then
    subgroup["bob-intermediates"].group = "intermediate-products"
    subgroup["bob-boards"].group = "intermediate-products"
    subgroup["bob-electronic-boards"].group = "intermediate-products"

    subgroup["angels-basic-intermediate"].group = "intermediate-products"
    subgroup["angels-circuit-components"].group = "intermediate-products"

    subgroup["bob-resource"].group = "intermediate-products"
    subgroup["bob-fluid"].group = "petrochem-refining"
    subgroup["bob-fluid-electrolysis"].group = "petrochem-refining"
    subgroup["bob-resource-chemical"].group = "petrochem-refining"
  end
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

  if mods["ShinyIcons"] then subgroup["avatar-supporting-structures"].order = "y3" end
end

-- if bobmods and bobmods.plates then
--   subgroup["bob-gems-ore"].group = "bob-resource-products"
--   subgroup["bob-gems-raw"].group = "bob-resource-products"
--   subgroup["bob-gems-cut"].group = "bob-resource-products"
--   subgroup["bob-gems-polished"].group = "bob-resource-products"
--   subgroup["bob-intermediates"].group = "bob-resource-products"
--   subgroup["bob-gas-bottle"].group = "bob-resource-products"
--   subgroup["bob-empty-gas-bottle"].group = "bob-resource-products"

--   if mods["EndgameCombat"] then if lab["lab-2"] then table.insert(lab["lab-2"].inputs, "biter-flesh") end end

--   if mods["expanded-rocket-payloads"] then
--     if lab["lab-2"] then
--       table.insert(lab["lab-2"].inputs, "planetary-data")
--       table.insert(lab["lab-2"].inputs, "station-science")
--     end
--   end

--   if mods["ShinyIcons"] then
--     subgroup["shinygem1"].group = "bob-resource-products"
--   else
--     sort_item_recipe("grinding-wheel", "bob-intermediates")
--     sort_item_recipe("polishing-wheel", "bob-intermediates")
--     sort_item_recipe("polishing-compound", "bob-intermediates")
--   end
-- end

if mods["Clowns-Processing"] then subgroup["armor"].group = "combat" end

if mods["EndgameCombat"] then
  if mods["angelspetrochem"] then
    recipe["sticky-cheap"].subgroup = "petrochem-chemistry"
    if recipe["sticky-expensive"] then recipe["sticky-expensive"].subgroup = "petrochem-chemistry" end
  end
end

if mods["MoreScience-BobAngelsExtension"] then
  item["storage-tank"].order = "a1"
  recipe["storage-tank"].order = "a1"
end

if mods["RampantArsenal"] then
  if mods["extrabobs"] then
    if subgroup["tank-other-vehicle"] then
      sort_item_recipe_order("advanced-car-recipe-rampant-arsenal", "tank-other-vehicle", "b-05")
      sort_item_recipe_order("nuclear-car-recipe-rampant-arsenal", "tank-other-vehicle", "b-06")
      sort_item_recipe_order("nuclear-train-recipe-rampant-arsenal", "tank-locomotive", "b-031")
    end
  end

  if mods["ShinyIcons"] then
    sort_item_recipe_order("advanced-tank-recipe-rampant-arsenal", "shinyvehicle1", "b4")
    sort_item_recipe_order("nuclear-tank-recipe-rampant-arsenal", "shinyvehicle1", "b5")
  end
end

if mods["tater_spacestation"] then
  subgroup["space-station"].group = "production"

  if mods["ShinyIcons"] then subgroup["space-station"].order = "y4" end
end

--DrD
if mods["angelsrefining"] then
      sort_item_recipe_order("angelsore7-crystallization-3", "intermediate-product", "aa1")
      sort_item_recipe_order("angelsore7-crystallization-1", "intermediate-product", "aa2")
	  sort_item_recipe_order("angelsore7-crystallization-4", "intermediate-product", "aa3")
	  sort_item_recipe_order("angelsore7-crystallization-5", "intermediate-product", "aa4")
	  sort_item_recipe_order("angelsore7-crystallization-2", "intermediate-product", "aa5")
	  sort_item_recipe_order("angelsore7-crystallization-6", "intermediate-product", "aa6")
end