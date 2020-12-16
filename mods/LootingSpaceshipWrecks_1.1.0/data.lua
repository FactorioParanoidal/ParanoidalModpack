require("prototypes.animations")
require("prototypes.entities")
require("prototypes.items")

-- big hull
    data.raw.container["crash-site-spaceship"].inventory_size = 80


    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-1"].minable = {mining_time = 0.75, result = "concrete", count = 50}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-2"].minable = {mining_time = 0.75, result = "copper-plate", count = 20}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-3"].minable = {mining_time = 0.75, result = "iron-plate", count = 20}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-4"].minable = {mining_time = 0.75, result = "steel-plate", count = 35}

data.raw.container["crash-site-spaceship"].minable =
	{
      mining_time = 0.5 * 10,
      results=
		{
        --{name="iron-plate", amount = 114},
        --{name="copper-plate", amount = 56},
        {name="steel-plate", amount = 15},
		{name="iron-gear-wheel", amount = 14},
        {name="electronic-circuit", amount = 8},
        {name="pipe", amount = 45},
        {name="aluminium-plate", amount = 45},
        {name="titanium-plate", amount = 45},
        {name="salvaged-generator", amount = 1}
		}
    }