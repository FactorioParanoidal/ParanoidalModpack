-- Согласованные иконки: после восстановлений технологий и Reskins.
-- Только оформление; модульные исследования и игровые параметры не меняются.
local root = "__zzzparanoidal__/graphics/technology/approved-beta8/"
local icons = {
    { "basic-logistics", "basic-logistics", 256 },
    { "bi-tech-advanced-biotechnology", "bi-tech-advanced-fertilizers", 256 },
    { "bi-tech-biomass", "bi-tech-biomass", 256 },
    { "bi-tech-biomass-conversion", "bi-tech-biomass-conversion", 256 },
    { "bi-tech-biomass-reprocessing-1", "bi-tech-biomass-reprocessing-1", 256 },
    { "bi-tech-bio-farming", "bi-tech-bio-farming-1", 256 },
    { "bi-tech-bio-farming-2", "bi-tech-bio-farming-2", 256 },
    { "bi-tech-bio-farming-3", "bi-tech-bio-farming-3", 256 },
    { "bi-tech-bio-farming-4", "bi-tech-bio-farming-4", 256 },
    { "bi-tech-timber", "bi-tech-timber", 256 },
    { "bi-dart-turret", "bi-dart-turret", 128 },
    { "bi-tech-darts-1", "bi-tech-darts-1", 256 },
    { "bi-tech-darts-2", "bi-tech-darts-2", 256 },
    { "bi-tech-darts-3", "bi-tech-darts-3", 256 },
    { "military", "military-1", 128 },
    { "military-2", "military-2", 128 },
    { "military-3", "military-3", 128 },
    { "military-4", "military-4", 128 },
    { "bi-tech-stone-crushing-1", "bi-tech-stone-crushing-1", 256 },
    { "steel-processing", "steel-processing", 128 },
    { "bob-long-inserters-1", "long-inserters-1", 128 },
    { "bob-long-inserters-2", "long-inserters", 128 },
    { "mercury-processing-1", "mercury-tech", 128 },
    { "mercury-processing-2", "mercury-tech", 128 },
    -- Ниже — согласованный выбор ресурсов Beta 8, не прежние назначения из дампа.
    { "effect-transmission", "effect-transmission-1", 128 },
    { "effect-transmission-2", "effect-transmission-2", 128 },
    { "effect-transmission-3", "effect-transmission-3", 128 },
    { "angels-bio-plastic-1", "bi-tech-bio-plastics", 256 },
    { "angels-bio-plastic-2", "bi-tech-bio-plastics", 256 },
    { "angels-resin-1", "resins-tech", 128 },
    { "angels-resin-2", "resins-tech", 128 },
    { "angels-resin-3", "resins-tech", 128 },
    { "angels-rubber", "rubbers-tech", 128 },
    { "rubber-processing", "rubbers-tech", 128 },
    -- Общая тематическая картинка: старые цвета I–III не выдаём за уровни IV–V.
    { "electronics-machine-4", "electronics-machine-3", 128 },
    { "electronics-machine-5", "electronics-machine-3", 128 },
    { "garden-mutation", "farm-mutation-tech", 128 },
    { "angels-thermal-water-processing", "thermal-refining", 256 },
}

for _, entry in ipairs(icons) do
    local technology = data.raw.technology[entry[1]]
    if technology then
        technology.icons = nil
        technology.icon = root .. entry[2] .. ".png"
        technology.icon_size = entry[3]
        -- В файлах оставлен только основной квадрат, без старых полос mipmaps 1.1.
        technology.icon_mipmaps = nil
    end
end
