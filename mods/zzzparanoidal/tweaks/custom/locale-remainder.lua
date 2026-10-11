-- Строковые аргументы сторонних шаблонов локализуются в слое сборки.
-- RU-only ключи сохраняют исходный текст для остальных языков.
for _, technology in pairs(data.raw.technology or {}) do
  local description = technology.localised_description
  if type(description) == "table" and type(description[2]) == "string" then
    local unit
    if description[1] == "technology-description.qol-inventory-size" then
      unit = "inventory-slots"
    elseif description[1] == "technology-description.qol-player-reach" then
      unit = "tiles"
    end
    if unit then
      local count, suffix = description[2]:match("^(%d+) (%a+)$")
      if count and (suffix == "slot" or suffix == "slots" or suffix == "tile" or suffix == "tiles") then
        description[2] = {"?", {"paranoidal-locale-units." .. unit, count}, description[2]}
      end
    end
  end
end

-- Названия модулей в достижениях соответствуют названиям базовой игры.
for _, module in ipairs({"efficiency", "productivity", "speed"}) do
  for tier = 2, 3 do
    local achievement = data.raw["produce-achievement"]["crafting-with-" .. module .. "-" .. tier]
    if achievement and type(achievement.localised_name) == "table" then
      local title = achievement.localised_name[2]
      if type(title) == "table" and title[1] == "more-achievements.crafting-with" then
        achievement.localised_name[2] = {"achievement-name.crafting-with-" .. module}
      end
    end
  end
end

for tier = 1, 10 do
  local cloud = data.raw["smoke-with-trigger"]["poison-cloud-v" .. tier .. "-cloud-rampant"]
  if cloud and cloud.localised_name then
    cloud.localised_name = {"?", {"paranoidal-locale-remainder.poison-cloud"}, cloud.localised_name}
  end
  local healing_cloud = data.raw["smoke-with-trigger"]["poison-cloud-Dmg-Heal" .. tier .. "-cloud-rampant"]
  if healing_cloud and healing_cloud.localised_name then
    healing_cloud.localised_name = {"?", {"paranoidal-locale-remainder.healing-poison-cloud"}, healing_cloud.localised_name}
  end
end

-- Локализуются подписи уже существующих служебных объектов.
-- Исходные строки остаются fallback для остальных языков.
local service_labels = {
  ["dummy-elevated-curved-rail-a"] = {key = "dummy", source = "dummy"},
  ["dummy-elevated-curved-rail-b"] = {key = "dummy", source = "dummy"},
  ["dummy-elevated-half-diagonal-rail"] = {key = "dummy", source = "dummy"},
  ["dummy-elevated-straight-rail"] = {key = "dummy", source = "dummy"},
  ["dummy-rail-ramp"] = {key = "dummy", source = "dummy"},
  ["dummy-rail-support"] = {key = "dummy", source = "dummy"},
  ["dummy-spider-unit"] = {key = "dummy", source = "dummy"},
  ["uranium-cannon-explosion"] = {
    key = "uranium-cannon-explosion", source = "entity-name.uranium-cannon-explosion"
  },
}
for _, prototypes in pairs(data.raw) do
  for name, label in pairs(service_labels) do
    local prototype = prototypes[name]
    if prototype and prototype.localised_name == label.source then
      prototype.localised_name = {
        "?", {"paranoidal-locale-remainder." .. label.key}, prototype.localised_name
      }
    end
  end
end
