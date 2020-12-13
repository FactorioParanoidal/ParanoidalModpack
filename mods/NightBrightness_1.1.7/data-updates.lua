
local black_night_enabled = settings.startup["nb_black_night"] and settings.startup["nb_black_night"].value or false

if black_night_enabled then
	
--	data.raw["utility-constants"].default.daytime_color_lookup[4] = {0.45, "__core__/graphics/color_luts/lut-night.png"}
--	data.raw["utility-constants"].default.daytime_color_lookup[5] = {0.55, "__core__/graphics/color_luts/lut-night.png"}

	local filename = "__NightBrightness__/graphics/lut-night.png"

	local dcl = data.raw["utility-constants"].default.daytime_color_lookup
	dcl[4][2]=filename
	dcl[5][2]=filename



--	data.raw["utility-constants"].default.zoom_to_world_daytime_color_lookup[2] = {0.45, "__core__/graphics/color_luts/night.png"}
--	data.raw["utility-constants"].default.zoom_to_world_daytime_color_lookup[3] = {0.55, "__core__/graphics/color_luts/night.png"}

	filename = "__NightBrightness__/graphics/night.png"

	local ztwdcl = data.raw["utility-constants"].default.zoom_to_world_daytime_color_lookup

	ztwdcl[2][2]=filename
	ztwdcl[3][2]=filename

end