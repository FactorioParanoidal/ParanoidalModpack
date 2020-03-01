data:extend(
{
  {
    type = "recipe",
    name = "storage-tank-2",
    energy_required = 4,
    enabled = false,
    ingredients =
    {
      {"storage-tank", 1},
      {"steel-plate", 20},
    },
    result= "storage-tank-2"
  },

  {
    type = "recipe",
    name = "storage-tank-3",
    energy_required = 5,
    enabled = false,
    ingredients =
    {
      {"storage-tank-2", 1},
      {"steel-plate", 20},
    },
    result= "storage-tank-3"
  },

  {
    type = "recipe",
    name = "storage-tank-4",
    energy_required = 6,
    enabled = false,
    ingredients =
    {
      {"storage-tank-3", 1},
      {"steel-plate", 20},
    },
    result= "storage-tank-4"
  },
}
)

