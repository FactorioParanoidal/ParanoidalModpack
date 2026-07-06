for material, tech_data in pairs(textplates.technologies) do
  local prerequisite
  for _, potential_prerequisite in pairs(tech_data.prerequisite) do
    if data.raw.technology[potential_prerequisite] then
      prerequisite = potential_prerequisite
      break
    end
  end
  if prerequisite then
    local prerequisite_tech = data.raw.technology[prerequisite]

    local textplate_tech = {
      type = "technology",
      name = "textplates-"..material,
      effects = {
      },
      icon = "__textplates__/graphics/entity/"..material.."/t.png",
      icon_size = 128,
      --order = "a",
      prerequisites = {prerequisite},
      localised_name = { "technology-name.textplate", {"textplates.".. material.."-C"} }
    }

    if prerequisite_tech.unit then
      textplate_tech.unit = {
        count = 10,
        ingredients = table.deepcopy(prerequisite_tech.unit.ingredients),
        time = prerequisite_tech.unit.time
      }
    else -- Trigger tech
      textplate_tech.research_trigger = table.deepcopy(prerequisite_tech.research_trigger)
    end

    data:extend({textplate_tech})
  end
end
