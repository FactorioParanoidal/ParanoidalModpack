--[[
    "name": "belt-legacy",
    "title": "Belt Legacy",
    "author": "fishycat",
    "description": "Tired of accidentally replacing underground-belts and splitters with transport-belts?
                    Then this small mod is for you. When activated they can't fast-replace each other anymore.
                    For a safer bus building. For Vanilla and for Bob's basic, green and purple belt stuff.",
--]] --
if settings.startup['picker-legacy-belt-fast-replace'].value then
    for _, splitter in pairs(data.raw['splitter']) do splitter.fast_replaceable_group = 'splitter' end
    for _, ug in pairs(data.raw['underground-belt']) do ug.fast_replaceable_group = 'underground-belt' end
end

--[[
	"name": "silent-belts-4",
	"title": "Silent Belts 4",
	"author": "Azias, Wakaba-chan, GotLag, Alan",
	"contact": "Mod portal or Github",
	"homepage": "https://github.com/aziascreations/Factorio-Silent-Belts-4",
    "description": "Disables running sound for all belts, including modded ones.
                    For those who get annoyed with that squeaking noise chasing you all over the base.",
--]] --
local sound_level = settings.startup['picker-belt-sounds'].value
if sound_level ~= 1 then
    for _, entity in pairs(data.raw['transport-belt']) do
        if entity.working_sound and entity.working_sound.sound then
            entity.working_sound.sound.volume = (entity.working_sound.sound.volume or 1) * sound_level
        end
    end
end
