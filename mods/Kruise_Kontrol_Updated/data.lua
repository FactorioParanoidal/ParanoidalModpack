local input =
{
  name = "klient-move-to",
  type = "custom-input",
  key_sequence = "mouse-button-2",
}

local alt_input =
{
  name = "klient-alt-move-to",
  type = "custom-input",
  consuming = "game-only",
  key_sequence = "CONTROL + ALT + mouse-button-2"
}

local enqueue_input =
{
  name = "klient-enqueue-command",
  type = "custom-input",
  consuming = "game-only",
  key_sequence = "CONTROL + ALT + SHIFT + mouse-button-2"
}

local cancel_w =
{
  name = "klient-cancel-w",
  type = "custom-input",
  linked_game_control = "move-up",
  consuming = "none",
  key_sequence = ""
}

local cancel_a =
{
  name = "klient-cancel-a",
  type = "custom-input",
  linked_game_control = "move-left",
  consuming = "none",
  key_sequence = ""
}

local cancel_s =
{
  name = "klient-cancel-s",
  type = "custom-input",
  linked_game_control = "move-down",
  consuming = "none",
  key_sequence = ""
}

local cancel_d =
{
  name = "klient-cancel-d",
  type = "custom-input",
  linked_game_control = "move-right",
  consuming = "none",
  key_sequence = ""
}

local cancel_enter =
{
  name = "klient-cancel-enter",
  type = "custom-input",
  consuming = "none",
  key_sequence = "RETURN"
}


data:extend
{
  --input,
  alt_input,
  --enqueue_input
  cancel_w,
  cancel_a,
  cancel_s,
  cancel_d,
  cancel_enter
}
