local rpath = (...):match("(.-)[^%.]+$")
local Setting = require(rpath .. "setting")

-- calculate power output, efficiency, bonus cell production

local function calculate_stats_ingo(reactor,state_running_time)
	local temperature = reactor.core.temperature
	local reactor_neighbours = math.min(reactor.neighbours,4)
	local power 
	local power_breeder
	local efficiency
	local BonusCellAmount
	local fuel_cell = reactor.entity.burner.currently_burning
	local bonus_cells_multiplier = 1
	
	reactor.signals.parameters["neighbour-bonus"].count = reactor_neighbours
	
	--set or calculate values
	if reactor.state == 2 and temperature<500 then --running below 500
		
		if reactor_neighbours == 1 then
				power = 30
				power_breeder = 30
			elseif reactor_neighbours == 2 then
				power = 33
				power_breeder = 33
			elseif reactor_neighbours == 3 then
				power = 36
				power_breeder = 36
			else
				power = 39
				power_breeder = 39
			end
		efficiency = 100
		BonusCellAmount = 0
		
	elseif reactor.state == 1 then --start
		local duration = Setting.duration("starting")
		
		if temperature <= 500 then
			--power on a cold reactor
			if reactor_neighbours == 1 then
				power_target = 30
				power_breeder_target = 30
			elseif reactor_neighbours == 2 then
				power_target = 33
				power_breeder_target = 33
			elseif reactor_neighbours == 3 then
				power_target = 36
				power_breeder_target = 36
			else
				power_target = 39
				power_breeder_target = 39
			end
			--power=math.min(((39/duration)*state_running_time)+1,40) -- running time: 0s=1MW, start_duration(default:30s)=40MW
			--power_breeder=math.min(((39/duration)*state_running_time)+1,40) -- running time: 0s=1MW, start_duration(default:30s)=40MW
		else
			-- power on a warm reactor
			power_target = math.max(((1/6)*temperature)-(130/3),40) -- 500°=40MW, 980°=120MW
			power_breeder_target = math.max(((1/12)*temperature)-(5/3),40) --500°=40MW, 980°=80MW
		end
		
		power=math.min((((power_target-1)/duration)*state_running_time)+1,power_target) -- running time: 0s=1MW, start_duration(default:30s)= output of a running reactor at this temp
		power_breeder=math.min((((power_breeder_target-1)/duration)*state_running_time)+1,power_breeder_target) -- running time: 0s=1MW, start_duration(default:30s)= output of a running breeder at this temp
		efficiency=100
		BonusCellAmount=0
		
	elseif reactor.state == 3 then --scram
		local duration = Setting.duration("scram")
		
		power=(((reactor.power_output_last_tick-1)/duration)*(duration-state_running_time))+1 --running time: scram_duration(default:180s)=power_output_last_tick, 0s=1MW
		power_breeder=(((reactor.power_output_last_tick-1)/duration)*(duration-state_running_time))+1 --running time: scram_duration(default:180s)=power_output_last_tick, 0s=1MW
		efficiency=200
		BonusCellAmount=0
		
	else --running above 500
		
		power = math.max(((1/6)*temperature)-(130/3),40) -- 500°=40MW, 980°=120MW
		power_breeder = math.max(((1/12)*temperature)-(5/3),40) --500°=40MW, 980°=80MW
		BonusCellAmount = math.max(((1/680)*temperature)-(15/34),0) --350°=0 Cells, 980°=1 Cell

		if reactor_neighbours==1 then
			-- one reactor
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100)
			else
				efficiency = math.max(-(5/6)*temperature+(2150/3),50)
			end
		
		elseif reactor_neighbours==2 then
			-- two reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100)
			elseif temperature > 620 and temperature <= 740 then
				efficiency = 200
			else
				efficiency = math.max(-(5/6)*temperature+(2450/3),50)
			end
			
		elseif reactor_neighbours==3 then
			-- three reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100)
			elseif temperature > 620 and temperature <= 860 then
				efficiency = 200
			else
				efficiency = math.max(-(5/6)*temperature+(2750/3),50)
			end
			
		else
			-- four reactors
			if temperature <= 620 then
				efficiency = math.max((5/6)*temperature-(950/3),100)
			else
				efficiency = 200
			end
			
		end
		
	end
	
	--reactor count modifier
	power = power*(0.7+0.075*reactor_neighbours)
	power_breeder = power_breeder*(0.7+0.075*reactor_neighbours)
	
	--nerf bonus cell amount depending on what fuel (mods) is used
	if not fuel_cell then
		--nerf nothing
	elseif fuel_cell.name ==  "mox-fuel-cell" and reactor.entity.burner.currently_burning.fuel_value == 8500000000 then --mox
		--SigmaOne's Mods: Nuclear fuel (same stats as uranium power)
		bonus_cells_multiplier = 0.825
		
	elseif fuel_cell.name == "breeder-fuel-cell" then
		--"Plutonium fuel cell" - Nuclear Fuel (4000000000) and "Breeder fuel cell (Pu)" - Nuclear Fuel Cycle (3500000000)
		bonus_cells_multiplier = 0.625
		
	elseif fuel_cell.name == "fuel-assembly-mox" then
		--Uranium Power
		
	elseif fuel_cell.name == "mox-fuel-cell" then
		--"MOX fuel cell" - Advanced Atomics (12000000000) and "MOX fuel cell" - Nuclear Fuel Cycle (8000000000)
		bonus_cells_multiplier = 1.8
		
	elseif fuel_cell.name == "MOX-fuel" then -- by Plutonium Energy
		--"MOX fuel cell" - plutonium energy (20GJ)
		bonus_cells_multiplier = 0.6

	else
		-- default uranium fuel cell or other mods
		if game.active_mods["Nuclear Fuel"] then
			bonus_cells_multiplier = 0.25
		else
			bonus_cells_multiplier = 1
		end
		
	end
	BonusCellAmount = BonusCellAmount * bonus_cells_multiplier
	
	
	-- return values
	if reactor.entity.name == REACTOR_ENTITY_NAME then
		reactor.max_power = 123
		reactor.max_efficiency = 200
		return {power = math.floor(power), efficiency = efficiency, bonus_cells = 0, max_power = 123, max_efficiency = 200}
	end
	if reactor.entity.name == BREEDER_ENTITY_NAME then
		reactor.max_power = 82
		reactor.max_efficiency = 200
		return {power = math.floor(power_breeder), efficiency = efficiency, bonus_cells = BonusCellAmount, max_power = 82, max_efficiency = 200}
	end
	reactor.max_efficiency = 200 --under optimal conditions - 4 reactors
	
end










local function calculate_stats_ownly(reactor,running_time)
	local fuel_cell = reactor.entity.burner.currently_burning
	local fuel_cell_name = ""
	if fuel_cell ~= nil then
		fuel_cell_name = fuel_cell.name
	end
	local temperature = reactor.core.temperature
	local neighbours = reactor.neighbours
	local reactors = neighbours
	reactors = math.min(4,reactors)
-- 	reactors = math.max(1,reactors) -- obsolete since neighbours are always >= 1
	local efficiency
	local output
	local min_efficiency = 1
	local max_efficiency = 200
	local max_output = 150
	local bonus_cells = 0
	local bonus_cells_multiplier = 1
	temperature = math.max(0,temperature - 500)
	-- https://rechneronline.de/funktionsgraphen/

	reactor.signals.parameters["neighbour-bonus"].count = neighbours
	if fuel_cell == nil then
		efficiency=0
		output=0
		
	--SigmaOne's Mods: Nuclear fuel (same stats as uranium power)
	elseif fuel_cell_name ==  "mox-fuel-cell" and reactor.entity.burner.currently_burning.fuel_value == 8500000000 then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		output = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_output = 150
		bonus_cells_multiplier = 0.66

		
	--"Plutonium fuel cell" - Nuclear Fuel (4000000000) and "Breeder fuel cell (Pu)" - Nuclear Fuel Cycle (3500000000)
	elseif fuel_cell_name == "breeder-fuel-cell" then --plutonium (although breeder cells are usually mox i think)
		output = (2.2+temperature*0.034)^0.57*25+10
		efficiency = (2.5+temperature*0.034)^0.45*39.5+45
		min_efficiency = 102
		max_efficiency = 195
		max_output = 145
		bonus_cells_multiplier = 0.5
		
	--Uranium Power & Patched Mad Clowns
	elseif fuel_cell_name == "fuel-assembly-mox" or fuel_cell_name == "rr-clowns-mox-cell" then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		output = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_output = 150
		
	--"MOX fuel cell" - Advanced Atomics (12000000000) and "MOX fuel cell" - Nuclear Fuel Cycle (8000000000)
	elseif fuel_cell_name == "mox-fuel-cell" then --mox
		efficiency = (3+temperature*0.11)^1.19+80
		output = (1+temperature*0.16)^1.08+35
		min_efficiency = 84
		max_efficiency = 205
		max_output = 150
		bonus_cells_multiplier = 1.45

	--Plutonium Energy
-- 	elseif fuel_cell_name == "plutonium-fuel-cell" then --plutonium -- this is pre PlutoniumEnergy 1.0.0
-- 		output = (2.2+temperature*0.034)^0.57*25+10
-- 		efficiency = (2.5+temperature*0.034)^0.45*39.5+45
-- 		min_efficiency = 102
-- 		max_efficiency = 195
-- 		max_output = 145

	-- "MOX fuel cell" - plutonium energy (20GJ)
	elseif fuel_cell_name == "MOX-fuel" then
		efficiency = ((3+temperature*0.11)^1.19+80)
		output = ((1+temperature*0.16)^1.08+35)*0.5
		min_efficiency = 84
		max_efficiency = 205
		max_output = 150*0.5
		bonus_cells_multiplier = 0.6
		
	-- "Thorium fuel cell" - MadClown01's AngelBob Nuclear Extension
	elseif fuel_cell_name == "thorium-fuel-cell" or fuel_cell_name == "apm_breeder_thorium_loaded" or fuel_cell_name == "apm_fuel_rod_thorium" then
		efficiency= 205-(1.5+temperature*0.1)^1.45*0.2
		output = 	155-(1.5+temperature*0.1)^1.6*0.08
		min_efficiency = 79
		max_efficiency = 204
		max_output = 155
		bonus_cells_multiplier = 0.8
		
	elseif fuel_cell_name == "apm_fuel_cell_mox" or fuel_cell_name == "apm_fuel_rod_mox" then
		efficiency = ((3+temperature*0.11)^1.19+80)
		output = ((1+temperature*0.16)^1.08+35)*0.5
		min_efficiency = 84
		max_efficiency = 205
		max_output = 150*0.5
		bonus_cells_multiplier = 0.8
		
	elseif fuel_cell_name:sub(1,22) == "apm_nuclear_fuel_cell_" then
		efficiency=(800+temperature*5)^0.64*0.96+29
		output=(1+temperature*0.07)^1.15*1.52*tonumber(fuel_cell_name:sub(23))/45+45
		min_efficiency = 94
		max_efficiency = 200
		max_output = 138
		
	--Default/other fuel cells 
	else --uranium
		efficiency=(800+temperature*5)^0.64*0.96+29
		output=(1+temperature*0.07)^1.15*1.52+45
		min_efficiency = 94
		max_efficiency = 200
		max_output = 138
		if game.active_mods["Nuclear Fuel"] then
			bonus_cells_multiplier = 0.2
		else
			bonus_cells_multiplier = 0.8
		end
	end

	--breeder
	if reactor.entity.name == BREEDER_ENTITY_NAME then
		bonus_cells = (0.15+(efficiency-min_efficiency)/(max_efficiency-min_efficiency)*0.85)*bonus_cells_multiplier --15% - 100% *multiplier
		output = output /(1+(efficiency-min_efficiency)/(max_efficiency-min_efficiency)*0.75)
		max_output = max_output /(1+(max_efficiency-min_efficiency)/(max_efficiency-min_efficiency)*0.75)
		efficiency = efficiency/(1.15+(efficiency-min_efficiency)/(max_efficiency-min_efficiency)*0.85)
		max_efficiency = max_efficiency/(1.15+(max_efficiency-min_efficiency)/(max_efficiency-min_efficiency)*0.85)
	end
	--reactor count modifier
	efficiency = efficiency*(0.7+0.075*reactors)
	--max_efficiency = math.floor(max_efficiency*(0.7+0.075*reactors))
	output = output / 1.1         -- why did i do this? Oo
	max_output = max_output/1.1   -- why did i do this? Oo
	output = output *(0.5+0.125*reactors)
	max_output = max_output*(0.5+0.125*reactors)
	output = output * (1+neighbours/100)
	max_output = max_output * (1+neighbours/100)
	output = math.min(250,output)
	max_output = math.min(250,max_output)
	
	
	if reactor.state  == 1 then
		local duration = Setting.duration("starting")
		output = math.floor(output * ((running_time)/duration)^2)
		bonus_cells = bonus_cells * ((running_time)/duration)^2
	end
	if reactor.state  == 3 then
		local duration = Setting.duration("scram")
		output = math.floor(reactor.power_output_last_tick * ((duration - (running_time)/3.5)/duration)^11+0.45)
		bonus_cells = bonus_cells * ((duration - (running_time)/3.5)/duration)^11
	end	
	--game.print(output)
	reactor.max_power = max_output
	reactor.max_efficiency = max_efficiency --under optimal conditions - 4 reactors
	if reactor.entity.name == REACTOR_ENTITY_NAME then
		return {power=math.floor(output),efficiency = efficiency, bonus_cells = 0, max_power = max_power, max_efficiency = max_efficiency}
	else
		return {power=math.floor(output),efficiency = efficiency, bonus_cells = bonus_cells, max_power = max_output, max_efficiency = max_efficiency}
	end
end






return { -- exports
	[ "ingo"] = calculate_stats_ingo,
	["ownly"] = calculate_stats_ownly,
}
