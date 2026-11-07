local immersive = require("prototypes.library")
local trains = require("prototypes.trains")
local raw = data.raw
local function selected(name, source)
    return settings.startup["paranoidal-sound-" .. name].value == source
end
local function epic(prefix)
    local sounds = {}
    for i = 1, 3 do
        sounds[i] = {filename = "__paranoidal-sound__/sound/epic/" .. prefix .. i .. ".ogg", volume = 0.6}
    end
    return sounds
end
for _, row in ipairs{
    {"pistol", "gun", "pistol", "light-gunshot-"},
    {"smg", "gun", "submachine-gun", "submachine-gunshot-"},
    {"shotgun", "gun", "shotgun", "pump-shotgun-"},
    {"gun-turret", "ammo-turret", "gun-turret", "gun-turret-gunshot-"},
    {"vehicle-machine-gun", "gun", "vehicle-machine-gun", "gun-turret-gunshot-"},
} do
    if selected(row[1], "EpicWeaponSounds") then raw[row[2]][row[3]].attack_parameters.sound = epic(row[4]) end
end
if selected("grenade", "EpicWeaponSounds") then
    -- Base shares this wrapper with other explosions. Detach only the chosen grenade.
    local grenade = raw.explosion["grenade-explosion"]
    grenade.sound = table.deepcopy(grenade.sound)
    grenade.sound.variations = epic("medium-explosion-")
end
-- Not an overlap: the turret's shot and the beam's working sound have always coexisted.
raw["electric-turret"]["laser-turret"].attack_parameters.sound = epic("laser-")

local locomotive, cargo = raw.locomotive.locomotive, raw["cargo-wagon"]["cargo-wagon"]
locomotive.sound_minimum_speed = 0.1
if selected("train-engine", "newtrainsfx2") then locomotive.working_sound.sound = trains.locomotive_engine end
if selected("cargo-wheels", "newtrainsfx2") then cargo.working_sound.sound = trains.working_sound end
if selected("train-brakes", "newtrainsfx2") then
    -- Preserve smoke and the separate Immersive brake squeal; only replace the main braking sound.
    for _, effect in ipairs(locomotive.stop_trigger) do
        if effect.type == "play-sound" then effect.sound = trains.breaks_sound; break end
    end
end
for name, prototype in pairs({["locomotive-ties"] = locomotive, ["cargo-ties"] = cargo}) do
    -- Keep the trigger identity: BatteryElectricTrain made a shallow copy before us.
    prototype.drive_over_tie_trigger.sound = selected(name, "newtrainsfx2") and trains.stuk_sounds or immersive.train_drive_tie_sound
end
-- These have no Immersive alternative in the old mods, so they are not fake two-way choices.
raw["fluid-wagon"]["fluid-wagon"].working_sound.sound = trains.working_sound
for _, kind in ipairs{"fluid-wagon", "artillery-wagon"} do
    raw[kind][kind].drive_over_tie_trigger.sound = trains.stuk_sounds
end
