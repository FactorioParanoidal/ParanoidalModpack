local function convertPath(path)
  return path:gsub("__core__", "__DarkNight__") -- Mod change
end

for _, table in pairs(data.raw["utility-constants"]["default"].daytime_color_lookup) do
  table[2] = convertPath(table[2])
end

for _, table in pairs(data.raw["utility-constants"]["default"].zoom_to_world_daytime_color_lookup) do
  table[2] = convertPath(table[2])
end
