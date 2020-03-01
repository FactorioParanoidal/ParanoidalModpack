local recipe = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for LuaRecipe --

function recipe:ingredientcount(item) -- get count of a specific item in recipe ingredients
    if self:is("valid") then
		for __,ingredient in pairs(self.ingredients) do
			if ingredient.name == item then return ingredient.amount end
		end
    end
    
	return 0
end

function recipe:hasIngredient(item)
    return self:ingredientcount(item) > 0
end

function recipe:ingredientmap() -- ingredient table: name --> amount
	local ingredients = {}
    
    if self:is("valid") then
        for __,ingredient in pairs(self.ingredients) do
            if ingredient.type == "item" then ingredients[ingredient.name] = ingredient.amount end
        end
	end
	
	return ingredients
end