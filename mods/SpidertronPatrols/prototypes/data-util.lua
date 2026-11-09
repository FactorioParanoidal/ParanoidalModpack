local data_util = {}

function data_util.add_prerequisite(tech_name, prerequisite)
  local technology = data.raw.technology[tech_name]
  for _, name in pairs(technology.prerequisites) do
    if name == prerequisite then
      return
    end
  end
  table.insert(technology.prerequisites, prerequisite)
end

function data_util.remove_prerequisite(tech_name, prerequisite)
  local technology = data.raw.technology[tech_name]
  for i, name in pairs(technology.prerequisites) do
    if name == prerequisite then
      table.remove(technology.prerequisites, i)
    end
  end
end

function data_util.add_research_ingredient(tech_name, ingredient)
  local technology = data.raw.technology[tech_name]
  for _, name in pairs(technology.unit.ingredients) do
    if name[1] == ingredient then
      return
    end
  end
  table.insert(technology.unit.ingredients, {ingredient, 1})
end

function data_util.remove_research_ingredient(tech_name, ingredient)
  local technology = data.raw.technology[tech_name]
  for i, name in pairs(technology.unit.ingredients) do
    if name[1] == ingredient then
      table.remove(technology.unit.ingredients, i)
    end
  end
end

function data_util.contains_research_ingredient(tech_name, ingredient)
  local technology = data.raw.technology[tech_name]
  for _, name in pairs(technology.unit.ingredients) do
    if name[1] == ingredient then
      return true
    end
  end
  return false
end

function data_util.is_descendant_of(tech_name, ancestor)
  if tech_name == ancestor then return true end
  local technology = data.raw.technology[tech_name]
  if technology.prerequisites == nil then
    return false
  end
  for _, name in pairs(technology.prerequisites) do
    if name == ancestor then
      return true
    end
    if data_util.is_descendant_of(name, ancestor) then
      return true
    end
  end
  return false
end

return data_util