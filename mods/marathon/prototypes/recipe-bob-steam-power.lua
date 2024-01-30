data:extend( --DrD
{
  {
    type = "recipe",
    name = "steam-engine-2",
    normal =
    {
	  enabled = false,
      ingredients =
      {  
        {"steam-engine", 2},
        {"steel-plate", 75},
        {"steel-pipe", 25},
        {"steel-gear-wheel", 25},
        {"steel-bearing", 15},
		
      },
      result = "steam-engine-2",
    },
    expensive =
    {
      ingredients =
      {
        {"steam-engine", 2},
        {"steel-plate", 125},
        {"steel-pipe", 25},
        {"steel-gear-wheel", 25},
        {"steel-bearing", 15},
      },
      result = "steam-engine-2",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-3",
    normal =
    {
	  enabled = false,
      ingredients =
      {
        {"steam-engine-2", 2},
        {"brass-pipe", 25},
        {"brass-alloy", 45},
        {"cobalt-steel-gear-wheel", 25},
        {"cobalt-steel-bearing", 15},
      },
      result = "steam-engine-3",
    },
    expensive =
    {
      ingredients =
      {
        {"steam-engine-2", 2},
        {"brass-pipe", 35},
        {"brass-alloy", 85},
        {"cobalt-steel-gear-wheel", 25},
        {"cobalt-steel-bearing", 15},
      },
      result = "steam-engine-3",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-4",
    normal =
    {
	  enabled = false,
      ingredients =
      {
        {"steam-engine-3", 2},
        {"titanium-pipe", 25},
        {"titanium-plate", 40},
        {"titanium-gear-wheel", 25},
        {"titanium-bearing", 20},
      },
      result = "steam-engine-4",
    },
    expensive =
    {
      ingredients =
      {
        {"steam-engine-3", 2},
        {"titanium-pipe", 25},
        {"titanium-plate", 90},
        {"titanium-gear-wheel", 45},
        {"titanium-bearing", 20},
      },
      result = "steam-engine-4",
    }
  },
  {
    type = "recipe",
    name = "steam-engine-5", 
    normal =
    {
	  enabled = false,
      ingredients =
      {
        {"steam-engine-4", 2},
        {"nitinol-pipe", 25},
        {"nitinol-alloy", 40},
        {"nitinol-gear-wheel", 25},
        {"nitinol-bearing", 20},
      },
      result = "steam-engine-5",
    },
    expensive =
    {
      ingredients =
      {
        {"steam-engine-4", 2},
        {"nitinol-pipe", 25},
        {"nitinol-alloy", 80},
        {"nitinol-gear-wheel", 45},
        {"nitinol-bearing", 20},
      },
      result = "steam-engine-5",
    }
  },
}
)

-- TIME TO BUILD REQUIRED --

data.raw.recipe["steam-engine-2"].normal.energy_required = 50
data.raw.recipe["steam-engine-2"].expensive.energy_required = 50
data.raw.recipe["steam-engine-3"].normal.energy_required = 40
data.raw.recipe["steam-engine-3"].expensive.energy_required = 40
data.raw.recipe["steam-engine-4"].normal.energy_required = 30
data.raw.recipe["steam-engine-4"].expensive.energy_required = 30
data.raw.recipe["steam-engine-5"].normal.energy_required = 20
data.raw.recipe["steam-engine-5"].expensive.energy_required = 20

data.raw.recipe["steam-turbine"].normal.energy_required = 120
data.raw.recipe["steam-turbine"].expensive.energy_required = 120
data.raw.recipe["steam-turbine-2"].normal.energy_required = 90
data.raw.recipe["steam-turbine-2"].expensive.energy_required = 90
data.raw.recipe["steam-turbine-3"].normal.energy_required = 60
data.raw.recipe["steam-turbine-3"].expensive.energy_required = 60

data.raw.recipe["boiler-2"].energy_required = 10
data.raw.recipe["boiler-3"].energy_required = 15
data.raw.recipe["boiler-4"].energy_required = 20
data.raw.recipe["boiler-5"].energy_required = 30

data.raw.recipe["nuclear-reactor"].energy_required = 60
data.raw.recipe["nuclear-reactor-2"].energy_required = 120
data.raw.recipe["nuclear-reactor-3"].energy_required = 180

data.raw.recipe["heat-exchanger"].energy_required = 10
data.raw.recipe["heat-exchanger-2"].energy_required = 20
data.raw.recipe["heat-exchanger-3"].energy_required = 30

data.raw.recipe["centrifuge"].energy_required = 50
data.raw.recipe["centrifuge-mk2"].energy_required = 75
data.raw.recipe["centrifuge-mk3"].energy_required = 100

data.raw.recipe["assembling-machine-1"].energy_required = 5

data.raw.recipe["assembling-machine-2"].energy_required = 10
data.raw.recipe["assembling-machine-3"].energy_required = 15
data.raw.recipe["assembling-machine-4"].energy_required = 20
data.raw.recipe["assembling-machine-5"].energy_required = 30
data.raw.recipe["assembling-machine-6"].energy_required = 40
data.raw.recipe["assembling-machine-7"].energy_required = 50
data.raw.recipe["assembling-machine-8"].energy_required = 60
data.raw.recipe["assembling-machine-9"].energy_required = 60

data.raw.recipe["electronics-machine-1"].energy_required = 5
data.raw.recipe["electronics-machine-2"].energy_required = 10
data.raw.recipe["electronics-machine-3"].energy_required = 15
data.raw.recipe["electronics-machine-4"].energy_required = 20
data.raw.recipe["electronics-machine-5"].energy_required = 30

data.raw.recipe["burner-lab"].energy_required = 5