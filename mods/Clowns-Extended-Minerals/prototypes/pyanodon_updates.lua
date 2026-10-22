local OV = angelsmods.functions.OV
local special_vanilla = clowns.special_vanilla

if mods["pycoalprocessing"] then
--update mixed sorting recipes
  OV.patch_recipes(
    {
      --Borax
      {
        name = "clowns-crushed-mix7-processing",
        results = {{"!!"},{type = "item", name = "raw-borax", amount = special_vanilla and 6 or 9}},
        icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          clowns.tables.tweaked_icon_lookup("raw-borax", 0.5, {10, 10}),
          {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
        ingredients = special_vanilla and {
          {"!!"},
          {type = "item", name = "clowns-ore7-crushed", amount = 2},
          {type = "item", name = "angels-ore4-crushed", amount = 2},
          {type = "item", name = "clowns-resource1", amount = 2},
          {type = "item", name = "catalysator-brown", amount = 0}
        } or nil,
      },
      --Nexelit
      {
        name = "clowns-chunk-mix7-processing",
        results = {{"!!"},{type = "item", name = "nexelit-ore", amount = 8}},
        icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          clowns.tables.tweaked_icon_lookup("nexelit-ore", 0.5, {10, 10}),
          {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
        ingredients = special_vanilla and {
          {"!!"},
          {type = "item", name = "clowns-ore4-chunk", amount = 2},
          {type = "item", name = "angels-ore2-chunk", amount = 2},
          {type = "item", name = "clowns-resource2", amount = 2},
          {type = "item", name = "angels-ore1-chunk", amount = 2},
          {type = "item", name = "catalysator-green", amount = 0}
        } or nil,
      },
      --Niobium
      {
        name = "clowns-chunk-mix8-processing",
        results = {{"!!"},{type = "item", name = "niobium-ore", amount = 8}},
        icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          clowns.tables.tweaked_icon_lookup("niobium-ore", 0.5, {10, 10}),
          {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
        ingredients = special_vanilla and {
          {"!!"},
          {type = "item", name = "clowns-ore4-chunk", amount = 2},
          {type = "item", name = "clowns-resource1", amount = 2},
          {type = "item", name = "clowns-resource2", amount = 2},
          {type = "item", name = "clowns-ore7-chunk", amount = 2},
          {type = "item", name = "catalysator-green", amount = 0}
        } or nil,
      },
      -- Rare-earth-dust 
      {
        name = "clowns-chunk-mix9-processing",
        results = {{"!!"},{type = "item", name = "rare-earth-dust", amount = 8}},
        icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          clowns.tables.tweaked_icon_lookup("rare-earth-dust", 0.5, {10, 10}),
          {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
        ingredients = special_vanilla and {
          {"!!"},
          {type = "item", name = "angels-ore4-chunk", amount = 2},
          {type = "item", name = "clowns-ore1-chunk", amount = 2},
          {type = "item", name = "clowns-resource2", amount = 2},
          {type = "item", name = "clowns-ore7-chunk", amount = 2},
          {type = "item", name = "catalysator-green", amount = 0}
        } or nil,
      },
    }
  )
  table.insert(data.raw.technology["clowns-ore-crushing"].effects,{type = "unlock-recipe",recipe = "clowns-crushed-mix7-processing"})
  table.insert(data.raw.technology["clowns-ore-floatation"].effects,{type = "unlock-recipe",recipe = "clowns-chunk-mix7-processing"})
  table.insert(data.raw.technology["clowns-ore-floatation"].effects,{type = "unlock-recipe",recipe = "clowns-chunk-mix8-processing"})
  table.insert(data.raw.technology["clowns-ore-floatation"].effects,{type = "unlock-recipe",recipe = "clowns-chunk-mix9-processing"})
  --regular ore sorting
  angelsmods.functions.OV.patch_recipes(
    { --clowns ore 7
      --["raw-borax"] = pymode and {1,1,1,1} or nil,
      --["nexelit-ore"] = pymode and {0,0,1,1} or nil
      { name = 'clowns-ore7-crushed-processing',
        ingredients = {{type = 'item', name = 'clowns-ore7-crushed', amount = '+1'}},
        results = {{type = 'item', name = 'raw-borax', amount = 1}}},
      { name = 'clowns-ore7-chunk-processing',
        ingredients = {{type = 'item', name = 'clowns-ore7-chunk', amount = '+1'}},
        results = {{type = 'item', name = 'raw-borax', amount = 1}}},
      { name = 'clowns-ore7-crystal-processing',
        ingredients = {{type = 'item', name = 'clowns-ore7-crystal', amount = '+2'}},
        results = {{type = 'item', name = 'raw-borax', amount = 1},{type = 'item', name = 'nexelit-ore', amount = 1}}},
      { name = 'clowns-ore7-pure-processing',
        ingredients = {{type = 'item', name = 'clowns-ore7-pure', amount = '+2'}},
        results = {{type = 'item', name = 'raw-borax', amount = 1},{type = 'item', name = 'nexelit-ore', amount = 1}}},
      --clowns ore 4
      --["niobium-ore"] = pymode and {0,1,1,1} or nil,
      --["rare-earth-dust"] = pymode and {0,1,1,1} or nil
      { name = 'clowns-ore4-chunk-processing',
        ingredients = {{type = 'item', name = 'clowns-ore4-chunk', amount = '+2'}},
        results = {{type = 'item', name = 'niobium-ore', amount = 1},{type = 'item', name = 'rare-earth-dust', amount = 1}}},
      { name = 'clowns-ore4-crystal-processing',
        ingredients = {{type = 'item', name = 'clowns-ore4-crystal', amount = '+2'}},
        results = {{type = 'item', name = 'niobium-ore', amount = 1},{type = 'item', name = 'rare-earth-dust', amount = 1}}},
      { name = 'clowns-ore4-pure-processing',
        ingredients = {{type = 'item', name = 'clowns-ore4-pure', amount = '+2'}},
        results = {{type = 'item', name = 'niobium-ore', amount = 1},{type = 'item', name = 'rare-earth-dust', amount = 1}}}
    }
  )
  if mods["pyfusionenergy"] then
    --update mixed sorting recipes
      OV.patch_recipes(
        {
          --Molybdenum
          {
            name = "clowns-crystal-mix6-processing",
            results = {{"!!"},{type = "item", name = "molybdenum-ore", amount = special_vanilla and 4 or 5}},
            icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
              clowns.tables.tweaked_icon_lookup("molybdenum-ore", 0.5, {10, 10}),
              {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
            ingredients = special_vanilla and {
              {"!!"},
              {type = "item", name = "angels-ore1-crystal", amount = 2},
              {type = "item", name = "clowns-ore5-crystal", amount = 2},
              {type = "item", name = "catalysator-orange", amount = 0}
            } or nil,
          },
          --Regolites
          {
            name = "clowns-crystal-mix7-processing",
            results = {{"!!"},{type = "item", name = "regolite-rock", amount = special_vanilla and 4 or 5}},
            icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
              clowns.tables.tweaked_icon_lookup("regolite-rock", 0.5, {10, 10}),
              {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
            ingredients = special_vanilla and {
              {"!!"},
              {type = "item", name = "clowns-ore1-crystal", amount = 2},
              {type = "item", name = "clowns-ore5-crystal", amount = 2},
              {type = "item", name = "catalysator-orange", amount = 0}
            } or nil,
          },
          --Kimberlite
          {
            name = "clowns-pure-mix6-processing",
            results = {{"!!"},{type = "item", name = "kimberlite-rock", amount = 5}},
            icons = {{icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
              clowns.tables.tweaked_icon_lookup("kimberlite-rock", 0.5, {10, 10}),
              {icon = "__Clowns-Processing__/graphics/icons/advsorting-overlay.png",icon_size=32}},
            ingredients = special_vanilla and {
              {"!!"},
              {type = "item", name = "angels-ore4-pure", amount = 1},
              {type = "item", name = "angels-ore2-pure", amount = 1},
              {type = "item", name = "clowns-resource2", amount = 1},
              {type = "item", name = "clowns-ore1-pure", amount = 1},
              {type = "item", name = "clowns-ore7-pure", amount = 1},
              {type = "item", name = "catalysator-orange", amount = 0}
            } or nil,
          },
        }
      )
      --add tech unlocks
      table.insert(data.raw.technology["clowns-ore-leaching"].effects,{type = "unlock-recipe",recipe = "clowns-crystal-mix6-processing"})
      table.insert(data.raw.technology["clowns-ore-leaching"].effects,{type = "unlock-recipe",recipe = "clowns-crystal-mix7-processing"})
      table.insert(data.raw.technology["clowns-ore-refining"].effects,{type = "unlock-recipe",recipe = "clowns-pure-mix6-processing"})
      --regular ore sorting
    angelsmods.functions.OV.patch_recipes(
      { --clowns ore 1
        --["molybdenum-ore"] = pymode and {0,1,1,1} or nil,
        { name = 'clowns-ore4-chunk-processing',
          ingredients = {{type = 'item', name = 'clowns-ore1-chunk', amount = '+1'}},
          results = {{type = 'item', name = 'molybdenum-ore', amount = 1}}},
        { name = 'clowns-ore4-crystal-processing',
          ingredients = {{type = 'item', name = 'clowns-ore1-crystal', amount = '+1'}},
          results = {{type = 'item', name = 'molybdenum-ore', amount = 1}}},
        { name = 'clowns-ore4-pure-processing',
          ingredients = {{type = 'item', name = 'clowns-ore1-pure', amount = '+1'}},
          results = {{type = 'item', name = 'molybdenum-ore', amount = 1}}},
      --clowns ore 5
      --["regolite-rock"] = pymode and {0,1,1,1} or nil)
        { name = 'clowns-ore4-chunk-processing',
          ingredients = {{type = 'item', name = 'clowns-ore5-chunk', amount = '+1'}},
          results = {{type = 'item', name = 'regolite-rock', amount = 1}}},
        { name = 'clowns-ore4-crystal-processing',
          ingredients = {{type = 'item', name = 'clowns-ore5-crystal', amount = '+1'}},
          results = {{type = 'item', name = 'regolite-rock', amount = 1}}},
        { name = 'clowns-ore4-pure-processing',
          ingredients = {{type = 'item', name = 'clowns-ore5-pure', amount = '+1'}},
          results = {{type = 'item', name = 'regolite-rock', amount = 1}}},
      }
    ) 
  end

end
