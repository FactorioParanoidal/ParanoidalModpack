if settings.startup["SpaceX-no-bob"].value == false then

if (mods['boblibrary'] and 
	mods['bobplates'] and 
	mods['bobmodules'] and 
	mods['bobelectronics'] and 
	mods['boblogistics'] and 
	mods['bobtech'] and 
	mods['bobequipment'] and
	data.raw.recipe["advanced-processing-unit"]) then
	require("prototypes.recipe-bobs")
	require("prototypes.technology-bobs")

	-- local researchCost = settings.startup["SpaceX-research"]
	-- if researchCost == nil then
		-- researchCost.value = 1
	-- end

	-- --apply cost mult to new technology
	-- local SpaceXTechs = {
	-- "ftl-theory-D",
	-- }
	
	-- for i, tech in pairs(SpaceXTechs) do
		-- local rootTech = data.raw.technology[tech]
		-- if rootTech ~= nil then
			-- rootTech.unit.count = rootTech.unit.count * researchCost.value
		-- end
	-- end

	-- local productionCost = settings.startup["SpaceX-production"]
	-- if productionCost == nil then
		-- productionCost.value = 1
	-- end

	-- --apply cost mult to new recipe
	 -- local SpaceXRecipes = {
	 -- "protection-field-goopless",
	 -- }
	 -- for j, recipe in pairs(SpaceXRecipes) do
		 -- local rootRecipe = data.raw.recipe[recipe]
		 -- if rootRecipe then
			-- local tableIngredients = rootRecipe.ingredients
			-- if(tableIngredients) then
				-- for k, ingredient in pairs(tableIngredients) do
					-- if(ingredient.amount) then
						-- data.raw.recipe[recipe].ingredients[k].amount = ingredient.amount*productionCost.value
					-- elseif(ingredient[1] and type(ingredient[1]) == "number") then
						-- data.raw.recipe[recipe].ingredients[k][1] = ingredient[1]*productionCost.value
					-- end
				-- end
			-- end
		-- end
	 -- end
	 
 
end

end