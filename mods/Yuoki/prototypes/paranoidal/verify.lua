-- Paranoidal fork: every Yuoki recipe must be unlocked by the Yuoki technology tree, every Yuoki technology must
-- unlock something. A failure stops the load with the list (development check; cheap at load time).
local missing, empty = {}, {}
for name in pairs(YUOKI_PARANOIDAL.owned_recipes) do
	local recipe = data.raw.recipe[name]
	if recipe and not YUOKI_PARANOIDAL.assigned[name] and not recipe.hidden then
		missing[#missing + 1] = name
	end
end
for name in pairs(YUOKI_PARANOIDAL.tech_names) do
	if #(data.raw.technology[name].effects or {}) == 0 then
		empty[#empty + 1] = name
	end
end
table.sort(missing)
table.sort(empty)
if #missing > 0 or #empty > 0 then
	error("Yuoki (Paranoidal): recipes without a technology: " .. table.concat(missing, ", ")
		.. "\ntechnologies without effects: " .. table.concat(empty, ", "))
end
