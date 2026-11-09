maraxsis.tints = {
	{r = 1.0,   g = 1.0,   b = 0.0,   a = 1.0},
	{r = 1.0,   g = 0.0,   b = 0.0,   a = 1.0},
	{r = 0.223, g = 0.490, b = 0.858, a = 1.0},
	{r = 1.0,   g = 0.0,   b = 1.0,   a = 1.0}
}

maraxsis.light_tints = {}
for i, tint in pairs(maraxsis.tints) do
	maraxsis.light_tints[i] = {}
	for color, amount in pairs(tint) do
		maraxsis.light_tints[i][color] = (amount - 0.5) / 2 + 0.5
	end
	maraxsis.light_tints[i].a = 1
end

---@param color Color
---@return Color
function maraxsis.color_normalize(color)
	local r = color.r or color[1]
	local g = color.g or color[2]
	local b = color.b or color[3]
	local a = color.a or color[4] or 1
	if r > 1 then r = r / 255 end
	if g > 1 then g = g / 255 end
	if b > 1 then b = b / 255 end
	if a > 1 then a = a / 255 end
	return {r = r, g = g, b = b, a = a}
end

---@param a Color
---@param b Color
---@param percent number
---@return Color
function maraxsis.color_combine(a, b, percent)
	a = maraxsis.color_normalize(a)
	b = maraxsis.color_normalize(b)

	return {
		r = a.r * percent + b.r * (1 - percent),
		g = a.g * percent + b.g * (1 - percent),
		b = a.b * percent + b.b * (1 - percent),
		a = a.a * percent + b.a * (1 - percent)
	}
end
