--build basic table
local ore_table = clowns.tables.ores
local ore_material = {
  ["clowns-ore1"] = {order = "a", acid = "angels-liquid-hydrofluoric-acid", geode="purple"},
  ["clowns-ore2"] = {order = "b", acid = "sulfuric-acid", geode="lightgreen"},
  ["clowns-ore3"] = {order = "c", acid = "angels-liquid-nitric-acid", geode="red"},
  ["clowns-ore4"] = {order = "d", acid = "angels-liquid-hydrochloric-acid", geode="lightgreen"},
  ["clowns-ore5"] = {order = "e", acid = "angels-liquid-nitric-acid", geode="yellow"},
  ["clowns-ore6"] = {order = "f", acid = "sulfuric-acid", geode="cyan"},
  ["clowns-ore7"] = {order = "g", acid = "angels-liquid-hydrofluoric-acid", geode="blue"},
  ["clowns-ore8"] = {order = "h", acid = "angels-liquid-hydrochloric-acid", geode="lightgreen"},
  ["clowns-ore9"] = {order = "i", acid = "clowns-liquid-phosphoric-acid", geode="cyan"},
}
local acid_wastewater = {
  ["sulfuric-acid"] = "angels-water-yellow-waste",
  ["angels-liquid-hydrofluoric-acid"] = "angels-water-greenyellow-waste",
  ["angels-liquid-nitric-acid"] = "angels-water-red-waste",
  ["angels-liquid-hydrochloric-acid"] = "angels-water-green-waste",
  ["angels-liquid-boric-acid"] = "", --currently no wastewater
  ["clowns-liquid-phosphoric-acid"] = "angels-water-yellow-waste", --currently no wastewater
}
for _, ore in pairs(ore_table) do
  data:extend(
    {
      --TIER 1
      {
        type = "recipe",
        name = ore.."-crushed",
        localised_name = {"recipe-name.clowns-mix",{"entity-name."..ore},"Crushing"},
        category = "angels-ore-refining-t1",
        subgroup = "clowns-ore-processing-a",
        energy_required = 1,
        enabled = false,
        allow_decomposition = false,
        ingredients = {{type = "item", name = ore, amount = 2}},
        results=
        {
          {type = "item", name = ore.."-crushed", amount = 2},
          {type = "item", name = "angels-stone-crushed", amount = 1}
        },
        icons={
          {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/crushed.png", icon_size = 64}
        },
        order = ore_material[ore].order or "a"
      },
      --TIER 2
      {
        type = "recipe",
        name = ore.."-chunk",
        localised_name = {"recipe-name.clowns-mix",{"entity-name."..ore},"Hydro Refining"},
        category = "angels-ore-refining-t2",--t2
        subgroup = "clowns-ore-processing-b",
        energy_required = 2,
        enabled = false,
        ingredients =
        {
          {type = "item", name = ore.."-crushed", amount = 2},
          {type = "fluid", name = "angels-water-purified", amount = 50},
        },
        results=
        {
          {type = "item", name = ore.."-chunk", amount = 2},
          {type = "fluid", name = acid_wastewater[ore_material[ore].acid], amount = 50},
          {type = "item", name = "angels-geode-"..ore_material[ore].geode, amount = 1, probability = 0.5},
        },
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/chunk.png",
        icon_size = 64,
        order = ore_material[ore].order or "a"
      },
	    --TIER 3
		  {
        type = "recipe",
        name = ore.."-crystal",
        category = "angels-ore-refining-t3", --t3
        subgroup = "clowns-ore-processing-c",
        energy_required = 2,
        enabled = false,
        ingredients =
        {
          {type = "item", name = ore.."-chunk", amount = 2},
          {type = "fluid", name = ore_material[ore].acid, amount = 10}
        },
        results =
        {
          {type = "item", name = ore.."-crystal", amount = 2},
        },
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/crystal.png",
        icon_size = 64,
        order = ore_material[ore].order or "a"
      },
	    --TIER 4
      {
        type = "recipe",
        name = ore.."-pure",
        category = "angels-ore-refining-t4", --t4
        subgroup = "clowns-ore-processing-d",
        energy_required = 2,
        enabled = false,
        ingredients =
        {
          {type = "item", name = ore.."-crystal", amount = 4},
        },
        results=
        {
          {type = "item", name = ore.."-pure", amount = 4},
        },
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore.."/pure.png",
        icon_size = 64,
        order = ore_material[ore].order or "a"
      },
    }   
  )
end