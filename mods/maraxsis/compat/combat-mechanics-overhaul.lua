-- https://github.com/notnotmelon/maraxsis/issues/209

for _, tile in pairs(data.raw.tile) do
    if tile.collision_mask and tile.collision_mask.layers and tile.fluid == "maraxsis-saline-water" then
        tile.collision_mask.layers.item = nil
    end
end