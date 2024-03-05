for _, s in pairs(game.surfaces) do
  for _, container in ipairs(s.find_entities_filtered{type = "container"}) do
    if container.name == "railloader-chest" or container.name == "railunloader-chest" then
      for _, rail in ipairs(s.find_entities_filtered{type = "straight-rail", area = container.bounding_box}) do
        rail.destructible = false
        rail.minable = false
      end
    end
  end
end