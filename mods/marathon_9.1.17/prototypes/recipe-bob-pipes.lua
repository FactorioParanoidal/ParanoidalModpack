data:extend(
{
  {
    type = "recipe",
    name = "stone-pipe",
	hidden = true,
    normal =
    {
      ingredients =
      {
        {"stone-brick", 1}
      },
      result = "stone-pipe",
    },
    expensive =
    {
      ingredients =
      {
        {"stone-brick", 2}
      },
      result = "stone-pipe",
    }
  },

  {
    type = "recipe",
    name = "stone-pipe-to-ground",
	hidden = true,
    ingredients =
    {
      {"stone-pipe", 10},
      {"stone-brick", 5},
    },
    result_count = 2,
    result = "stone-pipe-to-ground",
  },


  {
    type = "recipe",
    name = "copper-pipe",
    normal =
    {
      ingredients =
      {
        {"copper-plate", 4}, --DrD 1
      },
      result = "copper-pipe",
    },
    expensive =
    {
      ingredients =
      {
        {"copper-plate", 8},
      },
      result = "copper-pipe",
    }
  },

  {
    type = "recipe",
    name = "copper-pipe-to-ground",
    ingredients =
    {
      {"copper-pipe", 10},
      {"copper-plate", 15}, --DrD 5
    },
    result_count = 2,
    result = "copper-pipe-to-ground",
  },


  {
    type = "recipe",
    name = "steel-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"steel-plate", 4}, --DrD 1
      },
      result = "steel-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"steel-plate", 8},
      },
      result = "steel-pipe",
    }
  },

  {
    type = "recipe",
    name = "steel-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"steel-pipe", 15}, --DrD  12 5
      {"steel-plate", 15},
    },
    result_count = 2,
    result = "steel-pipe-to-ground",
  },


  {
    type = "recipe",
    name = "plastic-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"plastic-bar", 4}, --DrD 4
      },
      result = "plastic-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"plastic-bar", 8},
      },
      result = "plastic-pipe",
    }
  },

  {
    type = "recipe",
    name = "plastic-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"plastic-pipe", 100}, --DrD
      {"plastic-bar", 200},
    },
    result_count = 2,
    result = "plastic-pipe-to-ground",
  },
}
)


if data.raw.item["bronze-alloy"] then
data:extend(
{
  {
    type = "recipe",
    name = "bronze-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"bronze-alloy", 4}, --DrD 1
      },
      result = "bronze-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"bronze-alloy", 8},
      },
      result = "bronze-pipe",
    }
  },

  {
    type = "recipe",
    name = "bronze-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"bronze-pipe", 15},
      {"bronze-alloy", 15},
    },
    result_count = 2,
    result = "bronze-pipe-to-ground",
  },
}
)
end


if data.raw.item["brass-alloy"] then
data:extend(
{
  {
    type = "recipe",
    name = "brass-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"brass-alloy", 4}, --DrD 1
      },
      result = "brass-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"brass-alloy", 8},
      },
      result = "brass-pipe",
    }
  },

  {
    type = "recipe",
    name = "brass-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"brass-pipe", 20},
      {"brass-alloy", 15},
    },
    result_count = 2,
    result = "brass-pipe-to-ground",
  },
}
)
end


if data.raw.item["silicon-nitride"] then
data:extend(
{
  {
    type = "recipe",
    name = "ceramic-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"silicon-nitride", 4}, --DrD 1
      },
      result = "ceramic-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"silicon-nitride", 8},
      },
      result = "ceramic-pipe",
    }
  },

  {
    type = "recipe",
    name = "ceramic-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"ceramic-pipe", 25},
      {"silicon-nitride", 15},
    },
    result_count = 2,
    result = "ceramic-pipe-to-ground",
  },
}
)
end


if data.raw.item["titanium-plate"] then
data:extend(
{
  {
    type = "recipe",
    name = "titanium-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"titanium-plate", 2},
      },
      result = "titanium-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"titanium-plate", 4},
      },
      result = "titanium-pipe",
    }
  },

  {
    type = "recipe",
    name = "titanium-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"titanium-pipe", 25}, --DrD
      {"titanium-plate", 10},
    },
    result_count = 2,
    result = "titanium-pipe-to-ground",
  },
}
)
end


if data.raw.item["tungsten-plate"] then
data:extend(
{
  {
    type = "recipe",
    name = "tungsten-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"tungsten-plate", 2}, --DrD
      },
      result = "tungsten-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"tungsten-plate", 4},
      },
      result = "tungsten-pipe",
    }
  },

  {
    type = "recipe",
    name = "tungsten-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"tungsten-pipe", 25}, --DrD
      {"tungsten-plate", 10},
    },
    result_count = 2,
    result = "tungsten-pipe-to-ground",
  },
}
)
end


if data.raw.item["nitinol-alloy"] then
data:extend(
{
  {
    type = "recipe",
    name = "nitinol-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"nitinol-alloy", 2},--DrD
      },
      result = "nitinol-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"nitinol-alloy", 4},
      },
      result = "nitinol-pipe",
    }
  },

  {
    type = "recipe",
    name = "nitinol-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"nitinol-pipe", 250},--DrD
      {"nitinol-alloy", 100},
    },
    result_count = 2,
    result = "nitinol-pipe-to-ground",
  },
}
)
end


if data.raw.item["copper-tungsten-alloy"] then
data:extend(
{
  {
    type = "recipe",
    name = "copper-tungsten-pipe",
    normal =
    {
      enabled = false,
      ingredients =
      {
        {"copper-tungsten-alloy", 2},--DrD
      },
      result = "copper-tungsten-pipe",
    },
    expensive =
    {
      enabled = false,
      ingredients =
      {
        {"copper-tungsten-alloy", 4},
      },
      result = "copper-tungsten-pipe",
    }
  },

  {
    type = "recipe",
    name = "copper-tungsten-pipe-to-ground",
    enabled = false,
    ingredients =
    {
      {"copper-tungsten-pipe", 250},--DrD
      {"copper-tungsten-alloy", 100},
    },
    result_count = 2,
    result = "copper-tungsten-pipe-to-ground",
  },
---------- drd added more
  {
      type = "recipe",
    name = "bob-small-inline-storage-tank",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"iron-plate", 25}, --DrD
      {"pipe", 4}, --DrD
    },
    result = "bob-small-inline-storage-tank"
  },
  
  {
    type = "recipe",
    name = "bob-small-storage-tank",
    energy_required = 2,
    enabled = false,
    ingredients =
    {
      {"iron-plate", 25}, --DrD
      {"pipe", 8}, --DrD
    },
    result = "bob-small-storage-tank"
  },
  
}
)
end
