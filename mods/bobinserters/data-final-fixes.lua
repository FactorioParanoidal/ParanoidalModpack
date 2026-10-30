if settings.startup["bobmods-inserters-long1"].value == true then
  for _, inserter in pairs(data.raw.inserter) do
    if inserter.fast_replaceable_group == "long-handed-inserter" then
      inserter.fast_replaceable_group = "inserter"
    end
  end
end

-- Paranoidal: these technologies change only the inserter configuration window, so their result shows a
-- "nothing" effect with an icon and a text of what they unlock (control.lua checks the same names).
local adjustment_effects = {
  ["bob-long-inserters-1"] = "long-inserters",
  ["bob-long-inserters-2"] = "long-inserters-2",
  ["bob-near-inserters"] = "near-inserters",
  ["bob-more-inserters-1"] = "more-inserters",
  ["bob-more-inserters-2"] = "more-inserters",
}
for name, icon in pairs(adjustment_effects) do
  local technology = data.raw.technology[name]
  if technology then
    technology.effects = technology.effects or {}
    table.insert(technology.effects, 1, {
      type = "nothing",
      effect_description = { "modifier-description.bobmods-inserters-" .. name },
      icon = "__bobinserters__/graphics/icons/technology/" .. icon .. ".png",
      icon_size = 128,
    })
  end
end
