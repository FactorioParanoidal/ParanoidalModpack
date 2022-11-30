data:extend{
	-- Factory buildings
	{
		type = 'recipe',
		name = 'factory-1',
		enabled = false,
		energy_required = 30,
		ingredients = {{'stone', 500}, {'iron-plate', 500}, {'copper-plate', 200}},
		result = 'factory-1-raw'
	},
	{
		type = 'recipe',
		name = 'factory-2',
		enabled = false,
		energy_required = 45,
		ingredients = {{'stone-brick', 1000}, {'steel-plate', 250}, {'big-electric-pole', 50}},
 		result = 'factory-2-raw'
	},
	{
		type = 'recipe',
		name = 'factory-3',
		enabled = false,
		energy_required = 60,
		ingredients = {{'concrete', 5000}, {'steel-plate', 2000}, {'substation', 100}},
		result = 'factory-3-raw'
	},
	-- Utilities
	{
		type = 'recipe',
		name = 'factory-circuit-connector',
		enabled = false,
		energy_required = 1,
		ingredients = {{'electronic-circuit', 2}, {'copper-cable', 5}},
		result = 'factory-circuit-connector'
	}
}
