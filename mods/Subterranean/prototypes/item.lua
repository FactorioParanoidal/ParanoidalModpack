local items = {
  {"subterranean-belt", "underground-belt", "bob-logistic-tier-1", "b[underground-belt]-a[underground-belt]"},
  {"fast-subterranean-belt", "fast-underground-belt", "bob-logistic-tier-2", "b[underground-belt]-b[fast-underground-belt]"},
  {"express-subterranean-belt", "express-underground-belt", "bob-logistic-tier-3", "b[underground-belt]-c[express-underground-belt]"},
  {"subterranean-pipe", "pipe-to-ground", "bob-pipe-to-ground", "a[pipe]-b[pipe-to-ground]-5-3"},
}

for _, spec in ipairs(items) do
  data:extend({{
    type = "item",
    name = spec[1],
    icon = "__Subterranean__/graphics/icons/" .. spec[2] .. ".png",
    icon_size = 32,
    subgroup = spec[3],
    order = spec[4],
    place_result = spec[1],
    stack_size = 50,
  }})
end
