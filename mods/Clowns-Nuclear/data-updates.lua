clowns.functions.add_unlock("kovarex-enrichment-process","depleted-uranium-reprocessing")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-80pc")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-75pc")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-70pc")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-65pc")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-55pc")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-45pc")
clowns.functions.add_unlock("kovarex-enrichment-process","nuclear-fuel")

require("prototypes.overrides.ENP-overrides")
clowns.functions.replace_ing("uranium-fuel-cell","uranium-235","35pc-uranium","ing")
--if data.raw.recipe["uranium-processing"] then
  --clowns.functions.replace_ing("uranium-processing","uranium-235","35pc-uranium","res")
  --[[roll through each ingredient and replace the uranium 235 with the 35%
  local res={}
  if data.raw["recipe"]["uranium-processing"].results then
    for i,ing in pairs(data.raw["recipe"]["uranium-processing"].results) do
      res[i]=table.deepcopy(ing)
      if ing.name and ing.name == "uranium-235" then
        res[i].name = "35pc-uranium"
      elseif ing[1] and string.find(ing[1],"uranium-235") then
        res[i][1] = "35pc-uranium"
      end
    end
    data.raw.recipe["advanced-uranium-processing"].results=res
  end]]
--end
