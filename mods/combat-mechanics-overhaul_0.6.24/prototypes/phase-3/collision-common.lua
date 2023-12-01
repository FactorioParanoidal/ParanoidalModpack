-- Collisions shared between SE, combat mechanics overhaul & alien biomes

local vehicle_layer = collision_mask_util_extended.get_make_named_collision_mask("vehicle-layer")

for _, tile in pairs(data.raw.tile) do
  if string.find(tile.name, "water") then
    table.insert(tile.collision_mask, "item-layer")
  end
end

if data.raw.tile.water and collision_mask_util_extended.mask_contains_layer(data.raw.tile.water.collision_mask, "resource-layer") then
  table.insert(data.raw.tile.landfill.collision_mask, "resource-layer") -- prevent regenerated ores from spawning on landfill
end

for _, type in pairs({"car"}) do
  for _, prototype in pairs(data.raw[type]) do
    prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
    if collision_mask_util_extended.mask_contains_layer(prototype.collision_mask, "player-layer") then
      collision_mask_util_extended.add_layer(prototype.collision_mask, vehicle_layer)
    end
  end
end

-- make trees collide with resources so they won't be placed on top
-- make trees collide with vehicles (train-layer) but not characters (player-layer)
for _, type in pairs({"tree"}) do
  for _, prototype in pairs(data.raw[type]) do
    if string.find(prototype.name, "tree", 1, true) then
      prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
      if collision_mask_util_extended.mask_contains_layer(prototype.collision_mask, "player-layer") then
        collision_mask_util_extended.remove_layer(prototype.collision_mask, "player-layer")
        collision_mask_util_extended.add_layer(prototype.collision_mask, vehicle_layer)
      end
      collision_mask_util_extended.add_layer(prototype.collision_mask, "resource-layer")
      if prototype.collision_box
       and ((prototype.collision_box[1][1] == -1/32 and prototype.collision_box[1][2] == -1/32 -- AB tree
       and prototype.collision_box[2][1] == 1/32  and prototype.collision_box[2][2] == 1/32)
       or (prototype.collision_box[1][1] == -0.080000000000000018 and prototype.collision_box[1][2] == -0.080000000000000018 -- squeak tree
       and prototype.collision_box[2][1] == 0.080000000000000018  and prototype.collision_box[2][2] == 0.080000000000000018)) then
        prototype.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
      end
    end
  end
end

for _, prototype in pairs(data.raw["spider-leg"]) do
  prototype.collision_mask = collision_mask_util_extended.get_mask(prototype)
  if collision_mask_util_extended.mask_contains_layer(prototype.collision_mask, "player-layer") then
    collision_mask_util_extended.add_layer(prototype.collision_mask, "object-layer")
    --collision_mask_util_extended.add_layer(prototype.collision_mask, "water-tile")
  end
end
