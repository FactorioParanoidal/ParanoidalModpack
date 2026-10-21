-- animations for offshore pumps
local offshore_pumps = {
	"offshore-mk0-pump",
	"offshore-mk2-pump",
	"offshore-mk3-pump",
	"offshore-mk4-pump",
}

-- Цветная маска тира поверх корпуса насоса. HR-маски (hr-*-mask_<Dir>.png) нарисованы в кадр корпуса
-- base 2.0 один в один, поэтому размер, сдвиг и масштаб берутся у слоя корпуса. Маска статична:
-- один кадр на весь цикл анимации (раньше — 32 одинаковых stripes и низкое разрешение 1.1).
local function mask_layer(body, offshore_pump, direction)
	return {
		filename = "__zzzparanoidal__/graphics/entity/offshore-pump/"
			.. offshore_pump
			.. "/hr-"
			.. offshore_pump
			.. "-mask_"
			.. direction
			.. ".png",
		priority = "high",
		frame_count = 1,
		repeat_count = (body.frame_count or 1) * (body.repeat_count or 1),
		animation_speed = body.animation_speed,
		width = body.width,
		height = body.height,
		shift = body.shift,
		scale = body.scale,
	}
end

for _, offshore_pump in pairs(offshore_pumps) do
	local prototype = data.raw["offshore-pump"][offshore_pump]
	local animation = prototype and prototype.graphics_set and prototype.graphics_set.animation
	if animation then
		for direction, key in pairs({ North = "north", East = "east", South = "south", West = "west" }) do
			local layers = animation[key] and animation[key].layers
			if layers and layers[1] then
				table.insert(layers, mask_layer(layers[1], offshore_pump, direction))
			end
		end
	end
end
