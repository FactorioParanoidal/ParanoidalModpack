require("__stdlib__/stdlib/core")

data:extend {
    {
        type = "custom-input",
        name = "dolly-move-north",
        key_sequence = "SHIFT + UP"
    },
    {
        type = "custom-input",
        name = "dolly-move-west",
        key_sequence = "SHIFT + LEFT"
    },
    {
        type = "custom-input",
        name = "dolly-move-south",
        key_sequence = "SHIFT + DOWN"
    },
    {
        type = "custom-input",
        name = "dolly-move-east",
        key_sequence = "SHIFT + RIGHT"
    },
    {
        type = "custom-input",
        name = "dolly-rotate-rectangle",
        key_sequence = "PAD DELETE"
    },
    {
        type = "custom-input",
        name = "dolly-rotate-saved",
        key_sequence = "PAD 0",
        linked_game_control = "rotate"
    },
    {
        type = "custom-input",
        name = "dolly-rotate-saved-reverse",
        key_sequence = "SHIFT + PAD 0",
        linked_game_control = "reverse-rotate"
    }
}
