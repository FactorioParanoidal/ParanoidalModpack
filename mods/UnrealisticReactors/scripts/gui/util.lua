local rpath = (...):match("(.-)[^%.]+$")
local rroot = rpath:match("^([^%.]+%.)")
local split = require(rroot .. "heat.util").split


local function string2sprite(ryba)
	if ryba == "" then
		return "rr-black"
	else
		return "rr-"..ryba
	end
end

local function string2color(ryba)
	local color = {r=0,g=0,b=0}
	if ryba == "r" then
		color.r=1
	end
	if ryba == "y" then
		color.r=1
		color.g=1
	end
	if ryba == "b" then
		color.b=1
	end
	if ryba == "a" then
		color.r=0.4
		color.g=0.75
		color.b=1
	end
	return color
end


local function splitty(s,delimiter)
	return unpack(split(s..delimiter,delimiter,tonumber))
end


return { -- exports
	string2sprite = string2sprite,
	string2color = string2color,
	splitty = splitty,
}
