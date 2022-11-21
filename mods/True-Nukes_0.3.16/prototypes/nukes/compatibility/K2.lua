if(data.raw.recipe["FOGBANK"])then
data.raw.recipe["FOGBANK"].ingredients = {
  {type="item", name="low-density-structure", amount=10},
  {type="item", name="imersite-powder", amount=5},
  {type="item", name="rare-metals", amount=10},
  {type="item", name="energy-control-unit", amount=1},
}
end
if(data.raw.recipe["neutron-reflector"])then
data.raw.recipe["neutron-reflector"].ingredients = {
  {type="item", name="low-density-structure", amount=1},
  {type="item", name="rare-metals", amount=10},
  {type="item", name="lithium", amount=5},
  {type="fluid", name="nitric-acid", amount=20},
}
end
