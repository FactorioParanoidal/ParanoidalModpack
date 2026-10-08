-- Beta 8 PickerTweaks (grfwoot / EnhancedFlashlight): restore the character's
-- beam and surrounding light after AAI's wide-flashlight replacement.
-- Vehicles, night LUTs and seasonal surface parameters are deliberately untouched.
local light = {
    {
        minimum_darkness = 0.1,
        intensity = 0.3,
        size = 40,
        color = {r = 1, g = 1, b = 1},
    },
    {
        type = "oriented",
        minimum_darkness = 0.1,
        picture = {
            filename = "__zzzparanoidal__/graphics/light/lightcone-enhanced-beta8.png",
            priority = "extra-high",
            flags = {"light"},
            scale = 2,
            width = 350,
            height = 370,
        },
        shift = {0, -24},
        size = 2,
        intensity = 0.9,
        color = {r = 1, g = 1, b = 1},
    },
}

for _, character in pairs(data.raw.character) do
    if character.light then
        character.light = table.deepcopy(light)
    end
end
