for _, tweak in pairs 
  {
	{
		name = "bob-plasma-turret-1",
		health = 2000,
		drain = "4800kW",
		buffer_capacity = "420000kJ",
		input_flow_limit = "20000kW",
		energy_consumption = "400000kJ"
	},
	{ 
		name = "bob-plasma-turret-2",
		health = 2200,
		drain = "6000kW",
		buffer_capacity = "1020000kJ",
		input_flow_limit = "66667kW",
		energy_consumption = "500000kJ"
	},
	{ 
		name = "bob-plasma-turret-3",
		health = 2400,
		drain = "7200kW",
		buffer_capacity = "1820000kJ",
		input_flow_limit = "150000kW",
		energy_consumption = "600000kJ"
	},
	{
		name = "bob-plasma-turret-4",
		health = 2600,
		drain = "8400kW",
		buffer_capacity = "2820000kJ",
		input_flow_limit = "280000kW",
		energy_consumption = "700000kJ"
	},
	{
		name = "bob-plasma-turret-5",
		health = 4000,
		drain = "9600kW",
		buffer_capacity = "4020000kJ",
		input_flow_limit = "400000kW",
		energy_consumption = "800000kJ"
	}
  } do

  local turret = data.raw["electric-turret"][tweak.name]
  if turret then
    turret.max_health = tweak.health
    turret.energy_source.buffer_capacity = tweak.buffer_capacity
    turret.energy_source.input_flow_limit = tweak.input_flow_limit
    turret.energy_source.drain = tweak.drain
    turret.attack_parameters.ammo_type.energy_consumption = tweak.energy_consumption
  end  
end
