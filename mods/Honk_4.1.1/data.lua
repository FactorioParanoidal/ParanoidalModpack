data:extend({
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
  {
    type = "sound",
    name = "honk-single",
    filename = "__Honk__/sounds/honklong.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range"].value,
    volume = settings.startup["honk-sound-volume"].value
  },
  {
    type = "sound",
    name = "honk-double",
    filename = "__Honk__/sounds/honk2xshort.ogg",
    category = "environment",
    audible_distance_modifier = settings.startup["honk-sound-range"].value,
    volume = settings.startup["honk-sound-volume"].value
  }
})