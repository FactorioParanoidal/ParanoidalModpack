local offshore_pumps = {
	"offshore-mk0-pump",
	"offshore-mk2-pump",
	"offshore-mk3-pump",
	"offshore-mk4-pump"
}

for _, offshore_pump in pairs(offshore_pumps) do
	local animation_table = {}

	if data.raw["offshore-pump"][offshore_pump] then
		table.insert(animation_table, data.raw["offshore-pump"][offshore_pump].graphics_set.animation)
	end

	for _, animation in pairs(animation_table) do
		table.insert(animation.north.layers, {
			stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/"..offshore_pump.."-mask_North.png"),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 48,
			height = 84,
			shift = util.by_pixel(-2, -16),
			hr_version = {
				stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/hr-"..offshore_pump.."-mask_North.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.5,
				width = 90,
				height = 162,
				shift = util.by_pixel(-1, -15),
				scale = 0.5
			}
		})

		table.insert(animation.east.layers, {
			stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/"..offshore_pump.."-mask_East.png"),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 52,
			height = 16,
			shift = util.by_pixel(14, -2),
			hr_version = {
				stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/hr-"..offshore_pump.."-mask_East.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.5,
				width = 124,
				height = 102,
				shift = util.by_pixel(15, -2),
				scale = 0.5
			}
		})

		table.insert(animation.south.layers, {
			stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/"..offshore_pump.."-mask_South.png"),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 48,
			height = 96,
			shift = util.by_pixel(-2, 0),
			hr_version = {
				stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/hr-"..offshore_pump.."-mask_South.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.5,
				width = 92,
				height = 192,
				shift = util.by_pixel(-1, 0),
				scale = 0.5
			}
		})

		table.insert(animation.west.layers, {
			stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/"..offshore_pump.."-mask_West.png"),
			priority = "high",
			frame_count = 32,
			animation_speed = 0.5,
			width = 64,
			height = 52,
			shift = util.by_pixel(-16, -2),
			hr_version = {
				stripes = OSM.utils.make_stripes(8*4, "__zzzparanoidal__/graphics/entity/offshore-pump/"..offshore_pump.."/hr-"..offshore_pump.."-mask_West.png"),
				priority = "high",
				frame_count = 32,
				animation_speed = 0.5,
				width = 124,
				height = 102,
				shift = util.by_pixel(-15, -2),
				scale = 0.5
			}
		})
	end
end

