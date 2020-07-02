if mods["Early_Nuclear_Power"] then
  data.raw["recipe"]["uranium-processing"].results={{"35%-uranium",0.007},{"uranium-238",0.993}}
  data.raw["recipe"]["crude-uranium-processing"].ingredients={{"uranium-ore",50}}
  data.raw["recipe"]["crude-uranium-processing"].results={{"35%-uranium",0.005},{"uranium-238",0.895},{"stone",0.1}}
  data.raw["recipe"]["breeder-nuclear-reactor"].ingredients={{"35%-uranium",20},{"copper-plate",250},{"steel-plate",100},{"electronic-circuit",250},{"stone-brick",200}}
  data.raw["recipe"]["crude-enrichment"].ingredients={{"35%-uranium",1},{"uranium-238",10}}
  data.raw["recipe"]["crude-enrichment"].results={{"35%-uranium",1},{"35%-uranium",0.2}}
end