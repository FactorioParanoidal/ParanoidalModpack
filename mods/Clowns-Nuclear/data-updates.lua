clowns.functions.add_unlock("kovarex-enrichment-process","depleted-uranium-reprocessing")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-80%")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-75%")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-70%")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-65%")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-55%")
clowns.functions.add_unlock("kovarex-enrichment-process","clowns-centrifuging-45%")
clowns.functions.add_unlock("kovarex-enrichment-process","nuclear-fuel")

--if Early_Nuclear_Power
require("prototypes.overrides.ENP-overrides")
--require("prototypes.more-overrides")

if data.raw.recipe["advanced-uranium-processing"] then 
  --roll through each ingredient and replace the uranium 235 with the 35%
  local res={}
  if data.raw["recipe"]["uranium-processing"].results then
    for i,ing in pairs(data.raw["recipe"]["uranium-processing"].results) do
      res[i]=table.deepcopy(ing)
      if ing.name and ing.name == "uranium-235" then
        res[i].name = "35%-uranium"
      elseif ing[1] and string.find(ing[1],"uranium-235") then
        res[i][1] = "35%-uranium"
      end
    end
    data.raw.recipe["advanced-uranium-processing"].results=res
  end
end
