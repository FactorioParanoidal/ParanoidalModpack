data:extend(
{
	{
		type = "recipe",
		name = "hypernuclear-fuel",
		energy_required = 60,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="strontium-90", amount=1},
			{type="item", name="nuclear-fuel", amount=1}
		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 0.07, g = 0.95, b = 0.70}, -- hyperfuel
			secondary = {r = 0.89, g = 0.32, b = 0.95}, --strontium
			tertiary = {r = 0, g = 1, b = 0}, --uranium
		},
		results = {{type="item", name="hypernuclear-fuel", amount=1}}
	},
	{
		type = "recipe",
		name = "turbonuclear-fuel",
		energy_required = 60,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="protactinium-231", amount=1},
			{type="item", name="hypernuclear-fuel", amount=1}
		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 0.09, g = 0.36, b = 0.09}, -- turbonuclear fuel
			secondary = {r = 1, g = 0.38, b = 0.18}, --protactinium
			tertiary = {r = 0.07, g = 0.95, b = 0.70}, --hyperfuel
		},
		results = {{type="item", name="turbonuclear-fuel", amount=1}}
	},

	{
		type = "recipe",
		name = "radiothermal-fuel",
		energy_required = 60,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="lead-plate", amount=10},
			{type="item", name="plutonium-239", amount=1}

		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 0.92, g = 0.72, b = 0.09}, --radiothermal fuel/thorium fuel
			secondary = {r = 0.75, g = 1, b = 1}, --lead plate
			tertiary = {r = 1, g = 0.7, b = 0}, --plutonium
		},
		results = {{type="item", name="radiothermal-fuel", amount=1}}
	},
	{
		type = "recipe",
		name = "superradiothermal-fuel",
		energy_required = 60,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="polonium-210", amount=1},
			{type="item", name="radiothermal-fuel", amount=1}
		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 0.92, g = 0.36, b = 0.92}, -- superradiothermal fuel
			secondary = {r = 0.93, g = 0.24, b = 0.38}, -- polonium
			tertiary = {r = 0.92, g = 0.72, b = 0.09}, -- radiothermal fuel
		},
		results = {{type="item", name="superradiothermal-fuel", amount=1}}
	},
	{
		type = "recipe",
		name = "ultraradiothermal-fuel",
		energy_required = 60,
		enabled = false,
		category = "centrifuging",
		ingredients =
		{
			{type="item", name="caesium-137", amount=1},
			{type="item", name="superradiothermal-fuel", amount=1}
		},
		icon_size = 32,
		crafting_machine_tint =
		{
			primary = {r = 1, g = 0.38, b = 0.18}, -- ultraradiothermal fuel
			secondary = {r = 0.75, g = 0.78, b = 0.73}, -- caesium
			tertiary = {r = 0.92, g = 0.36, b = 0.91}, -- superrad
		},
		results = {{type="item", name="ultraradiothermal-fuel", amount=1}}
	},
}
)
