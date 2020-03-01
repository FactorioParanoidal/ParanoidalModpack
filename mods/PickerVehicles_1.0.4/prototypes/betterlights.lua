if settings.startup['picker-better-lights-cars'].value then
    for _, vehicle in pairs(data.raw['car']) do
        vehicle.light = {
            {
                minimum_darkness = 0.1,
                intensity = 0.2,
                size = 30
            },
            {
                type = 'oriented',
                minimum_darkness = 0.1,
                picture = {
                    filename = '__PickerVehicles__/graphics/lightcone-enhanced-vehicle.png',
                    priority = 'extra-high',
                    flags = {'light'},
                    scale = 2,
                    width = 350,
                    height = 370
                },
                shift = {0, -25},
                size = 2,
                intensity = 1.0,
                color = {r = 1.0, g = 1.0, b = 1.0}
            }
        }
    end
end

if settings.startup['picker-better-lights-trains'].value then
    for _, loco in pairs(data.raw['locomotive']) do
        loco.front_light = {
            {
                shift = {0, -3.5},
                intensity = 0.2,
                minimum_darkness = 0.1,
                size = 30
            },
            {
                type = 'oriented',
                minimum_darkness = 0.3,
                picture = {
                    filename = '__PickerVehicles__/graphics/lightcone-enhanced-vehicle.png',
                    priority = 'extra-high',
                    flags = {'light'},
                    scale = 2,
                    width = 350,
                    height = 370
                },
                shift = {0, -27},
                size = 2,
                intensity = 1.0,
                color = {r = 1.0, g = 1.0, b = 1.0}
            }
        }
        loco.stand_by_light = {
            {
                add_perspective = true,
                color = {b = 1},
                shift = {-0.6, -3.5},
                size = 2,
                intensity = 0.3,
                minimum_darkness = 0.3
            },
            {
                add_perspective = true,
                color = {b = 1},
                shift = {0.6, -3.5},
                size = 2,
                intensity = 0.3,
                minimum_darkness = 0.3
            },
            {
                shift = {0, -3.5},
                intensity = 0.2,
                minimum_darkness = 0.1,
                size = 30
            }
        }
    end
end
