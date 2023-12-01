require "arrays"

function isWaterTile(tile)
	return tile.valid and hasCollisionMask(tile, "water-tile")
end

function isWaterEdge(surface, x, y)
	if surface.get_tile{x-1, y}.valid and surface.get_tile{x-1, y}.prototype.collision_mask["water-tile"] then
		return true
	end
	if surface.get_tile{x+1, y}.valid and surface.get_tile{x+1, y}.prototype.collision_mask["water-tile"] then
		return true
	end
	if surface.get_tile{x, y-1}.valid and surface.get_tile{x, y-1}.prototype.collision_mask["water-tile"] then
		return true
	end
	if surface.get_tile{x, y+1}.valid and surface.get_tile{x, y+1}.prototype.collision_mask["water-tile"] then
		return true
	end
end