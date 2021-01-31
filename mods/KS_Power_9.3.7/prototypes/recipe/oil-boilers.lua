data:extend({
 {
    type = "recipe",
    name = "oil-steam-boiler",
    enabled = false,
    energy_required = 15,
    ingredients =
    {
      {"boiler", 1},
	  {"basic-circuit-board", 5},
	  {"copper-plate", 50},
      {"stone-brick", 10},
    },
    result = "oil-steam-boiler"
 },
 {
    type = "recipe",
    name = "oil-steam-boiler-2",
    enabled = false,
    energy_required = 20,
    ingredients =
    {
	  {"boiler-2", 1},
      {"oil-steam-boiler", 1},
      {"steel-plate", 15},
	  {"basic-circuit-board", 10},
      {"concrete", 20},
    },
    result = "oil-steam-boiler-2"
 },
 {
    type = "recipe",
    name = "oil-steam-boiler-3",
    enabled = false,
    energy_required = 25,
    ingredients =
    {
	  {"boiler-3", 1},
      {"oil-steam-boiler-2", 1},
      {"invar-alloy", 15},
	  {"brass-pipe", 10},
      {"electronic-circuit", 10},
    },
    result = "oil-steam-boiler-3"
 },
 {
    type = "recipe",
    name = "oil-steam-boiler-4",
    enabled = false,
    energy_required = 30,
    ingredients =
    {
	  {"boiler-4", 1},
      {"oil-steam-boiler-3", 1},
      {"titanium-plate", 15},
	  {"titanium-pipe", 10},
	  {"advanced-circuit", 8},
    },
    result = "oil-steam-boiler-4"
 },
 {
    type = "recipe",
    name = "oil-steam-boiler-5",
    enabled = false,
    energy_required = 40,
    ingredients =
    {
	  {"boiler-5", 1},
      {"oil-steam-boiler-4", 1},
      {"copper-tungsten-alloy", 15},
	  {"copper-tungsten-pipe", 10},
    },
    result = "oil-steam-boiler-5"
 },
})