if settings.startup["bobmods-power-steam"].value == true then

data:extend(
{
  {
    type = "recipe",
    name = "steam-engine-2",
    normal =
    {
      enabled = false,
      ingredients =
      {  
        {"steam-engine", 1},
        {"steel-plate", 75}, --DrD
        {"pipe", 25}, --DrD
        {"iron-gear-wheel", 25},
      },
      result = "steam-engine-2",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"steam-engine", 1},
        {"steel-plate", 125}, --DrD
        {"pipe", 25},
        {"iron-gear-wheel", 10},
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
        {"steam-engine-2", 1},
        {"pipe", 25},--DrD
        {"steel-plate", 45}, --DrD
        {"iron-gear-wheel", 25},--DrD
      },
      result = "steam-engine-3",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"steam-engine-2", 1},
        {"pipe", 25},
        {"steel-plate", 85},
        {"iron-gear-wheel", 10},
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
        {"steam-engine-3", 1},
        {"pipe", 25},--DrD
        {"steel-plate", 25}, --DrD
        {"iron-gear-wheel", 25},--DrD
      },
      result = "steam-engine-4",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"steam-engine-3", 1},
        {"pipe", 25},--DrD
        {"steel-plate", 35},  --DrD
        {"iron-gear-wheel", 10},
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
        {"steam-engine-4", 1},
        {"pipe", 25},--DrD
        {"steel-plate", 25},  --DrD
        {"iron-gear-wheel", 25},--DrD
      },
      result = "steam-engine-5",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"steam-engine-4", 1},
        {"pipe", 5},
        {"steel-plate", 25},
        {"iron-gear-wheel", 10},
      },
      result = "steam-engine-5",
    }
  },
}
)

end
