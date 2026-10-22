-- Расплавы олова и хрома как в Beta 8. В Angels 2.0 цвета иконок поменялись местами
-- (олово стало зелёным, хром — фиолетовым), а меню литья и bobicons несут иконки Beta 8.
-- Иконки: везде заменяется путь Angels 2.0 на копию иконки Beta 8.
-- Трубы: цвет жидкости приводится к цвету иконки (олово — сиреневое, хром — зелёный).
local replacements = {
	["__angelssmeltinggraphics__/graphics/icons/molten-tin.png"] = "__zzzparanoidal__/graphics/casting-water-menu-beta8/f52dfe2944d36ba7344e.png",
	["__angelssmeltinggraphics__/graphics/icons/molten-chrome.png"] = "__zzzparanoidal__/graphics/casting-water-menu-beta8/57639bc626b0709c6bfa.png",
}

local seen = {}
local function replace(node)
	if seen[node] then return end
	seen[node] = true
	for key, value in pairs(node) do
		if type(value) == "table" then
			replace(value)
		elseif type(value) == "string" and replacements[value] then
			node[key] = replacements[value]
		end
	end
end
replace(data.raw)

local colors = {
	["angels-liquid-molten-tin"] = { r = 200 / 255, g = 186 / 255, b = 245 / 255 },
	["angels-liquid-molten-chrome"] = { r = 87 / 255, g = 130 / 255, b = 96 / 255 },
}
for name, color in pairs(colors) do
	local fluid = data.raw.fluid[name]
	if fluid then
		fluid.base_color = table.deepcopy(color)
		fluid.flow_color = table.deepcopy(color)
	end
end
