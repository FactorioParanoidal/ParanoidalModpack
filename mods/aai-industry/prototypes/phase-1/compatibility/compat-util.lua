local compat = {}

function compat.get_compat_sand_names()
  local names = {"sand"}
  if mods["Krastorio2"] then
    table.insert(names, "kr-sand")
  end

  return names
end

function compat.get_compat_glass_names()
  local names = {"glass"}
  if mods["Krastorio2"] then
    table.insert(names, "kr-glass")
  end

  return names
end

return compat