local function regenerate_entity(ore)
  if game.entity_prototypes[ore] and game.entity_prototypes[ore].autoplace_specification then
    game.regenerate_entity(ore)
  end
end