if settings.startup[Settings.labsAbsorbPollution].value
then
    local absorbPerSecond = { pollution = 0.01 }
    data.raw.tile["lab-dark-1"].absorptions_per_second = absorbPerSecond
    data.raw.tile["lab-dark-2"].absorptions_per_second = absorbPerSecond
end

if settings.startup[Settings.customLabTiles].value
then
    data.raw.tile["lab-dark-1"].variants = {
        main = {
            {
                picture = BPSB.path .. "/graphics/lab-dark-1.png",
                count = 1,
                size = 1,
                scale = 0.5
            }
        },
        empty_transitions = true
    }
    data.raw.tile["lab-dark-1"].map_color = { r = 0.04, g = 0.16, b = 0.22 }

    data.raw.tile["lab-dark-2"].variants = {
        main = {
            {
                picture = BPSB.path .. "/graphics/lab-dark-2.png",
                count = 1,
                size = 1,
                scale = 0.5
            }
        },
        empty_transitions = true
    }
    data.raw.tile["lab-dark-2"].map_color = { r = 0.05, g = 0.18, b = 0.25 }
end
