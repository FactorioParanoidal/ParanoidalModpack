--Переменные
local volume_stuk = 0.5 -- Громкость сука колёс (не фонового)
local locomotive_engine_volume = 0.3 -- Громкость двигателя локомотива
local breaks_sound_volume = 1 --  Громкость работы тормоза при остановке
local working_sound_volume = 1.0 -- Громкость фонового шума поезда (гул поездов с ритмичным постукиванием)
stuk_sounds = {
         {
		filename = "__newtrainsfx__/sfx/train/rail/stuk_1.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_2.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_3.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_4.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_5.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_6.ogg",
		volume = volume_stuk
		},
		{
		filename = "__newtrainsfx__/sfx/train/rail/stuk_7.ogg",
		volume = volume_stuk
		}
}

locomotive_engine = {
          filename = "__newtrainsfx__/sfx/train/motor/CHME3_Disel.ogg",
          volume = locomotive_engine_volume
}

breaks_sound = {
          filename = "__newtrainsfx__/sfx/train/breaks_sound.ogg",
          volume = breaks_sound_volume
}

working_sound = {
          filename = "__newtrainsfx__/sfx/train/rail/new_SNG_train_sound_old.ogg",
          volume = working_sound_volume
}
