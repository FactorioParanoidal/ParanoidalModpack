-- Dollies (from even-pickier-dollies): keys to move and rotate placed entities

data:extend {
    -- move
    {
        type = "custom-input",
        name = "dolly-move-north",
        key_sequence = "SHIFT + UP",
        hidden_in_factoriopedia = true,
    },
    {
        type = "custom-input",
        name = "dolly-move-west",
        key_sequence = "SHIFT + LEFT",
        hidden_in_factoriopedia = true,
    },
    {
        type = "custom-input",
        name = "dolly-move-south",
        key_sequence = "SHIFT + DOWN",
        hidden_in_factoriopedia = true,
    },
    {
        type = "custom-input",
        name = "dolly-move-east",
        key_sequence = "SHIFT + RIGHT",
        hidden_in_factoriopedia = true,
    },
    -- rotate
    {
        type = "custom-input",
        name = "dolly-rotate-rectangle",
        key_sequence = "KP_0",
        hidden_in_factoriopedia = true,
    },
    {
        type = "custom-input",
        name = "dolly-rotate-rectangle-reverse",
        key_sequence = "SHIFT + KP_0",
        hidden_in_factoriopedia = true,
    },
    -- attach to existing rotate key
    {
        type = "custom-input",
        name = "dolly-rotate-saved",
        key_sequence = "",
        linked_game_control = "rotate",
        hidden_in_factoriopedia = true,
    },
    {
        type = "custom-input",
        name = "dolly-rotate-saved-reverse",
        key_sequence = "",
        linked_game_control = "reverse-rotate",
        hidden_in_factoriopedia = true,
    }
}

-- mod-data object other mods can extend with names that must not move (name kept from even-pickier-dollies)

data:extend({
    {
        type = 'mod-data',
        name = 'even-pickier-dollies',
        data_type = 'even-pickier-dollies',
        data = {
            blacklist_names = {},
        },
    }
})
