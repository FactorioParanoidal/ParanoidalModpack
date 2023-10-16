function convertColor(argb, divideBy)
	if not argb then error("Null color") end
	local blue = bit32.band(argb, 255)
	local green = bit32.band(bit32.rshift(argb, 8), 255)
	local red = bit32.band(bit32.rshift(argb, 16), 255)
	if divideBy then
		red = red/255
		green = green/255
		blue = blue/255
	end
	return {r = red, g = green, b = blue}
end

function permuteColor(clr, dr, dg, db)
	clr = table.deepcopy(clr)
	clr.r = math.max(0, math.min(255, clr.r+dr))
	clr.g = math.max(0, math.min(255, clr.g+dg))
	clr.b = math.max(0, math.min(255, clr.b+db))
	return clr
end