-- Decoding the flight recorder: the recorder itself is the only research ingredient (labs that
-- take red science also take the recorder, see bnl-final.lua). scripts/recorder.lua gives the
-- flight log, the coordinates and the red science packs when it finishes.
data:extend({
    {
        type = "technology",
        name = "bnl-flight-recorder-decoding",
        icon = "__zzzparanoidal-start-bnl__/graphics/icons/flight-recorder.png",
        icon_size = 64,
        essential = false,
        effects = {
            {type = "nothing", effect_description = {"modifier-description.bnl-flight-recorder-decoding"}, icon = "__zzzparanoidal-start-bnl__/graphics/icons/flight-recorder.png", icon_size = 64},
        },
        unit = {count = 1, time = 90, ingredients = {{"bnl-flight-recorder", 1}}},
        prerequisites = {},
        order = "a-a-b[bnl]",
    },
})
