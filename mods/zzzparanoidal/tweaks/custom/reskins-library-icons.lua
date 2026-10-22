-- Keep Paranoidal's shared icons without modifying the upstream Reskins Library.
local replacements = {}
for _, name in ipairs({ "gilded-copper-cable", "gold-plate", "rubber", "silicon-wafer" }) do
	replacements["__reskins-library__/graphics/icons/shared/items/" .. name .. ".png"] =
		"__zzzparanoidal__/graphics/reskins-library/" .. name .. ".png"
end

local function replace_icons(node, seen)
	if seen[node] then return end
	seen[node] = true
	for key, value in pairs(node) do
		if type(value) == "table" then
			replace_icons(value, seen)
		elseif type(value) == "string" and replacements[value] then
			node[key] = replacements[value]
		end
	end
end

replace_icons(data.raw, {})
