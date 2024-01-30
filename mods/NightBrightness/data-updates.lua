
local darkness = settings.startup["nb_black_night_darkness"] and settings.startup["nb_black_night_darkness"].value

local lut_dark_127_night = "__NightBrightness__/graphics/lut_dark_127_night.png"
local lut_dark_191_night = "__NightBrightness__/graphics/lut_dark_191_night.png"
local lut_black_night = "__NightBrightness__/graphics/lut_black_night.png"


local dark_127_night = "__NightBrightness__/graphics/dark_127_night.png"
local dark_191_night = "__NightBrightness__/graphics/dark_191_night.png"
local black_night = "__NightBrightness__/graphics/black_night.png"

-- "normal-night", "dark-night", "very-dark-night", "black-night"
if darkness then
	
	if not (darkness == "normal-night") then
		
		local lut_night = lut_black_night
		local night = black_night
		if darkness == "dark-night" then
			log ('dark night darkness')
			lut_night = lut_dark_127_night
			night = dark_127_night
		elseif darkness == "very-dark-night" then
			log ('very dark night darkness')
			lut_night = lut_dark_191_night
			night = dark_191_night
		else
			log ('black night darkness')
		end
		
		data.raw["utility-constants"].default.daytime_color_lookup =
		{
			{0, "identity"},
			{0.15, "identity"},
			{0.2, "identity"},
			{0.45, lut_night},
			{0.55, lut_night},
			{0.8, "identity"},
			{0.85, "identity"},
		}

		data.raw["utility-constants"].default.zoom_to_world_daytime_color_lookup =
		{
			{0.25, "identity"},
			{0.45, night},
			{0.55, night},
			{0.75, "identity"},
		}
	else
		log ('normal darkness')
	end
else
	log ('no darkness')
end