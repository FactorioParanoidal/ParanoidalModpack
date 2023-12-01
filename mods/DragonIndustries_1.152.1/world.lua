function isWaterEdge(surface, x, y)
	if surface.get_tile{x-1, y}.valid and surface.get_tile{x-1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x+1, y}.valid and surface.get_tile{x+1, y}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y-1}.valid and surface.get_tile{x, y-1}.prototype.layer == "water-tile" then
		return true
	end
	if surface.get_tile{x, y+1}.valid and surface.get_tile{x, y+1}.prototype.layer == "water-tile" then
		return true
	end
end

function isInChunk(x, y, chunk)
	local minx = math.min(chunk.left_top.x, chunk.right_bottom.x)
	local miny = math.min(chunk.left_top.y, chunk.right_bottom.y)
	local maxx = math.max(chunk.left_top.x, chunk.right_bottom.x)
	local maxy = math.max(chunk.left_top.y, chunk.right_bottom.y)
	return x >= minx and x <= maxx and y >= miny and y <= maxy
end