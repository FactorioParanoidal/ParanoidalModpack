	impact_resistance = 
    {
     type = "impact",
     percent = 90,
    }
	
-- fraqueza fogo
    acid_resistances = 
    {
				{
					type = "fire",
					decrease = -10,
					percent =  -250
				},
				{
					type = "explosion",
					decrease = 0,
					percent =  40
				},
				{
					type = "laser",
					decrease = -10,
					percent = -20
				},
				{
					type = "physical",
					decrease = 15,
					percent = 60
				},
				{
					type = "acid",
					decrease = 15,
					percent = 90
				},
				impact_resistance
    }

	-- fraqueza fisica
	fire_resistances = 
	{
				{
					type = "fire",
					decrease = 50,
					percent  = 99
				},
				{
					type = "explosion",
					decrease = 50,
					percent =  80
				},
				{
					type = "laser",
					decrease = 50,
					percent =  50
				},
				{
					type = "electric",
					decrease = 50,
					percent =  50
				},				
				{
					type = "physical",
					decrease = -10,
					percent  = -180
				},
				{
					type = "acid",
					decrease = 0,
					percent = 50
				},
				impact_resistance
	}

	-- fraqueza fogo,acido, veneno
	acidweak_resistances = 
	{
				{
					type = "fire",
					decrease = -10,
					percent =  -150
				},
				{
					type = "explosion",
					decrease = 30,
					percent =  30
				},
				{
					type = "laser",
					decrease = 50,
					percent =  50
				},
				{
					type = "electric",
					decrease = 50,
					percent =  50
				},				
				{
					type = "electric",
					decrease = 40,
					percent  = 70
				},
				{
					type = "physical",
					decrease = 40,
					percent  = 90
				},
				{
					type = "poison",
					decrease = -20,
					percent =  -250
				},	
				{
					type = "acid",
					decrease = -20,
					percent =  -250
				},				
				impact_resistance
	}
	
	energy_resistances =
	{
				{
					type = "fire",
					decrease = -20,
					percent =  -200
				},
				{
					type = "explosion",
					decrease = -30,
					percent = -250
				},
				{
					type = "laser",
					decrease = 90,
					percent = 99
				},
				{
					type = "electric",
					decrease = 90,
					percent =  90
				},				
				{
					type = "physical",
					decrease = 50,
					percent = 90
				},
				impact_resistance
	}


	strong_resistances =
	{
				{
					type = "explosion",
					decrease = 50,
					percent = 50
				},
				{
					type = "fire",
					decrease = 90,
					percent =  90
				},
				{
					type = "laser",
					decrease = -10,
					percent = -200
				},
				{
					type = "electric",
					decrease = -10,
					percent =  -200
				},				
				{
					type = "physical",
					decrease = 50,
					percent =  99
				},
				impact_resistance

	}

	volcano_resistances =
	{
				{
					type = "explosion",
					percent =  50
				},
				{
					type = "fire",
					percent =  100
				},
				{
					type = "laser",
					decrease = 20,
					percent =  20
				},
				{
					type = "electric",
					decrease = 20,
					percent =  20
				},				
				{
					type = "physical",
					percent =  50
				},
				{
					type = "poison",
					percent =  100
				},	
				{
					type = "acid",
					decrease = 20,
					percent =  20
				},					
				impact_resistance

	}	
	
	
	
	
if data.raw["damage-type"]["bob-pierce"] then	
local pierce_resistance = 
    {
        type = "bob-pierce",
        decrease = 15,
        percent = 90,
    }
local pierce_resistance100 = 
    {
        type = "bob-pierce",
        percent = 100,
    }
table.insert(energy_resistances,pierce_resistance)	
table.insert(strong_resistances,pierce_resistance)
table.insert(acidweak_resistances,pierce_resistance)
table.insert(volcano_resistances,pierce_resistance100)
end