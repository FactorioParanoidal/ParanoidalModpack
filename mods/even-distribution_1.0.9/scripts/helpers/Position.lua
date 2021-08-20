local pos = scripts.helpers
local _ = scripts.helpers.on

-- Helper functions for Position --

function pos:offset(...)
    if self.left_top ~= nil then
        return self:boxoffset(...)
    else
        return self:posoffset(...)
    end
end

function pos:posoffset(arg1, arg2) -- accepts Position or x,y
    local offx, offy = arg1, arg2
    if arg2 == nil then offx, offy = arg1.x, arg1.y end

	return _{x = self.x + offx, y = self.y + offy}
end

function pos:perimeter(radiusx, radiusy) -- with given radius (y radius defaults to x radius)
    radiusy = radiusy or radiusx
	return _{left_top = {x = self.x - radiusx, y = self.y - radiusy}, right_bottom = {x = self.x + radiusx, y = self.y + radiusy}}
end