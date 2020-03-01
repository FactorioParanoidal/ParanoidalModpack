data.raw.item["storage-tank"].order = "b[fluid]-a[storage-tank-1]"
data.raw.item["storage-tank"].subgroup = "bob-storage-tank"

data:extend(
{
  {
    type = "item",
    name = "storage-tank-2",
    icon = "__base__/graphics/icons/storage-tank.png",
    icon_size = 32,
    subgroup = "bob-storage-tank",
    order = "b[fluid]-a[storage-tank-2]",
    place_result = "storage-tank-2",
    stack_size = 50
  },

  {
    type = "item",
    name = "storage-tank-3",
    icon = "__base__/graphics/icons/storage-tank.png",
    icon_size = 32,
    subgroup = "bob-storage-tank",
    order = "b[fluid]-a[storage-tank-3]",
    place_result = "storage-tank-3",
    stack_size = 50
  },

  {
    type = "item",
    name = "storage-tank-4",
    icon = "__base__/graphics/icons/storage-tank.png",
    icon_size = 32,
    subgroup = "bob-storage-tank",
    order = "b[fluid]-a[storage-tank-4]",
    place_result = "storage-tank-4",
    stack_size = 50
  },
}
)


