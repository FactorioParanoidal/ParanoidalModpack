
if(data.raw.recipe["FOGBANK"])then
data.raw.recipe["FOGBANK"].ingredients = {
  {type="item", name="se-aeroframe-scaffold", amount=2},
  {type="item", name="se-naquium-powder", amount=10},
  {type="fluid", name="sulfuric-acid", amount=20},
}
end
if(data.raw.recipe["neutron-reflector"])then
data.raw.recipe["neutron-reflector"].ingredients = {
      {type="item", name="low-density-structure", amount=1},
      {type="item", name="se-beryllium-plate", amount=5},
      {type="item", name="plastic-bar", amount=10},
      {type="item", name="iron-plate", amount=5},
}
end
se_delivery_cannon_recipes["atomic-bomb"] = nil
