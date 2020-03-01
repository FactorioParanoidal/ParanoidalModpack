for _, f in pairs(game.forces) do
  for _, t in pairs(f.technologies) do
    local prefix = string.match(t.name, "^(.*)miniloader$")
    if prefix then
      local recipe = f.recipes[prefix .. "filter-miniloader"]
      if recipe then
        recipe.enabled = t.researched
      end
    end
  end
end