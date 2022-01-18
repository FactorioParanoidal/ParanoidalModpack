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