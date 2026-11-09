--- custom event for submarine submerged
--- also triggers on character submerged with abyssal diving gear
--- event table: {entity, old_surface_index, old_position}
data:extend {{
    type = "custom-event",
    name = "maraxsis-on-submerged",
}}

data:extend {{
    type = "custom-input",
    key_sequence = "",
    linked_game_control = "mine",
    name = "mine"
}}

data:extend {{
    type = "custom-input",
    name = "build",
    key_sequence = "",
    linked_game_control = "build"
}}

data:extend {{
    type = "custom-input",
    name = "build-ghost",
    key_sequence = "",
    linked_game_control = "build-ghost"
}}

data:extend {{
    type = "custom-input",
    name = "super-forced-build",
    key_sequence = "",
    linked_game_control = "super-forced-build"
}}

-- https://github.com/notnotmelon/maraxsis/issues/255
-- Paranoidal fork: Factorissimo of the build defines this input (with its own key); only define it when it is absent.
if not data.raw["custom-input"]["factory-open-outside-surface-to-remote-view"] then
    data:extend {{
        type = "custom-input",
        name = "factory-open-outside-surface-to-remote-view",
        key_sequence = "COMMAND + mouse-button-2",
        controller_key_sequence = "controller-leftstick"
    }}
end
