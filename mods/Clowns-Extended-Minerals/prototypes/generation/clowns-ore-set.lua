local special_vanilla = clowns.special_vanilla
--------------------------------------------------
-- define bare minimum (special vanilla tables) --
--------------------------------------------------
local ap_dat={
	["clowns-ore1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-ore4"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-ore5"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-ore7"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource3"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource4"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["clowns-resource5"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1},
	["infinite-clowns-ore1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid="angels-liquid-hydrofluoric-acid"},
	["infinite-clowns-ore4"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid="angels-liquid-hydrochloric-acid"},
	["infinite-clowns-ore5"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid="angels-liquid-nitric-acid"},
  ["infinite-clowns-ore7"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid="angels-liquid-hydrofluoric-acid"},
	["infinite-clowns-resource2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid = "steam"},
	["infinite-clowns-resource1"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid = "clowns-liquid-phosphoric-acid"},
}
local ore_dat = {
  ["clowns-ore1"] = {--[[stage="clowns_ore1",]]ore_sheet = 3, order = "c-a",	mining_time = 3*4--[[old time * hardness]], tint = {r = 0.6510, g = 0.3490, b = 0.6510}},
	["clowns-ore4"] = {--[[stage="clowns_ore4",]]ore_sheet = 1,	order = "c-d",	mining_time = 2*1.5, tint = {r = 1, g = 0.3438, b = 0.0}},
	["clowns-ore5"] = {--[[stage="clowns_ore5",]]ore_sheet = 3,	order = "c-e",	mining_time = 1.5*0.9, tint = {r = 1, g = 1, b = 1}},
  ["clowns-ore7"] = {--[[stage="clowns_ore7",]]ore_sheet = 2,	order = "c-g",	mining_time = 2*3,	tint = {r = 0.48, g = 0.63, b = 0.15}},
  --["clowns-resource1"] = {--[[stage="clowns-resource1",]]ore_sheet = "__Clowns-Extended-Minerals__/graphics/entity/alluvium.png",	order = "c-k",	mining_time = 1*0.2,	tint = {r = 0.9, g = 0.7, b = 0.7}},
  --["clowns-resource2"] = {--[[stage="clowns-resource2",]]ore_sheet = "__Clowns-Extended-Minerals__/graphics/entity/oil-sands.png",	order = "c-l",	mining_time = 1*0.5,	tint = {r = 0.2, g = 0.25, b = 0.25}},
}
------------------------------------------------------------
-- append tables if running with bobs or angelsindustries --
------------------------------------------------------------
if not special_vanilla then
  ap_dat["clowns-ore2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["clowns-ore3"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["clowns-ore6"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["clowns-ore8"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["clowns-ore9"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  --ap_dat["clowns-ore10"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["infinite-clowns-ore2"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
	ap_dat["infinite-clowns-ore3"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid = "angels-liquid-nitric-acid"}
  ap_dat["infinite-clowns-ore6"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1}
  ap_dat["infinite-clowns-ore8"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid = "angels-liquid-hydrochloric-acid"}
  ap_dat["infinite-clowns-ore9"] = { starting_area = false, base_density = 10, regular_rq_factor_multiplier = 0.9, starting_rq_factor_multiplier = 1.1, acid = "clowns-liquid-phosphoric-acid"}

  ore_dat["clowns-ore2"] = {--[[stage="clowns_ore2",]]ore_sheet = 4,	order = "c-b",	mining_time = 1.75*2.75--[[old time * hardness]], tint = {r = 1, g = 0, b = 0.5}}
  ore_dat["clowns-ore3"] = {--[[stage="clowns_ore3",]]ore_sheet = 3,	order = "c-c",	mining_time = 1.5*0.9--[[old time * hardness]],	tint = {r = 0.4, g = 0.4, b = 0.4}}
  ore_dat["clowns-ore6"] = {--[[stage="clowns_ore6",]]ore_sheet = 2,	order = "c-f",	mining_time = 1.75*2--[[old time * hardness]], tint = {r = 0.9020, g = 0.0000, b = 0.0000}}
  ore_dat["clowns-ore8"] = {--[[stage="clowns_ore8",]]ore_sheet = 6,	order = "c-h",	mining_time = 1.4*4--[[old time * hardness]], tint = {r = 110, g = 207, b = 148}}
  ore_dat["clowns-ore9"] = {--[[stage="clowns_ore9",]]ore_sheet = 5,	order = "c-i",	mining_time = 1.6*4--[[old time * hardness]], tint = {r = 219, g = 160, b = 0.0000}}
  --ore_dat["clowns-ore10"] = {--[[stage="clowns_ore6",]]ore_sheet = 2,	order = "c-j",	mining_time = 1.75*2--[[old time * hardness]], tint = {r = 0.9020, g = 0.0000, b = 0.0000}}
end
local inf_dat={} --duplicate regular ore_dat into inf_dat table
for j,ore in pairs(ore_dat) do
  inf_dat["infinite-"..j] = table.deepcopy(ore_dat[j])
end
---------------------------------------------
-- Create ores and auto-plate for each ore --
---------------------------------------------
for ore_name in pairs(ore_dat) do
local build_tab =  {
    name = ore_name,
    order = ore_dat[ore_name].order,
    sheet = ore_dat[ore_name].ore_sheet,
    infinite = false,
    map_color = ore_dat[ore_name].tint,
    tint = ore_dat[ore_name].tint,
    mining_time = ore_dat[ore_name].mining_time,
    type = "item",
    output_name = ore_name,
    output_min = 1,
    output_max = 1,
    icon = "__Clowns-Extended-Minerals__/graphics/icons/"..ore_name.."/ore.png",
    icon_size = 64,
    autoplace = {
      starting_area = ap_dat[ore_name].starting_area,
      base_density = ap_dat[ore_name].base_density,
      regular_rq_factor_multiplier = ap_dat[ore_name].regular_rq_factor_multiplier,
      starting_rq_factor_multiplier = ap_dat[ore_name].starting_rq_factor_multiplier
    }
  }
	angelsmods.functions.add_resource("make",build_tab)
end


if mods["angelsinfiniteores"] then
  for ore_name in pairs(inf_dat) do
    local num=string.match(ore_name,"%d+")
    if settings.startup["enableinfiniteclownsore"..num].value then
      local base_ore = string.sub(ore_name,10)

      local build_tab = {
        name = ore_name,
        get = base_ore,
        order = "b"..ore_dat[base_ore].order, --place inf ores at the top of the list
        sheet = ore_dat[base_ore].sheet,
        infinite = true,
        glow = true,
        var = 6,
        map_color = ore_dat[base_ore].tint,
        tint = ore_dat[base_ore].tint,
        mining_time = ore_dat[base_ore].mining_time,
        type = "item",
        minimum = angelsmods.ores.yield,
        normal = 1500,
        maximum = 6000,
        acid_to_mine = ap_dat[ore_name].acid or "sulfuric-acid",
        output_name = base_ore,
        output_min = 1,
        output_max = 1,
        output_probability = angelsmods.ores.loweryield,
        autoplace = {
          starting_area = false,
          resource_index = "z"..ore_dat[base_ore].order,
          base_density = ap_dat[base_ore].base_density/10,--tenth the density
          regular_rq_factor_multiplier = ap_dat[base_ore].regular_rq_factor_multiplier,
          starting_rq_factor_multiplier = ap_dat[base_ore].starting_rq_factor_multiplier
        }
      }
      angelsmods.functions.add_resource("make",build_tab)
    end
  end
end
