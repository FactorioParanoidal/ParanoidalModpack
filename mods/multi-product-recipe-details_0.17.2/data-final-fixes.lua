local Vertical_Display = settings.startup["mprd-vertical-display"].value
local Amount_Display = settings.startup["mprd-amount-display"].value

-- Result definition structure can vary:
-- {name="product_name", amount=int}
-- {name="product_name", amount=int, probability=int}
-- {type="item|fluid", name="product_name", amount=int}
-- {type="item|fluid", name="product_name", amount=int, probability=int}
-- {[1]="item|fluid", [2]="product_name", [3]=int, [4]=int}
local function parse_product_info(result)
	local p_type = nil
	local p_name = nil
	local p_amount = nil
	local p_probability = nil

	-- Get Type
	if result.type ~= nil then p_type = result.type
	else
		-- {[1]="item|fluid", [2]="product_name", ... }
		if type(result[1]) == "string" and type(result[2]) == "string" then	p_type = result[1] end
	end

	-- Get Name
	if result.name ~= nil then p_name = result.name
	else
		if p_type ~= nil then p_name = result[2]	-- {[1]="item|fluid", [2]="product_name", [3]=int}
		else p_name = result[1]						-- {[1]="product_name", [2]=int}
		end
	end

	-- Get Amount
	if result.amount ~= nil then p_amount = result.amount
	else
		if p_type ~= nil then p_amount = result[3]	-- {[1]="item|fluid", [2]="product_name", [3]=int}
		else p_amount = result[2]					-- {[1]="product_name", [2]=int}
		end
	end

	-- Get Probability
	if result.probability ~= nil then p_probability = result.probability
	else
		if p_type ~= nil then p_probability = result[4] -- {[1]="item|fluid", [2]="product_name", [3]=int, [4]=int}
		else p_probability = result[3]					-- {[1]="product_name", [2]=int, [3]=int}
		end
	end

	return {type=p_type, name=p_name, amount=p_amount, probability=p_probability}
end

local function format_line(product, name_prefix, output)
	if Vertical_Display then 
		table.insert(output, "\n")
		table.insert(output, {name_prefix .. product.name})
	else
		table.insert(output, ", ")
		table.insert(output, {name_prefix .. product.name})
	end
	if Amount_Display and product.amount ~= nil then
		if product.probability ~= nil and product.probability ~= 1 then
			table.insert(output, " [" .. product.amount .. "*" .. product.probability * 100 .. "%]")
		else
			table.insert(output, " [" .. product.amount .. "]")
		end
	end
	return output
end

local function generate_description(recipe, results)
	local new_description = {'', {"recipe-description.mprd-caption"}, " "}

	local fluids = {}
	for _, result in pairs(results) do
		local product = parse_product_info(result)
		-- If type is not defined product supposed to be an Item
		if product.type == "item" or product.type == nil then
			new_description = format_line(product, "item-name.", new_description)
		else
			fluids = format_line(product, "fluid-name.", fluids)
		end
	end
	for _, key in pairs(fluids) do table.insert(new_description, key) end -- Items first, Fluids last

	if not Vertical_Display then table.remove(new_description, 4) end -- Remove preemptive first comma
	if recipe.localised_description or recipe.description then -- Preserve existing description
		if recipe.localised_description then table.insert(new_description, 2, recipe.localised_description)
		else table.insert(new_description, 2, {recipe.description}) end
		table.insert(new_description, 3, "\n\n")
	end
	--table.insert(new_description, "\n") -- In case additional spacing is needed

	return new_description
end

local function get_results(recipe)
	if recipe.results ~= nil then return recipe.results end
	if recipe.normal ~= nil and recipe.normal.results ~= nil then return recipe.normal.results end
end

for _, recipe in pairs(data.raw["recipe"]) do
	if recipe.results ~= nil or (recipe.normal ~= nil and recipe.normal.results ~= nil) then
		local results = get_results(recipe)
		if results ~= nil and #results > 1 then -- Only for multi-product recipes
			local new_description = generate_description(recipe, results)
			-- For some reason there is a hard limit(=20) to how many elements can be in recipe.localised_description
			-- Until it is raised/removed we have to ignore very long recipes
			if #new_description <= 20 then
				recipe.localised_description = new_description
			end
		end
	end
end
