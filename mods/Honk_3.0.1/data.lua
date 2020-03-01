SINGLE_HONK_VOLUME = 2
DOUBLE_HONK_VOLUME = 2

-- require("prototypes.entities")

data:extend({
  {
    type = "custom-input",
    name = "honk",
    key_sequence = "H"
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
    volume = SINGLE_HONK_VOLUME
  },
  {
    type = "sound",
    name = "honk-double",
    filename = "__Honk__/sounds/honk2xshort.ogg",
    volume = DOUBLE_HONK_VOLUME
  }
})