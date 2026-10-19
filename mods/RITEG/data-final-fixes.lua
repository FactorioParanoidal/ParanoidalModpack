-- some mod combinations leave a recipe pointing at an item that no other mod
-- ever created, and the game refuses to load with "Error in assignID, item with
-- name '...' does not exist". this drops such an ingredient instead

local item_type_names = {}
for type_name in pairs(defines.prototypes.item) do
	table.insert(item_type_names, type_name)
end
table.sort(item_type_names)


local function item_exists(item_name)
	for _, type_name in ipairs(item_type_names) do
		if (data.raw[type_name] or {})[item_name] then
			return true
		end
	end
	return false
end


local removed = 0
for _, recipe in pairs(data.raw.recipe) do
	if recipe.ingredients then
		local kept = {}
		for _, ingredient in pairs(recipe.ingredients) do
			local item_name = nil
			if ingredient.type == "item" or ingredient[1] then
				item_name = ingredient.name or ingredient[1]
			end
			if item_name and not item_exists(item_name) then
				log('RITEG: dropped missing item "' .. item_name .. '" from recipe "' .. recipe.name .. '"')
				removed = removed + 1
			else
				-- the old code set the entry to nil, which left a hole in the
				-- array, so the list is rebuilt instead
				table.insert(kept, ingredient)
			end
		end
		recipe.ingredients = kept
	end
end

if removed > 0 then
	log('RITEG: ' .. removed .. ' missing ingredients were dropped')
end
