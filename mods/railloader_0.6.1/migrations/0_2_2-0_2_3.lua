for _, f in pairs(game.forces) do
  local researched = f.technologies["railloader"].researched
  f.recipes["railloader"].enabled = researched
  f.recipes["railunloader"].enabled = researched
end

local function replace_all_inserters()
  for _, s in pairs(game.surfaces) do
    for _, type in ipairs{"railloader", "railunloader"} do
      local to_match = type .. "-inserter"
      local replace_with = type .. "-universal-inserter"
      for _, e in ipairs(s.find_entities_filtered{name=to_match}) do
        local replacement = s.create_entity{
          name = replace_with,
          position = e.position,
          direction = e.direction,
          force = e.force,
        }
        replacement.destructible = false
        replacement.held_stack.swap_stack(e.held_stack)
        e.destroy()
      end
    end
  end
end

if settings.global["railloader-allowed-items"].value == "any" then
  replace_all_inserters()
end