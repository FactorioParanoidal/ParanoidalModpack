require("sfx.defines")
--Сам подвижной состав
data.raw.locomotive["armored-locomotive-mk1"].sound_minimum_speed = 0.1
data.raw.locomotive["armored-locomotive-mk1"].working_sound.sound = locomotive_engine
data.raw.locomotive["armored-locomotive-mk1"].stop_trigger[3].sound = breaks_sound
data.raw.locomotive["armored-locomotive-mk1"].drive_over_tie_trigger.sound = stuk_sounds
--Вагон с пушкой
data.raw["cargo-wagon"]["cannon-wagon-mk1"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["cannon-wagon-mk1"].drive_over_tie_trigger.sound = stuk_sounds
--Огнемётный вагон
data.raw["cargo-wagon"]["flamethrower-wagon-mk1"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["flamethrower-wagon-mk1"].drive_over_tie_trigger.sound = stuk_sounds
--Вагон с автопушкой
data.raw["cargo-wagon"]["minigun-platform-mk1"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["minigun-platform-mk1"].drive_over_tie_trigger.sound = stuk_sounds
--Вагон с радарной установкой
data.raw["cargo-wagon"]["radar-platform-mk1"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["radar-platform-mk1"].drive_over_tie_trigger.sound = stuk_sounds
--Вагон с ракетной установкой
data.raw["cargo-wagon"]["rocket-platform-mk1"].working_sound.sound = working_sound
data.raw["cargo-wagon"]["rocket-platform-mk1"].drive_over_tie_trigger.sound = stuk_sounds