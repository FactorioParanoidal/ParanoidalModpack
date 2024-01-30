require("prototypes.animations")
require("prototypes.entities")
require("prototypes.items")

-- big hull
    data.raw.container["crash-site-spaceship"].inventory_size = 80

    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-1"].minable = {mining_time = 3, results = {{name="iron-plate", amount_min = 2, amount_max = 30}}}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-2"].minable = {mining_time = 3, results = {{name="copper-plate", amount_min = 2, amount_max = 30}}}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-3"].minable = {mining_time = 3, results = {{name="pipe", amount_min = 2, amount_max = 30}}}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-4"].minable = {mining_time = 3, results = {{name="steel-plate", amount_min = 2, amount_max = 30}}}
	data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-5"].minable = {mining_time = 3, results = {{name="iron-plate", amount_min = 2, amount_max = 30}}}
    data.raw["simple-entity-with-owner"]["crash-site-spaceship-wreck-small-6"].minable = {mining_time = 3, results = {{name="copper-plate", amount_min = 2, amount_max = 30}}}
	
    data.raw.container["crash-site-spaceship-wreck-big-1"].minable = {
      mining_time = 5,
      results={
        {name="steel-plate", amount_min = 2, amount_max = 8},
		{name="iron-plate", amount_min = 15, amount_max = 35},
        {name="aluminium-plate", amount_min = 5, amount_max = 25},
        {name="titanium-plate", amount_min = 5, amount_max = 10}
	}}
	
    data.raw.container["crash-site-spaceship-wreck-big-2"].minable = {
      mining_time = 5,
      results={
        {name="electronic-circuit", amount_min = 1, amount_max = 5},
		{name="rocket-fuel", amount_min = 2, amount_max = 10},
        {name="pipe", amount_min = 5, amount_max = 15},
        {name="titanium-plate", amount_min = 5, amount_max = 10}
	}}

    data.raw.container["crash-site-spaceship-wreck-medium-2"].minable = {
      mining_time = 4,
      results={
        {name="electronic-circuit", amount_min = 1, amount_max = 2},
		{name="rocket-fuel", amount_min = 1, amount_max = 4},
        {name="pipe", amount_min = 2, amount_max = 5},
        {name="titanium-plate", amount_min = 1, amount_max = 4}
	}}

    data.raw.container["crash-site-spaceship-wreck-medium-1"].minable = {
      mining_time = 4,
      results={
        {name="sci-component-1", amount_min = 1, amount_max = 10},
		{name="sci-component-2", amount_min = 1, amount_max = 4},
		{name="copper-cable", amount_min = 25, amount_max = 55},
        {name="CW-air-filter", amount_min = 5, amount_max = 15}
	}}

    data.raw.container["crash-site-spaceship-wreck-medium-3"].minable = {
      mining_time = 4,
      results={
        {name="steel-plate", amount_min = 2, amount_max = 6},
		{name="iron-plate", amount_min = 5, amount_max = 25},
        {name="aluminium-plate", amount_min = 1, amount_max = 10},
        {name="titanium-plate", amount_min = 1, amount_max = 5}
	}}

	data.raw.container["crash-site-spaceship"].minable =
	{
      mining_time = 5,
      results={
        --{name="iron-plate", amount = 114},
        --{name="copper-plate", amount = 56},
        {name="steel-plate", amount_min = 5, amount_max = 25},
		{name="iron-gear-wheel", amount_min = 5, amount_max = 20},
        {name="electronic-circuit", amount_min = 4, amount_max = 12},
        {name="concrete", amount_min = 25, amount_max = 85},
        {name="pipe", amount_min = 5, amount_max = 45},
        {name="aluminium-plate", amount_min = 5, amount_max = 85},
        {name="titanium-plate", amount_min = 5, amount_max = 85},
		{name="condensator3", amount_min = 5, amount_max = 35},
		{name="processing-electronics", amount_min = 1, amount_max = 5},
		{name="insulated-cable", amount_min = 11, amount_max = 39},
        {name="salvaged-generator", amount = 1}
	}}
	