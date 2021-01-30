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
  
  ["gas-hydrogen"] = "150KJ", -- 10,78 МДж/м3 
["hydrogen"] = "150KJ", -- 10,78 МДж/м3 

["liquid-multi-phase-oil"] = "360KJ", --21,5MДж/кг
["crude-oil"] = "734KJ",-- 44 MДж/кг
  
  ["heavy-oil"] = "660KJ", -- МАЗУТ
  ["liquid-naphtha"] = "660KJ",
  
  ["light-oil"] = "690KJ",
 	["liquid-fuel"] = "1340KJ", 
	["liquid-fuel-oil"] = "1340KJ",  --Gas oil	38MДж/кг
	["diesel"] = "2250KJ", -- 44,8-43,5 MДж/кг
	["diesel-fuel"] = "2250KJ", --375KJ
	["gasoline"] = "768KJ", -- 46 МДж/кг, 32,7 МДж/литр
	["kerosene"] = "718KJ", -- 43 МДж/кг	

  ["petroleum-gas"] = "700KJ",

	
	["gas-natural-1"] = "560KJ",  -- 33,5 МДж/м3 
	["gas-raw-1"] = "500KJ",
	["liquid-ngl"] =  "780KJ",  -- 46,8 МДж/кг

	["gas-methane"] = "558KJ", -- 33,41 МДж/м3 
	["gas-ethane"] = "1000KJ",  -- 59,85 МДж/м3 
	["gas-butane"] = "1900KJ", -- 113,81 МДж/м3 
	
	["gas-propene"] = "760KJ", -- 45,6 МДж/м3 
	["gas-ethylene"] = "800KJ",  -- 48 Мдж/м3
	["gas-benzene"] = "2420KJ", -- 145 МДж/м3 -- БЕНЗОЛ

	["gas-butadiene"] = "1896KJ", -- butilene 113,51
	["liquid-ethylbenzene"] = "2616KJ",

	
  	["acetylene"] = "936KJ", -- 56,04 МДж/м3 


["gas-synthesis"] = "192KJ", -- 11,5 Мдж/м3
["gas-residual"] = "700KJ", -- 42 Мдж/м3	

    ["gas-methanol"] = "360KJ", -- 21,1-22 MДж/кг
	["methanol"] = "360KJ", -- 21,1-22 MДж/кг
    ["acetone"] = "524KJ", -- 31,4 МДж/кг
	["coal-gas"] = "292KJ", -- 17,5 Мдж/м3
	["syngas"] = "240KJ", -- 11,5 Мдж/м3	
	["liquid-toluene"] = "2616KJ", --156,71 Мдж/м3
	["gas-hydrazine"] = "760KJ", --fuel_value = "380KJ", 14644 кДж/кг
	
	["gas-ammonia"] = "310KJ",  --18,6  Мдж/м3
	["gas-hydrogen-sulfide"] = "364KJ",  --21,75  Мдж/м3
	["sour-gas"] = "304KJ",
	
	
	["combustion-mixture1"] = "600KJ",
	["combustion-mixture2"] = "600KJ",
	["diborane"] = "600KJ",	
	["refsyngas"] = "600KJ",
	["xylenol"] = "600KJ"
  
}

for k, fluid in pairs (data.raw.fluid) do
  --if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
  --end
end