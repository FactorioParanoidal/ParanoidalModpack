local weapons = {"pistol", "smg", "shotgun", "gun-turret", "vehicle-machine-gun", "grenade"}
local trains = {"train-engine", "cargo-wheels", "train-brakes", "locomotive-ties", "cargo-ties"}
local function add(list, group, first, second, default)
    for i, name in ipairs(list) do
        data:extend{{
            type = "string-setting", name = "paranoidal-sound-" .. name, setting_type = "startup",
            default_value = default, allowed_values = {first, second},
            order = group .. string.format("%02d", i),
            localised_description = {"mod-setting-description.paranoidal-sound-" .. group},
        }}
    end
end
add(weapons, "weapons", "EpicWeaponSounds", "immersive-sounds2", "immersive-sounds2")
add(trains, "trains", "newtrainsfx2", "immersive-sounds2", "newtrainsfx2")
