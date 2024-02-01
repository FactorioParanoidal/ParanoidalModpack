for _,surf in pairs(game.surfaces) do
  for _,ent in pairs(surf.find_entities_filtered{name='nixie-colorman'}) do ent.destroy() end
end
