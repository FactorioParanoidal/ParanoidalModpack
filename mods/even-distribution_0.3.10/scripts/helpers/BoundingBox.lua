local box = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for BoundingBox --

function box:boxoffset(arg1, arg2) -- accepts Position or x,y
    local offx, offy = arg1, arg2
    if arg2 == nil then offx, offy = arg1.x, arg1.y end

	local x1, y1, x2, y2 = self.left_top.x, self.left_top.y, self.right_bottom.x, self.right_bottom.y
	return _{left_top = {x = x1 + offx, y = y1 + offy}, right_bottom = {x = x2 + offx, y = y2 + offy}}
end

function box:expand(tilesx, tilesy) -- by number of tiles (y defaults to x)
    tilesy = tilesy or tilesx
	local x1, y1, x2, y2 = self.left_top.x, self.left_top.y, self.right_bottom.x, self.right_bottom.y
	return _{left_top = {x = x1 - tilesx, y = y1 - tilesy}, right_bottom = {x = x2 + tilesx, y = y2 + tilesy}}
end

function box:boxwidth()
    return self.right_bottom.x - self.left_top.x
end

function box:boxheight()
    return self.right_bottom.y - self.left_top.y
end

function box:area()
    return (self.right_bottom.x - self.left_top.x) * (self.right_bottom.y - self.left_top.y)
end
