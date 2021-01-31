local fuel_values = {
  --["crude-oil"] = "1.4MJ",
  --["light-oil"] = "1.5MJ",
  --["heavy-oil"] = "1MJ",
  --["petroleum-gas"] = "1.5MJ",
  --["diesel-fuel"] = "2MJ",

-- coefficient *8.35 above natural;  8.35*x (kg/liquid , m3/gas)

  ["gas-hydrogen"] = "150KJ", -- 10,78 МДж/м3 
["hydrogen"] = "150KJ", -- 10,78 МДж/м3 

["liquid-multi-phase-oil"] = "360KJ", --21,5MДж/кг
["crude-oil"] = "734KJ",-- 44 MДж/кг
  
  ["heavy-oil"] = "660KJ", -- МАЗУТ  40
  ["liquid-naphtha"] = "660KJ",
  
  ["light-oil"] = "690KJ",
 	["liquid-fuel"] = "1140KJ", 
	["liquid-fuel-oil"] = "890KJ",  --Gas oil	38MДж/кг
	["diesel"] = "2250KJ", -- 44,8-43,5 MДж/кг
	["diesel-fuel"] = "2250KJ", --375KJ
	["gasoline"] = "1540KJ", -- 46 МДж/кг, 32,7 МДж/литр
	["kerosene"] = "1436KJ", -- 43 МДж/кг	

  ["petroleum-gas"] = "700KJ",

	
	["gas-natural-1"] = "560KJ",  -- 33,5 МДж/м3 
	["gas-raw-1"] = "500KJ",
	["liquid-ngl"] =  "780KJ",  -- 46,8 МДж/кг

	["gas-methane"] = "558KJ", -- 33,41 МДж/м3 
	["gas-ethane"] = "1000KJ",  -- 59,85 МДж/м3 
	["gas-butane"] = "1900KJ", -- 113,81 МДж/м3 
	
	["gas-propene"] = "760KJ", -- 45,6 МДж/м3 
	["gas-ethylene"] = "800KJ",  -- 48 Мдж/м3
	["gas-benzene"] = "2420KJ", -- 40.45 МДж/кг -- БЕНЗОЛ 


	["gas-butadiene"] = "1896KJ", -- butilene 113,51
	["liquid-ethylbenzene"] = "2616KJ",
	["liquid-styrene"] = "2600KJ", --42,6 МДж/кг
	["liquid-toluene"] = "2616KJ", --156,71 Мдж/м3
	["liquid-phenol"] = "1716KJ", --32.24МДж/кг

	
  	["acetylene"] = "936KJ", -- 56,04 МДж/м3 
	["liquid-polyethylene"] = "1796KJ", --47,2 МДж/кг
	
	["liquid-resin"] = "1896KJ", --44,7 МДж/кг
	["liquid-rubber-masterbatch"] = "1850KJ",
	["liquid-rubber-pre"] = "2150KJ", --33,52 МДж/кг
	["liquid-plastic"] = "1920KJ",  --41,87 МДж/кг

["gas-synthesis"] = "240KJ", -- 11,5 Мдж/м3
["gas-residual"] = "700KJ", -- 42 Мдж/м3	

    ["gas-methanol"] = "360KJ", -- 21,1-22 MДж/кг
	["methanol"] = "360KJ", -- 21,1-22 MДж/кг
	["gas-ethanol"] = "510KJ", --30,6 MДж/кг
    ["acetone"] = "524KJ", -- 31,4 МДж/кг
	["coal-gas"] = "292KJ", -- 17,5 Мдж/м3

	["gas-formaldehyde"] = "280KJ", --17,26 МДж/кг

	["gas-hydrazine"] = "760KJ", --fuel_value = "380KJ", 14644 кДж/кг
	
	["gas-ammonia"] = "310KJ",  --18,6  Мдж/м3
	["gas-hydrogen-sulfide"] = "364KJ",  --21,75  Мдж/м3
	
	
	["sour-gas"] = "304KJ",
	["gas-acid"] = "304KJ",
	
	
	["combustion-mixture1"] = "600KJ",
	["combustion-mixture2"] = "600KJ",
	["diborane"] = "600KJ",	
	["refsyngas"] = "600KJ",
	["xylenol"] = "600KJ",
	
	
	["solid-paper"] = "0.8MJ",
	["wooden-board"] = "1MJ",
	["phenolic-board"] = "4MJ",
	["resin"] = "3.8MJ",
	["plastic-bar"] = "5MJ",
	["rubber"] = "5MJ"
	
 
}

local emissions = {
  ["liquid-multi-phase-oil"] = 15,
  ["crude-oil"] = 10,
  
  ["light-oil"] = 2,
  
  ["heavy-oil"] = 3,
  ["liquid-fuel-oil"] = 1.9,
  ["petroleum-gas"] = 1,
  

  ["diesel-fuel"] = 1.5,
  
  ["gas-hydrogen"] = -2,
  
  ["liquid-fuel-oil"] = 1.2,

	["gas-methane"] = 1.1,
	["gas-ethane"] = 1.5,
    ["gas-butane"] = 1.8,
	
	["gas-residual"] = 4.5,
	
	["liquid-naphtha"] = 3,
	["gas-propene"] = 5,
	["gas-hydrogen"] = -2,
	["gas-hydrazine"] = -1,
	
	["sour-gas"] = 7,
	["gas-acid"] = 7,
	
	["gas-synthesis"] = 0.8,
	["gas-ethylene"] = 2.8,
	["gas-butadiene"] = 3,

	["gas-benzene"] = 6.5,
	["liquid-phenol"] = 6.5,
	["liquid-toluene"] = 6.5,

	
	["gas-ethanol"] = 0.7,
	["liquid-ngl"] = 1.2,
	["liquid-resin"] = 6.5,
	["liquid-rubber-masterbatch"] = 7,
	["liquid-rubber-pre"] = 9,
	["liquid-polyethylene"] = 6.5,
	["liquid-plastic"] = 8,

	["wooden-board"] = 1.1,
	["phenolic-board"] = 4.9,
	["resin"] = 7,
	["plastic-bar"] = 10,
	["rubber"] = 15

}

local parse_energy = function(energy)
  local ending = energy:sub(energy:len())
  if not (ending == "J" or ending == "W") then
    error(ending.. " is not a valid unit of energy")
  end
  local magnitude = energy:sub(energy:len() - 1, energy:len() - 1)
  local multiplier = 1
  if type(magnitude) == "number" then
    return tonumber(energy:sub(1, energy:len()-1))
  end
  local char = {
    k = 1000,
    K = 1000,
    M = 1000000,
    G = 1000000000,
    T = 1000000000000,
    P = 1000000000000000,
    E = 1000000000000000000,
    Z = 1000000000000000000000,
    Y = 1000000000000000000000000
  }
  multiplier = char[magnitude]
  if not multiplier then error(magnitude.. " is not valid magnitude") end
  return tonumber(energy:sub(1, energy:len()-2)) * multiplier
end

local names = {}

for k, fluid in pairs (data.raw.fluid) do
  --if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
  --end
  --if not fluid.emissions_multiplier then
    fluid.emissions_multiplier = emissions[fluid.name]
  --end
end