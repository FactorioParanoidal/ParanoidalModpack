-- animations for offshore pumps
local offshore_pumps = {
	"offshore-mk0-pump",
	"offshore-mk2-pump",
	"offshore-mk3-pump",
	"offshore-mk4-pump",
}

for _, offshore_pump in pairs(offshore_pumps) do
	local animation_table = {}

	if data.raw["offshore-pump"][offshore_pump] then
		table.insert(animation_table, data.raw["offshore-pump"][offshore_pump].graphics_set.animation)
	end

	for _, animation in pairs(animation_table) do
		table.insert(animation.north.layers, {
			stripes = OSM.utils.make_stripes(
				8 * 4,
				"__zzzparanoidal__/graphics/entity/offshore-pump/"
					.. offshore_pump
					.. "/"
					.. offshore_pump
					.. "-mask_North.png"
			),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 48,
			height = 84,
			shift = util.by_pixel(-2, -16),
		})

		table.insert(animation.east.layers, {
			stripes = OSM.utils.make_stripes(
				8 * 4,
				"__zzzparanoidal__/graphics/entity/offshore-pump/"
					.. offshore_pump
					.. "/"
					.. offshore_pump
					.. "-mask_East.png"
			),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 52,
			height = 16,
			shift = util.by_pixel(14, -2),
		})

		table.insert(animation.south.layers, {
			stripes = OSM.utils.make_stripes(
				8 * 4,
				"__zzzparanoidal__/graphics/entity/offshore-pump/"
					.. offshore_pump
					.. "/"
					.. offshore_pump
					.. "-mask_South.png"
			),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 48,
			height = 96,
			shift = util.by_pixel(-2, 0),
		})

		table.insert(animation.west.layers, {
			stripes = OSM.utils.make_stripes(
				8 * 4,
				"__zzzparanoidal__/graphics/entity/offshore-pump/"
					.. offshore_pump
					.. "/"
					.. offshore_pump
					.. "-mask_West.png"
			),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 64,
			height = 52,
			shift = util.by_pixel(-16, -2),
		})
	end
end

