local ICON = "__carbon-capture2__/graphics/icons/"

local items = {}

for tier = 1, 6 do
	local name = "CW-air-filter-machine-" .. tier
	items[#items + 1] = {
		type = "item",
		name = name,
		icon = ICON .. "air-filter-machine-" .. tier .. ".png",
		icon_size = 64,
		subgroup = "production-machine",
		order = "e[air-filter-machine-" .. tier .. "]",
		place_result = name,
		stack_size = 10,
	}
end

-- Icons 120×64: 64 px with mipmaps (2.0 detects them from the picture width).
for _, filter in ipairs({
	{ name = "CW-empty-air-filter", icon = "empty-air-filter", order = "h[air-filter]-a[empty-air-filter]" },
	{ name = "CW-air-filter", icon = "air-filter", order = "h[air-filter]-b[air-filter]" },
	{ name = "CW-used-air-filter", icon = "used-air-filter", order = "h[air-filter]-i[used-air-filter]" },
}) do
	items[#items + 1] = {
		type = "item",
		name = filter.name,
		icon = ICON .. filter.icon .. ".png",
		icon_size = 64,
		subgroup = "raw-material",
		order = filter.order,
		stack_size = 200,
	}
end

data:extend(items)
