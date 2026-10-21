local function regenerate_entity(ore)
  if prototypes.entity[ore] and prototypes.entity[ore].autoplace_specification then
    game.regenerate_entity(ore)
  end
end