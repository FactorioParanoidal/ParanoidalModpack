-- Paranoidal: with paranoidal-space-age-filter bobores keeps its tungsten ore at home, as without Space Age.
if script.active_mods["space-age"] and not script.active_mods["paranoidal-space-age-filter"] then
  local surface = game.surfaces["nauvis"]
  if surface and prototypes.entity["tungsten-ore"] then
    local entities = surface.find_entities_filtered({
      name = { "tungsten-ore" },
      type = "resource",
    })
    for _, entity in pairs(entities) do
      entity.destroy()
    end
  end
end
