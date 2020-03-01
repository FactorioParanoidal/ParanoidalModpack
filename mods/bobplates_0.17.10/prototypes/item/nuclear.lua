if data.raw.item["thorium-ore"] then

data:extend(
{
  {
    type = "item",
    name = "thorium-232",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-232.png",
    icon_size = 32,
    subgroup = "bob-material",
    order = "r[thorium-232]",
    stack_size = 100
  },
  {
    type = "item",
    name = "plutonium-239",
    icon = "__bobplates__/graphics/icons/nuclear/plutonium-239.png",
    icon_size = 32,
    subgroup = "bob-material",
    order = "r[plutonium-239]",
    stack_size = 100
  },
  {
    type = "item",
    name = "thorium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[thorium-processing]-a[thorium-fuel-cell-1]",
    fuel_category = "nuclear",
    burnt_result = "used-up-thorium-fuel-cell",
    fuel_value = "6GJ",
    fuel_glow_color = {r = 1, g = 1, b = 0},
    stack_size = 50
  },
  {
    type = "item",
    name = "thorium-plutonium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/thorium-plutonium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[thorium-processing]-a[thorium-fuel-cell-2]",
    fuel_category = "nuclear",
    burnt_result = "used-up-thorium-fuel-cell",
    fuel_value = "40GJ",
    fuel_glow_color = {r = 1, g = 0.7, b = 0},
    stack_size = 50
  },
  {
    type = "item",
    name = "used-up-thorium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/used-up-thorium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "s[used-up-thorium-fuel-cell]",
    stack_size = 50
  }
}
)

end

data:extend(
{
  {
    type = "item",
    name = "deuterium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/deuterium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "t[deuterium-processing]-a[deuterium-fuel-cell]",
    fuel_category = "nuclear",
    burnt_result = "used-up-deuterium-fuel-cell",
    fuel_value = "100GJ",
    fuel_glow_color = {r = 1, g = 0, b = 0.57},
    stack_size = 50
  },
  {
    type = "item",
    name = "used-up-deuterium-fuel-cell",
    icon = "__bobplates__/graphics/icons/nuclear/used-up-deuterium-fuel-cell.png",
    icon_size = 32,
    subgroup = "intermediate-product",
    order = "t[used-up-deuterium-fuel-cell]",
    stack_size = 50
  }
}
)

if settings.startup["bobmods-plates-bluedeuterium"].value == true then
  data.raw.item["deuterium-fuel-cell"].fuel_glow_color = {r = 0, g = 0.7, b = 1}
  data.raw.item["deuterium-fuel-cell"].icon = "__bobplates__/graphics/icons/nuclear/deuterium-fuel-cell-blue.png"
  data.raw.item["used-up-deuterium-fuel-cell"].icon = "__bobplates__/graphics/icons/nuclear/used-up-deuterium-fuel-cell-blue.png"
end
