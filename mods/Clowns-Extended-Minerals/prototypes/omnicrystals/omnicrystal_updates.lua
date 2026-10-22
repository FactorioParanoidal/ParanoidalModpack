if mods["omnimatter_crystal"] then
  require("__omnimatter_crystal__.prototypes.crystal-making")
  if mods["bobplates"] then
    omni.crystal.add_crystal("angels-solid-lithium", "Lithium Chloride")
  end
  omni.crystal.add_crystal("angels-solid-calcium-sulfate", "Calcium Sulfate")
  omni.crystal.add_crystal("angels-thorium-ore", "Thorium")
  omni.crystal.add_crystal("clowns-phosphorus-ore", "Phosphorus")
  omni.crystal.add_crystal("angels-solid-limestone", "Limestone")
  omni.crystal.add_crystal("angels-solid-sodium-carbonate", "Sodium Carbonate")
  omni.crystal.add_crystal("clowns-osmium-ore", "Osmium")
  omni.crystal.add_crystal("clowns-magnesium-ore", "Magnesium")
  omni.crystal.add_crystal("angels-slag", "Slag")
  if mods["pycoalprocessing"] then
    --add_crystal("raw-borax", "Raw Borax")
    --add_crystal("nexelit-ore", "Nexelit")
    --add_crystal("niobium-ore", "Niobium")
    omni.crystal.add_crystal("rare-earth-dust", "Rare Earth Dust")
    omni.crystal.add_crystal("molybdenum-ore", "Molybdenum")
    if mods["PyCoalTBaA"] then
      omni.crystal.add_crystal("angels-sodium-carbonate", "Sodium Carbonate")
    end
  end
  local oresList = {
    { ore = "clowns-ore1", name = "Adamantite" },
    { ore = "clowns-ore4", name = "Orichalcite" },
    { ore = "clowns-ore5", name = "Phosphorite" },
    { ore = "clowns-ore7", name = "Elionagate" }
  }
  if not clowns.special_vanilla then
    table.insert(oresList, { ore = "clowns-ore2", name = "Antitate" })
    table.insert(oresList, { ore = "clowns-ore3", name = "Pro-Galena" })
    table.insert(oresList, { ore = "clowns-ore6", name = "Sanguinate" })
    table.insert(oresList, { ore = "clowns-ore8", name = "Meta-Garnierite" })
    table.insert(oresList, { ore = "clowns-ore9", name = "Nova-Leucoxene" })
  end
  -- icon updates
  if mods["bobplates"] then
    icon_fixes = {
      ["angels-solid-lithium"] = "solid-lithium-crystal",
      ["angels-solid-sodium-carbonate"] = "solid-sodium-carbonate-crystal",
      ["angels-solid-calcium-sulfate"] = "solid-calcium-sulfate-crystal",
      ["angels-solid-limestone"] = "solid-limestone-crystal",
      ["clowns-phosphorus-ore"] = "phosphorus-ore-crystal",
      ["clowns-osmium-ore"] = "osmium-ore-crystal",
      ["clowns-magnesium-ore"] = "magnesium-ore-crystal",
      ["angels-slag"] = "solid-limestone-crystal",
    }
  else
    icon_fixes = {
      ["angels-solid-sodium-carbonate"] = "solid-sodium-carbonate-crystal",
      ["angels-solid-calcium-sulfate"] = "solid-calcium-sulfate-crystal",
      ["angels-solid-limestone"] = "solid-limestone-crystal",
      ["clowns-phosphorus-ore"] = "phosphorus-ore-crystal",
      ["clowns-osmium-ore"] = "osmium-ore-crystal",
      ["clowns-magnesium-ore"] = "magnesium-ore-crystal",
      ["angels-slag"] = "solid-limestone-crystal",
    }
  end

  for i, k in pairs(icon_fixes) do
    data.raw.item[i .. "-crystal"].icons = { { icon = "__Clowns-Extended-Minerals__/graphics/icons/omnicrystals/" .. k .. ".png", icon_size = 32, } }
    data.raw.recipe[i .. "-crystal"].icons = { { icon = "__Clowns-Extended-Minerals__/graphics/icons/omnicrystals/" .. k .. ".png", icon_size = 32, } }
  end
  --duplicate local functions as needed
  local function ingrediences_solvation(recipe)
    local ing = {}
    ing[#ing + 1] = { type = "fluid", name = "hydromnic-acid", amount = 120 }
    for _, i in pairs(recipe.ingredients) do
      if i.name ~= "catalysator-brown" then
        ing[#ing + 1] = i
      end
    end
    return ing
  end

  local function results_solvation(recipe)
    local ing = {}
    --ing[#ing+1]={type = "fluid", name = "hydromnic-acid", amount = 120}
    for _, i in pairs(recipe.results) do
      if i.name ~= "slag" then
        ing[#ing + 1] = { type = "item", name = i.name .. "-omnide-salt", amount = 5 * i.amount }
      end
    end
    return ing
  end
  local function salt_omnide_icon(metal)
    local nr = 5
    --Build the icons table
    local icons = {}
    local icon_2 = "__omnimatter_crystal__/graphics/icons/omnide-salt.png" --if some error occurs
    if data.raw.item[metal] and data.raw.item[metal].icon then
      icon_2 = data.raw.item[metal].icon
    elseif data.raw.item[metal].icons and data.raw.item[metal].icons[1].icon then
      icon_2 = data.raw.item[metal].icons[1].icon
    end
    icons[#icons + 1] = { icon = "__omnimatter_crystal__/graphics/icons/omnide-salt.png", icon_size = 32 }
    icons[#icons + 1] = {
      icon = icon_2,
      icon_size = get_ore_ic_size(metal),
      scale = 0.4 * 32 / get_ore_ic_size(metal),
      shift = { -10, 10 }
    }
    return icons
  end
  --convert these two tables to be more flexible, so i can deal with regular/advanced lists
  local toAdd = {}
  local toTech = {}
  local oresGrade = { "crushed", "chunk", "crystal", "pure" }
  local pureOresList = { --[["angels-chrome",]] "clowns-osmium", "clowns-phosphorus", --[["angels-platinum", "angels-thorium", "angels-manganese",]]
    "clowns-magnesium" }

  for _, oreSet in pairs(oresList) do
    for _, gradeSet in pairs(oresGrade) do
      local baseName = oreSet.ore .. "-" .. gradeSet .. "-processing"
      local base = data.raw.recipe[baseName]

      if not data.raw["item-subgroup"][base.subgroup .. "-omnide"] then
        local cat = {
          type = "item-subgroup",
          name = base.subgroup .. "-omnide",
          group = "omnicrystal",
          order = "aa",
        }
        toAdd[#toAdd + 1] = cat
      end
      local ing = table.deepcopy(ingrediences_solvation(base))
      local res = table.deepcopy(results_solvation(base))
      local ic = salt_omnide_icon(oreSet.ore .. "-" .. gradeSet)
      toAdd[#toAdd + 1] = {
        type = "recipe",
        name = oreSet.ore .. "-" .. gradeSet .. "-salting",
        localised_name = { "recipe-name.clowns-omnide-salting", { "lookup." .. gradeSet }, oreSet.name },
        localised_description = { "recipe-description.clowns-omnide-salting", { "lookup." .. gradeSet }, oreSet.name },
        category = "omniplant",
        subgroup = base.subgroup .. "-omnide",
        enabled = false,
        ingredients = ing,
        order = "b[clownsore1-crushed]",
        icons = ic,
        icon_size = 32,
        results = res,
        energy_required = 5,
      }
      if gradeSet == "crushed" then
        toTech[#toTech + 1] = { "omnitech-crystallology-1", oreSet.ore .. "-" .. gradeSet .. "-salting" }
      elseif gradeSet == "chunk" then
        toTech[#toTech + 1] = { "omnitech-crystallology-2", oreSet.ore .. "-" .. gradeSet .. "-salting" }
      elseif gradeSet == "crystal" then
        toTech[#toTech + 1] = { "omnitech-crystallology-3", oreSet.ore .. "-" .. gradeSet .. "-salting" }
      elseif gradeSet == "pure" then
        toTech[#toTech + 1] = { "omnitech-crystallology-4", oreSet.ore .. "-" .. gradeSet .. "-salting" }
      end
    end
  end
  --old additions list, where rec name is [ore.."-pure-processing"]

  if not clowns.special_vanilla then
    for _, ore in pairs(pureOresList) do
      if not data.raw.item[ore .. "-ore-omnide-salt"] then
        omni.crystal.add_crystal(ore .. "-ore", ore:gsub("^%l", string.upper)) --incase it is missing
      end
      local rec = data.raw.recipe[ore .. "-pure-processing"]
      if rec then
        local gradeSet = get_grade_set(rec)
        if not data.raw["item-subgroup"][rec.subgroup .. "-omnide"] then
          local cat = {
            type = "item-subgroup",
            name = rec.subgroup .. "-omnide",
            group = "omnicrystal",
            order = "aa",
          }
          toAdd[#toAdd + 1] = cat
        end
        local ing = table.deepcopy(ingrediences_solvation(rec))
        local res = table.deepcopy(results_solvation(rec))
        local ic = salt_omnide_icon(ore .. "-ore")
        toAdd[#toAdd + 1] = {
          type = "recipe",
          name = ore .. "-pure-salting",
          localised_name = { "recipe-name.pure-omnide-salting", { "lookup." .. ore } },
          localised_description = { "recipe-description.pure-omnide-salting", { "lookup." .. ore } },
          category = "omniplant",
          subgroup = rec.subgroup .. "-omnide",
          enabled = false,
          ingredients = ing,
          order = "b[clownsore1-crushed]",
          icons = ic,
          results = res,
          energy_required = 5,
        }
        local techlvl = 3 --set at 3 for odd stuff
        if gradeSet == "crushed" then
          techlvl = 1
        elseif gradeSet == "chunk" then
          techlvl = 2
        elseif gradeSet == "crystal" then
          techlvl = 3
        elseif gradeSet == "pure" then
          techlvl = 4
        end

        for _, each in pairs({ "-crystal", "-omnide-solution", "-crystal-omnitraction", "-pure-salting" }) do
          toTech[#toTech + 1] = { "omnitech-crystallology-" .. techlvl, ore .. "-ore" .. each }
        end
      end
    end
    data:extend(toAdd)
    --new additions list where name is clowns-tier-mix#-processing
    toAdd = {}                         --nil it out
    for i, tier in pairs(oresGrade) do --grade
      for j = 1, 12, 1 do              --number
        local rec = data.raw.recipe["clowns-" .. tier .. "-mix" .. j .. "-processing"]
        if rec and rec.results[1].name ~= "angels-void" then
          local gradeSet = tier
          if not data.raw["item-subgroup"][rec.subgroup .. "-omnide"] then
            local cat = {
              type = "item-subgroup",
              name = rec.subgroup .. "-omnide",
              group = "omnicrystal",
              order = "aa",
            }
            toAdd[#toAdd + 1] = cat
          end
          --grab ore name from result
          local ing = table.deepcopy(ingrediences_solvation(rec))
          local res = table.deepcopy(results_solvation(rec))
          local ore = res[1].name or res[1][1]
          ore = string.sub(ore, 1, -13)
          local lookup = ore
          if string.find(lookup, "-ore") then
            lookup = string.sub(lookup, 1, -5)
          end
          local ic = salt_omnide_icon(ore)

          toAdd[#toAdd + 1] = {
            type = "recipe",
            name = "clowns-" .. tier .. "-mix" .. j .. "-pure-salting",
            localised_name = { "recipe-name.pure-omnide-salting", { "lookup." .. lookup } },
            localised_description = { "recipe-description.pure-omnide-salting", { "lookup." .. lookup } },
            category = "omniplant",
            subgroup = rec.subgroup .. "-omnide",
            enabled = false,
            ingredients = ing,
            order = "b[clownsore1-crushed]",
            icons = ic,
            results = res,
            energy_required = 5,
          }
          if tier == "crushed" then
            toTech[#toTech + 1] = { "omnitech-crystallology-1", "clowns-" .. tier .. "-mix" .. j .. "-pure-salting" }
          elseif tier == "chunk" then
            toTech[#toTech + 1] = { "omnitech-crystallology-2", "clowns-" .. tier .. "-mix" .. j .. "-pure-salting" }
          elseif tier == "crystal" then
            toTech[#toTech + 1] = { "omnitech-crystallology-3", "clowns-" .. tier .. "-mix" .. j .. "-pure-salting" }
          elseif tier == "pure" then
            toTech[#toTech + 1] = { "omnitech-crystallology-4", "clowns-" .. tier .. "-mix" .. j .. "-pure-salting" }
          end
        end
        if mods["angelsrefining"] and settings.startup["angels-salt-sorting"].value then
          for i, rec in pairs(data.raw.recipe) do
            if rec.category == "omniplant" and string.find(rec.name, "salting") then
              omni.lib.replace_recipe_ingredient(rec.name, "hydromnic-acid",
                { type = "item", name = "omni-catalyst", amount = 1 })
              rec.category = "angels-ore-sorting"
            end
          end
        end
      end
    end
  end
  data:extend(toAdd)
  for i, n in pairs(toTech) do
    omni.lib.add_unlock_recipe(n[1], n[2])
  end
end
