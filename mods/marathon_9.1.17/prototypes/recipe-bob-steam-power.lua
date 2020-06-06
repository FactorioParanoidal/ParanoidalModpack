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