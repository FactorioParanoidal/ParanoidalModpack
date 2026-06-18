-- Синхронизация скорости AAI-лоадеров с лентами.
-- Bob's logistics (boblogistics/prototypes/aai-loaders.lua, data.lua) задаёт скорость
-- лоадеров через set_belt_speed по своей шкале; ленты переопределены в belts.lua
-- (data-final-fixes, выполняется после Bob) на шкалу 0.5/1/2/4/6/12. Возвращаем
-- каждому лоадеру скорость его ленты. Подключается после tweaks.entity.belts.
if mods["aai-loaders"] then
  local belt_to_loader = {
    ["bob-basic-transport-belt"]    = "aai-basic-loader",
    ["transport-belt"]              = "aai-loader",
    ["fast-transport-belt"]         = "aai-fast-loader",
    ["express-transport-belt"]      = "aai-express-loader",
    ["turbo-transport-belt"]        = "aai-turbo-loader",
    ["bob-ultimate-transport-belt"] = "aai-ultimate-loader",
  }
  for belt_name, loader_name in pairs(belt_to_loader) do
    local belt = data.raw["transport-belt"][belt_name]
    local loader = data.raw["loader-1x1"][loader_name]
    if belt and loader then
      loader.speed = belt.speed
    end
  end
end
