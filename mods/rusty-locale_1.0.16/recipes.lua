local _M  = {partial = {}}


function _M.parse_product(product)
--- Get the given product in the `{name = ..., type = ..., ...}` format.
	if type(product) == 'string' then return {name = product, type = 'item'}; end
	local product = table.deepcopy(product)
	if not product.type then product.type = 'item'; end
	if not product.name then product.name = product[1]; end
	if not product.amount then product.amount = product[2]; end
	product[1] = nil
	product[2] = nil
	return product
end

function _M.partial.find_product(recipe, name)
--- Get the full product definition for a product with the given name from the given recipe part.
	if recipe.results then
		for _, p in pairs(recipe.results) do
			local product = _M.parse_product(p)
			if product.name == name then return product; end
		end
	elseif recipe.result == name then return _M.parse_product(name); end
	return nil
end

function _M.partial.get_main_product(recipe)
--- Get the main product of the given recipe part.
	if recipe.main_product == '' then return nil
	elseif recipe.main_product ~= nil then return _M.partial.find_product(recipe, recipe.main_product)
	elseif recipe.results then
		if table_size(recipe.results) == 1 then return _M.parse_product(recipe.results[1])
		else return nil; end
	elseif recipe.result then return _M.parse_product(recipe.result); end
	return nil
end


function _M.get_main_product(recipe)
--- Get the main product of the given recipe.
--- For normal+expensive definitions, the product is only returned if it's the same for both.
	if recipe.normal and recipe.expensive then
		local normal, expensive = _M.partial.get_main_product(recipe.normal), _M.partial.get_main_product(recipe.expensive)
		if normal and expensive and normal.name == expensive.name and normal.type == expensive.type then return normal
		else return nil; end
	end
	return _M.partial.get_main_product(recipe.normal or recipe.expensive or recipe)
end


return _M
