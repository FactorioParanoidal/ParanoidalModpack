local fuel_values = {
  --["crude-oil"] = "1.4MJ",
  --["light-oil"] = "1.5MJ",
  --["heavy-oil"] = "1MJ",
  --["petroleum-gas"] = "1.5MJ",
  --["diesel-fuel"] = "2MJ",

-- coefficient *8.35 above natural;  8.35*x (kg/liquid , m3/gas)

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

local emissions = {
  ["crude-oil"] = 1.4,
  ["light-oil"] = 1.2,
  ["heavy-oil"] = 1.3,
  ["petroleum-gas"] = 1,
  ["diesel-fuel"] = 0.8,
  
  ["gas-hydrogen"] = 0.05,
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
  if not fluid.fuel_value then
    fluid.fuel_value = fuel_values[fluid.name]
  end
  if not fluid.emissions_multiplier then
    fluid.emissions_multiplier = emissions[fluid.name]
  end
end