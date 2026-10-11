-- Vibrant Paint задаёт эти фразы строками, минуя стандартные ключи настроек.
local setting = data.raw["bool-setting"]["vibPaint-paintActives"]
if setting then
  for _, field in ipairs({"name", "description"}) do
    local attribute = "localised_" .. field
    if setting[attribute] then
      setting[attribute] = {"?", {"mod-setting-" .. field .. ".vibPaint-paintActives"}, setting[attribute]}
    end
  end
end
