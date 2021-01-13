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

function recipe:productcount(item) -- get count of a specific item in recipe products
    if self:is("valid") then
		for __,product in pairs(self.products) do
            if product.name == item then 
                return product.amount or product.amount_min or product.amount_max or product.probability or 1 
            end
		end
    end
    
	return 0
end

function recipe:hasIngredient(item)
    return self:ingredientcount(item) > 0
end

function recipe:hasProduct(item)
    return self:productcount(item) > 0
end

function recipe:ingredientmap() -- ingredient table: item name --> amount
	local ingredients = {}
    
    if self:is("valid") then
        for __,ingredient in pairs(self.ingredients) do
            if ingredient.type == "item" then ingredients[ingredient.name] = ingredient.amount end
        end
	end
	
	return ingredients
end

function recipe:productmap() -- product table: item name --> amount
	local products = {}
    
    if self:is("valid") then
        for __,product in pairs(self.products) do
            if product.type == "item" then products[product.name] = product.amount end
        end
	end
	
	return products
end