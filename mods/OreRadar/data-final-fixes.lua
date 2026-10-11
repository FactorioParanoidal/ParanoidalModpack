-- As in 1.1, follow whichever technology unlocks the standard radar.
if data.raw.recipe.radar.enabled == false then
  local prerequisites = {}
  for name, technology in pairs(data.raw.technology) do
    for _, effect in pairs(technology.effects or {}) do
      if effect.type == "unlock-recipe" and effect.recipe == "radar" then
        prerequisites[#prerequisites + 1] = name
        break
      end
    end
  end
  table.sort(prerequisites)
  if #prerequisites > 0 then
    data.raw.recipe["ore-radar"].enabled = false
    data:extend({{
      type = "technology", name = "ore-radar",
      icons = {{icon = "__OreRadar__/graphics/ore_radar_tech.png", icon_size = 256}},
      prerequisites = prerequisites,
      effects = {{type = "unlock-recipe", recipe = "ore-radar"}},
      unit = {count = 100, ingredients = {{"automation-science-pack", 1}}, time = 60}
    }})
  end
end
