local offshore = data.raw["offshore-pump"]["offshore-pump"]
offshore.tile_buildability_rules[1].colliding_tiles.layers[maraxsis_lava_collision_mask] = true
offshore.tile_buildability_rules[1].required_tiles.layers[maraxsis_underwater_collision_mask] = true
offshore.tile_buildability_rules[2].required_tiles.layers[maraxsis_underwater_collision_mask] = true
