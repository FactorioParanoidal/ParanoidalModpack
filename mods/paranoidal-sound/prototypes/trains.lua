-- New train sounds for CIS countries, Artanis_Mattias.
local variants = require("prototypes.variants")
return {breaks_sound = {filename = "__paranoidal-sound__/sound/trains/train/breaks_sound.ogg", volume = 1}, locomotive_engine = {filename = "__paranoidal-sound__/sound/trains/train/motor/CHME3_Disel.ogg", volume = 0.3}, stuk_sounds = variants("__paranoidal-sound__/sound/trains/train/rail/stuk_%d.ogg", 7, 0.5), working_sound = {filename = "__paranoidal-sound__/sound/trains/train/rail/new_SNG_train_sound_old.ogg", volume = 1}}
