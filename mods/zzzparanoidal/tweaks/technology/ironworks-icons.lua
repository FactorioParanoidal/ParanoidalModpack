-- Согласованные шестерни исследований I–V; иконки предметов и рецептов не меняются.
local root = "__zzzparanoidal__/graphics/"
local icons = {
    {"bobicons-beta8/bobicons/graphics/icons/base/iron-gear-wheel-128.png", 128},
    {"technology/ironworks-gears/brass.png", 256},
    {"technology/ironworks-gears/titanium.png", 256},
    {"technology/ironworks-gears/tungsten.png", 256},
    {"technology/ironworks-gears/nitinol.png", 256},
}

for level, entry in ipairs(icons) do
    local technology = data.raw.technology["angels-ironworks-" .. level]
    if technology then
        technology.icons = nil
        technology.icon = root .. entry[1]
        technology.icon_size = entry[2]
        technology.icon_mipmaps = nil
    end
end
