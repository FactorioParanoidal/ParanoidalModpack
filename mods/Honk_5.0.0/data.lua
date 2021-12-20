soundpath = "__Honk__/sounds/"

-- Custom Inputs
data:extend{
  {
    type = "custom-input",
    name = "honk",
    key_sequence = "H"
  },
  {
    type = "custom-input",
    name = "honk-alt",
    key_sequence = "SHIFT + H"
  },
  {
    type = "custom-input",
    name = "toggle-train-control",
    key_sequence = "J"
  },
}

-- Horn sounds
data:extend{
  -- Diesel
  {
    type = "sound",
    name = "honk-single-diesel",
    filename = soundpath.."honklong.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-diesel"].value,
    volume = settings.startup["honk-sound-volume-diesel"].value
  },
  {
    type = "sound",
    name = "honk-double-diesel",
    filename = soundpath.."honk2xshort.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-diesel"].value,
    volume = settings.startup["honk-sound-volume-diesel"].value
  },

  -- Steam
  {
    type = "sound",
    name = "honk-single-steam",
    filename = soundpath.."honk-single-steam-train.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-steam"].value,
    volume = settings.startup["honk-sound-volume-steam"].value
  },
  {
    type = "sound",
    name = "honk-double-steam",
    filename = soundpath.."honk-double-steam-train.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-steam"].value,
    volume = settings.startup["honk-sound-volume-steam"].value
  },

  -- Boat
  {
    type = "sound",
    name = "honk-single-boat",
    filename = soundpath.."honk-single-boat.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-boat"].value,
    volume = settings.startup["honk-sound-volume-boat"].value
  },
  {
    type = "sound",
    name = "honk-double-boat",
    filename = soundpath.."honk-double-boat.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-boat"].value,
    volume = settings.startup["honk-sound-volume-boat"].value
  },

  -- Ship
  {
    type = "sound",
    name = "honk-single-ship",
    filename = soundpath.."honk-single-ship.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-ship"].value,
    volume = settings.startup["honk-sound-volume-ship"].value
  },
  {
    type = "sound",
    name = "honk-double-ship",
    filename = soundpath.."honk-double-ship.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range-ship"].value,
    volume = settings.startup["honk-sound-volume-ship"].value
  },
}
