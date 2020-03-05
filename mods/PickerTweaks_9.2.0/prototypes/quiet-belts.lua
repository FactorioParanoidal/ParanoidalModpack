for _, entity in pairs(data.raw["transport-belt"]) do
    if entity.working_sound and entity.working_sound.sound then
        entity.working_sound.sound.volume = (entity.working_sound.sound.volume or 1) * settings.startup['picker-belt-sounds'].value
    end
end
