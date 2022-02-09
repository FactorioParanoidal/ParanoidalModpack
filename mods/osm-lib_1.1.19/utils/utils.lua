if not OSM.utils then OSM.utils = {} end

-- Store animation functions
function OSM.utils.make_stripes(count, filename)
	local stripe = {filename=filename, width_in_frames = 1, height_in_frames = 1}
	local stripes = {}
	for i = 1, count do
		stripes[i] = stripe
	end
	return stripes
end

-- Generates an item placeholder
function OSM.utils.make_placeholder(placeholder_name)
	local OSM_placeholder =
	{
		type = "item",
		name = placeholder_name,
		icon = "__core__/graphics/empty.png",
		icon_size = 1,
		subgroup = "OSM-placeholder",
		flags = {"hidden"},
		order = "8==D",
		stack_size = 1
	}	data:extend({OSM_placeholder})
end