data:extend({
  {
    type = "item-subgroup",
    name = "crash-site",
    group = "production",
    order = "x"
  },
--[[{
    type = "equipment-grid",
    name = "survival-equipment-grid",
    width = 3,
    height = 3,
    equipment_categories = {"armor"}
  },
    {
    type = "armor",
    name = "survival-armor",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/survival-armor.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "armor",
    order = "aa[light-armor]",
    stack_size = 1,
    infinite = true,
    equipment_grid = "survival-equipment-grid"
  },]]--
  {
    type = "item",
    name = "salvaged-assembling-machine",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-assembling-machine-1-repaired.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "crash-site",
    order = "x[crash-site-assembling-machine-1-broken]",
    place_result = "salvaged-assembling-machine",
    stack_size = 1
  },
  {
    type = "item",
    name = "salvaged-lab",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-lab-repaired.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "crash-site",
    order = "x[crash-site-lab-repaired]",
    place_result = "salvaged-lab",
    stack_size = 1
  },
  {
    type = "item",
    name = "salvaged-generator",
    icon = "__LootingSpaceshipWrecks__/graphics/icons/crash-site-generator.png",
    icon_size = 64, icon_mipmaps = 4,
    subgroup = "crash-site",
    order = "x[crash-site-generator]",
    place_result = "salvaged-generator",
    stack_size = 1
  }
})