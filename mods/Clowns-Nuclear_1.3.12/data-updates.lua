data.raw["technology"]["kovarex-enrichment-process"].effects=
{
	{type = "unlock-recipe", recipe = "depleted-uranium-reprocessing"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-80%"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-75%"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-70%"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-65%"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-55%"},
	{type = "unlock-recipe", recipe = "clowns-centrifuging-45%"},
	{type = "unlock-recipe", recipe = "nuclear-fuel"}
}
--if Early_Nuclear_Power
require("prototypes.ENP-overrides")

if data.raw.recipe["advanced-uranium-processing"] then 
  --roll through each ingredient and replace the uranium 235 with the 35%
  local res={}
  if data.raw["recipe"]["uranium-processing"].results then
    for i,ing in pairs(data.raw["recipe"]["uranium-processing"].results) do
      res[i]=table.deepcopy(ing)
      if ing.name and ing.name == "uranium-235" then
        res[i].name = "20%-uranium"
      elseif ing[1] and string.find(ing[1],"uranium-235") then
        res[i][1] = "20%-uranium"
      end
    end
    data.raw.recipe["advanced-uranium-processing"].results=res
  end
end
