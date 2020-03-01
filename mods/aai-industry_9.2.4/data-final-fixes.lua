require("prototypes/recipe/recipe-final")

-- if another mod has changed labs but not burner lab
data.raw.lab["burner-lab"].inputs = data.raw.lab["lab"].inputs

--[[
if data.raw.item["electronics-machine-1"] and data.raw.recipe["electronic-circuit-stone"] then
  data.raw.recipe["electronic-circuit-stone"].category = "electronics"
end
]]

--log( serpent.block( data.raw.technology, {comment = false, numformat = '%1.8g' } ) )
