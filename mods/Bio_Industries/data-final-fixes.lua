local BioInd = require('common')('Bio_Industries')
local ICONPATH = "__Bio_Industries__/graphics/icons/"

-- If OwnlyMe's or Tral'a "Robot Tree Farm" mods are active, they will create variatons
-- of our variations of tree prototypes. Remove them!
local ignore_trees = BioInd.get_tree_ignore_list()
local removed = 0

for name, _ in pairs(ignore_trees or {}) do
  if name:match("rtf%-bio%-tree%-.+%-%d-%d+") then
    data.raw.tree[name] = nil
    ignore_trees[name] = nil
    removed = removed + 1
    BioInd.show("Removed tree prototype", name)
  end
end
BioInd.writeDebug("Removed %g tree prototypes. Number of trees to ignore now: %g", {removed, table_size(ignore_trees)})

BI.Settings.BI_Game_Tweaks_Emissions_Multiplier = settings.startup["BI_Game_Tweaks_Emissions_Multiplier"].value

-- 5dim Stack changes
--~ if settings.startup["5d-change-stack"] and settings.startup["5d-change-stack"].value then
if BioInd.get_startup_setting("5d-change-stack") then
  local item = data.raw.item["wood"]
   if item then
      item.stack_size = math.max(210, item.stack_size)
   end
end
---- Game Tweaks ---- Tree
if BI.Settings.BI_Game_Tweaks_Tree then
  for tree_name, tree in pairs(data.raw["tree"] or {}) do
    if tree.minable and not ignore_trees[tree_name] then
BioInd.writeDebug("Tree name: %s\tminable.result: %s", {tree.name, (tree.minable and tree.minable.result or "nil")}, "line")
    --CHECK FOR SINGLE RESULTS
      if tree.minable.result then
        --CHECK FOR VANILLA TREES WOOD x 4
        if tree.minable.result == "wood" and tree.minable.count == 4 then
  BioInd.writeDebug("Changing wood yield of %s to random value.", {tree.name})
          tree.minable.mining_particle = "wooden-particle"
          tree.minable.mining_time = 1.5
          tree.minable.results = {
            {
              type = "item",
              name = "wood",
              amount_min = 1,
              amount_max = 6
            }
          }
        -- CONVERT RESULT TO RESULTS
        else
  BioInd.writeDebug("Converting tree.minable.result to tree.minable.results!")
  --~ BioInd.show("tree.minable", tree.minable)

          tree.minable.mining_particle = "wooden-particle"
          tree.minable.results = {
            {
              type = "item",
              name = tree.minable.result,
              amount = tree.minable.count,
            }
          }
  --~ BioInd.show("tree.minable.results", tree.minable.results)
        end
      --CHECK FOR RESULTS TABLE
      elseif tree.minable.results then
BioInd.writeDebug("Changing results!")
        for r, result in pairs(tree.minable.results) do
          --CHECK FOR RESULT WOOD x 4
          if result.name == "wood" and result.amount == 4 then
            result.amount = nil
            result.amount_min = 1
            result.amount_max = 6
          end
        end
        tree.minable.result = nil
        tree.minable.count = nil
      end
    else
BioInd.writeDebug("Ignoring  %s!", {tree.name})
    end
--~ BioInd.show("tree.minable", tree.minable)
  end
end


---- Game Tweaks ---- Player (Changed for 0.18.34/1.1.4!)
if BI.Settings.BI_Game_Tweaks_Player then
  -- There may be more than one character in the game! Here's a list of
  -- the character prototype names or patterns matching character prototype
  -- names we want to ignore.
  local blacklist = {
    ------------------------------------------------------------------------------------
    --                                  Known dummies                                 --
    ------------------------------------------------------------------------------------
    -- Autodrive
    "autodrive-passenger",
    -- AAI Programmable Vehicles
    "^.+%-_%-driver$",
    -- Minime
    "minime_character_dummy",
    -- Water Turret (currently the dummies are not characters -- but things may change!)
    "^WT%-.+%-dummy$",
    ------------------------------------------------------------------------------------
    --                                Other characters                                --
    ------------------------------------------------------------------------------------
    -- Bob's Classes and Multiple characters mod
    "^.*bob%-character%-.+$",
  }

  local whitelist = {
    -- Default character
    "^character$",
    -- Characters compatible with Minime
    "^.*skin.*$",
  }

  local tweaks = {
    loot_pickup_distance        = 5,    -- default 2
    build_distance              = 20,   -- Vanilla 6
    drop_item_distance          = 20,   -- Vanilla 6
    reach_distance              = 20,   -- Vanilla 6
    item_pickup_distance        = 6,    -- Vanilla 1
    reach_resource_distance     = 6,    -- Vanilla 2.7
  }

  local found, ignore
  for char_name, character in pairs(data.raw.character) do
BioInd.show("Checking character", char_name)
    found = false

    for w, w_pattern in ipairs(whitelist) do
--~ BioInd.show("w_pattern", w_pattern)
      if char_name == w_pattern or char_name:match(w_pattern) then
        ignore = false
BioInd.show("Found whitelisted character name", char_name)
        for b, b_pattern in ipairs(blacklist) do
--~ BioInd.show("b_pattern", b_pattern)

          if char_name == b_pattern or char_name:match(b_pattern) then
BioInd.writeDebug("%s is on the ignore list!", char_name)
            -- Mark character as found
            ignore = true
            break
          end
        end
        if not ignore then
          found = true
          break
        end
      end
      if found then
        break
      end
    end

    -- Apply tweaks
    if found then
      for tweak_name, tweak in pairs(tweaks) do
        if character[tweak_name] < tweak then
BioInd.writeDebug("Changing %s from %s to %s", {tweak_name, character[tweak_name], tweak})
          character[tweak_name] = tweak
        end
      end
    end
  end
end

---- Game Tweaks ---- Production science pack recipe
if data.raw.recipe["bi-production-science-pack"] then
  BI_Functions.lib.allow_productivity("bi-production-science-pack")
  thxbob.lib.tech.add_recipe_unlock("production-science-pack", "bi-production-science-pack")
  BioInd.writeDebug("Unlock for recipe \"bi-production-science-pack\" added.")
end

---- Game Tweaks ----
if BI.Settings.BI_Game_Tweaks_Stack_Size then
  -- Changed for 0.18.34/1.1.4
  local tweaks = {
    ["wood"]            = 200,
    ["stone"]           = 200,
    ["stone-crushed"]   = 400,
    ["concrete"]        = 500,
    ["slag"]            = 400,
  }
  local item
--[[drd
  for tweak_name, tweak in pairs(tweaks) do
    item = data.raw.item[tweak_name]
    if item and item.stack_size < tweak then
      BioInd.writeDebug("Changing stacksize of %s from %s to %s", {item.name, item.stack_size, tweak})
      item.stack_size = 800
    end
  end
]]--
end


--- Update fuel_emissions_multiplier values DrD
if BI.Settings.BI_Game_Tweaks_Emissions_Multiplier then
  for item, factor in pairs({
	["pellet-coke"] = 1.05,
    ["enriched-fuel"] = 0.75,
    ["solid-fuel"] = 1.2,
    ["solid-carbon"] = 0.9,
    ["carbon"] = 0.9,
    ["wood-bricks"] = 1.05,
    ["rocket-fuel"] = 2,
    ["bi-seed"] = 1.30,
    ["seedling"] = 1.30,
    ["bi-wooden-pole-big"] = 1.5,
    ["bi-wooden-pole-huge"] = 1.5,
    ["bi-wooden-fence"] = 1.5,
    ["bi-wood-pipe"] = 1.5,
    ["bi-wood-pipe-to-ground"] = 1.5,
    ["bi-wooden-chest-large"] = 1.30,
    ["bi-wooden-chest-huge"] = 1.30,
    ["bi-wooden-chest-giga"] = 1.30,
    ["bi-ash"] = 1.30,
    ["ash"] = 1.30,
    ["wood-charcoal"] = 1.25,
    ["cellulose-fiber"] = 1.40,
    ["bi-woodpulp"] = 1.40,
    ["solid-coke"] = 1.25,
    ["wood-pellets"] = 1.1,
    ["coal-crushed"] = 2,
    ["wood"] = 1.75,
    ["coal"] = 3.00,
    -- Removed in 0.17.48/0.18.16
    --~ ["thorium-fuel-cell"] = 5.00,
  }) do
    BI_Functions.lib.fuel_emissions_multiplier_update(item, factor)
  end
end

-- Make vanilla and Bio boilers exchangeable
if BI.Settings.BI_Bio_Fuel then
  local boiler = data.raw["boiler"]["boiler"]
  local boiler_group = boiler.fast_replaceable_group or "boiler"

  boiler.fast_replaceable_group = boiler_group
  data.raw["boiler"]["bi-bio-boiler"].fast_replaceable_group = boiler_group
end

-- Make sure fertilizers have the "place_as_tile" property!
local AlienBiomes = data.raw.tile["vegetation-green-grass-3"] and
                    data.raw.tile["vegetation-green-grass-1"] and true or false

-- We've already set place_as_tile. If it doesn't exist, our fertilizer definition has
-- been overwritten by some other mod, so we restore icons and localization and add
-- place_as_tile again!
local fertilizer = data.raw.item["fertilizer"]
if not fertilizer.place_as_tile then
  fertilizer.place_as_tile = {
    result = AlienBiomes and "vegetation-green-grass-3" or "grass-3",
    condition_size = 1,
    condition = { "water-tile" }
  }
end

data.raw.item["bi-adv-fertilizer"].place_as_tile = {
  result = AlienBiomes and "vegetation-green-grass-1" or "grass-1",
  condition_size = 1,
  condition = { "water-tile" }
}
------------------------------------------------------------------------------------
-- Add icons to our prototypes
BioInd.BI_add_icons()