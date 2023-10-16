function calcInterpolatedValue(curve, val)
	local idx = 1
	while idx <= #curve and curve[idx][1] < val do
		idx = idx+1
	end
	idx = idx-1
	if val <= curve[1][1] then idx = 1 end
	if not curve[idx] then error("Queried out-of-bounds index " .. idx .. " on curve! \n" .. serpent.block(curve) .. " \n" .. debug.traceback()) end
	local x1 = curve[idx][1]
	local x2 = curve[idx+1][1]
	local y1 = curve[idx][2]
	local y2 = curve[idx+1][2]
	return y1+(y2-y1)*((val-x1)/(x2-x1))
end

function buildLinearInterpolation(curve, step)
	local values = {}
	local minx = curve[1][1]
	local maxx = curve[#curve][1]
	for x = minx,maxx,step do
		local key = string.format('%.04f', x)
		local y = calcInterpolatedValue(curve, x)
		values[key] = y
	end
	
	--respecify limit
	local key = string.format('%.04f', maxx)
	local y = calcInterpolatedValue(curve, maxx)
	values[key] = y
	
	return {values = values, granularity = step, range = {minx, maxx}}
end

function getInterpolatedValue(curve, val)
	local rnd = math.floor(val/curve.granularity+0.5)*curve.granularity
	--game.print(rnd .. " from " .. serpent.block(curve.values))
	if rnd <= curve.range[1] then
		return curve.values[string.format('%.04f', curve.range[1])]
	end
	if rnd >= curve.range[2] then
		return curve.values[string.format('%.04f', curve.range[2])]
	end
	local key = string.format('%.04f', rnd)
	--if val < 1 then game.print(rnd .. " from " .. serpent.block(curve.values)) end
	return curve.values[key]
end