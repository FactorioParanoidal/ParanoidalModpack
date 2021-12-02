--[[ Copyright (c) 2019 robot256 (MIT License)
 * Project: Multiple Unit Train Control
 * File: technology.lua
 * Description: Adds Technology to unlock MU control features.
--]]


data:extend{
  ------------
  -- Add New Technologies for MU Control
  {
    type = "technology",
	name = "multiple-unit-train-control",
	icon = "__MultipleUnitTrainControl__/graphics/icons/mu-control.png",
	icon_size = 128,
	prerequisites = {"automated-rail-transportation","electronics"},
	effects = {},  -- Handled by mod scripting
	unit =  -- Intended to be early-game upgrade for simple railroads
	{
	  count = 150,
	  ingredients = {
	    {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
	  time = 30
	},
	order = "c-g-c"
  },
  {
    type = "technology",
	name = "adv-multiple-unit-train-control",
	icon = "__MultipleUnitTrainControl__/graphics/icons/adv-mu-control.png",
	icon_size = 128,
	prerequisites = {"multiple-unit-train-control","advanced-electronics"},
	effects = {},  -- Handled by mod scripting
	unit =  -- Wireless mode after you get advanced circuits.
	{
	  count = 250,
	  ingredients = {
	    {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
		{"chemical-science-pack", 1}
      },
	  time = 30
	},
	order = "c-g-c"
  },

  -----------------
  -- Add dummy technology to catalog the MU conversions
  {
    type = "technology",
	name = "multiple-unit-train-control-locomotives",
	icon = "__MultipleUnitTrainControl__/graphics/icons/mu-control.png",
	icon_size = 128,
	enabled = false,
	effects = 
	{
      
    },
    unit =
    {
      count = 8,
      ingredients = {{"automation-science-pack", 1}},
      time = 1
    },
    order = "c-a"
  },
}
