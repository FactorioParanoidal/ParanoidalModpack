data:extend{
    {
        type = "custom-input",
        name = "pipette",
        key_sequence = "",
        linked_game_control = "pipette",
    },
    -- Used by the ground diggers system to intercept the build controls so that mining
    -- drills can be converted into ground diggers when placed without nearby resources.
    {
        type = "custom-input",
        name = "PlanetsLib-build",
        key_sequence = "",
        linked_game_control = "build",
    },
    {
        type = "custom-input",
        name = "PlanetsLib-build-ghost",
        key_sequence = "",
        linked_game_control = "build-ghost",
    },
    {
        type = "custom-input",
        name = "PlanetsLib-super-forced-build",
        key_sequence = "",
        linked_game_control = "super-forced-build",
    },
}