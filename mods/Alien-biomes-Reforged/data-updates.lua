for _, tree in pairs(data.raw.tree) do
  if string.find(tree.name, "rubber", 1, true) and tree.autoplace then
    tree.autoplace.tile_restriction = alien_biomes.list_tiles(
      alien_biomes.exclude_tags(alien_biomes.all_tiles(), {"volcanic", "frozen"})
    )
  end
end
