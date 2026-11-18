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

-- Reskins caches its original defaults in tooltip fragments before this build overrides them.
-- Refresh only those fragments; do not change setting defaults or saved player values.
local function refresh_reskins_default(value, setting)
  if type(value) ~= "table" then return end
  local key = value[1]
  if setting.type == "bool-setting"
    and (key == "reskins-defaults.true" or key == "reskins-defaults.false") then
    value[1] = "reskins-defaults." .. tostring(setting.default_value)
  elseif setting.name == "reskins-lib-tier-mapping"
    and (key == "string-mod-setting.reskins-lib-tier-mapping-progression-map"
      or key == "string-mod-setting.reskins-lib-tier-mapping-traditional-map") then
    value[1] = "string-mod-setting.reskins-lib-tier-mapping-" .. setting.default_value
  end
  for i = 2, #value do
    refresh_reskins_default(value[i], setting)
  end
end

for _, target in ipairs({
  {"bool-setting", "reskins-angels-use-angels-material-colors-pipes"},
  {"bool-setting", "reskins-angels-use-vanilla-chemical-plant-sprites"},
  {"bool-setting", "reskins-bobs-flip-bulk-inserter-icons"},
  {"bool-setting", "reskins-lib-display-notifications"},
  {"string-setting", "reskins-lib-tier-mapping"},
}) do
  local setting = data.raw[target[1]] and data.raw[target[1]][target[2]]
  if setting then refresh_reskins_default(setting.localised_description, setting) end
end
