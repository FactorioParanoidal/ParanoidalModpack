if bobmods.logistics then
  data.raw.item["steam-inserter"].icon = "__steam-inserter-patch__/graphics/icons/straight-steam-inserter.png"
  data.raw.item["steam-inserter"].icon_size = 64
  data.raw.item["steam-inserter"].icon_mipmaps = 1
  data.raw.item["steam-inserter"].subgroup = "bob-logistic-tier-0"
  data.raw.item["steam-inserter"].order = "e[inserter]-1[steam-inserter]"
else
data:extend(
{
  {
    type = "item",
    name = "steam-inserter",
    icon = "__steam-inserter-patch__/graphics/icons/straight-steam-inserter.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = "bob-logistic-tier-0",
    order = "e[inserter]-1[steam-inserter]",
    place_result = "steam-inserter",
    stack_size = 50
  },
}
)
end

data:extend(
{
  {
    type = "item",
    name = "corner-steam-inserter",
    icon = "__steam-inserter-patch__/graphics/icons/corner-steam-inserter.png",
    icon_size = 64, icon_mipmaps = 1,
    subgroup = "bob-logistic-tier-0",
    order = "e[inserter]-1[steam-inserter]",
    place_result = "corner-steam-inserter",
    stack_size = 50
  },
}
)
