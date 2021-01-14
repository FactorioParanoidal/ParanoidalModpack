require("prototypes.animations")
require("prototypes.entities")
require("prototypes.items")

-- big hull
    data.raw.container["crash-site-spaceship"].inventory_size = 80


    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-1"].minable = {mining_time = 0.75, result = "pipe", count = {type = "random", min = 5, max = 30}}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-2"].minable = {mining_time = 0.75, result = "copper-plate", count = {type = "random", min = 5, max = 30}}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-3"].minable = {mining_time = 0.75, result = "iron-plate", count = {type = "random", min = 5, max = 30}}
	
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-4"].minable = {mining_time = 0.75, result = "steel-plate", count = {type = "random", min = 5, max = 50}}

data.raw.container["crash-site-spaceship"].minable =
	{
      mining_time = 5,
      results=
		{
        --{name="iron-plate", amount = 114},
        --{name="copper-plate", amount = 56},
        {name="steel-plate", amount = {type = "random", min = 5, max = 20}},
		{name="iron-gear-wheel", amount = {type = "random", min = 5, max = 20}},
        {name="electronic-circuit", amount = {type = "random", min = 4, max = 12}},
        {name="concrete", amount = {type = "random", min = 5, max = 85}},
        {name="pipe", amount = {type = "random", min = 5, max = 45}},
        {name="aluminium-plate", amount = {type = "random", min = 5, max = 85}},
        {name="titanium-plate", amount = {type = "random", min = 5, max = 85}},
        {name="salvaged-generator", amount = {type = "random", min = 1, max = 2}}
		}
    }