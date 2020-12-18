data:extend({
{
  type = "technology",
  name = "OilBurning",
  icon = "__KS_Power__/graphics/technology/oil-boiler-tech-1.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler"
  }},
  prerequisites = {"oil-processing"},
  unit =
  {
    count = 20,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  },
  order = "f-b-c",
},
{
  type = "technology",
  name = "OilBurning-2",
  icon = "__KS_Power__/graphics/technology/oil-boiler-tech-2.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler-2"
  }},
  prerequisites = {"OilBurning","concrete"},
  unit =
  {
    count = 200,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1}
    },
    time = 30
  },
  order = "f-b-c",
},
{
  type = "technology",
  name = "OilBurning-3",
  icon = "__KS_Power__/graphics/technology/oil-boiler-tech-3.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler-3"
  }},
  prerequisites = {"OilBurning-2"},
  unit =
  {
    count = 300,
    ingredients =
    {
      {"automation-science-pack", 1},
      {"logistic-science-pack", 1},
	  {"chemical-science-pack", 1}
    },
    time = 30
  },
  order = "f-b-c",
},
{
  type = "technology",
  name = "OilBurning-4",
  icon = "__KS_Power__/graphics/technology/oil-boiler-tech-4.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler-4"
  }},
  prerequisites = {"OilBurning-3"},
  unit =
  {
    count = 500,
    ingredients =
    {
      {"automation-science-pack", 2},
      {"logistic-science-pack", 2},
	  {"chemical-science-pack", 2}
    },
    time = 60
  },
  order = "f-b-c",
},
{
  type = "technology",
  name = "OilBurning-5",
  icon = "__KS_Power__/graphics/technology/oil-boiler-tech-5.png",
  icon_size = 128,
  effects ={
  {
    type = "unlock-recipe",
    recipe = "oil-steam-boiler-5"
  }},
  prerequisites = {"OilBurning-4"},
  unit =
  {
    count = 500,
    ingredients =
    {
      {"automation-science-pack", 2},
      {"logistic-science-pack", 2},
	  {"chemical-science-pack", 2},
	  {"production-science-pack", 2}
    },
    time = 60
  },
  order = "f-b-c",
}
})