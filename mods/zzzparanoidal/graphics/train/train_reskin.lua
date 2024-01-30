--локомотив мк1
if settings.startup["res_loc_1"].value then
data.raw.locomotive.locomotive.pictures =
{
    priority = "very-low",
    width = 512,
    height = 512,
    direction_count = 128,
    filenames =
    {
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-0.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-1.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-2.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-3.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-4.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-5.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-6.png",
        "__zzzparanoidal__/graphics/train/t1/se_cbl_sheet-7.png",
    },
    line_length = 4,
    lines_per_file = 4,
    shift = {0, -1.125},
    scale = 0.5,
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive.locomotive.wheels =
{
	priority = "very-low",
	width = 1,
	height = 1,
	direction_count = 1,
	filenames =
	{"__JunkTrain3__/graphics/nothing.png",},
	line_length = 1,
	lines_per_file = 1,
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive.locomotive.water_reflection = nil
-------------------------------------------------------------------------------------------------
data.raw.locomotive.locomotive.allow_manual_color = false
-------------------------------------------------------------------------------------------------
data.raw.locomotive.locomotive.burner.smoke[1] = 
{
    name = "train-smoke",
    deviation = {0.3, 0.3},
    frequency = 300,
    position = {0, -2.75},
    starting_frame = 0,
    starting_frame_deviation = 60,
    height = 3,
    height_deviation = 0.5,
    starting_vertical_speed = 0.2,
    starting_vertical_speed_deviation = 0.1,
}
end
--###############################################################################################
--локомотив мк2
if settings.startup["res_loc_2"].value then
data.raw.locomotive["bob-locomotive-2"].pictures =
{
    priority = "very-low",
    width = 512,
    height = 512,
    scale = 0.5,
    direction_count = 128,
    filenames = {
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-0.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-1.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-2.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-3.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-4.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-5.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-6.png",
      "__zzzparanoidal__/graphics/train/t2/se_wt580of_sheet-7.png"
    },
    line_length = 4,
    lines_per_file = 4,
    shift = {0, -1.125}
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].wheels =
{
	priority = "very-low",
	width = 1,
	height = 1,
	direction_count = 1,
	filenames =
	{"__JunkTrain3__/graphics/nothing.png",},
	line_length = 1,
	lines_per_file = 1,
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].water_reflection = nil
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].allow_manual_color = false
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-2"].burner.smoke[1] = 
{
    name = "train-smoke",
    deviation = {0.3, 0.3},
    frequency = 200,
    position = {0, -2.75},
    starting_frame = 0,
    starting_frame_deviation = 60,
    height = 2,
    height_deviation = 0.5,
    starting_vertical_speed = 0.2,
    starting_vertical_speed_deviation = 0.1
}
end
--###############################################################################################
--локомотив мк3
if settings.startup["res_loc_3"].value then
data.raw.locomotive["bob-locomotive-3"].pictures =
{
    priority = "very-low",
    width = 512,
    height = 512,
    scale = 0.5,
    direction_count = 128,
    filenames = {
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-0.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-1.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-2.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-3.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-4.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-5.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-6.png",
        "__zzzparanoidal__/graphics/train/t3/LOK_D1_sheet-7.png"
    },
    line_length = 4,
    lines_per_file = 4,
    shift = {0, -1.125}
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-3"].wheels =
{
	priority = "very-low",
	width = 1,
	height = 1,
	direction_count = 1,
	filenames =
	{"__JunkTrain3__/graphics/nothing.png",},
	line_length = 1,
	lines_per_file = 1,
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-3"].water_reflection = nil
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-3"].allow_manual_color = false
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bob-locomotive-3"].burner.smoke[1] = 
{
    name = "train-smoke",
    deviation = {0.3, 0.3},
    frequency = 100,
    position = {0, 0},
    starting_frame = 0,
    starting_frame_deviation = 60,
    height = 3,
    height_deviation = 0.5,
    starting_vertical_speed = 0.2,
    starting_vertical_speed_deviation = 0.1
}
end
--###############################################################################################
--электричка
if settings.startup["res_loc_e"].value then
data.raw.locomotive["bet-locomotive"].pictures =
{
    priority = "very-low",
    width = 256,
    height = 256,
    direction_count = 128,
    filenames =
    {
        "__zzzparanoidal__/graphics/train/electric/kurts_sheet-0.png",
        "__zzzparanoidal__/graphics/train/electric/kurts_sheet-1.png",
    },
    line_length = 8,
    lines_per_file = 8,
    shift = {0.42, -1.125}
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bet-locomotive"].wheels =
{
	priority = "very-low",
	width = 1,
	height = 1,
	direction_count = 1,
	filenames =
	{"__JunkTrain3__/graphics/nothing.png",},
	line_length = 1,
	lines_per_file = 1,
}
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bet-locomotive"].water_reflection = nil
-------------------------------------------------------------------------------------------------
data.raw.locomotive["bet-locomotive"].allow_manual_color = false
end
-------------------------------------------------------------------------------------------------
--поправка громкости звука двигателя
data.raw.locomotive["bet-locomotive"].working_sound.sound = {filename = "__BatteryElectricTrain__/sounds/bet-locomotive.ogg", volume = 0.8}
data.raw.locomotive["bet-locomotive"].working_sound.deactivate_sound = {filename = "__BatteryElectricTrain__/sounds/bet-locomotive-deactivate.ogg", volume = 0.8}
-------------------------------------------------------------------------------------------------
--убираем "тормозной пар" но оставляем звук
data.raw.locomotive["bet-locomotive"].stop_trigger =
{
    {
        type = "play-sound",
        sound = {filename = "__base__/sound/train-breaks.ogg", volume = 0.3} 
    },
    {
        type = "play-sound",
        sound = {
            {filename = "__base__/sound/train-brake-screech.ogg", volume = 0.3},
            {filename = "__base__/sound/train-brake-screech-1.ogg", volume = 0.3}
        }
    }
}
--###############################################################################################