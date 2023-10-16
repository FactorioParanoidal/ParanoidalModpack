function moveBox(area, dx, dy)
	--printTable(area)
	area.left_top.x = area.left_top.x+dx
	area.left_top.y = area.left_top.y+dy
	area.right_bottom.x = area.right_bottom.x+dx
	area.right_bottom.y = area.right_bottom.y+dy
	return area
end

function padBox(area, padX, padY)
	area.left_top.x = area.left_top.x-padX
	area.left_top.y = area.left_top.y-padY
	area.right_bottom.x = area.right_bottom.x+padX
	area.right_bottom.y = area.right_bottom.y+padY
	return area
end

function getMovedBox(entity, dx, dy)
	local base = entity.prototype.collision_box
	return moveBox(base, dx, dy)
end

function getPaddedBox(entity, padX, padY)
	local base = entity.prototype.collision_box
	return moveBox(padBox(base, padX, padY), entity.position.x, entity.position.y)
end

function intersects(box1, box2)
	if box1.right_bottom.x < box2.left_top.x then return false end -- box1 is left of box2
    if box1.left_top.x > box2.right_bottom.x then return false end -- box1 is right of box2
    if box1.right_bottom.y < box2.left_top.y then return false end -- box1 is above box2
    if box1.left_top.y > box2.right_bottom.y then return false end -- box1 is below box2
    return true -- boxes overlap
end

function getRadiusAABB(entity, r)
	return {{entity.position.x-r, entity.position.y-r}, {entity.position.x+r, entity.position.y+r}}
end