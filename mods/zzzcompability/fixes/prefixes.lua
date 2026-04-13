local prefixes = {
	"angels-",
	"bob-",
}

local function TryFindPrefixed(name, section)
	if data.raw[section][name] then
		return name
	end
	for _, prefix in ipairs(prefixes) do
		if data.raw[section][prefix .. name] then
			log("FIXING: " .. name .. " -> " .. prefix .. name)
			return prefix .. name
		end
	end
	return name
end

local function fixEntityName(entity)
	entity.name = TryFindPrefixed(entity.name, entity.type)
end

for _, recipe in pairs(data.raw.recipe) do
	if recipe.ingredients then
		for _, ingredient in ipairs(recipe.ingredients) do
			fixEntityName(ingredient)
		end
	end
	if recipe.results then
		for _, result in ipairs(recipe.results) do
			fixEntityName(result)
		end
	end
end

for _, tech in pairs(data.raw.technology) do
	if tech.prerequisites then
		local newPrereq = {}
		for index, prereq in ipairs(tech.prerequisites) do
			local newName = TryFindPrefixed(prereq, "technology")
			newPrereq[newName] = true
		end
		tech.prerequisites = {}
		for prereq, _ in pairs(newPrereq) do
			table.insert(tech.prerequisites, prereq)
		end
	end
end

for _, item in pairs(data.raw.item) do
	if item.fuel_value and not item.fuel_category then
		log("WARN: FUEL CATEGORY not set in item: " .. item.name .. " set default to chemical")
		item.fuel_category = "chemical"
	end
end
