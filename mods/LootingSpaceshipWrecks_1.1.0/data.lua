require("prototypes.animations")
require("prototypes.entities")
require("prototypes.items")

-- big hull
    data.raw.container["crash-site-spaceship"].inventory_size = 80

    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-1"].minable = {mining_time = 1, result = "pipe", amount_min = 5, amount_max = 30}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-2"].minable = {mining_time = 1, result = "copper-plate", amount_min = 5, amount_max = 30}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-3"].minable = {mining_time = 1, result = "iron-plate", amount_min = 5, amount_max = 30}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-4"].minable = {mining_time = 1, result = "steel-plate", amount_min = 5, amount_max = 30}

	data.raw.container["crash-site-spaceship"].minable =
	{
      mining_time = 5,
      results=
		{
        --{name="iron-plate", amount = 114},
        --{name="copper-plate", amount = 56},
        {name="steel-plate", amount_min = 5, amount_max = 25},
		{name="iron-gear-wheel", amount_min = 5, amount_max = 20},
        {name="electronic-circuit", amount_min = 4, amount_max = 12},
        {name="concrete", amount_min = 5, amount_max = 85},
        {name="pipe", amount_min = 5, amount_max = 45},
        {name="aluminium-plate", amount_min = 5, amount_max = 85},
        {name="titanium-plate", amount_min = 5, amount_max = 85},
		{name="condensator3", amount_min = 5, amount_max = 25},
		{name="processing-electronics", amount_min = 1, amount_max = 5},
		{name="insulated-cable", amount_min = 11, amount_max = 39},
        {name="salvaged-generator", amount = 1}
		}
    }