--[[--
Metaball shapes for ore fields (original by Dark).
force(x, y) grows to infinity at the centre and equals 1 at the radius. The arithmetic of every
force() is kept operation for operation: ore fields of existing maps must not change.
--]]--
local _M = {}
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local abs = math.abs
local zero_value = 0x80000000

local function new_shape(class, fields, angle, x_scale, y_scale, goo)
	angle = angle or 0
	fields.angle = angle
	fields.x_scale = x_scale or 1
	fields.y_scale = y_scale or 1
	fields.goo = goo or 1
	fields.cosa = cos(angle)
	fields.sina = sin(angle)
	return setmetatable(fields, class)
end

-- Ellipse
local MetaEllipse = {type = "MetaEllipse"}
MetaEllipse.__index = MetaEllipse
_M.MetaEllipse = MetaEllipse

function MetaEllipse:new(x, y, radius, angle, x_scale, y_scale, goo)
	return new_shape(MetaEllipse, {x = x, y = y, radius = radius}, angle, x_scale, y_scale, goo)
end

function MetaEllipse:force(x, y)
	local dx, dy = x - self.x, y - self.y
	local cosa, sina = self.cosa, self.sina
	local d = sqrt(((dx*cosa + dy*sina)^2)/(self.x_scale) + ((dy*cosa - dx*sina)^2)/(self.y_scale))
	if d == 0 then return zero_value end
	return (self.radius / d)^self.goo
end

-- Square (rotated diamond-like L1 shape)
local MetaSquare = {type = "MetaSquare"}
MetaSquare.__index = MetaSquare
_M.MetaSquare = MetaSquare

function MetaSquare:new(x, y, radius, angle, x_scale, y_scale, goo)
	return new_shape(MetaSquare, {x = x, y = y, radius = radius}, angle, x_scale, y_scale, goo)
end

function MetaSquare:force(x, y)
	local dx, dy = x - self.x, y - self.y
	local cosa, sina = self.cosa, self.sina
	local d = abs(dx*cosa + dy*sina)/self.x_scale + abs(dy*cosa - dx*sina)/self.y_scale
	if d == 0 then return zero_value end
	return (self.radius / d)^self.goo
end

-- Donut: the force peaks on the ring of radius out_r, int_r controls its thickness
local MetaDonut = {type = "MetaDonut"}
MetaDonut.__index = MetaDonut
_M.MetaDonut = MetaDonut

function MetaDonut:new(x, y, out_r, int_r, angle, x_scale, y_scale, goo)
	if int_r >= out_r then error("int_r >= out_r (" .. int_r .. " >= " .. out_r .. ")") end
	local donut = new_shape(MetaDonut, {x = x, y = y, radius = out_r, radius2 = int_r}, angle, x_scale, y_scale, goo)
	-- the original never stored a donut's angle (the negative balls placed around it read 0);
	-- kept so that generation stays the same
	donut.angle = 0
	return donut
end

function MetaDonut:force(x, y)
	local dx, dy = x - self.x, y - self.y
	local cosa, sina = self.cosa, self.sina
	local d = abs(self.radius - sqrt(((dx*cosa + dy*sina)^2)/(self.x_scale) + ((dy*cosa - dx*sina)^2)/(self.y_scale)))
	if d == 0 then return zero_value end
	return (self.radius2 / d)^self.goo
end

return _M
