--ore table
local ore_table=
--[[clowns.special_vanilla and {"clowns-ore1","clowns-ore4","clowns-ore5","clowns-ore7"}
or]] {"clowns-ore1","clowns-ore2","clowns-ore3","clowns-ore4","clowns-ore5","clowns-ore6","clowns-ore7","clowns-ore8", "clowns-ore9"}

for _, name in pairs(ore_table) do
data:extend(
  {
    --Crushed
    {
      type = "item",
      name = ""..name.."-crushed",
      localised_name = {"item-name.clown-mat","Crushed",{"entity-name."..name}},
      icons={
        {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/crushed.png", icon_size = 64}
      },
      subgroup = "clowns-ore-processing-a",
      order = "a["..name.."]",
      stack_size = 200
    },
    --Chunk
    {
      type = "item",
      name = ""..name.."-chunk",
      localised_name = {"item-name.clown-mat",{"entity-name."..name},"Chunk"},
      icons={
        {icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/chunk.png", icon_size = 64}
      },
      subgroup = "clowns-ore-processing-b",
      order = "a["..name.."]",
      stack_size = 200
    },
    --Crystal
    {
      type = "item",
      name = ""..name.."-crystal",
      localised_name = {"item-name.clown-mat",{"entity-name."..name},"Crystal"},
      icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/crystal.png",
      icon_size = 64,
      subgroup = "clowns-ore-processing-c",
      order = "a["..name.."]",
      stack_size = 200
    },
    --Pure
    {
      type = "item",
      name = ""..name.."-pure",
      localised_name = {"item-name.clown-mat","Purified",{"entity-name."..name}},
      icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/pure.png",
      icon_size = 64,
      subgroup = "clowns-ore-processing-d",
      order = "a["..name.."]",
      stack_size = 200
    },
    --Ore
    {
      type = "item",
      name = name,
      localised_name = {"item-name.clown-mat",{"entity-name."..name},"Ore"},
      icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/ore.png",
      icon_size = 64,
      subgroup = "angels-ores",
      order = "a["..name.."]",
      stack_size = 200
    }
  }
)
end
--mixed ores
clowns.shifts = {
  ["clowns-ore11"] = {["A"]={223,253,045},["B"]={255,150,110},["C"]={255,150,110,0.7},["D"]={250,145,105,0.9},["E"]={165,093,051}},
  ["clowns-ore12"] = {["A"]={251,133,000},["B"]={249,054,010},["C"]={249,054,010,0.7},["D"]={244,049,005,0.9},["E"]={165,093,051}},
  ["clowns-ore13"] = {["A"]={218,020,118},["B"]={159,020,121},["C"]={159,020,121,0.7},["D"]={154,015,016,0.9},["E"]={165,093,051}},
  ["clowns-ore14"] = {["A"]={098,000,171},["B"]={067,008,151},["C"]={067,008,151,0.7},["D"]={062,003,146,0.9},["E"]={165,093,051}},
  ["clowns-ore15"] = {["A"]={108,163,103},["B"]={162,131,100},["C"]={089,083,122,0.7},["D"]={122,088,074,0.9},["E"]={165,093,051}}
}
local shifts=clowns.shifts
for _, name in pairs({"clowns-ore11","clowns-ore12","clowns-ore13","clowns-ore14","clowns-ore15"}) do
  data:extend(
    {
      --SUBGROUP
      {
        type = "item-subgroup",
        name = "mixed-ore-".. name,
        group = "angels-resource-refining",
        order = "j-e",
      },
      --Crushed
      {
        type = "item",
        name = ""..name.."-crushed",
        localised_name = {"item-name.clown-mat","Crushed",{"entity-name."..name}},
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/crushed.png", 
        icon_size = 64,
        subgroup = "mixed-ore-".. name,
        order = "a["..name.."]",
        stack_size = 200
      },
      --Powder
      {
        type = "item",
        name = ""..name.."-powder",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Powder"},
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/powder.png", 
        icon_size = 64,
        subgroup = "mixed-ore-".. name,
        order = "b["..name.."]",
        stack_size = 200
      },
      --Dust
      {
        type = "item",
        name = ""..name.."-dust",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Dust"},
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/dust.png",
        icon_size = 64,
        subgroup = "mixed-ore-".. name,
        order = "d["..name.."]",
        stack_size = 200
      },
      --Crystal
      {
        type = "item",
        name = ""..name.."-crystal",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Crystal"},
        icon = "__Clowns-Extended-Minerals__/graphics/icons/"..name.."/crystal.png",
        icon_size = 64,
        subgroup = "mixed-ore-".. name,
        order = "h["..name.."]",
        stack_size = 200
      },
      --Sludge
      {
        type = "fluid",
        name = ""..name.."-sludge",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Sludge"},
        icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil, {shifts[name].A, shifts[name].A, shifts[name].B, shifts[name].B}),
        subgroup = "angels-fluids-refining",
        default_temperature = 25,
        heat_capacity = "1kJ",
        base_color = shifts[name].A,--{r = 132 / 255, g = 176 / 255, b = 11 / 255},
        flow_color = shifts[name].B,--{r = 132 / 255, g = 176 / 255, b = 11 / 255},
        max_temperature = 100,
      },
      --Solution
      {
        type = "fluid",
        name = ""..name.."-solution",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Solution"},
        icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil, {shifts[name].A, nil, shifts[name].B}),
        subgroup = "angels-fluids-refining",
        default_temperature = 25,
        heat_capacity = "1kJ",
        base_color = shifts[name].A,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        flow_color = shifts[name].B,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        max_temperature = 100,
      },
      --Anode-sludge
      {
        type = "fluid",
        name = ""..name.."-anode-sludge",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Anode Sludge"},
        icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil, {shifts[name].A, shifts[name].A, shifts[name].C, shifts[name].E}),
        subgroup = "angels-fluids-refining",
        default_temperature = 25,
        heat_capacity = "1kJ",
        base_color = shifts[name].A,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        flow_color = shifts[name].B,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        max_temperature = 100,
      },
      --Slime
      {
        type = "fluid",
        name = ""..name.."-slime",
        localised_name = {"item-name.clown-mat",{"entity-name."..name},"Essence"},
        icons = angelsmods.functions.create_viscous_liquid_fluid_icon(nil, {shifts[name].B, nil, shifts[name].D}),
        subgroup = "angels-fluids-refining",
        default_temperature = 25,
        heat_capacity = "1kJ",
        base_color = shifts[name].A,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        flow_color = shifts[name].B,--{r = 255 / 255, g = 119 / 255, b = 0 / 255},
        max_temperature = 100,
      },
    }
  )
end
if clowns.special_vanilla then --hide non-compliant
  angelsmods.functions.add_flag("clowns-ore2", "hidden")
  angelsmods.functions.add_flag("clowns-ore2-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore2-chunk", "hidden")
  angelsmods.functions.add_flag("clowns-ore2-crystal", "hidden")
  angelsmods.functions.add_flag("clowns-ore2-pure", "hidden")

  angelsmods.functions.add_flag("clowns-ore3", "hidden")
  angelsmods.functions.add_flag("clowns-ore3-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore3-chunk", "hidden")
  angelsmods.functions.add_flag("clowns-ore3-crystal", "hidden")
  angelsmods.functions.add_flag("clowns-ore3-pure", "hidden")

  angelsmods.functions.add_flag("clowns-ore6", "hidden")
  angelsmods.functions.add_flag("clowns-ore6-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore6-chunk", "hidden")
  angelsmods.functions.add_flag("clowns-ore6-crystal", "hidden")
  angelsmods.functions.add_flag("clowns-ore6-pure", "hidden")

  angelsmods.functions.add_flag("clowns-ore8", "hidden")
  angelsmods.functions.add_flag("clowns-ore8-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore8-chunk", "hidden")
  angelsmods.functions.add_flag("clowns-ore8-crystal", "hidden")
  angelsmods.functions.add_flag("clowns-ore8-pure", "hidden")

  angelsmods.functions.add_flag("clowns-ore9", "hidden")
  angelsmods.functions.add_flag("clowns-ore9-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore9-chunk", "hidden")
  angelsmods.functions.add_flag("clowns-ore9-crystal", "hidden")
  angelsmods.functions.add_flag("clowns-ore9-pure", "hidden")

  angelsmods.functions.add_flag("clowns-ore11-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore11-powder", "hidden")
  angelsmods.functions.add_flag("clowns-ore11-dust", "hidden")
  angelsmods.functions.add_flag("clowns-ore11-crystal", "hidden")
  data.raw.fluid["clowns-ore11-sludge"].hidden = true
  data.raw.fluid["clowns-ore11-solution"].hidden = true
  data.raw.fluid["clowns-ore11-anode-sludge"].hidden = true
  data.raw.fluid["clowns-ore11-slime"].hidden = true

  angelsmods.functions.add_flag("clowns-ore12-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore12-powder", "hidden")
  angelsmods.functions.add_flag("clowns-ore12-dust", "hidden")
  angelsmods.functions.add_flag("clowns-ore12-crystal", "hidden")
  data.raw.fluid["clowns-ore12-sludge"].hidden = true
  data.raw.fluid["clowns-ore12-solution"].hidden = true
  data.raw.fluid["clowns-ore12-anode-sludge"].hidden = true
  data.raw.fluid["clowns-ore12-slime"].hidden = true

  angelsmods.functions.add_flag("clowns-ore13-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore13-powder", "hidden")
  angelsmods.functions.add_flag("clowns-ore13-dust", "hidden")
  angelsmods.functions.add_flag("clowns-ore13-crystal", "hidden")
  data.raw.fluid["clowns-ore13-sludge"].hidden = true
  data.raw.fluid["clowns-ore13-solution"].hidden = true
  data.raw.fluid["clowns-ore13-anode-sludge"].hidden = true
  data.raw.fluid["clowns-ore13-slime"].hidden = true

  angelsmods.functions.add_flag("clowns-ore14-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore14-powder", "hidden")
  angelsmods.functions.add_flag("clowns-ore14-dust", "hidden")
  angelsmods.functions.add_flag("clowns-ore14-crystal", "hidden")
  data.raw.fluid["clowns-ore14-sludge"].hidden = true
  data.raw.fluid["clowns-ore14-solution"].hidden = true
  data.raw.fluid["clowns-ore14-anode-sludge"].hidden = true
  data.raw.fluid["clowns-ore14-slime"].hidden = true

  angelsmods.functions.add_flag("clowns-ore15-crushed", "hidden")
  angelsmods.functions.add_flag("clowns-ore15-powder", "hidden")
  angelsmods.functions.add_flag("clowns-ore15-dust", "hidden")
  angelsmods.functions.add_flag("clowns-ore15-crystal", "hidden")
  data.raw.fluid["clowns-ore15-sludge"].hidden = true
  data.raw.fluid["clowns-ore15-solution"].hidden = true
  data.raw.fluid["clowns-ore15-anode-sludge"].hidden = true
  data.raw.fluid["clowns-ore15-slime"].hidden = true
end