biomeTypes = {}

biomeTypes["basic"] = 1
biomeTypes["water"] = 1.5
biomeTypes["desert"] = 0.5
biomeTypes["sand"] = 0.5
biomeTypes["snow"] = 0.75
biomeTypes["ice"] = 0.75
biomeTypes["volcanic"] = 0.25

function getBiome(entity)
	local r = 10
	local aabb = entity.prototype.collision_box
	local box = {{entity.position.x-r-aabb.left_top.x, entity.position.y-r-aabb.left_top.y}, {entity.position.x+r+aabb.right_bottom.x, entity.position.y+r+aabb.right_bottom.y}}
	local tiles = entity.surface.find_tiles_filtered{area=box}
	local counts = {}
	counts["basic"] = #tiles
	for _,tile in pairs(tiles) do
		--[[
		if string.find(tile.name, "water") then
			counts["basic"] = counts["basic"]-1
			counts["water"] = counts["water"] and counts["water"]+1 or 1
		elseif string.find(tile.name, "snow") or string.find(tile.name, "ice") then
			counts["basic"] = counts["basic"]-1
			counts["snow"] = counts["snow"] and counts["snow"]+1 or 1
		elseif string.find(tile.name, "sand") or string.find(tile.name, "desert") then
			counts["basic"] = counts["basic"]-1
			counts["desert"] = counts["desert"] and counts["desert"]+1 or 1
		elseif string.find(tile.name, "volcanic") then
			counts["basic"] = counts["basic"]-1
			counts["volcanic"] = counts["volcanic"] and counts["volcanic"]+1 or 1
		end
		--]]
		for type,fac in pairs(biomeTypes) do
			if type ~= "basic" and string.find(tile.name, type) then
				counts["basic"] = counts["basic"]-1
				counts[type] = counts[type] and counts[type]+1 or 1
			end
		end
	end
	local max = 0
	local ret = "basic"
	for type,count in pairs(counts) do
		if count > max then
			ret = type
			max = count
		end
	end
	--game.print(ret)
	return ret
end