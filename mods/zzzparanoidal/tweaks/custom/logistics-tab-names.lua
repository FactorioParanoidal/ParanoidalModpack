-- Названия и иконки двух первых вкладок; ряды и рецепты не меняются.
-- localised_name, а не ключи locale: ParanoidalLocale грузится позже и перебил бы их.
local groups = data.raw["item-group"]
local storage, logistics = groups.logistics, groups["bob-logistics"]
if not (storage and logistics) then return end

-- «Логистика» (конвейеры, трубы, манипуляторы) получает прежнюю иконку первой вкладки.
logistics.icon = storage.icon
logistics.icon_size = storage.icon_size
logistics.icons = storage.icons and table.deepcopy(storage.icons) or nil
logistics.localised_name = {"item-group-name.paranoidal-logistics"}

-- Первая вкладка: сундуки, склады и ЛЭП.
-- Иконка технологии 256 px: иконки предметов 64 px на вкладке (128) растягиваются и мылят.
storage.icon = "__base__/graphics/technology/electric-energy-distribution-1.png"
storage.icon_size = 256
storage.icons = nil
storage.localised_name = {"item-group-name.paranoidal-storage-and-power"}
