-- Множители загрязнения топлива Beta 8 (аудит 2026-10-13, review/fuel-pollution-audit-20261013).
-- Таблица Bio Industries 2.0 ищет старые ID (coal-crushed, solid-coke, ...) или сменила числа;
-- здесь поздним патчем возвращаются значения Beta 8. Теплотворность и прочие поля не трогаются.
local multipliers = {
  ["coal"] = 3,
  ["angels-coal-crushed"] = 2,
  ["angels-solid-coke"] = 1.25,
  ["angels-solid-carbon"] = 0.9,
  ["solid-fuel"] = 1.2,
  ["rocket-fuel"] = 2,
  ["wood"] = 1.75,
  ["angels-cellulose-fiber"] = 1.4,
}

for name, multiplier in pairs(multipliers) do
  local item = data.raw.item[name]
  if item and item.fuel_value then
    item.fuel_emissions_multiplier = multiplier
  else
    log("fuel-emissions-beta8: no fuel item " .. name)
  end
end
