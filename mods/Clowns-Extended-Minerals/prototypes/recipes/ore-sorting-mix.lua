local OV = angelsmods.functions.OV
local special_vanilla = clowns.special_vanilla
local ore_table = clowns.tables.ores
local ore_combos = clowns.tables.ore_combos
----------------------------------------------------------------------------
-- MIXED INPUT SORTING METHODS --
-- Start with the statics and add the results later --
-- use tier to set catalysator and counts and kind (crushed etc)
-- use table to set input ores
-- set results based on mod combos/settings
----------------------------------------------------------------------------
---------------------------------------------------
-- CREATE LOOKUP TABLES --
---------------------------------------------------
-- Tier string grabber
local tier_set = { --i may remove the in_count and change it to read the ore_combo list length...
  --[[regular crushed]][1] = {name = "crushed", catalysator = "brown"},
  --[[regular chunk]][2] = {name = "chunk", catalysator = "green"},
  --[[regular crystal]][3] = {name = "crystal", catalysator = "orange"},
  --[[regular pure]][4] = {name = "pure", catalysator = "orange"},
}
local merge_tabs = function(t1,t2)
  for k,v in ipairs(t2) do
    table.insert(t1, v)
 end 
 return t1
end

local ore_list = table.deepcopy(ore_table)
ore_list = merge_tabs(ore_list,{"angels-ore1","angels-ore2","angels-ore3","angels-ore4"})
if not clowns.special_vanilla then --only add angels special vanilla ores to the ore_list
  ore_list = merge_tabs(ore_list,{"angels-ore5","angels-ore6","angels-ore7","angels-ore8"}) --7 and 8 are the advanced (combo) ores
end
--append other materials
ore_list = merge_tabs(ore_list,{"clowns-resource1","clowns-resource2"})

local adv_substitute = {["crushed"] = "crushed",["chunk"] = "powder",["crystal"] = "dust",["pure"] = "crystal"}
local is_adv = function(table_entry,style)
  for _,i in pairs({"angels-ore8","angels-ore9"--[[,"clowns-ore11","clowns-ore12","clowns-ore13","clowns-ore14","clowns-ore15"]]}) do
    if table_entry==i then
      return table_entry .."-".. adv_substitute[style]
    end
  end
  --if not found
  return table_entry .."-".. style
end
local create_mixed_sorting = function(num,tier)
  --grab defines from above tables
  local style = tier_set[tier].name
  local count = #ore_combos[tier][num]--tier_set[tier].in_count --used to add or remove sets
  local cat = tier_set[tier].catalysator

  --fetch ingredient ores
  local ings = ore_combos[tier][num]
  local out,i,ing_norm, ing_exp = 1,1,{},{}
  repeat
    if not string.find(ings[i],"-ore") then --for non ores
      nme=ings[i]
    else
      nme=is_adv(ings[i],style)
    end
    table.insert(ing_norm,{type = "item", name = nme, amount = math.ceil((4.5-tier)*2/9*(5.5-i))})
    --table.insert(ing_exp,{type = "item", name = nme, amount = math.ceil(((4.5-tier)*2/9*(5.5-i))*rawmulti)})
    out=out+(4.5-tier)*2/9*(5.5-i)
    i=i+1
  until(i > count)
  if not cat then--don't add catalysator
  elseif cat == drum then --add milling drum and spent drum --pretty sure this is done in that other script anyway
  elseif cat == acid then --(add acid from a lookup table) --pretty sure this is done in that other script anyway
  else --add catalyser
    table.insert(ing_norm, {type = "item", name = "angels-catalysator-"..cat, amount = 1})
    --table.insert(ing_exp, {type = "item", name = "catalysator-"..cat, amount = 1})
  end
  --create recipe
  --order setting
  local n_order="d"
  local cat= "angels-ore-sorting-"..tier
  if style=="crushed" then
    n_order="a"
    cat="angels-ore-sorting"
  elseif style=="chunk" then
    n_order="b"
  elseif style=="crystal" then
    n_order="c"
  else --style=="pure" then
    n_order="d"
  end
  data:extend(
    {
      {
        type = "recipe",
        name = "clowns-" .. style .. "-mix".. num .."-processing",
        category = cat,
        subgroup = "angels-ore-sorting-advanced-2",
        energy_required = 1,
        enabled = false,
        allow_decomposition = false,
        ingredients = ing_norm,
        results = {{type = "item", name = "angels-void", amount = 1}},
        icons =
        {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
        },
        order = n_order.."[clowns-" .. style .. "-mix".. num .."-processing]",
      },
    }
  )
end

------------------------------------
-- ADVANCED-BLENDED ORE FUNCTIONS --
------------------------------------
local adv_ore_list = {"clowns-ore11","clowns-ore12","clowns-ore13","clowns-ore14","clowns-ore15"}
local blends = {
  [11] = {"clowns-ore1","clowns-ore2","angels-ore6"},
  [12] = {"clowns-ore3","clowns-ore7","angels-ore5"},
  [13] = {"clowns-ore8","clowns-ore6","clowns-ore4"},
  [14] = {"clowns-ore9","clowns-ore1","angels-ore5"},
  [15] = {"clowns-ore5","clowns-ore2","clowns-ore6"}
}
data:extend(
  {
    {
      type = "item-subgroup",
      name = "clowns-ore-sorting-1",
      group = "angels-resource-refining",
      order = "l",
    },
    {
      type = "item-subgroup",
      name = "clowns-ore-sorting-2",
      group = "angels-resource-refining",
      order = "m",
    },
    {
      type = "item-subgroup",
      name = "clowns-ore-sorting-3",
      group = "angels-resource-refining",
      order = "n",
    },
    {
      type = "item-subgroup",
      name = "clowns-ore-sorting-4",
      group = "angels-resource-refining",
      order = "o",
    }
  }
)
local create_adv_mixed_sorting = function(num)
  local shifts=clowns.shifts


  data:extend(
    { --subgroup for recipe (have each ore have its own row)
      {
        type = "item-subgroup",
        name = "clowns-ore".. num .. "-refining",
        group = "angels-resource-refining",
        order = "k-"..num-10,
      },

      --Tier 1.5 (CRUSHED)
      {
        type = "recipe",
        name = "clownsore"..num.."-crushed",
        localised_name = {"recipe-name.clowns-mix","Crushed",{"entity-name.clowns-ore"..num}},
        category = "angels-ore-refining-t1",
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 1,
        enabled = false,
        ingredients = {
          {type = "item", name = blends[num][1].."-crushed", amount = 2},
          {type = "item", name = blends[num][2].."-crushed", amount = 2},
          {type = "item", name = blends[num][3].."-crushed", amount = 2}
        },
        results = {
          {type = "item", name = "clowns-ore"..num.."-crushed", amount = 6}
        },
        order = "a["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-crushed-processing",
        localised_name = {"recipe-name.clowns-proc","Crushed",{"entity-name.clowns-ore"..num}},
        category = "angels-ore-sorting",
        subgroup = "clowns-ore-sorting-1",
        energy_required = 1,
        allow_decomposition = false,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-crushed", amount = 4}
        },
        results = {
          {type = "item", name = "angels-void", amount = 1}
        },
        icons = {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore"..num.."/crushed.png", icon_size = 64, scale = 0.25, shift = {-10, 10}}
        },
        icon_size = 32,
        order = "b["..num.."]"
      },
      --Tier 1.5 (powder)
      {
        type = "recipe",
        name = "clownsore"..num.."-powder",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Powder"},
        category = "angels-powderizing-1",--t-1-5
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 2,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-crushed", amount = 3},
          {type = "item", name = "angels-milling-drum-lubricated", amount = 1}
        },
        results = {
          {type = "item", name = "clowns-ore"..num.."-powder", amount = 3},
          {type = "item", name = "angels-milling-drum", amount = 1}
        },
        main_product = "clowns-ore"..num.."-powder",
        order = "c["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-powder-processing",
        localised_name = {"recipe-name.clowns-proc",{"entity-name.clowns-ore"..num},"Powder"},
        category = "angels-ore-sorting",
        subgroup = "clowns-ore-sorting-2",
        energy_required = 1,
        allow_decomposition = false,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-powder", amount = 6}
        },
        results = {
          {type = "item", name = "angels-void", amount = 1}
        },
        icons = {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore"..num.."/powder.png", icon_size = 64, scale = 0.25, shift = {-10, 10}}
        },
        order = "d["..num.."]"
      },
      --TIER 2.5 (Dust)
      {
        type = "recipe",
        name = "clownsore"..num.."-sludge",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Sludge"},
        category = "chemistry",
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 4,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-powder", amount = 3},
          {type = "item", name = blends[num][1].."-chunk", amount = 1},
          {type = "item", name = blends[num][2].."-chunk", amount = 1},
          {type = "item", name = blends[num][3].."-chunk", amount = 1},
          {type = "fluid", name = "angels-thermal-water", amount = 20},
          {type = "fluid", name = "sulfuric-acid", amount = 20}
        },
        results = {
          {type = "fluid", name = "clowns-ore"..num.."-sludge", amount = 6}
        },
        order = "e["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-dust",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Dust"},
        category = "angels-ore-refining-t2",--t2
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 4,
        enabled = false,
        ingredients = {
          {type = "fluid", name = "clowns-ore"..num.."-sludge", amount = 4},
          {type="item", name="angels-solid-sodium-hydroxide", amount=2}
        },
        results = {
          {type = "item", name = "clowns-ore"..num.."-dust", amount = 4},
          {type = "fluid", name = "angels-water-yellow-waste", amount = 20}
        },
        main_product = "clowns-ore"..num.."-dust",
        icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore"..num.."/dust.png",
        icon_size = 64,
        order = "f["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-dust-processing",
        localised_name = {"recipe-name.clowns-proc",{"entity-name.clowns-ore"..num},"Dust"},
        category = "angels-ore-sorting-3",
        subgroup = "clowns-ore-sorting-3",
        energy_required = 1.5,
        allow_decomposition = false,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-dust", amount = 8}
        },
        results = {
          {type = "item", name = "angels-void", amount = 1}
        },
        icons = {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore"..num.."/dust.png", icon_size = 64, scale = 0.25, shift = {-10, 10}}
        },
        order = "g["..num.."]"
      },
      --Tier 3.5 (CRYSTAL)
      {
        type = "recipe",
        name = "clownsore"..num.."-solution",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Solution"},
        category = "angels-ore-refining-t3",--t3
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 2,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-dust", amount = 3},
          {type = "item", name = blends[num][1].."-crystal", amount = 1},
          {type = "item", name = blends[num][2].."-crystal", amount = 1},
          {type = "item", name = blends[num][3].."-crystal", amount = 1},
          {type = "fluid", name = "sulfuric-acid", amount = 20}
        },
        results = {
          {type = "fluid", name = "clowns-ore"..num.."-solution", amount = 60}
        },
        order = "h["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-anode-sludge-filtering",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Filtering"},
        category = "angels-filtering-2",
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 2,
        enabled = false,
        ingredients = {
          {type = "fluid", name = "clowns-ore"..num.."-solution", amount = 60},
          {type = "fluid", name = "angels-water-purified", amount = 50},
          {type = "item", name = "angels-filter-ceramic", amount = 1}
        },
        results = {
          {type = "fluid", name = "clowns-ore"..num.."-slime", amount = 60},
          {type = "fluid", name = "angels-water-yellow-waste", amount = 10},
          {type = "item", name = "angels-filter-ceramic-used", amount = 1}
        },
        main_product = "clowns-ore"..num.."-slime",
        icons = angelsmods.functions.create_viscous_liquid_filtering_recipe_icon(
          "ceramic",
          { shifts["clowns-ore"..num]["A"], shifts["clowns-ore"..num]["B"], shifts["clowns-ore"..num]["B"], shifts["clowns-ore"..num]["D"]}
        ),
        order = "i["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-anode-sludge",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Sludge"},
        category = "angels-ore-refining-t3-5",--t3-5
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 2,
        enabled = false,
        ingredients = {
          {type = "fluid", name = "clowns-ore"..num.."-slime", amount = 60},
          {type="fluid", name="angels-liquid-ferric-chloride-solution", amount=2} --change a few of them to HCl later?
        },
        results = {
          {type = "fluid", name = "clowns-ore"..num.."-anode-sludge", amount = 60},
          {type = "fluid", name = "angels-water-yellow-waste", amount = 20},
          {type = "item", name = "angels-slag", amount = 1}
        },
        main_product = "clowns-ore"..num.."-anode-sludge",
        order = "j["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-crystal",
        localised_name = {"recipe-name.clowns-mix",{"entity-name.clowns-ore"..num},"Crystal"},
        category = "angels-crystallizing",
        subgroup = "clowns-ore".. num .. "-refining",
        energy_required = 2,
        enabled = false,
        ingredients = {
          {type = "fluid", name = "clowns-ore"..num.."-anode-sludge", amount = 60}
        },
        results = {
          {type = "item", name = "clowns-ore"..num.."-crystal", amount = 6}
        },
        order = "k["..num.."]"
      },
      {
        type = "recipe",
        name = "clownsore"..num.."-crystal-processing",
        localised_name = {"recipe-name.clowns-proc",{"entity-name.clowns-ore"..num},"Crystal"},
        category = "angels-ore-sorting-4",
        subgroup = "clowns-ore-sorting-4",
        energy_required = 1.5,
        allow_decomposition = false,
        enabled = false,
        ingredients = {
          {type = "item", name = "clowns-ore"..num.."-crystal", amount = 9}
        },
        results = {
          {type = "item", name = "angels-void", amount = 1}
        },
        icons = {
          {icon = "__angelsrefininggraphics__/graphics/icons/sort-icon.png", icon_size = 32},
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/clowns-ore"..num.."/crystal.png", icon_size = 64, scale = 0.25, shift = {-10, 10}}
        },
        order = "l["..num.."]"
      },
    }
  )
end
-------------------------------
-- CALL FUNCTION --
-------------------------------
for j=1,#ore_combos, 1 do
  for i= 1, #ore_combos[j],1 do
    create_mixed_sorting(i,j)
  end
end
if not clowns.special_vanilla then
  for k=11,15,1 do
    create_adv_mixed_sorting(k)
  end
end