-- Генерация рыбы: в воде появляется только Луч Санты (angels-alien-fish-3).
-- Остальные виды (ванильная рыба, Левак, медуза) не генерируются; прототипы и предметы остаются.
-- Плотность: раньше четыре вида делили клетки воды по чётности X/Y, по 0.01 каждый
-- (суммарно ~0.01 на клетку). Теперь Луч Санты на всех клетках в 5 раз реже: 0.002.
local santa = "angels-alien-fish-3"
local removed = {"fish", "angels-alien-fish-1", "angels-alien-fish-2"}

if data.raw.fish[santa] then
  local nauvis = data.raw.planet and data.raw.planet.nauvis
  local settings = nauvis and nauvis.map_gen_settings and nauvis.map_gen_settings.autoplace_settings
    and nauvis.map_gen_settings.autoplace_settings.entity and nauvis.map_gen_settings.autoplace_settings.entity.settings

  for _, name in ipairs(removed) do
    local fish = data.raw.fish[name]
    if fish then fish.autoplace = nil end
    if settings then settings[name] = nil end
  end

  local autoplace = data.raw.fish[santa].autoplace or {}
  autoplace.probability_expression = "0.002"
  data.raw.fish[santa].autoplace = autoplace
  if settings then settings[santa] = settings[santa] or {} end
end
