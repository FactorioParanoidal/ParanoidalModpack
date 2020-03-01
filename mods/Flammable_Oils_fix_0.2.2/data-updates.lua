require "util"
local fire = util.table.deepcopy(data.raw.fire["fire-flame"])
fire.initial_lifetime = 600
fire.name="oil-fire-flame"
fire.damage_per_tick = {amount = 1, type = "fire"},
data:extend({fire})

local fuel_values = {
  --["crude-oil"] = "2.5MJ",
  --["light-oil"] = "3MJ",
  --["heavy-oil"] = "2MJ",
  --["petroleum-gas"] = "3MJ",
  --["diesel-fuel"] = "4MJ",
  
  ["gas-hydrogen"] = "90KJ", -- 10,78 МДж/м3 
["hydrogen"] = "90KJ", -- 10,78 МДж/м3 

["liquid-multi-phase-oil"] = "180KJ", --21,5MДж/кг
["crude-oil"] = "367KJ",-- 44 MДж/кг
  
  ["heavy-oil"] = "330KJ", -- МАЗУТ
  ["liquid-naphtha"] = "330KJ",
  
  ["light-oil"] = "345KJ",
 	["liquid-fuel"] = "350KJ", 
	["liquid-fuel-oil"] = "375KJ",  --Gas oil	38MДж/кг
	["diesel"] = "775KJ", -- 44,8-43,5 MДж/кг
	["diesel-fuel"] = "775KJ", --375KJ
	["gasoline"] = "384KJ", -- 46 МДж/кг, 32,7 МДж/литр
	["kerosene"] = "359KJ", -- 43 МДж/кг	

  ["petroleum-gas"] = "350KJ",

	
	["gas-natural-1"] = "280KJ",  -- 33,5 МДж/м3 
	["gas-raw-1"] = "250KJ",

	["gas-methane"] = "279KJ", -- 33,41 МДж/м3 
	["gas-ethane"] = "500KJ",  -- 59,85 МДж/м3 
	["gas-butane"] = "950KJ", -- 113,81 МДж/м3 
	
	["gas-propene"] = "380KJ", -- 45,6 МДж/м3 
	["gas-ethylene"] = "400KJ",  -- 48 Мдж/м3
	["gas-benzene"] = "1210KJ", -- 145 МДж/м3 -- БЕНЗОЛ

	["gas-butadiene"] = "948KJ", -- butilene 113,51
	["gas-ethylbenzene"] = "1308KJ",

	
  	["acetylene"] = "468KJ", -- 56,04 МДж/м3 


["gas-synthesis"] = "96KJ", -- 11,5 Мдж/м3
["gas-residual"] = "350KJ", -- 42 Мдж/м3	

    ["gas-methanol"] = "180KJ", -- 21,1-22 MДж/кг
	["methanol"] = "180KJ", -- 21,1-22 MДж/кг
    ["acetone"] = "262KJ", -- 31,4 МДж/кг
	["coal-gas"] = "146KJ", -- 17,5 Мдж/м3
	["syngas"] = "12KJ", -- 11,5 Мдж/м3	
	["liquid-toluene"] = "1308KJ", --156,71 Мдж/м3
	["gas-hydrazine"] = "380KJ", --fuel_value = "380KJ", 14644 кДж/кг
	
	["gas-ammonia"] = "155KJ",  --18,6  Мдж/м3
	["gas-hydrogen-sulfide"] = "182KJ",  --21,75  Мдж/м3
	
	["combustion-mixture1"] = "300KJ",
	["combustion-mixture2"] = "300KJ",
	["diborane"] = "300KJ",	
	["refsyngas"] = "300KJ",
	["xylenol"] = "300KJ"
  
}

for k, fluid in pairs (data.raw.fluid) do
  if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
  end
end