require("sfx.defines")
--Локомотив
data.raw.locomotive.locomotive.sound_minimum_speed = 0.1
data.raw.locomotive.locomotive.working_sound.sound = locomotive_engine
data.raw.locomotive.locomotive.stop_trigger[3].sound = breaks_sound
data.raw.locomotive.locomotive.drive_over_tie_trigger.sound = stuk_sounds
--Жидкостный вагон
data.raw["fluid-wagon"]["fluid-wagon"].working_sound.sound = working_sound
data.raw["fluid-wagon"]["fluid-wagon"].drive_over_tie_trigger.sound = stuk_sounds
--Артеллерийский вагон
--data.raw["artillery-wagon"]["artillery-wagon"].working_sound.sound = working_sound --drd tweak from Naylok#4293
data.raw["artillery-wagon"]["artillery-wagon"].drive_over_tie_trigger.sound = stuk_sounds
--Грузовой вагон
data.raw["cargo-wagon"]["cargo-wagon"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["cargo-wagon"].drive_over_tie_trigger.sound = stuk_sounds
