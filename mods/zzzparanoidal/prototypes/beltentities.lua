-- Vanilla Belts
-- Changes Speed 

local base_speed = 1/32
if settings.startup["bobmods-logistics-beltoverhaul"].value then
-- 0.5x Belt

	data.raw["transport-belt"]["basic-transport-belt"].speed = 0.5 * base_speed
data.raw["underground-belt"]["basic-underground-belt"].speed = 0.5 * base_speed
				data.raw["splitter"]["basic-splitter"].speed = 0.5 * base_speed
end
-- 1x Belt

				data.raw["transport-belt"]["transport-belt"].speed = base_speed
			data.raw["underground-belt"]["underground-belt"].speed = base_speed
							data.raw["splitter"]["splitter"].speed = base_speed

-- 2x Belt

		data.raw["transport-belt"]["fast-transport-belt"].speed = 2 * base_speed
	data.raw["underground-belt"]["fast-underground-belt"].speed = 2 * base_speed
					data.raw["splitter"]["fast-splitter"].speed = 2 * base_speed

-- 4x Belt

	data.raw["transport-belt"]["express-transport-belt"].speed = 4 * base_speed
data.raw["underground-belt"]["express-underground-belt"].speed = 4 * base_speed
				data.raw["splitter"]["express-splitter"].speed = 4 * base_speed


if mods.boblogistics then
    -- 8x Purple Belt
		data.raw["transport-belt"]["turbo-transport-belt"].speed = 6 * base_speed
    data.raw["underground-belt"]["turbo-underground-belt"].speed = 6 * base_speed
					data.raw["splitter"]["turbo-splitter"].speed = 6 * base_speed
	
    data.raw["underground-belt"]["turbo-underground-belt"].max_distance = 23
	
    -- 16x Green Belt
		data.raw["transport-belt"]['ultimate-transport-belt'].speed = 12 * base_speed
    data.raw["underground-belt"]['ultimate-underground-belt'].speed = 12 * base_speed
					data.raw["splitter"]['ultimate-splitter'].speed = 12 * base_speed
	
    data.raw["underground-belt"]['ultimate-underground-belt'].max_distance = 27
    -- Green belt is very buggy at 16x speed
	--[[
    data.raw.technology["bob-logistics-5"].enabled =        false
    data.raw.recipe['ultimate-transport-belt'].hidden =     true
    data.raw.recipe['ultimate-underground-belt'].hidden =   true
    data.raw.recipe['ultimate-splitter'].hidden =           true
	
    --Bob Miniloader
    if mods.miniloader then
        data.raw.technology["ultimate-miniloader"].enabled = false
    end
	]]
end

if mods.miniloader then
	local base_inserter_speed = base_speed * 4
	local base_display_speed = base_speed * 480
	local font_open_tags = "[font=default-semibold][color=255,230,192]"
	local font_close_tags = ":[/color][/font] "
	local speed_desc = {"description.belt-speed"}
	local items_desc = {"description.belt-items"}
	local suffix = {"per-second-suffix"}
	if settings.startup["bobmods-logistics-beltoverhaul"].value then
		data.raw["inserter"]["basic-miniloader-inserter"].rotation_speed = 0.5 * base_inserter_speed
		data.raw["inserter"]["basic-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 0.5 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["basic-miniloader-loader"].speed = 0.5 * base_speed
	end
	data.raw["inserter"]["miniloader-inserter"].rotation_speed = 1 * base_inserter_speed
	data.raw["inserter"]["miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 1 * base_display_speed, " ", items_desc, suffix}
	data.raw["loader-1x1"]["miniloader-loader"].speed = 1 * base_speed
	data.raw["inserter"]["fast-miniloader-inserter"].rotation_speed = 2 * base_inserter_speed
	data.raw["inserter"]["fast-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 2 * base_display_speed, " ", items_desc, suffix}
	data.raw["loader-1x1"]["fast-miniloader-loader"].speed = 2 * base_speed
	data.raw["inserter"]["express-miniloader-inserter"].rotation_speed = 4 * base_inserter_speed
	data.raw["inserter"]["express-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 4 * base_display_speed, " ", items_desc, suffix}
	data.raw["loader-1x1"]["express-miniloader-loader"].speed = 4 * base_speed
	if mods.boblogistics then
		data.raw["inserter"]["turbo-miniloader-inserter"].rotation_speed = 6 * base_inserter_speed
		data.raw["inserter"]["turbo-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 6 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["turbo-miniloader-loader"].speed = 6 * base_speed
		data.raw["inserter"]["ultimate-miniloader-inserter"].rotation_speed = 12 * base_inserter_speed
		data.raw["inserter"]["ultimate-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 12 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["ultimate-miniloader-loader"].speed = 12 * base_speed
	end
	
	if settings.startup["miniloader-enable-filter"].value then
		if settings.startup["bobmods-logistics-beltoverhaul"].value then
			data.raw["inserter"]["basic-filter-miniloader-inserter"].rotation_speed = 0.5 * base_inserter_speed
			data.raw["inserter"]["basic-filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 0.5 * base_display_speed, " ", items_desc, suffix}
			data.raw["loader-1x1"]["basic-filter-miniloader-loader"].speed = 0.5 * base_speed
		end
		data.raw["inserter"]["filter-miniloader-inserter"].rotation_speed = 1 * base_inserter_speed
		data.raw["inserter"]["filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 1 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["filter-miniloader-loader"].speed = 1 * base_speed
		data.raw["inserter"]["fast-filter-miniloader-inserter"].rotation_speed = 2 * base_inserter_speed
		data.raw["inserter"]["fast-filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 2 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["fast-filter-miniloader-loader"].speed = 2 * base_speed
		data.raw["inserter"]["express-filter-miniloader-inserter"].rotation_speed = 4 * base_inserter_speed
		data.raw["inserter"]["express-filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 4 * base_display_speed, " ", items_desc, suffix}
		data.raw["loader-1x1"]["express-filter-miniloader-loader"].speed = 4 * base_speed
		if mods.boblogistics then
			data.raw["inserter"]["turbo-filter-miniloader-inserter"].rotation_speed = 6 * base_inserter_speed
			data.raw["inserter"]["turbo-filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 6 * base_display_speed, " ", items_desc, suffix}
			data.raw["loader-1x1"]["turbo-filter-miniloader-loader"].speed = 6 * base_speed
			data.raw["inserter"]["ultimate-filter-miniloader-inserter"].rotation_speed = 12 * base_inserter_speed
			data.raw["inserter"]["ultimate-filter-miniloader-inserter"].localised_description = {"", font_open_tags, speed_desc, font_close_tags, 12 * base_display_speed, " ", items_desc, suffix}
			data.raw["loader-1x1"]["ultimate-filter-miniloader-loader"].speed = 12 * base_speed
		end
	end
end
