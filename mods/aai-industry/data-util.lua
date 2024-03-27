local util = {}
util.str_gsub = string.gsub

util.char_to_multiplier = {
	m = 0.001,
	c = 0.01,
	d = 0.1,
	h = 100,
	k = 1000,
	M = 1000000,
	G = 1000000000,
	T = 1000000000000,
	P = 1000000000000000,
}

function util.string_to_number(str)
	str = "" .. str
	local number_string = ""
	local last_char = nil
	for i = 1, #str do
		local c = str:sub(i, i)
		if c == "." or tonumber(c) ~= nil then
			number_string = number_string .. c
		else
			last_char = c
			break
		end
	end
	if last_char and util.char_to_multiplier[last_char] then
		return tonumber(number_string) * util.char_to_multiplier[last_char]
	end
	return tonumber(number_string)
end

function util.replace(str, what, with)
	what = string.gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
	with = string.gsub(with, "[%%]", "%%%%") -- escape replacement
	return string.gsub(str, what, with)
end

function util.remove_recipe_from_effects(effects, recipe)
	local index = 0
	for _, _item in ipairs(effects) do
		if _item.type == "unlock-recipe" and _item.recipe == recipe then
			index = _
			break
		end
	end
	if index > 0 then
		table.remove(effects, index)
	end
end

function util.remove_from_table(list, item)
	local index = 0
	for _, _item in ipairs(list) do
		if item == _item then
			index = _
			break
		end
	end
	if index > 0 then
		table.remove(list, index)
	end
end

function util.result_to_results(recipe_section)
	if not recipe_section.result then
		return
	end
	local result_count = recipe_section.result_count or 1
	if type(recipe_section.result) == "string" then
		recipe_section.results = { { type = "item", name = recipe_section.result, amount = result_count } }
	elseif recipe_section.result.name then
		recipe_section.results = { recipe_section.result }
	elseif recipe_section.result[1] then
		result_count = recipe_section.result[2] or result_count
		recipe_section.results = { { type = "item", name = recipe_section.result[1], amount = result_count } }
	end
	recipe_section.result = nil
end

function util.conditional_modify(prototype)
	if data.raw[prototype.type] and data.raw[prototype.type][prototype.name] then
		local raw = data.raw[prototype.type][prototype.name]

		-- update to new spec
		if not raw.normal then
			raw.normal = {
				enabled = raw.enabled,
				energy_required = raw.energy_required,
				requester_paste_multiplier = raw.requester_paste_multiplier,
				hidden = raw.hidden,
				ingredients = raw.ingredients,
				results = raw.results,
				result = raw.result,
				result_count = raw.result_count,
			}
			raw.enabled = nil
			raw.energy_required = nil
			raw.requester_paste_multiplier = nil
			raw.hidden = nil
			raw.ingredients = nil
			raw.results = nil
			raw.result = nil
			raw.result_count = nil
		end
		if not raw.expensive then
			raw.expensive = table.deepcopy(raw.normal)
		end
		if not raw.normal.results and raw.normal.result then
			util.result_to_results(raw.normal)
		end
		if not raw.expensive.results and raw.expensive.result then
			util.result_to_results(raw.expensive)
		end

		for key, property in pairs(prototype) do
			if key == "ingredients" then
				raw.normal.ingredients = property
				raw.expensive.ingredients = property
			elseif key ~= "normal" and key ~= "expensive" then
				raw[key] = property
			end
		end

		if prototype.normal then
			for key, property in pairs(prototype.normal) do
				raw.normal[key] = property
			end
		end

		if prototype.expensive then
			for key, property in pairs(prototype.expensive) do
				raw.expensive[key] = property
			end
		end
	end
end

function util.replace_or_add_ingredient_sub(recipe, old, new, amount)
	-- old can be nil to just add
	local found = false
	if old then
		for i, component in pairs(recipe.ingredients) do
			for _, value in pairs(component) do
				if value == old then
					found = true
					recipe.ingredients[i] = { type = "item", name = new, amount = amount }
					break
				end
			end
		end
	end
	if not found then
		table.insert(recipe.ingredients, { type = "item", name = new, amount = amount })
	end
end

function util.replace_or_add_ingredient(recipe, old, new, amount)
	if not recipe then
		return
	end
	if recipe.ingredients then
		util.replace_or_add_ingredient_sub(recipe, old, new, amount)
	end
	if recipe.normal and recipe.normal.ingredients then
		util.replace_or_add_ingredient_sub(recipe.normal, old, new, amount)
	end
	if recipe.expensive and recipe.expensive.ingredients then
		util.replace_or_add_ingredient_sub(recipe.expensive, old, new, amount)
	end
end

function util.disable_recipe(recipe_name)
	util.conditional_modify({
		type = "recipe",
		name = recipe_name,
		enabled = false,
		normal = {
			enabled = false,
		},
		expensive = {
			enabled = false,
		},
	})
end

function util.recipe_require_tech(recipe_name, tech_name)
	if data.raw.recipe[recipe_name] and data.raw.technology[tech_name] then
		util.disable_recipe(recipe_name)
		for _, tech in pairs(data.raw.technology) do
			if tech.effects then
				util.remove_recipe_from_effects(tech.effects, recipe_name)
			end
		end
		local already = false
		data.raw.technology[tech_name].effects = data.raw.technology[tech_name].effects or {}
		for _, effect in pairs(data.raw.technology[tech_name].effects) do
			if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
				already = true
				break
			end
		end
		if not already then
			table.insert(data.raw.technology[tech_name].effects, { type = "unlock-recipe", recipe = recipe_name })
		end
	end
end

function util.tech_lock_recipes(tech_name, recipe_names)
	if not data.raw.technology[tech_name] then
		return
	end
	if type(recipe_names) == "string" then
		recipe_names = { recipe_names }
	end
	for _, recipe_name in pairs(recipe_names) do
		if data.raw.recipe[recipe_name] then
			util.recipe_require_tech(recipe_name, tech_name)
		end
	end
end

function util.tech_add_prerequisites(tech_name, require_names)
	if not data.raw.technology[tech_name] then
		return
	end
	if type(require_names) == "string" then
		require_names = { require_names }
	end
	for _, require_name in pairs(require_names) do
		data.raw.technology[tech_name].prerequisites = data.raw.technology[tech_name].prerequisites or {}
		local already = false
		for _, prerequisite in pairs(data.raw.technology[tech_name].prerequisites) do
			if prerequisite == require_name then
				already = true
				break
			end
		end
		if not already then
			table.insert(data.raw.technology[tech_name].prerequisites, require_name)
		end
	end
end

function util.allow_productivity(recipe_name)
	for _, prototype in pairs(data.raw["module"]) do
		if prototype.limitation and string.find(prototype.name, "productivity", 1, true) then
			table.insert(prototype.limitation, recipe_name)
		end
	end
end

function util.replace(str, what, with)
	what = util.str_gsub(what, "[%(%)%.%+%-%*%?%[%]%^%$%%]", "%%%1") -- escape pattern
	with = util.str_gsub(with, "[%%]", "%%%%") -- escape replacement
	return util.str_gsub(str, what, with)
end

function util.replace_filenames_recursive(subject, what, with)
	if subject.filename then
		subject.filename = util.replace(subject.filename, what, with)
	else
		for _, sub in pairs(subject) do
			if type(sub) == "table" then
				util.replace_filenames_recursive(sub, what, with)
			end
		end
	end
end

return util
