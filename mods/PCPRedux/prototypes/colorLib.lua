local util = require("__core__/lualib/util")
local colorLib = {}


-- Takes an input, checks if it is a table with three or four entries
-- converts
function colorLib.isColor(input)
	if type(input) ~= "table" then
		return nil
    end
    local length = table_size(input)
    if length ~= 3 and length ~= 4 then
        return nil
    end
    local is_small = true
    for _,v in pairs(input) do 
        if v > 1 then
            is_small = false
            break
        end
    end
    if not is_small then
        for k,v in pairs(input) do
            input[k] = v/255
        end
    end
	local color = {
		r = input.r or input[1],
		g = input.g or input[2],
		b = input.b or input[3],
		a = input.a or input[4] or 1
	}
	return color
end

function colorLib.colorToHex(color)
	color = colorLib.toColor(color)
	local hex = {}
	local n = 1
	for _,v in pairs(color) do
		if v <= 1 then
			v = v * 255
		end
		hex[n] = string.format("%x",v)
		if hex[n]:len() == 1 then
			hex[n] = "0"..hex[n]
		end
		n = n + 1
	end
	if hex[4] == "ff" then
		table.remove(hex,4)
	end
	hex = table.concat(hex)
	return hex
end

function colorLib.findRGB(inputString)
	if type(inputString) ~= "string" then
		return nil
	end
	if inputString:find("%a") then	
		return nil
	end
	local rawColor = util.split(inputString:gsub("%D", " "), " ")
	if #rawColor < 3 then
		return nil
	end
	local color = {}
	for k,v in pairs(rawColor) do
		color[k] = v / 255
	end
	return {
		r = color[1],
		g = color[2],
		b = color[3],
		a = color[4] or 1
	}
end

--modified version of util.color provided by API
function colorLib.findHex(hex)
	if type(hex) ~= "string" then
		return nil
	end
	if hex:find("%X") or #hex > 8  or #hex == 5 or #hex == 7 then
		return nil
	end

	local function h(i,j)
	  return j and tonumber("0x"..hex:sub(i,j)) / 255 or tonumber("0x"..hex:sub(i,i)) / 15
	end

	hex = hex:gsub("#","")
	return #hex == 6 and {r = h(1,2), g = h(3,4), b = h(5,6)}
	  or #hex == 3 and {r = h(1), g = h(2), b = h(3)}
	  or #hex == 8 and {r = h(1,2), g = h(3,4), b = h(5,6), a = h(7,8)}
	  or #hex == 4 and {r = h(1), g = h(2), b = h(3), a = h(4)}
	  or #hex == 2 and {r = h(1,2), g = h(1,2), b = h(1,2)}
	  or #hex == 1 and {r = h(1), g = h(1), b = h(1)}
	  or {r=1, g=1, b=1}
end

function colorLib.toColor(color)
	return colorLib.isColor(color) or colorLib.findHex(color) or colorLib.findRGB(color) or {r=0,g=0,b=0,a=1}
end


function colorLib.multiply_color(c1, n)
	return
	{
	  r = (c1.r or c1[1] or 0) * (n or 0),
	  g = (c1.g or c1[2] or 0) * (n or 0),
	  b = (c1.b or c1[3] or 0) * (n or 0),
	  a = (c1.a)
	}
end

function colorLib.multiply_colors(c1, c2)
    return {
        r = (c1.r or c1[1] or 1) * (c2.r or c2[1] or 1),
        g = (c1.g or c1[2] or 1) * (c2.g or c2[2] or 1),
        b = (c1.b or c1[3] or 1) * (c2.b or c2[3] or 1),
        a = (c1.a or c1[4] or 1) * (c2.a or c2[4] or 1)
    }
end

--These functions all from the formulas given here: https://en.wikipedia.org/wiki/HSL_and_HSV
function colorLib.RGBtoHSL(color)
    color = colorLib.toColor(color)
	local r,g,b = color.r, color.g, color.b
	local max = math.max(r,g,b)
	local min = math.min(r,g,b)
	local range = max - min
	local h
	if max == min then
		h = 0
	elseif max == r then
		h = (g-b)/range*60
	elseif max == g then
		h = (2+(b-r)/range)*60
	elseif max == b then
		h = (4+(r-g)/range)*60
	end
	if h < 0 then
		h = h + 360
	end
	local l = (min+max)/2
	local s = 0
	if min == 1 or max == 0 then
	else
		s = (max-l)/math.min(l,1-l)
	end
	--local s = (min == 1 and 0) or (max == 0 and 0) or ((max-l)/math.min(l,1-l))
	return{
		h = h,
		s = s,
		l = l,
		a = color.a or 1
	}
end

function colorLib.RGBtoHSV(color)
    color = colorLib.toColor(color)
	local r,g,b = color.r, color.g, color.b
	local max = math.max(r,g,b)
	local min = math.min(r,g,b)
	local range = max - min
	local h
	if range == 0 then
		h = 0
	elseif max == r then
		h = (g-b)/range*60
	elseif max == g then
		h = (2+(b-r)/range)*60
	elseif max == b then
		h = (4+(r-g)/range)*60
	end
	if h < 0 then
		h = h + 360
	end
	local v = max
	local s = range/max
	return{
		h = h,
		s = s,
		v = v,
		a = color.a or 1
	}
end

function colorLib.HSLtoRGB(color)
	local h,s,l,a = color.h, color.s, color.l, color.a
	local function f(n)
		local k = (n + h/30) % 12
		local x = s * math.min(l,1-l)
		return l - x*math.max(math.min(k-3,9-k,1),-1)
	end
	return {
		r = f(0),
		g = f(8),
		b = f(4),
		a = color.a or 1
	}
end

function colorLib.HSVtoRGB(color)
	local h,s,v,a = color.h, color.s, color.v, color.a
	local function f(n)
		local k = (n + h/60) % 6
		return v - v*s*math.max(math.min(k,4-k,1),0)
	end
	return {
		r = f(5),
		g = f(3),
		b = f(1),
		a = color.a or 1
	}
end

function colorLib.get_color_distance(color1, color2)
	color1 = colorLib.toColor(color1)
	color2 = colorLib.toColor(color2)
	local disp = {r = color1.r - color2.r, g = color2.g - color2.g, b = color1.b - color2.b}
	return disp.r*disp.r + disp.g*disp.g + disp.b*disp.b
end


function colorLib.find_closest_color(color, table)
    color = colorLib.toColor(color)
	local closestColor
	local min = 1
	for k,v in pairs(table) do
		local distance = colorLib.get_color_distance(color,v)
		min = (distance < min) and distance or min
		closestColor = k
	end
	return closestColor
end

return colorLib
