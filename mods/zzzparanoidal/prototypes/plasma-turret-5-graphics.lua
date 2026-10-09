-- Зелёный T5 из Reskins Bob 1.1; сохраняем остальные цвета исходной графики.
return function(prototype)
	local source_tint
	for _, layer in ipairs(prototype.icons or {}) do
		if layer.tint and (layer.tint.a or layer.tint[4] or 1) ~= 0 then
			source_tint = layer.tint
			break
		end
	end
	local function channel(color, key, index)
		return color[key] or color[index] or 0
	end
	local function recolor(node)
		if type(node) ~= "table" then
			return
		end
		local tint = node.tint
		if tint and source_tint and
			channel(tint, "r", 1) == channel(source_tint, "r", 1) and
			channel(tint, "g", 2) == channel(source_tint, "g", 2) and
			channel(tint, "b", 3) == channel(source_tint, "b", 3) then
			node.tint = { r = 46 / 255, g = 229 / 255, b = 92 / 255, a = tint.a or tint[4] or 1 }
		end
		if node.icon then
			node.icon = node.icon:gsub("(/tiers/[^/]+/)%d+%.png$", "%15.png")
		end
		for _, value in pairs(node) do
			recolor(value)
		end
	end
	recolor(prototype)
end
