function ReplaceAllIngredientItemWithItem(oldItemName , newItemName)

local function editIngredient(recipeName, oldIngredientName, newIngredientName, amountMultiplier)
	if not data.raw["recipe"][recipeName] then return end
	--recipePrototypeCleanup(recipeName)

	if data.raw["recipe"][recipeName].ingredients then
	  for index, ingredient in pairs(data.raw["recipe"][recipeName].ingredients) do
		if ingredient.name and ingredient.name == oldIngredientName then
		  data.raw["recipe"][recipeName].ingredients[index].name = newIngredientName
		  data.raw["recipe"][recipeName].ingredients[index].amount = math.floor(.5 + data.raw["recipe"][recipeName].ingredients[index].amount * amountMultiplier)
		  break
		elseif ingredient[1] and ingredient[1] == oldIngredientName then
		  data.raw["recipe"][recipeName].ingredients[index][1] = newIngredientName
		  data.raw["recipe"][recipeName].ingredients[index][2] = math.floor(.5 + data.raw["recipe"][recipeName].ingredients[index][2] * amountMultiplier)
		  break
		end
	  end
	end

	if data.raw["recipe"][recipeName].normal then
	  for index, ingredient in pairs(data.raw["recipe"][recipeName].normal.ingredients) do
		if ingredient.name and ingredient.name == oldIngredientName then
		  data.raw["recipe"][recipeName].normal.ingredients[index].name = newIngredientName
		  data.raw["recipe"][recipeName].normal.ingredients[index].amount = math.floor(.5 + data.raw["recipe"][recipeName].normal.ingredients[index].amount * amountMultiplier)
		  break
		elseif ingredient[1] and ingredient[1] == oldIngredientName then
		  data.raw["recipe"][recipeName].normal.ingredients[index][1] = newIngredientName
		  data.raw["recipe"][recipeName].normal.ingredients[index][2] = math.floor(.5 + data.raw["recipe"][recipeName].normal.ingredients[index][2] * amountMultiplier)
		  break
		end
	  end
	end

	if data.raw["recipe"][recipeName].expensive then
	  for index, ingredient in pairs(data.raw["recipe"][recipeName].expensive.ingredients) do
		if ingredient.name and ingredient.name == oldIngredientName then
		  data.raw["recipe"][recipeName].expensive.ingredients[index].name = newIngredientName
		  data.raw["recipe"][recipeName].expensive.ingredients[index].amount = math.floor(.5 + data.raw["recipe"][recipeName].expensive.ingredients[index].amount * amountMultiplier)
		  break
		elseif ingredient[1] and ingredient[1] == oldIngredientName then
		  data.raw["recipe"][recipeName].expensive.ingredients[index][1] = newIngredientName
		  data.raw["recipe"][recipeName].expensive.ingredients[index][2] = math.floor(.5 + data.raw["recipe"][recipeName].expensive.ingredients[index][2] * amountMultiplier)
		  break
		end
	  end
	end
  end
  
  for recipeName,_ in pairs(data.raw["recipe"]) do
	editIngredient(recipeName, oldItemName, newItemName, 1)
  end
  
end
if mods.angelssmelting then
ReplaceAllIngredientItemWithItem("concrete-brick" , "concrete")
ReplaceAllIngredientItemWithItem("reinforced-concrete-brick","refined-concrete")
data.raw.recipe["angels-concrete"].hidden = true
data.raw.recipe["angels-concrete-brick"].hidden = true
data.raw.recipe["angels-reinforced-concrete-brick"].hidden = true
if mods["aai-industry"] then
data.raw.recipe["concrete"].normal.ingredients = {
      {type="fluid", name="liquid-concrete", amount=40},
	}
data.raw.recipe["concrete"].normal.result_count = 4
else
data.raw.recipe["concrete"].ingredients = {
      {type="fluid", name="liquid-concrete", amount=40},
	}
data.raw.recipe["concrete"].result_count = 4
end
data.raw.recipe["refined-concrete"].ingredients = {
      {type="fluid", name="liquid-concrete", amount=40},
      {type="item", name="steel-plate", amount=4},
      {type="item", name="iron-stick", amount=8},
	}
data.raw.item["reinforced-concrete-brick"].place_as_tile.result = "refined-concrete"
end